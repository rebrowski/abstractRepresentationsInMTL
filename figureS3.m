clear
load ospr_colors
outfn = 'figureS3.tiff';

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

%% load results Image RSA
datafilename = 'ospr_picture_similarity.mat';
% this file is computed in calculate_image_similarities.m
nstim = 100;
load(datafilename);

% concat distance measures as in measurenames
dms = [d1; d2; d3; d4];

%% load some data mainly for the lookups
load category_responses;

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
% dissimilarty mats row 1
% multidimensional scaling row 2
% dendrograms row 3
nrows = 3;
ncols = 4;
gapwidth_h = 10;
gapwidth_v = 10;
overall_width = 0.9;                      
overall_height = 0.88;

pos = setup_plot(nrows, ncols, gapwidth_h, gapwidth_v, overall_height, ...
                        overall_width);
    

%% simmilarity matrices
for r = 1:numel(measurenames)

    % `axpos = squeeze(pos(3,r,:));
    axpos = squeeze(pos(1,r,:));
    % move it up
    axpos(2) = axpos(2) + 0.8*(1-overall_height); 

    axpos(1) = axpos(1) + 0.4*(1-overall_width); % move to the right

    rsax(r) = axes('Position', axpos);
    
    docb = false; 
    %if r == 4; docb = true; end;
    
    
    cbh = plot_similarity_mat(rsax(r), dms(r,:), '', ...
                              catticks, docb, 0.7);

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
    
    title(measurenames{r}, 'FontSize', ...
          fontSize, 'FontWeight', 'normal')
    
    add_text_topleft(rsax(r),annot(aidx(ac)), 0.02, 0.02, fontSize, 'bold')
    ac = ac + 1;
end

if docb
    cbtextpos = [cbh.Position(1), ...
                 cbh.Position(2) + cbh.Position(4)*1.2, ...
                 cbh.Position(3), ...
                 cbh.Position(4) * 0.2];
    cbtxt = axes('Position', cbtextpos);
    text(0,0,measurenames{r}, 'FontSize', fontSize, 'HorizontalAlignment', 'center')
    axis off
end

%% Multidimensional Scaling 
for r = 1:numel(measurenames)
    axpos = squeeze(pos(2,r,:));
    % move it a bit to the right
    axpos(1) = axpos(1) + 0.47*(1-overall_width);
    % make it a bit smaller
    axpos(3) = axpos(3) - axpos(3) * 0.1;
    axpos(4) = axpos(4) * 0.9;
    % move it up
    axpos(2) = axpos(2) + 0.2*(1-overall_height); 

    mdsax(r) = axes('Position', axpos);


    plot_mds(mdsax, squareform(dms(r,:)), [], catticks,false,category_colors, markSize);
% $$$     mdsax(r).XTick = [];
% $$$     mdsax(r).YTick = [];
 
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
% cth = 1.37;

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
    
% $$$     links = linkage(squareform(pdist(zvals(idx,:)', 'correlation')), ...
% $$$                     'average');
    
    d = squareform(dms(r,:)');
    links = linkage(d, 'average');
    
    [h,nodes,orig] = dendrogram(links, 0, 'labels', ...
                                strrep(cat_lookup, '_', ' '));
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
    %axis off
    ylabel('Dissimilarity');
    set(gca, 'XTick', []);
    
    add_text_topleft(dendax(r),annot(aidx(ac)), 0.02, 0.02, fontSize, 'bold');
    ac = ac + 1;
end


print(figh, 'figureS3.tiff','-dtiff', '-r600');