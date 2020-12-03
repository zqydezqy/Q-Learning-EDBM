load('动态特性讨论4.mat');
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
% for i=1:length(Results_Error)
%     if(mod(i,50)==0 &&mod(i,2)==0)
%         ResultsSample=[ResultsSample,500-Results_ValueS0(i)];
%     end
% end
plot(ResultsSample(1:50),'k')
% plot(Results_TotalReward(1:500),'k')
xlabel('Episodes (\times 50)')
ylabel('Error')
grid on;