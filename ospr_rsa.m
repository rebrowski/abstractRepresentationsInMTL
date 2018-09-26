%% some paths
% change this accordingly:
datadir = '~/projects/ospr/osprBrainVsDNN/';

%% load data 
% 1. zscored responses (one zscore for each unit/stimulus combination)
load([datadir 'zvals.mat']);
% the variables loaded here are:
% - zvals, a nunits X nstimuli matrix of zscores
% - cluster_lookup, a table with nunits rows and 8 columns with infos on the units (such as anatomical location, SU vs. MU, etc)
%   rows in this table correspond to rows in zvals variable above     
% - stim_lookup, a cell of size nstimuli, i.e., 100 of names of the
%   presented images (e.g., wild_animals_6)
%   entries correspond to the columns in zvals variable above
% - cat_lookup, a cell of size nstimuli, i.el, 100 of names of the category the images belong to
%   entries correspond to teh columns in zvals variable above
% - regions: this is merely a struct with names of anatomical Regions, i.e., AM, HC,
%   EC, PHC, and the names of electrode localizations (sites) assign to anatomical regions e.g. 
%   regions(1).name = AM for amygdala
%   regions(1).sites = {'RA', 'LA'}; for wires in left and right amygdala


%% Lets plot a dissimilarity matrix for each anatomical region of interest to demonstrate:
nregions = numel(regions);

% setup figure
figh = figure('color', 'w', 'visible', 'on');
figh.PaperUnits = 'inches';
figh.PaperPosition = [0 0 7.4 5];
figh.Position = [200 200 800 600];

% define axes ticklabels for categories
catticks = cat_lookup(1:10:end);
catticks = cellfun(@(x) strrep(x, '_', ' '), catticks, 'UniformOutput', false);

% loop over anatomical regions and do the plots
for r = 1:nregions
    
    % get row-indices in zvals belonging to region(r)
    ridx = strcmp(cluster_lookup.regionname, regions(r).name);
    
    % use pdist to get a dissimilarity matrix
    S=pdist(zvals(ridx,:)', 'correlation');
    toplot = squareform(S);
    
    % define the range of data to be displayed in color values:
    from = mean(toplot(:)) - 2.5*std(toplot(:));
    to = mean(toplot(:)) + 2.5*std(toplot(:));
    
    % from here on its just plotting...
    ax = subplot(2,2,r);
    
    [x1 x2] = size(toplot);
    step = x1/10;
    
    pch = pcolor(1:x1, 1:x2, toplot);
    pch.LineStyle = 'none';
    ticks_ = step/10*6:step:100*step;
    set(ax,'YDir','reverse');
    
    set(ax, 'YTick', []);
    set(ax, 'XTick', []);
    if r == 1 || r == 3
        set(ax, 'YTick', ticks_);
        set(ax, 'YTickLabel', catticks)
        ax.XTickLabelRotation=45;
        
    end
    if r == 3 || r == 4
        set(ax, 'XTick', ticks_);
        set(ax, 'XTickLabel', catticks);
        ax.XTickLabelRotation=45;
    end
    
    if r == 2
        pos_ = get(ax, 'Position');
        cbh = colorbar;
        set(ax, 'Position', pos_);
        cbpos =get(cbh, 'Position');
        cbpos(2) = cbpos(2) + cbpos(4)/3;
        cbpos(4) = cbpos(4) /3;
        set(cbh, 'Position', cbpos);
        ylabel(cbh,'1-R');
    else
        cbh = [];
    end
    
    colormap(ax, 'parula')
    caxis([from to]);
    hold on
    if ~exist('lw', 'var')
        lw = 1;
    end
    
    for ix = 1:9
        plot([ix*step+1 ix*step+1], [0 10*step], 'k', 'LineWidth', lw);
        plot([0 10*step], [ix*step+1 ix*step+1], 'k', 'LineWidth', lw);
    end
    
    title(regions(r).name)
    
end
