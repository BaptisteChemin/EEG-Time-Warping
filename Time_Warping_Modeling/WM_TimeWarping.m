function [out_data] = time_warping(fs,index_samples,index_query,data)
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

data_length     = length(data);
t               = (1/fs:1/fs:1/fs*data_length);

out_data=zeros(size(data));

x=[t(1),index_query(2:end),t(end)];
y=[t(1),index_samples(2:end),t(end)];

t1=interp1(x,y,t);
out_data=interp1(t,data',t1)';
