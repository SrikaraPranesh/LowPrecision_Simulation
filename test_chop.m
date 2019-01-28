% function test_chop
%TEST_CHOP Test the chop function.
%   The tests are for single precision and fp16, the latter requiring
%   Cleve Moler's fp16 class.

addpath('MainFunctions/')
addpath('MainScripts/')
clear chop fp options assert_eq

% Check handling of defaults and persistent variable.
fp.precision = 'bfloat16'; [c,options] = chop(pi,fp);
assert_eq(fp.precision,options.precision)
assert_eq(options.subnormal,0)

fp.subnormal = 0; [c,options] = chop(pi,fp);
assert_eq(options.subnormal,0)

clear chop
[~,fp] = chop;
assert_eq(fp.subnormal,1)
assert_eq(fp.precision,'h')
[c,options] = chop(pi);
assert_eq(options.precision,'h')
assert_eq(options.subnormal,1)

fp.precision = 'd'; [c,options] = chop(pi,fp);
assert_eq(options.precision,'d')
assert_eq(options.subnormal,1)
[~,fp] = chop;
assert_eq(fp.precision,'d')
assert_eq(fp.subnormal,1)

clear chop
[~,fp] = chop;
fp.precision = 'b'; [c,options] = chop(pi,fp);
assert_eq(options.subnormal,1) % No subnormals only if that field was empty.

% Check these usages do not give an error.
c = chop([]);
chop([]);
chop([],fp);
chop(1,fp);
c = chop(1,fp);

for i = 1:2

if i == 1
   % Single precision tests.
   [u,xmins,xmin,xmax,p,emins,emin,emax] = float_params('single');
   options.precision = 's';
elseif i == 2
   % Half precision tests.
   [u,xmins,xmin,xmax,p,emins,emin,emax] = float_params('half');
   options.precision = 'h';
end
options.subnormal = 0;

x = pi;
if i == 1
   y = double(single(x));
elseif i == 2
   y = double(fp16(x));
end    
c = chop(x,options);
assert_eq(c,y);
x = -pi;
c = chop(x,options);
assert_eq(c,-y);

% Next number power of 2.
y = 2^10;
if i == 1
   dy = double(eps(single(y)));
elseif i == 2
   dy = double(eps(fp16(y)));
end    
x = y + dy;
c = chop(x,options);
assert_eq(c,x)

% Number just before a power of 2.
y = 2^10; x = y - dy;
c = chop(x,options);
assert_eq(c,x)

% Next number power of 2.
y = 2^(-4);
if i == 1
   dy = double(eps(single(y)));
elseif i == 2
   dy = double(eps(fp16(y)));
end    
x = y + dy;
c = chop(x,options);
assert_eq(c,x)

% Number just before a power of 2.
y = 2^(-4); x = y - dy;
c = chop(x,options);
assert_eq(c,x)

% Overflow tests.
x = xmax;
c = chop(x,options);
assert_eq(c,x)

% IEEE 2008, page 16: rule for rounding to infinity.
x = 2^emax * (2-(1/2)*2^(1-p));  % Round to inf.
xboundary = 2^emax * (2-(1/2)*2^(1-p));
c = chop(x,options);
assert_eq(c,inf)
x = 2^emax * (2-(3/4)*2^(1-p));  % Round to realmax.
c = chop(x,options);
assert_eq(c,xmax)

% Round to nearest.
if i == 2
   x = 1 + 2^(-11);
   c = chop(x,options);
   assert_eq(c,1)
end

% Underflow tests.

options.subnormal = 1;
c = chop(xmin,options);
assert_eq(c,xmin)
options.subnormal = 0;
c = chop(xmin,options);
assert_eq(c,xmin)

x = [xmins xmin/2 xmin 0 xmax 2*xmax];
c = chop(x,options);
c_expected = [0 0 x(3:5) inf];
assert_eq(c,c_expected)

% Smallest normal number and spacing between the subnormal numbers.
y = xmin; delta = xmin*2^(1-p);
x = y - delta; % The largest subnormal number.
options.subnormal = 1;
c = chop(x,options);
assert_eq(c,x)
% Now try flushing to zero.
options.subnormal = 0;
c = chop(x,options);
assert_eq(c,0)

options.subnormal = 1;
x = xmins*8;  % A subnormal number.
c = chop(x,options);
assert_eq(c,x)

% Number too small too represent.
x = xmins/2; c = chop(x,options); assert_eq(c,0)
options.subnormal = 1;
x = xmins/2; c = chop(x,options); assert_eq(c,0)

end

% Double precision tests.
[u,xmins,xmin,xmax,p,emins,emin,emax] = float_params('d');
options.precision = 'd';
x = [1e-309 1e-320 1 1e306];  % First two entries are subnormal.
c = chop(x,options);
assert_eq(c,x)
options.subnormal = 0;
c = chop(x,options);
assert_eq(c,[0 0 x(3:4)])

options.precision = 'd'; options.subnormal = 0; chop([],options)
a = chop(pi); assert_eq(a,pi)
options.precision = 'd'; options.subnormal = 1; chop([],options)
a = chop(pi); assert_eq(a,pi)

fprintf('Tests successful!\n')

%%%%%%%%%%%%%%%%%%%%%%%
function assert_eq(a,b)
persistent n
if isempty(n), n = 0; end  % First call.
n = n+1;
if ~isequal(a,b)
   error('Failure')
end
fprintf('Test %g succeeded.\n', n )
end
