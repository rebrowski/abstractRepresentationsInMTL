
load category_responses % produced by ospr_category_responses.m
load ospr_colors
load regions
nregions = numel(regions);

%% define what we want to look at
Analyses = {'CategoriesFromMeanResponse', ...
            'StimuliFromTrials'};
analyseslabels = {'MR\rightarrow SC', 'T\rightarrow SI'};

allong = {{'semantic'; 'generlization'}, {'decode identity'; 'from trials'}}; 
% set different color max/mins for each analysis

caxticks(1,:) = [0 50];
caxticks(2,:) = [0 10];

%whichUnits ='all' or 'responsive';
whichUnits = 'all';

whichanalyses = [1 2];

Analyses = Analyses(whichanalyses);
analyseslabels = analyseslabels(whichanalyses);
allong = allong(whichanalyses);
caxticks = caxticks(whichanalyses,:);

outfn = ['ospr_classification_results', ...
         whichUnits , '_' ];
for a = 1: numel(Analyses)
    outfn = [outfn Analyses{a}(1:2), '_'];     
end

%% setup figure
figh = figure('color', 'w', 'visible', 'on');
figh.PaperUnits = 'inches';
figh.PaperPosition = [0 0 7.4 1.65*numel(Analyses)];
% display it somewhat similar to what will be plotted
figh.Position = [200 200  figh.PaperPosition(3)*150 figh.PaperPosition(4)*150];

fontSizeSmall=6;
fontSize=7;
fontSizeLarge = 10;
markSize = 3;
lineWidht = 2;

% setup anntoations
annot = ['ABCDEFGHIKLMNOPQRSTUVWXYZ'];
if numel(Analyses) == 2                    
aidx  = [ 2,3,4,5, 7,8,9,10, 1,6];
elseif numel(Analyses) == 3;
    aidx = [2,3,4,5, 7,8,9,10, 12,13,14,15, 1,6,11];
end

ac = 1;
%% setup subplot positions for the confusion matrices
nrows = numel(Analyses);
ncols = 5;
gapwidth_h = 10;%15;
gapwidth_v = 10;%5;
overall_width = 0.9;
overall_height = 0.85;

pos = setup_plot(nrows, ncols, gapwidth_h, gapwidth_v, overall_height, ...
                        overall_width);

