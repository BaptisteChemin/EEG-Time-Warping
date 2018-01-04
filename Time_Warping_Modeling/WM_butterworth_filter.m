function [out_data]=WM_butterworth_filter(fs,data);
%WM_butterworth_filter
%
%
%'filter_type' : 'bandpass','lowpass','highpass','notch'
%'low_cutoff' : 0.5
%'high_cutoff' : 30
%'filter_order' : 4
%
% Author : 
% Andre Mouraux
% Institute of Neurosciences (IONS)
% Universite catholique de louvain (UCL)
% Belgium
% 
% Contact : andre.mouraux@uclouvain.be
% This function is part of Letswave 6
% See http://nocions.webnode.com/letswave for additional information
%

filter_type='bandpass';
low_cutoff=0.1;
high_cutoff=60;
filter_order=4;


%init out_data
out_data=zeros(size(data));

%sampling rate and half sampling rate
fnyquist=fs/2;

%filter order : filtOrder
filtOrder=filter_order;

%b,a
switch filter_type
    case 'lowpass'
        [b,a]=butter(filtOrder,high_cutoff/fnyquist,'low');
    case 'highpass'
        [b,a]=butter(filtOrder,low_cutoff/fnyquist,'high');
    case 'bandpass'
        if mod(filter_order,2);
            filtOrder=filtOrder-1;
            filter_order=filtOrder;
        end
        filtOrder=filtOrder/2;
        [bLow,aLow]=butter(filtOrder,high_cutoff/fnyquist,'low');
        [bHigh,aHigh]=butter(filtOrder,low_cutoff/fnyquist,'high');
        b=[bLow;bHigh];
        a=[aLow;aHigh];
    case 'notch'
        [b,a]=butter(filtOrder,[low_cutoff/fnyquist high_cutoff/fnyquist],'stop');
end;

%loop through all the data

switch filter_type
    case 'lowpass'
        out_data=filtfilt(b,a,data);
    case 'highpass'
        out_data=filtfilt(b,a,data);
    case 'bandpass'
        out_data=filtfilt(b(1,:),a(1,:),data);
        out_data=filtfilt(b(2,:),a(2,:),out_data);
    case 'notch'
        out_data=filtfilt(b,a,data);
end;



