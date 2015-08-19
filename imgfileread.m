function imgstack = imgfileread(rp, rrsz, ccsz, zzsz)
imgfiles = dir(fullfile(rp, '*.tif'));
imgfilename = imgfiles(1).name;
thisfile = fullfile(rp, imgfilename);
tifobj = Tiff(thisfile,'r');
img = tifobj.read();
tifobj.close();
[rr, cc] = size(img);

if isempty(rrsz)
    rrsz(1) = 1;
    rrsz(2) = rr;
end

if isempty(ccsz)
    ccsz(1) = 1;
    ccsz(2) = cc;
end

if isempty(zzsz)
    zzsz(1) = 1;
    zzsz(2) = length(imgfiles);
else
    imgfiles = imgfiles(zzsz(1):zzsz(2));
end

imgstack = zeros(rrsz(2)-rrsz(1)+1, ccsz(2)-ccsz(1)+1, zzsz(2)-zzsz(1)+1);

if matlabpool('size') == 0
    error('Please enable parallel computing');
end

disp('*****Start reading images*****');

rrmin = rrsz(1);
rrmax = rrsz(2);
ccmin = ccsz(1);
ccmax = ccsz(2);

tic
parfor ii = 1 : zzsz(2) -zzsz(1) + 1
    disp(ii)
    imgfilename = imgfiles(ii).name;
    thisfile = fullfile(rp, imgfilename);
    tifobj = Tiff(thisfile,'r');
    img = tifobj.read();
    tifobj.close();
    
    img = double(img) / 65535.0;
    imgstack(:, :, ii) = img(rrmin:rrmax, ccmin:ccmax);
end
toc
disp('*****End reading images*****');

end