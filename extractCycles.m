%% extractCycles:
% This function extracts the applied potentials for each cycle of a 
%  CV from the given potential data, segmenting them based on the number of cycles.
%
% Code written by: Rudy R. Acosta, University of Arkansas, 08/15/24
%
% Inputs:
% CV_Potentials -> The applied potentials during cyclic voltammetry.
% number_of_cycles -> The total number of cycles in the CV data.
%
% Outputs:
% cyclePotentials -> A cell array where each cell contains the potential data
%                   for one cycle.
% cycleIndices -> A cell array containing the indices of the potential data
%                for each cycle.

function [cyclePotentials, cycleIndices] = extractCycles(CV_Potentials, number_of_cycles)
   % Calculate the number of values per cycle
    valuesPerCycle = length(CV_Potentials) / number_of_cycles;
    valuesPerCycle = round(valuesPerCycle);
    
    % Initialize cell arrays to store potentials and indices for each cycle
    cyclePotentials = cell(1, number_of_cycles);
    cycleIndices = cell(1, number_of_cycles);
    
    % Loop through each cycle to extract potentials and corresponding indices
    for cycle = 1:number_of_cycles
        startIndex = (cycle - 1) * valuesPerCycle + 1;
        if cycle == number_of_cycles
            % Handle the last cycle separately to include all remaining values
            endIndex = length(CV_Potentials);
        else
            endIndex = cycle * valuesPerCycle;
        end
        
        % Store the potentials and indices for each cycle
        cyclePotentials{cycle} = CV_Potentials(startIndex:endIndex);
        cycleIndices{cycle} = startIndex:endIndex;
    end