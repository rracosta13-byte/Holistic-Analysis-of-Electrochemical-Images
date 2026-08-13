%% RESHAPE_DATA function:
% This function transposes and processes variable 'data', and is called 'A' 
% It adjusts voltage and current values and identifies where meniscus contact occurs, marked by changes in line numbers.
%
% The line numbers in the dataset change whenever the instrument gives a new command, indicating a new segment in the CV scan.
%
% The pop-up menu for this function will ask for two inputs: start point and endpoint
% In the figures that will be shown in this function, the start point is the
% first graph that you will see that does not appear as random points on a
% plot, but more closely resembles a voltammogram. There will be a prompt
% to press any key to look at the next graph, the end point is the last
% graph that looks like a voltammogram before that plots look like random
% points again.
%
% For Figure 5 data in the pop-up menu 7 = startpoint, 18 = endpoint
%
% Graph appeares and pauses to give time to visually inspect the images 
% (press any key to proceed to the next graph (CV Segment))
%
% Inputs:
% data -> The raw dataset as provided from the electrochemical experiment.
% VOffset -> Offset refers to the deviation between the applied potential and the actual potential experienced at the electrode surface
% Curr -> Conversion factor to scale current response
%
% Outputs:
%    A -> Transposed and adjusted dataset, where:
%      -> A(5,:) contains adjusted voltage values.
%      -> A(6,:) contains adjusted current values (in nanoamps).
%      -> A(7,:) contains line number data that helps determine where the meniscus made contact.
% SegmentStartIndices -> Indices indicating the start of each new line number, marking a new segment of the data.
% SegmentEndIndices -> Indices indicating the end of each line number, marking the end of a segment.
%
% Code written by: Rudy R. Acosta, University of Arkansas, 08/15/24


function [A,SegmentStartIndices,SegmentEndIndices,input_points]  = RESHAPE_DATA(data,VOffset,Curr)
    % % Transpose data 
    A = (data');

    % Adjust data
    A(6,:) = -A(6,:) / Curr ; %Convert to nanoamps
    A(5,:) = VOffset - A(5,:); %Adjust Voltage
    
    % Find indices where segments change
    SegmentEndIndices = find(A(7,2:end) - A(7,1:end-1)); 
    SegmentStartIndices = [1 SegmentEndIndices + 1]; 
    SegmentEndIndices = [SegmentEndIndices size(A,2)]; 

    % Use this plot to determine which segments contain data 
 % (Meniscus  in the air vs Meniscus  contacts with the surface)
    for i = 1:40 % Calls up to 'i' number of start/end segments to see where data is.
        figure;
        PlotIndex = SegmentStartIndices(i):SegmentEndIndices(i);
        plot(A(5,PlotIndex), A(6,PlotIndex), '.')
        title(['Segment ', num2str(i)]);
        xlabel('Voltage');
        ylabel('Current');

 % Pause and wait for the user input before proceeding
    pause;  % Gives time to visually inspect the images (press any key to proceed)
    
    end

    % Input box pop-up to define start and endpoints based on the figures
    % of the first 'i' number of start endpoints
    prompt = {'Define the startpoint:' , 'Define the endpoint:'};
    dlgtitle = 'Input';
    dims = [1 35; 1 35];
    definput = {'1','20'}; 
    input_points = inputdlg(prompt, dlgtitle, dims, definput);


     if isempty(input_points)
        for i = 21:40 % Calls up to 'i' number of start/end segments to see where data is.
        figure;
        PlotIndex = SegmentStartIndices(i):SegmentEndIndices(i);
        plot(A(5,PlotIndex), A(6,PlotIndex), '.')
        title(['Segment ', num2str(i)]);
        xlabel('Voltage');
        ylabel('Current');

 % Pause and wait for the user input before proceeding
    pause;  % Gives time to visually inspect the images (press any key to proceed)
    
        end

        % Input box pop-up to define start and endpoints based on the figures
        % of the first 'i' number of start endpoints
        prompt = {'Define the startpoint:' , 'Define the endpoint:'};
        dlgtitle = 'Input';
        dims = [1 35; 1 35];
        definput = {'21','40'}; 
        input_points = inputdlg(prompt, dlgtitle, dims, definput);
    end
close all
end

 
