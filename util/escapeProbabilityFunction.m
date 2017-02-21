function probability = escapeProbabilityFunction(distance, tau, beta0, dt)
% escapeProbabilityFunction Description
% REMEMBER: the distance is negative when under threshold
  function escape_rate = escape_func(x)
    % shape of the escape function (proba to trigger)
    % see plot above, in real neurons it can be 19 ms and 4 mV
    escape_rate = 1 / tau * exp(beta0 * x);
  end
  probability = 1 - exp(-dt * escape_func(distance) );
  % WARNING, FIXME: for now we obligate the curve to cross zero
  probability = probability - (1 - exp(-dt * escape_func(-1) ));
end
