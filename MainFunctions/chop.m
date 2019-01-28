function [c,options] = chop(x,options)
%CHOP    Round matrix elements to lower precision.
%   CHOP(X,options) is the matrix obtained by rounding the elements of
%   the array X to an arithmetic specified by the structure options.
%   The precision is specified by options.precision, which is one of 
%     'b', 'bfloat16'           - bfloat16,
%     'h', 'half', 'fp16'       - IEEE half precision (the default),
%     's', 'single', 'fp32'     - IEEE single precision,
%     'd', double', 'fp64'      - IEEE double precision.
%   options.subnormal specifies whether subnormal numbers are supported
%   (if they are not, subnormals are flushed to zero):
%      0 = do not support subnormals (the default for bfloat16),
%      1 = support subnormals (the default for fp16, fp32 and fp64).
%   If options is omitted or only partially specified then 
%      - if this is the first call to CHOP then it uses defaults of fp16
%        and supports subnormals for fp16, fp32 and fp64
%        and does not support subnormals for bfloat16,
%      - on subsequent calls, for any missing field(s) the values from the 
%        previous call are used.  The structure is stored in a persistent
%        variable and can be obtained with [~,options] = CHOP.

% References:
% [1] IEEE Standard for Floating-Point Arithmetic, IEEE Std 754-2008 (revision 
%   of IEEE Std 754-1985), 58, IEEE Computer Society, 2008; pages 8,
%   13. https://ieeexplore.ieee.org/document/461093
% [2] Intel Corporation, BFLOAT16---hardware numerics definition,  Nov. 2018, 
%   White paper. Document number 338302-001US.
%   https://software.intel.com/en-us/download/bfloat16-hardware-numerics-definition

persistent fpopts

if isempty(fpopts) % First call.
   if (nargin == 2 && ~isempty(options)) && isfield(options,'precision')
       prec = options.precision;
   else
       prec = 'h';
   end    
   if (nargin == 2 && ~isempty(options)) && isfield(options,'subnormal')
       sub = options.subnormal;
   else 
       if ismember(prec, {'b','bfloat16'}), sub = 0; else sub = 1; end
   end
else          % Subsequent calls.
   if (nargin == 2 && ~isempty(options)) && isfield(options,'precision')
       prec = options.precision;
   elseif isempty(fpopts.precision)
       prec = 'h';
   else
       prec = fpopts.precision;
   end    
   if (nargin == 2 && ~isempty(options)) && isfield(options,'subnormal')
       sub = options.subnormal;
   elseif isempty(fpopts.subnormal)
       if ismember(prec, {'b','bfloat16'}), sub = 0; else sub = 1; end
   else
      sub = fpopts.subnormal;
   end
end

% These values will be the defaults on subsequent calls in this session.
fpopts.precision = prec; fpopts.subnormal = sub; 
if nargout == 2, options = fpopts; end
if nargin == 0 || isempty(x), if nargout >= 1, c = []; end, return, end

if ismember(prec, {'h','half','fp16'})
    % Significand: 10 bits plus 1 hidden. Exponent: 5 bits.
    p = 11; emax = 15;
elseif ismember(prec, {'b','bfloat16'})
    % Significand: 7 bits plus 1 hidden. Exponent: 8 bits.
    p = 8; emax = 127;  
elseif ismember(prec, {'s','single','fp32'})
    % Significand: 23 bits plus 1 hidden. Exponent: 8 bits.
    p = 24; emax = 127;
elseif ismember(prec, {'d','double','fp64'})
    % Significand: 52 bits plus 1 hidden. Exponent: 11 bits.
    p = 53; emax = 1023;
else 
    error('Unrecognized argument.')
end
    
emin = 1-emax;            % Exponent of smallest normal number.
emins = emin + 1 - p;     % Exponent of smallest subnormal number.
xmins = 2^emins;
xmin = 2^emin;
xmax = 2^emax * (2-2^(1-p));

% Use the representation:
% x = 2^e * d_1.d_2...d_t * s, s = 1 or -1.

e = floor(log2(abs(x)));
k_subnormal = find(e < emin & e >= emins);
if ismember(prec, {'d','double','fp64'}) 
    c = x;
    if sub == 0
       % Only one thing to check given that x is already double precision.
       if ~isempty(k_subnormal)
         c(k_subnormal) = 0;   % Flush subnormals to zero.
       end   
    end   
    return 
end
if isempty(k_subnormal)
   c = pow2(round_even(pow2(x, p-1-e)), e-(p-1));
else
  if sub == 1
    % Do not flush subnormal numbers to zero.
    p1 = p - max(emin-e,0);
    c = pow2(round_even( pow2(x, p1-1-e) ), e-(p1-1));
  else
    c = x; c(k_subnormal) = 0;   % Flush subnormals to zero.
  end  
end  

% Any number large than xboundary rounds to inf [1, p. 16].
xboundary = 2^emax * (2-(1/2)*2^(1-p));
c(find(x >= xboundary)) = inf;   % Overflow to +inf.
c(find(x <= -xboundary)) = -inf; % Overflow to -inf.
c(find(abs(x) < xmins)) = 0;     % Underflow to zero.

%-------------------------------------------------------
function u = round_even(x)
% Round to nearest integer using round to even to break ties.
y = abs(x);
u = round(y-(rem(y,2)==0.5));
u = sign(x).*u;