function [Triptime,Energy]=GetOptimalStrategy(QEnergy)
Parameters;%�������
%�����ʼVS����
smin=0;smax=max(station_info(:))*1000;
vc=18;%Ѳ���ٶ�64.8km/h
ds=0.1;
%ds=1;
% ds=5;
S=smin:ds:smax;%�õ��������
size=length(S);

index_acc=fix(size*0.06);%���ݾ��飬ǰ%6�ľ����������٣�����������
%index_acc=fix(size*0.09);%���ݾ��飬ǰ%9�ľ����������٣�����������
s_acc=S(index_acc);
%index_brake=fix(size*0.76);%���ݾ��飬��%24���ҵľ��������ƶ�������������
index_brake=fix(size*0.8);%���ݾ��飬��%20���ҵľ��������ƶ�������������
s_brake=S(index_brake);

T0=zeros(1,size);%�洢ÿһ��ds��ʱ��
V=zeros(1,size);%�洢ÿһ��ds���ٶ�
Acceleration=zeros(1,size);%�洢ÿһ��ds�ļ��ٶ�
Fraction=zeros(1,size);%�洢ÿһ��ds��ǣ����
E0=zeros(1,size);%�洢ÿһ��ds���ܺ�

acc_grad=zeros(1,size);%�洢�¶ȵļ��ٶ�
pos=2;
for i=1:fix(1000/ds*max(gradient(:,1)))
   acc_grad(1,i)=-gradient(pos-1,2)/1000*9.8; %%�¶ȴ����ļ��ٶ�
    if i*ds>=fix(gradient(pos,1)*1000)
        pos=pos+1;
    end
end
 
v_forward=zeros(1,size);%ǰ���ٶ�
acc_forward=zeros(1,size);%ǰ����ٶ�
acc_gra=zeros(1,size);%���ԣ��¶ȼ��ٶ�
acc_dav=zeros(1,size);%���ԣ���ά˹����
%�����ʼ����
for i=1:size-1%����ǰ���ٶ�
    acc_res=(Davis(1)+Davis(2)*v_forward(1,i)+Davis(3)*(v_forward(1,i))^2);  %�������������ļ��ٶ�    
    if(i<index_acc)%���ٽ׶�
        acc_F=F(v_forward(1,i))/(Mass*1000);%ǣ�����ٶ�
        Fraction(1,i)=F(v_forward(1,i));%�洢ǣ����
        acc_gra(1,i+1)=acc_grad(1,i+1);
        acc_dav(1,i+1)=-acc_res;
        acc_forward(1,i+1)=acc_grad(1,i+1)+acc_F-acc_res;
        v_forward(1,i+1)=(v_forward(1,i)^2+2*acc_forward(1,i+1)*ds).^0.5;%�õ���ǰ�ٶ�
    else%���н׶�
        acc_F=0;
        acc_gra(1,i+1)=acc_grad(1,i+1);
        acc_dav(1,i+1)=-acc_res;
        acc_forward(1,i+1)=acc_grad(1,i+1)+acc_F-acc_res;
        v_forward(1,i+1)=(v_forward(1,i)^2+2*acc_forward(1,i+1)*ds).^0.5;%�õ���ǰ�ٶ�
    end   
end

v_backward=ones(1,size)*100;%�����ٶ�
acc_backward=zeros(1,size);%������ٶ�
v_backward(1,size)=0;
for i=fix(smax/ds):-1:index_brake%��������ٶȺͼ��ٶȣ�һֱ�ƶ��ͺ�
    acc_res=(Davis(1)+Davis(2)*v_backward(1,i+1)+Davis(3)*(v_backward(1,i+1))^2)/Mass;
    acc_backward(1,i)=-acc_res + MaxDeccel- acc_grad(1,i);%������ٶ�
    v_backward(1,i)=(v_backward(1,i+1).^2+2*acc_backward(1,i)*(ds)).^0.5;
    if(v_backward(1,i)>vc)
        v_backward(1,i)=vc;
    end
end

for i=1:size%ȡ�����ٶȵ���Сֵ���õ�ʵ���ٶ�
    if v_forward(1,i)<v_backward(1,i)
        V(1,i)=v_forward(1,i);
        Acceleration(1,i)=acc_forward(1,i);
    else
        V(1,i)=v_backward(1,i);
        Fraction(1,i)=0;
        Acceleration(1,i)=-acc_backward(1,i);
    end
end
positions=gradient(:,1)';
sections=positions.*1000;
sections=[sections,s_brake];
sections(1)=s_acc;%���Է�������������
StateSpace_Time;
dt=0.1;
dE=0.5;
start_state=torg-torg+1;
end_state=time2state(topt,torg,dt);
st=start_state;
Voptq=V(1,:);
Aoptq=Acceleration(1,:);
E_dis_optq=zeros(1,length(sections));
n_actions=length(sections)-3;%�����ռ䣺���п��Է�������������,��Ҫ������������η�����
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
[Toptq,Triptime]=caculate_time(Voptq,S,ds);
[Eoptq,Energy]=caculate_energy(Foptq,S,ds);
end