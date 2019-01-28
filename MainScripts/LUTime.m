%LUTIME compares the time for LU factorisation by
% @fp16 matlab class, chop based LU, and native
% matlab LU for double precision.

rng(1)
nvals = [50 100 250 500];
for k = 1:length(nvals)
    
n = nvals(k);
fprintf('n = %g\n',n)
AA = randn(n);

% Half Precision 
options.precision = 'h'; options.subnormal = 1; chop([],options)
A16 = fp16(AA);
A = double(A16);

% t = clock; [L,U,P] = gep_chop(A,'p'); twall(k,1) = etime(clock,t);

% Double precision run, for comparison.  Run 10 times to get average.
twall(k,5) = 0;
for i = 1:10
t = clock;  [L0,U0,p0] = lutx(A); twall(k,5) = twall(k,5) + etime(clock,t);
end
twall(k,5) = twall(k,5)/10;

t = clock;  [L1,U1,p1] = lutx_chop(A); twall(k,2) = etime(clock,t);
I = eye(n); P1 = I(p1,:); % R = P16*A16 - L16*U16
res(k,1) = norm(P1*A-L1*U1,1)/norm(A,1);

%{
t = clock; [L16,U16,p16] = lu(A16);    twall(k,1) = etime(clock,t);
P16 = I(p16,:); % R = P16*A16 - L16*U16
L16 = double(L16); U16 = double(U16); P16 = double(P16); 
res(k,2) = norm(P16*A-L16*U16,1)/norm(A,1);
%}
% norm(L-L16,1)/norm(L,1)
% norm(U-U16,1)/norm(U,1)
% norm(P-P16,1)

% Single Precision 
A32 = single(AA);
A = double(A32);
options.precision = 's'; options.subnormal = 1; chop([],options)
% tic, [L,U,P] = gep_chop(A,'p'); toc
t = clock;  [L2,U2,p2] = lutx_chop(A); twall(k,3) = etime(clock,t);
t = clock;  [L32,U32,P32] = lu(A32); twall(k,4) = etime(clock,t);

P2 = I(p2,:); 
res(k,3) = norm(P2*A-L2*U2,1)/norm(A,1);
res(k,4) = norm(P32*A-L32*U32,1)/norm(A,1);

end

save('LUTime.mat','nvals','twall','res')

% Use code from https://github.com/higham/matlab-guide-3ed
print_matrix([nvals' twall],{'%g','%4.1e','%4.1e','%4.1e',},[],9,1,1)
