function temp_data = temporalBValueAnalysis(dates, magnitudes, window_days, step_days)
% TEMPORALBVALUEANALYSIS Performs temporal b-value analysis on earthquake data
%   temp_data = temporalBValueAnalysis(dates, magnitudes, window_days, step_days)
%   Calculates b-values for sliding time windows
%
%   Input:
%       dates - vector of earthquake dates (datetime format)
%       magnitudes - vector of earthquake magnitudes
%       window_days - size of the sliding window in days
%       step_days - step size for sliding window in days
%
%   Output:
%       temp_data - matrix with columns [center_time, b_value, a_value, mc, num_events]

    fprintf('  Performing temporal b-value analysis...\n');
    fprintf('  Window size: %d days, Step size: %d days\n', window_days, step_days);
    
    % Remove NaN or infinite values
    valid_idx = isfinite(magnitudes);
    if ~isdatetime(dates)
        dates = datetime(dates, 'ConvertFrom', 'datenum');
    end
    dates = dates(valid_idx);
    magnitudes = magnitudes(valid_idx);
    
    % Check if enough data
    if length(magnitudes) < 100
        warning('Not enough data for meaningful temporal b-value analysis');
        temp_data = [];
        return;
    end
    
    % Convert window and step to duration
    window_duration = days(window_days);
    step_duration = days(step_days);
    
    % Determine time range
    time_min = min(dates);
    time_max = max(dates);
    total_days = days(time_max - time_min);
    
    % Calculate number of windows
    num_steps = floor((total_days - window_days) / step_days) + 1;
    
    if num_steps < 1
        warning('Time range too short for temporal analysis with current window');
        temp_data = [];
        return;
    end
    
    % Pre-allocate results matrix
    temp_data = nan(num_steps, 5);
    
    % Progress indicator
    fprintf('  Calculating b-values for %d time windows...\n', num_steps);
    progress_step = max(1, floor(num_steps / 10));
    
    % Loop through time windows
    for i = 1:num_steps
        % Show progress
        if mod(i, progress_step) == 0 || i == num_steps
            fprintf('    Progress: %d/%d (%.1f%%)\n', i, num_steps, 100*i/num_steps);
        end
        
        % Window start and end times
        window_start = time_min + (i-1) * step_duration;
        window_end = window_start + window_duration;
        window_center = window_start + window_duration/2;
        
        % Find earthquakes within time window
        in_window = (dates >= window_start) & (dates <= window_end);
        window_magnitudes = magnitudes(in_window);
        num_events = sum(in_window);
        
        % Skip if not enough events
        if num_events < 50
            continue;
        end
        
        % Calculate b-value
        try
            [b_value, a_value, mc] = calculateBValue(window_magnitudes);
            
            % Store results with center time as datenum for MATLAB compatibility
            temp_data(i, :) = [datenum(window_center), b_value, a_value, mc, num_events];
        catch
            % Skip this window if calculation fails
            continue;
        end
    end
    
    % Remove rows with NaN values
    temp_data = temp_data(~isnan(temp_data(:,2)), :);
    
    fprintf('  Completed b-value calculations for %d valid time windows.\n', size(temp_data, 1));
end