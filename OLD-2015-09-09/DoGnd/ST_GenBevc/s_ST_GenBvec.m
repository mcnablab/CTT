%% s_ST_GenBvec.m
%
% This script is to generate uniform sampling on an unit sphere as b-vector
% using a function from online
%
% http://www.mathworks.com/matlabcentral/fileexchange/37004-uniform-sampling-of-a-sphere
%
% (c) Qiyuan Tian, Stranford, Aug 2015

narr = [10, 20, 30, 40, 50, 60]; 

for ii = 1: length(narr)
    n = narr(ii);
    % generate uniform sampling by calling function 
    [bvec,Tri,~,Ue]=ParticleSampleSphere('N', n); % V is bvec
    fnBvecMat = ['bvec' num2str(n) '.mat'];
    fnBvecTxt = ['bvec' num2str(n) '.txt'];
    % write bvec to file
    dlmwrite(fnBvecTxt, bvec, 'delimiter', ' ');
    save(fnBvecMat, 'bvec');
end