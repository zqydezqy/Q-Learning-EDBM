%========================��ʼ��=======================%
% clear;close all;
init;%��ʼ����������ʼ����·ģ�ͣ������ʼ�ٶ����ߵ�
positions=gradient(:,1)';
sections=positions.*1000;
sections=[sections,s_brake];
sections(1)=s_acc;%���Է�������������

%% ==========================Qѧϰ����1����ʱ����Ϊ״̬========================
%=======�����������յ�״̬����Ϊ0������Ϊ-1=======
n_actions=length(sections)-1;%�����ռ䣺���п��Է�������������,��Ҫ�����һ�����η�����
StateSpace_Time;
dE=0.5;%��λ��ǧ��ʱ
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
% ���¶�
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