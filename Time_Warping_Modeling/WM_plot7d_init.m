%function [ output_args ] = updateplot3(p,v,x,o)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
%
%  usage:
%       load amp_recovery_mean
%       load param
%      updateplot3

p=1; v=1; o=1; l=1; %size(param.wavelength_range,2)-20;


%% first graph
xax     = (1:size(amp_recovery_mean,7))';
xMat    = repmat(xax, 1, size(param.jitter_range(1,:),2));
yax     = param.jitter_range(1,:);
yMat    = repmat(yax, numel(xax), 1);
zMats = [];
fig = figure('unit','norm','pos',[.01 .05 .98 .85]); 
subplot(1,2,1); hold on;
xlabel('frequencies of interest (f0, f1, ...)'); ylabel('jitter coef var (%)'); zlabel('amplitude');
axesHandles = findall(fig,'type','axes');
pos_raw=get(axesHandles,'position');
pos_raw(2)=0.3; pos_raw(4)=0.65;
set(axesHandles,'position',pos_raw)
grid;
view(-65,10);
title('Spectra of Jittered, Warped and Isochronous synthetic signals')


Hs=zeros(size(param.jitter_range,2),size(param.warping,1));
Hns=zeros(size(param.jitter_range,2),size(param.warping,1));
sumfsignif=NaN(3,length(param.jitter_range));

for w = [3 2 1]
    zMats = NaN(size(yMat));
    zMatns = NaN(size(yMat));

    for x=1:length(param.jitter_range)
        f=squeeze(amp_recovery_mean(p,l,v,x,o,w,:));
        fse=WM_self(f,mode);
        fre=(1:100)'; fre(fse)=[];
        signif=f;
        signif(fre)=NaN; 
        sumfsignif(w,x)=nansum(signif);
        nonsignif=f; 
        nonsignif(fse(1:end-1))=NaN;
        zMats(:,x)=signif';
        zMatns(:,x)=nonsignif';
    end
    switch w
        case 3, rgb = [0 .7 0];
        case 2, rgb = [.9 0 0];
        case 1, rgb = [0 0 1];
    end
    Hs(:,w) = plot3(xMat,yMat,zMats, 'color',rgb, 'Marker','.','LineStyle',':');
    Hns(:,w) = plot3(xMat,yMat,zMatns, 'color',[.8 .8 .8], 'LineStyle',':');
end
set(gca, 'YDir', 'reverse');
xlim([0 50]) 
ylim([0 .3])
zlim([0 .6])

%% second graph
subplot(1,2,2); hold on
xlabel('jitter coef var (%)'); ylabel('recovery ratio');
axesHandles = findall(fig,'type','axes');
pos_pro=get(axesHandles(1),'position');
pos_pro(2)=0.3; pos_pro(4)=0.65;
set(axesHandles(1),'position',pos_pro)
grid;
title('recovered amplitude of warped regarding isochronous signal')

amp_ratio_jittered = sumfsignif(2,:)./sumfsignif(1,:);
amp_ratio_warped = sumfsignif(3,:)./sumfsignif(1,:);

Hrj = plot(param.jitter_range,amp_ratio_jittered, 'color',[.9 0 0]);
Hrw = plot(param.jitter_range,amp_ratio_warped, 'color',[0 .7 0]);
threshold=param.jitter_range;threshold(1,:)=0.95; plot(param.jitter_range,threshold,'LineStyle','--', 'color',[.8 .8 .8])
rangeoff = find(amp_ratio_warped<.95,1); rangeoff=param.jitter_range(rangeoff);
Hrt = line([rangeoff rangeoff],[0 1],'LineStyle','--','color',[.8 .8 .8]);
ylim([0 1])
% handletest=get(gca);
% set(gca, 'XtickLabel', param.jitter_range(1:length(param.jitter_range)/8:end));

hold off




