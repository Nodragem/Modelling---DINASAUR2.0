function [locations, threshold] = applyStochasticThreshold(fr, fixation_pole, field_size, dt)
  % -- DESCRIPTION --
  % The threshold to trigger a saccade is unhomogenous over space (exponential
  % by default). Furthermore the threshold is stochastic: the distance of the
  % firing rate to the threshold defines a probability to trigger a saccade.
  % This probability function is the escape function.
  %
  % Returns:
  % ----------
  % locations: [array]
  %           The user will check if locations isempty to know whether the
  %           threshold was reached
  persistent first_time;
  persistent threshold_func;  % shape of the threshold over space
  persistent tau; persistent beta0;
  if isempty(first_time)
    first_time = false;
    x = (1:field_size) - fixation_pole;
    tau = 0.5; beta0 = 10.0;
    threshold_func = zeros(1, field_size);
    threshold_func(1, 1:fixation_pole) = exp(x(1:fixation_pole)/20) + 0.85;
    threshold_func(1, fixation_pole:end) = exp(-x(fixation_pole:end)/20) + 0.85;

    figure
    subplot(2,1,1)
    plot(threshold_func)
    line([25, 25], [0 3])
    title('threshold')
    subplot(2, 1, 2)
    space = 0:0.01:1;
    plot(space, 1 - exp(-dt * escape_func(space)) )
    title({'probability to trigger', '(according to distance from threshold)'})
  end
  threshold = threshold_func; % DON'T REMOVE: that is for the output
  distance = fr - threshold_func; % REMEMBER: the distance is negative when under threshold
  escape_prob = escapeProbabilityFunction(distance, tau, beta0, dt);
  triggered = (rand(size(escape_prob)) < escape_prob);
  % note from python, we were doing complicated stuffs
  % that would have been translate into:
  % [trials, locations, times] = ind2sub(size(triggered),find(triggered));
  % and some more stuffs.
  % However, we are not concerned with time and trials anymore here
  locations = find(triggered);

end  % function
