function F=F(v)
%计算牵引力，牵引力与速度有关
 %[T,B,m,s1,s2,s3,s4,s5,s6,s7,s8,s9,s10,s11,s12]=Parameter;
if v<10
    F=250000;%单位是N
else
    F=250000-(v-10)*20;%最大牵引力与速度有关
end

