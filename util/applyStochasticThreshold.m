function [locations, threshold, escape_prob] = applyStochasticThreshold(fr, threshold_func, tau, beta0, field_size, dt)
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
  if isempty(first_time)
    first_time = false;
    figure
    subplot(2, 2, 1)
    plot(threshold_func)
    hold on
    plot(fr)
    line([25, 25], [0 3], 'Color', [0,0,0])
    subplot(2, 2, 2)
    plot(fr- threshold_func)
    hold on
    dista = (fr - threshold_func)./threshold_func;
    plot(dista)
    legend('distance from T', 'relative distance from T')
    line([0, 120], [-1 -1], 'Color', [0.5,0.5,0.5])
    title('threshold distance')

    subplot(2, 2, 3)
    plot(1 / tau * exp(beta0 .* dista));
    hold on
    plot(escapeProbabilityFunction(dista, tau, beta0, dt), 'r')
    title('probability to trigger (on the map)')

    subplot(2, 2, 4)
    space = -1:0.01:0;
    plot(space, escapeProbabilityFunction(space, tau, beta0, dt) )
    title({'probability to trigger', '(according to distance from threshold)'})
  end

  threshold = threshold_func; % DON'T REMOVE: that is for the output
  %distance = (fr - threshold_func)./threshold_func;
  distance = fr - threshold_func;
  % REMEMBER: the distance is negative when under threshold
  % REMEMBER: we use the relative distance from the threshold
  escape_prob = escapeProbabilityFunction(distance, tau, beta0, dt);
  triggered = (rand(size(escape_prob)) < escape_prob);
  % note from python, we were doing complicated stuffs
  % that would have been translate into:
  % [trials, locations, times] = ind2sub(size(triggered),find(triggered));
  % and some more stuffs.
  % However, we are not concerned with time and trials anymore here
  locations = find(triggered);

end  % function
