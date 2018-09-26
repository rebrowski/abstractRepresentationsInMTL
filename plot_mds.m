function plot_mds(ax, zvals, regionname, catticks,docb, plotcolors,markSize)

    S=pdist(zvals', 'correlation');
    Y = cmdscale(squareform(S),2);
    %plotcolors = linspecer(10);

    hold on
    for i = 1:100
        if i < 11
            c = 1;
        else
            c = sprintf('%02d', i);
            c = str2num(c(1))+1;
        end

        h(i) = plot(Y(i,1), Y(i,2), 'o', 'Color', plotcolors(c,:), ...
                    'MarkerFaceColor', plotcolors(c,:), 'MarkerSize', ...
                    markSize); 
    end
    

    for d = 1:2
        g = 0.1 * range(Y(:,d));
        r_ =[min(Y(:,d)-g) max(Y(:,d))+g];
        if d == 1; xlim(r_); else ylim(r_);end
    end
    title(regionname)
    
    if docb
        pos = get(ax, 'Position');
        legend(h(1:10:100), catticks, 'Location', 'Best')
        set(ax, 'Position', pos)
        %legend boxoff
    end
