function newstate=get_newstate(st,at)
%���ݵ�ǰ״̬�Ͷ����õ��µ�״̬
%���ԭ����״̬����û�����״̬������չ��
%���������st,at��ʾ��ǰ״̬����;newstate��ʾ��״̬
global statetree;
global nodenumber;
newstate=statetree(st).Nextstate(at);
if newstate==-1%�����������һ��״̬������չ״̬��
    nodenumber=nodenumber+1;
    statetree(nodenumber).Energy=statetree(st).Energy;
    statetree(nodenumber).Energy(at)=statetree(nodenumber).Energy(at)+1;%�����һ������
%     statetree(nodenumber).Qenergy=zeros(1,length(statetree(nodenumber).Energy));
    statetree(nodenumber).Qenergy=ones(1,length(statetree(nodenumber).Energy))*500;
    statetree(nodenumber).Nextstate=ones(1,length(statetree(nodenumber).Energy))*-1;
    statetree(st).Nextstate(at)=nodenumber;
    newstate=nodenumber;
end
end