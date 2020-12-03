%========================初始化=======================%
clear;close all;
init;%初始化，包括初始化线路模型，计算初始速度曲线等
positions=gradient(:,1)';
sections=positions.*1000;
sections=[sections,s_brake];
sections(1)=s_acc;%可以分配能量的区段
figure();
plot(S,V);axis([0,1400,0,20]);title('初始运行曲线');
%%
%不同epsilon和训练片段数对训练效果的影响
global statetree;
global nodenumber;
tree=[];
StateSpace_Energy;
N_Episode=1000000;
% epsilon=0.2;
t_target=100;%目标最优时间
dE=0.5;%单位：千瓦时
% alphas=0.1:0.1:0.5;
% gammas=0.5:0.1:0.9;
% alphas=[0.1,0.5];
% gammas=[0.5,0.9];
alpha=0.1;
gamma=0.9;
epsilons=0.1:0.1:0.5;
Results_Time={};
Results_Energy={};
Results_Nodes={};
Results_Q11Values={};
Episodes=[];
% for i=1:length(alphas)
%     for j=1:length(gammas)
for i=1:length(epsilons)
%     eactual=999;%实际运行时间
%     alpha=alphas(i);
%     gamma=gammas(j);
    epsilon=epsilons(i);
    statetree=[];
    nodenumber=0;
    tree=[];
    StateSpace_Energy;
    ei=0;
    OptimalTimes=0;
    fprintf('当epsilon=%f时\n',epsilon);
    TripTimes=[];
    Energys=[];
    Nodes=[];
    Q11Values=[];%记录第一个状态下第一个动作的值函数
    while OptimalTimes<=10
    statenow=1;%总是从初始状态开始
    t_required=t0;%原始曲线的时间
    Vnew=V;
    Anew=Acceleration;
    Fnew=Fraction;
    E_dis_new=zeros(1,length(sections));
    t_old=t0;
    t_new=t0;
    while t_required>t_target
        %action=select_action(n_actions,statetree(statenow).Qenergy,random_mode);%训练阶段全部采用随机动作法
        t_old=t_new;
        action=eps_greedy_forstatetree(n_actions,statetree(statenow).Qenergy,epsilon);
        [Vnew,Anew,Fnew,E_dis_new]=distribute_energy_for_section5(dE,E_dis_new,action,...
        sections,Anew,Vnew,S,...
     ds,index_acc,index_brake,v_backward,acc_backward,Davis,acc_grad,vc,Mass,MaxDeccel);%执行动作
        
        [~,t_new]=caculate_time(Vnew,S,ds);
        %reward=abs(t_required-t_new);
        reward=t_old-t_new;
        t_required=t_new;
        statenext=get_newstate(statenow,action);
        statetree(statenow).Qenergy(action)=statetree(statenow).Qenergy(action)...
           +alpha*(reward+gamma*(max(statetree(statenext).Qenergy))-statetree(statenow).Qenergy(action)) ;
       if statenow==1&&action==1
          Q11Values=[Q11Values,statetree(1).Qenergy(1)];
       end
       statenow=statenext;
    end%一个片段完成
    ei=ei+1;
    %根据习得的最优策略得到速度曲线
    Aopt=Acceleration;
    Fopt=Fraction;
    Vopt=V;
    E_dis_opt=zeros(1,length(sections));
    statenow=1;
    tactual=999;
    while statenow~=-1 &&tactual>t_target
        action=eps_greedy_forstatetree(n_actions,statetree(statenow).Qenergy,0);%利用阶段全部采用最优动作
        [Vopt,Aopt,Fopt,E_dis_opt]=distribute_energy_for_section5(dE,E_dis_opt,action,...
            sections,Aopt,Vopt,S,...
         ds,index_acc,index_brake,v_backward,acc_backward,Davis,acc_grad,vc,Mass,MaxDeccel);%执行动作
         statenow=statetree(statenow).Nextstate(action);
         [~,tactual]=caculate_time(Vopt,S,ds);
    end
    [~,tactual]=caculate_time(Vopt,S,ds);
    [~,eactual]=caculate_energy(Fopt,S,ds);
    if mod(ei,1)==0
       TripTimes=[TripTimes,tactual];
       Energys=[Energys,eactual];
       Nodes=[Nodes,length(statetree)];
    end
        if(tactual<98.6&&tactual>98.5)
        OptimalTimes=OptimalTimes+1;
    else
        OptimalTimes=0;
    end
   end%完成第一批片段的训练
   Results_Time{i}=TripTimes;
   Results_Energy{i}=Energys;
   Results_Nodes{i}=Nodes;
   Rssults_Value{i}=Q11Values;
   Episodes=[Episodes,ei];
end%结束所有epsilon
% figure()
% % surf(episodes,epsi,rate);
% title('epsilon-Episodes-learning effect')
% xlabel('episodes');ylabel('epsi');zlabel('rate');
