clearvars;
%close all;
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
    [r_all]= runFlatNoiseExperiment(soa,no_trials,noise);
    disp('time of simulation')
    toc
end

plotProbability(r_all, 100);

hold off
