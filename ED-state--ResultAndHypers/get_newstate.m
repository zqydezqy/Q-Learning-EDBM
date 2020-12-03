function newstate=get_newstate(st,at)
%根据当前状态和动作得到新的状态
%如果原本的状态树种没有这个状态，就扩展树
%输入参数：st,at表示当前状态动作;newstate表示新状态
global statetree;
global nodenumber;
newstate=statetree(st).Nextstate(at);
if newstate==-1%如果不存在下一个状态，则扩展状态树
    nodenumber=nodenumber+1;
    statetree(nodenumber).Energy=statetree(st).Energy;
    statetree(nodenumber).Energy(at)=statetree(nodenumber).Energy(at)+1;%多分配一格能量
%     statetree(nodenumber).Qenergy=zeros(1,length(statetree(nodenumber).Energy));
    statetree(nodenumber).Qenergy=ones(1,length(statetree(nodenumber).Energy))*500;
    statetree(nodenumber).Nextstate=ones(1,length(statetree(nodenumber).Energy))*-1;
    statetree(st).Nextstate(at)=nodenumber;
    newstate=nodenumber;
end
end