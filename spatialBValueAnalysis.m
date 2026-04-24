function spatial_data = spatialBValueAnalysis(latitudes, longitudes, magnitudes)
% SPATIALBVALUEANALYSIS Performs spatial b-value analysis on earthquake data
%   spatial_data = spatialBValueAnalysis(latitudes, longitudes, magnitudes)
%   Calculates b-values for overlapping spatial windows
%
%   Input:
%       latitudes - vector of earthquake latitudes
%       longitudes - vector of earthquake longitudes
%       magnitudes - vector of earthquake magnitudes
%
%   Output:
%       spatial_data - matrix with columns [center_lat, center_lon, b_value, a_value, mc, num_events]

    fprintf('  Performing spatial b-value analysis...\n');
    
    % Remove NaN or infinite values
    valid_idx = isfinite(latitudes) & isfinite(longitudes) & isfinite(magnitudes);
    latitudes = latitudes(valid_idx);
    longitudes = longitudes(valid_idx);
    magnitudes = magnitudes(valid_idx);
    
    % Check if enough data
    if length(magnitudes) < 100
        warning('Not enough data for meaningful spatial b-value analysis');
        spatial_data = [];
        return;
    end
    
    % Define grid parameters
    grid_spacing = 1.0; % degrees
    radius = 1.5 * grid_spacing; % degrees, search radius
    min_events = 50; % minimum number of events for b-value calculation
    
    % Determine grid boundaries
    lat_min = floor(min(latitudes));
    lat_max = ceil(max(latitudes));
    lon_min = floor(min(longitudes));
    lon_max = ceil(max(longitudes));
    
    % Create grid
    lat_grid = lat_min:grid_spacing:lat_max;
    lon_grid = lon_min:grid_spacing:lon_max;
    
    % Pre-allocate results matrix
    num_points = length(lat_grid) * length(lon_grid);
    spatial_data = nan(num_points, 6);
    point_counter = 0;
    
    % Progress indicator
    total_points = length(lat_grid) * length(lon_grid);
    fprintf('  Calculating b-values for %d grid points...\n', total_points);
    progress_step = max(1, floor(total_points / 10));
    
    % Loop through grid points
    for i = 1:length(lat_grid)
        for j = 1:length(lon_grid)
            point_counter = point_counter + 1;
            
            % Show progress
            if mod(point_counter, progress_step) == 0 || point_counter == total_points
                fprintf('    Progress: %d/%d (%.1f%%)\n', point_counter, total_points, 100*point_counter/total_points);
            end
            
            % Center point
            center_lat = lat_grid(i);
            center_lon = lon_grid(j);
            
            % Find earthquakes within radius using haversine distance
            distances = haversineDistance(center_lat, center_lon, latitudes, longitudes);
            in_radius = distances <= radius;
            
            local_magnitudes = magnitudes(in_radius);
            num_events = length(local_magnitudes);
            
            % Skip if not enough events
            if num_events < min_events
                continue;
            end
            
            % Calculate b-value
            try
                [b_value, a_value, mc] = calculateBValue(local_magnitudes);
                
                % Store results
                spatial_data(point_counter, :) = [center_lat, center_lon, b_value, a_value, mc, num_events];
            catch
                % Skip this point if calculation fails
                continue;
            end
        end
    end
    
    % Remove rows with NaN values
    spatial_data = spatial_data(~isnan(spatial_data(:,3)), :);
    
    fprintf('  Completed b-value calculations for %d valid grid points.\n', size(spatial_data, 1));
end

function distances = haversineDistance(lat1, lon1, lat2, lon2)
% Calculate haversine distance in degrees between (lat1,lon1) and each point in (lat2,lon2)
    
    % Convert to radians
    lat1_rad = deg2rad(lat1);
    lon1_rad = deg2rad(lon1);
    lat2_rad = deg2rad(lat2);
    lon2_rad = deg2rad(lon2);
    
    % Differences
    dlat = lat2_rad - lat1_rad;
    dlon = lon2_rad - lon1_rad;
    
    % Haversine formula
    a = sin(dlat/2).^2 + cos(lat1_rad) .* cos(lat2_rad) .* sin(dlon/2).^2;
    c = 2 * atan2(sqrt(a), sqrt(1-a));
    
    % Convert back to degrees
    distances = rad2deg(c);
end