for a = 1:numel(Analyses)
    
    whichAnalysis = Analyses{a};
    
    %% load data for requested analyses:
    if strcmp(whichAnalysis, 'CategoriesFromTrials')
        infn =  ['classification_results_categories_fromtrials_' whichUnits '.mat'];
        load(infn);
        
        guessrate = 100/numel(ulabels); % percent
        plotCategories = true;
    end

    if strcmp(whichAnalysis, 'StimuliFromTrials')
        infn =  ['classification_results_stimuli_' whichUnits '.mat'];
        load(infn);
        guessrate = 100/numel(ustimlabels);
        ulabels = cat_lookup(1:100:1000);
        plotCategories = false;
    end

    if strcmp(whichAnalysis, 'CategoriesFromMeanResponse')
        infn = ['classification_results_categories_frommeanresponse_' ...
                whichUnits '.mat'];
        load (infn)
        guessrate = 100/numel(ulabels); % percent
        plotCategories = true;
    end
    
    %% define ticks for confusion matrices
    st = length(conf(1,1,1,:));
    if plotCategories
        xt = [st/10+(st/10/2):st/10:(st+(st/10/2))];
    else
        xt = [5:st/10:st];
    end
    
    % get names of catticks
    catticks = ulabels;
    for c =1:numel(catticks)
        e =  strfind(catticks{c}, ' ');
        if isempty(e)
            catticksshort{c} = catticks{c}(1:2);
            %catticksshort{c} = regexprep(catticksshort{c},'(\<[a-z])','${upper($1)}');
        else
            catticksshort{c} = catticks{c}([1,e+1]);
            %catticksshort{c} = regexprep(catticksshort{c},'(\<[a-z]+)','${upper($1)}');
        end

    end
    % save data for boxplots further below
    allKappas{a} = kappas;
    allAccuracies{a} = [1 - ooserr];
    
    %% regions confusion 
    for r = 1:nregions
        % position of subplot
        axpos = squeeze(pos(a, r+1,:));
        axpos(2) = axpos(2) + 0.9*(1-overall_height); % move up
        axpos(1) = axpos(1) + 0.6*(1-overall_width); % move to the right
        ax = axes('Position', axpos);
        confaxes(a,r) = ax;
        
        % confusion
        conftoplot = squeeze(sum(conf(:,r,:,:),1));
        % the following is necessary because pcolor displays vertices
        % not faces (as it is the case in imagesc)
        conftoplot(:,end+1) = 0;
        conftoplot(end+1,:) = 0;
        assert(maxtestperf == sum(sum(sum(conf(:,1,:,:)))))

        conftoplot = 100 * conftoplot./sum(conftoplot(:,1));
        pch = pcolor(conftoplot);
        pch.LineStyle = 'none';
        
        %colormapname = 'hot';
        colormapname = 'jet';
        
        cm = colormap(colormapname);        
        
        if strcmp(colormapname, 'hot')
        cm(end,:) = [0.95 0.95 0.95]; % not toally white such that
                                     % we can use imagemagick to
                                     % replace white with
                                     % tranparency afterwards
        end
        
        colormap(cm);
        set(ax, 'YDir', 'reverse')
        set(ax, 'FontSize', fontSize);
        if a == 1
            title([regions(r).name] , 'FontWeight', 'normal', 'FontSize', ...
                  fontSize) 
        end
        
        caxis(caxticks(a,:));            
        
        if r == 4
            keepos = get(ax, 'Position');
            cbax = colorbar;
            cbpos = get(cbax,'Position');
            cbpos(1) = keepos(1) + keepos(3) * 1.05;
            cbpos(2) = cbpos(2) + cbpos(4) * 0.25;
            cbpos(3) = keepos(3) * 0.05;
            cbpos(4) = cbpos(4) * 0.5;
            set(cbax,'Position', cbpos)
            ylabel(cbax, '%', 'Rotation', 0);
            set(cbax, 'FontSize', fontSize);
            set(ax,'Position', keepos);
            ylim(cbax, caxticks(a,:));
            set(cbax, 'YTick',caxticks(a,:));
            set(cbax, 'FontSize', fontSize);
        end
        
        xl = xlim;
        yl = ylim;
        set(ax, 'XTick', [] );
        set(ax, 'YTick', [] );
        % plot ticks manually

        for c =1:numel(xt)
            % xticks
            if a == numel(Analyses)
                text(xt(c),yl(2)*1.02,strrep(catticks{c}, '_', ' '), 'Rotation',45, 'FontSize', fontSize, ...
                     'HorizontalAlignment', 'right', 'VerticalAlignment', ...
                     'middle' );
            else
                    text(xt(c),yl(2)*1.02,catticksshort{c}, 'Rotation',90, 'FontSize', fontSize, ...
                     'HorizontalAlignment', 'right', 'VerticalAlignment', ...
                     'middle' );
            end
            
            % yticks
            if true%r == 1
                text(xl(1)-xl(2)*0.03,xt(c),catticksshort{c}, 'Rotation',0, 'FontSize', fontSize, ...
                     'HorizontalAlignment', 'right', 'VerticalAlignment', ...
                     'middle');
            end
        end
        add_text_topleft(ax, annot(aidx(ac)),0.01, 0.04, fontSize, 'bold');
        ac = ac + 1;
    end
end

%% arrange kappas for boxplot function
clearvars alab rlab dat
dc = 1;
for r = 1:numel(regions)        
    for a = 1:numel(Analyses)
        for k =1:numel(allKappas{a}(:,r));
            dat(dc) = allKappas{a}(k,r);
            alab{dc} = analyseslabels{a};
            rlab{dc} = regions(r).name;
            dc = dc + 1;
        end
    end
end

kytix = [0:0.2:1];

%% plot boxplots for each analysis
for a = 1:numel(Analyses)
    axpos = squeeze(pos(a, 1,:));
    axpos(2) = axpos(2) + 0.9*(1-overall_height); % move up
    axpos(1) = axpos(1) + 0.2*(1-overall_width); % move to the
                                                 % right
    axpos(3) = axpos(3) * 1.2;
    axes('Position', axpos)
    
    idx = strcmp(alab, analyseslabels{a});
    bph = boxplot(dat(idx), rlab(idx), ...
                  'factorgap', 0, ...
                  'Color', 'k', ...
                  'Notch', 'on', 'Symbol', '.k');%,'LabelOrientation',
                                                 %'inline');

    title(allong{a}, 'FontSize', fontSize, 'FontWeight', 'normal')

    h = findobj(gca,'Tag','Box');
    h2 = findobj(gca,'tag','Median');
    ylim([0 1])
    box off
    ylabel('\kappa')
    set(gca, 'FontSize', fontSize);
    add_text_topleft(gca,annot(aidx(ac)),0.01, 0.04, fontSize, 'bold');
    ac = ac + 1;
end

outfn = sprintf('%s_%dperms_%s', outfn, nperms,codingscheme)
print(figh, [outfn '.png'],'-dpng','-r600');
