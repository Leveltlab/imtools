function PP = PPfromMask(Mask, varargin)
% Find contours around 2D ROI mask
% 
% PP = PPfromMask(Mask);
% PP = PPfromMask(Mask, BImg);
% PP = PPfromMask(Mask, BImg, PP);
% 
% Input:
%   Mask (2D double): ROI mask with numbers indicating ROI id at each pixel
%   If BImg is inputted, that image will be used to find the location of
%   brightest pixel in each ROI: the seedpoint location. 
%       If no BImg is inputted, the center of mass of the ROI will be used
%   If PP is inputted, Con and P will be updated with new data.
% 
% Output:
%   PP.Con.x 
%   PP.Con.y
%   PP.P    ([2 x nrois]): x and y coordinates of seedpoint or COM
% 
% See also: PPfromMaskFile, PPModernize
% 
% Leander de Kraker
% 2022-9-23
% 

hasBImg = false;
if exist('varargin', 'var') && nargin >= 2 && ~isempty(varargin{1})
    BImg = varargin{1};
    minval = min(BImg(:));
    hasBImg = true;
end

nROIs = max(Mask(:));

if exist('varargin', 'var') && nargin >= 3
    PP = varargin{2};
    if nROIs ~= PP.Cnt
        warning('number of ROIs in mask is different than in PP! Removing original PP')
        PP = [];
    end
end

PP.Cnt = nROIs;
PP.Con = struct('x', [], 'y', []);
PP.P = [];

for i = 1:nROIs
    maski = double(Mask==i);
    coni = contourc(maski, [0.5 0.5]);
    coni = getcontourlines(coni);
    PP.Con(i).x = coni.x;
    PP.Con(i).y = coni.y;

    if hasBImg % Get ROI probable seedpoint
        BImgi = BImg;
        BImgi(maski==0) = minval;
        [~, PP.P(1,i)] = max(max(BImgi));
        [~, PP.P(2,i)] = max(BImgi(:,PP.P(1,i)));
    end
end

if ~hasBImg %  If BImg not present, get Center Of Mass of Mask ROI
    PP.P = GetRoiCoM(Mask);
end

