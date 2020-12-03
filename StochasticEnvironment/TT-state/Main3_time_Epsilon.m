%主函数
%========================初始化=======================%
clear;close all;
init;%初始化，包括初始化线路模型，计算初始速度曲线等
positions=gradient(:,1)';
sections=positions.*1000;
sections=[sections,s_brake];
sections(1)=s_acc;%可以分配能量的区段
figure();
subplot(3,1,1);
plot(S,V);axis([0,1400,0,18]);title('Original Solution')

%% ==========================Q学习方法1：以时间作为状态========================
%=======奖励：进入终点状态奖励为0，其他为-1=======
n_actions=length(sections)-3;%动作空间：所有可以分配能量的区段,不要在最后两个区段分能量
StateSpace_Time;
QEnergy=zeros(n_states,n_actions);
load('时间状态下的最优Q表0.5度.mat');
dE=0.5;%单位：千瓦时
%dE=0.1;%单位：千瓦时
% N_Episodes=250000;%100000个片段时能达到和普通方法等同的效果
% alphas=0.1:0.1:0.5;
% gammas=0.5:0.1:0.9;
% alphas=[0.1,0.2];
% gammas=[0.9];
alpha=0.1;
gamma=0.9;
% epsilon = 0.1;
epsilons=0.1:0.1:0.5;
% epsilons=[0.1,0.5];
start_state=torg-torg+1;
end_state=torg-topt+1;
end_state=time2state(topt,torg,dt);
results=[];%存储所有结果
for i=1:length(epsilons)
    delta=100;%训练前后值函数最大误差，衡量训练是否可以结束
    epsilon=epsilons(i);
    ei=0;%片段数
    QEnergy=zeros(n_states,n_actions);
    result=[];
    fprintf('当epsilon=%f\n',epsilon);
    while ei<150000%判断十万片段内的收敛
       tic
       st=start_state;
       Vnew=V(1,:);
       Anew=Acceleration(1,:);
       E_dis_new=zeros(1,length(sections));
       Q1=QEnergy(:,:);%旧的值函数表，用来计算两次值函数的误差
       tnew=torg;%原来的时间
       while st<end_state
           at=eps_greedy(st,QEnergy,epsilon,n_actions);
           %采取动作：即分配能量
           %[Vnew,Anew]=distribute_energy_for_section2(dE,at,sections,Anew,Vnew,S,ds,v_forward,acc_forward,index_acc,index_brake,v_backward,acc_backward,Davis,acc_grad,vc,Mass,MaxDeccel);
           E_dis_new(at)=E_dis_new(at)+1;
           [Vnew,Anew,Fnew]=energy2speedprofile2(dE,E_dis_new,sections,Acceleration,V,S,...
            ds,index_acc,index_brake,v_backward,acc_backward,Davis,acc_grad,vc,Mass,MaxDeccel);
           told=tnew;
           [Tnew,tnew]=caculate_time(Vnew,S,ds);
           %st1=torg-fix(tnew)+1;%得到新的状态
           st1=time2state(tnew,torg,dt);
%          if(st1<=0)%出现时间倒退的现象;
%             QEnergy(st,at)=QEnergy(st,at)-2;
%               st1=st;%保持状态不变
%           else
            reward=told-tnew;%以时间做奖励
            if(st1<end_state)
               value=max(QEnergy(st1,:));
                %QEnergy(st,at)=QEnergy(st,at)+alpha*(-1+gamma*value-QEnergy(st,at));
               QEnergy(st,at)=QEnergy(st,at)+alpha*(reward+gamma*value-QEnergy(st,at));
             else
               st1=end_state;
    %QEnergy(st,at)=QEnergy(st,at)+alpha*(0-QEnergy(st,at));
               QEnergy(st,at)=QEnergy(st,at)+alpha*(reward+gamma*value-QEnergy(st,at));
%          st1=end_state;
             end
           st=st1;
        end%结束一个片段    
     delta=max(max(abs(Qoptimal-QEnergy)));
     fprintf("第%d个片段训练结束\n",ei);
     delta
     toc;
     if(mod(ei,50)==0)
         result=[result,delta];
     end
     ei=ei+1;
     end%结束一个epsilon的训练
     results=[results;result];%新开一行
end%结束epsilon循环

%% ==========================测试1：分配一次能量=========================================
% index=1:50;
% plot(index,results(1,:),index,results(2,:))

