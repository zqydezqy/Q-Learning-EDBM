%===========��ʼ������================
%===========�õ���ʼ���ٶ�����=========
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

[T0,t0]=caculate_time(V,S,ds);
[E0,e0]=caculate_energy(Fraction,S,ds);
% fprintf("��ʼ�ܺ�ʱΪ��%f��\n",t0)
% fprintf("��ʼ�ܵ�ǣ���ܺ�Ϊ��%fǧ��ʱ\n",e0)
% figure(1);
% plot(S,V);axis([0,1400,0,16]);title('��ʼ��������')