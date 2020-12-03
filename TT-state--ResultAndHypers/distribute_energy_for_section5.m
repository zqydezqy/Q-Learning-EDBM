function [Vnew,Anew,Fnew,E_distributed_after]=distribute_energy_for_section4(dE,E_distributed,index,sections,Acceleration,V,S,...
    ds,index_acc,index_brake,v_backward,acc_backward,Davis,acc_grad,vc,Mass,MaxDeccel)
%�����������Ϊ��dE:�������������index���ڵڼ����������������E_distributed���Ѿ������˶���������sections���ɷ�������������λ������
%Acceleration:ԭ���߼��ٶȱ�V��ԭ�����ٶȱ�S��·�̱�Fraction������ǣ������ds��·�̷ָ�
%index_acc���������ε����ꣻindex_brake���ƶ����ε�����
%v_backward�������ٶȣ�acc_backward��������ٶȣ�Davis����ά˹��������������������
%acc_grad���¶ȵļ��ٶȣ�vc��Ѳ���ٶȣ�Mass���г�������MaxDeccel������ƶ���
index_max=length(sections);
size=length(S);
e_used=0;%���ٹ��������ĵ�����
%�ȷ���ø����ε�����
E_distributed_after=E_distributed(1,:);
E_distributed_after(index)=E_distributed_after(index)+1;%���һ������
%���¼�����������������
Vnew=zeros(1,size);
Anew=zeros(1,size);
Fnew=zeros(1,size);
%ǣ���׶�
for i=1:index_acc
    acc_res=(Davis(1)+Davis(2)*Vnew(1,i)+Davis(3)*(Vnew(1,i))^2);  %�������������ļ��ٶ�    
    acc_F=F(Vnew(1,i))/(Mass*1000);%ǣ�����ٶ�
    Fnew(1,i)=F(Vnew(1,i));%�洢ǣ����
    Anew(1,i+1)=acc_grad(1,i+1)+acc_F-acc_res;
    Vnew(1,i+1)=(Vnew(1,i)^2+2*Anew(1,i+1)*ds).^0.5;%�õ���ǰ�ٶ�
end%ǣ������
%�������е��������з���
vlimit=21;
dv=3;%���е��ٶȼ��
for number=1:index_max-1
    E_total=E_distributed_after(1,number)*dE;
    i=fix(sections(number)/ds);%��ʼ��������
    coastingflag=0;%�Ƿ����
    while e_used<E_total&&i<fix(sections(number+1)/ds)
        %acc_res=(Davis(1)+Davis(2)*Vnew(1,i)+Davis(3)*(Vnew(1,i))^2)/(Mass*1000);  %�������������ļ��ٶ� 
        acc_res=(Davis(1)+Davis(2)*Vnew(1,i)+Davis(3)*(Vnew(1,i))^2);  %�������������ļ��ٶ� 
        if(coastingflag==0)%ȷ���Ǽ��ٻ��Ƕ���
            acc_F=F(Vnew(1,i))/(Mass*1000);%ǣ�����ٶ�
            Fnew(1,i)=F(Vnew(1,i));
        else
            acc_F=0;%ǣ�����ٶ�
            Fnew(1,i)=0;
        end
        Anew(1,i+1)=acc_grad(1,i+1)+acc_F-acc_res;
        Vnew(1,i+1)=(Vnew(1,i)^2+2*Anew(1,i+1)*ds).^0.5;%�õ���ǰ�ٶ�
        if(Vnew(1,i+1)>vlimit)
            Vnew(1,i+1)=vlimit;
            coastingflag=1;
        elseif(Vnew(1,i+1)<vlimit-dv && coastingflag==1)
            coastingflag=0;
        end
%         if(Vnew(1,i+1)>vc)
%             Vnew(1,i+1)=vc;%Ѳ��
%             Anew(1,i+1)=0;
%             Fnew(1,i)=(acc_res-acc_grad(1,i+1))*(Mass*1000);
%         end
        e_used=e_used+ Fnew(1,i)*ds/3.6/1000000;
        i=i+1;
    end%�����������
    e_used=0;
    while i<fix(sections(number+1)/ds)
        %acc_res=(Davis(1)+Davis(2)*Vnew(1,i)+Davis(3)*(Vnew(1,i))^2)/(Mass*1000);  %�������������ļ��ٶ�   
        acc_res=(Davis(1)+Davis(2)*Vnew(1,i)+Davis(3)*(Vnew(1,i))^2);  %�������������ļ��ٶ� 
        Anew(1,i+1)=acc_grad(1,i+1)-acc_res;
        Fnew(1,i)=0;
        Vnew(1,i+1)=(Vnew(1,i)^2+2*Anew(1,i+1)*ds).^0.5;%�õ���ǰ�ٶ�
        i=i+1;
    end%���������ʣ�µ����ζ���
end%�������������������
%��β�����ȶ���
% for i=sections(index_max):size-1
%      acc_res=(Davis(1)+Davis(2)*Vnew(1,i)+Davis(3)*(Vnew(1,i))^2)/(Mass*1000);  %�������������ļ��ٶ�   
%      Anew(1,i+1)=acc_grad(1,i+1)-acc_res;
%      Fnew(1,i)=0;
%      Vnew(1,i+1)=(Vnew(1,i)^2+2*Anew(1,i+1)*ds).^0.5;%�õ���ǰ�ٶ�
% end%��β�������

for i=1:size%ȡ�����ٶȵ���Сֵ���õ�ʵ���ٶ�
  if Vnew(1,i)>v_backward(1,i)
        Vnew(1,i)=v_backward(1,i);
        Anew(1,i)=-acc_backward(1,i);
  end
end

end%��������