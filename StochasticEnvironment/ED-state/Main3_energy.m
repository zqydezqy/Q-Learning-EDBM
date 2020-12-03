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
global statetree;
statetree=[];
global nodenumber;
tree=[];
StateSpace_Energy;
%% ==========================Q学习方法2：以能量分配为状态========================
%  N_Episodes=1000;
%  N_Episodes=5000;
N_Episodes=1000000;
% N_Episodes=100000;
%t_target=100;%目标最优时间
t_target=95;%目标最优时间
dE=0.5;%单位：千瓦时
alpha=0.1;
gamma=0.9;
%训练部分，完成多批训练，每一批的eps不一样
batchnumber=1;
optimaltimes=0;
tic;
ei=0;
Results_Reward=[];
Results_Steps=[];
while optimaltimes<5%第一批片段的训练
    statenow=1;%总是从初始状态开始
    ei=ei+1;
    t_required=t0;%原始曲线的时间
    Vnew=V;
    Anew=Acceleration;
    Fnew=Fraction;
    E_dis_new=zeros(1,length(sections));
    t_old=t0;
    t_new=t0;
    step=0;
    dis_reward=0;
    Davis=StoDavis(Davis0,0);
    while t_required>t_target && step<=50
        %action=select_action(n_actions,statetree(statenow).Qenergy,random_mode);%训练阶段全部采用随机动作法
        step=step+1;
        t_old=t_new;
        action=eps_greedy_forstatetree(n_actions,statetree(statenow).Qenergy,0.2);
        [Vnew,Anew,Fnew,E_dis_new]=distribute_energy_for_section5(dE,E_dis_new,action,...
        sections,Anew,Vnew,S,...
     ds,index_acc,index_brake,v_backward,acc_backward,Davis,acc_grad,vc,Mass,MaxDeccel);%执行动作
        
        [~,t_new]=caculate_time(Vnew,S,ds);
        %reward=abs(t_required-t_new);
        reward=t_old-t_new;
        dis_reward=dis_reward+reward*(gamma^(step-1));
        t_required=t_new;
        statenext=get_newstate(statenow,action);
        statetree(statenow).Qenergy(action)=statetree(statenow).Qenergy(action)...
           +alpha*(reward+gamma*(max(statetree(statenext).Qenergy))-statetree(statenow).Qenergy(action)) ;
       statenow=statenext;
    end%一个片段完成
    fprintf("第%d批第%d个片段训练结束，运行时间%.2f秒\n",batchnumber,ei,t_required);
    Results_Reward=[Results_Reward,dis_reward];
    Voptq=V(1,:);
    Aoptq=Acceleration(1,:);
    Fopt=Fraction(1,:);
    E_dis_opt=zeros(1,length(sections));
    statenow=1;
    topt=999;
    step=0;
    while topt>t_target && step<=30
        step=step+1;
        action=eps_greedy_forstatetree(n_actions,statetree(statenow).Qenergy,0);%利用阶段全部采用最优动作
        [Voptq,Aoptq,Fopt,E_dis_opt]=distribute_energy_for_section5(dE,E_dis_opt,action,...
            sections,Aoptq,Voptq,S,...
            ds,index_acc,index_brake,v_backward,acc_backward,Davis,acc_grad,vc,Mass,MaxDeccel);%执行动作
        %statenow=statetree(statenow).Nextstate(action);
        statenow=get_newstate(statenow,action);
        [~,topt]=caculate_time(Voptq,S,ds);
        %      [Eopt,eopt]=caculate_energy(Fopt,S,ds);
    end
    [~,toptq]=caculate_time(Voptq,S,ds);
    [~,eoptq]=caculate_energy(Fopt,S,ds);
    Results_Steps=[Results_Steps,step];
    if(E_dis_opt(1)>=14&&toptq<=t_target)
        optimaltimes=optimaltimes+1;
    else
        optimaltimes=0;
    end
end%完成第一批片段的训练
toc;
% batchnumber=batchnumber+1;
% for ei=1:N_Episodes%第二批片段的训练
% 
%     tic;
%     statenow=1;%总是从初始状态开始
%     t_required=t0;%原始曲线的时间
%     Vnew=V;
%     Anew=Acceleration;
%     Fnew=Fraction;
%     E_dis_new=zeros(1,length(sections));
%     while t_required>t_target
%         %action=select_action(n_actions,statetree(statenow).Qenergy,random_mode);%训练阶段全部采用随机动作法
%         action=eps_greedy_forstatetree(n_actions,statetree(statenow).Qenergy,0.5);
%         [Vnew,Anew,Fnew,E_dis_new]=distribute_energy_for_section4(dE,E_dis_new,action,...
%         sections,Anew,Vnew,S,...
%      ds,index_acc,index_brake,v_backward,acc_backward,Davis,acc_grad,vc,Mass,MaxDeccel);%执行动作
%         
%         [~,t_new]=caculate_time(Vnew,S,ds);
%         reward=abs(t_required-t_new);
%         t_required=t_new;
%         statenext=get_newstate(statenow,action);
%         statetree(statenow).Qenergy(action)=statetree(statenow).Qenergy(action)...
%            +alpha*(reward+gamma*(max(statetree(statenext).Qenergy))-statetree(statenow).Qenergy(action)) ;
%        statenow=statenext;
%     end%一个片段完成
%     fprintf("第%d批第%d个片段训练结束\n",batchnumber,ei);
%     toc;
% end%完成第二批片段的训练
% batchnumber=batchnumber+1;
% for ei=1:N_Episodes%第三批片段的训练
% 
%     tic;
%     statenow=1;%总是从初始状态开始
%     t_required=t0;%原始曲线的时间
%     Vnew=V;
%     Anew=Acceleration;
%     Fnew=Fraction;
%     E_dis_new=zeros(1,length(sections));
%     while t_required>t_target
%         %action=select_action(n_actions,statetree(statenow).Qenergy,random_mode);%训练阶段全部采用随机动作法
%         action=eps_greedy_forstatetree(n_actions,statetree(statenow).Qenergy,0.1);
%         [Vnew,Anew,Fnew,E_dis_new]=distribute_energy_for_section4(dE,E_dis_new,action,...
%         sections,Anew,Vnew,S,...
%      ds,index_acc,index_brake,v_backward,acc_backward,Davis,acc_grad,vc,Mass,MaxDeccel);%执行动作
%         
%         [~,t_new]=caculate_time(Vnew,S,ds);
%         reward=abs(t_required-t_new);
%         t_required=t_new;
%         statenext=get_newstate(statenow,action);
%         statetree(statenow).Qenergy(action)=statetree(statenow).Qenergy(action)...
%            +alpha*(reward+gamma*(max(statetree(statenext).Qenergy))-statetree(statenow).Qenergy(action)) ;
%        statenow=statenext;
%     end%一个片段完成
%     fprintf("第%d批第%d个片段训练结束\n",batchnumber,ei);
%     toc;
% end%完成第三批片段的训练

