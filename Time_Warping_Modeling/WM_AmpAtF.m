function [AmpAtF_Isochronous,AmpAtF_Jittered,AmpAtF_Warped,P1_Isoch,P1_Jit,P1_Warp] = WM_AmpAtF (frequinterest,Envelope_Isochronous, Envelope_Jittered, Envelope_Warped)

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
fs                  = 1000;                                                 % Sampling frequency                    
T                   = 1/fs;                                                 % Sampling period       
L_Isoch             = length(Envelope_Isochronous);                         % Length of Isochronous and Warped signals
L_Jit               = length(Envelope_Jittered);                            % Length of Jittered signal
t_Isoch             = (0:L_Isoch-1)*T;                                      % Time vector of Isochronous and Warped signals
t_Jit               = (0:L_Jit-1)*T;                                        % Time vector of Jittered signal
f_Isoch             = fs*(0:(L_Isoch/2))/L_Isoch;                           % Frequency vector of Isochronous and Warped signals
f_Jit               = fs*(0:(L_Jit/2))/L_Jit;                               % Frequency vector of Jittered signal

frequi_Isoch        = NaN(size(frequinterest));
for foi=1:length(frequinterest)
    frequi_Isoch(foi)   = find(abs(f_Isoch-frequinterest(foi))==min(abs(f_Isoch-frequinterest(foi))),1);
end

frequi_Jit           = NaN(size(frequinterest));
for foi=1:length(frequinterest)
    frequi_Jit(foi)  = find(abs(f_Jit-frequinterest(foi))==min(abs(f_Jit-frequinterest(foi))),1);   % Note that because of jitter and non strictly periodicity of the signal, there is a large spectral leakage. Also, it is impossible to get the "perfect" bin for each frequency of interest. See line 58-61 for proposed solution
end

%% frequency domain analyses of the sequences
% Compute the fft
FFT_Isochronous    = fft(Envelope_Isochronous);
FFT_Jittered       = fft(Envelope_Jittered);
FFT_Warped         = fft(Envelope_Warped);
% Compute the two-sided spectrum P2. Then compute the single-sided spectrum P1 based on P2 and the even-valued signal length L.
P2_Isoch            = abs(FFT_Isochronous/L_Isoch);
P1_Isoch            = P2_Isoch(1:round(L_Isoch/2)+1);
P1_Isoch(2:end-1)   = 2*P1_Isoch(2:end-1);

P2_Jit              = abs(FFT_Jittered/L_Jit);
P1_Jit              = P2_Jit(1:round(L_Jit/2)+1);
P1_Jit(2:end-1)     = 2*P1_Jit(2:end-1);

P2_Warp             = abs(FFT_Warped/L_Isoch);
P1_Warp             = P2_Warp(1:round(L_Isoch/2)+1);
P1_Warp(2:end-1)    = 2*P1_Warp(2:end-1);
% Get the amplitude at frequencies of interest

AmpAtF_Isochronous  = P1_Isoch(frequi_Isoch);
AmpAtF_Warped       = P1_Warp(frequi_Isoch);
AmpAtF_Jittered     = NaN(size(frequi_Jit));
for foi=1:length(frequinterest)
    if frequi_Jit(foi)+1<=length(P1_Jit)
        AmpAtF_Jittered(1,foi)     = max(P1_Jit(frequi_Jit(foi)-1:frequi_Jit(foi)+1)); % get maximal amplitude within a +-1 bin range around the frequency of interest
    elseif frequi_Jit(foi)==length(P1_Jit)
        AmpAtF_Jittered(1,foi)     = max(P1_Jit(frequi_Jit(foi)-1:frequi_Jit(foi))); % get maximal amplitude within a -1:0 bin range around the frequency of interest
    elseif frequi_Jit(foi)<length(P1_Jit)
        AmpAtF_Jittered(1,foi)     = 0;
    end
end