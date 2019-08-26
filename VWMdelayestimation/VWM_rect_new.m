%%2014/10/11%%%
%%%ref_answer输出所有的colored index，顺序为[target,distractors,not-targets]%%%
Screen('Preference', 'SkipSyncTests', 1); 
clear all;
colorinfo=zeros(100,8,3);  %定义colorinfo矩阵
%% read configurations
frominput.ncolor=input('plz input number of shapes:     ');
frominput.nrect=input('plz input number of rects:     ');
frominput.shapebold=input('plz input which shape to bold: [1]cirle;[2]rect     ');
frominput.ntrial=input('plz input number of trials:     ');
subjname=input('plz subj_name:     ','s');

if ~ismember(frominput.shapebold,[1 2])
    finish;
elseif frominput.shapebold==1, frominput.shapebold='circle'; 
else
    frominput.shapebold='rect';
end

if strcmp(frominput.shapebold,'circle')
    target='circle';
    distractor='rect';
    tar_num=frominput.ncolor-frominput.nrect;
    dis_num=frominput.nrect;
elseif strcmp(frominput.shapebold,'rect')
    target='rect';
    distractor='circle';
    tar_num=frominput.nrect;
    dis_num=frominput.ncolor-frominput.nrect;
end

%% open window
Screens = Screen('Screens');
ScreenNum = max(Screens); %根据全屏分辨率
scr.width = 1680; scr.height = 1050;  %定义屏幕分辨率，换显示器时要修改！！！！！！！！！！
% FontWidth = 40; FontHeight = 40;
[w, wRect] = Screen('OpenWindow', ScreenNum, [192 192 192], [], [], [], [], 4);  %打开屏幕的参数
%改set size时需要改两处，x以及color_list。若采用将圆环分成6份的算法，则set size最大为6
%可调整的内容：【scr.width/scr.height】【注视点的位置】【set size】//【圆环颜色平分】【圆环半径】【色块位置】

HideCursor;



%% instruction

a = imread('instruction.jpg');
GratingIndex = Screen('MakeTexture',w,a);  %将M制作成图片，用GratingIndex来指代
GRect = Screen('Rect',GratingIndex);   %求当前M的位置
cGRect = CenterRect(GRect,wRect);    %将位置调整为屏幕w的中央，wRect即是w屏幕的位置矩阵
Screen('DrawTexture',w,GratingIndex,GRect,cGRect);  %将GratingIndex画到屏幕画板上，GRect是图片原始位置；cGRect是目标位置
Screen('Flip',w);  %最后，需要Flip才会呈现出来。

KbName('UnifyKeyNames');   %定义按键前最好都加上这一句
key_continue = KbName('space');   %定义空格键
reaction = 0;
while (reaction == 0);   %按空格键继续
[KeyIsDown, secs, KeyCode] = KbCheck; 
% reaction = 0;
    if KeyCode(key_continue);
%         reaction = 1;
        break;
    end;
end
KbWait;    %按任意键继续


positionscale=get_position(8,220,[98 98],[scr.width/2 scr.height/2]);

%% start

ncolor=frominput.ncolor;   %色块的个数   
nrect=frominput.nrect; %色块中方的个数 
shapebold=frominput.shapebold;  %加粗的形状 

sub_answer=zeros(1,frominput.ntrial);
ref_answer=zeros(frominput.ntrial,ncolor);


for trial = 1:frominput.ntrial  %trial数
    HideCursor;

    %% fixation
    
    Screen('FillRect',w,[192 192 192]); %把屏幕w涂成灰色
    Screen('TextSize',w,35);        
    DrawFormattedText(w,('+'),'center','center',[0 0 0],[],[],[],[]);
