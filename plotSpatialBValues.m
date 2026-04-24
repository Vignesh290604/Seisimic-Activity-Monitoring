function fig = plotSpatialBValues(spatial_data, region_boundaries, region_name)
% Plot spatial distribution of b-values
%
% Parameters:
% -----------
% spatial_data : matrix
%    Matrix with [center_lat, center_lon, b_value, a_value, mc, num_events]
% region_boundaries : [min_lat, max_lat, min_lon, max_lon]
%    Region boundaries
% region_name : string
%    Name of region for plot title

    % Extract columns
    center_lat = spatial_data(:, 1);
    center_lon = spatial_data(:, 2);
    b_values = spatial_data(:, 3);
    num_events = spatial_data(:, 6);
    
    % Create figure
    fig = figure('Position', [100, 100, 900, 800]);
    
    % Create scatter plot of b-values
    scatter(center_lon, center_lat, num_events/10, b_values, 'filled', 'MarkerFaceAlpha', 0.7);
    
    % Set colormap and add colorbar
    colormap('jet');
    cb = colorbar;
    caxis([0.6, 1.4]);
    cb.Label.String = 'b-value';
    
    % Add region boundaries
    xlim([region_boundaries(3), region_boundaries(4)]);
    ylim([region_boundaries(1), region_boundaries(2)]);
    
    % Add labels and title
    xlabel('Longitude');
    ylabel('Latitude');
    title(sprintf('Spatial Distribution of b-values\n%s', region_name));
    grid on;
    
    % Save figure
    filename = sprintf('spatial_b_values_%s.png', strrep(region_name, ' ', '_'));
    saveas(fig, filename);
end