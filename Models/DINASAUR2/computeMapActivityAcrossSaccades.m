function [firingrate, membrane_potential] = computeMapActivityAcrossSaccades(nstep, ...
  u_zero, mat_connections, input_map, noise_amplitude, noise_start, tau, beta, field_size)
  % DESCRIPTION
  % -------------
  % This code simulates a 1D neural field that represents the SC s activation during a saccade sequence dynamic.
  % The model simulates:
  %  - natural/automatic spatial drifts in the input,
  %  - triggers automatic micro-saccades
  %  - triggers reflexives macro-saccades,
  %  - update its new fixation location after a saccade/drift,
  %  - update of the input s locations and activity accoring to the new fixation location.
  % the model uses -
  %  - an unhomogenous and stochastic threshold to trigger saccades
  % when a saccade is triggered, we shift the inputs according to the new fixation position of the model
  %
  % we run a loop to compute the neural field firing rate evolution over all the time steps
  % Method d'Euler: g(t+1) = g(n) + dg/dt
  %
  % For-loop:
  % ---------
  % update neural field with Euler Methods
  % check if saccade with stochastic threshold
  % if yes:
  %    compute the saccadic vector,
  %    update center_of_gaze position
  %% if not:
  %    compute fixation drift
  %    update center_of_gaze position
  % then(first line): move the inputs according to new center_of_gaze (from drift/saccade)
  %
  % Parameters:
  % ----------
  % nstep: (type integer)
  %	number of time steps to go to the end of the simulation (maybe we don't need to comment every thing but...)
  % u_zero: (type 1D array)
  %	represent the membrane potential of neurons at time zero (note we use the notation u for membrane potential)
  % mat_connection: (type matrix)
  %	the row i describes the connection of the neuron i with its neighbours (columns)
  % input_exo, input_endo: (type matrix)
  %	value of the input over time step (columns) and space (rows)
  % tau: (type float)
  %	time constant of the neurons
  % beta: (type float)
  %	stepness of the sigmoid used to convert our membrane potential (u) in a firing rate
  % dx: (type float)
  %	one cell of the model represent dx degrees (or radians) in the visual field
  %
  % Return:
  % ----------
  % firingrate: (type matrix)
  %	describes the firing rate of all the neurons of the field (rows) for all the time steps (columns)
  % -----------------------------------------------------------------------------------------------------------

  % -- Initialize fixation-related variables
  % FIXME: make some variables persistent?
  model_fixation_pole = 50;    % [constant] analogous to the rostral pole of the SC
  center_of_gaze = 50;         % [variable] analogous to the center of gaze
  % the center of gaze projects on the fixation pole, while the center_of_gaze can vary
  border = (size(input_map, 1) - field_size)/2;
  if border < 0
   disp('ERROR: input_map is smaller than the dynamic neural field')
  end
  record_gaze = zeros([1000, 1]);
  record_gaze(1,:) = center_of_gaze;
  record_fixation_map = zeros([1000, 100]);

  % -- Initialize the neural field at time t_0:
  tau_inv = 1./tau;             % inverse time constant
  firingrate = zeros(field_size, nstep);
  membrane_potential = zeros(field_size, nstep);
  % noise_map = [zeros(noise_start, nn); noise_amplitude*randn(nstep - noise_start, nn)]';
  u = u_zero;
  r = 1 ./ (1 + exp(-beta*u));

  % -- Computation Loop (Euler Method):
  for t=1:nstep
   % move the inputs according to new center_of_gaze (from drift/saccade)
    projected_input = projectInput(input_map, border, field_size, ...
                                  center_of_gaze - model_fixation_pole);
    % update the DNF with Euler Method
    u = u + tau_inv * (- u + projected_input(:,t) + noise_map(:, t) + ...
                        mat_connections * r); % u is the current membrane potential
    r = 1 ./ (1 + exp(-beta*u));
    firingrate(:,t) = r;
    membrane_potential(:, t) = u;
    % we check whether there are locations where the threshold was passed:
    triggered_locations = applyStochasticThreshold(firingrate);
    if ~isempty(triggered_locations);
     % if yes: compute the saccadic vector, update center_of_gaze position
     % NEXT: implement getSaccadicVector()
     saccadic_vector = getSaccadicVector(firingrate); % FIXME: we may need to pass the winner, so that we can decrease the weight of other...
     center_of_gaze = center_of_gaze + saccadic_vector;
    else
     % if not: compute fixation drift, update center_of_gaze position
     [fix_map, center_of_gaze] = getEyesDrift(center_of_gaze, field_size, ...
                                              model_fixation_pole);
    end
    % record some variables
    record_gaze(t, :) = center_of_gaze;
    record_fixation_map(t, :) = fix_map;
  end
end
