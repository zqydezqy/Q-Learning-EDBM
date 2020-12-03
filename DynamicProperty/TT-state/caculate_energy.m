function [E,e]=caculate_energy(Fraction,S,ds)
size=length(S);
for i=1:size%¼ÆËãÇ£ÒıÄÜºÄ
    E(1,i)=Fraction(1,i)*ds;
end
e=sum(E)/3.6/1000000;
end