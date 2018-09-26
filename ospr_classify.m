%% run decoding analysis

load('ospr_colors.mat');
r = load('regions.mat'); % we need to fool parfor
regions = r.regions;

analyses = {'classify_category_from_meanresponse', ...
            'classify_stim_identity'};

select_units = {'responsive', 'all'};

fracholdout = 0.5;
nperms = 100;  % numer of random repartitionings of data into
              % training and test set
algo = 'svm'; % support vector machiens
codingscheme = 'onevsall'; 

for ai = 1:numel(analyses)
    for su = 1:numel(select_units)
        whichAnalysis = analyses{ai};
        whichUnits = select_units{su};

        disp(sprintf('running %s on %s units', whichAnalysis, whichUnits));
        disp(sprintf('using %s with %s coding-scheme', algo, codingscheme));
        disp(sprintf(['Proportion holdout: %.2f, Number of random reparitionings: ' ...
                      '%d'], fracholdout, nperms));

        % the rows in X are observations/instances/examples ... i.e., ospr images
        % the columns are a set of measurments/predictors/features ...i.e,  cells

        if strcmp(whichAnalysis, 'classify_stim_identity')
            datafilename = 'zvals_trials.mat';
            load(datafilename)
            Y = stim_lookup';
            
            ustims = stim_lookup(1:10:1000);
            ustimlabels = cellfun(@(x) strrep(x, '_', ' '), ustims, 'UniformOutput', false);

            ucats = cat_lookup(1:100:1000);
            ucatlabels = cellfun(@(x) strrep(x, '_', ' '), ucats, 'UniformOutput', false);

            
            ulabels = ustims;
            outfn =  'classification_results_stimuli';
            
        elseif strcmp(whichAnalysis, 'classify_category_from_trials')
            datafilename = 'zvals_trials.mat';
            load(datafilename)
            Y = cat_lookup';
            
            ustims = stim_lookup(1:10:1000);
            ustimlabels = cellfun(@(x) strrep(x, '_', ' '), ustims, 'UniformOutput', false);

            ucats = cat_lookup(1:100:1000);
            ucatlabels = cellfun(@(x) strrep(x, '_', ' '), ucats, 'UniformOutput', false);
            
            ulabels = ucats;
            outfn =  'classification_results_categories_fromtrials';
        
        elseif strcmp(whichAnalysis, 'classify_category_from_meanresponse')
            datafilename = 'zvals.mat';
            load(datafilename)
            Y = cat_lookup';
            
            ustims = stim_lookup;
            ustimlabels = cellfun(@(x) strrep(x, '_', ' '), ustims, 'UniformOutput', false);
            ucats = cat_lookup(1:10:100);
            ucatlabels = cellfun(@(x) strrep(x, '_', ' '), ucats, 'UniformOutput', false);
            
            ulabels = cat_lookup(1:10:100);
            outfn = 'classification_results_categories_frommeanresponse';
        end

        X = zvals'; 

        outfn = [outfn '_' whichUnits '.mat'];

        %% do the steps suggested in this video for the unit data:
        %https://de.mathworks.com/videos/machine-learning-with-matlab-getting-started-with-classification-81766.html?elqsid=1491471561059&potential_use=Education

        % for reproducability
        rng('default');
        rng(1)

        %% partition into training and test set
        ooserr = NaN(nperms, numel(regions)); % out of sample errors per
        kappas = NaN(nperms, numel(regions)); % cohens kappa
        conf = NaN(nperms, numel(regions),numel(ulabels), numel(ulabels)); 
        maxtestperf  = fracholdout * numel(Y) * nperms;

        %% select whether to use all units, only responsive or only SU etc.
        if strcmp(whichUnits, 'responsive')
            catresps = load ('category_responses.mat');
            includeUnits = any(catresps.consider_rs,2);
        elseif strcmp(whichUnits,'all')
            includeUnits = true(size(X,2),1);
        end
        assert(size(X,2) == numel(includeUnits));
        %disp(sprintf('will use %d units', sum(includeUnits)));

        tic
        disp(sprintf('running %d random repartitionsings into training and test set', ...
                     nperms))

        for np = 1:nperms
            ci = cvpartition(Y, 'holdout', fracholdout);
            [ooserr(np,:) conf(np, :,:,:) kappas(np,:)]= ospr_doclassperm(X,Y,ci,regions, ...
                                                              cluster_lookup, ...
                                                              ulabels, ...
                                                              algo, ...
                                                              codingscheme, ...
                                                              includeUnits);

            
        end

        toc

        save(outfn,...
             'ooserr', 'conf', 'nperms', 'algo', ...
             'codingscheme', 'ustims', 'ustimlabels', 'ulabels', 'ucatlabels', ...
             'cat_lookup', 'stim_lookup', 'kappas', ...
             'maxtestperf', 'fracholdout','-v7.3', 'includeUnits')
        disp(sprintf('saved %s in %s', outfn));
                            
    end
end