% v=0:0.1:18;
% F1=[];
% for i=1:length(v)
%     f=F(v(i))/1000;
%     F1=[F1,f];
% end
% figure();
% plot(v,F1);
% title('Traction Force');
% xlabel('Speed(m/s)');ylabel('Force(kN)');
% axis([0,20,249.80,250.05]);

% v=0:0.1:18;
% Davis= [3.4818036  0.040254284*3.6   0.006575*3.6*3.6  0]; %戴维斯阻力公式 
% F=(Davis(1)+Davis(2)*v+Davis(3)*v.^2);
% plot(v,F)
% title('Basic Resistance');
% xlabel('speed(m/s)');ylabel('Resistance(kN)');
% axis([0,20,0,40])

%===================gamma=====================
% t=[100.6459,99.8525,99.8525,99.9976,99.8525,99.9976,99.9976,99.8525,99.9976];
% e=[9.9350,9.9284,9.9284,9.9288,9.9284,9.9288,9.9288,9.9284,9.9288];
% t0=144.078873;e0=8.428949;
% for i=1:length(t)
%     rate(i)=(e(i)-e0)/abs(t(i)-t0);
% end

%=================alpha==================
% t=[99.8525,99.9976,99.8525,99.9976,99.8525,99.8525,99.9976,99.9877,99.9976,99.8525];
% e=[9.9284,9.9288,9.9284,9.9288,9.9284,9.9284,9.9288,9.9350,9.9288,9.9284];
% t0=144.078873;e0=8.428949;
% for i=1:length(t)
%     rate(i)=(e(i)-e0)/abs(t(i)-t0);
% end
%=============state_tree======================
% t=[101.0683,103.7563,99.6986,99.6078,99.6078,99.6078,99.6078,99.6078];
% e=[10.4417,10.4349,9.9789,9.9765,9.9765,9.9765,9.9765,9.9765];
% t0=144.078873;e0=8.428949;
% for i=1:length(t)
%     rate(i)=(e(i)-e0)/abs(t(i)-t0);
% end
%======================三维图时间状态法=================
% k=1;
% for i=1:length(alp)
%     for j=1:length(gam)
%         rate1(i,j)=rate(k);
%         episodes1(i,j)=episode(k);
%         k=k+1;
%     end
% end
% figure()
% surf(gam,alp,episode);
% title('alpha-gamma-learning speed')
% xlabel('gamma');ylabel('alpha');zlabel('episodes');
% figure();
% surf(gam,alp,rate*999);title('alpha-gamma-learning effect')
% xlabel('gamma');ylabel('alpha');zlabel('energy/time');
%============================================
figure();
subplot(3,1,1);
plot(S,V);axis([0,1400,0,18]);title('Original Solution');
subplot(3,1,2);
plot(S,Vopt);title('Optimal Solution with Q-Learning Approach');
subplot(3,1,3);
plot(S,Vopt);title('Optimal Solution with EDBM')
