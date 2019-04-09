function cbh = plot_similarity_mat(ax, zvals, regionname, catticks, docb, lw)

if size(zvals, 1) == 1 & size(zvals, 2) == 4950
    % if this is the case, these alredy are distance values
    % this was added to use the same plotting routine to do the
    % image similarities as the neural similarities
    
    toplot = squareform(zvals);
else

    S=pdist(zvals', 'correlation');
    toplot = squareform(S);

end
from = mean(toplot(:)) - 2.5*std(toplot(:));
to = mean(toplot(:)) + 2.5*std(toplot(:));
[x1 x2] = size(toplot);

step = x1/10;
pch = pcolor(1:x1, 1:x2, toplot); 
pch.LineStyle = 'none';
ticks_ = step/10*6:step:100*step;

if ~isempty('catticks')

    set(ax,'YDir','reverse');
    set(ax, 'XTick', ticks_);
    set(ax, 'XTickLabel', catticks)
    set(ax, 'YTick', ticks_);
    set(ax, 'YTickLabel', catticks)
    ax.XTickLabelRotation=45;
end

if docb
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

colormap(ax, 'jet')
caxis([from to]);
hold on
if ~exist('lw', 'var')
    lw = 1;
end

for i = 1:9
    plot([i*step+1 i*step+1], [0 10*step], 'k', 'LineWidth', lw);
    plot([0 10*step], [i*step+1 i*step+1], 'k', 'LineWidth', lw);
end

title(regionname)
