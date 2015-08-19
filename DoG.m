function DoGker = DoG(sigma)
halfsize = ceil(3 * sigma);
x = -halfsize : halfsize;
DoGker = -x .* exp(-x.*x / 2 / sigma / sigma) / sigma^3 / sqrt(2 * pi);
end