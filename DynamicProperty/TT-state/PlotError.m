load('动态特性讨论2.mat')
ResultsSample=[];
for i=1:length(Results_Error)
    if(mod(i,50)==0)
        if(Results_Error(i)>10)
            ResultsSample=[ResultsSample,Results_Error(i+1)];
        else
            ResultsSample=[ResultsSample,Results_Error(i)];
        end
    end
end
plot(ResultsSample,'k')
xlabel('Episodes (\times 50)')
ylabel('Error')
grid on;