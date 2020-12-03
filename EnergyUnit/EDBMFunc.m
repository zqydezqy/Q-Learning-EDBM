function [toptimal,eoptimal]=EDBMFunc(dE)
init;%��ʼ����������ʼ����·ģ�ͣ������ʼ�ٶ����ߵ�
positions=gradient(:,1)';
sections=positions.*1000;
sections=[sections,s_brake];
sections(1)=s_acc;%���Է�������������
t_target=100;%����ʱ��
Vopt=V(1,:);
Aopt=Acceleration(1,:);
Topt=T0(1,:);
Eopt=E0(1,:);%������������Ż�����
Fopt=Fraction(1,:);
topt=t0;
eopt=e0; 
count=1;%���������������ǵڼ��θ���
E_dis_opt=zeros(1,length(sections));%��¼�Ѿ������ȥ������
while topt>t_target    
    etratemax=0;%������ʱ��ı�ֵ��˭��֤��˭��Ч���ã���Ӧ�÷����������� 
    Vtemp=Vopt(1,:);
    Atemp=Aopt(1,:);
    Ttemp=Topt(1,:);
    Etemp=Eopt(1,:);%�����������м����
    Ftemp=Fopt(1,:);
    E_dis_temp=E_dis_opt(1,:);
%     fprintf("��%d�η�������\n",count)
    for i=1:length(sections)%���ÿһ�����Σ����¶Ȼ��֣�����˭�Ľ�Լʱ��Ч����
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
    end%������ÿ�����η�������forѭ��
    Vopt=Vtemp(1,:);
    Aopt=Atemp(1,:);
    Fopt=Ftemp(1,:);
    E_dis_opt=E_dis_temp(1,:);
    [Topt,topt]=caculate_time(Vopt,S,ds);
    [Eopt,eopt]=caculate_energy(Fopt,S,ds);
%     fprintf("��%d�η�����������%d������󣬹��ı�Ϊ%f����ʱ��Ϊ%f\n",count,aopt,eopt,topt);
%     fprintf("\n");
    count=count+1;
end%������ѭ��
[~,toptimal]=caculate_time(Vopt,S,ds);
[~,eoptimal]=caculate_energy(Fopt,S,ds);
% fprintf("��ͨ�����Ż����ܺ�ʱΪ��%f��\n",topt)
% fprintf("��ͨ�����Ż����ܵ�ǣ���ܺ�Ϊ��%fǧ��ʱ\n",eopt)
end