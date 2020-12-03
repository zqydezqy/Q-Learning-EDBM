%========================��ʼ��=======================%
clear;close all;
init;%��ʼ����������ʼ����·ģ�ͣ������ʼ�ٶ����ߵ�
positions=gradient(:,1)';
sections=positions.*1000;
sections=[sections,s_brake];
sections(1)=s_acc;%���Է�������������
figure();
plot(S,V);axis([0,1400,0,20]);title('��ʼ��������');
%%
%��ͬepsilon��ѵ��Ƭ������ѵ��Ч����Ӱ��
global statetree;
statetree=[];
global nodenumber;
tree=[];
StateSpace_Energy;
% N_Episode=150000;
epsilon=0.2;
t_target=100;%Ŀ������ʱ��
dE=0.5;%��λ��ǧ��ʱ
alphas=0.1:0.05:0.5;
% alphas=[0.1,0.3,0.5];
gammas=0.5:0.05:0.9;
% gammas=[0.9,0.8,0.6];
% alphas=[0.1];
% gammas=[0.9];
Results_Time={};
Results_Energy={};
Results_Nodes={};
Rssults_Value={};
% Results_Episodes=[];
% N_Episode=1000000;
results=zeros(length(alphas),length(gammas));
for i=1:length(alphas)
    for j=1:length(gammas)
%     eactual=999;%ʵ������ʱ��
    alpha=alphas(i);
    gamma=gammas(j);
    statetree=[];
    nodenumber=0;
    tree=[];
    StateSpace_Energy;
    ei=0;
    fprintf('��alpha=%f,gamma=%fʱ\n',alpha,gamma);
    OptimalTimes=0;
    TripTimes=[];
    Energys=[];
    Nodes=[];
    Q11Values=[];%��¼��һ��״̬�µ�һ��������ֵ����
%     for k=1:N_Episode %ѵ��һ��Ƭ����
    while OptimalTimes<=10
    statenow=1;%���Ǵӳ�ʼ״̬��ʼ
    t_required=t0;%ԭʼ���ߵ�ʱ��
    Vnew=V;
    Anew=Acceleration;
    Fnew=Fraction;
    E_dis_new=zeros(1,length(sections));
    t_old=t0;
    t_new=t0;
    step=0;
    while t_required>t_target&& step<=16
        %action=select_action(n_actions,statetree(statenow).Qenergy,random_mode);%ѵ���׶�ȫ���������������
        t_old=t_new;step=step+1;
        action=eps_greedy_forstatetree(n_actions,statetree(statenow).Qenergy,epsilon);
        [Vnew,Anew,Fnew,E_dis_new]=distribute_energy_for_section5(dE,E_dis_new,action,...
        sections,Anew,Vnew,S,...
     ds,index_acc,index_brake,v_backward,acc_backward,Davis,acc_grad,vc,Mass,MaxDeccel);%ִ�ж���
        
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
    end%һ��Ƭ�����
    ei=ei+1;
    %����ϰ�õ����Ų��Եõ��ٶ�����
    Aopt=Acceleration;
    Fopt=Fraction;
    Vopt=V;
    E_dis_opt=zeros(1,length(sections));
    statenow=1;
    tactual=999;
    while statenow~=-1 &&tactual>t_target
        action=eps_greedy_forstatetree(n_actions,statetree(statenow).Qenergy,0);%���ý׶�ȫ���������Ŷ���
        [Vopt,Aopt,Fopt,E_dis_opt]=distribute_energy_for_section5(dE,E_dis_opt,action,...
            sections,Aopt,Vopt,S,...
         ds,index_acc,index_brake,v_backward,acc_backward,Davis,acc_grad,vc,Mass,MaxDeccel);%ִ�ж���
         statenow=statetree(statenow).Nextstate(action);
         [Topt,tactual]=caculate_time(Vopt,S,ds);
    end
    [Topt,tactual]=caculate_time(Vopt,S,ds);
    [Eopt,eactual]=caculate_energy(Fopt,S,ds);
    if mod(ei,1)==0 ||ei==1
       TripTimes=[TripTimes,tactual];
       Energys=[Energys,eactual];
       Nodes=[Nodes,length(statetree)];
    end
    if(tactual<98.6&&tactual>98.5)
        OptimalTimes=OptimalTimes+1;
    else
        OptimalTimes=0;
    end
   end%��ɵ�һ��Ƭ�ε�ѵ��
   Results_Time{i,j}=TripTimes;
   Results_Energy{i,j}=Energys;
   Results_Nodes{i,j}=Nodes;
   Rssults_Value{i,j}=Q11Values;
   Results{i,j}=ei;
    end%��������gammas
end%��������alphas
% figure()
% % surf(episodes,epsi,rate);
% title('epsilon-Episodes-learning effect')
% xlabel('episodes');ylabel('epsi');zlabel('rate');
