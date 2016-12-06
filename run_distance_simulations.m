clearvars;
close all;
addpath('util')
mkdir('./results', 'distances')
% Initially the model was made to explain the behavior of human participants
% during an experiment where we present them a target and a distractor.
% the experiment consist of a lot of trials of ~1s. From which we estimate the reaction time distributions.
% Because of that, here, the authors called an iteration a trial (because it correspond a trial of one participant in our experiment )
% and they call a simulation a bunch of N iterations/trials (that would correspond to a session of N trials for one participant).
% [simulation ID, SOA (time distance between target and distractor), nb trials, amplitude of white noise]

sim_keys = {'IDs' 'SOA' 'TargetPos' 'DistractorPos'...
'TargetWeight' 'DistractorWeight' 'nbTrials' 'noise_amplitude'};

sim_values = [];
for i=1:8;
  sim_values(i,:) = [i, 0, 0+i*10, 10, 1, 0, 100, 50];
end
sim_values = array2table(sim_values, 'VariableNames', sim_keys);
disp('To Simulate:')
disp(sim_values)
writetable(sim_values, './results/distances/table_distance.csv')


for row = 1:size(sim_values, 1) % we run only 1 simulation of 100 iterations/trials here
    disp('Current Simulation:  '); disp(sim_values{row, :});
    tic
    % run the simulation 100 times:
    [targ_RTs, dist_RTs, rall, uall]= runDinasaur2(sim_values(row,:));
    disp('time of simulation')
    toc

    tic
    results.keys = sim_keys;
    results.values = table2array(sim_values(row,:));
    results.firing_rate = rall;
    % note that we can transform the firing rate to membrane potential with
    % an inverse function.
    save(['./results/distances/results_', num2str(row), '_distance.mat'], 'results')
    disp('time saving data')
    toc

end
