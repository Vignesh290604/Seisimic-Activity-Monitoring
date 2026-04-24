function [data, headers] = downloadEarthquakeData(region, start_time, end_time, min_magnitude)
% Download earthquake data from USGS web service
%
% Parameters:
% -----------
% region : [min_lat, max_lat, min_lon, max_lon]
%    Region boundaries
% start_time : string
%    Start time in format 'YYYY-MM-DD'
% end_time : string
%    End time in format 'YYYY-MM-DD'
% min_magnitude : float
%    Minimum magnitude to include
%
% Returns:
% --------
% data : matrix
%    Matrix with earthquake data
% headers : cell array
%    Column headers

    % Format URL
    base_url = 'https://earthquake.usgs.gov/fdsnws/event/1/query';
    format = 'csv';
    
    % Create URL with parameters
    url = sprintf('%s?format=%s&starttime=%s&endtime=%s&minlatitude=%.2f&maxlatitude=%.2f&minlongitude=%.2f&maxlongitude=%.2f&minmagnitude=%.1f', ...
        base_url, format, start_time, end_time, ...
        region(1), region(2), region(3), region(4), min_magnitude);
    
    % Display URL for debugging
    fprintf('Downloading data from: %s\n', url);
    
    try
        % Create temporary file
        temp_file = 'temp_eq_data.csv';
        
        % Download the data
        fprintf('Downloading earthquake data...\n');
        options = weboptions('Timeout', 120);
        websave(temp_file, url, options);
        
        % Read the CSV file
        opts = detectImportOptions(temp_file, 'FileType', 'text');
        T = readtable(temp_file, opts);
        
        % Convert table to matrix and cell array of headers
        data = table2array(T);
        headers = T.Properties.VariableNames;
        
        % Clean up temporary file
        delete(temp_file);
        
        fprintf('Downloaded %d earthquakes\n', size(data, 1));
        
    catch e
        fprintf('Error downloading data: %s\n', e.message);
        data = [];
        headers = {};
    end
    
    % If download failed, generate synthetic data for testing
    if isempty(data)
        warning('Download failed. Generating synthetic data for testing purposes.');
        
        % Create synthetic data with time, lat, lon, depth, mag, magType
        n_events = 1000;
        
        % Generate random times within period
        t_start = datenum(start_time);
        t_end = datenum(end_time);
        times = t_start + (t_end - t_start) * rand(n_events, 1);
        
        % Generate random positions within region
        lats = region(1) + (region(2) - region(1)) * rand(n_events, 1);
        lons = region(3) + (region(4) - region(3)) * rand(n_events, 1);
        
        % Generate random depths (0-100 km)
        depths = 100 * rand(n_events, 1);
        
        % Generate magnitudes following Gutenberg-Richter law
        r = rand(n_events, 1);
        mags = min_magnitude - log10(r) / 1.0;  % b-value of 1.0
        
        % Combine into data matrix
        data = [times, lats, lons, depths, mags];
        headers = {'time', 'latitude', 'longitude', 'depth', 'magnitude'};
    end
end