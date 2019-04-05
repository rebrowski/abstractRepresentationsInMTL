function [cba] = density_plot(spikes, idx, donorm)
%%function density_plot(spikes, idx)
% this is copied and slightly adapted from Simeons qMetrics.m

color_ = [0 0 0];
if ~exist('idx', 'var')
    wavs = spikes;
else
    wavs = spikes(idx,:);
end

if ~exist('donorm', 'var')
    donorm = true;
end

mean_spike = mean(wavs);
std_spike = std(wavs);
lbound=floor(min(min(wavs)));  %Lowest point of the figure
ubound=ceil(max(max(wavs)));  %Highest point of the figure
vps=size(spikes,2);   %Values per spike after interpolation. 64 without interpolation

%Make the 2D histogram
ybins=linspace(lbound,ubound,150);  %Vector of bins in vertical direction
ybinSize=ybins(2)-ybins(1);         %Size of a bin in vertical direction
numXbins=vps;                       %Number of bins in horizontal direction
numYbins=length(ybins);             %Number of bins in vertical direction
n=zeros(numXbins,numYbins);         %Preallocate 2D histogram

%Bin count
for k=1:numXbins
    for j=1:numYbins
        n(k,j)= sum ( wavs(:,k) <= ybins(j)+ybinSize/2 & wavs(:,k) > ybins(j)-ybinSize/2);
    end
end

% 17.12.2018 T.R. some normalization to get meaningful color-values here
if donorm
    n = n./max(n(:));
end

%Creates colormaps for each cluster
maxN=max(max(n));   %determine amount of colorsteps in colormap (color resolution)
colorMap=zeros(maxN+1,3);   %preallocate space for the colormap. 3-column RGB vector
colorMap(1,:)=[1 1 1];   %first value of colormap set to white. 
cBuffer=zeros(1,maxN);
for e=1:3
    cBuffer(1:ceil(maxN/2))=color_(e)-linspace(0,1,ceil(maxN/2));  % in equal steps, increment from color of choice (myColors{i}) towards black
    cBuffer(cBuffer < 0)=0;     % RGB are values between 0 and 1. can't go below black (=0).
    cBuffer((ceil(maxN/2)+1):maxN)=linspace(0,1,maxN-ceil(maxN/2));  % in equal steps, increment from color of choice (myColors{i}) towards black
    cBuffer(cBuffer > 1)=1;     % RGB are values between 0 and 1. can't go above white
    colorMap(2:end,e)=cBuffer;   % assign cBuffer colormap to i in colorMaps
end

% remove extreme outliers in order to keep color resolution
cutoff = 5*std(reshape(n,numel(n),1)); %magic cutoff for too high bin values
n(n>cutoff) = cutoff; %replace n with n without too high bin values
% pcolor(n'),shading interp % plot the 2D histogram
xvals = [-19:44]*1000/(2^15);
try
    pcolor(xvals, ybins, n');
catch
    pcolor(n')
end

shading interp
% xlim([0 numXbins]);
% ylim([0 numYbins]);

xlabel('ms'); 
ylabel('\muV');


cba = colorbar;
if donorm
    ylabel(cba, 'Density', 'rotation', 90);
end
    