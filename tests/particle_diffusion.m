function particle_diffusion(config_file)
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
                    'n_bins',    1
                  };

    config = read_config(config_file,exp_options);

    % Analyze data
    for i = 1:size(config.folders,2)
        % load file
        path = config.folders{i};
        if path(end) ~= '/'
            path = [path '/'];
        end

        files = dir(path);
        
        for j = 1:size(files,1)
            if ~(files(j).isdir)
                analyze_file(files(j).name, path, config);
            end
        end
    end
end