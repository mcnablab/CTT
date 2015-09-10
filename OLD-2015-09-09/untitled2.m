clear, clc, close all
matlabpool('open', 12);
matlabpool('size')

r = zeros(4, 5, 10);
parfor ii = 1:10
   r(:, :, ii) = ones(4, 5);
end

matlabpool('close');
