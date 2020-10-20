% VWM color-delayed estimation task, this is the practice
%
% History
%   20201016 RZ fixed the screen resolution on mac, combine practice and
%       main experiment
%   20201012 RZ add multiple levels of set size within the same session
%   20191206 RZ confirmed not only record probe and response, also record
%       all color squares information
%   20191025 RZ add 4s constraint (subject must response within 4s) for the respnse
%   20190808 RZ save revise the code and save more inforamtion.
%   20190709 RZ adds brainSite
%   20190629 RZ modified original code

clear all;close all;clc;
KbName('UnifyKeyNames');

%%  ------- !!! important !!! Parameter you want to change ----------
subj = input('Please the subject initial (e.g., RYZ or RZ)?: ','s');
mainExp = input('Please choose the exp (1, main exp; 0, practice): ');

% mac built-in screen
scrSize = [32 18]; % [width, height] cm
resolution = [2560 1600]; % pixels, be careful about the, MacOS is

% % office desk monitor
%scrSize = [59.5 33.5]; % [width, height] cm
%resolution = [3840 2160]; % pixels, 

nStim = [1 3 6 8]; % set size levels
trialsPerStim = [3 3 3 3]; % How many trials for each set size.

viewDist = 50; %please keep the viewDist roughly 50 cm
%% calculation monitor parameters
addpath(genpath('./utils')); % add the RZutil directory here and the end of this script
nTrials = sum(trialsPerStim);
nSetSize = sum(nStim);
scale_factor = atand(scrSize(1)/2/viewDist)*2*60/resolution(1); % how many acrmin per pixels

%% stimuli parameters
ovalr = round(0.25 * 60 / scale_factor); % pixels, radius of fixation oval
radin = 7.8; % deg,
radout = 9.8; % deg,
bg = 192; % background color intensity
nPosi = 8; % How many possible positions that stimuli can occur  
posiRadius = 4; % deg, radius of stimulus presentation distance from center of screen
shapeSize = 1.5; % deg, diameter (circle) or edge length of an object

%% Experimental parameters
delayDur = 1; % seconds, delay duration;
sampleDur = 0.11; % seconds, sample duration
respLimit = 4; % seconds, Time window for a response

%% calculate some parameters
radin = radin * 60 / scale_factor;
radout = radout * 60 / scale_factor; 
posiRadius = posiRadius * 60 / scale_factor; 
shapeSize = shapeSize * 60 / scale_factor;

colorinfo=zeros(100, 8, 3);  %

%% Open window
Screen('Preference', 'SkipSyncTests', 1);
Screens = Screen('Screens');
PsychImaging('PrepareConfiguration');
PsychImaging('AddTask','General','UseRetinaResolution');
ScreenNum = max(Screens); 
%[w, wRect] = Screen('OpenWindow', ScreenNum, [255 255 255],[0 0 resolution(1) resolution(2)]); 
[w, wRect] = PsychImaging('OpenWindow', ScreenNum);
scr.width = wRect(3);
scr.height = wRect(4);

%% instruction
a = imread('./utils/instruction.jpg');
GratingIndex = Screen('MakeTexture',w, a);  
GRect = Screen('Rect', GratingIndex);   
cGRect = CenterRect([0 0 resolution(2)/GRect(4)*GRect(3) resolution(2)],wRect);    
Screen('DrawTexture',w, GratingIndex, GRect, cGRect);  
Screen('Flip',w);  %
getkeyresp('space'); % Wait for space to start the experiment

% calculate all possible positions
positionscale = get_position(nPosi, posiRadius, [shapeSize shapeSize], [scr.width/2 scr.height/2]); % get the possible positions of stimuli
% load RGB values of standard color space
colorscale = load('colorscale','colorscale');
colorscale = colorscale.colorscale;
%% Start
% create stimulus list
assert(length(nStim)==length(trialsPerStim), 'Please input correct Stimulus and Trial number');
results.stimNum = [];
for i=1:numel(nStim)
    results.stimNum = [results.stimNum nStim(i)*ones(1,trialsPerStim(i))];
