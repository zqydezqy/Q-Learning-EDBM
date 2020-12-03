function [Vnew,Anew,Fnew]=energy2speedprofile(dE,E_distributed,sections,Acceleration,V,S,...
    ds,index_acc,index_brake,v_backward,acc_backward,Davis,acc_grad,vc,Mass,MaxDeccel)

index_max=length(sections);
size=length(S);
e_used=0;%加速过程中消耗的能量

%重新计算分配能量后的曲线
Vnew=zeros(1,size);
Anew=zeros(1,size);
Fnew=zeros(1,size);
%牵引阶段
for i=1:index_acc
    acc_res=(Davis(1)+Davis(2)*Vnew(1,i)+Davis(3)*(Vnew(1,i))^2);  %基本阻力产生的加速度    
    acc_F=F(Vnew(1,i))/(Mass*1000);%牵引加速度
    Fnew(1,i)=F(Vnew(1,i));%存储牵引力
    Anew(1,i+1)=acc_grad(1,i+1)+acc_F-acc_res;
    Vnew(1,i+1)=(Vnew(1,i)^2+2*Anew(1,i+1)*ds).^0.5;%得到当前速度
end%牵引结束
%根据现有的能量进行分配
for number=1:index_max-1
    E_total=E_distributed(1,number)*dE;
    i=fix(sections(number)/ds);%开始分配能量
    while e_used<E_total&&i<fix(sections(number+1)/ds)
        %acc_res=(Davis(1)+Davis(2)*Vnew(1,i)+Davis(3)*(Vnew(1,i))^2)/(Mass*1000);  %基本阻力产生的加速度 
        acc_res=(Davis(1)+Davis(2)*Vnew(1,i)+Davis(3)*(Vnew(1,i))^2);  %基本阻力产生的加速度 
        acc_F=F(Vnew(1,i))/(Mass*1000);%牵引加速度
        Fnew(1,i)=F(Vnew(1,i));
        Anew(1,i+1)=acc_grad(1,i+1)+acc_F-acc_res;
        Vnew(1,i+1)=(Vnew(1,i)^2+2*Anew(1,i+1)*ds).^0.5;%得到当前速度
        if(Vnew(1,i+1)>vc)
            Vnew(1,i+1)=vc;%巡航
            Anew(1,i+1)=0;
            Fnew(1,i)=(acc_res-acc_grad(1,i+1))*(Mass*1000);
        end
        e_used=e_used+ Fnew(1,i)*ds/3.6/1000000;
        i=i+1;
    end%能量分配完毕
    e_used=0;
    while i<fix(sections(number+1)/ds)
        %acc_res=(Davis(1)+Davis(2)*Vnew(1,i)+Davis(3)*(Vnew(1,i))^2)/(Mass*1000);  %基本阻力产生的加速度   
        acc_res=(Davis(1)+Davis(2)*Vnew(1,i)+Davis(3)*(Vnew(1,i))^2);  %基本阻力产生的加速度 
        Anew(1,i+1)=acc_grad(1,i+1)-acc_res;
        Fnew(1,i)=0;
        Vnew(1,i+1)=(Vnew(1,i)^2+2*Anew(1,i+1)*ds).^0.5;%得到当前速度
        i=i+1;
    end%能量分完后剩下的区段惰行
end%分配完所有区间的能量
%结尾部分先惰行
% for i=sections(index_max):size-1
%      acc_res=(Davis(1)+Davis(2)*Vnew(1,i)+Davis(3)*(Vnew(1,i))^2)/(Mass*1000);  %基本阻力产生的加速度   
%      Anew(1,i+1)=acc_grad(1,i+1)-acc_res;
%      Fnew(1,i)=0;
%      Vnew(1,i+1)=(Vnew(1,i)^2+2*Anew(1,i+1)*ds).^0.5;%得到当前速度
% end%结尾惰行完毕

for i=1:size%取两个速度的最小值，得到实际速度
  if Vnew(1,i)>v_backward(1,i)
        Vnew(1,i)=v_backward(1,i);
        Anew(1,i)=-acc_backward(1,i);
  end
end

end