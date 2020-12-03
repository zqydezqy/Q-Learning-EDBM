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
% StateSpace_Time;

%����״̬�ռ�
topt=100;
%topt=102;
topt1=topt-10;
torg=141;
dt=0.1;
T=torg:-dt:topt1;
n_states=length(T);

% QEnergy=zeros(n_states,n_actions);
QEnergy=ones(n_states,n_actions)*500;
% load('ʱ��״̬�µ�����Q��0.5��.mat');
dE=0.5;%��λ��ǧ��ʱ
%dE=0.1;%��λ��ǧ��ʱ
% N_Episodes=250000;%100000��Ƭ��ʱ�ܴﵽ����ͨ������ͬ��Ч��
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
results=ones(length(alphas),length(gammas))*-1;%�洢�ڲ�ͬ��alpha��gamma����Ҫ����Ƭ���ܹ�����
for i=1:length(alphas)
    for j=1:length(gammas)
        delta=10;%ѵ��ǰ��ֵ�������������ѵ���Ƿ���Խ���
        alpha=alphas(i);
        gamma=gammas(j);
        ei=0;%Ƭ����
%         QEnergy=zeros(n_states,n_actions);
        QEnergy=ones(n_states,n_actions)*500;
        fprintf('��alpha=%f,gamma=%fʱ\n',alpha,gamma);
       % while delta>1e-3
       OptimalTimes=0;%�����ﵽ���Ž�Ĵ�������Ϊ����ʮ�δﵽ���Ž��������������ֵ����
        %while delta>1e-3
        while OptimalTimes<=10
%            tic
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
%              if(st1<=0)%����ʱ�䵹�˵�����;
%                 QEnergy(st,at)=QEnergy(st,at)-2;
%                  st1=st;%����״̬����
%               else
               reward=told-tnew;%��ʱ��������
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
           end%����һ��Ƭ��    
%         delta=max(max(abs(Q1-QEnergy)));
        ei=ei+1;
        %=====�����Ž�=======
        %����ϰ�õĲ��Է��������õ�����
        st=start_state;
        dt=0.1;
        Voptq=V(1,:);
        Aoptq=Acceleration(1,:);
        E_dis_optq=zeros(1,length(sections));
        temp=0;
        while st~=end_state&&temp<20
            temp=temp+1;%�ƴΣ����������������һ��������δ�ﵽ��������Ϊ�ò������Ž�
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
        end%����һ��alpha,gamma��ѵ��
        results(i,j)=ei;
        ei
    end%����gammaѭ��
end%����alphaѭ��

%% ��������ͼ

