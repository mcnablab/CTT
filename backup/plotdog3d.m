function plotdog3d(dogkernel3d)

sz = size(dogkernel3d, 1);

x = -(sz - 1)/2 : (sz - 1)/2;
[X, Y, Z] = meshgrid(x, x, x);

contourslice(X, Y, Z, dogkernel3d, x, x, x);

xlabel('X (cc)')
ylabel('Y (rr)')
zlabel('Z (zz)')
view([-20,25]);

colorbar
set(gca,'Color','k');
set(gcf, 'InvertHardCopy', 'off');
axis vis3d;
end