%% 根据习得的最优策略得到速度曲线
% Vopt=V;
% Aopt=Acceleration;
% Fopt=Fraction;
% E_dis_opt=zeros(1,length(sections));
% statenow=1;
% topt=999;
% t_target=102;
% while topt>t_target
%     action=eps_greedy_forstatetree(n_actions,statetree(statenow).Qenergy,0);%利用阶段全部采用最优动作
%     [Vopt,Aopt,Fopt,E_dis_opt]=distribute_energy_for_section5(dE,E_dis_opt,action,...
%         sections,Aopt,Vopt,S,...
%      ds,index_acc,index_brake,v_backward,acc_backward,Davis,acc_grad,vc,Mass,MaxDeccel);%执行动作
%      %statenow=statetree(statenow).Nextstate(action);
%      statenow=get_newstate(statenow,action);
%      [~,topt]=caculate_time(Vopt,S,ds);
% %      [Eopt,eopt]=caculate_energy(Fopt,S,ds);
% end
% % figure(2);
% subplot(3,1,2);
% plot(S,Vopt);title('Optimal Solution with Q-Learning Approach');
% [Topt,topt]=caculate_time(Vopt,S,ds);
% [Eopt,eopt]=caculate_energy(Fopt,S,ds);
% fprintf("用Qlearning方法优化后总耗时为：%f秒\n",topt)
% fprintf("用Qlearning方法优化后总的牵引能耗为：%f千瓦时\n\n",eopt)


%% ==========================测试2：用分配试凑的方法找最优解=========================
% dE=0.5;%单位：千瓦时
% % dE=400000;%单位：瓦特
% t_target=95;%最优时间
% Vopt=V(1,:);
% Aopt=Acceleration(1,:);
% Topt=T0(1,:);
% Eopt=E0(1,:);%以上四项都是最优化的项
% Fopt=Fraction(1,:);
% topt=t0;
% eopt=e0; 
% count=1;%计数器，计现在是第几次更新
% E_dis_opt=zeros(1,length(sections));%记录已经分配出去的能量
% fprintf("普通方法找最优策略");
% while topt>t_target    
%     etratemax=0;%能量和时间的比值，谁大证明谁的效果好，更应该分配给这个区段 
%     Vtemp=Vopt(1,:);
%     Atemp=Aopt(1,:);
%     Ttemp=Topt(1,:);
%     Etemp=Eopt(1,:);%以上四项是中间变量
%     Ftemp=Fopt(1,:);
%     E_dis_temp=E_dis_opt(1,:);
%     fprintf("第%d次分配能量\n",count)
%     for i=1:length(sections)%穷举每一个区段（按坡度划分），看谁的节约时间效果好
%     [Vnew,Anew,Fnew,E_dis_new]=distribute_energy_for_section5(dE,E_dis_opt,i,...
%         sections,Aopt,Vopt,S,...
%      ds,index_acc,index_brake,v_backward,acc_backward,Davis,acc_grad,vc,Mass,MaxDeccel);
%     [Tnew,tnew]=caculate_time(Vnew,S,ds);
%     [Enew,enew]=caculate_energy(Fnew,S,ds);
%     dt=abs(tnew-topt);
%     if dt>etratemax
%         etratemax=dt;
%         Vtemp=Vnew(1,:);
%         Atemp=Anew(1,:);
%         Ttemp=Tnew(1,:);
%         Etemp=Enew(1,:);
%         Ftemp=Fnew(1,:);
%         E_dis_temp=E_dis_new(1,:);
%     end
%     end%结束给每个区段分能量的for循环
%     Vopt=Vtemp(1,:);
%     Aopt=Atemp(1,:);
%     Fopt=Ftemp(1,:);
%     E_dis_opt=E_dis_temp(1,:);
%     [Topt,topt]=caculate_time(Vopt,S,ds);
%     [Eopt,eopt]=caculate_energy(Fopt,S,ds);
%     fprintf("第%d次分配能量后，功耗变为%f，耗时变为%f\n",count,eopt,topt);
%     fprintf("\n");
%     count=count+1;
% end%结束大循环
% [Topt,topt]=caculate_time(Vopt,S,ds);
% [Eopt,eopt]=caculate_energy(Fopt,S,ds);
% fprintf("普通方法优化后总耗时为：%f秒\n",topt)
% fprintf("普通方法优化后总的牵引能耗为：%f千瓦时\n",eopt)
% % figure(3);
% subplot(3,1,3);
% plot(S,Vopt);title('Optimal Solution with EDBM')

