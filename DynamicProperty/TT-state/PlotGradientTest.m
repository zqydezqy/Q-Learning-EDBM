load('route_XHMtoXC.mat')
figure(1);
gradient(:,1)=gradient(:,1)*1000;
for i=1:length(gradient(:,1))-1
       
       if gradient(i,2)==0
                rectangle('Position',[gradient(i,1),0,gradient(i+1,1)-gradient(i,1),0.1],'Curvature', [0 0], 'FaceColor','black');
       end
           
       if gradient(i,2)>0
           rectangle('Position',[gradient(i,1),0,gradient(i+1,1)-gradient(i,1),gradient(i,2)],'Curvature', [0 0], 'FaceColor','black');
       elseif -24>=gradient(i,2)
                rectangle('Position',[gradient(i,1),2,gradient(i+1,1)-gradient(i,1),18],'Curvature', [0 0], 'FaceColor','black');
           
           elseif  -24 <gradient(i,2)&&gradient(i,2)<-10
             rectangle('Position',[gradient(i,1),20+gradient(i,2)+3,gradient(i+1,1)-gradient(i,1),abs(gradient(i,2))-3],'Curvature', [0 0], 'FaceColor','black'); 
            elseif  -10 <gradient(i,2)&&gradient(i,2)<0
             %rectangle('Position',[gradient(i,1),20+gradient(i,2),gradient(i+1,1)-gradient(i,1),abs(gradient(i,2))],'Curvature', [0 0], 'FaceColor','black'); 
             rectangle('Position',[gradient(i,1),gradient(i,2),gradient(i+1,1)-gradient(i,1),abs(gradient(i,2))],'Curvature', [0 0], 'FaceColor','black'); 
       end
end
%title('Gradient');
xlabel('Position(m)','fontsize',20);ylabel('Gradient(бы)','fontsize',20);