load zvals; % zscored firing rates per unit and stimulus
load ospr_colors % some defintions of the colors for the stimulus-categories
load regions % some definitions of anatomical regions were electrodes are located

%% some constants
nregions = numel(regions);
nstim = 100;
fontSizeSmall=6;
fontSize=8;
fontSizeLarge = 10;
markSize = 3;
lineWidht = 2;


%% define which set of units we want to include in the analysis
%whichUnits ='all','responsive', 'non-responsive';
whichUnits = 'all';

%% setup figure
figh = figure('color', 'w', 'visible', 'on');
figh.PaperUnits = 'inches';
figh.PaperPosition = [0 0 7.4 5];
% display it somewhat similar to what will be plotted
figh.Position = [200 200  figh.PaperPosition(3)*150 figh.PaperPosition(4)*150];

%% setup anntoations
annot = ['ABCDEFGHIKLMOPQRSTUVWXYZ'];
aidx  = [ 1:numel(annot)];
ac = 1;

%% load responsive units info
if strcmp(whichUnits, 'responsive') | strcmp(whichUnits, 'non-responsive')
    catresps = load ('category_responses.mat');
end

%% axes ticklabels for categories
catticks = cat_lookup(1:10:end);
catticks = cellfun(@(x) strrep(x, '_', ' '), catticks, 'UniformOutput', false);
for c =1:numel(catticks)
    e =  strfind(catticks{c}, ' ');
    if isempty(e)
        catticksshort{c} = catticks{c}(1:2);
        catticksshort{c} = regexprep(catticksshort{c},'(\<[a-z])','${upper($1)}');
    else
        catticksshort{c} = catticks{c}([1,e+1]);
        catticksshort{c} = regexprep(catticksshort{c},'(\<[a-z]+)','${upper($1)}');
    end

end

%% setup subplot 
nrows = 3;
ncols = 4;
gapwidth_h = 10;
gapwidth_v = 10;
overall_width = 0.9;                      
overall_height = 0.88;

pos = setup_plot(nrows, ncols, gapwidth_h, gapwidth_v, overall_height, ...
                        overall_width);

