%% Grain_avg:
% This function calculates the average current response for each grain 
% across all potential values, using the masked data from NEWEDIT.
% The 2D grain masks from G_MASK_single_objects are expanded to 3D to match
% the dimensions of the dataset (3D array of current responses for each potential).
% The function computes the average current response across all applied potentials 
% for each grain, ignoring NaN values in the process.
%
% Code written by: Rudy R. Acosta, University of Arkansas, 08/15/24
%
% Inputs:
% G_MASK_single_objects -> A cell array where each cell contains a binary mask 
%                          representing a single grain (2D mask).
% NEWEDIT -> 3D array of CV data, where each slice along the third dimension 
%            corresponds to the current responses for different applied potentials.
%
% Output:
% avg_g_all -> A cell array where each cell contains the average current response 
%              for a corresponding grain across all applied potentials.

function avg_g_all = grain_avg(G_MASK_single_objects, Voltametric_Data_LR, grain_number, EDITCYCLE, score_cell)
% Initialize cell array to store averages for each grain
avg_g_all = cell(1, numel(G_MASK_single_objects));

for i = 1:numel(G_MASK_single_objects)
    % Stack the 2D mask into a 3D mask
    cluster_3d = repmat(G_MASK_single_objects{i}, [1, 1, size(Voltametric_Data_LR, 3)]);
    
    % Apply the 2d mask to the 3D array 
    cluster_crystal = rot90(Voltametric_Data_LR);
    cluster_crystal(~cluster_3d) = 0;

    % Reshape and compute average, handling NaNs
    crystal_num = reshape(cluster_crystal,[size(Voltametric_Data_LR,1)*size(Voltametric_Data_LR,2) size(Voltametric_Data_LR,3)]);
    crystal_num(crystal_num == 0) = NaN;
    avg_g = mean(crystal_num,"omitnan");

    % Store the average for the current grain
    avg_g_all{i} = avg_g;


end

x = size(Voltametric_Data_LR, 1);
y = size(Voltametric_Data_LR, 2);
pc1 = rot90(reshape(-score_cell{1,2}(:, 1), [x, y]));
pc2 = rot90(reshape(-score_cell{1,2}(:, 2), [x, y]));

% Create a new figure for the scatter plot
figure('Position', [0, 0, 850, 700]);

% Cell array to store the masks and colors for each grain
%colors = { '#', '#', '#', '#d46a6a', '#', '#9d87ff', '#', '#00e5ff'}; % You can adjust colors as desired
colors = { '#2ca02c', '#7a0c0c', '#1f77b4', '#a69819', '#ff7f0e', '#d46a6a', '#00e5ff', '#9d87ff'}; % You can adjust colors as desired

% Process each grain and plot the corresponding points in specific order
order = [8, 6, 4, 3, 2, 1, 5, 7]; % Change the order of grains as desired
%order = [5, 7, 2, 3, 4, 6, 1, 8]; % Change the order of grains as desired

totalPoints = 0; % Initialize the counter for total points

% Initialize a variable to store all points already plotted
allPlottedPoints = [];

for i = 1:8
    grain = order(i);
    % Create an eroded version of the mask
    mask_eroded = imerode(G_MASK_single_objects{grain}, strel('disk', 1));
    
    % Extract data points within the eroded mask using the 'find' function
    data_in_interior = [pc1(mask_eroded), pc2(mask_eroded)];
    
    % Extract all data points within the grain's region
    data_grain_region = [pc1(G_MASK_single_objects{grain}), pc2(G_MASK_single_objects{grain})];
    
    % Calculate data points outside of the grain's region
    data_outside_grain = setdiff(data_grain_region, data_in_interior, 'rows');
    
    % Scatter plot of points outside the mask as unfilled circles with the corresponding color
    scatter(data_outside_grain(:, 1), data_outside_grain(:, 2), '+', 'MarkerEdgeColor', colors{grain}, 'SizeData', 100, 'LineWidth', 1.5);
    hold on;

    % Scatter plot of points within the interior of the grain as filled circles with the corresponding color
    scatter(data_in_interior(:, 1), data_in_interior(:, 2), 'o', 'filled', 'MarkerFaceColor', colors{grain}, 'DisplayName', sprintf('Grain %d', grain), 'MarkerFaceAlpha', 0.8, 'SizeData', 150);
    
    % Increment the counter for total points
    totalPoints = totalPoints + size(data_outside_grain, 1) + size(data_in_interior, 1);
    
    % Update the variable with all points already plotted
    allPlottedPoints = unique(cat(1, allPlottedPoints, data_outside_grain, data_in_interior), 'rows');
end

% Scatter plot of points outside all masks as unfilled circles with a black color
data_outside_all_grains = setdiff([pc1(:), pc2(:)], allPlottedPoints, 'rows');
scatter(data_outside_all_grains(:, 1), data_outside_all_grains(:, 2), 'x', 'MarkerEdgeColor', 'k', 'SizeData', 100, 'LineWidth', 1.5);    

%totalPoints = totalPoints + size(data_outside_all_grains, 1);



grid on
set(gca, 'FontSize', 48, 'XTick', [-5, -2.5, 0, 2.5, 5], 'XAxisLocation', 'bottom', 'YAxisLocation', 'left', 'Box', 'on', 'LineWidth', 6);
% xlim([-6 6]);
% ylim([-1.4 1.4]);

xlabel('PC1 Score');
ylabel('PC2 Score');

% Display the total number of points
disp(['Total number of points: ', num2str(totalPoints)]);


    

end
