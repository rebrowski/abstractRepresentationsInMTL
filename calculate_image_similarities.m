%%% compute image similarity
impath = 'stimuli';
load category_responses
nimages = numel(stim_lookup);

overwrite = false;
picsimilarityfile = 'ospr_picture_similarity.mat';

if overwrite
    iout = 1;
    %% loop over all image combinations
    for i1 = 1:nimages
        for i2 = i1+1:nimages
            
            im1 = imread([impath, filesep, stim_lookup{i1}, '.jpg']);
            im2 = imread([impath, filesep, stim_lookup{i2}, '.jpg']);
            
            % compute L2, Euclidian Distance        
            R1 = im1(:,:,1); R2 = im2(:,:,1);
            G1 = im1(:,:,2); G2 = im2(:,:,2);
            B1 = im1(:,:,3); B2 = im2(:,:,3);
            s = (R1-R2).^2+(G1-G2).^2+(B1-B2).^2;
            s = s(:);
            d1(iout)= sqrt(sum(s)); % this is euclidean norm
  
            
            % mean squared error
            d2(iout) = immse(im1, im2);
            
            % structural similarity index
            d3(iout) = ssim(im1, im2);
            
            % peak signal to noise
            d4(iout) = psnr(im1, im2);
            
            iout = iout + 1;
        end
        fprintf('%d ', iout);
    end
    
    measurenames = {'euclidian distance', ...
          'mse', ...
          'max(ssim)-ssim', ...
          'max(psnr)-psnr'};
    
    d3 = max(d3)-d3;
    d4 = max(d4)-d4;
    
    save(picsimilarityfile, 'd1', 'd2', 'd3', 'd4', 'measurenames');    
end
