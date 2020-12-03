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

%% ==========================Qѧϰ����1����ʱ����Ϊ״̬========================
%=======�����������յ�״̬����Ϊ0������Ϊ-1=======
n_actions=length(sections)-3;%�����ռ䣺���п��Է�������������,��Ҫ������������η�����
StateSpace_Time;
QEnergy=zeros(n_states,n_actions);
load('ʱ��״̬�µ�����Q��0.5��.mat');
dE=0.5;%��λ��ǧ��ʱ
%dE=0.1;%��λ��ǧ��ʱ
% N_Episodes=250000;%100000��Ƭ��ʱ�ܴﵽ����ͨ������ͬ��Ч��
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
results=[];%�洢���н��
for i=1:length(epsilons)
    delta=100;%ѵ��ǰ��ֵ�������������ѵ���Ƿ���Խ���
    epsilon=epsilons(i);
    ei=0;%Ƭ����
    QEnergy=zeros(n_states,n_actions);
    result=[];
    fprintf('��epsilon=%f\n',epsilon);
    while ei<150000%�ж�ʮ��Ƭ���ڵ�����
       tic
       st=start_state;
       Vnew=V(1,:);
       Anew=Acceleration(1,:);
       E_dis_new=zeros(1,length(sections));
       Q1=QEnergy(:,:);%�ɵ�ֵ������������������ֵ���������
       tnew=torg;%ԭ����ʱ��
       while st<end_state
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
%          if(st1<=0)%����ʱ�䵹�˵�����;
%             QEnergy(st,at)=QEnergy(st,at)-2;
%               st1=st;%����״̬����
%           else
            reward=told-tnew;%��ʱ��������
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
        end%����һ��Ƭ��    
     delta=max(max(abs(Qoptimal-QEnergy)));
     fprintf("��%d��Ƭ��ѵ������\n",ei);
     delta
     toc;
     if(mod(ei,50)==0)
         result=[result,delta];
     end
     ei=ei+1;
     end%����һ��epsilon��ѵ��
     results=[results;result];%�¿�һ��
end%����epsilonѭ��

%% ==========================����1������һ������=========================================
% index=1:50;
% plot(index,results(1,:),index,results(2,:))

