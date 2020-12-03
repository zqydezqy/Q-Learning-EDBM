function [toptimal,eoptimal]=EDBMFunc(dE)
init;%初始化，包括初始化线路模型，计算初始速度曲线等
positions=gradient(:,1)';
sections=positions.*1000;
sections=[sections,s_brake];
sections(1)=s_acc;%可以分配能量的区段
t_target=100;%最优时间
Vopt=V(1,:);
Aopt=Acceleration(1,:);
Topt=T0(1,:);
Eopt=E0(1,:);%以上四项都是最优化的项
Fopt=Fraction(1,:);
topt=t0;
eopt=e0; 
count=1;%计数器，计现在是第几次更新
E_dis_opt=zeros(1,length(sections));%记录已经分配出去的能量
while topt>t_target    
    etratemax=0;%能量和时间的比值，谁大证明谁的效果好，更应该分配给这个区段 
    Vtemp=Vopt(1,:);
    Atemp=Aopt(1,:);
    Ttemp=Topt(1,:);
    Etemp=Eopt(1,:);%以上四项是中间变量
    Ftemp=Fopt(1,:);
    E_dis_temp=E_dis_opt(1,:);
%     fprintf("第%d次分配能量\n",count)
    for i=1:length(sections)%穷举每一个区段（按坡度划分），看谁的节约时间效果好
    [Vnew,Anew,Fnew,E_dis_new]=distribute_energy_for_section5(dE,E_dis_opt,i,...
        sections,Aopt,Vopt,S,...
     ds,index_acc,index_brake,v_backward,acc_backward,Davis,acc_grad,vc,Mass,MaxDeccel);
    [Tnew,tnew]=caculate_time(Vnew,S,ds);
    [Enew,enew]=caculate_energy(Fnew,S,ds);
    dt1=abs(tnew-topt);
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
    end%结束给每个区段分能量的for循环
    Vopt=Vtemp(1,:);
    Aopt=Atemp(1,:);
    Fopt=Ftemp(1,:);
    E_dis_opt=E_dis_temp(1,:);
    [Topt,topt]=caculate_time(Vopt,S,ds);
    [Eopt,eopt]=caculate_energy(Fopt,S,ds);
%     fprintf("第%d次分配能量给第%d个区间后，功耗变为%f，耗时变为%f\n",count,aopt,eopt,topt);
%     fprintf("\n");
    count=count+1;
end%结束大循环
[~,toptimal]=caculate_time(Vopt,S,ds);
[~,eoptimal]=caculate_energy(Fopt,S,ds);
% fprintf("普通方法优化后总耗时为：%f秒\n",topt)
% fprintf("普通方法优化后总的牵引能耗为：%f千瓦时\n",eopt)
end