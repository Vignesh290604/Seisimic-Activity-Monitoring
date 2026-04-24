function fig = plotMagnitudeFrequency(magnitudes, b_value, a_value, mc, region_name)
% PLOTMAGNITUDEFREQUENCY Plots magnitude-frequency distribution
%   fig = plotMagnitudeFrequency(magnitudes, b_value, a_value, mc, region_name)
%   Plots the magnitude-frequency distribution with Gutenberg-Richter fit
%
%   Input:
%       magnitudes - vector of earthquake magnitudes
%       b_value - the Gutenberg-Richter b-value
%       a_value - the Gutenberg-Richter a-value
%       mc - the completeness magnitude
%       region_name - name of the region (for plot title)
%
%   Output:
%       fig - figure handle

    fprintf('  Plotting magnitude-frequency distribution...\n');
    
    % Remove NaN or infinite values
    magnitudes = magnitudes(isfinite(magnitudes));
    
    % Create figure
    fig = figure('Position', [100, 100, 800, 600]);
    
    % Set up magnitude bins with 0.1 bin width
    bin_width = 0.1;
    mag_min = floor(min(magnitudes) / bin_width) * bin_width;
    mag_max = ceil(max(magnitudes) / bin_width) * bin_width;
    mag_edges = mag_min:bin_width:mag_max;
    mag_centers = mag_edges(1:end-1) + bin_width/2;
    
    % Calculate histogram
    [N, ~] = histcounts(magnitudes, mag_edges);
    
    % Calculate cumulative frequency
    cum_freq = zeros(size(mag_centers));
    for i = 1:length(mag_centers)
        cum_freq(i) = sum(magnitudes >= mag_centers(i));
    end
    
    % Plot non-cumulative (incremental) frequency
    subplot(2, 1, 1);
    bar(mag_centers, N, 'FaceColor', [0.3, 0.6, 0.9], 'EdgeColor', [0.2, 0.2, 0.2]);
    hold on;
    
    % Calculate and plot GR fit for incremental frequencies
    mag_range = mag_min:bin_width:mag_max;
    N_incremental = 10.^(a_value - b_value * mag_range) - 10.^(a_value - b_value * (mag_range + bin_width));
    plot(mag_range, N_incremental, 'r-', 'LineWidth', 2);
    
    % Add Mc vertical line
    line([mc, mc], [0, max(N)*1.1], 'Color', 'k', 'LineStyle', '--', 'LineWidth', 1.5);
    text(mc + 0.1, max(N)*0.9, sprintf('M_c = %.2f', mc), 'FontSize', 12);
    
    % Format incremental plot
    title(sprintf('Magnitude-Frequency Distribution for %s', region_name), 'FontSize', 14);
    xlabel('Magnitude', 'FontSize', 12);
    ylabel('Number of Events', 'FontSize', 12);
    xlim([mag_min, mag_max]);
    ylim([0, max(N)*1.1]);
    grid on;
    box on;
    set(gca, 'FontSize', 11);
    
    % Plot cumulative frequency
    subplot(2, 1, 2);
    semilogy(mag_centers, cum_freq, 'bo', 'MarkerFaceColor', [0.3, 0.6, 0.9], 'MarkerSize', 6);
    hold on;
    
    % Calculate and plot GR fit for cumulative frequencies
    N_cumulative = 10.^(a_value - b_value * mag_range);
    semilogy(mag_range, N_cumulative, 'r-', 'LineWidth', 2);
    
    % Add Mc vertical line
    line([mc, mc], [1, 10^(a_value + 1)], 'Color', 'k', 'LineStyle', '--', 'LineWidth', 1.5);
    text(mc + 0.1, 10^(a_value - 1), sprintf('M_c = %.2f', mc), 'FontSize', 12);
    
    % Add b-value annotation
    text(mag_min + 0.5, 10^(a_value - 2), sprintf('b = %.3f', b_value), 'FontSize', 12, 'BackgroundColor', [1, 1, 1, 0.7]);
    text(mag_min + 0.5, 10^(a_value - 2.5), sprintf('a = %.3f', a_value), 'FontSize', 12, 'BackgroundColor', [1, 1, 1, 0.7]);
    
    % Format cumulative plot
    title('Cumulative Magnitude-Frequency Distribution', 'FontSize', 14);
    xlabel('Magnitude', 'FontSize', 12);
    ylabel('Cumulative Number of Events', 'FontSize', 12);
    xlim([mag_min, mag_max]);
    ylim([1, 10^(ceil(log10(max(cum_freq))+0.5))]);
    grid on;
    box on;
    set(gca, 'FontSize', 11);
    
    % Save figure
    fig_filename = sprintf('%s_magnitude_frequency.fig', lower(region_name));
    savefig(fig, fig_filename);
    
    % Save as PNG
    png_filename = sprintf('%s_magnitude_frequency.png', lower(region_name));
    saveas(fig, png_filename, 'png');
    
    fprintf('  Figure saved as %s and %s\n', fig_filename, png_filename);
end