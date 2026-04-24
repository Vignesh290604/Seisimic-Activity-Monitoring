% main.m - Main script for earthquake magnitude-frequency distribution analysis

% Clear workspace and close figures
clear all;
close all;
clc;

% Define regions
regions = struct();
regions(1).name = 'California';
regions(1).boundaries = [32.0, 42.0, -125.0, -114.0]; % [min_lat, max_lat, min_lon, max_lon]
regions(2).name = 'Japan';
regions(2).boundaries = [30.0, 46.0, 128.0, 146.0];
regions(3).name = 'Chile';
regions(3).boundaries = [-40.0, -20.0, -76.0, -66.0];

% Time period
start_time = '2010-01-01';
end_time = '2023-01-01';

% Results storage
results = struct();

% Process each region
for i = 1:length(regions)
    region_name = regions(i).name;
    boundaries = regions(i).boundaries;
    
    fprintf('Processing %s...\n', region_name);
    
    % Download data
    [data, headers] = downloadEarthquakeData(boundaries, start_time, end_time, 2.0);
    
    % Save raw data
    csv_filename = sprintf('%s_earthquakes.csv', lower(region_name));
    writeDataToCSV(data, headers, csv_filename);
    
    % Extract magnitudes
    magnitudes = data(:, strcmp(headers, 'magnitude'));
    
    % Calculate overall b-value
    [b_value, a_value, mc] = calculateBValue(magnitudes);
    
    fprintf('  Region: %s\n', region_name);
    fprintf('  Number of events: %d\n', size(data, 1));
    fprintf('  b-value: %.3f\n', b_value);
    fprintf('  a-value: %.3f\n', a_value);
    fprintf('  Completeness magnitude (Mc): %.2f\n', mc);
    
    % Plot magnitude-frequency distribution
    fig = plotMagnitudeFrequency(magnitudes, b_value, a_value, mc, region_name);
    
    % Perform spatial b-value analysis
    lat_col = strcmp(headers, 'latitude');
    lon_col = strcmp(headers, 'longitude');
    
    spatial_data = spatialBValueAnalysis(data(:, lat_col), data(:, lon_col), magnitudes);
    
    % Save spatial data
    spatial_csv = sprintf('%s_spatial_bvalues.csv', lower(region_name));
    spatial_headers = {'center_lat', 'center_lon', 'b_value', 'a_value', 'mc', 'num_events'};
    writeDataToCSV(spatial_data, spatial_headers, spatial_csv);
    
    % Plot spatial b-values
    if ~isempty(spatial_data)
        spatial_fig = plotSpatialBValues(spatial_data, boundaries, region_name);
    end
    
    % Store results
    results(i).name = region_name;
    results(i).b_value = b_value;
    results(i).a_value = a_value;
    results(i).mc = mc;
    results(i).num_events = size(data, 1);
    
    % Temporal b-value analysis
    if strcmp(headers{1}, 'time')
        time_col = 1;
        dates = data(:, time_col);
        if ~iscell(dates) && ~isdatetime(dates)
            dates = datetime(dates, 'ConvertFrom', 'datenum');
        elseif iscell(dates)
            dates = datetime(dates);
        end
        
        temp_data = temporalBValueAnalysis(dates, magnitudes, 180, 30);
        temp_fig = plotTemporalBValues(temp_data, region_name);
    end
end

% Compare b-values across regions
compareRegions(results);