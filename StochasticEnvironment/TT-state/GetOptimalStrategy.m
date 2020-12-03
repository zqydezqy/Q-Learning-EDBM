function [Triptime,Energy]=GetOptimalStrategy(QEnergy)
Parameters;%导入变量
%计算初始VS曲线
smin=0;smax=max(station_info(:))*1000;
vc=18;%巡航速度64.8km/h
ds=0.1;
%ds=1;
% ds=5;
S=smin:ds:smax;%得到距离矩阵
size=length(S);

index_acc=fix(size*0.06);%根据经验，前%6的距离用来加速，不分配能量
%index_acc=fix(size*0.09);%根据经验，前%9的距离用来加速，不分配能量
s_acc=S(index_acc);
%index_brake=fix(size*0.76);%根据经验，后%24左右的距离用来制动，不分配能量
index_brake=fix(size*0.8);%根据经验，后%20左右的距离用来制动，不分配能量
s_brake=S(index_brake);

T0=zeros(1,size);%存储每一段ds的时间
V=zeros(1,size);%存储每一段ds的速度
Acceleration=zeros(1,size);%存储每一段ds的加速度
Fraction=zeros(1,size);%存储每一段ds的牵引力
E0=zeros(1,size);%存储每一段ds的能耗

acc_grad=zeros(1,size);%存储坡度的加速度
pos=2;
for i=1:fix(1000/ds*max(gradient(:,1)))
   acc_grad(1,i)=-gradient(pos-1,2)/1000*9.8; %%坡度带来的加速度
    if i*ds>=fix(gradient(pos,1)*1000)
        pos=pos+1;
    end
end
 
v_forward=zeros(1,size);%前向速度
acc_forward=zeros(1,size);%前向加速度
acc_gra=zeros(1,size);%测试：坡度加速度
acc_dav=zeros(1,size);%测试：戴维斯阻力
%计算初始曲线
for i=1:size-1%计算前向速度
    acc_res=(Davis(1)+Davis(2)*v_forward(1,i)+Davis(3)*(v_forward(1,i))^2);  %基本阻力产生的加速度    
    if(i<index_acc)%加速阶段
        acc_F=F(v_forward(1,i))/(Mass*1000);%牵引加速度
        Fraction(1,i)=F(v_forward(1,i));%存储牵引力
        acc_gra(1,i+1)=acc_grad(1,i+1);
        acc_dav(1,i+1)=-acc_res;
        acc_forward(1,i+1)=acc_grad(1,i+1)+acc_F-acc_res;
        v_forward(1,i+1)=(v_forward(1,i)^2+2*acc_forward(1,i+1)*ds).^0.5;%得到当前速度
    else%惰行阶段
        acc_F=0;
        acc_gra(1,i+1)=acc_grad(1,i+1);
        acc_dav(1,i+1)=-acc_res;
        acc_forward(1,i+1)=acc_grad(1,i+1)+acc_F-acc_res;
        v_forward(1,i+1)=(v_forward(1,i)^2+2*acc_forward(1,i+1)*ds).^0.5;%得到当前速度
    end   
end

v_backward=ones(1,size)*100;%后向速度
acc_backward=zeros(1,size);%后向加速度
v_backward(1,size)=0;
for i=fix(smax/ds):-1:index_brake%计算后向速度和加速度，一直制动就好
    acc_res=(Davis(1)+Davis(2)*v_backward(1,i+1)+Davis(3)*(v_backward(1,i+1))^2)/Mass;
    acc_backward(1,i)=-acc_res + MaxDeccel- acc_grad(1,i);%反向加速度
    v_backward(1,i)=(v_backward(1,i+1).^2+2*acc_backward(1,i)*(ds)).^0.5;
    if(v_backward(1,i)>vc)
        v_backward(1,i)=vc;
    end
end

for i=1:size%取两个速度的最小值，得到实际速度
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
sections(1)=s_acc;%可以分配能量的区段
StateSpace_Time;
dt=0.1;
dE=0.5;
start_state=torg-torg+1;
end_state=time2state(topt,torg,dt);
st=start_state;
Voptq=V(1,:);
Aoptq=Acceleration(1,:);
E_dis_optq=zeros(1,length(sections));
n_actions=length(sections)-3;%动作空间：所有可以分配能量的区段,不要在最后两个区段分能量
while st~=end_state
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
[Toptq,Triptime]=caculate_time(Voptq,S,ds);
[Eoptq,Energy]=caculate_energy(Foptq,S,ds);
end