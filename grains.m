%% Grains:
% This function takes the clusters that have been sectioned from the
% variable 'pixel labels' and places each unique cluster into an individual
% cell. Here it is still possible for a cluster to have multiple objects,
% they will be separated in another function 'mask_split_objects'
%
% Input 
% unique_clusters -> number of clusters identified based on color from the
% RGB image
% pixel_lables -> xy coordnates of where those clusters are located
% RGB_8 -> RGB image made from PC1-PC3
%
% Output
% G_MASK -> each cluster split into an individual cell
%
%Code written by: Rudy R. Acosta, University of Arkansas, 08/15/24


function G_MASK = grains(unique_clusters, window_labels, RGB_8)
% Initialize cell array to store masks
num_clusters = length(unique_clusters);
G_MASK = cell(1, num_clusters);

% Loop through each cluster
for i = 1:num_clusters
    % Create mask for the current cluster
    cluster = window_labels == unique_clusters(i);
    G_MASK{i} = RGB_8 .* uint8(cluster);
  
    % Plot the mask
    figure('Position', [0, 0, 750, 700]);    
    imagesc(G_MASK{i});
    title(['Objects in Cluster ', num2str(unique_clusters(i))]);
    set(gca, 'XTick',[], 'XTickLabel', [],'YTick',[], 'YTickLabel', []);
end

end
