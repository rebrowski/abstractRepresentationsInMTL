function [positions] = setup_plot(nrows, ncols, gapwidth_h, gapwidth_v, ...
                                         overall_height, overall_width)
%% function [positions] = setup_plot(nrows, ncols, gapwidth_h, gapwidth_v, ...
%                                         overall_height, overall_width)
% use the return arguemnt like this
% subplot('Position', squeeze(positions(row, column, :)));

if nargin < 3
    gapwidth_h = 10;
    gapwidth_v = 15;
end

if ~exist('overall_height', 'var') || isempty(overall_height)
    overall_height = 1;
end

if ~exist('overall_width', 'var') || isempty(overall_width)
    overall_width = 1;
end

h_unit = overall_width/ncols;
h_margin = gapwidth_h*h_unit/100;
v_unit = overall_height/nrows;
v_margin =gapwidth_v*v_unit/100;

for r = 1:nrows
    for c = 1:ncols
      positions(r,c,:) = [(c-1)*h_unit+h_margin ...
                          (r-1)*v_unit+v_margin ...
                          h_unit-2*h_margin ...
                          v_unit-2*v_margin];
      positions2(nrows-r+1,c,:) = positions(r,c,:);
      
    end
end

clear positions;
positions = positions2;
