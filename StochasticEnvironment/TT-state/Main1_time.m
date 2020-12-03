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


%% ==========================Qѧϰ����1����ʱ����Ϊ״̬:ѵ����������========================
%=======�����������յ�״̬����Ϊ0������Ϊ-1=======
n_actions=length(sections)-3;%�����ռ䣺���п��Է�������������,��Ҫ������������η�����
StateSpace_Time;
% QEnergy=zeros(n_states,n_actions);
QEnergy=ones(n_states,n_actions)*500;
dE=0.5;%��λ��ǧ��ʱ
% dE=0.1;%��λ��ǧ��ʱ
N_Episodes=200000;
% N_Episodes=11;
% N_Episodes=10000;
% N_Episodes=100000;%100000��Ƭ��ʱ�ܴﵽ����ͨ������ͬ��Ч��
alpha=0.1;
gamma=0.9;
% alpha=0.5;
% gamma=0.8;

epsilon = 0.1;
% eps=0.05:0.05:0.95;
start_state=torg-torg+1;
% end_state=torg-topt1+1;
end_state=time2state(topt,torg,dt);
delta=100;%ѵ��ǰ��ֵ�������������ѵ���Ƿ���Խ���
ei=1;%Ƭ����
optimaltimes=0;
Result_TotalReward=[];
Result_Steps=[];
%% ѵ������
tic;
% for ei=1:N_Episodes
while optimaltimes<5
    st=start_state;
    Vnew=V(1,:);
    Anew=Acceleration(1,:);
    E_dis_new=zeros(1,length(sections));
    Q1=QEnergy(:,:);%�ɵ�ֵ������������������ֵ���������
    tnew=torg;%ԭ����ʱ��
    Davis=StoDavis(Davis0,0);%��Ƭ�εĴ�ά˹����
    ttt=0;
    discount_reward=0;
    while st<end_state &&ttt<50
        ttt=ttt+1;
        at=eps_greedy(st,QEnergy,epsilon,n_actions);
        %��ȡ����������������
        %[Vnew,Anew]=distribute_energy_for_section2(dE,at,sections,Anew,Vnew,S,ds,v_forward,acc_forward,index_acc,index_brake,v_backward,acc_backward,Davis,acc_grad,vc,Mass,MaxDeccel);
        E_dis_new(at)=E_dis_new(at)+1;
        [Vnew,Anew,Fnew]=energy2speedprofile2(dE,E_dis_new,sections,Acceleration,V,S,...
    ds,index_acc,index_brake,v_backward,acc_backward,Davis,acc_grad,vc,Mass,MaxDeccel);
        told=tnew;
        [Tnew,tnew]=caculate_time(Vnew,S,ds);
        %st1=torg-fix(tnew)+1;%�õ��µ�״̬
        st1=time2state(tnew,torg,dt);
%         if(st1<=0)%����ʱ�䵹�˵�����;
%             QEnergy(st,at)=QEnergy(st,at)-2;
%             st1=st;%����״̬����
%         else
         reward=told-tnew;%��ʱ��������
         discount_reward=discount_reward+reward*(gamma^(ttt-1));
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
    end%����һ��Ƭ��    
%     delta=max(max(abs(Q1-QEnergy)));
    Result_TotalReward=[Result_TotalReward,discount_reward];
    fprintf("��%d��Ƭ��ѵ������\n",ei);
    tnew;
    ei=ei+1;
    %����ϰ�õĲ��Է��������õ�����
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
        %st1=torg-fix(topt)+1;%�õ��µ�״̬
        st1=time2state(toptq,torg,dt);
        if(st1>end_state)
            st=end_state;
        else
            st=st1;
        end
    end
    [Toptq,toptq]=caculate_time(Voptq,S,ds);
    [Eoptq,eoptq]=caculate_energy(Foptq,S,ds);
    Result_Steps=[Result_Steps,ttt];
%     if(toptq< 94.95 && eoptq<13.13)
    if(E_dis_optq(1)>=14)
        optimaltimes=optimaltimes+1;
    else
        optimaltimes=0;
    end
end%���������forѭ������������Ƭ��ѵ��.
toc;
%%
%����ϰ�õĲ��Է��������õ�����
st=start_state;
dt=0.1;
Voptq=V(1,:);
Aoptq=Acceleration(1,:);
E_dis_optq=zeros(1,length(sections));
Davis=StoDavis(Davis0,0);%��Ƭ�εĴ�ά˹����
while st~=end_state
    at=eps_greedy(st,QEnergy,0,n_actions);
    %[Vopt,Aopt]=distribute_energy_for_section2(dE,at,sections,Aopt,Vopt,S,ds,v_forward,acc_forward,index_acc,index_brake,v_backward,acc_backward,Davis,acc_grad,vc,Mass,MaxDeccel);
    E_dis_optq(at)=E_dis_optq(at)+1;
    [Voptq,Aoptq,Foptq]=energy2speedprofile2(dE,E_dis_optq,sections,Acceleration,V,S,...
    ds,index_acc,index_brake,v_backward,acc_backward,Davis,acc_grad,vc,Mass,MaxDeccel);
    [Toptq,toptq]=caculate_time(Voptq,S,ds);
    %st1=torg-fix(topt)+1;%�õ��µ�״̬
    st1=time2state(toptq,torg,dt);
    if(st1>end_state)
        st=end_state;
    else
        st=st1;
    end
