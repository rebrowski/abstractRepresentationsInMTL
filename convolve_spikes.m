function [ys x] = convolve_spikes(spikes1, x, kern_width, resolution)
%%function [ys x] = convolve_spikes(spikes1, x, kern_width, resolution)
% takes spikes from grapes.mat (milliseconds), x-axis (seconds), kern_width (seconds), and a
% time-resolution (binwith for kernel-convolution, seconds)
if ~exist('kern_width', 'var')    
    kern_width = 0.1; %s
end

if ~exist('resolution', 'var')
    resolution = 0.001; % one millisecond
end

kern_length = kern_width*5;
kernel = normpdf(-kern_length:resolution:kern_length, 0, kern_width);

%% assert that area under the curve of kernel is one, if so, wen can
%% interpret the resutls as firing-rates in Hz (See Dylan & Abbots
%% Theoretical Neuroscience, p. 12), if the resulting curve is divided
%% by ntrials (should be th case if kern_width is about +/- 5SD

kernel_area = trapz(-kern_length:resolution:kern_length,kernel); % are under curve of kernel
if ~(kernel_area > 0.99 & kernel_area <1.001)
    warning(['The inst. firing rates produces might have an arbitrary ' ...
             'unit']);
end

if ~iscell(spikes1)
    spikes1 = grapes2cell(spikes1);
end

if ~exist('x', 'var')
    warning(['assuming timestamps are in milliseconds '...
             'will construct an x-axis based on earliest and latest ' ...
             'spike time-stamp in seconds']);
    mints = min([spikes1{:}]);
    maxts = max([spikes1{:}]);
    x = (floor(mints/100)*100)/1000: ...
        resolution: ...
        (ceil(maxts/100)*100)/1000;
end

ntrials = length(spikes1);

for t =1:ntrials
    % convert to seconds
    y_ = (spikes1{t}./1000)';
    % bin spikes in 1 ms bins
    y_ = histc(y_, x);
    % convolve with kernel
    ys(t,:) = conv(y_, kernel, 'same');
end

if ntrials == 0
    ys = zeros(0, length(x));
end