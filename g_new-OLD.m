function k_g = g_new(sigma, k_sz)
v = [-(k_sz-1)/2 : (k_sz-1)/2];

[X, Y, Z] = meshgrid(v, v, v);
r = sqrt(X.*X + Y.*Y + Z.*Z);
k_g = exp(-r.*r / 2 / sigma / sigma) / sigma / sqrt(2 * pi);
end