% test and showcase the function applyStochasticThreshold.m
clearvars;
clear applyStochasticThreshold;
addpath(genpath('/home/c1248317/Bitbucket/Dinasaur'))
% shuffle the random generator of MATLAB to avoid to get the same results
%rng('shuffle');

fixation_pole = 100;
field_size = 200;
dt = 1;
fixation = mirrorGaussian(fixation_pole, 1, 5, field_size)';
target = 0*mirrorGaussian(50, 1, 10, field_size)';
distractor = 0*mirrorGaussian(150, 0.7, 5, field_size)';

% we want a stochastic threshold that produces:
% - 1-2 microsaccades (saccade at the fixation) per seconds
% - not too much spatial variability
%    that depends on:
%      - the sigma of the input-evoked activity on the map
%      - the escape function that can cut this sigma

field = target + fixation + distractor;
nb_simulations = 10000; % can be seen as simulation time
locations = NaN([1, nb_simulations]);
for trial=1:nb_simulations
  [loc, threshold, prob] = ...
  applyStochasticThreshold(field, fixation_pole, field_size, dt);
  if ~isempty(loc)
    if length(loc) == 1
      locations(1, trial) = loc;
    else % if it is > 1, we need to select a location randomly
      locations(1, trial) = randsample(loc, 1);
    end
  end
end
figure
subplot(1,2,1)
plot(field*nb_simulations/4/1000, 1:field_size, 'Color', '[1, 0.7, 0.7]')
ylabel('Space (nodes)')
xlabel('Activity or Time (seconds)')
hold on
plot(threshold*nb_simulations/4/1000, 1:field_size)
line([nb_simulations/4/1000, nb_simulations/4/1000], [0, field_size])
plot( (1:nb_simulations)/1000, locations, 'r.')
subplot(1,2,2)
[f, x] = hist(locations, 100);
bar(x, f/10)
xlabel('Space (nodes)')
ylabel('Saccades/seconds')

% can the distractor trigger a saccade before the target does?
% figure
% first_locations = zeros([1, 1000]);
% for trial = 1:1000
%   spike_trial = randsample(locations, 1000);
%   first_locations(1, trial) = spike_trial(1);
% end
% histogram(first_locations, 100)