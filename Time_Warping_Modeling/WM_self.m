function [ fsel ] = WM_self(f,mode)
%SELF selections the frequencies that have a significant weight within the
%spectrum
%this function needs signal processing toolbox
%% f0 and harmonics untill amp of harmonics fall under threhold 5 pc of max amp OR 
if mode==1
    thresh = 5*max(f)/100;
    stop = find(f<thresh);
    fsel=(1:stop(1)-1)';
end

%% f0 and harmonics untill first local minimum
if mode==2
    [~,locmin]=findpeaks(-f);
    if isempty(locmin) 
        warning('no local minimum could be found')
        quit
    end
    fsel=(1:locmin(1))';
end

%% f that explains 95% of the spectrum 
if mode==3
    [fsort,id]=sort(f);
    thres=sum(f)*5/100;
    fsel=sort(id(cumsum(fsort)>thres)); %fsel=id(find(cumsum(fsort)>thres));
end
%% f that are minimum 5% of the maximum f amp 
if mode==4
    fsel=find(f>5*max(f)/100);
end

%% f that are the first 15 harmonics
if mode==5
    fsel=(1:10)';
end

%% all f
if mode==6
    fsel=(1:length(f))';
end


end
