%% Analyze voltametric electrochemical images via principal component analysis (PCA)
% This script processes cyclic voltammetry (CV) data, with key steps 
% including the identification of electrochemical cycles, isolation of 
% meniscus contact points, and application of PCA to analyze the CV data.
%
% Please enter the following information: 
% Pathway to TSV file (line 50)
% offset voltage if applicable, enter 0 if n/a (line 58)
% current conversion, enter 1 to keep at A, enter 1e-9 to change to nA (line 61) 
% number of cycles (line 64) 
% current limit of amplifier (line 67)
% cycle number to analyze (Figure 5 presents data from cycle 4) (line 69)
% line_number_increments (line 71) - This value can be found in the associated (.set) file, 'Waypoints per hop'
%
% In the TSV file, each column represents a variable:
% X coordinate 
% Y coordinate
% Z coordinate
% noise (not used)
% Voltage (V)
% Current (i)
% Line Number
% noise (not used)
% second voltage (not used)
% ? (not used)
%
% Author: Rudy R. Acosta, University of Arkansas, 08/15/24

% Custom Functions 
% 1. **import_raw_data**: raw data is imported into this script as a (.tsv)
%    file, then converted to a (.mat) file for speed
% 2. **SEGMENT_DATA**: Pre-process the .mat dataset, 'data', by transposing the dataset
%    , and identifying start/end segments of the experiment.
% 3. **ISO_CV**: Identify the X, Y, and Z coordinates where CV measurements occurred 
%    and visualize applied potentials of these CVs.
% 4. **removerows**: Refine the coordinates and current response data by trimming unnecessary points
%    making current/XY coodrinate data a 3D array, 'XYI'.
% 5. **extractCycles**: Separate the CV potentials into distinct cycles for further analysis.
% 6. **PC_image_flatten_data**: Perform PCA on the dataset and visualize the results new RGB images.
% 7. **reassign_small_islands**: reassign small (stray objects/pixels 
%     in each cluster and reassign them to the nearest object in another cluster
% 8. **movie**: Generates a movie of each current map in dataset as frames.
% 9. **grains**: Places each unique cluster into a separate cell based on color segmentation.
% 10. **RMSD**: Compute the residuals and Root Mean Square Deviation (RMSD) between the original and PCA datasets,
%    providing insight into reconstruction error.
% 11. **mask_split_objects**: Refine the segmented grain masks, splitting clusters into
%    individual grains.
% 12. **grain_avg**: Calculate the average current response across potentials for each grain.

Filename = '/Users/rudyacosta/Desktop/Manuscript/Figure5.tsv'; %Change this path to wherever your tsv is
% Defines pathway in computer where raw dataset is located
% Data can be found at https://wrap.warwick.ac.uk/id/eprint/143056/

[data] = import_raw_data(Filename);
% 'data' is 'Filename' converted from (.tsv) file to .mat array for speed

% Offset voltage 
VOffset = 0; % recorded in volts

% Current by default is recorded in Amps. 
Curr = 1e-9; % convert to Nanoamps

% Number of cycles per CV 
number_of_cycles = 4; %This value can be found in the
% metadata found in the (.set) file associated with this dataset- 'No. Cycles'

current_limit = -1; % This value is in Nanoamps

view_cycle = 5; % This Value dictates which one of the cycles will be analyzed

line_number_increments = 15; % # of line number changes from one start point to the next start point 
% (and one endpoint to the next endpoint) 
% This value can be found in the metadata 
% (.set) file associated with this dataset - 'Waypoints per hop'

%% Call SEGMENT_DATA function to process the raw dataset and return indices where meniscus contact occurs
% pop-up menu -> For figdure 5 dataset, startpoint is 7 and endpoint is 18
[A,SegmentStartIndices,SegmentEndIndices,input_points]  = SEGMENT_DATA(data,VOffset,Curr);

%% CAll 'ISO_CV' to create a grid of XY coordinates where CVs took place from the dataset
startpoint = str2double(input_points{1,1}); % The point where the meniscus makes its initial contact with the substrate (Line number).
endpoint = str2double(input_points{2,1}); % The point just before the meniscus lifts from the substrate (Line number).

[IsoDataStart, IsoDataEnd, CV_Potentials, MeanX, MeanY, MeanZ] = ISO_CV(A,startpoint,endpoint,line_number_increments,SegmentStartIndices,SegmentEndIndices);

figure;
plot(CV_Potentials);

%% Call 'removerows' to trim the rows from the top and bottom of the grid
% For figure 5 dataset, first row from the top and the bottom 4 are removed
[IsoDataStart, IsoDataEnd, MeanX, MeanY, MeanZ, xSize, ySize, XYI] = removerows(IsoDataStart, IsoDataEnd, MeanX, MeanY, MeanZ, A);

%% Call 'extractCycles' to split CV potentials into individual cycles.
[cyclePotentials, cycleIndices] = extractCycles(CV_Potentials, number_of_cycles);
%%
% 'Unedited_Potentials' are the potentials of the unedited dataset for a single cycle,
% determined by the 'view_cycle' value (line 69)
% 'Unedited_Voltametric_Data' come from the variable 'XYI', the values will
% change depending on the 'view_cycle' value (line 69)
% Final Full CV
Unedited_Potentials=CV_Potentials(cycleIndices{1,view_cycle});
Unedited_Voltametric_Data=XYI(:,:,cycleIndices{1,view_cycle}); 

% Find and remove flatline regions that reach the limit of the current
% amplifier. 'current_limit'(line 67)
limit_break_neg = min(min(Unedited_Voltametric_Data(:,:,1:size(Unedited_Voltametric_Data,3))));
mins_2d = squeeze(limit_break_neg);
remove_points = find(mins_2d == current_limit);

% 'Voltametric_Data_LR' is the almost the same as
% 'Unedited_Voltametric_Data', but with the currents that reach or surpass
% the limt of the amplifer, removed

% Check if 'remove_points' is not empty before removing points
if ~isempty(remove_points)
    % Remove points from 'Unedited_Voltametric_Data'
    Voltametric_Data_LR = Unedited_Voltametric_Data; % LR -> Limits Removed
    Voltametric_Data_LR(:,:,remove_points) = [];
    
    % Remove points from 'Unedited_Potentials'
    CYCLE_With_LR = CV_Potentials(cycleIndices{1,view_cycle});
    CYCLE_With_LR(:,remove_points) = [];
else
    % If 'remove_points' is empty, just keep the original variables
    Voltametric_Data_LR = Unedited_Voltametric_Data;
    CYCLE_With_LR = CV_Potentials(cycleIndices{1,view_cycle});
end
% the variable 'applied_potentials' stores the applied potentials for both
% the original dataset and the dataset with current responses for 20 mV from 
% -0.43 V to -0.45 V omitted.
applied_potentials = {Unedited_Potentials, CYCLE_With_LR};

%% The `PC_image_flatten_data` function is used to perform PCA on the dataset, returning 
% coefficients, scores, variance, and other metrics.
% Figures generated from this function were used to make Figure 4

varnames={Unedited_Voltametric_Data,Voltametric_Data_LR};
q = 2; % 1 is the original dataset, 2 is the edited dataset 
pc = 2;% this value determines which PC is being viewed using the function directly below
apply_median_filter = false;  % Set to false if you don't want to apply the filter

[Flat_cell,coeff_cell,score_cell,latent_cell,tsquared_cell,explained_cell,mu_cell,RGB_2pc,RGB_3pc,X,Y,AverageCVall,cluster_input] = PC_image_flatten_data(apply_median_filter,varnames,q,Voltametric_Data_LR,applied_potentials,pc);

%% Image segmentation of the RGB image (RGB_2pc)
% RGB_2pc represents the the scores of the first 2 principal components.
numColors = str2double(cluster_input{1,1}); % Number of clusters (colors) to segment the image into
L = imsegkmeans(RGB_2pc,numColors);
B = labeloverlay(RGB_2pc,L);
imagesc(B)
title("Labeled Image RGB")

pixel_labels = imsegkmeans(RGB_2pc,numColors,NumAttempts=3);

% Get unique cluster labels
unique_clusters = unique(pixel_labels);

G_MASK = grains(unique_clusters,pixel_labels,RGB_2pc);

% Iterate over each cell in the G_MASK cell array
for i = 1:numel(G_MASK)
    % Apply the operation to convert uint8 to logical
    G_MASK{i} = pixel_labels == i;

    %G_MASK{i} = imerode(G_MASK{i}, strel('disk', 1));

    figure;
    imagesc(G_MASK{i});
    title(['Objects in Cluster ', num2str(unique_clusters(i)) ' Before Voting']);
    colormap gray
end
     
%% The 'reassign_small_islands' function is used to reassign small objects  
% in each cluster from 'pixel_labels' and reassign them to the nearest
% object in another cluster

maxIslandSize = 10; % If a object in a cluster has a pixel count smaller than this value, it will be reassigned.
win = 3; % kernel size [win,win]
window_labels = reassign_small_islands(pixel_labels, maxIslandSize, win);

% The function 'grains' takes the clusters that have been sectioned from the
% variable 'window_labels' and places each unique cluster into an individual
% cell. 
G_MASK = grains(unique_clusters,window_labels,RGB_2pc);

% Iterate over each cell in the G_MASK cell array
for i = 1:numel(G_MASK)
    % Apply the operation to convert uint8 to logical
    G_MASK{i} = window_labels == i;

    figure;
    imagesc(G_MASK{i});
    title(['Objects in Cluster ', num2str(unique_clusters(i))]);
    colormap gray
end

% Clear variables to free memory
clear A
clear data
%% Splits clusters 'G_MASK' that have more than one object in the cluster 
% into separate cells, so that there is a single cell for each grain

G_MASK_single_objects = mask_split_objects(G_MASK);
for grain_number = 1:size(G_MASK_single_objects,2)

figure;
imagesc(G_MASK_single_objects{grain_number});
end
%% Make Grains 3D and take the average of current response for each grain
% The 'grain_avg' function is called to compute the average current response for each grain.

grain_number = 1:length(G_MASK_single_objects); 
% 
avg_g_all = grain_avg(G_MASK_single_objects, Voltametric_Data_LR, grain_number, CYCLE_With_LR, score_cell);

figure('Position', [0, 0, 950, 700]); % Adjust the values as needed (x,y,width,height)
hold on
plot(CYCLE_With_LR, avg_g_all{7}, 'LineStyle', '-', 'LineWidth', 4,'Color','#71E2F7');
plot(CYCLE_With_LR, avg_g_all{8}, 'LineStyle', '-', 'LineWidth', 4,'Color','#9584F3');
plot(CYCLE_With_LR, avg_g_all{1}, 'LineStyle', '-', 'LineWidth', 4,'Color','#499734');
plot(CYCLE_With_LR, avg_g_all{5}, 'LineStyle', '-', 'LineWidth', 4,'Color','#EF8634');
set(gca, 'FontSize', 40, 'LineWidth', 5)
xlim([-0.6 1.1])
ylim([-0.6 0.25])
xlabel('{\it E} vs Ag/AgCl, V')
ylabel('{\it i} / nA')
%% Voltammograms and current maps
  voltammogram_number = 423;
figure('Position', [1,1,720,640]);
hold on

 plot(applied_potentials{q}, Flat_cell{2}(153,:),'k', 'LineWidth', 6, 'Color', 'k', 'LineStyle', '-')
 plot(applied_potentials{q}, Flat_cell{2}(427,:),'k', 'LineWidth', 6, 'Color', [0.44,0.44,1.00], 'LineStyle', '-')
 plot(applied_potentials{q}, Flat_cell{2}(945,:),'k', 'LineWidth', 6, 'Color', 'r', 'LineStyle', '-')

xlabel('{\it E} vs Ag/AgCl, V')
ylabel(['{\it i}' ' / nA'])
xlim([-0.6 1.1])
ylim([-1.25 0.55])
ax = gca;
set(gca, 'FontSize', 60, 'LineWidth', 4)


%%
% Current Map (change value of 'p' to change the applied potential of the current map)
   for p = 1
    figure('Position', [100, 1, 750, 700]);
    imagesc(rot90(Voltametric_Data_LR(:,:,p)));

    title([num2str(CYCLE_With_LR(p), 2) ' V '], 'FontSize', 65, 'FontWeight', 'Normal')
    set(gca, 'XTick',[], 'XTickLabel', [],'YTick',[], 'YTickLabel', [], 'Position', [0.01 0.2500 0.5550 0.5547],'DataAspectRatio',[1 1 1]);
    colormap jet
    colorbar
    c = colorbar;
    c.FontSize = 50;
    c.LineWidth = 6;
    c.Position = [0.592019607843129,0.2500,0.055980392156871,0.554597701149424];

    % Get the tick values
    tickValues = c.Ticks;

    % Convert tick values to strings with fixed decimal places (2 digits)
    tickLabels = arrayfun(@(x) sprintf('%.2g', x), tickValues, 'UniformOutput', false);

    % Set the tick labels
    c.TickLabels = tickLabels;

   end

%% Movie
% t=2; % A number (1 or 2) that selects which dataset to use (original or edited)
% [filtered_data] = movie(varnames,applied_potentials,t);

%% RMSD Calculation
% The function 'RMSD' is called to calculate the root mean squared deviation/error (RMSD/RMSE)
%       between the original CVs and the CVs from PC data.

% When Num_PCs = 2 and n = 2, the figure generated by this function is the image from
% Figure 4B

    n = 2; % A number (1 or 2) that selects which dataset to use (original or edited)
    Num_PCs=2; % Number of principal components to include in the calculation
    VoltammogramNumber = 153; % This number will change which voltammogram you view in a CV

[roots,actual_residuals, resi_reshape,resi_reshape_l, mean_resi, resi_sd, RecreatedFlattenedImage] = ...
RMSD(AverageCVall,n,Flat_cell,score_cell,coeff_cell,Num_PCs,Voltametric_Data_LR,applied_potentials,VoltammogramNumber);
%
figure('Position', [1,1,720,640]);
hold on
%use this line to plot residual used in fig 4A 
plot(applied_potentials{n}, actual_residuals(VoltammogramNumber,:)*1000,'k', 'LineWidth', 4, 'Color', 'k', 'LineStyle', '-')

%use these line to plot CVs from fig 5f 
%plot(applied_potentials{n}, RecreatedFlattenedImage(VoltammogramNumber,:), 'LineStyle', '--', 'LineWidth', 4, 'Color', [1 0 0]);
%plot(applied_potentials{q}, Flat_cell{2}(153,:),'k', 'LineWidth', 6, 'Color', 'k', 'LineStyle', '-')

ax = gca;
set(gca,'FontName','Helvetica','FontSize',50)
ax.LineWidth = 4;
xlabel('{\it E} vs Ag/AgCl, V')
ylabel(['{\it i}' ' / pA'])
xlim([-0.6 1.05])
ylim([-150 150])
