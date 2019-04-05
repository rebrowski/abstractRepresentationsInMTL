function [h f ylimits_]=plot_signals(signals, x, plot_color, error_type, x_label, y_label, ...
                                     do_transparency, nperms, ...
                                     do_labels, do_normalize_to_max, ...
                                     maxval_for_normalization)
    
%%    function [h f ylimits_]=plot_signals(signals, x, plot_color,...
%                                           error_type, x_label, y_label, ...
%                                          do_transparency, nperms,
%                                          do_labels, do_normalize_to_max)
% plots the mean and some error of signals stored in 2D array (rows:
% observations/trials/segments, columns: samples, mV...). 
%
% Optional arguments:
% x:          a custom x-axis (e.g. time in seconds), same length as there
%             are columns in signals
%
% plot_color: either a matlab-color string ('r', 'g', ... ) or a
%             vector with r-g-b values between 0 and 1 (e.g. [0.7 0.7 0.7])
% 
% error_type: a string denoting how the error should be displayed
%             one of the following: '95%CI', '99%CI', 'SEM', 'boot
%             95%CI', 'boot '90%CI', 'boot SEM';
%
% x_/y_label: strings to label the axes
%
% do_transparency: boolean whether error should be displayed with
%              alpha
% 
% nperms:     how many bootstraps to do if a bootstr estimate of the error is chosen
%
% do_normalize_to_max: this has been done to satisfy a reviewers
%                      comment - maybe it hardly makes sense in most situations to set
%                      this true in other situations
% maxval_to_noramlize_to: this applies to the above


    
    if ~exist('x', 'var') || isempty(x)
        x = 1:size(signals,2);
    end
    assert(size(signals,2) == length(x));
    
    if ~exist('plot_color', 'var') || isempty(plot_color)
        plot_color = 'b';
    end
    
    if ~exist('error_type', 'var') || isempty(error_type)
        error_type = 'boot SEM';
    end
    if ~exist('do_transparency') || isempty(do_transparency)
        do_transparency = true;
    end
    
    if ~exist('do_labels', 'var') || isempty(do_labels)
        do_labels = true;
    end
    
    if ~exist('x_label', 'var') || isempty(x_label)
        x_label = '';
    end
    
    if ~exist('y_label', 'var') || isempty(y_label)
        y_label = '';
    end
    
    if ~exist('nperms', 'var') || isempty(nperms)
        nperms  = 400;
    end
    
    if ~exist('do_normalize_to_max', 'var') || ...
            isempty(do_normalize_to_max)
        do_normalize_to_max = false;
        
    end
    
    if ~exist('maxval_for_normalization', 'var') || ... 
            isempty(maxval_for_normalization)
        maxval_for_normalization = max(mean(signals));
    end
    
    
    error_types = {'95%CI', '99%CI', 'SEM', 'boot 95%CI', ['boot ' ...
                        '90%CI'], 'boot SEM'};
    if sum(strcmp(error_types, error_type)) < 1
        error(['Please chosse one of the following error ' ...
               'types:', sprintf(['\n %s '], error_types{:})]);
    end
    
    nsigs = size(signals,1);
    
    nansigs = sum(isnan(signals),2) > 0;
    if sum(nansigs) > 0
% $$$         warning('%d signals contain NaN values... will exlcude these', ...
% $$$                 sum(nansigs));
    end
    
    signals = signals(~nansigs,:);
    nsigs = size(signals,1);
    
    if nsigs > 1        
        m = mean(signals);
        sd = std(signals);
        sem = sd./sqrt(nsigs);   
    else
        m = signals;
        sem = repmat(0, 1,size(signals,2));
        sd = repmat(0, 1,size(signals,2));
    end
    
    if strcmp(error_type, '95%CI')
        err = 1.96 .* sem;
    elseif strcmp(error_type, '99%CI')
        err = 2.58 .* sem;
    elseif strcmp(error_type, 'SEM')
        err = sem;
    elseif strcmp(error_type, 'boot 95%CI')
        err = bootci(nperms, {@mean, signals});  
    elseif strcmp(error_type, 'boot 90%CI')
        err = bootci(nperms, {@mean, signals}, 'alpha', 0.1);
    elseif strcmp(error_type, 'boot SEM')
        [bootstat,bootsam] = bootstrp(nperms,@mean,signals);
        if size(signals,1)< 2
            err = repmat(0, 1,size(signals,2));
        else
            err = std(bootstat);
        end
        err = err;
    end
    
    if strcmp(error_type, 'boot 95%CI') | strcmp(error_type, 'boot 90%CI')
        p_sem = err(2,:);
        n_sem = err(1,:);
    else 
        p_sem = m + err;
        n_sem = m - err;
    end

    if do_normalize_to_max
        p_sem = p_sem ./ maxval_for_normalization;
        n_sem = n_sem ./ maxval_for_normalization;
        m = m ./ maxval_for_normalization;
    end
    
    
    ylimits_= [floor(min(n_sem)),ceil(max(p_sem))];
    
    X=[x, fliplr(x)];
    Y=[p_sem,fliplr(n_sem)];
    f=fill(X,Y,plot_color);
    
    if do_transparency
        alpha(0.25);   
    end
    
    set(f,'EdgeColor','none'),
    hold on
    h = plot(x,m, 'Color', plot_color);
% $$$     ylims = ylim;
% $$$     plot([0 0],ylims, ':k');
% $$$     ylim(ylims);
    box off
    
    if do_labels
        ylabel(sprintf('%s M +/- %s', y_label, error_type));
        xlabel(x_label);
    end
