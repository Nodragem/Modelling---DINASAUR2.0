function [passed] = isStochasticThresholdPassed(fr, fixation_pole, field_size)
  % -- DESCRIPTION --
  % The threshold to trigger a saccade is unhomogenous over space (exponential
  % by default). Furthermore the threshold is stochastic: the distance of the
  % firing rate to the threshold defines a probability to trigger a saccade.
  % This probability function is the escape function.
  %

  persistent first_time;
  persistent center;
  persistent escape_func;     % shape of the escape function (proba to trigger)
  persistent threshold_func;  % shape of the threshold over space
  if isempty(first_time)
    first_time = false;
    x = (1:field_size) - fixation_pole;
    tau = 0.5; beta = 10.;
    center = fixation_pole;
    threshold_func = zeros(1, field_size);
    threshold_func(1, 1:fixation_pole) = exp(x(1:fixation_pole)/20) + 0.85;
    threshold_func(1, fixation_pole:end) = exp(-x(fixation_pole:end)/20) + 0.85;
    %plot(threshold_func)
    %line([25, 25], [0 3])
  end

  function [ out ] = escape_func(x)
    % see plot above, in real neurons it can be 19 ms and 4 mV
    out = 1 / tau * np.exp(beta * x)
  end

  distance = fr - threshold_array
  escape_prob = 1 - np.exp(-dt*escape_func(distance))
  triggered = np.random.uniform(low=0.0, high=1.0, size=escape_prob.shape) < escape_prob
  trials = np.where(triggered)[0]  % those are the trials that passes the trhreshold
  times = np.where(triggered)[2]
  locations = np.where(triggered)[1]
  index = np.zeros_like(np.unique(trials))
  nb_trials = 0
  for i, id in enumerate(np.unique(trials)):  % note that pandas could have been used with groubby-apply
      % we use i and id because there maybe trials that did not reach the threshold
      index[i,] = np.argmin(times[(trials == id)]) + nb_trials
      nb_trials += len(times[(trials == id)])

  first_time = times[index] * dt
  first_loc = locations[index] * dx
  first_trial = trials[index]  % note that this should give np.unique(trials) if there is no omission

  if not return_slice:
      return first_trial, first_loc, first_time
  else:
      % activity_slice = fr[first_trial, :, first_time]
      return first_trial, first_loc, first_time, fr[first_trial, :, first_time]

end  % function
