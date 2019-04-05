function ospr_stats_zvals_rprobs()
%% function ospr_stats_zvals_rprobs()
load category_responses
load regions

%% some constants
nregions = numel(regions);
nsess = numel(unique(cluster_lookup.sessid));
usub = unique(cluster_lookup.subjid);
nsubs = numel(usub);
catticks = cat_lookup(1:10:100);
ncats = numel(catticks);
nstims = numel(cat_lookup);
nsig = squeeze(sum(nsig_rs)); % average over left/right hemisphere
ntot = squeeze(sum(ntot)); % total number of tests run in both hemispheres

%% do fishers exact test of each cat against all others within a region
fp = NaN(nregions, ncats); % fisher pvalue
foddsr = NaN(nregions, ncats); % odds ratio
fci = NaN(nregions,ncats,2); % confidence intervals from fisher
ftname = cell(ncats); % which catgeory ist tested gainst all others?

for ri = 1:4
    for ci = 1:ncats
        
        fmat(1,1) = nsig(ri,ci); % sig tests in cat of interest
        fmat(2,1) = ntot(ri,ci) - nsig(ri,ci); % nonsig in cat of interst
      
        oidx = 1:10; oidx(oidx == ci) = [];
        fmat(1,2) = sum(nsig(ri,oidx));
        fmat(2,2) = sum(ntot(ri,oidx)) - fmat(1,2);
        
        [h p stats] = fishertest(fmat);

        fp(ri,ci) = p;
        foddsr(ri, ci) = stats.OddsRatio;
        fci(ri,ci,1:2) = stats.ConfidenceInterval;
        ftname{ri,ci} = catticks{ci};        
        
    end
end

% bonferroni correction
pcrit = 0.05 ./ numel(fp);

% save data of fisher as mat to be plottet in
% ospr_figure_repsonses_probabilities.m
save('fisherOnCategories.mat', 'fp', 'foddsr', 'fci', 'ftname', 'pcrit');
