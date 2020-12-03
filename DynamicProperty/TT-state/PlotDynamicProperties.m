load('时间状态动态特性3.mat');
ResultsSample=[];
for i=1:length(Results_Error)
    if(mod(i,50)==0)
        if(Results_Error(i)>10)
            ResultsSample=[ResultsSample,500-Results_ValueS0(i+1)];
        else
            ResultsSample=[ResultsSample,500-Results_ValueS0(i)];
        end
    end
end
plot(ResultsSample,'k')
xlabel('Episodes (\times 50)')
ylabel('Value Function')
grid on;