% VWM color-delayed estimation task, practice
% History
%   20191025 RZ add time constraints
%   20190826 RZ change the monitor setting part
%   20190808 RZ save revise the code and save more inforamtion.

clear all;close all;

%% Parameter you want to change

%addpath(genpath('')); % add the RZutil directory here and the end of this script

subj = input('Please the subject initial (e.g., RYZ or RZ)?: ','s');
nStim = 2;
nTrials = 50; % How many trials for each set size.

%% calculation monitor parameters
scrSize = [32 18]; % [width, height] cm
resolution = [1920 1080]; % pixels
viewDist = 50; %cm
scale_factor = atand(scrSize(1)/2/viewDist)*2*60/resolution(1); % how many acrmin per pixels

%% stimuli parameters
ovalr = 5; % pixels, radius of fixation oval
radin = 7.8; % deg,
radout = 9.8; % deg,
bg = 192; % background color intensity
nPosi = 8; % How many possible positions that stimuli can occur  
posiRadius = 4; % deg, radius of stimulus presentation distance from center of screen
shapeSize = 1.5; % deg, diameter (circle) or edge length of an object

%% Experimental parameters
delayDur = 1; % seconds;
sampleDur = 0.11; % sample duration
respLimit = 60; % Time window for a response

%% calculate some parameters
radin = radin * 60 / scale_factor;
radout = radout * 60 / scale_factor; 
posiRadius = posiRadius * 60 / scale_factor; 
shapeSize = shapeSize * 60 / scale_factor;

colorinfo=zeros(100, 8, 3);  %

%% Open window
Screen('Preference', 'SkipSyncTests', 1);
Screens = Screen('Screens');
ScreenNum = max(Screens); 
[w, wRect] = Screen('OpenWindow', ScreenNum, [255 255 255], [], [], [], [], 4); 
scr.width = wRect(3);
scr.height = wRect(4);

%% instruction
a = imread('instruction.jpg');
GratingIndex = Screen('MakeTexture',w,a);  
GRect = Screen('Rect',GratingIndex);   
cGRect = CenterRect(GRect,wRect);    
Screen('DrawTexture',w,GratingIndex,GRect,cGRect);  
Screen('Flip',w);  %
getkeyresp('space'); % wait for space to start the experiment

% calculate all possible positions
positionscale = get_position(nPosi, posiRadius, [shapeSize shapeSize], [scr.width/2 scr.height/2]); % get the possible positions of stimuli
% load RGB values of standard color space
colorscale = load('colorscale','colorscale');
colorscale = colorscale.colorscale;
%% Start
results.colorWheelStart = zeros(1, nTrials); % the start number of the colorwheel?1~180
results.respInd = zeros(1, nTrials); % response color index, 1~180
results.respIndArc = zeros(1, nTrials); % response degree on the colorwheel, 1~360
results.stimuliInd = zeros(nTrials, nStim); % all stimuli color index
results.RT = zeros(1, nTrials); % reaction time
results.probePosiInd = zeros(1,nTrials); % probe position index, 1-8
results.probeInd = zeros(1,nTrials); % probe color index, 1~180
results.colorList = cell(1,nTrials); % colorlist for all stimull
results.posiInd = zeros(nTrials,nStim); % position index of all targets, 1-8

