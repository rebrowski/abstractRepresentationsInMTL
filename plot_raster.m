function h = plot_raster(spikes, x, condition, plot_colors, linewidth, ...
                         burstonsets, burstoffsets, burstcolor)
%% function h = plot_raster(spikes, x, condition, plot_colors,
%% linewidth, burstonsets, burstoffsets)
% does a raster plot of spike-times
% spikes is expected to be a cell array of vectors of spike-times
% per trial (e.g. spikes{trialnr} = [-199, 20, 25, 46...]
% x denotes the x-axis in time (same unit as spikes, most of the
% time : milliseconds)
%
% optional arguments for different colors
% condition:  vector with same length as spikes indicating the
% condition a trial belongs to (values should be ascending integers starting
% with 1)
% plot_colors: n by 3 array of rgb-color values, n=number of
% conditions

if ~iscell(spikes)
    spikes = grapes2cell(spikes);
end
ntrials = length(spikes);
if ~exist('x', 'var') || isempty(x)
    warning(['will construct an x-axis based on earliest and latest ' ...
             'spike time-stamp in seconds']);
    mints = min([spikes{:}]);
    maxts = max([spikes{:}]);
    x = (floor(mints/100)*100): ...
        (ceil(maxts/100)*100);
    if isempty(x)
        x = -1000:2000;
    end
    
end
if ~exist('condition', 'var') || isempty(condition)
    condition = repmat(1,1,ntrials);
end

if ~exist('plot_colors', 'var') || isempty(plot_colors)
    ncolors = length(unique(condition));
    if ncolors == 1
        plot_colors = [0 0 0];
    else
        try
            plot_colors = linspecer(ncolors);
            % linspecer.m: http://www.mathworks.com/matlabcentral/fileexchange 
        catch err
            
            warning(['using linspecer.m to define nice colors failed. ' ...
                     'will get some other colors...']);
            
            if ncolors <= 7
                plot_colors = get(gca, 'colororder');
            else
                plot_colors = colormap('hsv');
                idx = 1:floor(size(plot_colors,1)/  ncolors):size(plot_colors,1);
                plot_colors = plot_colors(idx,:);
            end
        end
    end
end
if ~exist('linewidth', 'var') || isempty(linewidth)
    linewidth = 1.2;
end

if nargin < 6
    burstonsets = [];
    borstoffsets = [];
end

if ~exist('burstcolor', 'var')
    burstcolor = [0.7 0.7 0.7]; 
end

ucond = unique(condition); % to lookup color

disp_between = 1/ntrials;
line_height = (3/5)*disp_between;
hold on
a = 1;
for t=1:ntrials
    if ~isempty(spikes{t})
        %% if burst on and offsets are provided, plot bursts as patches
        if ~isempty(burstonsets) & ~isempty(burstoffsets)
            nb = min([length(burstonsets{t}), length(burstoffsets{t})]);
            for j = 1:nb
                
                X = [burstonsets{t}(j) burstonsets{t}(j) ...
                     burstoffsets{t}(j) burstoffsets{t}(j) ];
                Y = [a a-line_height a-line_height a ];
                patch(X, Y, burstcolor, 'EdgeColor', 'none')
                text(burstonsets{t}(1), a-line_height/2, 'X', 'Color', ...
                     burstcolor, 'HorizontalAlignment', 'center', ...
                     'VerticalAlignment', 'middle', 'FontSize', 8, ...
                     'FontWeight', 'bold')
            end
        end

        %% plot the spikes
        for j=1:length(spikes{t})
            line([spikes{t}(j) spikes{t}(j)],[a a-line_height], 'color', ...
                 plot_colors(find(condition(t)==ucond),:), 'LineWidth',linewidth);
        end
        
    end
    a = a - disp_between;
end

xlim([x(1) x(end)]);
plot([0 0], [0 1], ':k');
%plot([1000 1000], [0 1], ':k');

box off
axis off

h = gca;
hold on;
