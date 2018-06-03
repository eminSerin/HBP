try

    subID = input('Participant number: ','s'); % ask participant id. 
    hbtsession = 1;
    lang = 'eng'; % 'eng' or 'deu'
    
    %% Setup Triggers
    
    HBTtrig.S20 = 20;
    HBTtrig.S25 = 25;
    HBTtrig.S30 = 30;
    HBTtrig.S35 = 35;
    HBTtrig.S40 = 40;
    HBTtrig.S45 = 45;
    HBTtrig.S50 = 50;
    HBTtrig.S55 = 55;
    HBTtrig.onset = 01;
    HBTtrig.offset = 02;
    HBTtrig.duration = 0.005;
    
    OpenTriggerPort;
    StartSaveBDF;
    %% Import sound and image files
    [startWav] = audioread('start.wav');
    [stopWav, FS] = audioread('stop.wav');
    heart = imread('heartbeat.png');
    
    % Output directory
    outDir = [pwd filesep 'Data' filesep];
    if ~exist(outDir)
        mkdir(outDir)
    end
    %% Screen Parameters
    
    % Get number of screens used, and use the display with the greatest display
    % number. For instance if you use external display with laptop, experiment
    % take place on external display.
    screen = max(Screen('Screens'));
    
    % Skip Sync Test. Decrease timing accuracy. Please Change when you figure
    % out problem!! If you have problem with screen synchronization test please
    % uncomment the one line of code below this comment removing % before the
    % code. This code skip the sync. test, but it may create timing
    % inconsistencies in miliseconds.
    Screen('Preference', 'SkipSyncTests', 0);
    
     % Color codes used for the task.
    color.bg = [0 0 0]; % black background
    color.text = [255 255 255]; % white
    
    % Open drawing window in your display with maximum number. That means
    % if you have external monitor, it will open drawing window on it. To
    % run experiment on your main display write 0 (zero) instead of
    % maxScreen.
    mainwin = Screen('OpenWindow',screen, color.bg);
    Priority(MaxPriority(mainwin)); % set the window high priority
    res = Screen('Resolution',mainwin); 
    
    hT = Screen('MakeTexture',mainwin,heart); % Load image to vRam
    %% Instructions
    
    % German
    deu.one = ['Im Folgenden werden wir eine Ruhemessung durchführen.\n'...,
        'Bitte schauen Sie auf das Fixationskreuz und bleiben Sie ruhig sitzen.'];
    deu.two = ['Im Folgenden konzentrieren Sie sich bitte auf die Brust-Region und zählen leise im Kopf jeden Herzschlag, den Sie fühlen. \n'...,
        'Sobald Sie "Start" hören fangen Sie an zu zählen, bis Sie "Stop" hören. Anschliessend tragen Sie die Zahl über die Tastatur ein. \n'...,
        'Bitte verwenden Sie keine Hilfsmittel, wie das manuelle Erfassen des Pulses.'];
    deu.end = ['Ende.'];
    deu.fixation = ['+'];
    deu.start = ['Start...'];
    
    % English
    eng.one = ['In the following, there is a baseline measurement. \n',...
        'Please fixate at the cross on the screen and stay calm.',...
        'Please press any key to procede....'];
    eng.two = ['Please focus on your breast area and quietly count ',...
        'your heartbeat that you feel. \n',...
        'As soon as you hear "Zählen" start counting your pulse until you ',...
        'hear "Stop". Then enter your heartbeat using keyboard.\n',...
        'Please do not use any aids, such as the manual capture of the pulse.\n',...
        'Please press any key to procede...'];
    eng.end = ['Task finished. \n Please inform the researcher!'];
    eng.fixation = ['+'];
    eng.start = ['Start...'];
    
    % Set language.
    switch lang
        case 'eng'
            HBTmsg = eng;
        case 'deu'
            HBTmsg = deu;
    end
    
    %% Trial design
    sFirst = {25,30,35,40,45,50};
    sSecond = {20,30,35,40,45,55};
    
    if hbtsession == 1
        hbtDur = Shuffle(sFirst);
    else
        hbtDur = sSecond;
    end
    
    for i = 1: length(hbtDur)
        hbtInfo(i).duration = hbtDur{i};
        hbtInfo(i).response = [];
    end
    
    %% Task
    DrawFormattedText(mainwin,HBTmsg.one,'center','center', color.text,60,[],[],1.5);
    Screen('Flip',mainwin);
    KbWait;
    WaitSecs(.5);
    
    % Baseline recording
    SendTrigger(HBTtrig.onset,HBTtrig.duration);
    DrawFormattedText(mainwin,HBTmsg.fixation,'center','center', color.text,60,[],[],1.5);
    Screen('Flip',mainwin);
    WaitSecs(120); % Wait 120 secs for baseline recording. 
    SendTrigger(HBTtrig.offset,HBTtrig.duration);
    
    DrawFormattedText(mainwin,HBTmsg.two,'center','center', color.text,60,[],[],1.5);
    Screen('Flip',mainwin);
    WaitSecs(2);
    KbWait();
    
    DrawFormattedText(mainwin,HBTmsg.start,'center','center', color.text)
    Screen('Flip',mainwin);
    WaitSecs(1);
    
    for i = 1: length(hbtInfo)
        DrawFormattedText(mainwin,HBTmsg.fixation,'center','center', color.text,60,[],[],1.5);
        Screen('Flip',mainwin);
        WaitSecs(1);
        disp(['Trial: ',int2str(i)]);
        cT = HBTtrig.(['S', int2str(hbtInfo(i).duration)]); % Trigger
        disp(num2str(cT));
        sound(startWav,FS); % Play start sound
        WaitSecs(length(startWav)/FS);
        SendTrigger(cT,HBTtrig.duration);  % Send Trigger
        Screen('DrawTexture', mainwin,hT); % Draw heart image
        Screen('Flip',mainwin); % flip
        WaitSecs(hbtInfo(i).duration); % Wait
        SendTrigger(HBTtrig.offset,HBTtrig.duration); % send trigger.
        sound(stopWav,FS); % play stop sound
        [string,~] = GetString(mainwin,[],res.width/2,res.height/2,[255,255,255]);
        hbtInfo(i).response = string;
        save([outDir 'HBTdata_',subID,'_',date,'_s',int2str(hbtsession),'.mat'],'hbtInfo');
    end
    
    DrawFormattedText(mainwin,HBTmsg.end,'center','center', color.text,60);
    Screen('Flip',mainwin);
    KbWait();
    CloseTriggerPort; % Close Trigger port.
    
    
catch error;
    sca;
    rethrow(error);
    CloseTriggerPort; % Close Trigger port.
end
sca;
