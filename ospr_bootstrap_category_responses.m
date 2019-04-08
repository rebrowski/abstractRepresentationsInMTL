function ospr_bootstrap_category_responses()

load category_responses
load regions
load zvals 

%% some constants
subsample_size = 700; % cells per region, EC 822, PHC 819
nbootstraps = 2000; 
nregions = numel(regions);
catticks = cat_lookup(1:10:100);
ncats = numel(catticks);
nstims = numel(cat_lookup);
pcrit = pcrit_rs;
pvals = pvals_rs;
consider = consider_rs;

%% do N subsamples of certain size without replacement 
% bootstrap nsignificant, average zscore of significant responses,

nsigboot = NaN(nbootstraps, nregions,nstims);
zvalboot = NaN(nbootstraps, nregions, nstims);

for ri = 1:nregions
    for bi = 1:nbootstraps
        % bootstrap n significant responses
        ridx = find(strcmp(cluster_lookup.regionname, regions(ri).name));
        ridx = ridx(randperm(numel(ridx)));
        ridx = ridx(1:subsample_size);
        
        %sigidx = pvals(ridx,:)< pcrit; % positive and negative responses
        sigidx = consider(ridx,:); % only positive
        
        z_ = zvals(ridx,:);
        nsigboot(bi,ri,1:nstims) = sum(sigidx);
        % bootstrap average zval of significant responses
        for st = 1:nstims
            sigcells = find(sigidx(:,st));
            sigzvals = z_(sigcells,st);
            if ~isempty(sigzvals)
                zvalboot(bi,ri,st) = mean(sigzvals);
            else
                zvalboot(bi,ri,st) = 0;
            end
        end
    end
end

nsigcatboot = NaN(nbootstraps, nregions, ncats);
zvalcatboot = NaN(nbootstraps, nregions, ncats);

for ri = 1:nregions
    for ci = 1:ncats
        cidx = strcmp(catticks{ci}, cat_lookup);
        nsigcatboot(1:nbootstraps, ri, ci) = sum(nsigboot(:,ri,cidx),3);
        zvalcatboot(1:nbootstraps, ri, ci) = mean(zvalboot(:,ri, cidx),3);
    end
end

%% save info to plot in ospr_figure_response_probabilities
save('response_probabilites_bootstrap.mat', ...
     'nsigboot', 'nsigcatboot', 'subsample_size', 'zvalboot', 'zvalcatboot')
disp('saved boostrapping results to reponse_probabilities_bootstrap.mat')

