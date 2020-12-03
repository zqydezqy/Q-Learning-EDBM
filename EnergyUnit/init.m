%===========初始化函数================
%===========得到初始的速度曲线=========
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

[T0,t0]=caculate_time(V,S,ds);
[E0,e0]=caculate_energy(Fraction,S,ds);
% fprintf("初始总耗时为：%f秒\n",t0)
% fprintf("初始总的牵引能耗为：%f千瓦时\n",e0)
% figure(1);
% plot(S,V);axis([0,1400,0,16]);title('初始运行曲线')