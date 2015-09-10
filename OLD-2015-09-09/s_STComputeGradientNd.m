clear, clc, close all

[datarp, resultrp] = CLARITYrootpath();
maskrp = fullfile(resultrp, 'mask-v138');
gradientndrp = fullfile(resultrp, 'gradientnd-v138');
imgrp = fullfile(datarp, '150626_v138_08x2sh1sp9090p200s_15-43-41', 'ch0');
mkdir(gradientndrp)

if matlabpool('size') == 0
    matlabpool('open', 12);
end

tic
% load(fullfile(maskrp, 'maskstack.mat'));
maskstack = maskfileread(maskrp, [], [], []);
toc

%%
load(fullfile(resultrp, 'mask-v138', 'masksz.mat'))
idxmaskedszrr = masksz.rrmax - masksz.rrmin + 1;
idxmaskedszcc = masksz.ccmax - masksz.ccmin + 1;
idxmaskedszzz = masksz.zzmax - masksz.zzmin + 1;
idxmaskedsz = [idxmaskedszrr, idxmaskedszcc, idxmaskedszzz];

%%
load('DoGbank_dim3_sigma1.3_bvec34.mat');

%%
downratioarr = [5];
sigma = DoGbank.sigma;
bankvec = DoGbank.DoGbankvec;
halfsz = ceil(3*sigma);
fullsz = 2 * halfsz + 1;

%%
tic;
for ii = 1 : length(downratioarr)
    downratio = downratioarr(ii);
    mask = false(size(maskstack));
    
    rridx = masksz.rrmin : downratio : masksz.rrmax;
    ccidx = masksz.ccmin : downratio : masksz.ccmax;
    zzidx = masksz.zzmin : downratio : masksz.zzmax;
    mask(rridx, ccidx, zzidx) = true;
    mask = and(mask, maskstack);
    clear maskstack
    
    if ~exist('imgstack', 'var')
        tic
        imgstack = imgfileread(imgrp, [], [], []);
        toc
    end

    idx1d = find(mask);
    [idx3drr, idx3dcc, idx3dzz] = ind2sub(size(mask), idx1d);
    
    gradientnd = zeros(length(idx1d), size(DoGbank.DoGbankvec, 2));
    
    parfor jj = 1 : length(idx1d)
        rr = idx3drr(jj);
        cc = idx3dcc(jj);
        zz = idx3dzz(jj);
        
        rrwin = rr - halfsz : rr + halfsz;
        ccwin = cc - halfsz : cc + halfsz;
        zzwin = zz - halfsz : zz + halfzz;
        
        % Memory might be not enough to store the gradient product
        imgvol = imgstack(rrwin, ccwin, zzwin);
        imgvec = imgvol(:);
        gradientnd(jj, :) = imgvec' * bankvec;
    end
    
    % Save files
    tensorvol = transform2vol(tensor, idx3drr, idx3dcc, idx3dzz, rrmin, ccmin, zzmin, idxmaskedsz);
    
    niiname = ['v138_ch0_masked_tensor_down' num2str(downratio) '_sigma' num2str(sigma) '.nii'];
    nii = make_nii(tensorvol, [0.001*downratio, 0.001*downratio, 0.001*downratio]); % voxel size not real resolution
    save_nii(nii, fullfile(tensorrp, niiname));
    clear tensorvol
    
    
end
matlabpool('close');
toc

%% Save tensor file


