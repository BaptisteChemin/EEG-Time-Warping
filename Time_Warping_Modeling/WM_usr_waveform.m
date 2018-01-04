fs=1000;
wavelength = 150;

Cst_frequ           = fs/wavelength;
Cst_ts              = (1/fs:1/fs:wavelength/fs);


    UnitWav_CstL    = rand(1,length(Cst_ts));
    spect           = fft(UnitWav_CstL);
    P2              = abs(spect/length(UnitWav_CstL));
    P1              = P2(1:length(UnitWav_CstL)/2+1);
    P1(2:end-1)     = 2*P1(2:end-1);
    f               = fs*(0:(length(UnitWav_CstL)/2))/length(UnitWav_CstL);
    mask            = (cos(2*pi*Cst_frequ*10*[0 Cst_ts(1:length(f)-1)]));
    mask            = (mask+1)./2;
    [~,stop]        = findpeaks(-mask);
    mask(1,stop(1):end)=0;
    mask            = [1 mask zeros(1,length(mask)-3)];
    mask(length(mask)/2+1:end) = flip(mask(2:length(mask)/2+1));
    spect_filt      = spect.*mask;
    UnitWav_CstL    = real(ifft(spect_filt));
    UnitWav_CstL    = UnitWav_CstL-UnitWav_CstL(1);
    rampup          = 0:1/5:1;
    rampdown        = 1:-1/5:0;
    UnitWav_CstL(1:length(rampup)) = UnitWav_CstL(1:length(rampup)).*rampup;
    UnitWav_CstL(end-length(rampdown)+1:end) = UnitWav_CstL(end-length(rampdown)+1:end).*rampdown;
    
figure;plot(Cst_ts,UnitWav_CstL)
figure; hold on;  plot(f,abs(spect_filt(1:length(f)))); plot(f,abs(spect(1:length(f))));
plot(f,mask(1:length(f)),'g');
user_waveform = UnitWav_CstL;