% Author : 
% Baptiste Chemin
% Institute of Neurosciences (IONS)
% Universite catholique de louvain (UCL)
% Belgium
% 
% Contact : baptiste.chemin@uclouvain.be
% CORE function for modeling of synthetic signals

%% set the PARAMETERS
% parameters that are not tested 
param.numberofevents            = 105;                                      % (e) number of unitary waveforms to form the (nearly)-periodic signal
param.ntrials                   = 100;                                      % (n) number of repetition of each set of parameters (the mean of those n trials is used for final results)
param.fs                        = 1000;                                     % frequency sampling of the generated sequences. The max frequency of interest is thus param.fs/2 Hz.
param.nfrequencies              = 200;                                      % (f) F and harmonics 2F, ... that are measured in each spectrum. 200 harmonics is far above the number of frequencies that will be significantly sailient in the spectrum. 

% discrete parameters
param.warping                   = {'Isochronous'; 'Jittered'; 'Warped'};    % (w) 'Jittered' is the model waveform with fluctuations of period; 'Warped' is the model waveform rendered isochronous by TW procedure; 'Isochronous' is the isochronous model waveform, never warped

load('user_waveform.mat');                                                  % load the waveform from the published paper dataset (Cz, average of all the finger taps); Also load the EEG baseline from the resting condition.
button = questdlg('What unitary waveform do you want to use?', ...          % dialog box to choose the unitary waveform
    'Unitary Waveform', ...
    'Finger Tap Cz','Biphasic Sinwave','Load my own waveform','Biphasic Sinwave');
if strcmp(button,'Finger Tap Cz') 
    param.waveform              = {'Usr'};                                   % (v) shape of unitary waveform; default is "Sin" which is a biphasic pseudosinusoidal wave. Note that a hidden "Squ" wave (a biphasic square wave) can be enabled by manually edditing the code.
    param.user_waveform = user_waveform; 
elseif strcmp(button,'Biphasic Sinwave')
    param.waveform              = {'Sin'};
    param.user_waveform         = NaN; 
elseif strcmp(button,'Load my own waveform')
    param.waveform              = {'Usr'};
    param.user_waveform         = user_waveform;
    %%%% load the waveform from the end-user %%%%
    uw                          = uiimport;                                 % load the end-user unitary waveform
    names                       = fieldnames(uw);
    eval(sprintf('%s',['param.user_waveform{2,1}=uw.' char(names) ';']));   % load the unitary waveform in the parameters structure, for further use.
end
clear button; clear user_waveform;

param.wavelength_mode           = {'CstL';'AdaptL'};                        % (m) in 'AdaptL' mode, the length of each unitary waveform is proportional to the instant period; in 'CstL' mode, the length of the unitary waveform is constant, proportional to the mean period
param.order                     = {'Random';'Shuffled'};                    % (o) 'Random' is a first time serie of fluctuating Inter Event Intervals, 'Schuffled' is the same IEI fluctuations, with a different time order.

% continuous parameters
prompt                          = {'Enter mean Inter-Event-Interval (ms):'};
dlg_title                       = 'Parameters for Synthetic Signals';
num_lines                       = 1;
defaultans                      = {'800'};
iei                             = inputdlg(prompt,dlg_title,num_lines,defaultans);
param.period_range              = str2double(cell2mat(iei));                % (p) mean Inter-Event-Interval (ms). NOTE that you can also make a RANGE of IEI to test, for example: param.period_range = (200:300:1100);
clear prompt; clear dlg_title; clear num_lines; clear defaultans; clear iei;

if strcmp(param.waveform,'Sin')                                             % when the unitary waveform is a biphasic sin wave, the user can test a range of unitary waveform length (in % of the mean IEI)
    step    = 5;
    param.wavelength_range      = (5:step:60);                              % (l_CstL) range of length (in % of the mean period) for the unit-waveform when it is constant across the different events
    al                          = find(strcmp(param.wavelength_mode,'AdaptL'),1);
    param.wavelength_range(al,:)= (100-step*(size(param.wavelength_range,2)-1):step:100); % (l_AdaptL) range of length (in % of the instant period) for the unit-waveform when it adapts to the instant period
    clear step; clear al;
