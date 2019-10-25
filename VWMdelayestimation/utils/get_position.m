function [ positionscale ] = get_position(nDiv, radius, shapesize, scr)

deg=(360/nDiv)/2+(360/nDiv).*(0:nDiv-1); % we divide 360deg circle as 

positionscale=zeros(nDiv,4); 
positionscale(:,1)=scr(1)+sind(deg)*radius-shapesize(1)/2;
positionscale(:,2)=scr(2)+cosd(deg)*radius-shapesize(2)/2;
positionscale(:,3)=scr(1)+sind(deg)*radius+shapesize(1)/2;
positionscale(:,4)=scr(2)+cosd(deg)*radius+shapesize(2)/2;




