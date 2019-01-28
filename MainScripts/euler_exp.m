%EULER_EXP    Euler's method experiment.

a = 0; b = 1;
y0 = 1e-2; 
yexact = exp(-1)*y0;

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
   case 1, options.precision = 'b'; options.subnormal = 1;
     %   case 2, options.precision = 'b'; options.subnormal = 0;
   case 2, options.precision = 'h'; options.subnormal = 1;
   case 3, options.precision = 'h'; options.subnormal = 0;
   case 4, options.precision = 's'; options.subnormal = 1;
     %   case 6, options.precision = 's'; options.subnormal = 0;
     %    case 5, options.precision = 'd'; options.subnormal = 1;
     %   case 8, options.precision = 'd'; options.subnormal = 0;
end

fprintf('k = %1.0f, prec = %s, subnormal = %1.0f\n',...
         k,options.precision,options.subnormal)
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

h = loglog(nrange,efp(:,3),'x--',...
       nrange,efp(:,1),'o-',...
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
set(gca,'FontSize',12)
legend('fp16 no subnormals','bfloat16', 'fp16 with subnormals',...
       'fp32','fp64','Position',[0.75 0.6 0.1 0.2])
shg
set(gcf, 'Color', 'w')
export_fig ../figs/euler_fig.pdf

% logloe, ecs, 'x', nrange, ecs, '-', ...
%        nrange, efp, 'o', nrange, efp, '--', ...
%        nrange, edp, ':')

function f = feuler(x,y);
%FEULER      Function called by EULERCS.
f = -y;
% f = [ 0 -1; 1 0] * [y(1); y(2)];
end