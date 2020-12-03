function [Vnew,Anew,Fnew,E_distributed_after]=distribute_energy_for_section4(dE,E_distributed,index,sections,Acceleration,V,S,...
    ds,index_acc,index_brake,v_backward,acc_backward,Davis,acc_grad,vc,Mass,MaxDeccel)
%输入参数依次为：dE:分配的能量数；index：在第几个区间分配能量；E_distributed：已经分配了多少能量；sections：可分配能量的区间位置向量
%Acceleration:原曲线加速度表；V：原曲线速度表；S：路程表；Fraction：各段牵引力；ds：路程分格
%index_acc：加速区段的坐标；index_brake：制动区段的坐标
%v_backward：后向速度；acc_backward：后向加速度；Davis：戴维斯阻力参数表计算基本阻力
%acc_grad：坡度的加速度；vc：巡航速度；Mass：列车质量；MaxDeccel：最大制动力
index_max=length(sections);
size=length(S);
e_used=0;%加速过程中消耗的能量
%先分配好个区段的能量
E_distributed_after=E_distributed(1,:);
E_distributed_after(index)=E_distributed_after(index)+1;%多分一份能量
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
vlimit=21;
dv=3;%惰行的速度间隔
for number=1:index_max-1
    E_total=E_distributed_after(1,number)*dE;
    i=fix(sections(number)/ds);%开始分配能量
    coastingflag=0;%是否惰行
    while e_used<E_total&&i<fix(sections(number+1)/ds)
        %acc_res=(Davis(1)+Davis(2)*Vnew(1,i)+Davis(3)*(Vnew(1,i))^2)/(Mass*1000);  %基本阻力产生的加速度 
        acc_res=(Davis(1)+Davis(2)*Vnew(1,i)+Davis(3)*(Vnew(1,i))^2);  %基本阻力产生的加速度 
        if(coastingflag==0)%确定是加速还是惰行
            acc_F=F(Vnew(1,i))/(Mass*1000);%牵引加速度
            Fnew(1,i)=F(Vnew(1,i));
        else
            acc_F=0;%牵引加速度
            Fnew(1,i)=0;
        end
        Anew(1,i+1)=acc_grad(1,i+1)+acc_F-acc_res;
        Vnew(1,i+1)=(Vnew(1,i)^2+2*Anew(1,i+1)*ds).^0.5;%得到当前速度
        if(Vnew(1,i+1)>vlimit)
            Vnew(1,i+1)=vlimit;
            coastingflag=1;
        elseif(Vnew(1,i+1)<vlimit-dv && coastingflag==1)
            coastingflag=0;
        end
%         if(Vnew(1,i+1)>vc)
%             Vnew(1,i+1)=vc;%巡航
%             Anew(1,i+1)=0;
%             Fnew(1,i)=(acc_res-acc_grad(1,i+1))*(Mass*1000);
%         end
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

end%函数结束