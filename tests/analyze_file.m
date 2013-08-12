function analyze_file(filename, filepath, config)
    data_filename   = [filepath filename];
    result_folder = [data_filename '_results/'];
    result_filename = [result_folder filename '_results.txt'];
    
    if ~exist(result_folder, 'file')
        mkdir(result_folder);
    end
    
    result_file = fopen(result_filename, 'w');
    data_file = fopen(data_filename, 'r');
    
    %load in data
    deltat = 1/config.framerate;
    t = [];
    x = [];
    y = [];
    i = 1;
    
    current_line = fgetl(data_file);
    while ischar(current_line)
        raw_data = str2num(current_line);
        %assumes 1-based frame indexing
        t(i) = (raw_data(config.frame_col))*deltat;
        x(i) = raw_data(config.x_col)*config.x_scale;
        y(i) = raw_data(config.y_col)*config.y_scale;
        
        current_line = fgetl(data_file);
        i = i + 1;
    end
    
    %analyze data
    t = t - min(t);
    x = x - x(1);
    y = y - y(1);
    r2 = x.^2 + y.^2;
    r = sqrt(r2);
    
    slope = sum(r2)/sum(t);
    line = slope*t;
    coeff = slope/4;
    
    intervals = linspace(min(t),max(t),config.n_bins+1);
    binned_t = cell(config.n_bins,1);
    binned_x = cell(config.n_bins,1);
    binned_y = cell(config.n_bins,1);
    
    for i = 2:config.n_bins + 1
        range = (t >= intervals(i-1)) & (t < intervals(i));
        if i == config.n_bins + 1
            range = range | t == intervals(i);
        end
        binned_t{i-1} = t(range);
        binned_x{i-1} = x(range);
        binned_y{i-1} = y(range);
    end
    
    
    
    figure()
    hold all
    plot(t,r2)
    plot(t,line)
    plot_title = sprintf('Squared displacement vs. time.\nDiffusion Coefficient: %2.5f', coeff);
    title(plot_title)
    
    
    %print results
    fprintf(result_file, 'Results from analyzing %s\n', filename);
    fprintf(result_file, 'Diffusion coefficient: %f um^2/s',coeff);
    
    
    fclose(result_file);
    fclose(data_file);
end