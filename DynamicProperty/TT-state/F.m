function F=F(v)
%����ǣ������ǣ�������ٶ��й�
 %[T,B,m,s1,s2,s3,s4,s5,s6,s7,s8,s9,s10,s11,s12]=Parameter;
if v<10
    F=250000;%��λ��N
else
    F=250000-(v-10)*20;%���ǣ�������ٶ��й�
end

