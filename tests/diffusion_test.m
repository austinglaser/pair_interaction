[coefficient velocity] = particle_diffusion('./configuration.ini');

lower_lim = log(0.5)/log(10);
upper_lim = log(5)/log(10);

exp_velocity = logspace(lower_lim,upper_lim, 21);

figure()
subplot(1,2,1)
hold all

errorbar(exp_velocity,[coefficient.value],[coefficient.error],'bx')
plot(exp_velocity,0.5*ones(size(exp_velocity)),'k')

set(gca, 'xscale','log','yscale','lin')
xlabel('Induced Systematic Drift (um/s)')
ylabel('Measured Diffusion Coefficient (um^2/s)')
axis([10^(lower_lim-0.2) 10^(upper_lim+0.2) 0 1])
% axis([10^(lower_lim-0.2) 10^(upper_lim+0.2) min([coeff.x coeff.y]) - 0.2 max([coeff.x coeff.y]) + 0.2])

subplot(1,2,2)
hold all

errorbar(exp_velocity,[velocity.value],[velocity.error],'bx')
plot(exp_velocity,exp_velocity,'k')

set(gca, 'xscale','log','yscale','log')
xlabel('Induced Systematic Drift (um/s)')
ylabel('Measured Systematic Drift (um/s)')
axis([10^(lower_lim-0.2) 10^(upper_lim+0.2) 10^(lower_lim-0.2) 10^(upper_lim+0.2)])
% axis([0 6 0 6])