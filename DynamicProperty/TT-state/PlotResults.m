%% 
%plot results
%load(数据区)
Ftra=[];Fmax=250000;
for i=1:length(Foptq)
    if(Aoptq(i)<-0.5)
        res=-1;
    elseif(Foptq(i)/Fmax>0.8)
        res=1;
    else
        res=0;
    end
    Ftra=[Ftra,res];
end
plot(S,Voptq,'k',S,Ftra,'k--');axis([0,1350,-2,22]);title('Optimal driving strategy with Q-Learning Approach')
legend('Speed','Control Sequence');

%% 多个速度曲线
gradient(:,1)=gradient(:,1)*1000;
VLimit=zeros(1,length(S));
for i=1:length(S)
    if(i*ds<=80||i*ds>=gradient(9,1))
        VLimit(1,i)=15;
    else
        VLimit(1,i)=22;
    end
end
plot(S,Voptq95,'k',S-0.1,Voptq98,'k:',S-0.2,Voptq102,'k-.',S,VLimit,'k--');
legend('95s','98s','102s','Speed Limit');
xlabel('Distance (m)');ylabel('Velocity (m/s)');

