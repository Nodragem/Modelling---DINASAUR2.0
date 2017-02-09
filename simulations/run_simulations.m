clearvars;
close all;
addpath('util')

% Initially the model was made to explain the behavior of human participants
% during an experiment where we present them a target and a distractor.
% the experiment consist of a lot of trials of ~1s. From which we estimate the reaction time distributions.
% Because of that, here, the authors called an iteration a trial (because it correspond a trial of one participant in our experiment )
% and they call a simulation a bunch of N iterations/trials (that would correspond to a session of N trials for one participant).
% [simulation ID, SOA (time distance between target and distractor), nb trials, amplitude of white noise]

sim_keys = ['ID', 'SOA', 'nbTrials', 'noise_amplitude'];
sim_values=[
    1 -60 1200 50;
    2 -40 1200 50
    3 -20 1200 50
    4 0 1200 50;
    5 20 1200 50
    6 40 1200 50;
    7 60 1200 50;
  ];

% 
% sim_values=[ 
%      1 0 100 50; 
%      ];

for ID=sim_values(:,1)' % we run only 1 simulation of 100 iterations/trials here
    disp('Simulation:  '); disp(sim_values(ID, :));
    soa=sim_values(ID,2);
    no_trials=sim_values(ID,3);
    noise=sim_values(ID,4);

    tic
    % run the simulation 100 times:
    [targ_RTs, dist_RTs, rall, u]= runDinasaur2(soa, no_trials, noise);
    disp('time of simulation')
    toc
    
    tic
    results(ID).keys = sim_keys;
    results(ID).values = sim_values(ID,:);
    results(ID).target_RTs = targ_RTs;
    results(ID).distractor_RTs = dist_RTs;
    results(ID).firing_rate = rall;
    results(ID).membrane_potential = u;    
    save('results_distance.mat', 'results')
    disp('time saving data')
    toc
    
end

