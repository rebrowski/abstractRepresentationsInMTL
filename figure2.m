clear

load category_responses
load ospr_colors
load regions

%% open a figure
figh = figure('color', 'w', 'visible', 'on');
figh.PaperUnits = 'inches';
figh.PaperPosition = [0 0 7.4 7.2] * 0.7;
% display it somewhat similar to what will be plotted
figh.Position = [200 200  figh.PaperPosition(3)*150 figh.PaperPosition(4)*150];

fontSize = 8;
fontSizeLarge = 10;
markSize = 4;
lineWidht = 2;

%% format ticks
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

%%%% RESPONSE PROBABILITIES
%%%%%%%%%%%%%%%%%%%%%%%%%%%
mh_ = 0.04; % for the bold panel Letters in the top left
mv_ = 0.01;
rpax = subplot(2,2,[1 2]);%axes('Position', rpaxpos);

%% some constants
nregions = numel(regions);
nsess = numel(unique(cluster_lookup.sessid));
usub = unique(cluster_lookup.subjid);
nsubs = numel(usub);
catticks = cat_lookup(1:10:100);
ncats = numel(catticks);
nstims = numel(cat_lookup);

%% load/calcualte response probabilities boostrapped CI
if ~exist('response_probabilites_bootstrap.mat', 'file')
    ospr_bootstrap_category_responses
end
load response_probabilites_bootstrap.mat

toplot = nsigcatboot ./ subsample_size ./ ncats * 100;
ms = squeeze(mean(toplot));
confi = quantile(toplot, [0.025, 0.975],1); %95%CI
citoplot = NaN(nregions,ncats,2);
citoplot(:,:,2) = squeeze(confi(2, :,:))-ms;
citoplot(:,:,1) = squeeze(confi(1, :,:))-ms;
[bh ebh] = barwitherr(citoplot, ms);
ylabel('%RP [M +- 95%CI]')
set(rpax, 'XTickLabel', {regions(:).name})
box off
grid on
%% plot results of fisher exact test on bars with sign different repsonse probabilities
if ~exist('fisherOnCategories.mat')
    ospr_stats_zvals_rprobs()
end
load fisherOnCategories.mat

[ridx catidx] = find(fp < pcrit & foddsr > 1);
hold on
for k = 1:numel(ridx)
    y = confi(2, ridx(k), catidx(k)) + 0.13;
    x = (ridx(k) - 1) + 0.64 + (catidx(k)-1) * 0.08;
    plot(x,y, '*k', 'MarkerSize', markSize)
end

% color the bars 
for bidx = 1:numel(bh)
   bh(bidx).FaceColor = category_colors(bidx,:);
   bh(bidx).LineWidth = 0.5;
end
set(rpax, 'FontSize', fontSize);

for bidx = 1:numel(ebh)
    set(ebh(bidx), 'CapSize', 2);
end

xlim(rpax, [0.5 4.5])

mh_ = 0.02; % for the bold panel Letters in the top left
mv_ = 0.04;

ax1 = gca;
ax1.Position(3) = ax1.Position(3) * 0.85;


add_text_topleft(rpax,'A', mh_, mv_, fontSize, 'bold')

% do a legend
lh = axes();
lh.Position = [0.81, 0.6, 0.1, 0.4];

for ct=1:numel(catticks)
    text(1, ct, strrep(catticks{ct}, '_', ' '), 'color', category_colors(ct, :));
end

xlim([1 5])
ylim([0 12])
axis off



%% do some unit descritptives
dax = subplot(2,2,3);
load unit_descriptives

% do a plot

domusu=true;

if domusu
    bardat = [nrsu' nrmu' nnrsu' nnrmu'];
    barlabels = {'r SU', 'r MU', 'nr SU', ...
                 'nr MU'};
    co = [46,140,186;
      61,184,184;
      89,149,84;
      122,180,67]./255;
else
    bardat = [(nrsu'+ nrmu') (nnrsu' +nnrmu')];
    barlabels = {'r', 'nr'};
    co = [46,140,186;
      89,149,84;]./255;

end


h = bar(bardat, 'stacked');
for hi = 1:numel(h)
    h(hi).FaceColor = co(hi,:);    
end
set(gca, 'XTick', [1:4]);
set(gca, 'YTick', [0:200:2000]);
set(gca, 'XTickLabel', {regions(:).name});
set(gca, 'FontSize', fontSize);
ylabel('number of units');
grid('on');

% make legend smaller for it to not overlap with the bars:
%keyboard
lh  = legend(barlabels, 'Location', 'NorthEast');
mv_ = 0.01;
mv_ = 0.002;
lh.Position(1) = lh.Position(1) + mv_;
lh.Position(3) = lh.Position(3) - mv_;
legend boxoff;
box off

set(gca, 'FontSize', fontSize);

mh_ = 0.01; % for the bold panel Letters in the top left
mv_ = 0.05;
add_text_topleft(dax,'B', mh_, mv_, fontSize, 'bold')


%% selectivity per category/region
sax = subplot(2,2,4); %axes('Position', saxpos);

for r = 1:nregions
    idx = strcmp(cluster_lookup.regionname, regions(r).name);
    sig = consider_rs(idx,:);
    nsig = sum(sig,2);
    nsig = nsig(nsig>0);

        
    clear n m c
    n = numel(nsig);
    m = max(nsig);

    for k = 1:m
        c(k) = sum(nsig < k);
        
        if k == 2
            %keyboard
            disp(sprintf(['%s: percent of responsive units with exactly one ' ...
                          'response: %.1f'], ...
                         regions(r).name, 100 * c(k)./n))
        end
    end
    
    plot(0:m-1,c./n * 100, 'Linewidth', 1, 'Color', regioncolors(r,:))

    hold on;
    box off
    ylabel('% units');
    xlabel('responses per unit')
end

xlim([0 35])
ylim([0 100])

set(gca, 'FontSize', fontSize);
box off
grid on
hold on;
for r = 1:nregions
    plot(15, 60 - r*10, 'o', 'Color', regioncolors(r,:), ...
         'MarkerFaceColor', regioncolors(r,:), 'MarkerSize', 4)
    text(20, 60 - r*10, regions(r).name, 'Color', 'k', 'FontSize', ...
         fontSize)
end

mh_ = 0.01; % for the bold panel Letters in the top left
mv_ = 0.05;
add_text_topleft(sax,'C', mh_, mv_, fontSize, 'bold')

%% print to file
print(figh, 'figure2.tiff', '-dtiff','-r600');
close(figh)
