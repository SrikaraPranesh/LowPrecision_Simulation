%MATMULT
rng(1)

rpts = 5;

nvals = [500:500:2500];
nn = length(nvals);

options.format = 'h';

cbe_x16 = zeros(rpts,nn); 
cbe_x64 = zeros(rpts,nn);

for j = 1:nn
    
n = nvals(j);
fprintf('%g out of %g n values\n', j, nn)

for k = 1:rpts

    % fprintf('%g out of %g repetitions\n', k, rpts)

A = chop(randn(n));
B = chop(randn(n));

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

