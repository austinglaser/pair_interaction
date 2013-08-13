function r_s = rand_walk(n_particles, n_steps, t_sample,show_plot)
    n_samples = floor(n_steps/t_sample);
    
    dr = sqrt(2);
    
    r_s = zeros(n_particles, 2, n_samples);
    loc = [0 0];
    
    bounds = [-10 10 -10 10];
    
    for i = 1:n_particles 
        outputfile = fopen(['./tracks/track_' num2str(i)], 'w');
        
        loc = [0 0];
        if show_plot
            clf
            
            frame_samplerate = 1;
        end
        for t = 2:n_steps
            if mod(t,t_sample) == 0
                r_s(i,:,t/t_sample) = loc;
               fprintf(outputfile, '%d\t%d\t%d\t0\t0\n', t/t_sample, loc);
                
                if show_plot && (mod(t/t_sample, frame_samplerate) == 0)
                    plot(squeeze(r_s(i,1,1:t/t_sample)),squeeze(r_s(i,2,1:t/t_sample)));
                    axis(bounds)
                    
                    plot_title = sprintf('Brownian Diffusion Simulation\nTime Step %d\nParticle Location (%2.3f, %2.3f)',t,loc);
                    
                    title(plot_title)
                    drawnow
                    
                    walk(t/(t_sample*frame_samplerate)) = getframe(gcf);
                end
            end
            
            theta = rand(1)*128*pi;

            dx = dr*cos(theta);
            dy = dr*sin(theta);

            loc = loc + [dx dy];

            mag = max(abs(loc));
            if mag > bounds(2)
                lim = mag + 0.5;
                bounds = [-lim lim -lim lim];
            end
        end
        
       fclose(outputfile);
    end
    
    if show_plot
        disp('Saving movie...')
        writerObj = VideoWriter('./videos/brownian_walk_example', 'MPEG-4');
        writeVideo(writerObj, walk)
    end
end