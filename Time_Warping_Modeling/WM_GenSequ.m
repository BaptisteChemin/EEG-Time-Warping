function [Signal_Isochronous, Signal_Jittered, Signal_Warped] = WM_GenSequ (fs,meanperiod,IEI,mode,wavelengthpc,unitwave,user_waveform)
% Author : 
% Baptiste Chemin
% Institute of Neurosciences (IONS)
% Universite catholique de louvain (UCL)
% Belgium
% 
% Contact : baptiste.chemin@uclouvain.be
% This subfunction for modeling synthetic signals generates three signals
% (called "envelopes"). One is an isochronous repetition of the unitary
% waveform, another is a nonisochronous repetition of the unitary waveform
% and another is the warped signal, from the nonisochronous signal to an
% isochronous signal.


%% Param
numberofevents                  = length(IEI);
time                            = (1/fs:1/fs:(((numberofevents+5)*meanperiod/fs)+1));

% events index
IndexSamples_Isochronous        = (1:meanperiod:(numberofevents+1)*meanperiod);
IndexTime_Isochronous           = IndexSamples_Isochronous/fs;  
IndexTime_Jittered              = [1/fs cumsum(IEI)+1/fs];
IndexSamples_Jittered           = round(IndexTime_Jittered*fs);

usr_mode = 1;
if strcmp(unitwave, 'Usr')
    usr_mode = 2;                                                           % user_waveform cannot be used in such plastic way as the model waveforms!
    usr_waveform = user_waveform{2};
    usr_baseline = user_waveform{1};
end

%% generate the sequences (3 temporal organisation levels: jittered, warped and isochronous)
if usr_mode == 1  % Automatic Synthetic Waveform
    wavelength                      = meanperiod*wavelengthpc/100;          % so the unitary waveform has a lenght of l% of the p period (ms)
%     % "security check"
%     if strcmp(mode, 'CstL')                                               % this correction does not apply when the unit wavelength adapts to instant period
%         IEI(IEI<wavelength/fs)          = wavelength/fs;
%     end
    % pre allocation of signals vectors
    Signal_Isochronous            = zeros(size(time));
    Signal_Jittered               = zeros(size(time));
    if strcmp(mode, 'CstL')
        % generate the CstL unit waveform
        UnitWav_CstL                = WM_UnitWav(fs,wavelength,unitwave,user_waveform);
        for evt=1:numberofevents
            %%% ISOCHRONOUS %%%
            Signal_Isochronous(1,round(IndexSamples_Isochronous(1,evt)):(round(IndexSamples_Isochronous(1,evt))+length(UnitWav_CstL)-1))=Signal_Isochronous(1,round(IndexSamples_Isochronous(1,evt)):(round(IndexSamples_Isochronous(1,evt))+length(UnitWav_CstL)-1))+UnitWav_CstL;  % sum of building signals and event waveform, so it allows superimposition in extreame cases.
            %%% JITTERED %%%
            Signal_Jittered(1,round(IndexSamples_Jittered(1,evt)):(round(IndexSamples_Jittered(1,evt))+length(UnitWav_CstL)-1))=Signal_Jittered(1,round(IndexSamples_Jittered(1,evt)):(round(IndexSamples_Jittered(1,evt))+length(UnitWav_CstL)-1))+UnitWav_CstL;
        end
    elseif strcmp(mode, 'AdaptL')
        % generate the AdaptL unit waveform
        wavelength                	= meanperiod*wavelengthpc/100;
        IsochWav                	= WM_UnitWav(fs,wavelength,unitwave,user_waveform);
        for evt=1:numberofevents
            %%% ISOCHRONOUS %%%
            Signal_Isochronous(1,round(IndexSamples_Isochronous(1,evt)):(round(IndexSamples_Isochronous(1,evt))+length(IsochWav)-1))=Signal_Isochronous(1,round(IndexSamples_Isochronous(1,evt)):(round(IndexSamples_Isochronous(1,evt))+length(IsochWav)-1))+IsochWav;
            %%% JITTERED %%%
            InstantWL                   = IEI(evt)*fs*wavelengthpc/100;
            InstantWav                	= WM_UnitWav(fs,InstantWL,unitwave,user_waveform);
            Signal_Jittered(1,round(IndexSamples_Jittered(1,evt)):(round(IndexSamples_Jittered(1,evt))+length(InstantWav)-1))=Signal_Jittered(1,round(IndexSamples_Jittered(1,evt)):(round(IndexSamples_Jittered(1,evt))+length(InstantWav)-1))+InstantWav;
        end
    end
