clear

%% Figure 1
% load some preliminaries
load category_responses
load ospr_colors

%% info on units to plot
ex(1).fn = '033e06timesCSC10.mat';
ex(1).fnsp = '033e06segmentedSpikes.mat';
ex(1).clusid = 1;
ex(1).site = 'LAH';
ex(1).unitId = 900; % index in lookup


ex(2).fn = '034e14timesCSC50.mat';
ex(2).fnsp = '034e14segmentedSpikes.mat';
ex(2).clusid = 4;
ex(2).site = 'RA';
ex(2).unitId = 1406; % index in lookup


ex(3).fn = '030e16timesCSC47.mat';
ex(3).fnsp = '030e16segmentedSpikes.mat';
ex(3).clusid = 2;
ex(3).site = 'RA';
ex(3).unitId = 272; % index in lookup

%% some constants 
kernelwidth = 0.05; %seconds kernel convolution for inst. firing rates
resolution = 0.001; 

% how many responses to stimuli per cell should we plot?
howmany = 6; 

% format the x-axis ticks for categories
catticks = cat_lookup(1:10:end);
catticks = cellfun(@(x) strrep(x, '_', ' '), catticks, 'UniformOutput', false);

%% setup anotations
annot = ['ABCDEFGHIKLMOPQRSTUVWXYZ'];
pbi = 0;
rasterids = [numel(ex)+1:numel(annot)];
ri = 1;

%% open a figure
figh = figure('color', 'w', 'visible', 'on');
figh.PaperUnits = 'inches';
figh.PaperPosition = [0 0 7.4 1*length(ex)];

% setup subplots
gapwidth_h = 10;
gapwidth_v = 17;
sbpos = setup_plot(numel(ex)+1, howmany+6, gapwidth_h, ...
                                 gapwidth_v);
figh.Position = [200 200  figh.PaperPosition(3)*150 figh.PaperPosition(4)*150]; % just for onscreen display, not for plotting

fontSize = 8;
fontSizeLarge = 10;

%% plot units
for wi = 1:numel(ex)
    
    %% do a density plot first
    h = 1;
    ts = load(ex(wi).fn);
    spidx = ts.cluster_class(:,1) == ex(wi).clusid ;
    pos0 = squeeze(sbpos(wi,h,:));
    
    pos0(1) = pos0(1) + pos0(3) * 0.6;
    pos0(3) = pos0(3) * 2.5;
    densax = axes('Position', pos0);
    colorbarhandle = density_plot(ts.spikes, spidx);
    %title(cluster_lookup.sitename(c), 'FontWeight', 'normal');
    
    ylabel(colorbarhandle, '')
    
    if wi == 1
        title(colorbarhandle, 'Density','FontWeight', 'normal')        
    end
        
    set(densax, 'FontSize', fontSize)
    if wi < numel(ex.unitId)        
        xlabel('');        
    end
    pbi = pbi + 1;
    add_text_topleft(densax,annot(pbi), +0.04, +0.04, fontSize, 'bold');
    
    h = h + 2;
    
    %% do a histogramm of log(pvals for each stimulus)
    pos1 = squeeze(sbpos(wi,h,:));
    pos1(3) = pos1(3) * 2.8;
    pos1(1) = pos1(1) + 0.09;
    pvalax = axes('Position', pos1);

    if wi < numel(ex)
        ospr_plot_pval_bars(pvals_rs(ex(wi).unitId,:), [], fontSize, category_colors);
    else
        ospr_plot_pval_bars(pvals_rs(ex(wi).unitId,:), catticks, fontSize, category_colors);
    end
    pbi = pbi + 1;
    add_text_topleft(pvalax,annot(pbi), 0.055, 0.04, fontSize, 'bold');
    
    %% do raster plots for most response-eliciting stimuli
    [temp stimidx] = sort(pvals_rs(ex(wi).unitId,:)); 
    
    % load segmented spikes and paradigm infos
    load(ex(wi).fnsp);
    
    for h = 1:howmany
        tidx = strcmp(conditions.imagename, ...
                      [stim_lookup{stimidx(h)}, '.jpg']);
        cati = floor(stimidx(h)/10)+1;
        spikes = cherries.trial(tidx);
        pos1 = squeeze(sbpos(wi,h+6,:));

        % rasterplot
        ax1 = axes('Position', [pos1(1); (pos1(2) + pos1(4) * 0.3); pos1(3); pos1(4)*0.75]);
        plot_raster(spikes, [-500:1500], [] ,[], 0.8);
        plot([1000 1000], [0 1], ':k');

        if consider_rs(ex(wi).unitId,stimidx(h)) 
            xlr = xlim;
            ylr = ylim;
            
            rectangle('Position', [xlr(1) ylr(1) diff(xlr) diff(ylr)], ...
                      'EdgeColor', [0.7 0.7 0.7], ...
                      'FaceColor', 'none', ...
                      'LineWidth', .5, ...
                      'Curvature', [0.1 0.1]);
        end

        if h == 1
            pbi = pbi + 1;
            add_text_topleft(gca,annot(pbi), 0.04, 0.03, fontSize, 'bold');
        end
        
        % ifrs           
        ax2 = axes('Position', [pos1(1:3); pos1(4)*0.3]);
        ifrs = convolve_spikes(spikes,-1:resolution:2,kernelwidth, ...
                               resolution); 
        [hdl f ] = plot_signals(ifrs(:,500:2500), [-500:1500], ...
                                [0 0 0]);
        ifrhdls(h) = ax2;
        ylabel(ax2, '')
        xlim(ax2, [-500 1500]);
        yl(h,:) = ylim;
        plot([1000 1000], [-1000 1000], ':k');
        plot([0 0], [-1000 1000], ':k');
        ylim(yl(h,:));
        if h > 1 
            set(ax2, 'YTick', []);
        else
            yt = get(ax2, 'YTick');
            set(ax2,'YTick', [yt(1) yt(end)]);
        end
        
        if wi ==numel(ex) && h == 1
            xt = get(ax2,'XTick');
            set(ax2, 'XTick', [0, 1000]);
            ax2.XTickLabelRotation=45;            
            xlabel('ms', 'FontSize', fontSize);
            ylabel('Hz');
        elseif h == 1
            set(ax2, 'XTick', []);
            ylabel('Hz', 'FontSize', fontSize);
        else
            axis off; ;        
        end
        set(ax2, 'FontSize', fontSize)
                
        % stimulus
        ax3 = axes('Position', [pos1(1) + pos1(3) * .75; ...
                            pos1(2)+pos1(4)*.2; pos1(3)*.4; ...
                            pos1(4)*.6]);
        imshow(['stimuli', filesep, stim_lookup{stimidx(h)}, '.jpg']);
        
    end

    for h = 1:howmany
        ylim(ifrhdls(h), [0 max(yl(:,2))]);
    end
    
    
end

print(figh, 'figure1.tiff','-dtiffn','-r600');

