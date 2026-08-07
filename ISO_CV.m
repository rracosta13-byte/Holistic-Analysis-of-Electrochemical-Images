%% ISO_CV: 
% Isolates the X, Y and Z coordinates of the voltametric electrochemical image
% into a grid of points and creates an index for the voltametric data 
% associated with each xyz coordinate 
%
% Inputs:
% A -> The transposed raw dataset.
%      -> A(1,:) contains coordinates in the x position
%      -> A(2,:) contains coordinates in the y position
%      -> A(3,:) contains coordinates in the z position
% startpoint -> The point where the meniscus makes its initial contact with the substrate (from pop-up menu).
% endpoint -> The point just before the meniscus lifts from the substrate (from pop-up menu).
% line_number_increments: Number of line number changes from one startpoint to the next startpoint (from the .set file associated with this dataset).
% SegmentStartIndices: Indices marking the start of each line in the dataset.
% SegmentEndIndices: Indices marking the end of each line in the dataset.
%
% Outputs:
% IsoDataStart -> The line number where the meniscus makes contact with the substrate.
% IsoDataEnd -> The line number just before the meniscus detaches from the substrate.
% CV_Potentials -> Array containing the applied potentials for each CV. (Contains multiple cycles, will split into single cycles later)
% MeanX, MeanY, MeanZ -> Mean X, Y, and Z coordinates for each CV segment.
%
% Code written by: Rudy R. Acosta, University of Arkansas, 08/15/24

function [IsoDataStart, IsoDataEnd, CV_Potentials, MeanX, MeanY, MeanZ]  = ISO_CV(A,startpoint,endpoint,line_number_increments,SegmentStartIndices,SegmentEndIndices)

    IsoDataStart = SegmentStartIndices(startpoint:line_number_increments:end);

    IsoDataEnd = SegmentEndIndices(endpoint:line_number_increments:end);

    CV_Potentials = A(5,IsoDataStart(1):IsoDataEnd(1));

    % Calculate the X/Y points for the CVs
MeanX=arrayfun(@(x,y) mean(A(1,x:y)), IsoDataStart,IsoDataEnd);
MeanY=arrayfun(@(x,y) mean(A(2,x:y)), IsoDataStart,IsoDataEnd);
MeanZ=arrayfun(@(x,y) mean(A(3,x:y)), IsoDataStart,IsoDataEnd);

MeanX = round(MeanX);
MeanY = round(MeanY);
%MeanZ = round(MeanZ);
figure
scatter(MeanX,MeanY)
title('X,Y Positions where CVs were taken')

% Count the number of unique x and y values
xSize = numel(unique(MeanX)); % Number of unique x-values (columns)
ySize = numel(unique(MeanY)); % Number of unique y-values (rows)

% Display the grid dimensions
disp(['Grid dimensions: ', num2str(xSize), ' rows x ', num2str(ySize), ' columns']);


