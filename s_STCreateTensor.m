clear, clc, close all

[datarp, resultrp] = CLARITYrootpath();
tensorrp = fullfile(resultrp, 'tensor-v138');
mkdir(tensorrp)

tic
load(fullfile(resultrp, 'mask-v138', 'maskstack.mat'));
toc

gradientrp = fullfile(resultrp, 'gradient-v138', 'ch0');
tic
matname = ['v138_ch0_idxmasked_gradientrr_sigma' num2str(sigma) '.mat'];
load(fullfile(gradientrp, matname));
toc

tic
matname = ['v138_ch0_idxmasked_gradientcc_sigma' num2str(sigma) '.mat'];
load(fullfile(gradientrp, matname));
toc

tic
matname = ['v138_ch0_idxmasked_gradientzz_sigma' num2str(sigma) '.mat'];
load(fullfile(gradientrp, matname));
toc

load(fullfile(resultrp, 'mask-v138', 'index.mat'))
idxmaskedszrr = rrmax - rrmin + 1;
idxmaskedszcc = ccmax - ccmin + 1;
idxmaskedszzz = zzmax - zzmin + 1;
idxmaskedsz = [idxmaskedszrr, idxmaskedszcc, idxmaskedszzz];

%%
downratioarr = [4];
sigma = 1.3;
halfsz = ceil(3*sigma);
fullsz = 2 * halfsz + 1;
Gker3d = G3d(sigma);

