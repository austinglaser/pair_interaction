function prefs = read_prefs(config_file)
% Utility for reading preferences from .ini file

    config_id = fopen(config_file, 'r');

    config_line = fgetl(config_id);
    while ischar(config_line)
        % Don't look at comments or blank lines
        if (length(config_line) >= 1) && (config_line(1) ~= '#')
            config_line(ismember(config_line,' ')) = [];
            [option, value] = strsplit(config_line, '=');
            disp(config_line)
            disp(option)
            disp(value)
        end
        config_line = fgetl(config_id);
    end

    fclose(config_id);

    prefs = [];
end