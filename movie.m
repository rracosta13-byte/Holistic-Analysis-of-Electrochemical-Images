%% Movie Function: Minimum and Maximum current responses at each frame is filtered and smoothed.
% Frames then are used to make a movie of current responses 

% Inputs:
% varnames -> a 1 x 2 cell which stores two sets of data, the
% dataset in its original edited form, and the same dataset but with the
% current responses from -0.43 V to -0.45 V omitted from the dataset
% (original,NEWEDIT)
% applied_potentials -> a 1 x 2 cell which stores two sets of data, the
% applied potentials of the CVs in 'original' and the applied potentials of
% the CVs in 'NEWEDIT'
% t -> change this number to '1' to run function for 'original' change to
% '2' to run function for 'NEWEDIT'
% Outputs:
% filtered_data -> Filtered and smoothed current responses

function [filtered_data] = movie(varnames,applied_potentials,t)

% Max currents
    max_current=zeros(size(1:size(varnames{t},3)));
for i=1:size(varnames{t},3)
    max_current(1,i) = max(max(varnames{t}(:,:,i)));
end

% Min currents
    min_current=zeros(size(1:size(varnames{t},3)));
for i=1:size(varnames{t},3)
    min_current(1,i) = min(min(varnames{t}(:,:,i)));
end

% smoothing max
% Window size for max filtering
window_size = 7;

% Apply max filtering using colfilt
max_filtered_signal = colfilt(max_current, [1, window_size], 'sliding', @(x) max(x));

% smoothing min
min_filtered_signal = colfilt(min_current, [1, window_size], 'sliding', @(x) min(x));

filtered_data = varnames{t};
for z = 1:size(varnames{t},3)

    [max_x,max_y] = find(varnames{t}(:,:,z)==max_current(1,z));
    filtered_data(max_x,max_y,z) = max_filtered_signal(1,z);
    
end

for z = 1:size(varnames{t},3)

    [min_x,min_y] = find(varnames{t}(:,:,z)==min_current(1,z));
    filtered_data(min_x,min_y,z) = min_filtered_signal(1,z);
    
end
%%
%Max vs Filtered Max
figure;
hold on
plot(applied_potentials{t}, max_current,'LineStyle', '-','DisplayName','Max Currents','LineWidth', 6, 'Color', [0 0 0]);
plot(applied_potentials{t}, max_filtered_signal,'LineStyle', '-','DisplayName','Max Filtered Currents','LineWidth', 6, 'Color', [1 0 0]);

ax = gca;
set(gca,'FontSize',20)
ax.LineWidth = 6;
xlabel('{\it E} vs Ag/AgCl, V')
ylabel(['{\it i}' ' / nA'])

xlim([-0.6 1.1])
ylim([-0.1 0.4])

legend('FontName', 'Helvetica','FontSize', 20, 'Location', 'best', 'box', 'off') % Adjust the font size as needed

%Min vs Filtered min
figure;
hold on
plot(applied_potentials{t}, min_current,'LineStyle', '-','DisplayName','Min Currents','LineWidth', 6, 'Color', [0 0 0]);
plot(applied_potentials{t}, min_filtered_signal,'LineStyle', '-','DisplayName','Min Filtered Currents','LineWidth', 6, 'Color', [1 0 0]);

ax = gca;
set(gca,'FontSize',20)
ax.LineWidth = 6;
xlabel('{\it E} vs Ag/AgCl, V')
ylabel(['{\it i}' ' / nA'])

xlim([-0.6 1.1])
ylim([-1.1 0.1])
% 
legend('FontName', 'Helvetica','FontSize', 20, 'Location', 'best', 'box', 'off') % Adjust the font size as needed
%%
v = VideoWriter('Movie_F3_with_voltage_trace', 'MPEG-4');
v.Quality = 100;  % Optional: max quality
open(v);

figure('Units', 'pixels', 'Position', [100, 100, 1100, 644]);  % Fixed size
set(gcf, 'Color', 'w');  % White background for consistency

loops = size(varnames{t}, 3);
time_vector = 1:length(applied_potentials{t});

for L = 1:loops
    clf;  % Clear figure, retain size

    % === Left: Electrochemical image ===
    subplot(1,2,1);
    imagesc(rot90(filtered_data(:, :, L)));
    c = colorbar;
    c.FontSize = 20;
    c.LineWidth = 3; 
    title(c, '{\it i} / nA', 'FontSize', 20);
    axis image off
    title(sprintf('%.2f V', applied_potentials{t}(L)), 'FontSize', 30);
    colormap jet
    axis image off
    

    % === Right: Potential vs Time ===
    pos2 = [0.6 0.3 0.3 0.4];
    subplot('Position',pos2)    
    plot(time_vector, applied_potentials{t}, 'k-', 'LineWidth', 2);
    hold on;
    plot(time_vector(L), applied_potentials{t}(L), 'ro', 'MarkerSize', 12, 'MarkerFaceColor', 'r');
    xlim([1, length(time_vector)]);
    ylim([min(applied_potentials{t})-0.05, max(applied_potentials{t})+0.05]);  % Add buffer
    ylabel('{\it E} vs Ag/AgCl, V');
    title('Applied Potential vs Time', 'FontSize', 20);
    set(gca, 'FontSize', 20, 'LineWidth', 2,'XTickLabel', []);

    drawnow;
    frame = getframe(gcf);  % Always same size
    writeVideo(v, frame);
end

close(v);

end