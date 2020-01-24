function [specProfiles, peakFreq] = SpecProfileCalcFun(spec, mask, rois, specAx)
% specProfiles = SpecProfileCalcFun(spec, mask, specAx) calculates the 
%   spectral profiles for all the ROIs in the mask.
% [specProfiles, peakFreq] = SpecProfileCalcFun(spec, mask, specAx) also
%   returns the frequency which has the highest spectral power values for
%   each ROI in peakFreq
% 
% This function can be executed via SpecProfileCalcRun.m
% 
% inputs: 
%   spec: spectral components: 3D matrix [width x height x frequency]
%         The 0Hz component should be removed to conform with standard way
%   mask: 2D double: with ROI IDs [height x width]
%   rois: 1D double: which rois to analyze?
%   specAx: spectral axis: 1D double with the frequency of each spectral
%           component (0 Hz should already be removed)
%
% outputs:
%   specProfiles: 2D double [frequency x ROIs], with the average spectral
%                 power of each ROI for all the frequencies (except 0Hz).
%   peakFreq: 1D double [ROIs] with the frequency at which each the
%             spectral power was highest.
% 
% 
% Leander de Kraker
% 2020-1-21
% 

% Does the spec need transposing (permuting)?
if size(spec, 1) ~= size(mask, 1)
    if size(spec, 1) == size(mask, 2)
        fprintf('permuted spec to enable analysis\n')
        spec = permute(spec, [2 1 3]);
    else
        warning('sizes of spec and mask seem incompatible!')
        return
    end
end

nSpec = size(spec, 3);
nRois = length(rois);

if length(specAx) ~= nSpec
    warning('difference between spectral frequency axis and spec 3rd dimension!')
end

mask3D = repmat(mask, [1 1 nSpec]);

% Retrieve the spectral profiles
specProfiles = zeros(nSpec, nRois);
for i = 1:nRois
    roii = mask == rois(i); 
    npixels = sum(roii(:));
    specProfilei = reshape(spec(mask3D==rois(i)), [npixels, nSpec]);
    specProfiles(:,i) = mean(specProfilei);
end

% Calculate which frequency had the highest spectral power values
[~, peakFreqidx] = max(specProfiles);
peakFreq = specAx(peakFreqidx);


