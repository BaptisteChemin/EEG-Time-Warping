function [out_header,out_data] = LW_time_warping(header,data,varargin)
% LW_time_warping
%
% Inputs
% - header (LW6 header)
% - data (LW6 data)
% - parameter : 
%
% Outputs
% - outheader (LW6 header)
% - outdata (LW6data)
%
% ex: [header,data]=LW_warping(header,data,'event_code_sample',event_code_sample,'event_code_query',event_code_query);



%process data
disp('*** Processing : ');


%% parameters
%default
event_code_sample={'s1'};
event_code_query={'s2'};
%parse varargin
if isempty(varargin);
else
    %event_code_sample
    a=find(strcmpi(varargin,'event_code_sample'));
    if isempty(a);
    else
        event_code_sample=varargin{a+1};
    end;
    %event_code_query
    a=find(strcmpi(varargin,'event_code_query'));
    if isempty(a);
    else
        event_code_query=varargin{a+1};
    end;
end;
%others
epoch_num       = size(data,1);
data_length     = size(data,6);
Fs              = header.xstep;
t               = header.xstart+(Fs:Fs:Fs*data_length);

%% get latencies info
% get the event latencies for every code separately
events_sample = cell(epoch_num,1);
for k=1:length(header.events)
    if strcmp(header.events(k).code,event_code_sample)
        events_sample{header.events(k).epoch} = [events_sample{header.events(k).epoch},header.events(k).latency];
    end
end

events_query = cell(epoch_num,1);
for k=1:length(header.events)
    if strcmp(header.events(k).code,event_code_query)
        events_query{header.events(k).epoch} = [events_query{header.events(k).epoch},header.events(k).latency];
    end
end

for epoch_n=1:epoch_num
    if ~isequal(size(events_sample{epoch_n,1}),size(events_query{epoch_n,1}))
        display(epoch_n);
        error('The number of sample points has to be equal to the number of query points.');
    end
end

%% time wrapping
events_wrap=header.events(1);
events_wrap.code='wrapped';
out_data=zeros(size(data));
for epoch_n=1:epoch_num
    x=[t(1),events_query{epoch_n}(1:end),t(end)];
    y=[t(1),events_sample{epoch_n}(1:end),t(end)];
    events_wrap.epoch=epoch_n;
    
    for event_n=1:length(events_sample{epoch_n})
        events_wrap.latency=events_query{epoch_n}(event_n);
        header.events(end+1)=events_wrap;
    end
    
    t1=interp1(x,y,t);
    out_data(epoch_n,:,:,:,:,:)=interp1(t,squeeze(data(epoch_n,:,:,:,:,:))',t1)';
end

out_header=header;
%add history
out_header.history(end+1).description='LW_time_waring';
out_header.history(end).date=date;
out_header.history(end).index=[varargin];
