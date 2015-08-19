clear, clc, close all

% sigmaArr = [0.5, 1, 1.5, 2, 2.5, 3];
sigmaArr = [0.5, 1];

for ii = 1 : length(sigmaArr)
    sigma = sigmaArr(ii);
    k_dog = dog_new(sigma);
    k_sz = length(k_dog);
    k_g = g_new(sigma, k_sz);
    rr = (k_sz - 1)/2;
    
    load(['fat15_down3_gra_sigma_' num2str(sigma) '.mat'])
    [nx, ny, nz] = size(gx);
    
    graproduct = zeros(nx, ny, nz, 6);
    graproduct(:, :, :, 1) = gx .* gx;
    graproduct(:, :, :, 2) = gx .* gy;
    graproduct(:, :, :, 3) = gx .* gz;
    graproduct(:, :, :, 4) = gy .* gy;
    graproduct(:, :, :, 5) = gy .* gz;
    graproduct(:, :, :, 6) = gz .* gz;
    
    fa = zeros(nx, ny, nz);
    md = zeros(nx, ny, nz);
    v1 = zeros(nx, ny, nz, 3);
    v2 = zeros(nx, ny, nz, 3);
    v3 = zeros(nx, ny, nz, 3);
    e1 = zeros(nx, ny, nz);
    e2 = zeros(nx, ny, nz);
    e3 = zeros(nx, ny, nz);
    tensor = zeros(nx, ny, nz, 6);
    
    for xx = rr + 1 : nx - rr
        for yy = rr + 1 : ny - rr
            for zz = rr + 1 : nz - rr

            [sigma xx, yy, zz]

            startxx = xx - rr;
            endxx = xx + rr;
            startyy = yy - rr;
            endyy = yy + rr;
            startzz = zz - rr;
            endzz = zz + rr;

            gxgx = sum(sum(sum(k_g .* graproduct(startxx : endxx, startyy : endyy, startzz : endzz, 1))));
            gxgy = sum(sum(sum(k_g .* graproduct(startxx : endxx, startyy : endyy, startzz : endzz, 2))));
            gxgz = sum(sum(sum(k_g .* graproduct(startxx : endxx, startyy : endyy, startzz : endzz, 3))));
            gygy = sum(sum(sum(k_g .* graproduct(startxx : endxx, startyy : endyy, startzz : endzz, 4))));
            gygz = sum(sum(sum(k_g .* graproduct(startxx : endxx, startyy : endyy, startzz : endzz, 5))));
            gzgz = sum(sum(sum(k_g .* graproduct(startxx : endxx, startyy : endyy, startzz : endzz, 6))));

            tensor(xx, yy, zz, 1) = gxgx;
            tensor(xx, yy, zz, 2) = gxgy;
            tensor(xx, yy, zz, 3) = gygy;
            tensor(xx, yy, zz, 4) = gxgz;
            tensor(xx, yy, zz, 5) = gygz;
            tensor(xx, yy, zz, 6) = gzgz;

            thistensor = [gxgx, gxgy, gxgz; ...
                          gxgy, gygy, gygz; ...
                          gxgz, gygz, gzgz];
            [V, D] = eig(thistensor); 
            D = sum(D, 1); % transform eignvalues to a vector 
            [tmp, idx] = sort(D, 'descend');

            v1(xx, yy, zz, :) = V(:, idx(1));
            v2(xx, yy, zz, :) = V(:, idx(2));
            v3(xx, yy, zz, :) = V(:, idx(3));

            e1(xx, yy, zz) = D(idx(1));
            e2(xx, yy, zz) = D(idx(2));
            e3(xx, yy, zz) = D(idx(3));

            md(xx, yy, zz) = mean(D);
            fa(xx, yy, zz) = sqrt(sum(diff([D, D(1)]).^2) / sum(D.^2) / 2); % fractional anisotropy
            end
        end
    end
    
    niiname = ['fat15_down3_fa_sigma_' num2str(sigma) '.nii'];
    nii = make_nii(fa);
    save_nii(nii, niiname);
    
    niiname = ['fat15_down3_md_sigma_' num2str(sigma) '.nii'];
    nii = make_nii(md);
    save_nii(nii, niiname);
    
    niiname = ['fat15_down3_v1_sigma_' num2str(sigma) '.nii'];
    nii = make_nii(v1);
    save_nii(nii, niiname);
    
    niiname = ['fat15_down3_v2_sigma_' num2str(sigma) '.nii'];
    nii = make_nii(v2);
    save_nii(nii, niiname);
    
    niiname = ['fat15_down3_v3_sigma_' num2str(sigma) '.nii'];
    nii = make_nii(v3);
    save_nii(nii, niiname);
    
    niiname = ['fat15_down3_e1_sigma_' num2str(sigma) '.nii'];
    nii = make_nii(e1);
    save_nii(nii, niiname);
    
    niiname = ['fat15_down3_e2_sigma_' num2str(sigma) '.nii'];
    nii = make_nii(e2);
    save_nii(nii, niiname);
    
    niiname = ['fat15_down3_e3_sigma_' num2str(sigma) '.nii'];
    nii = make_nii(e3);
    save_nii(nii, niiname);
    
    niiname = ['fat15_down3_tensor_sigma_' num2str(sigma) '.nii'];
    nii = make_nii(tensor);
    save_nii(nii, niiname);
end

%%
clear, clc, close all
nii = load_nii('fat15_down3_sigma_1_tensor.nii');
img = nii.img;
[nx, ny, nz, nc] = size(img);
ck = 5;
img_crop = img(ck+1:end-ck,ck+1:end-ck,ck+1:end-ck,:);

niiname = 'fat15_down3_sigma_1_crop_tensor.nii';
nii = make_nii(img_crop);
save_nii(nii, niiname);

%%
clear, clc, close all
nii = load_nii('fat15_down3_ga_sigma_1.nii');
img = nii.img;
[nx, ny, nz] = size(img);
ck = 5;
img_crop = img(ck+1:end-ck,ck+1:end-ck,ck+1:end-ck);

niiname = 'fat15_down3_ga_sigma_1_crop.nii';
nii = make_nii(img_crop);
save_nii(nii, niiname);













