function [T,t]=caculate_time(V,S,ds)
size=length(S);
for i=1:size-1%����ÿ���ε�ʱ��
 T(1,i+1)=2*ds/(V(1,i+1)+V(1,i));
end
t=sum(T);
end