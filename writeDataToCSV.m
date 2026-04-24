function writeDataToCSV(data, headers, filename)
% WRITEDATATOCSV Writes data to a CSV file
%   writeDataToCSV(data, headers, filename)
%   Writes data matrix and headers to a CSV file
%
%   Input:
%       data - matrix of data (numeric or cell array)
%       headers - cell array of column names
%       filename - output filename

    fprintf('  Writing data to %s... ', filename);
    
    % Open file for writing
    fid = fopen(filename, 'w');
    
    % Check if file opened successfully
    if fid == -1
        error('Could not open file for writing: %s', filename);
    end
    
    % Write headers
    for i = 1:length(headers)
        fprintf(fid, '%s', headers{i});
        if i < length(headers)
            fprintf(fid, ',');
        end
    end
    fprintf(fid, '\n');
    
    % Write data
    [rows, cols] = size(data);
    for i = 1:rows
        for j = 1:cols
            % Handle different data types
            if iscell(data)
                value = data{i, j};
                if ischar(value)
                    % Check if value contains commas or newlines
                    if contains(value, ',') || contains(value, '"') || contains(value, char(10))
                        % Escape quotes and wrap in quotes
                        value = strrep(value, '"', '""');
                        fprintf(fid, '"%s"', value);
                    else
                        fprintf(fid, '%s', value);
                    end
                elseif isnumeric(value)
                    fprintf(fid, '%g', value);
                else
                    fprintf(fid, '%s', 'NA');
                end
            elseif isnumeric(data)
                if isnan(data(i, j))
                    fprintf(fid, 'NA');
                else
                    fprintf(fid, '%g', data(i, j));
                end
            else
                fprintf(fid, '%s', 'NA');
            end
            
            % Add comma if not the last column
            if j < cols
                fprintf(fid, ',');
            end
        end
        fprintf(fid, '\n');
    end
    
    % Close file
    fclose(fid);
    
    fprintf('Done.\n');
end