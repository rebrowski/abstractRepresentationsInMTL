function ospr_plot_pval_bars(pv, catticks, fontSize, catcolors)
%% ospr_plot_pval_bars is copied from plot_responses and plots
% 10log of p-values for each stimulus in one unit
% it is mainly a helper function for ospr_plot_responses.m

if ~exist('catcolors', 'var')
    catcolors = jet;
    catcolors = catcolors(1:6:end,:);
end

cutoff = -log10(1e-3);
plot_var = -log10(pv);
plot_var(pv == 0) = 50;
responses = find(plot_var > cutoff);

max_val = max(plot_var);
spacing = max(1, floor(max_val/5));
ticks = 0:spacing:(max_val+spacing);

labels = {'1'};
for n=2:length(ticks);
    labels{n} = ['10^{-' num2str(ticks(n)), '}'];
end

for bidx = 1:numel(plot_var)
    hold on
    cati = floor((bidx-1)/10) + 1;
    bh = bar(bidx, plot_var(bidx), 'stacked');
    bh.FaceColor = catcolors(cati,:);
    bh.EdgeColor = catcolors(cati,:);
end

xlim([0 100])

ym = max(plot_var);
if ym == 0
    ym = 1;
end

ylim([0 ym]);

hold on
for i = 1:9
    plot([i*10 i*10],[0 max(plot_var)], ':k');
end

set(gca, 'XTick', [])
set(gca, 'YTick', ticks, 'YTickLabel', labels);

if exist('catticks', 'var') && ~isempty(catticks)
    xt = [5:10:100];
    for c =1:numel(xt)
        
        text(xt(c),0,catticks{c}, 'Rotation', 45, 'FontSize', fontSize, ...
             'HorizontalAlignment', 'right', 'VerticalAlignment', ...
             'top', 'color', catcolors(c,:))
        
    end
% $$$     set(gca, 'XTick', xt );
% $$$     set(gca, 'XTickLabel', catticks)
% $$$     ax = gca;
% $$$     ax.XTickLabelRotation=45;
% $$$     set(gca, 'YTick', ticks, 'YTickLabel', labels);
end

set(gca, 'FontSize', fontSize);

box off

ylabel('p')