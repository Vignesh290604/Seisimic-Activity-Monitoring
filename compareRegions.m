function compareRegions(results)
% COMPAREREGIONS Compares b-values and other parameters across regions
%   compareRegions(results)
%   Creates comparison plots and tables for multiple regions
%
%   Input:
%       results - structure array with fields:
%                 name, b_value, a_value, mc, num_events

    fprintf('Comparing b-values across regions...\n');
    
    if isempty(results)
        warning('No results to compare');
        return;
    end
    
    % Extract data for plotting
    num_regions = length(results);
    region_names = cell(num_regions, 1);
    b_values = zeros(num_regions, 1);
    a_values = zeros(num_regions, 1);
    mc_values = zeros(num_regions, 1);
    num_events = zeros(num_regions, 1);
    
    for i = 1:num_regions
        region_names{i} = results(i).name;
        b_values(i) = results(i).b_value;
        a_values(i) = results(i).a_value;
        mc_values(i) = results(i).mc;
        num_events(i) = results(i).num_events;
    end
    
    % Create figure for comparing b-values
    fig1 = figure('Position', [100, 100, 800, 600]);
    
    % Create bar chart of b-values
    subplot(2, 2, 1);
    bar(b_values, 'FaceColor', [0.3, 0.6, 0.9]);
    
    % Add error bars (standard deviation of 0.1 is typical for b-values)
    hold on;
    errorbar(1:num_regions, b_values, 0.1*ones(size(b_values)), 'k.');
    
    % Add horizontal line at b=1.0
    line([0, num_regions+1], [1.0, 1.0], 'Color', 'r', 'LineStyle', '--', 'LineWidth', 1.5);
    
    % Format plot
    title('b-values by Region', 'FontSize', 14);
    xlabel('Region', 'FontSize', 12);
    ylabel('b-value', 'FontSize', 12);
    set(gca, 'XTick', 1:num_regions, 'XTickLabel', region_names, 'XTickLabelRotation', 45);
    ylim([0, max(b_values) + 0.3]);
    grid on;
    box on;
    set(gca, 'FontSize', 11);
    
    % Create bar chart of a-values
    subplot(2, 2, 2);
    bar(a_values, 'FaceColor', [0.9, 0.6, 0.3]);
    
    % Format plot
    title('a-values by Region', 'FontSize', 14);
    xlabel('Region', 'FontSize', 12);
    ylabel('a-value', 'FontSize', 12);
    set(gca, 'XTick', 1:num_regions, 'XTickLabel', region_names, 'XTickLabelRotation', 45);
    grid on;
    box on;
    set(gca, 'FontSize', 11);
    
    % Create bar chart of completeness magnitudes
    subplot(2, 2, 3);
    bar(mc_values, 'FaceColor', [0.6, 0.3, 0.9]);
    
    % Format plot
    title('Completeness Magnitude (M_c) by Region', 'FontSize', 14);
    xlabel('Region', 'FontSize', 12);
    ylabel('M_c', 'FontSize', 12);
    set(gca, 'XTick', 1:num_regions, 'XTickLabel', region_names, 'XTickLabelRotation', 45);
    grid on;
    box on;
    set(gca, 'FontSize', 11);
    
    % Create bar chart of number of events
    subplot(2, 2, 4);
    bar(num_events, 'FaceColor', [0.3, 0.9, 0.6]);
    
    % Format plot
    title('Number of Events by Region', 'FontSize', 14);
    xlabel('Region', 'FontSize', 12);
    ylabel('Number of Events', 'FontSize', 12);
    set(gca, 'XTick', 1:num_regions, 'XTickLabel', region_names, 'XTickLabelRotation', 45);
    grid on;
    box on;
    set(gca, 'FontSize', 11);
    
    % Adjust spacing
    sgtitle('Comparison of Seismic Parameters Across Regions', 'FontSize', 16);
    set(fig1, 'Color', 'w');
    
    % Save figure
    fig_filename = 'region_comparison.fig';
    savefig(fig1, fig_filename);
    
    % Save as PNG
    png_filename = 'region_comparison.png';
    saveas(fig1, png_filename, 'png');
    
    fprintf('Comparison figure saved as %s and %s\n', fig_filename, png_filename);
    
    % Create summary table and save to CSV
    table_data = [b_values, a_values, mc_values, num_events];
    table_headers = {'region', 'b_value', 'a_value', 'mc', 'num_events'};
    
    % Prepare data for CSV
    csv_data = cell(num_regions, 5);
    for i = 1:num_regions
        csv_data{i, 1} = region_names{i};
        csv_data{i, 2} = b_values(i);
        csv_data{i, 3} = a_values(i);
        csv_data{i, 4} = mc_values(i);
        csv_data{i, 5} = num_events(i);
    end
    
    % Save summary to CSV
    csv_filename = 'region_comparison_summary.csv';
    writeDataToCSV(csv_data, table_headers, csv_filename);
    
    % Print summary table to console
    fprintf('\nSummary of Results:\n');
    fprintf('%-12s %-10s %-10s %-10s %-10s\n', 'Region', 'b-value', 'a-value', 'Mc', 'Events');
    fprintf('%-12s %-10s %-10s %-10s %-10s\n', '------', '-------', '-------', '--', '------');
    
    for i = 1:num_regions
        fprintf('%-12s %-10.3f %-10.3f %-10.2f %-10d\n', ...
            region_names{i}, b_values(i), a_values(i), mc_values(i), num_events(i));
    end
    fprintf('\n');
end