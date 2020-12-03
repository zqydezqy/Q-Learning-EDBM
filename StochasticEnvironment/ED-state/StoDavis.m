%生成随机阻力参数（本片段）
function r=StoDavis(davis,v)
    a=normrnd(davis(1),0.000044,[1 1]);
    b=normrnd(davis(2),0.000044,[1 1]);
    c=normrnd(davis(3),0.000044,[1 1]);
%     r=a+b*v+c*v*v;
    r=[a,b,c];
    return;
end