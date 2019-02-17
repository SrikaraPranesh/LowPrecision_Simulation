function x = trisol(T, b)
%TRISOL   Solve triangualr system in low precision arithmetic.
%   TRISOL(T, b) is the solution x to the triangular system
%   Tx = b computed in low precision arithmetic.
%   It requires the CHOP function to simulate lower precision arithmetic.

n = length(T);
x = zeros(n,1);

if ~norm(T-triu(T),1)      % Upper triangular

    x(n) = chop( b(n)/T(n,n));
    for i=n-1:-1:1
        temp = chop( x(i+1) .* T(1:i,i+1));
        b(1:i) = chop( b(1:i) - temp);
        x(i) = chop( b(i)/T(i,i));
    end

elseif ~norm(T-tril(T),1)   % Lower triangular

    x(1) = chop( b(1)/T(1,1));
    for i=2:n
        temp = chop( x(i-1) .* T(i:n,i-1));
        b(i:n) = chop( b(i:n) - temp);
        x(i) = chop(b(i)/T(i,i));
    end

else
   error('Matrix T must be triangular.')
end
