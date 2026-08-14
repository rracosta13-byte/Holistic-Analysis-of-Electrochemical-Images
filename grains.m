%% grains:
% This function will recognize if there is more than one object in any of the clusters
% and will split each object (grain) individually and placed into its own cell 
%
% Input
% G_MASK -> cell with grain(s) in each of the cells 
%
% Output
% G_MASK_single_objects -> if more than one object is identified in each of the G_MASK,
% each of the objects (grains) will be placed in its own cell
%
%Code written by: Rudy R. Acosta, Univeristy of Arkansas, 08/15/24

function G_MASK_single_objects = grains(G_MASK)

G_MASK_single_objects = {};  % Initialize empty cell array to store single object masks

for num = 1:numel(G_MASK)
    [loca, n] = bwlabel(G_MASK{num});
    
    if n == 1
        % If there's only one object in the mask, add it directly to the output cell array
        G_MASK_single_objects{end+1} = G_MASK{num};
    else
        % If there are multiple objects, split them into individual cells
        for i = 1:n
            object_separate = loca == i;
            object = uint8(object_separate) .* 255;
            MASK = logical(object);
            G_MASK_single_objects{end+1} = MASK;
            
            
            %title(['MASK' num2str(i) '_Object' num2str(i)]);
        end
    end
end


        
end

