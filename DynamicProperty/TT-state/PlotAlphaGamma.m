%% alphaͼ
alpha1=results(:,1)';
alpha2=results(:,3)';
alpha3=results(:,7)';
plot(alphas,alpha1,'k',...
alphas,alpha2,'k--',...
alphas,alpha3,'k-.o');
legend('gamma=0.9','gamma=0.8','gamma=0.6');
xlabel('Alpha');ylabel('Episodes');grid on;
%% gammaͼ
gamma1=results(1,:);
gamma2=results(3,:);
gamma3=results(5,:);
plot(alphas,gamma1,'k',...
alphas,gamma2,'k--',...
alphas,gamma3,'k-.o');
legend('alpha=0.1','alpha=0.2','alpha=0.3');
xlabel('Gamma');ylabel('Episodes');grid on;
%% ��άͼ
figure();
surf(alphas,gammas,results);
xlabel('Alpha');ylabel('Gamma');zlabel('Episodes');