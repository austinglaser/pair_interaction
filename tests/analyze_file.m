function analyze_file(filename, filepath, config)
    data_filename   = [filepath filename];
    result_folder   = [data_filename '_results/'];
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
        t(i) = (raw_data(config.frame_col))*deltat;
        x(i) = raw_data(config.x_col)*config.x_scale;
        y(i) = raw_data(config.y_col)*config.y_scale;
        
        current_line = fgetl(data_file);
        i = i + 1;
    end
    
    % sort by t
    [t, inds] = sort(t);
    x = x(inds);
    y = y(inds);
    
    % normalize
    t = t - t(1);
    x = x - x(1);
    y = y - y(1);
    
    %analyze data
    max_steps = 25;
    
    vel_x = zeros(1,max_steps);
    vel_y = zeros(1,max_steps);
    
    var_x = zeros(1,max_steps);
    var_y = zeros(1,max_steps);
    
    diff_x = zeros(1,max_steps);
    diff_y = zeros(1,max_steps);
    
    for step = 1:max_steps
        end_x = x(1:step:end);
        end_y = y(1:step:end);
        start_x = [0 end_x(1:(end-1))];
        start_y = [0 end_y(1:(end-1))];
        disp_x = end_x - start_x;
        disp_y = end_y - start_y;

        interval = step*deltat;
        
        offset_x = mean(disp_x);
        offset_y = mean(disp_y);
        
        vel_x(step) = offset_x/interval;
        vel_y(step) = offset_y/interval;
        
        velocity_corrected_x = disp_x - offset_x;
        velocity_corrected_y = disp_y - offset_y;
        
        var_x(step) = var(velocity_corrected_x);
        var_y(step) = var(velocity_corrected_y);
        
        diff_x(step) = var_x(step)/(2*interval);
        diff_y(step) = var_y(step)/(2*interval);
    end

    coeff_x = mean(diff_x);
    coeff_y = mean(diff_y);
    
    drift_x = mean(vel_x);
    drift_y = mean(vel_y);
    
    figure()
    
    subplot(1,2,1)
    hold all
    plot(vel_x,'.')
    plot(vel_y,'.')
    
    subplot(1,2,2)
    hold all
    plot(var_x,'.')
    plot(var_y,'.')
    
    
    %print results
    fprintf(result_file, 'Results from analyzing %s\n', filename);
    fprintf(result_file, 'X Diffusion Coefficient:\t%e\n',coeff_x);
    fprintf(result_file, 'Y Diffusion Coefficient:\t%e\n',coeff_y);
    fprintf(result_file, 'X Systematic Drift:\t\t\t%e\n',drift_x);
    fprintf(result_file, 'Y Systematic Drift:\t\t\t%e\n',drift_y);
    
    
    fclose(result_file);
    fclose(data_file);
end