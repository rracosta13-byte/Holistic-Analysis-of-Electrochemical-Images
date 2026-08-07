%% The 'reassign_small_islands' function is used to reassign small objects  
% in each cluster from 'pixel_labels' and reassign them to the nearest
% object in another cluster
%
% Inputs:
% pixel_labels -> Labeled objects in each cluster in the image 'RGB_2pc'.
% maxIslandSize -> If a object in a cluster has a pixel count smaller than this value, it will be reassigned.
% win ->
%
% Outputs:
% window_labels -> window_labels
% Code written by: Rudy R. Acosta, University of Arkansas, 11/8/25


function window_labels = reassign_small_islands(pixel_labels, maxIslandSize, win)
% Reassigns tiny label islands (<= maxIslandSize px) to neighboring objects.
% L : integer label image (values 1..K)
% maxIslandSize : e.g., 4  (will reassign islands of size 1–4)
% win : local vote window (odd), e.g., 3 or 5

K = double(max(pixel_labels(:)));
[M,N] = size(pixel_labels);
ker = ones(win,win,'double'); % kernal size

% Keep only components >= maxIslandSize+1 for each class
Mkeep = false(M,N); % 'false is like zeros but for logicals
for c = 1:K %looping through the nuber of clusters based on pixel_labels
    Mkeep = Mkeep | bwareaopen(pixel_labels==c, maxIslandSize+1, 4); % 8 includes 
    % diagonal connectivity, change to '4' if only side connectivity is
    % needed

    % if your pixel island size is maxIslandSize+1, it will not need to be reassigned
end
Msmall = ~Mkeep;  % pixel islands smaller than maxIslandSize placed in'Msmall' for reassignment

%Local majority voting from kept pixels only
votes = zeros(M,N,K);
for c = 1:K
    % votes come only from  pixels of each cluster 'c' that are biger than maxIslandSize
    votes(:,:,c) = conv2(double((pixel_labels==c) & Mkeep), ker, 'same'); % sliding kernal applied to vote on each pixel
end

[~, RE_local] = max(votes, [], 3);      % winning class per pixel 
% (RE_local (index) -> will use to reassign local majority)
% If no neighbors voted (all zeros), mark as 0 to be handled by fallback:
nvns = sum(votes,3) == 0; %(nvns -> no vote no show)
RE_local(nvns) = 0;

% Initialize output with original labels
window_labels = pixel_labels;

% Reassign small islands to winning vote object
maskLocal = Msmall & ~nvns;
window_labels(maskLocal) = RE_local(maskLocal);

% Pixels with no votes are assigned to nearest object
maskFallback = Msmall & nvns;
if any(maskFallback(:))
    labels_src = zeros(M,N);
    labels_src(Mkeep) = pixel_labels(Mkeep);     % labels present only on kept pixels
    [~, idx] = bwdist(Mkeep);         % linear indices of nearest kept pixel
    window_labels(maskFallback) = labels_src(idx(maskFallback));
end

end
