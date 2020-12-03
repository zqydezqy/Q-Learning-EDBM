%相关变量，包括车辆重量、最大限速等信息
Mass=200;%最大质量200吨
%Mass=192;%最大质量192吨
%Davis= [3.4818036  0.040254284*3.6   0.006575*3.6*3.6  0]; %戴维斯阻力公式 
Davis0= [0.02  0 0.00008]; %戴维斯阻力公式 
Davis=StoDavis(Davis0,0);
%算运行基本阻力r=1000*(0.005*v^2+0.23*v+2.965),单位是N
MaxSpeed=22;%最大限速：22m/s
MaxTraction=250;%最大牵引力
MaxAcceleration=MaxTraction/Mass;
MaxDeccel=0.6;%最大制动加速度
load route_XHMtoXC.mat%导入线路信息(包括坡度、车站信息、限速信息)