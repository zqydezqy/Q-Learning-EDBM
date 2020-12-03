%% alphaͼ
figure();
alpha1=results(:,1)';
alpha2=results(:,3)';
alpha4=results(:,5)';
alpha3=results(:,7)';
plot(alphas,alpha1,'k',...
alphas,alpha2,'r--',...
alphas,alpha4,'g-*',...
alphas,alpha3,'b-.o');
legend('\gamma=0.9','\gamma=0.8','\gamma=0.7','\gamma=0.6');
xlabel('Learning rate (\alpha)');ylabel('Episodes');grid on;
%% gammaͼ
figure();
gamma1=results(1,:);
gamma2=results(3,:);
gamma3=results(5,:);
gamma4=results(7,:);
plot(alphas,gamma1,'k',...
alphas,gamma2,'r--',...
alphas,gamma3,'g-*',...
alphas,gamma4,'b-.o');
legend('\alpha=0.1','\alpha=0.2','\alpha=0.3','\alpha=0.4');
xlabel('Discounting factor (\gamma)');ylabel('Episodes');grid on;
%% ��άͼ
figure();
surf(alphas,gammas,results);
xlabel('Learning rate(\alpha)');ylabel('Discounting factor(\gamma)');zlabel('Episodes');