%% simmilarity matrices
for r = 1:numel(regions)

    % `axpos = squeeze(pos(3,r,:));
    axpos = squeeze(pos(1,r,:));
    % move it up
    axpos(2) = axpos(2) + 0.8*(1-overall_height); 

    axpos(1) = axpos(1) + 0.4*(1-overall_width); % move to the right

    rsax(r) = axes('Position', axpos);
    
    docb = false; if r == 4; docb = true; end;
    
    idx = strcmp(cluster_lookup.regionname, regions(r).name);
    if strcmp(whichUnits, 'responsive')
        idx = idx & any(catresps.consider_rs,2);
    elseif strcmp(whichUnits, 'non-responsive')
        idx = idx & ~any(catresps.consider_rs,2);
    end
    
    cbh = plot_similarity_mat(rsax(r), zvals(idx,:), '', ...
                              catticks, docb, 0.7);

    caxis([0.6 1.1])
    axis off
    if docb
        ylabel(cbh, '')
        cbh.Position(3) = cbh.Position(3)*.3;
    end
    
    xt = [5:10:100];
    ylim([-markSize 100+markSize])
    xlim([-markSize 100+markSize])
    for c =1:numel(xt)
        if true
            text(xt(c),100+markSize*.7,catticks{c}, 'Rotation',45, 'FontSize', fontSize, ...
                 'HorizontalAlignment', 'right', 'VerticalAlignment', ...
                 'middle', 'color', category_colors(c,:))
        end
        if true
            text(-markSize*.7, xt(c),catticksshort{c}, 'Rotation', 0, 'FontSize', fontSize, ...
                 'HorizontalAlignment', 'right', 'VerticalAlignment', ...
                 'middle', 'color', category_colors(c,:))
        end
    end
    
    title(sprintf('%s (n=%d)', regions(r).name, sum(idx)), 'FontSize', ...
          fontSize, 'FontWeight', 'normal')
    
    add_text_topleft(rsax(r),annot(aidx(ac)), 0.02, 0.02, fontSize, 'bold')
    ac = ac + 1;
end

cbtextpos = [cbh.Position(1), ...
       cbh.Position(2) + cbh.Position(4)*1.2, ...
       cbh.Position(3), ...
       cbh.Position(4) * 0.2];
cbtxt = axes('Position', cbtextpos);
text(0,0,'1-R', 'FontSize', fontSize, 'HorizontalAlignment', 'center')
axis off



%% Multidimensional Scaling 
for r = 1:numel(regions)
    axpos = squeeze(pos(2,r,:));
    % move it a bit to the right
    axpos(1) = axpos(1) + 0.47*(1-overall_width);
    % make it a bit smaller
    axpos(3) = axpos(3) - axpos(3) * 0.1;
    axpos(4) = axpos(4) * 0.9;
    % move it up
    axpos(2) = axpos(2) + 0.2*(1-overall_height); 

    mdsax(r) = axes('Position', axpos);

    idx = strcmp(cluster_lookup.regionname, regions(r).name);
    if strcmp(whichUnits, 'responsive')
        idx = idx & any(catresps.consider_rs,2);
    elseif strcmp(whichUnits, 'non-responsive')
        idx = idx & ~any(catresps.consider_rs,2);
    end

    plot_mds(mdsax, zvals(idx,:), [], catticks,false,category_colors, markSize);
    mdsax(r).XTick = [];
    mdsax(r).YTick = [];
 
    if r == 1
        xlabel(mdsax(r), 'D1');
        ylabel(mdsax(r), 'D2');
    end
    set(mdsax, 'FontSize', fontSize)
    add_text_topleft(mdsax(r),annot(aidx(ac)), 0.02, 0.02, fontSize, ...
                     'bold');
    ac = ac + 1;
end


%%% plot multidemnsional scaling representation of the same data
cth = 1.37;

for r = 1:numel(regions)
    %axpos = squeeze(pos(1,r,:));
    axpos = squeeze(pos(3,r,:));

    % move it a bit to the right
    axpos(1) = axpos(1) + 0.47*(1-overall_width);

    % make it a bit smaller
    axpos(3) = axpos(3) - axpos(3) * 0.1;
    axpos(4) = axpos(4) * 0.9;
    
    % move it up
    axpos(2) = axpos(2) + 0.2*(1-overall_height); 
    
    dendax(r) = axes('Position', axpos);

    idx = strcmp(cluster_lookup.regionname, regions(r).name);
    if strcmp(whichUnits, 'responsive')
        idx = idx & any(catresps.consider_rs,2);
    elseif strcmp(whichUnits, 'non-responsive')
        idx = idx & ~any(catresps.consider_rs,2);
    end
    
    links = linkage(squareform(pdist(zvals(idx,:)', 'correlation')), 'average');
    [h,nodes,orig] = dendrogram(links, 0, 'labels', ...
                                strrep(cat_lookup, '_', ' '), ...
                                'colorthreshold', cth);
    % sort according to x
    allx = vertcat(h(:).XData);
    [allx xidx] = sort(allx(:,1));
    allcolors = unique(vertcat(h(xidx).Color), 'rows', 'stable');
    allcolors(sum(allcolors,2) == 0,:) = [];

    % paint nodes in tones of grey, rather than default colors
    gc = [0.5 0.5 0.5; 0.7 0.7 0.7];
    for c = 1:size(allcolors,1)
        for hi = 1:numel(h)        
            if sum(h(hi).Color == allcolors(c,:)) == 3        
                h(hi).Color = gc(mod(c,2)+1,:);
            end
        end
    end

    ymin = min(ylim);
    hold on
    ct=cat_lookup(orig);
    for ix = 1:numel(ct)
        cati = find(strcmp(strrep(ct{ix},'_', ' '), catticks));
        plot([ix-0.5 ix+0.5], [ymin ymin], '-', 'color', ...
             category_colors(cati,:), 'LineWidth', 3);
    end

    set(dendax(r), 'FontSize', fontSize);
    axis off

    add_text_topleft(dendax(r),annot(aidx(ac)), 0.02, 0.02, fontSize, 'bold');
    ac = ac + 1;
end

%% write figure to file
outfn = ['ospr_rsa_results_', whichUnits '.png'];
print(figh, outfn,'-dpng','-r600');