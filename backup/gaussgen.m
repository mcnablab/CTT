function k = gaussgen(sigma)

halfsize = ceil(3 * max(sigma));
x = -halfsize : halfsize;

dim = length(sigma);

if dim == 1
    k = exp(-x.^2 / (2 * sigma^2));
    
elseif dim == 2
    [X, Y] = meshgrid(x, x);
    k = exp(-X.^2 / (2 * sigma(1)^2)) .* exp(-Y.^2 / (2 * sigma(2)^2)); 
    
elseif dim == 3
    [X, Y, Z] = meshgrid(x, x, x);
    k = exp(-X.^2 / (2 * sigma(1)^2)) .* exp(-Y.^2 / (2 * sigma(2)^2)) .* exp(-Z.^2 / (2 * sigma(3)^2));
    
else
    error('Only support upto dimension 3');

end

% k = k / sum(abs(k(:)));

end