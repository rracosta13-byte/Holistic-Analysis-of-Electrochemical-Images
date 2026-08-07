%% removerows: 
% presents coordinates and pop-up window to remove rows from the top and
% bottom of the grid of points 
% this fuction also formats voltametric data into a 3D array, XYI
%
% for figure 5 dataset, first row from the top and the bottom 4 are removed
%
%
% Inputs:
% IsoDataStart -> Array of line numbers where the meniscus makes contact with the substrate before removing rows.
% IsoDataEnd -> Array of line numbers just before the meniscus detaches from the substrate before removing rows.
% xSize -> Number of x points/Use plot of (MeanX, MeanY) from previous section
%           to determine X length if not already known 
% ySize -> Number of y points/Use plot of (MeanX, MeanY) from previous section
%           to determine Y length if not already known
%
% Outputs:
% IsoDataStart, IsoDataEnd-> Same as input, but now with rows removed
% xSize, ySize -> Same as input, but now with rows removed
% MeanX, MeanY, MeanZ -> Same as input, but now with rows removed
% XYI -> 3D Array of current (i/nA) data at each XY position
% each 2d slice of the array represents currents at a particular voltage
%
% Code written by: Rudy R. Acosta, University of Arkansas, 10/20/24


function [IsoDataStart, IsoDataEnd, MeanX, MeanY, MeanZ, xSize, ySize, XYI] = ...
    removerows(IsoDataStart, IsoDataEnd, MeanX, MeanY, MeanZ, A)
% removerows drops  N rows from top/bottom (by Y)
% Returns trimmed vectors + updated grid sizes.

    % Identify Rows of dataset from y position
    [rowVals, ~, iy] = unique(MeanY);      %find all unique Y values and assign each 
    % point a row index 'iy' in the order that they appear

    % sort from largets y val to smallest y val
    [rowValsSorted, sortIdx] = sort(rowVals,'descend');  
   

    %Builds a reindexing map so each data point gets a top-to-bottom row number
    newIndex = zeros(numel(rowVals),1,'like',iy);
    newIndex(sortIdx) = 1:numel(sortIdx);
    rowIndex = newIndex(iy);                   % 1..nRows, from top to bottom
    nRows = numel(rowValsSorted);

 % Shows what the grid looks like before the trim
    figure('Name','Before trimming (rows)')
    scatter(MeanX, MeanY, 12, 'filled');
    xlabel('X'); ylabel('Y');
    
    % How many row to remove?
    prompt = {sprintf('Rows to remove from TOP (0..%d):', max(0,nRows-1)), ...
              sprintf('Rows to remove from BOTTOM (0..%d):', max(0,nRows-1))};
    defAns = {'0','0'};
    dlgTitle = sprintf('Trim edge rows (total rows detected: %d)', nRows);
    answer = inputdlg(prompt, dlgTitle, [1 55], defAns);

    if isempty(answer)
        % User canceled: just report sizes and return unchanged
        xSize = numel(unique(MeanX));
        ySize = numel(unique(MeanY));
        removedInfo = struct('nTop',0,'nBottom',0,'topRows',[],'bottomRows',[]);
        return
    end

    nTop    = str2double(answer{1});
    nBottom = str2double(answer{2});
    if any(isnan([nTop nBottom])) || any([nTop nBottom] < 0) || (nTop + nBottom >= nRows)
        error('Invalid input: ensure nonnegative integers and nTop + nBottom < %d.', nRows);
    end
    nTop    = floor(nTop);
    nBottom = floor(nBottom);

    % Mask of Rows to to keep after remove slected rows from prompt above
    keepMask = (rowIndex > nTop) & (rowIndex <= (nRows - nBottom));

    % Apply Mask to dataset
    IsoDataStart = IsoDataStart(keepMask);
    IsoDataEnd   = IsoDataEnd(keepMask);
    MeanX        = MeanX(keepMask);
    MeanY        = MeanY(keepMask);
    MeanZ        = MeanZ(keepMask);

    % Grid Size after the trim
    xSize = numel(unique(MeanX));  % columns
    ySize = numel(unique(MeanY));  % rows


    % View Grid after the trim
    figure('Name','After trimming (rows)')
    scatter(MeanX, MeanY, 12, 'filled');
    title(sprintf('Kept %d rows × %d cols (removed top %d, bottom %d)', ySize, xSize, nTop, nBottom));
    xlabel('X'); ylabel('Y');

    % Display the grid dimensions
disp(['Grid dimensions: ', num2str(xSize), ' rows x ', num2str(ySize), ' columns']);


% Find flattening by fitting a plane (polynomial of total degree 1) 
% to Z as a function of X and Y using Curve Fitting Toolbox. Plots the plane with the data overlay
sf = fit([MeanX', MeanY'],MeanZ','poly11');
figure;
plot(sf,[MeanX', MeanY'],MeanZ');

% Initialize arrays using the variables
Coords = zeros(xSize, ySize, 4);
XYI = zeros(xSize, ySize, length(IsoDataStart(1):IsoDataEnd(1)));

% Iterate through X and Y points to extract current data and calculate flattened Z
%This computes the linear index into your vectors, assuming a serpentine scan
% i is x, j is y
for j = 1:ySize
    for i = 1:xSize
        Index = i * bitget(j, 1) + (xSize + 1 - i) * bitget(j + 1, 1) + (j - 1) * xSize;
        % disp(Index)
        XYI(i, j, :) = A(6, IsoDataStart(Index):IsoDataEnd(Index));
        Coords(i, j, :) = [MeanX(Index), MeanY(Index), MeanZ(Index), MeanZ(Index) - feval(sf, [MeanX(Index), MeanY(Index)])];
    end
end
XYI = flipud(XYI);
end

