function [ooserror, conf, kappa] = ospr_doclassperm(X,Y,ci,regions, ...
                                             cluster_lookup, labels, ...
                                             algo, codingscheme, includeUnits)

nlabels = numel(unique(Y));
conf = NaN(numel(regions),nlabels,nlabels);
ooserror = NaN(numel(regions),1);

if ~exist('includeUnits', 'var')
   includeUnits = true(1,numel(Y)); 
end


for r = 1:numel(regions)

    % get units in region
    if strcmp(regions(r).name, 'all')
        ridx = includeUnits;
    else
        ridx = strcmp(cluster_lookup.regionname, regions(r).name) & includeUnits;        
    end
    
    % train the model
    trainidx = training(ci);
    X_train = X(trainidx, ridx);
    Y_train = Y(trainidx);
    
    Model = fitcecoc(X_train,Y_train, 'Coding', codingscheme, ...
                     'Learners', algo);
    
    % test the model        
    testidx = test(ci);
    X_test = X(testidx, ridx);
    Y_true = Y(testidx);
    Y_pred = predict(Model, X_test);
    
    % save out of sample error
    conm = confusionmat(Y_true, Y_pred, 'ORDER', labels);
    conf(r,1:numel(labels),1:numel(labels)) = conm;
    ooserror(r) = 1-(trace(conm)/sum(conm(:))); 

    % save cohens kappa but see http://www.john-uebersax.com/stat/kappa2.htm
    % cohenskappa(conm)
    chance_agreement = 1/nlabels;
    observed_agreement = 1-ooserror(r);
    kappa(r) = (observed_agreement - chance_agreement)    / ...
               (                 1 - chance_agreement);
    
end

    
    
    