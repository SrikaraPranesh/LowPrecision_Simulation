%MATMULT
rng(1)

rpts = 1;

nvals = [500:500:2500];
nn = length(nvals);

clear options
options.format = 'h';

cbe_x16 = zeros(rpts,nn); 
cbe_x64 = zeros(rpts,nn);

for j = 1:nn
    
n = nvals(j);
fprintf('%g out of %g n values\n', j, nn)

for k = 1:rpts

    % fprintf('%g out of %g repetitions\n', k, rpts)

A = chop(rand(n));
B = chop(rand(n));

C = A*B;
C64 = chop(A*B);

C16 = zeros(n);
for i = 1:n
    C16 = chop(C16 + chop(A(:,i)*B(i,:)));
end    

cbe64(k,j) = max(max( abs(C-C64) ./ (abs(A)*abs(B)) ));
cbe16(k,j) = max(max( abs(C-C16) ./ (abs(A)*abs(B)) ));

end
end

cbe64, cbe16

for j = 1:nn
n = nvals(j);
fprintf('%4.0f & %9.2e & %9.2e & %9.2e & %9.2e \\\\\n',...
   n,mean(cbe16(:,j)), max(cbe16(:,j)), mean(cbe64(:,j)), max(cbe64(:,j)))
end        

% fprintf('Mean & %9.2e & %9.2e & %9.2e & %9.2e & %9.2e \\\\\n', ...
%         mean(cbe64(:,1)), mean(cbe64(:,2)), mean(cbe64(:,3)), ...
%         mean(cbe64(:,4)), mean(cbe64(:,5)))
% fprintf('Max  & %9.2e & %9.2e & %9.2e & %9.2e & %9.2e \n', ...
%         max(cbe64(:,1)), max(cbe64(:,2)), max(cbe64(:,3)), ...
%         max(cbe64(:,4)), max(cbe64(:,5)))

% fprintf('Mean & %9.2e & %9.2e & %9.2e & %9.2e & %9.2e \\\\\n', ...
%         mean(cbe16(:,1)), mean(cbe16(:,2)), mean(cbe16(:,3)), ...
%         mean(cbe16(:,4)), mean(cbe16(:,5)))
% fprintf('Max  & %9.2e & %9.2e & %9.2e & %9.2e & %9.2e \n', ...
%         max(cbe16(:,1)), max(cbe16(:,2)), max(cbe16(:,3)), ...
%         max(cbe16(:,4)), max(cbe16(:,5)))


%{
% rpts = 1
A = chop(rand(n));
B = chop(rand(n));
cbe64 =
   4.8759e-04   4.8799e-04   3.6660e-04   4.8803e-04   4.2930e-04
cbe16 =
   1.1945e-02   2.3047e-02   4.0701e-02   4.5976e-02   6.8770e-02

% No error grwoth with n!
% A = chop(randn(n));
% B = chop(randn(n));
% nvals = [500:500:2500];
>> matmult
1 out of 5 n values
2 out of 5 n values
3 out of 5 n values
4 out of 5 n values
5 out of 5 n values
cbe64 =
   1.0781e-04   9.0841e-05   6.8803e-05   5.1510e-05   7.3731e-05
   1.0789e-04   9.7298e-05   6.8248e-05   5.3311e-05   5.8807e-05
   1.1107e-04   9.6977e-05   6.9325e-05   5.2961e-05   4.1863e-05
   1.0497e-04   9.4705e-05   7.0785e-05   5.2121e-05   4.1660e-05
   1.0362e-04   9.6802e-05   6.7673e-05   5.1710e-05   6.4514e-05
cbe16 =
   2.4380e-03   2.5434e-03   2.3219e-03   3.4563e-03   3.0283e-03
   2.2926e-03   3.1371e-03   2.7694e-03   3.3059e-03   2.8939e-03
   2.8622e-03   2.6725e-03   2.7222e-03   2.9764e-03   2.9608e-03
   3.1955e-03   2.7892e-03   2.9036e-03   3.3888e-03   2.7468e-03
   2.4904e-03   2.3372e-03   2.7686e-03   3.9979e-03   3.3414e-03
%}   