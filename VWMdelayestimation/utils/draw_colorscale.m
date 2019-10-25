function [color_index]=draw_colorscale(wnd,cpoint,radin,radout ,colorscale)
% draw color wheel on the screen
rng(GetSecs);

% randomly shuffle the starting point of scale  
start=floor(rand()*180)+1;
if start>1 && start<180
    color_index=[start:180 1:start-1];
elseif start==1
    color_index=1:180;
elseif start==180
    color_index=[180 1:179];
end

% debug purpose
% color_index = 1:180; 

for i=1:180
    Screen('FillArc',wnd,colorscale(color_index(i),:),[cpoint-radout cpoint+radout],i*2-2,2);
end
Screen('FillOval',wnd,[192 192 192],[cpoint-radin cpoint+radin]);