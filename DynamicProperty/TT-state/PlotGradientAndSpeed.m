%主函数
%========================初始化=======================%
clear;close all;
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

% Vnew=V(1,:);
% Anew=Acceleration(1,:);
% E_distributed=zeros(1,length(sections));
% E_distributed(1)=E_distributed(1)+1;
% E_distributed(1)=E_distributed(1)+1;
% [Vnew,Anew,Fnew]=energy2speedprofile(dE,E_distributed,sections,Acceleration,V,S,...
%     ds,index_acc,index_brake,v_backward,acc_backward,Davis,acc_grad,vc,Mass,MaxDeccel);
% figure()
% p=plot(S,Vnew,'k');
E_distributed=zeros(1,length(sections));
[Vori,Anew,Fnew]=energy2speedprofile(dE,E_distributed,sections,Acceleration,V,S,...
    ds,index_acc,index_brake,v_backward,acc_backward,Davis,acc_grad,vc,Mass,MaxDeccel);
E_distributed(1)=3;
[Vnew,Anew,Fnew]=energy2speedprofile(dE,E_distributed,sections,Acceleration,V,S,...
    ds,index_acc,index_brake,v_backward,acc_backward,Davis,acc_grad,vc,Mass,MaxDeccel);
E_distributed=zeros(1,length(sections));
E_distributed(5)=3;
[Vnew2,Anew,Fnew]=energy2speedprofile(dE,E_distributed,sections,Acceleration,V,S,...
    ds,index_acc,index_brake,v_backward,acc_backward,Davis,acc_grad,vc,Mass,MaxDeccel);
marker_index=1:500:length(Vnew2);
figure();
% p=plot(S,Vori,'k-.',S,Vnew+0.1,'k:',S,Vnew2-0.2,'k-');
% p(1).LineWidth=1.5;p(2).LineWidth=1.5;
% % legend([p(1),p(2)],{'Distribute to the 1st section','Distribute to the 5th section'});
% legend('Primary strategy','Distribute to the 1st section','Distribute to the 5th section');
gradient(:,1)=gradient(:,1)*1000;
VLimit=zeros(1,length(S));
for i=1:length(S)
    if(i*ds<=80||i*ds>=gradient(9,1))
        VLimit(1,i)=15;
    else
        VLimit(1,i)=22;
    end
end
p=plot(S,Vori+0.2,'k-.',S,Vnew,'k-s',S,Vnew2-0.6,'k-*',S,VLimit,'k--','MarkerIndices',marker_index);
p(1).LineWidth=1.5;p(2).LineWidth=1.5;p(3).LineWidth=1.5;
% legend([p(1),p(2)],{'Distribute to the 1st section','Distribute to the 5th section'});
legend('Primary strategy','Distribute to the 1st section','Distribute to the 5th section','Speed limit');
for i=1:length(gradient(:,1))-1
       
       if gradient(i,2)==0
                rectangle('Position',[gradient(i,1),0,gradient(i+1,1)-gradient(i,1),0.1],'Curvature', [0 0], 'FaceColor','black');
       end
           
       if gradient(i,2)>0
           rectangle('Position',[gradient(i,1),0,gradient(i+1,1)-gradient(i,1),gradient(i,2)/8],'Curvature', [0 0], 'FaceColor','black');
       elseif -24>=gradient(i,2)
                rectangle('Position',[gradient(i,1),2,gradient(i+1,1)-gradient(i,1),18/10],'Curvature', [0 0], 'FaceColor','black');
           
           elseif  -24 <gradient(i,2)&&gradient(i,2)<-10
             rectangle('Position',[gradient(i,1),(20+gradient(i,2)+3),gradient(i+1,1)-gradient(i,1),(abs(gradient(i,2))-3)],'Curvature', [0 0], 'FaceColor','black'); 
            elseif  -10 <gradient(i,2)&&gradient(i,2)<0
             %rectangle('Position',[gradient(i,1),20+gradient(i,2),gradient(i+1,1)-gradient(i,1),abs(gradient(i,2))],'Curvature', [0 0], 'FaceColor','black'); 
             rectangle('Position',[gradient(i,1),gradient(i,2)+abs(gradient(i,2))*7/8,gradient(i+1,1)-gradient(i,1),abs(gradient(i,2))/8],'Curvature', [0 0], 'FaceColor','black'); 
       end
       if(gradient(i,1)>0&&gradient(i,1)<index_brake*ds)
       %line([gradient(i,1),gradient(i,1)],[0,MaxSpeed+1],'LineStyle','--','color','black');
       end
end
% line([index_brake*ds,index_brake*ds],[0,MaxSpeed+1],'LineStyle','--','color','black');
% line([index_acc*ds,index_acc*ds],[0,MaxSpeed+1],'LineStyle','--','color','black');
xlabel('Position(m)','fontsize',12);ylabel('Speed(m/s)','fontsize',12);
text(0,-1,'Gradient','fontsize',12);grid on;


