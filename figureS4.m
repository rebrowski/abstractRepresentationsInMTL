clear

load ospr_colors
load regions
nregions = numel(regions);
outfn = 'figureS4.tiff';

%% setup figure
figh = figure('color', 'w', 'visible', 'on');
figh.PaperUnits = 'inches';
figh.PaperPosition = [0 0 7.4 5];
% display it somewhat similar to what will be plotted
figh.Position = [200 200  figh.PaperPosition(3)*150 figh.PaperPosition(4)*150];

fontSizeSmall=6;
fontSize=8;
fontSizeLarge = 10;
markSize = 3;
lineWidht = 2;

%% setup anntoations
annot = ['ABCDEFGHIKLMOPQRSTUVWXYZ'];
aidx  = [ 1:numel(annot)];
ac = 1;

%% load results from RSA
datafilename = 'zvals.mat';
nstim = 100;

if ~exist(datafilename, 'file')
   ospr_calculate_zscores(sessions, secondleveldir) 
end    
load(datafilename)
nregions = numel(regions);

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
% dendrograms one on each row
nrows = 4;
ncols = 1;
gapwidth_h = 10;
gapwidth_v = 10;
overall_width = 0.9;                      
overall_height = 0.88;
pos = setup_plot(nrows, ncols, gapwidth_h, gapwidth_v, overall_height, ...
                        overall_width);

%%% plot dendrograms
cth = 1.37;

for r = 1:numel(regions)
    axpos = squeeze(pos(r,1,:));

    % move it a bit to the right
    axpos(1) = axpos(1) + 0.47*(1-overall_width);

    % make it a bit smaller
    axpos(3) = axpos(3) - axpos(3) * 0.1;
    axpos(4) = axpos(4) * 0.9;
    
    % move it up
    axpos(2) = axpos(2) + 0.2*(1-overall_height); 
    
    dendax(r) = axes('Position', axpos);

    idx = strcmp(cluster_lookup.regionname, regions(r).name);
    
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
                h(hi).Color ='k';
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
    ylabel('1-R');
    set(gca, 'XTick', []);
    title(regions(r).name);
    add_text_topleft(dendax(r),annot(aidx(ac)), 0.05, 0.05, fontSize, 'bold');
    ac = ac + 1;
end

lh = axes();
lh.Position = [0.85, 0.1, 0.1, 0.7];

for ct=1:numel(catticks)
    text(1, ct, catticks{ct}, 'color', category_colors(ct, :));
end

xlim([1 5])
ylim([0 12])
axis off
print(figh, outfn,'-dtiff','-r600');
