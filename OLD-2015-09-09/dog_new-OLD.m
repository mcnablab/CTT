function k_dog = dog_new(sigma)
halfsize = ceil(3 * sigma);
x = [-halfsize : halfsize];
k_dog = -x .* exp(-x.*x / 2 / sigma / sigma) / sigma^3 / sqrt(2 * pi);

end
