function config = read_config(config_file)
% Utility for reading preferences from .ini file

    config_id = fopen(config_file, 'r');

    i = 1;
    raw_config = {};
    current_line = fgetl(config_id);
    while ischar(current_line)
        % Don't look at comments or blank lines
        if (length(current_line) >= 1) && (current_line(1) ~= '#')
            current_line(ismember(current_line,' ')) = [];
            current_option = strsplit(current_line, '=');
            
            raw_config(i,:) = current_option;
            i = i + 1;
        end
        current_line = fgetl(config_id);
    end

    fclose(config_id);
    
    %default values, overwritten if present in config file
    config.framerate = 24;
    config.x_cal = 1;
    config.y_cal = 1;
    config.frame_col = 1;
    config.x_col = 2;
    config.y_col = 3;
    
    for i = 1:size(raw_config, 1)
        switch raw_config{i,1}
            case 'folders'
                config.folders = raw_config{i,2};
                config.folders = strsplit(config.folders,',');
                
            case 'framerate'
                temp = str2double(raw_config{i,2});
                if ~isnan(temp)
                    config.framerate = temp;
                else
                    fprintf('Invalid value for option "%s." Using default value of %f', ...
                             raw_config{i,1}, config.framerate);
                end
                
            case 'x_cal'
                temp = str2double(raw_config{i,2});
                if ~isnan(temp)
                    config.x_cal = temp;
                else
                    fprintf('Invalid value for option "%s." Using default value of %f', ...
                             raw_config{i,1}, config.x_cal);
                end
            case 'y_cal'
                config.y_cal = str2double(raw_config{i,2});
            case 'frame_col'
                config.frame_col = str2double(raw_config{i,2});
            case 'x_col'
                config.x_col = str2double(raw_config{i,2});
            case 'y_col'
                config.y_col = str2double(raw_config{i,2});
            otherwise
                fprintf('Unrecognized option "%s." Ignoring.\n', raw_config{i,1});
        end
    end
end