end
results.stimNum = Shuffle(results.stimNum);
results.colorWheelStart = nan(1, nTrials); % the start number of the colorwheel?1~180
results.probeInd = nan(1,nTrials); % probe color index, 1~180
results.respInd = nan(1, nTrials); % response color index, 1~180
results.respIndArc = nan(1, nTrials); % response degree on the colorwheel, 1~360
results.stimuliInd = nan(nTrials, 8); % all stimulus color index
results.RT = nan(1, nTrials); % reaction time
results.probePosiInd = nan(1, nTrials); % probe position index, 1-8
results.colorList = cell(1,nTrials); % colorlist for all stimull
results.posiInd = nan(nTrials, 8); % position index of all targets, 1-8

%%
trial = 1;
exitflag = 0;
while trial <= nTrials  
    
    HideCursor;

    %% Fixation
    Screen('FillRect', w, [bg bg bg]); 
    Screen('FrameOval', w, 0, [scr.width/2-ovalr, scr.height/2-ovalr, scr.width/2+ovalr, scr.height/2+ovalr],2,2);
    Screen('Flip',w);
    a = randsample(300:50:500,1)/1000; % randomly sample a fixation period
    WaitSecs(a);
    
    %% Sample array
    Screen('FillRect',w, [bg bg bg]); 
    Screen('TextSize',w, 35);        
    Screen('FrameOval', w, 0,[scr.width/2-ovalr, scr.height/2-ovalr, scr.width/2+ovalr, scr.height/2+ovalr],2,2)
    Screen('Flip', w);
    
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
    rd_index =(0:nPosi-1) * deg_div + round(deg_div*0.125) + randsample(round(deg_div * 0.75), 1);
    rd_index = floor(rd_index/2)+1;  % color is 180 so we divided by 2  
    
    rng(GetSecs);
    x = randsample(color_index(rd_index), results.stimNum(trial)); % choose n stim
    results.stimuliInd(trial,1:results.stimNum(trial)) = x; % save the color index of all targes
    
    % get the position
    posi = randperm(nPosi);  % random positions, correponding to positionscale     
    posi = posi(1:results.stimNum(trial));  
    results.posiInd(trial,1:results.stimNum(trial)) = posi;
    
    % create the color_list for this trial
    color_list = zeros(nPosi,3);
    color_list(posi,:) = colorscale(x,:);
    results.colorList{trial} = color_list;
   
    % draw stimuli
    Screen('FrameOval', w, 0,[scr.width/2-ovalr, scr.height/2-ovalr, scr.width/2+ovalr, scr.height/2+ovalr],2,2)
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
    colorwheel = draw_colorscale(w, cpoint, radin, radout, colorscale); % note that wr randomly choose a start in draw_colorscale function
    results.colorWheelStart(trial) = colorwheel(1); % % save the start point of colorwheel information
    
    % Fixation point
    Screen('FrameOval', w, 0,[scr.width/2-ovalr, scr.height/2-ovalr, scr.width/2+ovalr, scr.height/2+ovalr],2,2);
    
    % draw stimuli (debug purpose)
%     for ind = 1:length(posi)
%         Screen('FillRect', w, color_list(posi(ind),:), positionscale(posi(ind),:)); % change these part, otherwise the nearby color tend to be the same color
%     end
    
    % Draw black frames
    results.probePosiInd(trial)=draw_frames(w, positionscale, color_list); % 1-8; output bold is the row index in color_list, which is the bolded color.
    results.probeInd(trial) = x(posi == results.probePosiInd(trial)); % 1-180, color index of the probe
    Screen('Flip',w);
    
    
    % for debug purpose
