clear, clc, close all

[datarp, resultrp] = CLARITYrootpath();
inputrp = fullfile(datarp, '150626_v138_08x2sh1sp9090p200s_15-43-41-masked', 'ch0');
maskrp = fullfile(resultrp, 'mask-v138');
qvrp = fullfile(inputrp, 'quickview');
mkdir(qvrp);

load(fullfile(maskrp, 'index.mat'));
imgfiles = dir(fullfile(inputrp, '/*.tif'));

%% Read files
imgfilename = imgfiles(1).name;
thisfile = fullfile(inputrp, imgfilename);
tifobj = Tiff(thisfile,'r');
img = tifobj.read();
tifobj.close();
[rr, cc] = size(img);
% imgstack = zeros(rr, cc, length(imgfiles));

tic;
matlabpool('open', 12);
matlabpool('size')
parfor ii = 1 : length(imgfiles)
    disp(ii)
    imgfilename = imgfiles(ii).name;
    thisfile = fullfile(inputrp, imgfilename);
    tifobj = Tiff(thisfile,'r');
    img = tifobj.read();
    tifobj.close();
    
%     disp(max(img(:)))
%     img = double(img) / 65535;
%     imgstack(:, :, ii) = img;
    
    thr = 0.6;
    img = double(img) / 65535 / thr;
    img(img > thr) = 1;
    imwrite(img, fullfile(qvrp, imgfilename));
end
matlabpool('close');
toc

%% Save mat file
% matname = 'v138_ch0.mat';
% save(fullfile(inputrp, matname), 'imgstack', '-v7.3');

% imgstack_idxmasked = imgstack(rrmin:rrmax, ccmin:ccmax, zzmin:zzmax);
% matname = 'v138_ch0_masked_idxmasked.mat';
% save(fullfile(inputrp, matname), 'imgstack_idxmasked', '-v7.3');

%% Downsample and save downsampled file
% downratioarr = [2, 3, 4];
% for ii = 1 : length(downratioarr)
%     disp(ii)
%     downratio = downratioarr(ii);
%     [rr, cc, zz] = size(imgstack);
%     rridx = rrmin : downratio : rrmax;
%     ccidx = ccmin : downratio : ccmax;
%     zzidx = zzmin : downratio : zzmax;
%     imgstackdown = imgstack(rridx, ccidx, zzidx);
%     
%     % Save mat file
%     matname = ['v138_ch0_masked_down' num2str(downratio) '.mat'];
%     save(fullfile(inputrp, matname), 'imgstackdown', '-v7.3');
% 
%     % Save nii file
%     niiname = ['v138_ch0_masked_down' num2str(downratio) '.nii'];
%     nii = make_nii(imgstackdown, [0.001, 0.001, 0.001]); % voxel size not real resolution
%     save_nii(nii, fullfile(inputrp, niiname));
% end