%     Text1 = ('+');
%     oldTextSize = Screen('TextSize',w,35); %调整文字的大小为35号
%     Screen('DrawText', w, Text1,scr.width/2,scr.height/2,[0 0 0]); %呈现文字在屏幕上的函数,***注意注视点位置调试,坐标代表文本框左上角
    Screen('Flip',w);
    a = randsample(300:50:500,1)/1000;
    WaitSecs(a);
    
    %% sample array
    
    Screen('FillRect',w,[192 192 192]); %把屏幕w涂成灰色
    Screen('TextSize',w,35);        
    DrawFormattedText(w,('+'),'center','center',[0 0 0],[],[],[],[]);
    
    load colorscale    
    rng(GetSecs);
    start = floor(rand()*180)+1;    
    if start > 1 && start < 180
        color_index = [start:180 1:start-1];
    elseif start==1
        color_index=1:180;
    elseif start==180
        color_index = [180 1:179];
    end
    rng(GetSecs);
    div=1:8; 
    rd_index=zeros(1,div(end));
    deg_div=floor(360/div(end));
    rd_index(div) =(div-1)*deg_div+round(deg_div*0.125)+randsample(round(deg_div*0.75),1);
    rd_index(:) = floor(rd_index(:)/2)+1;    
    rng(GetSecs);
    x = randsample(color_index(rd_index(:)),ncolor);   

    y = randperm(8);       
    
    color_list = zeros(8,3);
    for ind = 1:ncolor    %set size
        color_list(y(ind),:) = colorscale(x(ind),:);
    end
    colorinfo(trial,:,:) = color_list(:,:);   
    
    shape_list=draw_colorlist(w,positionscale,color_list,nrect); 

    Screen('Flip',w);
    WaitSecs(0.2);       %sample呈现时间
    
    %% delay
    
    Screen('FillRect',w,[192 192 192]); %把屏幕w涂成灰色
    Screen('Flip',w);
    WaitSecs(0.9);
    
    %% test array
    
    load colorscale;
    
    radin = 400; radout = 508;         %画圆环啦啦啦！！先设置参数
    cpoint = [round(scr.width/2) round(scr.height/2)];
    % cpoint=[round(winwidth/2) round(winheight/2)];
    colorwheel = draw_colorscale(w,cpoint,radin,radout) ;       
    
    Screen('TextSize',w,35);        
    DrawFormattedText(w,('+'),'center','center',[0 0 0],[],[],[],[]);
    boldlist=draw_frames(w,positionscale,color_list,shape_list,shapebold); 

    Screen('Flip',w);
    
    %% response
    
    time1 = GetSecs;   %记录反应时
    
    ShowCursor(0);   %显示光标   0：箭头；1：十字；2：手；3：选中符号；4：垂直拉伸符号；5：水平拉伸符号；6:读取符号；7:停止符号
    while 1       %记录点击鼠标的位置
        [x,y,buttons] = GetMouse(w);
        if sum(buttons) > 0
            X = x; Y = y;
            d = sqrt((X-scr.width/2).^2+(Y-scr.height/2).^2);    
            if d>radin && d<radout, break; end  
        end
    end
    
    time2 = GetSecs;   %记录反应时
    RT(trial) = time2 - time1;

    dis_y = scr.height/2-Y;
    if X-scr.width/2 >= 0
        Arc = acosd(dis_y/d);
    else
        Arc = 180+acosd(-dis_y/d);
    end
    
    %Convert 2 colorindex
    sub_answer(trial) = colorwheel(floor(Arc/2)+1);  %被试判断结果
    for ind = 1:180
        for j=1:length(boldlist)
            if sum(colorscale(ind,:)==color_list(boldlist(j),:))==3
                ref_answer(trial,j)=ind;     %加粗方框的结果
                break;
            end
        end
    end
    
    Screen('FillRect',w,[192 192 192]); %把屏幕w涂成灰色
    Screen('Flip',w);
    b = randsample(200:50:400,1)/1000;
    WaitSecs(b);
    % save sub_answer;
    % save ref_answer;
    
end

save (fullfile (['sub' subjname '_' shapebold '_' 'target' num2str(tar_num) '_' 'distractor' num2str(dis_num)]));
Screen('CloseAll');








