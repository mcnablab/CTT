clear, clc, close all

[datarp, resultrp] = CLARITYrootpath();
imgrp = fullfile(datarp, '150626_v138_08x2sh1sp9090p200s_15-43-41', 'ch0');
gradientrp = fullfile(resultrp, 'gradient-v138', 'ch0');
mkdir(gradientrp);

if matlabpool('size') == 0
    matlabpool('open', 12);
end

load(fullfile(resultrp, 'mask-v138', 'masksz.mat'));
sigmaarr = [1.3];

%%
tic % 3min
% load(fullfile(imgrp, 'v138_ch0.mat'));
imgstack = imgfileread(imgrp, [masksz.rrmin, masksz.rrmax], [], []);
toc

[imgstackszrr, imgstackszcc, imgstackszzz]=size(imgstack);

if matlabpool('size') ~= 0
    matlabpool('close');
end

%%
gradientcc = zeros(500, imgstackszcc, imgstackszzz);
gradientzz = zeros(500, imgstackszcc, imgstackszzz);

tic
for ii = 1 : length(sigmaarr)
    sigma = sigmaarr(ii); 
    DoGkerrow = DoG(sigma);
    DoGkercol = DoGkerrow';

    for rr = 1 : 500
        disp(rr);
        img = squeeze(imgstack(rr, :, :));
        gradientcc(rr, :, :) = conv2(img, DoGkercol, 'same');
        gradientzz(rr, :, :) = conv2(img, DoGkerrow, 'same');
    end
end
toc

tic
gradientcc = gradientcc(:, masksz.ccmin:masksz.ccmax, masksz.zzmin:masksz.zzmax);
gradientzz = gradientzz(:, masksz.ccmin:masksz.ccmax, masksz.zzmin:masksz.zzmax);
toc

matname = ['v138_ch0_idxmasked_gradientcc_sigma' num2str(sigma) '.mat'];
save(fullfile(gradientrp, matname), 'gradientcc', '-v7.3');

matname = ['v138_ch0_idxmasked_gradientzz_sigma' num2str(sigma) '.mat'];
save(fullfile(gradientrp, matname), 'gradientzz', '-v7.3');

%%


%%
clear imgstack gradientcc gradientzz

tic % 3min
% load(fullfile(imgrp, 'v138_ch0.mat'));
imgstack = imgfileread(imgrp, [], [masksz.ccmin, masksz.ccmax], []);
toc

gradientrr = zeros(size(imgstack));

tic
for ii = 1 : length(sigmaarr)
    sigma = sigmaarr(ii); 
    DoGkerrow = DoG(sigma);
    DoGkercol = DoGkerrow';
    
    for cc = 1 : size(imgstack, 2)
        disp(cc);
        img = squeeze(imgstack(:, cc, :));
        gradientrr(:, cc, :) = conv2(img, DoGkercol, 'same');
    end
end
toc

gradientrr = gradientrr(masksz.rrmin:masksz.rrmax, :, masksz.zzmin:masksz.zzmax);

matname = ['v138_ch0_idxmasked_gradientrr_sigma' num2str(sigma) '.mat'];
save(fullfile(gradientrp, matname), 'gradientrr', '-v7.3');


