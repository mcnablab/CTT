% s_AxonalRecon.m
%
% This script is used to compute the structure tensor from the downsampled
% CLARITY data ( to deal with the PSF in Z) and use Trackvis to reconstrut
% the axons.
%
% Input the absolute directory of the data (e.g. ch0) that contains all the
% raw images. 
%
% Change the parameters for the structure tensor calculations and axon
% reconstruction.
%
% (c) Qiyuan Tian, McNab Lab, Stanford University
% September 9 2015

clear, clc, close all

rp = fileparts(which('s_AxonalRecon.m')); % root path\
addpath(genpath('NiftiToolbox'));

%% Input parameters
datapathArr = {'E:\sample\v0909_138_5ds'}; %absolute paths of the downsampled CLARITY data
dogsigmaArr = [1.3]; % sigma values used for the derivitive of gaussian filter to detect gradient
gausigmaArr = [1.3]; % sigma values used for the Gaussian filer to blur the structure tensors


%% Compute structure tensor
for ii = 1 : length(datapathArr)
    thisdp = datapathArr{ii};
    [path, fn, ext] = fileparts(thisdp);
    
    imgstack = imgfileread(thisdp); % read image stack
    imgstack = single(imgstack);
    save_nii(make_nii(imgstack), fullfile(thisdp, [fn '.nii']));
    
    if ~isempty(fullfile(thisdp, 'mask'));
        maskstack = imgfileread(fullfile(thisdp));
        maskstack = single(maskstack);
        save_nii(make_nii(maskstack), fullfile(thisdp, [fn '_mask.nii']));
    end
    
    
    for jj = 1 : length(dogsigmaArr)
        thisdogsigma = dogsigmaArr(jj);
        disp(['*****Start DoG Sigma ' num2str(thisdogsigma) '*****']);
        
        %% Generate dog kernel
        dogkercc = single(doggen([thisdogsigma, thisdogsigma, thisdogsigma]));
        % figure, plotdog3d(dogkercc);
        dogkerrr = permute(dogkercc, [2, 1, 3]);
        % figure, plotdog3d(dogkerrr);
        dogkerzz = permute(dogkercc, [1, 3, 2]);
        % figure, plotdog3d(dogkerzz);
        
        %% Compute gradients
        % gradients
        grr = convn(imgstack, dogkerrr);
        gcc = convn(imgstack, dogkercc);
        gzz = convn(imgstack, dogkerzz);
        
        % gradient products
        gprrrr = grr .* grr;
        gprrcc = grr .* gcc;
        gprrzz = grr .* gzz;
        gpcccc = gcc .* gcc;
        gpcczz = gcc .* gzz;
        gpzzzz = gzz .* gzz;
        
        % gradient amplitude
        ga = sqrt(gprrrr + gpcccc + gpzzzz);
        save_nii(make_nii(ga), fullfile(thisdp, [fn '_ga_dogsig' num2str(thisdogsigma) '.nii']));

        % gradient vectors
        gv = cat(4, grr, gcc, gzz);
        gv = gv ./ repmat(ga, [1, 1, 1, 3]);
        save_nii(make_nii(gv), fullfile(thisdp, [fn '_gv_dogsig' num2str(thisdogsigma) '.nii']));
        
        %% Compute tensor
        for kk = 1 : length(gausigmaArr)
            thisgausigma = gausigmaArr(kk);
            disp(['*****Start Gauss Sigma ' num2str(thisgausigma) '*****']);

            gaussker = single(gaussgen([thisgausigma, thisgausigma, thisgausigma]));
            
            gprrrrgauss = convn(gprrrr, gaussker, 'same');
            gprrccgauss = convn(gprrcc, gaussker, 'same');
            gprrzzgauss = convn(gprrzz, gaussker, 'same');
            gpccccgauss = convn(gpcccc, gaussker, 'same');
            gpcczzgauss = convn(gpcczz, gaussker, 'same');
            gpzzzzgauss = convn(gpzzzz, gaussker, 'same');
            
            tensorfsl = cat(4, gprrrrgauss, gprrccgauss, gprrzzgauss, gpccccgauss, gpcczzgauss, gpzzzzgauss);
            fntensorfsl = [fn '_tensorfsl_dogsig' num2str(thisdogsigma) '_gausig' num2str(thisgausigma) '.nii'];
            save_nii(make_nii(tensorfsl), fullfile(thisdp, fntensorfsl));

            tensordtk = cat(4, tensorfsl(:, :, :, 1:2), tensorfsl(:, :, :, 4), tensorfsl(:, :, :, 3), tensorfsl(:, :, :, 5:6));
            fntensordtk = [fn '_tensordtk_dogsig' num2str(thisdogsigma) '_gausig' num2str(thisgausigma) '_tensor.nii'];
            save_nii(make_nii(tensordtk), fullfile(thisdp, fntensordtk));
        end % gausigma        
    end % dogsigma
end % datapath

%% Track
angle = 15; % degree

for ii = 1 : length(datapathArr)
    thisdp = datapathArr{ii};
    [path, fn, ext] = fileparts(thisdp);
    
    for jj = 1 : length(dogsigmaArr)
        thisdogsigma = dogsigmaArr(jj);
        disp(['*****Start DoG Sigma ' num2str(thisdogsigma) '*****']);
        
        fnga = [fn '_ga_dogsig' num2str(thisdogsigma) '.nii'];
        tmp = load_nii(fullfile(thisdp, fnga));
        ga = tmp.img;
        galow = prctile(ga(:), 1);
        gahigh = prctile(ga(:), 99);
        
        for kk = 1 : length(gausigmaArr)
            thisgausigma = gausigmaArr(kk);
            disp(['*****Start Gauss Sigma ' num2str(thisgausigma) '*****']);
            
            cd(thisdp)

            fntensordtk = [fn '_tensordtk_dogsig' num2str(thisdogsigma) '_gausig' num2str(thisgausigma)];
            cmd = ['E:/TrackingTools/DiffusionToolkit/dti_tracker.exe ' fntensordtk ' ' fntensordtk '.trk -at ' num2str(angle) ' -v3 -m '...
                fnga ' ' num2str(galow) ' ' num2str(gahigh)];
            [status,result] = system(cmd);

            cd(rp)
        end % gausigma        
    end % dogsigma
end % datapath
























































