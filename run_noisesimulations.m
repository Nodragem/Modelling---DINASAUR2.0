clearvars;
close all;
addpath('util')
nb_trials = 1200;
sim_tab=[ % here we just run 100 iterations to test the MATLAB version against the Python version
     1 0 nb_trials 50; % [simulation ID, SOA (time distance between target and distractor), nb trials, amplitude of white noise]
     ];


no_sim=size(sim_tab,1);

for sim=1:no_sim % we run only 1 simulation of 100 iterations/trials here
    sim_number=sim_tab(sim,1);
    soa=sim_tab(sim,2);
    no_trials=sim_tab(sim,3);
    noise=sim_tab(sim,4);

    tic
    [r_all]= runNoiseExperiment(soa,no_trials,noise);
    disp('time of simulation')
    toc
end

r_median = squeeze(median(r_all, 1));
r_25q = squeeze(quantile(r_all, 0.25, 1));
r_75q = squeeze(quantile(r_all, 0.75, 1));
r_mean = squeeze(mean(r_all, 1));
r_sd = squeeze(std(r_all, 1));
figure
set(gcf, 'PaperPosition', [0 0 16 9]); %Position plot at left hand corner with width 5 and height 5.
set(gcf, 'PaperSize', [16 9]);
% mean and sd
subplot(2,2,3)
% p1 = plot(r_mean(50, :), 'r');
hold on
% plot(r_mean(50, :)-r_sd(50, :), 'b')
% plot(r_mean(50, :)+r_sd(50, :), 'b')
% median and 25/75 quartiles
p2 = plot(r_median(50, :), 'Color', '[1 0.2 0.0]');
line([350, 350], [r_25q(50, 350), r_75q(50, 350)], 'Color', '[0 0.7 1]')
line([100, 100], [r_25q(50, 100), r_75q(50, 100)], 'Color', '[0 0.7 1]')
line([700, 700], [r_25q(50, 700), r_75q(50, 700)], 'Color', '[0 0.7 1]')
for l=[0, 0.85, 1]
ph = line([0 775], [l, l], 'Color', '[0.7 0.7 0.7]', 'LineStyle', '--');
end
hold on
pq = plot(r_75q(50, :), 'Color', '[1, 0.5, 0.5]');
plot(r_25q(50, :), 'Color', '[1, 0.5, 0.5]')
% legend([p1, p2], {'mean firing rate', 'median firingrate'}, 'Location', 'northwest')
legend([p2, ph, pq] , {'median firing rate', 'saccadic threshold', '25-75% quantiles'}, 'Location', 'northwest')
title('median firingrate at the target location')
xlabel('time (ms))')
ylabel('firing rate (normed Hz)')

subplot(2, 2, [1 2])
imshow(r_mean)
colormap hot
title('mean firing rate on the map accross trials')
xlabel('time (ms)')
ylabel('space (nodes)')

subplot(2, 2, 4)
rate_triggered = squeeze(sum((r_all(:,50,:) > 0.85), 1)/nb_trials);
distances = r_median(50, :) - 0.85;
p1 = plot(distances, rate_triggered, 'o');
line([0 0], [0, 1], 'Color', 'black');
[V, I] = min(abs(distances - 0));
p50rate = rate_triggered(I);
line([-1 0], [p50rate, p50rate], 'Color', 'black');
hold on
F = @(x, xdata)escapeProbabilityFunction(xdata, x(1), x(2), 1);
x0 = [0.1 10];
[x, resnorm, ~, exitflag, output] = lsqcurvefit(F, x0, distances, rate_triggered');
% >> x = 1.3586   11.4967
% manually adjusted to 1.4 and 10
p2 = plot(distances, F(x, distances), 'Color', '[0.7, 0.5, 1]'); % purple
p3 = plot(distances, F([1.4, 10], distances), 'Color', '[0.5, 1, 1]'); % bright blue
p4 = plot(distances, F([0.1, 10], distances), 'Color', '[1, 0.5, 0.5]'); % pink
legend([p1 p2 p3 p4], {'data from DINASAUR', 'best fit', 'manually adjusted fit', 'initial parameters'}, 'Location', 'northwest')
title('probability to trigger a saccade')
xlabel('firing rate distance to threshold (normed Hz)')
ylabel('probability (per millisecond slice)')

hold off