end
[Toptq,toptq]=caculate_time(Voptq,S,ds);
[Eoptq,eoptq]=caculate_energy(Foptq,S,ds);
fprintf("��Qlearning�����Ż����ܺ�ʱΪ��%f��\n",toptq)
fprintf("��Qlearning�����Ż����ܵ�ǣ���ܺ�Ϊ��%fǧ��ʱ\n\n",eoptq)
%figure(2);
subplot(3,1,2);
plot(S,Voptq);title('Optimal Solution with Q-Learning Approach')
%% ��ͨ����
t_target=topt;
Vopt2=V(1,:);
Aopt2=Acceleration(1,:);
Topt2=T0(1,:);
Eopt2=E0(1,:);%������������Ż�����
Fopt2=Fraction(1,:);
topt2=t0;
eopt2=e0; 
count=1;%���������������ǵڼ��θ���
E_dis_opt=zeros(1,length(sections));%��¼�Ѿ������ȥ������
Davis=StoDavis(Davis0,0);%��Ƭ�εĴ�ά˹����
while topt2>t_target    
    etratemax=0;%������ʱ��ı�ֵ��˭��֤��˭��Ч���ã���Ӧ�÷����������� 
    Vtemp=Vopt2(1,:);
    Atemp=Aopt2(1,:);
    Ttemp=Topt2(1,:);
    Etemp=Eopt2(1,:);%�����������м����
    Ftemp=Fopt2(1,:);
    E_dis_temp=E_dis_opt(1,:);
    fprintf("��%d�η�������\n",count)
    for i=1:length(sections)%���ÿһ�����Σ����¶Ȼ��֣�����˭�Ľ�Լʱ��Ч����
    [Vnew,Anew,Fnew,E_dis_new]=distribute_energy_for_section5(dE,E_dis_opt,i,...
        sections,Aopt2,Vopt2,S,...
     ds,index_acc,index_brake,v_backward,acc_backward,Davis,acc_grad,vc,Mass,MaxDeccel);
    [Tnew,tnew]=caculate_time(Vnew,S,ds);
    [Enew,enew]=caculate_energy(Fnew,S,ds);
    dt1=abs(tnew-topt2);
    if dt1>etratemax
        etratemax=dt1;
        aopt=i;
        Vtemp=Vnew(1,:);
        Atemp=Anew(1,:);
        Ttemp=Tnew(1,:);
        Etemp=Enew(1,:);
        Ftemp=Fnew(1,:);
        E_dis_temp=E_dis_new(1,:);
    end
    end%������ÿ�����η�������forѭ��
    Vopt2=Vtemp(1,:);
    Aopt2=Atemp(1,:);
    Fopt2=Ftemp(1,:);
    E_dis_opt=E_dis_temp(1,:);
    [Topt2,topt2]=caculate_time(Vopt2,S,ds);
    [Eopt2,eopt2]=caculate_energy(Fopt2,S,ds);
    fprintf("��%d�η�����������%d������󣬹��ı�Ϊ%f����ʱ��Ϊ%f\n",count,aopt,eopt2,topt2);
    fprintf("\n");
    count=count+1;
end%������ѭ��
[Topt2,topt2]=caculate_time(Vopt2,S,ds);
[Eopt2,eopt2]=caculate_energy(Fopt2,S,ds);
fprintf("��ͨ�����Ż����ܺ�ʱΪ��%f��\n",topt2)
fprintf("��ͨ�����Ż����ܵ�ǣ���ܺ�Ϊ��%fǧ��ʱ\n",eopt2)
subplot(3,1,3);
plot(S,Vopt2);title('Optimal Solution with EDBM')
%% ==========================����1������һ������=========================================
% dE=2;  
% index=2;
% E_distributed=zeros(1,length(sections));
% [Vnew,Anew,Fnew,E_distributed]=distribute_energy_for_section4(dE,E_distributed,index,sections,Acceleration,V,S,...
%     ds,index_acc,index_brake,v_backward,acc_backward,Davis,acc_grad,vc,Mass,MaxDeccel);
% [T1,t1]=caculate_time(Vnew,S,ds);
% [E1,e1]=caculate_energy(Fnew,S,ds);
% fprintf("�ڵ�%d���������������\n",index);
% fprintf("��ʼ�ܺ�ʱΪ��%f��\n",t1)
% fprintf("��ʼ�ܵ�ǣ���ܺ�Ϊ��%fǧ��ʱ\n",e1)
% figure(2);
% plot(S,Vnew);title('�������������������')

