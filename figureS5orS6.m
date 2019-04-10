clear

%% plot data resulting from ospr_classify_per_subject
Analyses = {'CategoriesFromMeanResponse', ...
            'StimuliFromTrials'};

% a == 1 --> SFig 5 
% a == 2 --> SFig 6
a = 2; 

whichAnalysis = Analyses{a};
fontSize = 6;

%% load data for requested analyses:

if strcmp(whichAnalysis, 'StimuliFromTrials')
    infn =  'classification_results_stimuli_per_subject.mat';
    load(infn);
    guessrate = 100/numel(ustimlabels);
    ulabels = cat_lookup(1:100:1000);
    plotCategories = false;
    outfn = 'figureS6.tiff';
end

if strcmp(whichAnalysis, 'CategoriesFromMeanResponse')
    infn = 'classification_results_categories_frommeanresponse_per_subject.mat';
    load (infn)
    guessrate = 100/numel(ulabels); % percent
    plotCategories = true;
    outfn = 'figureS5.tiff';

end

%% define ticks for confusion matrices
st = length(conf(1,1,1,:));
if plotCategories
    %xt = [st/10+(st/10/2):st/10:(st+(st/10/2))];
    xt = [1:10];
else
    xt = [5:st/10:st];
end

% get names of catticks
catticks = ulabels;
for c =1:numel(catticks)
    e =  strfind(catticks{c}, ' ');
    if isempty(e)
        catticksshort{c} = catticks{c}(1:2);
    else
        catticksshort{c} = catticks{c}([1,e+1]);
    end
end 


%% plot confusion matrices for each subject
nsors = size(kappas,2);
if nsors == 25; % subjects
    nrows = 6; ncols = 5;
else
    nrows = 7; ncols = 9;
end

figh = figure('color', 'w', 'visible', 'on');
figh.PaperUnits = 'inches';
figh.PaperPosition = [0 0 7.4 9];
% display it somewhat similar to what will be plotted
figh.Position = [200 200  figh.PaperPosition(3)*150 figh.PaperPosition(4)*150];
for n = 1:nsors    
    h(n) = subplot(nrows, ncols, n);
    
    %toplot = squeeze(mean(conf(:,n,:,:)))./nperms * 100;
    
    toplot = squeeze(sum(conf(:,n,:,:)));
    toplot = toplot ./ sum(toplot(1,:)) * 100;
    
    imagesc(toplot);
    caxis([0 50]);
    if a == 2
        caxis([0 30]); % per stimulus
    end
        
    colormap('jet');
    ax = gca;
    
    if n == nsors
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
    end
    
    title(sprintf('S #%d', n));
        
    %% add ticks
    xl = xlim;
    yl = ylim;
    set(ax, 'XTick', [] );
    set(ax, 'YTick', [] );
    % plot ticks manually

    for c =1:numel(xt)

        text(xt(c),yl(2)*1.02,catticksshort{c}, 'Rotation',90, 'FontSize', fontSize, ...
             'HorizontalAlignment', 'right', 'VerticalAlignment', ...
             'middle' );

        text(xl(1)-xl(2)*0.03,xt(c),catticksshort{c}, 'Rotation',0, 'FontSize', fontSize, ...
             'HorizontalAlignment', 'right', 'VerticalAlignment', ...
             'middle');

    end
    
        
    %% arrage data for boxplot
    pcorr((n-1)*nperms + 1: n*nperms) = (1-ooserr(:,n))*100 ;
    pidx((n-1)*nperms + 1: n*nperms) = repmat(n,1,nperms);
end


%% plot kappas per subject

subplot(nrows, ncols, 26:30)
boxplot(pcorr', pidx');
hold on;
plot(xlim,[guessrate guessrate], '-.k');
ylabel('% Accuracy');
xlabel('Subject #');


%% print figure to file
print(figh, outfn ,'-dtiff','-r600');