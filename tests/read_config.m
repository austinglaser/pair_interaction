function config = read_config(config_filename,exp_options)
%READ_CONFIG Reads options from a .ini file, storing them as a struct
%
% SYNOPSIS: config = read_config(config_file,exp_options)
%
% INPUT  config_file: The path to a properly formatted .ini file
%        exp_options: The options expected to be present in the
%                     configuration file
%
% OUTPUT config: A struct with a field for each option present
%
% Reads program configuration from an .ini file. This is a text file, where each
% nonblank, noncommented line corresponds to an available option.
%
% exp_options is a cell array of available options. Each row of the array
% is of the format {'opt_name', default_value}. If default value is an
% empty array, the option will cause the program to halt if it is not
% present in the configuration file.
%
% More detailed help is in the <a href="matlab: help read_config>extended_help">extended help</a>.

    config_file = fopen(config_filename, 'r');

    % Read in raw data from the configuration file
    i = 1;
    raw_config = {};
    current_line = fgetl(config_file);
    while ischar(current_line)
        % Don't look at blank lines or comments
        current_line = strtrim(current_line);
        if (length(current_line) >= 1) && (current_line(1) ~= '#')
            current_line = current_line(current_line ~= ' ');
            current_option = strsplit(current_line, '=');
            
            raw_config(i,:) = current_option;
            i = i + 1;
        end
        current_line = fgetl(config_file);
    end

    fclose(config_file);
    
    %search for values
    
    for i = 1:size(exp_options,1)
        % look for the current option
        opt = find(strcmp(raw_config,exp_options{i,1}));
        
        % if it's present
        if ~isempty(opt)
            
            % check whether it should be treated as a number or a string
            option = raw_config{opt,2};
            isstring = ((option(1) == '"') && (option(end) == '"'));
            
            if isstring
                val = option(option ~= '"');
                val = strsplit(val,',');
                
            else
                val = str2num(option);
            end
            
            % remove the relevant line
            index = true(1,size(raw_config,1));
            index(opt) = false;
            raw_config = raw_config(index,:);
        end
        
        % check for invalid option
        if isempty(opt) || (~isstring && isnan(val))
            
            % throw warning or error
            if isempty(exp_options{i,2})
                error('read_config:opt_not_set','Option "%s" not set or set to invalid value.',exp_options{i,1});
            else
                config.(exp_options{i,1}) = exp_options{i,2};
                warning('read_config:opt_not_set','Option "%s" not set or set to invalid value. Setting to default value of %d', exp_options{i,2});
            end
        else
            config.(exp_options{i,1}) = val;
        end
    end
    
    for i = 1:size(raw_config,1)
        warning('read_config:unrecognized_opt','Option "%s" not recognized. Ignoring.', raw_config{i,1});
    end
end

function extended_help
% An example configuration file:
%
% # This is a comment
% # String options are denoted by quotation marks, and fields separated by
% # commas
% str_opt = "hello","there"
% 
% # Numerical options are denoted with equal signs.
% # They can be scalars, or MATLAB matrices
% num_opt = 5
% arr_opt = [1 2; 3 4]
%
% The corresponding expected options (exp_options) cell array:
%
% exp_options = {...
%                'str_opt', 'hi!'; ...
%                'num_opt',  20; ...
%                'arr_opt', [] ...
%               };
%
% In this example, arr_opt is a 'fatal' option; that is, if it is not
% specified in the configuration file, it will cause the entire program to
% halt.

    error('Just used to display help')
end