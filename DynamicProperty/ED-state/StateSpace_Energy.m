%以能量作为空间状态定义方式
%树的节点数据结构
%number:该状态的编号
%Energy:能量矩阵，表示状态
%Qenergy:表示当前状态下所有动作的值函数
%Nextstate:表示下一个状态在statetree中的标号
n_actions=length(sections)-3;%动作空间：所有可以分配能量的区段,不要在最后一个区段分能量
% n_actions=3;%动作空间：所有可以分配能量的区段,不要在最后一个区段分能量
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













