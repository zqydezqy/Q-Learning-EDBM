%������
%========================��ʼ��=======================%
clear;close all;
init;%��ʼ����������ʼ����·ģ�ͣ������ʼ�ٶ����ߵ�
positions=gradient(:,1)';
sections=positions.*1000;
sections=[sections,s_brake];
sections(1)=s_acc;%���Է�������������
figure();
subplot(3,1,1);
plot(S,V);axis([0,1400,0,18]);title('Original Solution')
global statetree;
statetree=[];
global nodenumber;
tree=[];
StateSpace_Energy;
%% ==========================Qѧϰ����2������������Ϊ״̬========================
%  N_Episodes=1000;
%  N_Episodes=5000;
N_Episodes=1000000;
% N_Episodes=100000;
%t_target=100;%Ŀ������ʱ��
t_target=95;%Ŀ������ʱ��
dE=0.5;%��λ��ǧ��ʱ
alpha=0.1;
gamma=0.9;
%ѵ�����֣���ɶ���ѵ����ÿһ����eps��һ��
batchnumber=1;
optimaltimes=0;
tic;
ei=0;
Results_Reward=[];
Results_Steps=[];
while optimaltimes<5%��һ��Ƭ�ε�ѵ��
    statenow=1;%���Ǵӳ�ʼ״̬��ʼ
    ei=ei+1;
    t_required=t0;%ԭʼ���ߵ�ʱ��
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
        %action=select_action(n_actions,statetree(statenow).Qenergy,random_mode);%ѵ���׶�ȫ���������������
        step=step+1;
        t_old=t_new;
        action=eps_greedy_forstatetree(n_actions,statetree(statenow).Qenergy,0.2);
        [Vnew,Anew,Fnew,E_dis_new]=distribute_energy_for_section5(dE,E_dis_new,action,...
        sections,Anew,Vnew,S,...
     ds,index_acc,index_brake,v_backward,acc_backward,Davis,acc_grad,vc,Mass,MaxDeccel);%ִ�ж���
        
        [~,t_new]=caculate_time(Vnew,S,ds);
        %reward=abs(t_required-t_new);
        reward=t_old-t_new;
        dis_reward=dis_reward+reward*(gamma^(step-1));
        t_required=t_new;
        statenext=get_newstate(statenow,action);
        statetree(statenow).Qenergy(action)=statetree(statenow).Qenergy(action)...
           +alpha*(reward+gamma*(max(statetree(statenext).Qenergy))-statetree(statenow).Qenergy(action)) ;
       statenow=statenext;
    end%һ��Ƭ�����
    fprintf("��%d����%d��Ƭ��ѵ������������ʱ��%.2f��\n",batchnumber,ei,t_required);
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
        action=eps_greedy_forstatetree(n_actions,statetree(statenow).Qenergy,0);%���ý׶�ȫ���������Ŷ���
        [Voptq,Aoptq,Fopt,E_dis_opt]=distribute_energy_for_section5(dE,E_dis_opt,action,...
            sections,Aoptq,Voptq,S,...
            ds,index_acc,index_brake,v_backward,acc_backward,Davis,acc_grad,vc,Mass,MaxDeccel);%ִ�ж���
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
end%��ɵ�һ��Ƭ�ε�ѵ��
toc;
% batchnumber=batchnumber+1;
% for ei=1:N_Episodes%�ڶ���Ƭ�ε�ѵ��
% 
%     tic;
%     statenow=1;%���Ǵӳ�ʼ״̬��ʼ
%     t_required=t0;%ԭʼ���ߵ�ʱ��
%     Vnew=V;
%     Anew=Acceleration;
%     Fnew=Fraction;
%     E_dis_new=zeros(1,length(sections));
%     while t_required>t_target
%         %action=select_action(n_actions,statetree(statenow).Qenergy,random_mode);%ѵ���׶�ȫ���������������
%         action=eps_greedy_forstatetree(n_actions,statetree(statenow).Qenergy,0.5);
%         [Vnew,Anew,Fnew,E_dis_new]=distribute_energy_for_section4(dE,E_dis_new,action,...
%         sections,Anew,Vnew,S,...
%      ds,index_acc,index_brake,v_backward,acc_backward,Davis,acc_grad,vc,Mass,MaxDeccel);%ִ�ж���
%         
%         [~,t_new]=caculate_time(Vnew,S,ds);
%         reward=abs(t_required-t_new);
%         t_required=t_new;
%         statenext=get_newstate(statenow,action);
%         statetree(statenow).Qenergy(action)=statetree(statenow).Qenergy(action)...
%            +alpha*(reward+gamma*(max(statetree(statenext).Qenergy))-statetree(statenow).Qenergy(action)) ;
%        statenow=statenext;
%     end%һ��Ƭ�����
%     fprintf("��%d����%d��Ƭ��ѵ������\n",batchnumber,ei);
%     toc;
% end%��ɵڶ���Ƭ�ε�ѵ��
% batchnumber=batchnumber+1;
% for ei=1:N_Episodes%������Ƭ�ε�ѵ��
% 
%     tic;
%     statenow=1;%���Ǵӳ�ʼ״̬��ʼ
%     t_required=t0;%ԭʼ���ߵ�ʱ��
%     Vnew=V;
%     Anew=Acceleration;
%     Fnew=Fraction;
%     E_dis_new=zeros(1,length(sections));
%     while t_required>t_target
%         %action=select_action(n_actions,statetree(statenow).Qenergy,random_mode);%ѵ���׶�ȫ���������������
%         action=eps_greedy_forstatetree(n_actions,statetree(statenow).Qenergy,0.1);
%         [Vnew,Anew,Fnew,E_dis_new]=distribute_energy_for_section4(dE,E_dis_new,action,...
%         sections,Anew,Vnew,S,...
%      ds,index_acc,index_brake,v_backward,acc_backward,Davis,acc_grad,vc,Mass,MaxDeccel);%ִ�ж���
%         
%         [~,t_new]=caculate_time(Vnew,S,ds);
%         reward=abs(t_required-t_new);
%         t_required=t_new;
%         statenext=get_newstate(statenow,action);
%         statetree(statenow).Qenergy(action)=statetree(statenow).Qenergy(action)...
%            +alpha*(reward+gamma*(max(statetree(statenext).Qenergy))-statetree(statenow).Qenergy(action)) ;
%        statenow=statenext;
%     end%һ��Ƭ�����
%     fprintf("��%d����%d��Ƭ��ѵ������\n",batchnumber,ei);
%     toc;
% end%��ɵ�����Ƭ�ε�ѵ��

%% ����ϰ�õ����Ų��Եõ��ٶ�����
% Vopt=V;
% Aopt=Acceleration;
% Fopt=Fraction;
% E_dis_opt=zeros(1,length(sections));
% statenow=1;
% topt=999;
% t_target=102;
% while topt>t_target
%     action=eps_greedy_forstatetree(n_actions,statetree(statenow).Qenergy,0);%���ý׶�ȫ���������Ŷ���
%     [Vopt,Aopt,Fopt,E_dis_opt]=distribute_energy_for_section5(dE,E_dis_opt,action,...
%         sections,Aopt,Vopt,S,...
%      ds,index_acc,index_brake,v_backward,acc_backward,Davis,acc_grad,vc,Mass,MaxDeccel);%ִ�ж���
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
% fprintf("��Qlearning�����Ż����ܺ�ʱΪ��%f��\n",topt)
% fprintf("��Qlearning�����Ż����ܵ�ǣ���ܺ�Ϊ��%fǧ��ʱ\n\n",eopt)


%% ==========================����2���÷����Դյķ��������Ž�=========================
% dE=0.5;%��λ��ǧ��ʱ
% % dE=400000;%��λ������
% t_target=95;%����ʱ��
% Vopt=V(1,:);
% Aopt=Acceleration(1,:);
% Topt=T0(1,:);
% Eopt=E0(1,:);%������������Ż�����
% Fopt=Fraction(1,:);
% topt=t0;
% eopt=e0; 
% count=1;%���������������ǵڼ��θ���
% E_dis_opt=zeros(1,length(sections));%��¼�Ѿ������ȥ������
% fprintf("��ͨ���������Ų���");
% while topt>t_target    
%     etratemax=0;%������ʱ��ı�ֵ��˭��֤��˭��Ч���ã���Ӧ�÷����������� 
%     Vtemp=Vopt(1,:);
%     Atemp=Aopt(1,:);
%     Ttemp=Topt(1,:);
%     Etemp=Eopt(1,:);%�����������м����
%     Ftemp=Fopt(1,:);
%     E_dis_temp=E_dis_opt(1,:);
%     fprintf("��%d�η�������\n",count)
%     for i=1:length(sections)%���ÿһ�����Σ����¶Ȼ��֣�����˭�Ľ�Լʱ��Ч����
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
%     end%������ÿ�����η�������forѭ��
%     Vopt=Vtemp(1,:);
%     Aopt=Atemp(1,:);
%     Fopt=Ftemp(1,:);
%     E_dis_opt=E_dis_temp(1,:);
%     [Topt,topt]=caculate_time(Vopt,S,ds);
%     [Eopt,eopt]=caculate_energy(Fopt,S,ds);
%     fprintf("��%d�η��������󣬹��ı�Ϊ%f����ʱ��Ϊ%f\n",count,eopt,topt);
%     fprintf("\n");
%     count=count+1;
% end%������ѭ��
% [Topt,topt]=caculate_time(Vopt,S,ds);
% [Eopt,eopt]=caculate_energy(Fopt,S,ds);
% fprintf("��ͨ�����Ż����ܺ�ʱΪ��%f��\n",topt)
% fprintf("��ͨ�����Ż����ܵ�ǣ���ܺ�Ϊ��%fǧ��ʱ\n",eopt)
% % figure(3);
% subplot(3,1,3);
% plot(S,Vopt);title('Optimal Solution with EDBM')

