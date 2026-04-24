function [b_value, a_value, mc] = calculateBValue(magnitudes)
% CALCULATEBVALUE Calculates Gutenberg-Richter b-value from magnitude data
%   [b_value, a_value, mc] = calculateBValue(magnitudes)
%   Calculates the b-value, a-value, and completeness magnitude (Mc)
%   using the maximum likelihood method
%
%   Input:
%       magnitudes - vector of earthquake magnitudes
%
%   Output:
%       b_value - the Gutenberg-Richter b-value
%       a_value - the Gutenberg-Richter a-value
%       mc - the completeness magnitude (min magnitude of completeness)

    fprintf('  Calculating Gutenberg-Richter parameters...\n');
    
    % Remove NaN or infinite values
    magnitudes = magnitudes(isfinite(magnitudes));
    
    if isempty(magnitudes)
        error('No valid magnitude data to calculate b-value');
    end
    
    % Determine magnitude of completeness (Mc) using maximum curvature method
    bin_width = 0.1;
    mag_min = floor(min(magnitudes) / bin_width) * bin_width;
    mag_max = ceil(max(magnitudes) / bin_width) * bin_width;
    mag_edges = mag_min:bin_width:mag_max;
    
    % Create histogram
    [N, ~] = histcounts(magnitudes, mag_edges);
    mag_centers = mag_edges(1:end-1) + bin_width/2;
    
    % Find magnitude of completeness as the magnitude with the highest frequency
    [~, max_idx] = max(N);
    mc = mag_centers(max_idx);
    
    % Use magnitudes >= Mc for b-value calculation
    complete_mags = magnitudes(magnitudes >= mc);
    
    if length(complete_mags) < 50
        warning('Small sample size (%d events) for b-value calculation. Results may be unreliable.', length(complete_mags));
    end
    
    % Maximum likelihood estimate of b-value (Aki, 1965)
    mean_mag = mean(complete_mags);
    b_value = log10(exp(1)) / (mean_mag - mc + bin_width/2);
    
    % Calculate a-value
    N_mc = sum(magnitudes >= mc);
    a_value = log10(N_mc) + b_value * mc;
    
    fprintf('  Using %d events with M >= %.2f for b-value calculation\n', ...
        length(complete_mags), mc);
end