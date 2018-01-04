% amp_recovery(n,p,m,l,v,x,o,w,f); % dims to keep = 2 4 5 6 7 8 9 
% amp_recovery_mean(p,l,v,x,o,w,f); 
amp_recovery_mean = nanmean(amp_recovery,1);
dimensions_to_keep=[0 1 0 1 1 1 1 1 1];
amp_recovery_mean = permute(amp_recovery_mean,[find(dimensions_to_keep),find(~dimensions_to_keep)]);
clear dimensions_to_keep