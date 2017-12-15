% EEG_Time_warping
% Warp the EEG signal to adjust 'sample points' to 'query points'
%
% data is a ep*ch*l 3D variable with 
% ep:   epoch as first dimension (i.e, 7 trials in one experiment condition); 
% ch:   channel as second dimension (i.e, 64 EEG channels);
% l:    epoch length as third dimension (i.e, 60.000 samples of a 60 s trial at Fs=1000 Hz).
%
% events_query and events_sample are ep*1 cells with
% ep double array of k values = query or sample points (in second) for the epoch ep
%
% Refer to data_example.mat, events_query_example.mat and
% events_sample_example.mat if needed.
%
%
% Author : 
% Baptiste Chemin, Dounia Meulders, Gan Huang & Andre Mouraux
% Institute of Neurosciences (IONS)
% Universite catholique de louvain (UCL)
% Belgium
% 
% Contact : baptiste.chemin@uclouvain.be

%% load data
disp('*** Loading : ');

uiwait(msgbox({'Please load your data...' '-> data.mat' '-> events_query.mat' '-> events_sample.mat'},'modal'));
filename = uigetfile('*.mat',  'All Files (*.mat)','MultiSelect','on');
if size(filename,2)==3
    for f=1:length(filename)
        load(char(filename(f)));
    end
elseif size(filename,1)==1
    f=1;
    while f<4
        load(char(filename));
        f=f+1;
        filename = uigetfile('*.mat',  'All Files (*.mat)','MultiSelect','on');
    end
end
% additional parameters
epoch_num       = size(data,1);
data_length     = size(data,3);
Fs = str2double(cell2mat(inputdlg({'Enter frequency sampling (Hz):'},'DATA INFO',1,{'1000'})));
t               = (1/Fs:1/Fs:1/Fs*data_length);
% check if the variables are loaded and correctly names
if ~exist('data','var') || ~exist('events_query','var') || ~exist('events_sample','var')
    error('Error: missing or incorreclty named data...');
end
% check if there are the same number of sample points and query points
for epoch_n=1:epoch_num
    if ~isequal(size(events_sample{epoch_n,1}),size(events_query{epoch_n,1}))
        display(epoch_n);
        error('Error: The number of sample points has to be equal to the number of query points.');
    end
end
clear f; clear filename; clear epoch_n;

%% time wrapping
disp('*** Processing : ');

warped_data=zeros(size(data));
for epoch_n=1:epoch_num
    x=[t(1),events_query{epoch_n}(1:end),t(end)];
    y=[t(1),events_sample{epoch_n}(1:end),t(end)];
    t1=interp1(x,y,t);
    warped_data(epoch_n,:,:)=interp1(t,squeeze(data(epoch_n,:,:))',t1)';
end

%% save data
disp('*** Saving : ');

uisave('warped_data')