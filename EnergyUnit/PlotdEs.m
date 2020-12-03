Times=[];
Energys=[];
dEs=0.01;
dEs1=0.05:0.05:0.5;
dEs=[dEs,dEs1];
for i=1:length(dEs)
    dE=dEs(i);
    [toptimal,eoptimal]=EDBMFunc(dE);
    Times(i)=toptimal;
    Energys(i)=eoptimal;
end
%% 
figure();
yyaxis left;
plot(dEs,Times,'b-o');
xlabel('Energy unit (kWh)');
ylabel('Trip time (s)');
legend('Trip time');
yyaxis right;
plot(dEs,Energys,'r--s');
ylabel('Energy consumption (kWh)');
legend('Trip time','Energy consumption');
grid on;