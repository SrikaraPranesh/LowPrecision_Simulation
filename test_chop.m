% function test_chop
%TEST_CHOP Test the chop function.
%   The tests are for single precision and fp16.

clear chop fp options options2 assert_eq

uh = 2^(-11);  % Unit roundoff for fp16.
pi_h = 6432*uh; % fp16(pi)
    
% Check handling of defaults and persistent variable.
fp.format = 'bfloat16'; [c,options] = chop(pi,fp);
assert_eq(fp.format,options.format)
assert_eq(options.subnormal,0)

fp.format = []; [c,options] = chop(pi,fp);
assert_eq(options.format,'h')  % Check default;

fp.subnormal = 0; [c,options] = chop(pi,fp);
assert_eq(options.subnormal,0)

fp.subnormal = []; [c,options] = chop(pi,fp);
assert_eq(options.subnormal,1)  % Check default;

fp.round = []; [c,options] = chop(pi,fp);
assert_eq(options.round,1)  % Check default.

fp.flip = []; [c,options] = chop(pi,fp);
assert_eq(options.flip,0)  % Check no default.

clear chop fp options 
% check all default options
fp.format = []; fp.subnormal = [];
fp.round = []; fp.flip = [];
fp.p = [];
[c,options] = chop(pi,fp);
assert_eq(options.format,'h')
assert_eq(options.subnormal,1)
assert_eq(options.round,1)
assert_eq(options.flip,0)
assert_eq(options.p,0.5)
% % Takes different path from previous test since fpopts exists.
% fp.subnormal = 0; 
% fp.format = []; [c,options] = chop(pi,fp);
% assert_eq(options.format,'h')

clear chop
[~,fp] = chop;
assert_eq(fp.subnormal,1)
assert_eq(fp.format,'h')
[c,options] = chop(pi);
assert_eq(options.format,'h')
assert_eq(options.subnormal,1)
assert_eq(options.round,1)
assert_eq(options.flip,0)
assert_eq(options.p,0.5)

fp.format = 'd'; [c,options] = chop(pi,fp);
assert_eq(options.format,'d')
assert_eq(options.subnormal,1)
[~,fp] = chop;
assert_eq(fp.format,'d')
assert_eq(fp.subnormal,1)

clear chop
[~,fp] = chop;
fp.format = 'b'; [c,options] = chop(pi,fp);
assert_eq(options.subnormal,1) % No subnormals only if that field was empty.

% Check these usages do not give an error.
c = chop([]);
chop([]);
chop([],fp);
chop(1,fp);
c = chop(1,fp);

% Test matrix.
options.format = 'b';
A = magic(4);
C = chop(A,options);
assert_eq(A,C);
B = A + randn(size(A))*1e-12;
C = chop(B,options);
assert_eq(A,C);
A2 = hilb(6); C = chop(A2);

options.format = 'c';
options.params = [8 127];  % bfloat16
C1 = chop(A,options);
assert_eq(A,C1);
C2 = chop(B,options);
assert_eq(A,C2);
assert_eq(C,chop(A2));

clear options
options.format = 'c';
options.params = [11 15];  % h
options2.format = 'h';
A = hilb(6);
[X1,opt] = chop(A,options);
[X2,opt2] = chop(A,options2);
assert_eq(X1,X2)
% assert_eq(chop(A,options),chop(A,options2));

% Row vector
clear options
options.format = 'h';
A = -10:10;
C = chop(A,options);
assert_eq(A,C);
B = A + randn(size(A))*1e-12;
C = chop(B,options);
assert_eq(A,C);

% Column vector
options.format = 's';
A = (-10:10)';
C = chop(A,options);
assert_eq(A,C);
B = A + A.*rand(size(A))*1e-14;  % Keep 0 as 0.
C = chop(B,options);
assert_eq(A,C);

for i = 1:2

if i == 1
   % Single precision tests.
   [u,xmins,xmin,xmax,p,emins,emin,emax] = float_params('single');
   options.format = 's';
elseif i == 2
   % Half precision tests.
   [u,xmins,xmin,xmax,p,emins,emin,emax] = float_params('half');
   options.format = 'h';
end
options.subnormal = 0;

x = pi;
if i == 1
   y = double(single(x));
elseif i == 2
   y = pi_h; % double(fp16(x));
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
   dy = 2*y*uh; % double(eps(fp16(y)));
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
   dy = 2*y*uh; % double(eps(fp16(y)));
end    
x = y + dy;
c = chop(x,options);
assert_eq(c,x)

% Check other rounding options
for rmode = 1:6
    options.round = rmode;
    x = y + (dy*10^(-3));
    c = chop(x,options);
    if (options.round == 2)
        assert_eq(c,y+dy) % Rounding up.
    elseif options.round >= 5
        % Check rounded either up or down.
        if c ~= y+dy
           assert_eq(c,y);
        end
    else
        assert_eq(c,y);
    end
end
options.round = 1; % reset the rounding mode to default

% Overflow tests.
x = xmax;
c = chop(x,options);
assert_eq(c,x)

% IEEE 2008, page 16: rule for rounding to infinity.
x = 2^emax * (2-(1/2)*2^(1-p));  % Round to inf.
xboundary = 2^emax * (2-(1/2)*2^(1-p)); % YYY This line is redundant right?
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

if i == 1
    delta = double(eps(single(1)));
else
    delta = 2*uh; % double(eps(fp16(1)));
end    

options.subnormal = 1;
c = chop(xmin,options); assert_eq(c,xmin)
x = [xmins xmin/2 xmin 0 xmax 2*xmax 1-delta/5 1+delta/4];
c = chop(x,options);
c_expected = [x(1:5) inf 1 1];
assert_eq(c,c_expected)

options.subnormal = 0;
c = chop(xmin,options); assert_eq(c,xmin)
x = [xmins xmin/2 xmin 0 xmax 2*xmax 1-delta/5 1+delta/4];
c = chop(x,options);
c_expected = [0 0 x(3:5) inf 1 1];
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

end % for i

% Double precision tests.
[u,xmins,xmin,xmax,p,emins,emin,emax] = float_params('d');
options.format = 'd';
x = [1e-309 1e-320 1 1e306];  % First two entries are subnormal.
c = chop(x,options);
assert_eq(c,x)
options.subnormal = 0;
c = chop(x,options);
assert_eq(c,[0 0 x(3:4)])

options.format = 'd'; options.subnormal = 0; chop([],options)
a = chop(pi); assert_eq(a,pi)
options.format = 'd'; options.subnormal = 1; chop([],options)
a = chop(pi); assert_eq(a,pi)

x = pi^2;
clear options
options.format = 'd';
y = chop(x,options);  % Should not change x.
assert_eq(x,y);
options.round = 2;
y = chop(x,options);  % Should not change x.
assert_eq(x,y);
options.round = 3;
y = chop(x,options);  % Should not change x.
assert_eq(x,y);
options.round = 4;
y = chop(x,options);  % Should not change x.
assert_eq(x,y);

fprintf('All tests successful!\n')

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
