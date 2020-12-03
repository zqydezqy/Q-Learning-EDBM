%========================初始化=======================%
% clear;close all;
init;%初始化，包括初始化线路模型，计算初始速度曲线等
positions=gradient(:,1)';
sections=positions.*1000;
sections=[sections,s_brake];
sections(1)=s_acc;%可以分配能量的区段

%% ==========================Q学习方法1：以时间作为状态========================
%=======奖励：进入终点状态奖励为0，其他为-1=======
n_actions=length(sections)-1;%动作空间：所有可以分配能量的区段,不要在最后一个区段分能量
StateSpace_Time;
dE=0.5;%单位：千瓦时
alpha=0.1;
gamma=0.9;
epsilon = 0.2;
gradient(:,1)=gradient(:,1)*1000;
VLimit=zeros(1,length(S));
marker_index=1:500:length(Voptq95);
for i=1:length(S)
    if(i*ds<=80||i*ds>=gradient(9,1)+15)
        VLimit(1,i)=15;
    else
        VLimit(1,i)=22;
    end
end

plot(S+0.5,Voptq95,'k',S,Voptq98,'r--*',S-0.5,Voptq102,'g-s',S,VLimit,'k--','MarkerIndices',marker_index);
axis([0,1350,0,25]);grid on;legend('95s','98s','102s','Speed limit');
xlabel('Distance(m)');ylabel('Velocity(m/s)');
axis([0,1350,-6,25])
% 画坡度
for i=1:length(gradient(:,1))-1
       
       if gradient(i,2)==0
                rectangle('Position',[gradient(i,1),0,gradient(i+1,1)-gradient(i,1),0.1],'Curvature', [0 0], 'FaceColor','black');
       end
           
       if gradient(i,2)>0
           rectangle('Position',[gradient(i,1),0,gradient(i+1,1)-gradient(i,1),gradient(i,2)],'Curvature', [0 0], 'FaceColor','black');
       elseif -24>=gradient(i,2)
                rectangle('Position',[gradient(i,1),2,gradient(i+1,1)-gradient(i,1),18],'Curvature', [0 0], 'FaceColor','black');
           
           elseif  -24 <gradient(i,2)&&gradient(i,2)<-10
             rectangle('Position',[gradient(i,1),20+gradient(i,2)+3,gradient(i+1,1)-gradient(i,1),abs(gradient(i,2))-3],'Curvature', [0 0], 'FaceColor','black'); 
            elseif  -10 <gradient(i,2)&&gradient(i,2)<0
             %rectangle('Position',[gradient(i,1),20+gradient(i,2),gradient(i+1,1)-gradient(i,1),abs(gradient(i,2))],'Curvature', [0 0], 'FaceColor','black'); 
             rectangle('Position',[gradient(i,1),gradient(i,2),gradient(i+1,1)-gradient(i,1),abs(gradient(i,2))],'Curvature', [0 0], 'FaceColor','black'); 
       end
end
text(1075,1,sprintf('Gradient(%c)', char(8240')),'fontsize',12);