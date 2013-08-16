function [coefficient,velocity] = analyze_file(filename, filepath, config)
    data_filename   = [filepath filename];
    result_folder   = [data_filename '_results/'];
    result_filename = [result_folder filename '_results.txt'];
    
    if ~exist(result_folder, 'file')
        mkdir(result_folder);
    end
    
    result_file = fopen(result_filename, 'w');
    
    %load in data
    delta_t = 1/config.framerate;
    
    raw_data = importdata(data_filename);
    t = (raw_data(:,config.frame_col)')*delta_t;
    x = (raw_data(:,config.x_col)')*config.x_scale;
    y = (raw_data(:,config.y_col)')*config.y_scale;
    
    % sort by t
    [t, inds] = sort(t);
    x = x(inds);
    y = y(inds);
    
    % normalize
    t = t - t(1);
    x = x - x(1);
    y = y - y(1);
    
    r = sqrt(x.^2 + y.^2);
    
    %analyze data
    n_bins = floor(size(t,2)/config.bin_size);
    
    if (n_bins == 0)
        error('analyze_file:bin_size','Bin size too large; specify size smaller than dataset length');
    end
    
    t_binned = zeros(n_bins, config.bin_size);
    r_binned = zeros(n_bins, config.bin_size);
    
    
    for i = 1:n_bins
        binstart = (i - 1)*config.bin_size + 1;
        binend   = i*config.bin_size;
        
        t_binned(i,:) = t(binstart:binend) - t(binstart);
        r_binned(i,:) = r(binstart:binend) - r(binstart);
    end

    step = 10;

    endpoint = r_binned(:,1:step:end);
    startpoint = [zeros(n_bins,1) endpoint(:,1:(end-1))];
    displacement = endpoint - startpoint;
    
    interval = step*delta_t;
    
    bin_offset = mean(displacement,2);
    bin_velocity = bin_offset/interval;
    
    velocity.value = mean(bin_velocity);
    velocity.error = (1/sqrt(n_bins - 1))*std(bin_velocity,0);
    
    bin_diffusion = var(displacement,0,2);
    bin_coefficient = bin_diffusion/(4*interval);
    
    coefficient.value = mean(bin_coefficient);
    coefficient.error = (1/sqrt(n_bins - 1))*std(bin_coefficient,0);
    
    %print results
    fprintf(result_file, 'Results from analyzing %s\n', filename);
    fprintf(result_file, 'Diffusion Coefficient:\t%e +/- %e\n',coefficient.value,coefficient.error);
    fprintf(result_file, 'Systematic Drift:\t\t\t%e +/- %e\n',velocity.value,velocity.error);
    
    fclose(result_file);
end