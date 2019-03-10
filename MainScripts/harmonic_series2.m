%HARMONIC_SERIES2
%Input: prec = 'h', 'b' or 's'.

for p = 0:2

clear options
switch p
  case 0
    prec = 'c'; 
    % Significand: 4 bits plus 1 hidden. Exponent: 3 bits.
    t = 5; emax = 3;
    options.params = [t emax];
  case 1, prec = 'bfloat16';
  case 2, prec = 'fp16';
  case 3, prec = 's';
end

options.format = prec;

% if ismember(prec, {'h','half','fp16'})
% p = 11; % fp16
% elseif ismember(prec, {'b','bfloat16'})
% p = 8;  % bfloat16
% elseif ismember(prec, {'s','single','fp32'})
% p = 24; % fp32
% end

for i = 1:6
% for i = [1 0]
% options.subnormal = i;
options.round = i;
chop([],options)

s = 0; n = 1;

while true
    sold = s;
    s = chop(s + chop(1/n));
    if s == sold, break, end;
    n = n + 1;
end 
fprintf('%s & %6.4f  & %g\\\\\n',prec,s,n)
% options
% n, s

end
end