function DoGker = DoGnd(sigma, ratio, dim, X, Y, Z)
halfsize = ceil(3 * sigma);
x = -halfsize : ratio : halfsize; 
if dim == 1
    if ~exist('X', 'var')
        X = x;
    end
    r = X;
elseif dim == 2
    if ~exist('X', 'var') || ~exist('Y', 'var')
        x = -halfsize : ratio : halfsize;
        [X, Y] = meshgrid(x, x);
    end
    r = sqrt(X.*X + Y.*Y);
elseif dim == 3
    if ~exist('X', 'var') || ~exist('Y', 'var') || ~exist('Z', 'var')
        x = -halfsize : ratio : halfsize;
        [X, Y, Z] = meshgrid(x, x, x);
    end
    r = sqrt(X.*X + Y.*Y + Z.*Z);
else
    error('Only support upto dimension 3');
end

DoGker = -X .* exp(-r.^2 / 2 / sigma^2) / sigma^2 / (sigma * sqrt(2 * pi))^dim;
end