%     fprintf('nTrials is %d \n', nTrials);
%     fprintf('wheel start is %d \n', results.colorWheelStart(trial));
%     fprintf('probe location is %d \n', results.probePosiInd(trial));
%     fprintf('probe color is %d \n', results.probeInd(trial));
       
    %% response
    ShowCursor(0, w); % Not sure why we need to call this twice...
    ShowCursor(0, w);
    
    noresp = 1; % first assume no response in this trial
    
    time1 = GetSecs;   %
    rs_keys = '';
    while GetSecs-time1 < respLimit       
        [x,y, buttons] = GetMouse(w);
        if sum(buttons) > 0
            X = x; Y = y;
            %d = sqrt((X-scr.width/2).^2+(Y-scr.height/2).^2); 
            d = sqrt((X-scr.width/2).^2+(Y-scr.height/2).^2); 
            if d > radin && d < radout
                noresp = 0;
                break; 
            end  
        end
        
        % Also check key resp
       [keyIsDown, secs, keyCode] = KbCheck(-1);
       if keyIsDown
            rs_key = find(keyCode == 1);
            % if multiple key presses, we might need only one key                
            rs_key=rs_key(1);
            % check keys
            rs_keys=intersect(rs_key, KbName('escape'));
            if ~isempty(rs_keys)
                exitflag = 1;
                break;
            end    
       end       
    end

    if exitflag % exit
        sca;
        return;        
    end
    
    if noresp % no response within 4 seconds
        nTrials = nTrials + 1; % we add a trial if there is no response within 4s
        results.respIndArc(trial)=nan;
        results.respInd(trial) = nan; % respInd, 1~180
        results.error(trial) = nan; % error range, -90~89
        results.stimNum(end+1) = results.stimNum(trial); % we add a trial at the end
    else
        results.RT(trial) = GetSecs - time1;
        % Convert to degree between [1:360]
        dis_y = scr.height/2-Y;
        if X-scr.width/2 >= 0
            Arc = acosd(dis_y/d);
        else
            Arc = 180+acosd(-dis_y/d);
        end
        results.respIndArc(trial) = Arc; % Arc, 1~360, nan if no response
        results.respInd(trial) = colorwheel(floor(Arc/2)+1); % respInd, 1~180
        results.error(trial) = circulardiff(results.respInd(trial),results.probeInd(trial), 180); % error range, -90~89
    end
    
%     % for debug purpose 
%     results.respIndArc(trial)
%     results.respInd(trial)
%     results.error(trial)
    
    
    %% Calculate response 
    Screen('FillRect',w,[bg bg bg]);
    Screen('FrameOval', w, 0,[scr.width/2-ovalr, scr.height/2-ovalr, scr.width/2+ovalr, scr.height/2+ovalr],2,2)
    Screen('Flip',w);
    b = randsample(200:50:400,1)/1000; % random delay
    WaitSecs(b);
    
    % debug purpose
    % fprintf('resp color is %d \n\n', results.respInd(trial));
    
%     if rem(trial,60) == 0 % have rest every 60 trials
%         Screen('FillRect',w,[255 255 255]);
%         Screen('DrawTexture',w,GratingIndex,GRect,cGRect);  
%         Screen('DrawText',w,'Rest, press space to continue..',scr.width/2-300,scr.height/2,0); 
%         Screen('Flip',w);  %
%         getkeyresp('space'); % wait for space to start the experiment
%         
%     end
    
    trial = trial + 1;
end
% % Save the data
% filename = strcat(subj,sprintf('_set%d_',nStim),datestr(now,'yymmddHHMM'),'.mat');
% if exist(filename,'file')
%     error('data file name exists')
% end
% save(filename);
% Screen('CloseAll');
% 
% %% calculate some diagnostic features, and save it
% close all;
% cpsfigure(1,length(nStim));
% x = {};
% for i=1:length(nStim)
%     x = [x results.error(results.stimNum==nStim(i))];
%     ax = subplot(1,length(nStim), i);
%     histogram(x{i});
%     set(ax, 'Box', 'off');
%     xlim([-90 90]);
%     title(sprintf('Set size = %d', nStim(i)));
%     xlabel('Response error');
%     ylabel('# of Trials')
% end
% saveas(gcf, filename(1:end-4), 'png'); % save the figure
% 
% %%
rmpath(genpath('./utils')); % remove the RZutil directory here







