% shuffle the random generator of MATLAB to avoid to get the same results
rng('shuffle');

fixation_pole = 60;
field_size = 120;
dt = 1;
fixation = mirrorGaussian(fixation_pole, 1, 5, field_size)';
target = mirrorGaussian(30, 1, 5, field_size)';
distractor = mirrorGaussian(90, 0.7, 5, field_size)';

field = target + fixation + distractor;
nb_simulations = 1000;
locations = NaN([1, nb_simulations]);
for trial=1:1000
  [loc, threshold] = ...
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
plot(field*nb_simulations/4, 1:field_size, 'g')
hold on
plot(threshold*nb_simulations/4, 1:field_size)
line([nb_simulations/4, nb_simulations/4], [0, 120])
plot(locations, 'ro')
subplot(1,2,2)
histogram(locations, 100)
