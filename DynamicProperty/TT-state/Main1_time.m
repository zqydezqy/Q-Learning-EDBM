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


%% ==========================Q学习方法1：以时间作为状态:训练参数设置========================
%=======奖励：进入终点状态奖励为0，其他为-1=======
n_actions=length(sections)-3;%动作空间：所有可以分配能量的区段,不要在最后两个区段分能量
StateSpace_Time;
% QEnergy=zeros(n_states,n_actions);
QEnergy=ones(n_states,n_actions)*500;
% QOld=QEnergy(:,:);%旧表，计算误差
dE=0.5;%单位：千瓦时
%dE=0.1;%单位：千瓦时
N_Episodes=100000;
% N_Episodes=11;
% N_Episodes=10000;
% N_Episodes=100000;%100000个片段时能达到和普通方法等同的效果
alpha=0.1;
gamma=0.9;
% alpha=0.5;
% gamma=0.8;

epsilon = 0.1;
% eps=0.05:0.05:0.95;
start_state=torg-torg+1;
end_state=torg-topt+1;
end_state=time2state(topt,torg,dt);
delta=100;%训练前后值函数最大误差，衡量训练是否可以结束
ei=1;%片段数
optimaltimes=0;
Results_Error=[];
Results_TotalReward=[];
Results_ValueS0=[];
Results_Steps=[];
%% 训练过程
tic;
for ei=1:N_Episodes
% while optimaltimes<5
    st=start_state;
    Vnew=V(1,:);
    Anew=Acceleration(1,:);
    E_dis_new=zeros(1,length(sections));
    Q1=QEnergy(:,:);%旧的值函数表，用来计算两次值函数的误差
    tnew=torg;%原来的时间
    step=0;disreward=0;
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
%         if(st1<=0)%出现时间倒退的现象;
%             QEnergy(st,at)=QEnergy(st,at)-2;
%             st1=st;%保持状态不变
%         else
         reward=told-tnew;%以时间做奖励
         disreward=disreward+reward*(gamma^step);
         step=step+1;
          if(st1<end_state)
            value=max(QEnergy(st1,:));
         %QEnergy(st,at)=QEnergy(st,at)+alpha*(-1+gamma*value-QEnergy(st,at));
          QEnergy(st,at)=QEnergy(st,at)+alpha*(reward+gamma*value-QEnergy(st,at));
           else
            st1=end_state;
         %QEnergy(st,at)=QEnergy(st,at)+alpha*(0-QEnergy(st,at));
        QEnergy(st,at)=QEnergy(st,at)+alpha*(reward+gamma*value-QEnergy(st,at));
%             st1=end_state;
          end
        st=st1;
    end%结束一个片段    
    delta=max(max(abs(Q1-QEnergy)));
    Results_Error=[Results_Error,delta];
    Results_TotalReward=[Results_TotalReward,disreward];
    Results_Steps=[Results_Steps,step];
    mean0=mean(QEnergy(1,:));
    Results_ValueS0=[Results_ValueS0,mean0];
    fprintf("第%d个片段训练结束\n",ei);
    tnew;
    ei=ei+1;
    %利用习得的策略分配能量得到曲线
    ttt=0;
    st=start_state;
    dt=0.1;
    Voptq=V(1,:);
    Aoptq=Acceleration(1,:);
    E_dis_optq=zeros(1,length(sections));
    while st~=end_state&&ttt<30
        ttt=ttt+1;
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
    [Toptq,toptq]=caculate_time(Voptq,S,ds);
    [Eoptq,eoptq]=caculate_energy(Foptq,S,ds);
    if(toptq<101.77 && eoptq<10.62)
        optimaltimes=optimaltimes+1;
    else
        optimaltimes=0;
    end
end%结束最外层for循环，结束所有片段训练.
toc;
%%
%利用习得的策略分配能量得到曲线
% st=start_state;
% dt=0.1;
% Voptq=V(1,:);
% Aoptq=Acceleration(1,:);
% E_dis_optq=zeros(1,length(sections));
% while st~=end_state
%     at=eps_greedy(st,QEnergy,0,n_actions);
%     %[Vopt,Aopt]=distribute_energy_for_section2(dE,at,sections,Aopt,Vopt,S,ds,v_forward,acc_forward,index_acc,index_brake,v_backward,acc_backward,Davis,acc_grad,vc,Mass,MaxDeccel);
%     E_dis_optq(at)=E_dis_optq(at)+1;
%     [Voptq,Aoptq,Foptq]=energy2speedprofile2(dE,E_dis_optq,sections,Acceleration,V,S,...
%     ds,index_acc,index_brake,v_backward,acc_backward,Davis,acc_grad,vc,Mass,MaxDeccel);
%     [Toptq,toptq]=caculate_time(Voptq,S,ds);
%     %st1=torg-fix(topt)+1;%得到新的状态
%     st1=time2state(toptq,torg,dt);
%     if(st1>end_state)
%         st=end_state;
%     else
%         st=st1;
%     end
% end
% [Toptq,toptq]=caculate_time(Voptq,S,ds);
% [Eoptq,eoptq]=caculate_energy(Foptq,S,ds);
% fprintf("用Qlearning方法优化后总耗时为：%f秒\n",toptq)
% fprintf("用Qlearning方法优化后总的牵引能耗为：%f千瓦时\n\n",eoptq)
% %figure(2);
% subplot(3,1,2);
% plot(S,Voptq);title('Optimal Solution with Q-Learning Approach')

%% ==========================测试1：分配一次能量=========================================
% dE=2;  
% index=2;
% E_distributed=zeros(1,length(sections));
% [Vnew,Anew,Fnew,E_distributed]=distribute_energy_for_section4(dE,E_distributed,index,sections,Acceleration,V,S,...
%     ds,index_acc,index_brake,v_backward,acc_backward,Davis,acc_grad,vc,Mass,MaxDeccel);
% [T1,t1]=caculate_time(Vnew,S,ds);
% [E1,e1]=caculate_energy(Fnew,S,ds);
% fprintf("在第%d个区间分配能量后：\n",index);
% fprintf("初始总耗时为：%f秒\n",t1)
% fprintf("初始总的牵引能耗为：%f千瓦时\n",e1)
% figure(2);
% plot(S,Vnew);title('分配能量后的运行曲线')

