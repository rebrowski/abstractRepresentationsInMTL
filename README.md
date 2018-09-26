# Analysis Code and Data of "Abstract Semantic Represetations in MTL Neurons" (Reber et al. in prep.)

This repository contains code and data accompanying "Representation of Abstract Semantic Knowledge in Populations of Human Single Neurons in the Medial Temporal Lobe". If you have any questions, please contact <treber@uni-bonn.de>. All data files and code are in Matlab format.

## Code
We used Matlab R2017 with the statistics and machine learning toolbox, as well as the signal processing toolbox. 

- `ospr_figure_rsa.m` reproduces Figure 2 in the paper.
- `ospr_classify.m` does the decoding analyses reported in the paper.
- `ospr_figure_decoding.m` reads output from `ospr_classify.m` and reproduces Figure 3 in the paper.

Further .m files in this repository are included because they are called by the above scripts at some point or another.

## Data
### `zvals.mat`
Containes z-scored firing rates for each stimulus-unit combination, and some lookup variables. Please refer to the paper for the methods used to obtain these z-scores. 

- `zvals`: a nunits X nstimuli matrix of zscores
- `cluster_lookup`: a table with nunits rows and 8 columns with infos on the units (such as anatomical location, SU vs. MU, etc) rows in this table correspond to rows in zvals variable above
- `stim_lookup`: a cell of size nstimuli, i.e., 100 of names of the presented images (e.g., wild\_animals\_6). Entries correspond to the columns in zvals variable above.
- `cat_lookup`: a cell of size nstimuli = 100 of names of the category the images belong to. Entries correspond to the columns in zvals variable above.

### `zvals_trial.mat`
Containes z-scored firing rates for each trial-unit combination, and some lookup variables. Please refer to the paper for the methods used to obtain these z-scores. 

- `zvals`: a nunits X nstrials matrix of zscores
- `cluster_lookup`: a table with nunits rows and 8 columns with infos on the units (such as anatomical location, SU vs. MU, etc) rows in this table correspond to rows in zvals variable above
- `stim_lookup`: a cell of size ntrials, i.e., 1000 of names of the presented images (e.g., wild\_animals\_6) entries correspond to the columns in zvals variable above
- `cat_lookup`: a cell of size ntrials, i.e., 1000 of names of the category the images belong to entries correspond to the columns in zvals variable above

### `category_responses.mat`
Containes whether a stimulus elicited a neuronal response for each unit-stimulus combination. 

- `consider_rs`: a nunits X nstimuli matrix of booleans that have the value 'true' if a stimulus elicits a response according to the criterion mentionen in the paper
- `pvals_rs`: a nunits X nstimuli matrix of p-values resulting from the binwise signed rank test mention in the paper
- `pcrit_rs`: the alpha-level at which the binwise ranksum test is considered 'significant'
- `cluster_lookup`: a table with nunits rows and 8 columns with infos on the units (such as anatomical location, SU vs. MU, etc) rows in this table correspond to rows in zvals variable above
- `stim_lookup`: a cell of size nstimuli, i.e., 100 of names of the presented images (e.g., wild\_animals\_6) entries correspond to the columns in the `consider_rs` and `pvals_rs` variables above
- `cat_lookup`: a cell of size nstimuli, i.el, 100 of names of the category the images belong to entries correspond to the columns in `consider_rs` and `pvals_rs` variables above

### `classification_results_*.mat`
.mat files starting `classification_results` are output produced by the script `ospr_classify.m` mentioned above. For details on the coding anlyses, please refer to the method section of the paper or inspect `ospr_classify.m` and `ospr_doclassperm.m`.


### `regions.mat`
Contains a struct with names of anatomical Regions, i.e., AM, HC, EC, PHC, and the names of electrode localizations (sites) assign to anatomical regions e.g. 

```
regions(1).name = 'AM' % Amygdala
regions(1).sites = {'RA', 'LA'}; % for wires in left and right amygdala
```

Note that data in the .mat files also includes units that are not reported int the paper as the units were recorded in anatomical regions outside the MTL. Such units are identified by:

```
idx = strcmp(cluster_lookup.regionname == 'other');
```


  