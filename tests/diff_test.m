%get trajectory data
fprintf('Simulating Particles\n')
n_particles = 10;
n_steps = 10000;
timestep = 10;
n_samples = floor(n_steps/timestep);

r_s = rand_walk(n_particles,n_steps,timestep,false);

%calculate average displacement (ensemble-average)
fprintf('Calculating Displacement\n')
diff_ens = squeeze(sum(r_s.^2,1)/size(r_s,1) + ...
                   (sum(r_s,1)/size(r_s,1)).^2)/2;

%calculate average displacement (time-average)
disp_tim = zeros(n_particles,2,n_samples);

for shift = 1:(n_samples - 1)
    r_s_shift = r_s(:,:,(1+shift):n_samples);
    r_s_unsh = r_s(:,:,1:(n_samples - shift));
    disp_tim(:,:,shift) = sum(abs(r_s_shift - r_s_unsh), ...
                              3)/(n_samples - shift);
end

diff_tim = squeeze(mean(disp_tim,1));

%fit lines through origin
fprintf('Fitting and Calculating Slope\n')
t = 0:(size(diff_ens,2)-1);

coeff_ens = sum(diff_ens(:,1:100),2)/sum(t(1:100));
coeff_tim = sum(diff_tim(:,1:100),2)/sum(t(1:100));
line_ens = coeff_ens*t;
line_tim = coeff_tim*t;

resid_ens = diff_ens(:,1:100) - line_ens(:,1:100);
resid_tim = diff_tim(:,1:100) - line_tim(:,1:100);
ss_resid_ens = sum(resid_ens.^2,2);
ss_resid_tim = sum(resid_tim.^2,2);
ss_total_ens = 99*var(diff_ens(:,1:100),0,2);
ss_total_tim = 99*var(diff_tim(:,1:100),0,2);

rsq_ens = 1 - ss_resid_ens./ss_total_ens;
rsq_tim = 1 - ss_resid_tim./ss_total_tim;

% rsq_max = [0 0];
% 
% for i = 5:5:length(diff_ens)
%     fprintf('First %d points: ', i);
%     coeff_tmp = sum(diff_ens(:,1:i),2)/sum(t(1:i));
%     line_tmp = coeff_tmp*t;
%     
%     resid = diff_ens(:,1:i) - line_tmp(:,1:i);
%     ss_resid = sum(resid.^2,2);
%     ss_total = (i - 1)*var(diff_ens(:,1:i),0,2);
%     
%     rsq = 1 - ss_resid./ss_total;
%     
%     fprintf('correlation (x,y): (%f, %f)\n', rsq);
%     
%     if rsq(1) >= rsq_max(1)
%         fprintf('New max (1)!\n');
%         rsq_max(1) = rsq(1);
%         line_ens(1,:) = line_tmp(1,:);
%         coeff_ens(1) = coeff_tmp(1);
%     end
%     
%     if rsq(2) >= rsq_max(2)
%         fprintf('New max (2)!\n');
%         rsq_max(2) = rsq(2);
%         line_ens(1,:) = line_tmp(1,:);
%         coeff_ens(2) = coeff_tmp(2);
%     end
% end
% 
% line_tmp = zeros(2,length(t));
% coeff_tmp = [0 0];
% 
% rsq_max = [0 0];
% 
% for i = 5:5:length(diff_tim)
%     fprintf('First %d points: ', i);
%     coeff_tmp = sum(diff_tim(:,1:i),2)/sum(t(1:i));
%     line_tmp = coeff_tmp*t;
%     
%     resid = diff_tim(:,1:i) - line_tmp(:,1:i);
%     ss_resid = sum(resid.^2,2);
%     ss_total = (i - 1)*var(diff_tim(:,1:i),0,2);
%     
%     rsq = 1 - ss_resid./ss_total;
%     
%     fprintf('correlation (x,y): (%f, %f)\n', rsq);
%     
%     if rsq(1) >= rsq_max(1)
%         fprintf('New max (1)!\n');
%         rsq_max(1) = rsq(1);
%         line_tim(1,:) = line_tmp(1,:);
%         coeff_tim(1) = coeff_tmp(1);
%     end
%     
%     if rsq(2) >= rsq_max(2)
%         fprintf('New max (2)!\n');
%         rsq_max(2) = rsq(2);
%         line_tim(1,:) = line_tmp(1,:);
%         coeff_tim(2) = coeff_tmp(2);
%     end
% end

%plot
fprintf('Plotting\n')
clf

%ensemble average
subplot(2,2,2)
hold all

plot(diff_ens(1,:))
plot(diff_ens(2,:))
plot(line_ens(1,:))
plot(line_ens(2,:))

plottitle = sprintf('Average Displacement vs. Time\nEnsemble Average Method\nD_x: %f    D_y: %f',coeff_ens);
title(plottitle)

%time average
subplot(2,2,4)
hold all

plot(diff_tim(1,:))
plot(diff_tim(2,:))
plot(line_tim(1,:))
plot(line_tim(2,:))

plottitle = sprintf('Average Displacement vs. Time\nTime Average Method\nD_x: %f    D_y: %f',coeff_tim);
title(plottitle)

%tracks
subplot(2,2,[1 3])
hold all

plottitle = sprintf('Particle Tracks');
title(plottitle)

for i =  1:size(r_s,1)
    plot(squeeze(r_s(i,1,:)),squeeze(r_s(i,2,:)))
end

axis square