function imgstack = imgfileread(rp)
% Function to read in images given a path
%
% (c) Qiyuan Tian, McNab Lab, Stanford University

imgfiles = dir(fullfile(rp, '*.tif'));
imgfilename = imgfiles(1).name;
thisfile = fullfile(rp, imgfilename);
tifobj = Tiff(thisfile,'r');
img = tifobj.read();
tifobj.close();
[rr, cc] = size(img);

imgstack = zeros(rr, cc, length(imgfiles));

disp('*****Start reading images*****');
tic
for ii = 1 : length(imgfiles)
%     disp(ii);
    imgfilename = imgfiles(ii).name;
    thisfile = fullfile(rp, imgfilename);
    tifobj = Tiff(thisfile,'r');
    imgstack(:, :, ii) = tifobj.read();
    tifobj.close();
end
toc
disp('*****End reading images*****');

end