clear, clc, close all

[datarp, resultrp] = CLARITYrootpath();
maskrp = fullfile(resultrp, 'mask-v138');
mkdir(maskrp);

oriimgrp = fullfile(datarp, '150626_v138_08x2sh1sp9090p200s_15-43-41', 'ch0');
maskimgrp = fullfile(datarp, '150626_v138_08x2sh1sp9090p200s_15-43-41-masked', 'ch0');

oriimgfiles = dir([oriimgrp, '/*.tif']);
maskimgfiles = dir([maskimgrp, '/*.tif']);

if length(oriimgfiles) ~= length(maskimgfiles)
    error('Number of original and masked images do not match!');
end

imgfilename = oriimgfiles(1).name;
thisfile = fullfile(oriimgrp, imgfilename);
tifobj = Tiff(thisfile,'r');
img = tifobj.read();
tifobj.close();
[rr, cc] = size(img);
maskstack = false(rr, cc, length(oriimgfiles));

rrmaxarr = zeros(1, length(oriimgfiles));
rrminarr = zeros(1, length(oriimgfiles));
ccmaxarr = zeros(1, length(oriimgfiles));
ccminarr = zeros(1, length(oriimgfiles));
countvox = zeros(1, length(oriimgfiles));

tic;
matlabpool('open', 12);
matlabpool('size')
parfor ii = 1 : length(oriimgfiles)
    disp(ii)
    imgfilename = oriimgfiles(ii).name;
    oriimg = imread(fullfile(oriimgrp, imgfilename));
    
    imgfilename = maskimgfiles(ii).name;
    maskimg = imread(fullfile(maskimgrp, imgfilename));
    
    diffimg = oriimg - maskimg;
    mask = diffimg == 0;
    
    maskstack(:, :, ii) = mask;
    imwrite(mask, fullfile(maskrp, imgfilename));

    [rr, cc] = find(mask);
    if ~isempty(rr)
        rrmaxarr(ii) = max(rr);
        rrminarr(ii) = min(rr);
    end
    if ~isempty(cc)
        ccmaxarr(ii) = max(cc);
        ccminarr(ii) = min(cc);
    end
    countvox(ii) = sum(mask(:));
end
matlabpool('close');
toc

%%
masksz.rrmax = max(rrmaxarr);
tmp = unique(rrminarr);
masksz.rrmin = tmp(2);
masksz.ccmax = max(ccmaxarr);
tmp = unique(ccminarr);
masksz.ccmin = tmp(2);
masksz.zzmax = find(countvox, 1, 'last' );
masksz.zzmin = find(countvox, 1 );
masksz.totalvox = sum(countvox);

%%
save(fullfile(resultrp, 'mask-v138', 'masksz.mat'), 'masksz');
save(fullfile(resultrp, 'mask-v138', 'maskstack.mat'), 'maskstack', '-v7.3');



















