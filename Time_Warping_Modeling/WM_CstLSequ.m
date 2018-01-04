function [Envelope_Isochronous_CstL, Envelope_Jittered_CstL, Envelope_Warped_CstL] = WM_CstLSequ (IEI_s,meanperiod, UnitWav_CstL)
% 
% 
%
%
% Author : 
% Baptiste Chemin
% Institute of Neurosciences (IONS)
% Universite catholique de louvain (UCL)
% Belgium
% 
% Contact : baptiste.chemin@uclouvain.be
% This subfunction is part of WarpModeling project
%

%% Param
fs                  = 1000;
numberofevents      = length(IEI_s);
time                = (1/fs:1/fs:(((numberofevents+5)*meanperiod/fs)+1));

%% generate the sequences (3 temporal organisation levels: jittered, warped and isochronous)
IndexSamples_Isochronous        = (1:meanperiod:(numberofevents+1)*meanperiod);
IndexTime_Isochronous           = IndexSamples_Isochronous/fs;  
IndexTime_Jittered              = [1/fs cumsum(IEI_s)];
IndexSamples_Jittered           = IndexTime_Jittered*fs;

% pre allocation of envelope vectors
Envelope_Isochronous_CstL   = zeros(size(time));
Envelope_Jittered_CstL      = zeros(1,length(time));

for evt=1:numberofevents
    %%% ISOCHRONOUS %%%
    Envelope_Isochronous_CstL(1,round(IndexSamples_Isochronous(1,evt)):(round(IndexSamples_Isochronous(1,evt))+length(UnitWav_CstL)-1))=UnitWav_CstL;     
    %%% JITTERED %%%
    Envelope_Jittered_CstL(1,round(IndexSamples_Jittered(1,evt)):(round(IndexSamples_Jittered(1,evt))+length(UnitWav_CstL)-1))=UnitWav_CstL;     
end

% croping the envelope vectors to keep numberofevents periods
Envelope_Isochronous_CstL   = Envelope_Isochronous_Sin_CstL(1:IndexSamples_Isochronous(numberofevents+1)-1); % crop sequence to keep numberofevents events
Envelope_Jittered_CstL      = Envelope_Jittered_Sin_CstL(1:round(IndexSamples_Jittered(numberofevents+1)-1));       % crop sequence to keep numberofevents events

%%% WARPED %%%
Envelope_Warped_CstL            = WM_TimeWarping(fs,IndexTime_Jittered,IndexTime_Isochronous,Envelope_Jittered_CstL)'; Envelope_Warped_CstL=Envelope_Warped_CstL(1:length(Envelope_Isochronous_CstL)); Envelope_Warped_CstL(isnan(Envelope_Warped_CstL))=0;
