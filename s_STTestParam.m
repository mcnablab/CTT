clear, clc, close all

tmp = load_nii('v138_down5.nii');
imgstack = single(tmp.img);
clear tmp

%%
grr = zeros(size(imgstack), 'single');
gcc = zeros(size(imgstack), 'single');
gzz = zeros(size(imgstack), 'single');

%%
sigma = 1.3; 
dogkernelcol = single(doggen([sigma, sigma]));
dogkernelrow = dogkernelcol';

for ii = 1 : size(imgstack, 3)
    disp(ii)
    img = imgstack(:, :, ii);
    grr(:, :, ii) = conv2(img, dogkernelrow, 'same');
    gcc(:, :, ii) = conv2(img, dogkernelcol, 'same');
end

for ii = 1 : size(imgstack, 1)
    disp(ii)
    img = squeeze(imgstack(ii, :, :));
    gzz(ii, :, :) = conv2(img, dogkernelcol, 'same');
end

%%
gprrrr = grr .* grr;
gprrcc = grr .* gcc;
gprrzz = grr .* gzz;
gpcccc = gcc .* gcc;
gpcczz = gcc .* gzz;
gpzzzz = gzz .* gzz;

ga = sqrt(gprrrr + gpcccc + gpzzzz);
nii = make_nii(ga);
save_nii(nii, ['ga_sigma_' num2str(sigma) '.nii']);

gv = cat(4, grr, gcc, gzz);
gv = gv ./ repmat(ga, [1, 1, 1, 3]);
nii = make_nii(gv);
save_nii(nii, ['gv_sigma_' num2str(sigma) '.nii']);

%%
sigma1 = 1.3;
gausskernel = single(gaussgen([sigma1, sigma1, sigma1]));

gprrrrgauss = convn(gprrrr, gausskernel, 'same');
gprrccgauss = convn(gprrcc, gausskernel, 'same');
gprrzzgauss = convn(gprrzz, gausskernel, 'same');
gpccccgauss = convn(gpcccc, gausskernel, 'same');
gpcczzgauss = convn(gpcczz, gausskernel, 'same');
gpzzzzgauss = convn(gpzzzz, gausskernel, 'same');

%%
tensor = cat(4, gprrrrgauss, gprrccgauss, gprrzzgauss, gpccccgauss, gpcczzgauss, gpzzzzgauss);
tensordtk = cat(4, tensor(:, :, :, 1:2), tensor(:, :, :, 4), ...
                   tensor(:, :, :, 3), tensor(:, :, :, 5:6));

% tensor = cat(4, gprrrr, gprrcc, gprrzz, gpcccc, gpcczz, gpzzzz);
% tensordtk = cat(4, tensor(:, :, :, 1:2), tensor(:, :, :, 4), ...
%                    tensor(:, :, :, 3), tensor(:, :, :, 5:6));
               
nii = make_nii(tensor);
save_nii(nii, 'v138_down5_tensorfsl_gauss.nii');
nii = make_nii(tensordtk);
save_nii(nii, 'v138_down5_tensordtk_gauss.nii');

%%
cmd = 'fslmaths v138_down5_tensorfsl.nii -tensor_decomp v138_down5';
[status,result] = system(cmd);

cmd = 'fslmaths v138_down5_tensorfsl_gauss.nii -tensor_decomp v138_down5_gauss';
[status,result] = system(cmd);

























































