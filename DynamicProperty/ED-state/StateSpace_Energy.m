%��������Ϊ�ռ�״̬���巽ʽ
%���Ľڵ����ݽṹ
%number:��״̬�ı��
%Energy:�������󣬱�ʾ״̬
%Qenergy:��ʾ��ǰ״̬�����ж�����ֵ����
%Nextstate:��ʾ��һ��״̬��statetree�еı��
n_actions=length(sections)-3;%�����ռ䣺���п��Է�������������,��Ҫ�����һ�����η�����
% n_actions=3;%�����ռ䣺���п��Է�������������,��Ҫ�����һ�����η�����
global statetree;
global nodenumber;
nodenumber=1;
initstate.Energy=zeros(1,10);
% initstate.Qenergy=zeros(1,10);
initstate.Qenergy=ones(1,10)*500;
initstate.Nextstate=ones(1,10)*-1;
statetree(nodenumber).Energy=initstate.Energy;
statetree(nodenumber).Qenergy=initstate.Qenergy;
statetree(nodenumber).Nextstate=initstate.Nextstate;













