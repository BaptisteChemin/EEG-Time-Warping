function [UnitWav_CstL] = WM_UnitWav(fs,wavelength,unitwave,user_waveform)
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
Cst_frequ           = fs/wavelength;
Cst_ts              = (1/fs:1/fs:wavelength/fs);

% envelopes for Bi-Phasic waves
if strcmp(unitwave,'Sin')
    UnitWav_CstL    = (-cos(2*pi*Cst_frequ*1.5*[0 Cst_ts(1:end-1)]));
    UnitWav_CstL(1:round(length(UnitWav_CstL)/3))=(UnitWav_CstL(1:round(length(UnitWav_CstL)/3))+1)/2;
    UnitWav_CstL(round(2*length(UnitWav_CstL)/3):end)=(UnitWav_CstL(round(2*length(UnitWav_CstL)/3):end)+1)/2-1;    
elseif strcmp(unitwave,'Squ')
    UnitWav_CstL    = zeros(1,length(Cst_ts));
    UnitWav_CstL(1:round(end/2)) = 1; UnitWav_CstL(round(end/2)+1:end) = -1;
elseif strcmp(unitwave,'Usr')
    o_ts            = (1/fs:1/fs:length(user_waveform)/fs);
    fs_ad           = fs*length(Cst_ts)/length(user_waveform);
    t_ts            = (1/fs_ad:1/fs_ad:length(Cst_ts)/fs_ad);
    UnitWav_CstL    = interp1(o_ts,user_waveform,t_ts,'spline');
end
