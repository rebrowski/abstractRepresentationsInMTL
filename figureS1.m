clear

% this script plots all stimuli on a 10x10 grid with category

dotext = true;
stimdir = 'stimuli';

load('zvals.mat');
load('category_responses.mat');
load('ospr_colors.mat')
load('regions.mat')

idx = false(numel(cluster_lookup.regionname),1);
for r = 1:numel(regions)
    idx = idx | strcmp(cluster_lookup.regionname, regions(r).name);
end
    
%ncellstot = size(pvals_rs,1); % watch out: this includes units out of regions specified
ncellstot = sum(idx);
si = 1;

if dotext
    positions = setup_plot(10, 12, 20, 0);
    fs = 8; % fontsize
    pos_ = [0 0 8 7];
else
    positions = setup_plot(10, 12, 0, 0);
    fs = 12; % fontsize
    pos_ = [0 0 8 7];
end

fig = figure('color', 'w');
fig.PaperUnits = 'inches';
fig.PaperPosition = pos_;

for catid = 1:10
    for col = 1:12
        
        if col == 1
            subplot('Position', squeeze(positions(catid, col,:)));
            catname = strrep( cat_lookup{si}, '_', ' ');
                        
            text(1,1,catname, ...
                 'FontWeight', 'bold', 'FontSize', fs, 'Color', category_colors(catid,:))
            xlim([0.5 4]); ylim([-1 3]);
            
            if dotext
                nresponses = sum(sum(nsig_rs(:,:,catid)));
                
                text(1,0,sprintf('%d (%.2f%%)', nresponses, ...
                                 nresponses/ncellstot/10 * 100),'FontWeight', ...
                     'bold', 'FontSize', fs);
            end
            

            axis off
        elseif col > 2
            subplot('Position', squeeze(positions(catid, col,:)));
            imshow([stimdir filesep stim_lookup{si} '.jpg']);
            xl = xlim; yl = ylim;
            if dotext
                nresponses = sum(consider_rs(:,si));
                probOfResponding = nresponses/ncellstot*100;
                title(sprintf('%d (%.2f%%)', nresponses, probOfResponding), 'FontWeight', ...
                      'normal', 'FontSize', fs);
            end
            si = si + 1;            
        end
        
    end
end

print(fig, 'figureS1.tiff','-dtiff','-r600');

