function DoGbank = DoGbank(sigma, bvec, dim)
halfsize = ceil(3 * sigma);
fullsize = 2*halfsize+1;

x = -halfsize : halfsize; 
[X, Y, Z] = meshgrid(x, x, x);
XYZ = [X(:)'; Y(:)'; Z(:)']; 

idx = find(bvec(:, 1) >= 0);
bvec = bvec(idx, :);
bvec = cat(1, eye(3), bvec); % Add X, Y, Z main axis orientation;

bankname = ['DoGbank_dim' num2str(dim) '_sigma' num2str(sigma) '_bvec' num2str(size(bvec, 1)+1)];
mkdir(bankname);

DoGbankvol = zeros(fullsize, fullsize, fullsize, size(bvec, 1));
DoGbankvec = zeros(fullsize^3, size(bvec, 1)); 
orienDoGker = [1, 0, 0];

for ii = 1 : size(bvec, 1)
    orien = bvec(ii, :);
    rotmtx = vrrotvec2mat(vrrotvec(orienDoGker, orien));
    XYZrot = rotmtx * XYZ;
    Xrot = reshape(XYZrot(1, :), fullsize, fullsize, fullsize);
    Yrot = reshape(XYZrot(2, :), fullsize, fullsize, fullsize);
    Zrot = reshape(XYZrot(3, :), fullsize, fullsize, fullsize);
    
    DoGkerrot = DoGnd(sigma, 1, dim, Xrot, Yrot, Zrot);
    DoGbankvol = DoGkerrot;
    DoGbankvec(:, ii) = DoGkerrot(:);
    
    close all
    pause(0.1)
    xlabel('X')
    ylabel('Y')
    zlabel('Z')
    contourslice(X, Y, Z, DoGkerrot, x, x, x);
    view([-20,25]);
    colorbar
    set(gca,'Color','k');
    set(gcf, 'InvertHardCopy', 'off');
    axis vis3d;
    title(mat2str(orien, 2));
    saveas(gca, [bankname '/DoGbank_' num2str(ii) '_' mat2str(orien, 2) '.png']);
end

% Add averaging filter which is like b0 image
avgker = ones(fullsize, fullsize, fullsize) / fullsize^3;
DoGbankvol = cat(4, avgker, DoGbankvol);
DoGbankvec = cat(2, avgker(:), DoGbankvec);
bvec = cat(1, [0, 0, 0], bvec); 

DoGbank.DoGbankvol = DoGbankvol;
DoGbank.DoGbankvec = DoGbankvec;
DoGbank.sigma = sigma;
DoGbank.dim = dim;
DoGbank.bvec = bvec;

save([bankname '/' bankname '.mat'], 'DoGbank');
fnBvecTxt = [bankname '/bvec' num2str(size(bvec, 1)) '.txt'];
dlmwrite(fnBvecTxt, bvec, 'delimiter', ' ');

% Plot bvec
plot3(bvec(:, 1), bvec(:, 2), bvec(:, 3), '*');
axis equal
axis([-1 1 -1 1 -1 1])
grid on
xlabel('X')
ylabel('Y')
zlabel('Z')
title(['bvec: ' num2str(size(bvec, 1)) ' directions']);
saveas(gca, [bankname '/bvec' num2str(size(bvec, 1)) '.png']);
end