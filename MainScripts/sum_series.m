%SUM_SERIES

options.precision = 'h';

% if ismember(prec, {'h','half','fp16'})
% p = 11; % fp16
% elseif ismember(prec, {'b','bfloat16'})
% p = 8;  % bfloat16
% elseif ismember(prec, {'s','single','fp32'})
% p = 24; % fp32
% end
fid = fopen('sum_series.txt','w');
for nmax = [1e2 1e3 1e4 1e5] %  1e6]

for j = [0 1]
options.subnormal = j;
chop([],options)

s1 = 0; s2 = 0; n = 1;

for k = 1:nmax
    s1 = chop(s1 + chop(1/(nmax-k+1))^2);
    s2 = chop(s2 + chop(1/k)^2);
end
mysum(1,j+1) = s1;
mysum(2,j+1) = s2;
% fprintf('Sum has converged:\n')
% options
% nmax, n, s

end

% mysum
% col_diff = mysum(:,1) - mysum(:,2)


fprintf(fid,'%7.0f &  %12.6e &  %12.6e &  %9.2e\\\\ \n',...
        nmax,mysum(1,2),mysum(1,1),mysum(1,2)-mysum(1,1));

end

fclose(fid);
