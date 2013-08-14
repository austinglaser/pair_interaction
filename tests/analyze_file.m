function [coeff,drift] = analyze_file(filename, filepath, config)
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
    
    %analyze data
    max_step = 25;
    
    n_bins = floor(size(t,2)/config.bin_size);
    
    if (n_bins == 0)
        error('analyze_file:bin_size','Bin size too large; specify size smaller than dataset length');
    end
    
    t_binned = zeros(n_bins, config.bin_size);
    x_binned = zeros(n_bins, config.bin_size);
    y_binned = zeros(n_bins, config.bin_size);
    
    
    for i = 1:n_bins
        binstart = (i - 1)*config.bin_size + 1;
        binend   = i*config.bin_size;
        
        t_binned(i,:) = t(binstart:binend) - t(binstart);
        x_binned(i,:) = x(binstart:binend) - x(binstart);
        y_binned(i,:) = y(binstart:binend) - y(binstart);
    end
    
    velocity_x = zeros(n_bins,max_step);
    velocity_y = zeros(n_bins,max_step);
    
    variance_x = zeros(n_bins,max_step);
    variance_y = zeros(n_bins,max_step);
    
    diffusion_x = zeros(n_bins,max_step);
    diffusion_y = zeros(n_bins,max_step);
    
    for bin = 1:n_bins
        for step = 1:max_step
            endpoint_x = x_binned(bin,1:step:end);
            endpoint_y = y_binned(bin,1:step:end);
            startpoint_x = [0 endpoint_x(1:(end-1))];
            startpoint_y = [0 endpoint_y(1:(end-1))];
            disp_x = endpoint_x - startpoint_x;
            disp_y = endpoint_y - startpoint_y;
            
            interval = step*delta_t;
            
            offset_x = mean(disp_x);
            offset_y = mean(disp_y);
            
            velocity_x(bin,step) = offset_x/interval;
            velocity_y(bin,step) = offset_y/interval;
            
            velocity_corrected_x = disp_x - offset_x;
            velocity_corrected_y = disp_y - offset_y;
            
            variance_x(bin,step) = var(velocity_corrected_x);
            variance_y(bin,step) = var(velocity_corrected_y);
            
            diffusion_x(bin,step) = variance_x(bin,step)/(2*interval);
            diffusion_y(bin,step) = variance_y(bin,step)/(2*interval);
        end
    end
    
    error_factor = 1/sqrt(n_bins);

    coeff.x = mean(mean(diffusion_x));
    coeff.y = mean(mean(diffusion_y));
    coeff.x_error = error_factor*std(mean(diffusion_x));
    coeff.y_error = error_factor*std(mean(diffusion_y));
    
    variance_error_x = error_factor*std(variance_x);
    variance_error_y = error_factor*std(variance_y);
    
    drift.x = mean(mean(velocity_x));
    drift.y = mean(mean(velocity_y));
    drift.x_error = error_factor*std(mean(velocity_x));
    drift.y_error = error_factor*std(mean(velocity_y));
    
    velocity_error_x = error_factor*std(velocity_x);
    velocity_error_y = error_factor*std(velocity_y);
    
    figure()
    
    subplot(1,2,1)
    hold all
    errorbar(mean(velocity_x,1),velocity_error_x,'b.')
    errorbar(mean(velocity_y,1),velocity_error_y,'g.')
    
    subplot(1,2,2)
    hold all
    errorbar(mean(variance_x,1),variance_error_x,'b.')
    errorbar(mean(variance_y,1),variance_error_y,'g.')
    
    %print results
    fprintf(result_file, 'Results from analyzing %s\n', filename);
    fprintf(result_file, 'X Diffusion Coefficient:\t%e +/- %e\n',coeff.x,coeff.x_error);
    fprintf(result_file, 'Y Diffusion Coefficient:\t%e +/- %e\n',coeff.y,coeff.y_error);
    fprintf(result_file, 'X Systematic Drift:\t\t\t%e +/- %e\n',drift.x,drift.x_error);
    fprintf(result_file, 'Y Systematic Drift:\t\t\t%e +/- %e\n',drift.y,drift.y_error);
    
    
    fclose(result_file);
end