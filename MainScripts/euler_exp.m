%EULER_EXP    Euler's method experiment.

a = 0; b = 1;
y0 = 1e-2; 
yexact = exp(-1)*y0;

% Decided not to do so - as brwon and oragen too similar.
c = get(groot,'defaultAxesColorOrder');
c([3 6],:) = c([6 3],:); % Swap yellow and light blue.
set(groot,'defaultAxesColorOrder',c)

% nrange = [1e1 5e1 1e2 5e2 1e3 5e3 1e4 5e4 1e5]
nrange = round(10.^linspace(1,5,16));
% [1e1 1e2 1e3 1e4 1e5]; %  1e7 1e8]; %  1e3]; % 1e4 1e5 1e6 1e7];
m = length(nrange);

% Standard double precision. 
for j = 1:m

     n = nrange(j);

     x_dp = a;
     h_dp = (b-a)/n;
     y_dp = y0;

     for i=1:n

         y_dp = y_dp + h_dp*feuler(x_dp,y_dp);  % DP Euler
         x_dp = x_dp + h_dp;

      end

edp(j) = norm(y_dp - yexact,inf);

end

% All chop formats.
for k = 1:4
    
switch k
  case 1, options.format = 'b'; options.subnormal = 1;
    % No point in bfoat16 with subnormals - such a tiny range.
    % case 5, options.format = 'b'; options.subnormal = 0;
   case 2, options.format = 'h'; options.subnormal = 1;
   case 3, options.format = 'h'; options.subnormal = 0;
   case 4, options.format = 's'; options.subnormal = 1;
     %   case 6, options.format = 's'; options.subnormal = 0;
     %    case 5, options.format = 'd'; options.subnormal = 1;
     %   case 8, options.format = 'd'; options.subnormal = 0;
end

fprintf('k = %1.0f, prec = %s, subnormal = %1.0f\n',...
         k,options.format,options.subnormal)
chop([],options)

a = chop(a); b = chop(b); y0 = chop(y0);

for j = 1:m

     n = nrange(j);

     x_fp = chop(a);
     h_fp = chop((b-a)/n);
     % fprintf('%9.2e  ', double(h_fp))
     y_fp = chop(y0);

     for i=1:n
         y_fp = chop(y_fp + chop(h_fp*feuler(x_fp,y_fp)));  % Chop Euler
         x_fp = chop(x_fp + h_fp);
         % x_fp = chop(a+i*h_fp);
      end

efp(j,k) = norm(y_fp - yexact,inf);

end
% fprintf('\n')

end

save('euler_exp_results','nrange','edp','efp','a','b','y0')

h = loglog(...
       nrange,efp(:,3),'x--',...
       nrange,efp(:,1),'*--',...
       nrange,efp(:,2),'o--',...
       nrange,efp(:,4),'s-.',...
       nrange,edp,'d-');
       % nrange,efp(:,6),'o-',...
       % nrange,efp(:,7),'o-',...
       % nrange,efp(:,8),'o-')
xlabel('$n$','Interpreter','latex')
ylabel('Error','Rotation',0)
grid
set(gca,'MinorGridLineStyle','none')
set(h,'LineWidth',1)
set(gca,'FontSize',10)
% For 12pt font:
% legend('fp16 no subnormals','bfloat16', ...
%        'fp16 with subnormals',...
%        'fp32','fp64','Position',[0.75 0.6 0.1 0.2])
legend('fp16 no subnormals','bfloat16', ...
       'fp16 with subnormals',...
       'fp32','fp64','Position',[0.69 0.6 0.1 0.2])
shg
set(gcf, 'Color', 'w')
export_fig ../figs/euler_fig.pdf

set(groot,'defaultAxesColorOrder','factory')

% logloe, ecs, 'x', nrange, ecs, '-', ...
%        nrange, efp, 'o', nrange, efp, '--', ...
%        nrange, edp, ':')

function f = feuler(x,y);
%FEULER      Function called by EULERCS.
f = -y;
% f = [ 0 -1; 1 0] * [y(1); y(2)];
end