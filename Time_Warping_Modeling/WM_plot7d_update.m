sumfsignif=NaN(3,length(param.jitter_range));
for w = [3 2 1]
    zMats = NaN(size(yMat));
    zMatns = NaN(size(yMat));
    for x=1:length(param.jitter_range)
        f=squeeze(amp_recovery_mean(p,l,v,x,o,w,:));
        fse=WM_self(f,mode);
        % fsel(l-4,w,1:length(fse))=fse;
        % for the figure
        fre=(1:100)'; fre(fse)=[];
        signif=f; 
        signif(fre)=NaN;
        sumfsignif(w,x)=nansum(signif);
        nonsignif=f; 
        nonsignif(fse(1:end-1))=NaN;
        zMats(:,x)=signif';
        zMatns(:,x)=nonsignif';
        set(Hs(x,w),'zdata',zMats(:,x))
        set(Hns(x,w),'zdata',zMatns(:,x))
    end
end
amp_ratio_jittered = sumfsignif(2,:)./sumfsignif(1,:);
amp_ratio_warped = sumfsignif(3,:)./sumfsignif(1,:);
rangeoff = find(amp_ratio_warped<.95,1); rangeoff=param.jitter_range(rangeoff);

set(Hrj,'ydata',amp_ratio_jittered)
set(Hrw,'ydata',amp_ratio_warped)
set(Hrt,'xdata',[rangeoff rangeoff]);



