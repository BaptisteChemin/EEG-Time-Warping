function [IEI_s] = WM_JitSequ(fs,numberofevents,period,jitstd)
% Author : 
% Baptiste Chemin
% Institute of Neurosciences (IONS)
% Universite catholique de louvain (UCL)
% Belgium
% 
% Contact : baptiste.chemin@uclouvain.be
% This subfunction for modeling synthetic signals generates a series of
% random Inter-Event-Intervals, and adjust the standard distribution to match specified parameters.

%% Param

%% generate the jitters
if jitstd == 0
    IEI_s = NaN(1,numberofevents); IEI_s(:) = period/fs;
else
    distribution_check = 1;
    while distribution_check == 1
        jitter_raw          = randn(numberofevents,1);
        jitter_mz           = jitter_raw-mean(jitter_raw);
        jitter_n            = jitter_mz/max(abs(jitter_mz));                % normalized jitter
        
        std_check = 1;
        jitter_pc           = jitter_n;
        while std_check == 1
            var = std(jitter_pc);
            %         clc
            %         warning('adjusting distribution')
            if var >= jitstd-0.0005 && var <= jitstd+0.0005
                std_check = 0;
                % clc; disp(var)
            elseif var<jitstd
                jitter_pc           = jitter_pc*1.001;
                %             disp(var)
            elseif var>jitstd
                jitter_pc           = jitter_pc*0.999;
                %             disp(var)
            end
        end
        IEI_s   = ((jitter_pc+1)*period/fs)';
        % security check: no value outside allowed range
        IEI_s(IEI_s<mean(IEI_s)-3*std(IEI_s))   = mean(IEI_s)-3*std(IEI_s);
        IEI_s(IEI_s>mean(IEI_s)+3*std(IEI_s))   = mean(IEI_s)+3*std(IEI_s);
        IEI_s(IEI_s<0)                          = 0.001; % because there is no negative time
        
        distribution_check              = jbtest(IEI_s);                    % to make sure we didn't mess the normal distribution
        if distribution_check == 1
            close all;
        end
    end
end
