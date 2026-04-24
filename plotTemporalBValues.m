function fig = plotTemporalBValues(temp_data, region_name)
% PLOTTEMPORALBVALUES Plots temporal evolution of b-values
%   fig = plotTemporalBValues(temp_data, region_name)
%   Creates a time series plot of b-values
%
%   Input:
%       temp_data - matrix with columns [center_time, b_value, a_value, mc, num_events]
%       region_name - name of the region (for plot title)
%
%   Output:
%       fig - figure handle

    fprintf('  Plotting temporal b-value evolution...\n');
    
    if isempty(temp_data)
        warning('No temporal data to plot');
        fig = figure('Visible', 'off');
        return;
    end
    
    % Extract data columns
    times = temp_data(:, 1); % Already in datenum format
    b_values = temp_data(:, 2);
    num_events = temp_data(:, 5);
    
    % Create figure
    fig = figure('Position', [100, 100, 1000, 600]);
    
    % Plot b-values
    subplot(2, 1, 1);
    plot(times, b_values, 'b-', 'LineWidth', 2);
    hold on;
    
    % Add error bars (standard deviation of 0.1 is typical for b-values)
    errorbar(times, b_values, 0.1*ones(size(b_values)), 'b.');
    
    % Add horizontal line at b=1.0
    line([min(times), max(times)], [1.0, 1.0], 'Color', 'r', 'LineStyle', '--', 'LineWidth', 1.5);
    
    % Format time axis
    datetick('x', 'yyyy-mm', 'keepticks');
    
    % Add labels and title
    title(sprintf('Temporal b-value Evolution for %s', region_name), 'FontSize', 14);
    xlabel('Time', 'FontSize', 12);
    ylabel('b-value', 'FontSize', 12);
    grid on;
    box on;
    set(gca, 'FontSize', 11);
    
    % Set y-axis limits
    b_min = max(0.5, min(b_values) - 0.2);
    b_max = min(2.0, max(b_values) + 0.2);
    ylim([b_min, b_max]);
    
    % Plot number of events
    subplot(2, 1, 2);
    bar(times, num_events, 'FaceColor', [0.3, 0.6, 0.9], 'EdgeColor', [0.2, 0.2, 0.2]);
    
    % Format time axis
    datetick('x', 'yyyy-mm', 'keepticks');
    
    % Add labels
    title('Number of Events in Each Time Window', 'FontSize', 14);
    xlabel('Time', 'FontSize', 12);
    ylabel('Number of Events', 'FontSize', 12);
    grid on;
    box on;
    set(gca, 'FontSize', 11);
    
    % Save figure
    fig_filename = sprintf('%s_temporal_bvalues.fig', lower(region_name));
    savefig(fig, fig_filename);
    
    % Save as PNG
    png_filename = sprintf('%s_temporal_bvalues.png', lower(region_name));
    saveas(fig, png_filename, 'png');
    
    fprintf('  Figure saved as %s and %s\n', fig_filename, png_filename);
end