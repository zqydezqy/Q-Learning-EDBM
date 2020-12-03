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
% StateSpace_Time;

%定义状态空间
topt=100;
%topt=102;
topt1=topt-10;
torg=141;
dt=0.1;
T=torg:-dt:topt1;
n_states=length(T);

% QEnergy=zeros(n_states,n_actions);
QEnergy=ones(n_states,n_actions)*500;
% load('时间状态下的最优Q表0.5度.mat');
dE=0.5;%单位：千瓦时
%dE=0.1;%单位：千瓦时
% N_Episodes=250000;%100000个片段时能达到和普通方法等同的效果
% alphas=0.1:0.1:0.5;
% % gammas=0.5:0.1:0.9;
% % alphas=[0.1,0.3,0.5];
% gammas=[0.9,0.8,0.6];
alphas=0.1:0.05:0.9;
gammas=0.9:-0.05:0.1;
% alpha=0.1;
% gamma=0.9;
epsilon = 0.1;
% eps=0.05:0.05:0.95;
start_state=torg-torg+1;
% end_state=torg-topt+1;
end_state=time2state(topt,torg,dt);
results=ones(length(alphas),length(gammas))*-1;%存储在不同的alpha和gamma下需要多少片段能够收敛
for i=1:length(alphas)
    for j=1:length(gammas)
        delta=10;%训练前后值函数最大误差，衡量训练是否可以结束
        alpha=alphas(i);
        gamma=gammas(j);
        ei=0;%片段数
%         QEnergy=zeros(n_states,n_actions);
        QEnergy=ones(n_states,n_actions)*500;
        fprintf('当alpha=%f,gamma=%f时\n',alpha,gamma);
       % while delta>1e-3
       OptimalTimes=0;%连续达到最优解的次数，认为连续十次达到最优解才是收敛到最优值函数
        %while delta>1e-3
        while OptimalTimes<=10
%            tic
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
%              if(st1<=0)%出现时间倒退的现象;
%                 QEnergy(st,at)=QEnergy(st,at)-2;
%                  st1=st;%保持状态不变
%               else
               reward=told-tnew;%以时间做奖励
               if(st1<end_state)
                   value=max(QEnergy(st1,:));
                    QEnergy(st,at)=QEnergy(st,at)+alpha*(reward+gamma*value-QEnergy(st,at));
               else
                    st1=end_state;
         %QEnergy(st,at)=QEnergy(st,at)+alpha*(0-QEnergy(st,at));
               QEnergy(st,at)=QEnergy(st,at)+alpha*(reward+gamma*value-QEnergy(st,at));
%             st1=end_state;
               end
              st=st1;
           end%结束一个片段    
%         delta=max(max(abs(Q1-QEnergy)));
        ei=ei+1;
        %=====求最优解=======
        %利用习得的策略分配能量得到曲线
        st=start_state;
        dt=0.1;
        Voptq=V(1,:);
        Aoptq=Acceleration(1,:);
        E_dis_optq=zeros(1,length(sections));
        temp=0;
        while st~=end_state&&temp<20
            temp=temp+1;%计次，如果分配数量超过一定次数还未达到最优则视为得不到最优解
            at=eps_greedy(st,QEnergy,0,n_actions);
            %[Vopt,Aopt]=distribute_energy_for_section2(dE,at,sections,Aopt,Vopt,S,ds,v_forward,acc_forward,index_acc,index_brake,v_backward,acc_backward,Davis,acc_grad,vc,Mass,MaxDeccel);
            E_dis_optq(at)=E_dis_optq(at)+1;
            [Voptq,Aoptq,Foptq]=energy2speedprofile2(dE,E_dis_optq,sections,Acceleration,V,S,...
                ds,index_acc,index_brake,v_backward,acc_backward,Davis,acc_grad,vc,Mass,MaxDeccel);
            [Toptq,toptq]=caculate_time(Voptq,S,ds);
            %st1=torg-fix(topt)+1;%得到新的状态
            st1=time2state(toptq,torg,dt);
            if(st1>end_state)
                st=end_state;
            else
                st=st1;
            end
        end
        Energy=999;
        if(temp<20)
              [~,Energy]=caculate_energy(Foptq,S,ds);
        end
        %===================
        if(Energy>11.62)
            OptimalTimes=0;
        else
            OptimalTimes=OptimalTimes+1;
        end        
        end%结束一组alpha,gamma的训练
        results(i,j)=ei;
        ei
    end%结束gamma循环
end%结束alpha循环

%% 绘制立体图

