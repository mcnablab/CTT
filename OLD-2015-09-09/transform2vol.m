function output = transform2vol(input, idx3drr, idx3dcc, idx3dzz, ...
                                  rrmin, ccmin, zzmin, idxmaskedsz)
% Modify index
idx3drridxmasked = idx3drr - rrmin + 1;
idx3dccidxmasked = idx3dcc - ccmin + 1;
idx3dzzidxmasked = idx3dzz - zzmin + 1;
idxmaskedlength = idxmaskedsz(1) * idxmaskedsz(2) * idxmaskedsz(3);

idx1didxmasked = sub2ind(idxmaskedsz, idx3drridxmasked, idx3dccidxmasked, idx3dzzidxmasked);

output = zeros(length(rridx), length(ccidx), length(zzidx), size(input, 2));

parfor jj = 1 : size(input, 2)
    input1d = zeros(idxmaskedlength, 1);
    input1d(idx1didxmasked) = input(:, jj);
    input3d = reshape(input1d, idxmaskedsz);
    output(:, :, :, jj) = input3d;
end

output = squeeze(output);
    
end