trial = 1;
while trial <= nTrials  
    
    HideCursor;

    %% Fixation
    Screen('FillRect', w, [bg bg bg]); 
    Screen('FrameOval', w, 0,[scr.width/2-ovalr, scr.height/2-ovalr, scr.width/2+ovalr, scr.height/2+ovalr],2,2)
    Screen('Flip',w);
    a = randsample(300:50:500,1)/1000; % randomly sample a fixation period
    WaitSecs(a);
    
    %% Sample array
    Screen('FillRect',w, [bg bg bg]); 
    Screen('TextSize',w, 35);        
    Screen('FrameOval', w, 0,[scr.width/2-ovalr, scr.height/2-ovalr, scr.width/2+ovalr, scr.height/2+ovalr],2,2)
    
    % We randomly start the color wheel to sample the colors of targets
    rng(GetSecs);
    start = floor(rand()*180)+1; %1-180
    if start > 1 && start < 180
        color_index = [start:180 1:start-1];
    elseif start==1
        color_index=1:180;
    elseif start==180
        color_index = [180 1:179];
    end
    
    % We do not want stimuli colors are too closed, so we set candidate
    % colors apart
    rng(GetSecs);
    deg_div=floor(360/nPosi);
    rd_index =(1:nPosi-1) * deg_div + round(deg_div*0.125) + randsample(round(deg_div * 0.75), 1);
    rd_index = floor(rd_index/2)+1;  % color is 180 so we divided by 2  
    
    rng(GetSecs);
    x = randsample(color_index(rd_index), nStim); % choose n stim
    results.stimuliInd(trial,:) = x; % save the color index of all targes
    
    % get the position
    posi = randperm(nPosi);  % random positions, correponding to positionscale     
    posi = posi(1:nStim); 
    results.posiInd(trial,:) = posi;
    
    % create the color_list for this trial
    color_list = zeros(nPosi,3);
    color_list(posi,:) = colorscale(x,:);
    results.colorList{trial} = color_list;
   
    % draw stimuli
    for ind = 1:length(posi)
        Screen('FillRect', w, color_list(posi(ind),:), positionscale(posi(ind),:)); % change these part, otherwise the nearby color tend to be the same color
    end
    
    Screen('Flip',w);
    WaitSecs(sampleDur);       
    
    %% Delay
    Screen('FillRect', w, [bg bg bg]); %delay period
    Screen('FrameOval', w, 0,[scr.width/2-ovalr, scr.height/2-ovalr, scr.width/2+ovalr, scr.height/2+ovalr],2,2)
    Screen('Flip',w);
    WaitSecs(delayDur);
    
    %% Test Array
    cpoint = [round(scr.width/2) round(scr.height/2)]; % center point
    colorwheel = draw_colorscale(w, cpoint, radin, radout, colorscale);
    results.colorWheelStart(trial) = colorwheel(1); % % save the start point of colorwheel information
    
    % Fixation point
    Screen('FrameOval', w, 0,[scr.width/2-ovalr, scr.height/2-ovalr, scr.width/2+ovalr, scr.height/2+ovalr],2,2)
    
    % draw stimuli (debug purpose)
    for ind = 1:length(posi)
        Screen('FillRect', w, color_list(posi(ind),:), positionscale(posi(ind),:)); % change these part, otherwise the nearby color tend to be the same color
    end
    
    % Draw black frames
    results.probePosiInd(trial)=draw_frames(w, positionscale, color_list); % 1-8; output bold is the row index in color_list, which is the bolded color.
    results.probeInd(trial) = x(find(posi == results.probePosiInd(trial))); % 1-180, color index of the probe
    Screen('Flip',w);
    
    
    % for debug purpose
    fprintf('nTrials is %d \n', nTrials);
    fprintf('wheel start is %d \n', results.colorWheelStart(trial));
    fprintf('probe location is %d \n', results.probePosiInd(trial));
    fprintf('probe color is %d \n', results.probeInd(trial));
       
    %% response
    time1 = GetSecs;   %
    ShowCursor(0, w); % Not sure why we need to call this twice...
    ShowCursor(0, w);
    
    noresp = 1; % first assume no response in this trial
    while GetSecs-time1 < respLimit       
        [x,y,buttons] = GetMouse(w);
        if sum(buttons) > 0
            X = x; Y = y;
            d = sqrt((X-scr.width/2).^2+(Y-scr.height/2).^2);    
            if d > radin && d < radout
                noresp = 0;
                break; 
            end  
        end
    end
    
    if noresp == 1 % no response within 4 seconds
        nTrials = nTrials + 1;
    end
    
    results.RT(trial) = GetSecs - time1;
    
    %% Calculate response 
    
    % Convert to degree between [1:360]
    dis_y = scr.height/2-Y;
    if X-scr.width/2 >= 0
        Arc = acosd(dis_y/d);
    else
        Arc = 180+acosd(-dis_y/d);
    end
    
    % Convert 2 colorindex
    results.respIndArc(trial)=Arc; % Arc, 1~360
    results.respInd(trial) = colorwheel(floor(Arc/2)+1); % respInd, 1~180
    results.error(trial) = circulardiff(results.respInd(trial),results.probeInd(trial), 180); % error range, -90~89

    Screen('FillRect',w,[bg bg bg]);
    Screen('FrameOval', w, 0,[scr.width/2-ovalr, scr.height/2-ovalr, scr.width/2+ovalr, scr.height/2+ovalr],2,2)
    Screen('Flip',w);
    b = randsample(200:50:400,1)/1000; % random delay
    WaitSecs(b);
    
    % debug purpose
    fprintf('resp color is %d \n\n', results.respInd(trial));
    
    
    if trial == nTrials/2
        Screen('DrawTexture',w,GratingIndex,GRect,cGRect);  
        Screen('DrawText',w,'Rest, press space to continue..',scr.width/2-300,scr.height/2,0); 
        Screen('Flip',w);  %
        getkeyresp('space'); % wait for space to start the experiment
        
    end
    
    trial = trial + 1;
end
% Save the data
filename = strcat(subj,sprintf('_set%d_',nStim),datestr(now,'yymmddHHMM'),'.mat');
if exist(filename,'file')
    error('data file name exists')
end
save(filename);
Screen('CloseAll');

%% calculate the response and save it
histogram(results.error,12);
xlim([-90 90]);
xlabel('Resp error (color deg)');
ylabel('Number of trials');
saveas(gcf, filename(1:end-4), 'png'); % save the figure

%%
rmpath(genpath('')); % remove the RZutil directory here







