% Author : 
% Baptiste Chemin
% Institute of Neurosciences (IONS)
% Universite catholique de louvain (UCL)
% Belgium
% 
% Contact : baptiste.chemin@uclouvain.be
% basic visualisation of synthetic signals made with WM_Core_function



% amp_recovery(n,p,m,l,v,x,o,w,f); % dims to keep = 2 3 4 5 6 7 8 9 
% amp_recovery_mean(p,l,v,x,o,w,f); 
amp_recovery_mean = nanmean(amp_recovery,1);
dimensions_to_keep=[0 1 1 1 1 1 1 1 1];
amp_recovery_mean = permute(amp_recovery_mean,[find(dimensions_to_keep),find(~dimensions_to_keep)]);
clear dimensions_to_keep

save(fullfile(cd,'SYNTH_DATA','amp_recovery_mean.mat'),'amp_recovery_mean');

% amp_recovery_mean(p,m,l,v,x,o,w,f);
amp_recovery_mean_CstL = amp_recovery_mean(1,1,1,1,:,:,:,:);
amp_recovery_mean_AdaptL = amp_recovery_mean(1,2,1,1,:,:,:,:);

dimensions_to_keep=[0 0 0 0 1 1 1 1];
amp_recovery_mean_CstL = permute(amp_recovery_mean_CstL,[find(dimensions_to_keep),find(~dimensions_to_keep)]);
amp_recovery_mean_AdaptL = permute(amp_recovery_mean_AdaptL,[find(dimensions_to_keep),find(~dimensions_to_keep)]);
clear dimensions_to_keep
% amp_recovery_mean_wf (x,o,w,f);
fsel = 1:10; % select F and 9 first harmonics. Also see WM_self for hamnonic selection.
amp_recovery_mean_CstL_fsel = sum(amp_recovery_mean_CstL(:,:,:,fsel),4);
amp_recovery_mean_AdaptL_fsel = sum(amp_recovery_mean_AdaptL(:,:,:,fsel),4);
% amp_recovery_mean_wf_fsel (x,o,w);

amp_ratio_CstL_JITTER = (amp_recovery_mean_CstL_fsel(:,:,2)./amp_recovery_mean_CstL_fsel(:,:,1))';
amp_ratio_CstL_WARPED = (amp_recovery_mean_CstL_fsel(:,:,3)./amp_recovery_mean_CstL_fsel(:,:,1))';

amp_ratio_AdaptL_JITTER = (amp_recovery_mean_AdaptL_fsel(:,:,2)./amp_recovery_mean_AdaptL_fsel(:,:,1))';
amp_ratio_AdaptL_WARPED = (amp_recovery_mean_AdaptL_fsel(:,:,3)./amp_recovery_mean_AdaptL_fsel(:,:,1))';


figure; hold on;
plot(amp_ratio_CstL_JITTER(1,:))
plot(amp_ratio_CstL_WARPED(1,:))

figure; hold on;
plot(amp_ratio_AdaptL_JITTER(1,:))
plot(amp_ratio_AdaptL_WARPED(1,:))