tic;
matlabpool('open', 12);
matlabpool('size')
for ii = 1 : length(downratioarr)
    downratio = downratioarr(ii);
    mask = false(size(maskstack));
    
    rridx = rrmin : downratio : rrmax;
    ccidx = ccmin : downratio : ccmax;
    zzidx = zzmin : downratio : zzmax;
    mask(rridx, ccidx, zzidx) = true;
    mask = and(mask, maskstack);
    clear maskstack
    
    idx1d = find(mask);
    [idx3drr, idx3dcc, idx3dzz] = ind2sub(size(mask), idx1d);
    
    tensor = zeros(length(idx1d), 6);
    fa = zeros(length(idx1d), 1);
    md = zeros(length(idx1d), 1);
    v1 = zeros(length(idx1d), 3);
    v2 = zeros(length(idx1d), 3);
    v3 = zeros(length(idx1d), 3);
    e1 = zeros(length(idx1d), 1);
    e2 = zeros(length(idx1d), 1);
    e3 = zeros(length(idx1d), 1);
    
    parfor jj = 1 : length(idx1d)
        rr = idx3drr(jj);
        cc = idx3dcc(jj);
        zz = idx3dzz(jj);
        
        rrwin = rr - halfsz : rr + halfsz;
        ccwin = cc - halfsz : cc + halfsz;
        zzwin = zz - halfsz : zz + halfzz;
        
        % Memory might be not enough to store the gradient product
        gradrrvol = gradientrr(rrwin, ccwin, zzwin);
        gradccvol = gradientcc(rrwin, ccwin, zzwin);
        gradzzvol = gradientzz(rrwin, ccwin, zzwin);
        
        gradprod1 = gradrrvol .* gradrrvol .* Gker3d;
        gradprod2 = gradrrvol .* gradccvol .* Gker3d;
        gradprod3 = gradrrvol .* gradzzvol .* Gker3d;
        gradprod4 = gradccvol .* gradccvol .* Gker3d;
        gradprod5 = gradccvol .* gradzzvol .* Gker3d;
        gradprod6 = gradzzvol .* gradzzvol .* Gker3d;
        
        t1 = sum(gradprod1(:));
        t2 = sum(gradprod2(:));
        t3 = sum(gradprod1(:));
        t4 = sum(gradprod1(:));
        t5 = sum(gradprod1(:));
        t6 = sum(gradprod1(:));
        
        tensor(jj, :) = [t1, t2, t3, t4, t5, t6];
        thistensor = [t1, t2, t3, ...
                      t2, t4, t5, ...
                      t3, t5, t6];
        
        [V, D] = eig(thistensor);
        D = sum(D, 1); % transform eignvalues to a vector 
        [tmp, idx] = sort(D, 'descend');
        v1(jj, :) = V(:, idx(1));
        v2(jj, :) = V(:, idx(2));
        v3(jj, :) = V(:, idx(3));
        
        e1(jj) = D(idx(1));
        e2(jj) = D(idx(2));
        e3(jj) = D(idx(3));
        
        md(jj) = mean(D);
        fa(jj) = sqrt(sum(diff([D, D(1)]).^2) / sum(D.^2) / 2); % fractional anisotropy    
    end
    
    % Save files
    % tensor
    tensorvol = transform2vol(tensor, idx3drr, idx3dcc, idx3dzz, rrmin, ccmin, zzmin, idxmaskedsz);
    niiname = ['v138_ch0_masked_tensor_down' num2str(downratio) '_sigma' num2str(sigma) '.nii'];
    nii = make_nii(tensorvol, [0.001*downratio, 0.001*downratio, 0.001*downratio]); % voxel size not real resolution
    save_nii(nii, fullfile(tensorrp, niiname));
    clear tensorvol
    
    % fa
    favol = transform2vol(fa, idx3drr, idx3dcc, idx3dzz, rrmin, ccmin, zzmin, idxmaskedsz);
    niiname = ['v138_ch0_masked_fa_down' num2str(downratio) '_sigma' num2str(sigma) '.nii'];
    nii = make_nii(favol, [0.001*downratio, 0.001*downratio, 0.001*downratio]); % voxel size not real resolution
    save_nii(nii, fullfile(tensorrp, niiname));
    clear favol
    
    % md
    mdvol = transform2vol(md, idx3drr, idx3dcc, idx3dzz, rrmin, ccmin, zzmin, idxmaskedsz);
    niiname = ['v138_ch0_masked_md_down' num2str(downratio) '_sigma' num2str(sigma) '.nii'];
    nii = make_nii(mdvol, [0.001*downratio, 0.001*downratio, 0.001*downratio]); % voxel size not real resolution
    save_nii(nii, fullfile(tensorrp, niiname));
    clear mdvol
    
    % v1
    v1vol = transform2vol(v1, idx3drr, idx3dcc, idx3dzz, rrmin, ccmin, zzmin, idxmaskedsz);
    niiname = ['v138_ch0_masked_v1_down' num2str(downratio) '_sigma' num2str(sigma) '.nii'];
    nii = make_nii(v1vol, [0.001*downratio, 0.001*downratio, 0.001*downratio]); % voxel size not real resolution
    save_nii(nii, fullfile(tensorrp, niiname));
    clear v1vol
    
    % v2
    v2vol = transform2vol(v2, idx3drr, idx3dcc, idx3dzz, rrmin, ccmin, zzmin, idxmaskedsz);
    niiname = ['v238_ch0_masked_v2_down' num2str(downratio) '_sigma' num2str(sigma) '.nii'];
    nii = make_nii(v2vol, [0.001*downratio, 0.001*downratio, 0.001*downratio]); % voxel size not real resolution
    save_nii(nii, fullfile(tensorrp, niiname));
    clear v2vol

    % v3
    v3vol = transform2vol(v3, idx3drr, idx3dcc, idx3dzz, rrmin, ccmin, zzmin, idxmaskedsz);
    niiname = ['v338_ch0_masked_v3_down' num2str(downratio) '_sigma' num2str(sigma) '.nii'];
    nii = make_nii(v3vol, [0.001*downratio, 0.001*downratio, 0.001*downratio]); % voxel size not real resolution
    save_nii(nii, fullfile(tensorrp, niiname));
    clear v3vol
    
    % e1
    e1vol = transform2vol(e1, idx3drr, idx3dcc, idx3dzz, rrmin, ccmin, zzmin, idxmaskedsz);
    niiname = ['e138_ch0_masked_e1_down' num2str(downratio) '_sigma' num2str(sigma) '.nii'];
    nii = make_nii(e1vol, [0.001*downratio, 0.001*downratio, 0.001*downratio]); % voxel size not real resolution
    save_nii(nii, fullfile(tensorrp, niiname));
    clear e1vol

    % e2
    e2vol = transform2vol(e2, idx3drr, idx3dcc, idx3dzz, rrmin, ccmin, zzmin, idxmaskedsz);
    niiname = ['e238_ch0_masked_e2_down' num2str(downratio) '_sigma' num2str(sigma) '.nii'];
    nii = make_nii(e2vol, [0.001*downratio, 0.001*downratio, 0.001*downratio]); % voxel size not real resolution
    save_nii(nii, fullfile(tensorrp, niiname));
    clear e2vol

    % e3
    e3vol = transform2vol(e3, idx3drr, idx3dcc, idx3dzz, rrmin, ccmin, zzmin, idxmaskedsz);
    niiname = ['e338_ch0_masked_e3_down' num2str(downratio) '_sigma' num2str(sigma) '.nii'];
    nii = make_nii(e3vol, [0.001*downratio, 0.001*downratio, 0.001*downratio]); % voxel size not real resolution
    save_nii(nii, fullfile(tensorrp, niiname));
    clear e3vol
    
end
matlabpool('close');
toc

%% Save tensor file


