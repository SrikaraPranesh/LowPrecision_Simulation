%solve_test

n = 100; nrun = 100;
clear options
rng(1)

for pp = 2
    
switch pp
  case 1, prec = 'bfloat16';
  case 2, prec = 'fp16';
  case 3, prec = 's';
end

for j = 1:nrun
AA = randn(n);
bb = randn(n,1);

options.format = prec;
chop([],options)
A = chop(AA); b = chop(bb);

for i = 1:6
% for i = [1 0]
% options.subnormal = i;
options.round = i;
% options.flip = 1; options.p = 0.01;
chop([],options)

[L,U,p] = lutx_chop(A);
bp = b(p);
y = trisol(L, bp);
x = trisol(U, y);
r = b - A*x;
berr(j,i) = norm(r,1)/(norm(A,1)*norm(x,1) + norm(b,1));
end

end % j 

fprintf('%s\n', prec)
fprintf('& Round to nearest & Round to $+\\infty$ & Round to $-\\infty$ &')
fprintf('Stochastic rounding\\\\\\hline\n')
fprintf('Mean & %9.2e & %9.2e & %9.2e & %9.2e & %9.2e & %9.2e\\\\\n', ...
        mean(berr(:,1)), mean(berr(:,2)), mean(berr(:,3)), ...
        mean(berr(:,4)), mean(berr(:,5)), mean(berr(:,6))), 
fprintf('Min  & %9.2e & %9.2e & %9.2e & %9.2e & %9.2e & %9.2e\\\\\n', ...
        min(berr(:,1)), min(berr(:,2)), min(berr(:,3)), ...
        min(berr(:,4)), min(berr(:,5)), min(berr(:,6)))
fprintf('Max  & %9.2e & %9.2e & %9.2e & %9.2e & %9.2e & %9.2e\n', ...
        max(berr(:,1)), max(berr(:,2)), max(berr(:,3)), ...
        max(berr(:,4)), max(berr(:,6)), max(berr(:,4)))
end % p