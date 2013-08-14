function [coeff,drift] = particle_diffusion(config_file)
%PARTICLE_DIFFUSION Calculate the diffusion of a single particle.

    %Load configuration
    exp_options = {
                    'framerate', 10;
                    'x_scale',   1;
                    'y_scale',   1; 
                    'frame_col', 1;
                    'x_col',     2;
                    'y_col',     3;
                    'folders',   '';
                    'bin_size',    1000
                  };

    config = read_config(config_file,exp_options);

    % Analyze data
    
    num = 1;
    for i = 1:size(config.folders,2)
        % load file
        path = config.folders{i};
        if path(end) ~= '/'
            path = [path '/'];
        end

        files = dir(path);
        
        for j = 1:size(files,1)
            if ~(files(j).isdir)
                [coeff(num) drift(num)] = analyze_file(files(j).name, path, config);
                num = num + 1;
            end
        end
    end
end