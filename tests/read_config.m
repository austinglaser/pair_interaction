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
    
    %search for values
    
    found = zeros(size(raw_config, 1), 1);
    
    i = find(strcmp(raw_config, 'folders'));
    if isempty(i)
        error('read_config:folders', 'No input folder specified (add the line "folders = path1, path2, ... , pathn" to the configuration file)');
    else
        config.folders = raw_config{i,2};
        config.folders = strsplit(config.folders,',');
        found(i) = 1;
    end
    
    i = find(strcmp(raw_config, 'framerate'));
    if isempty(i)
        config.framerate = 10;
        warning('read_config:framerate','Framerate unspecified: defaulting to 24 fps');
    else
        config.framerate = str2double(raw_config{i,2});
        if isnan(config.framerate)
            warning('read_config:framerate','Framerate invalid: defaulting to 24 fps');
        else
            found(i) = 1;
        end
    end
    
    i = find(strcmp(raw_config, 'x_scale'));
    if isempty(i)
        config.x_scale = 1;
        warning('read_config:x_scale','X scale unspecified: defaulting to 1 um/pixel');
    else
        config.x_scale = str2double(raw_config{i,2});
        if isnan(config.x_scale)
            warning('read_config:x_scale','X scale invalid: defaulting to 1 um/pixel');
        else
            found(i) = 1;
        end
    end
    
    i = find(strcmp(raw_config, 'y_scale'));
    if isempty(i)
        config.y_scale = 1;
        warning('read_config:y_scale','Y scale unspecified: defaulting to 1 um/pixel');
    else
        config.y_scale = str2double(raw_config{i,2});
        if isnan(config.y_scale)
            warning('read_config:y_scale','Y scale invalid: defaulting to 1 um/pixel');
        else
            found(i) = 1;
        end
    end
    
    i = find(strcmp(raw_config, 'frame_col'));
    if isempty(i)
        config.frame_col = 1;
        warning('read_config:frame_col','Column for frame data unspecified: defaulting to column 1');
    else
        config.frame_col = str2double(raw_config{i,2});
        if isnan(config.frame_col)
            warning('read_config:frame_col','Column for frame data invalid: defaulting to column 1');
        else
            found(i) = 1;
        end
    end
    
    i = find(strcmp(raw_config, 'x_col'));
    if isempty(i)
        config.x_col = 2;
        warning('read_config:x_col','Column for x position data unspecified: defaulting to column 2');
    else
        config.x_col = str2double(raw_config{i,2});
        if isnan(config.x_col)
            warning('read_config:x_col','Column for x position data invalid: defaulting to column 2');
        else
            found(i) = 1;
        end
    end
    
    i = find(strcmp(raw_config, 'y_col'));
    if isempty(i)
        config.y_col = 3;
        warning('read_config:y_col','Column for y position data unspecified: defaulting to column 3');
    else
        config.y_col = str2double(raw_config{i,2});
        if isnan(config.framerate)
            warning('read_config:y_col','Column for y position data invalid: defaulting to column 3');
        ene
            found(i) = 1;
        end
    end
    
    for i = find(~found)
        msg = sprintf('Unrecognized option %s. Ignoring.', raw_config{i,1});
        warning('read_config:unrecognized',msg);
    end
end