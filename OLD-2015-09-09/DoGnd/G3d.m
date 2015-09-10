function Gker = G3d(sigma)
halfsize = ceil(3 * sigma);
x = -halfsize : halfsize;
[X, Y, Z] = meshgrid(x, x, x);
r = sqrt(X.*X + Y.*Y + Z.*Z);
Gker = exp(-r.*r / 2 / sigma / sigma) / sigma / sqrt(2 * pi);
end