elseif strcmp(param.waveform,'Usr')
    param.wavelength_range      = [100;100];                                      % (l) the length of the unitary waveform corresponds to 100%
end

param.jitter_range          = (0:0.005:0.3);                                % (x) range of jitter amplitude (coeficient of variation of the mean Inter-Event-Interval)

%% pre-allocate the OUTPUTS
amp_recovery    = NaN.*ones(param.ntrials,length(param.period_range),size(param.wavelength_mode,1),size(param.wavelength_range,2),length(param.waveform),length(param.jitter_range),size(param.order,1),size(param.warping,1),param.nfrequencies);  
save_spectra    = 0;                                                        % 1 = save the full spectra of example data; 2 = don't save so much useless data (we have the amplitude at frequencies of interest anyway)
mkdir('SYNTH_DATA');
save(fullfile(cd,'SYNTH_DATA','param.mat'),'param');
% n,p,m,l,v,x,o,w,f 
nloops          = param.ntrials*length(param.period_range)*size(param.wavelength_mode,1)*size(param.wavelength_range,2)*length(param.waveform)*length(param.jitter_range)*size(param.order,1);
loop            = 0;

%% loops
for n = 1:param.ntrials
    for p = 1:length(param.period_range)
        frequinterest = (param.fs/param.period_range(p):param.fs/param.period_range(p):param.fs/2);% because the sampling rate of the generated sequences is 1000 Hz         % f0 and harmonics up to 500 Hz
        frequinterest = frequinterest(1:param.nfrequencies);                               % because it is more convenient to keep a constant number of frequencies of interest (to fill up the amp_recovery matrix) , and that it doesn't make much sense to keep super high frequencies anyway...
        for m = 1:size(param.wavelength_mode,1)
            for l = 1:size(param.wavelength_range,2)
                for v=1:length(param.waveform)
                    for x = 1:length(param.jitter_range)
                        IEI = WM_JitSequ(param.fs, param.numberofevents,param.period_range(p),param.jitter_range(x)); % Inter-Event-Intervals (s)
                        IEI(2,:) = IEI(randperm(param.numberofevents));                       % shuffling of IOI
                        for o=1:size(param.order,1)
                            loop = loop+1;
                            clc; disp(loop); disp('/'); disp(nloops);
                            % GENERATE THE SEQUENCES for the 3 warping levels (Isochronous, Jittered, Warped)
                            [Signal_Isochronous, Signal_Jittered, Signal_Warped] = WM_GenSequ (param.fs,param.period_range(p),IEI(o,:),param.wavelength_mode(m),param.wavelength_range(m,l),param.waveform(v),param.user_waveform);           
                            % GET AMPLITUDES AT FREQUENCIES OF INTEREST
                            % n,p,m,l,v,x,o,w,f  
                            [amp_recovery(n,p,m,l,v,x,o,1,:),amp_recovery(n,p,m,l,v,x,o,2,:),amp_recovery(n,p,m,l,v,x,o,3,:),fullspect_1,fullspect_2,fullspect_3] = WM_AmpAtF(frequinterest,Signal_Isochronous, Signal_Jittered, Signal_Warped);
                            if save_spectra == 1 && n==1
                                for ww=1:3
                                    eval(sprintf('%s',['example_spectra.p_' num2str(param.period_range(p)) '.m_' char(param.wavelength_mode(m)) '.l_' num2str(param.wavelength_range(m,l)) '.v_' char(param.waveform(v)) '.x_' num2str(param.jitter_range(x)*1000) '.o_' char(param.order(o)) '.w_' char(param.warping(ww)) '= fullspect_' num2str(ww) ';']));
                                end
                            else
                                clear fullspect_1; clear fullspect_2; clear fullspect_3;
                            end
                        end
                    end
                end    
            end
        end
    end
    %amp_r = squeeze(amp_recovery(n,:,:,:,:,:,:,:,:));
    %eval(sprintf('%s',['save(fullfile(cd,''SYNTH_DATA'',''amp_recovery_n' num2str(n) '.mat''),''amp_r'');']));
    if save_spectra == 1 && n==1
        save(fullfile(cd,'SYNTH_DATA','example_spectra.mat'),'example_spectra');
    end
end