elseif usr_mode == 2 % User Waveform
    % pre allocation of signals vectors
    Signal_Isochronous            = NaN(size(time));
    Signal_Jittered               = NaN(size(time));
    rd=randi(length(usr_baseline)/2,1);
    for evt=1:numberofevents
        %%% ISOCHRONOUS %%%
        InstantWL                   = meanperiod;
        if length(usr_waveform)<InstantWL
            add_length = InstantWL-length(usr_waveform)-1;
            if rd+add_length>length(usr_baseline); rd = rd+add_length-length(usr_baseline); end
            add = (usr_baseline(rd:rd+add_length)-usr_baseline(rd)+usr_waveform(end));
            UnitWav_CstL            = [usr_waveform add];
            clear add
            rd=rd+add_length;
        else
            UnitWav_CstL = user_waveform;
            InstantWL    = length(usr_waveform);
        end
        sig_already = Signal_Isochronous(1,floor(IndexSamples_Isochronous(1,evt)):floor(IndexSamples_Isochronous(1,evt))+length(UnitWav_CstL)-1);
        sig_to_add  = UnitWav_CstL;
        
        overlap = ~isnan(Signal_Isochronous(1,floor(IndexSamples_Isochronous(1,evt)):floor(IndexSamples_Isochronous(1,evt))+length(UnitWav_CstL)-1));
        if evt==1
            sig_level_correction = ones(1,InstantWL).*0;
        else
            first_free = find(isnan(sig_already),1);
            if first_free == 1
                level_correction = Signal_Isochronous(floor(IndexSamples_Isochronous(1,evt))-2);
            else
                level_correction = sig_already(first_free-1);
            end
            sig_level_correction = ones(1,InstantWL).*level_correction;
            sig_level_correction(overlap) = NaN;
        end
        
        tmp = cat(1,sig_already,sig_to_add,sig_level_correction);
        Signal_Isochronous(1,floor(IndexSamples_Isochronous(1,evt)):floor(IndexSamples_Isochronous(1,evt))+length(UnitWav_CstL)-1) = nansum(tmp,1);
        clear tmp;
        %%% JITTERED %%%
        if strcmp(mode,'CstL')
            InstantWavRaw = usr_waveform;
        elseif strcmp(mode,'AdaptL')
            InstantWavRaw = resample(usr_waveform,round(IEI(evt)*fs),meanperiod);
        end
        InstantWL                   = round(IEI(evt)*fs);
        if length(InstantWavRaw)<InstantWL
            add_length = InstantWL-length(InstantWavRaw)-1;
            if rd+add_length>length(usr_baseline); rd = rd+add_length-length(usr_baseline); end
            add = (usr_baseline(rd:rd+add_length)-usr_baseline(rd)+usr_waveform(end));
            InstantWav               = [InstantWavRaw add];
            clear add
            rd=rd+add_length;
        else
            InstantWav               = InstantWavRaw;
            InstantWL                = length(InstantWavRaw); % there will be some overlap with next event
        end
        
        sig_already = Signal_Jittered(1,floor(IndexSamples_Jittered(1,evt)):floor(IndexSamples_Jittered(1,evt))+length(InstantWav)-1);
        sig_to_add = InstantWav;
        
        overlap = ~isnan(Signal_Jittered(1,floor(IndexSamples_Jittered(1,evt)):floor(IndexSamples_Jittered(1,evt))+length(InstantWav)-1));
        if evt==1
            sig_level_correction = ones(1,InstantWL).*0;
        else
            first_free = find(isnan(sig_already),1);
            if first_free == 1
                level_correction = Signal_Jittered(floor(IndexSamples_Jittered(1,evt))-2);
            else
                level_correction = sig_already(first_free-1);
            end
            sig_level_correction = ones(1,InstantWL).*level_correction;
            sig_level_correction(overlap) = NaN;
        end
        
        tmp = cat(1,sig_already,sig_to_add,sig_level_correction);
        Signal_Jittered(1,floor(IndexSamples_Jittered(1,evt)):floor(IndexSamples_Jittered(1,evt))+length(InstantWav)-1) = nansum(tmp,1);
        clear tmp;
        
    end
    holes=find(isnan(Signal_Isochronous));
    Signal_Isochronous(holes) = Signal_Isochronous(holes-1);
    holes=find(isnan(Signal_Isochronous));
    if ~isempty(holes); Signal_Isochronous(holes) = Signal_Isochronous(holes(1)-1);end  
    holes=find(isnan(Signal_Jittered));
    Signal_Jittered(holes) = Signal_Jittered(holes-1);
    holes=find(isnan(Signal_Jittered));
    if ~isempty(holes); Signal_Jittered(holes) = Signal_Jittered(holes(1)-1); end
end
%%% WARPED %%%
Signal_Warped            = WM_TimeWarping(fs,IndexTime_Jittered,IndexTime_Isochronous,Signal_Jittered)'; Signal_Warped=Signal_Warped(1:length(Signal_Isochronous)); Signal_Warped(isnan(Signal_Warped))=0;

% butterworth filter
Signal_Isochronous=WM_butterworth_filter(fs,Signal_Isochronous);
Signal_Jittered=WM_butterworth_filter(fs,Signal_Jittered);
Signal_Warped=WM_butterworth_filter(fs,Signal_Warped);

% croping the envelope vectors to keep numberofevents periods
Signal_Isochronous        = Signal_Isochronous(1:round(IndexSamples_Isochronous(numberofevents+1)-1));  % crop sequence to keep numberofevents events
Signal_Jittered           = Signal_Jittered(1:round(IndexSamples_Jittered(numberofevents+1)-1));        % crop sequence to keep numberofevents events
Signal_Warped             = Signal_Warped(1:round(IndexSamples_Isochronous(numberofevents+1)-1));       % crop sequence to keep numberofevents events