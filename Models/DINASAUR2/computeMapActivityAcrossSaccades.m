function [event_recording, firingrate, record_input] = computeMapActivityAcrossSaccades(nstep, ...
                    u_zero, mat_connections, input_map, tau, beta, fixation_node, field_size)
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
  % if not:
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
  fixation_pole = fixation_node;                % [constant] analogous to the rostral pole of the SC
  input_size = size(input_map, 1);
  center_of_inputmap = round(input_size/2);
  center_of_gaze = round(input_size/2);         % [variable] analogous to the center of gaze, in input/visual space

  % the center of gaze projects on the fixation pole, while the center_of_gaze can vary
  clear getEyesDrift
  global gaze_drift; gaze_drift = 0;
  border = (input_size - field_size)/2;
  if border < 0
   disp('ERROR: input_map is smaller than the dynamic neural field')
  end

  % -- Initialize the saccade averaging varibles:
  winner_boost = 5;
  LLBN_weight = (1:field_size) - fixation_pole;

  % -- Initialize the recording
  % 'winner_ecc' 'saccade_ecc' 'gaze_pos' 'time'
  event_recording = NaN([nstep, 4]);
  record_input = NaN([nstep, input_size]);
  % record_fixation_map = zeros([nstep, input_size]);

  % -- Initialize the neural field at time t_0:
  tau_inv = 1./tau;             % inverse time constant
  firingrate = zeros(field_size, nstep);
  membrane_potential = zeros(field_size, nstep);
  % noise_map = [zeros(noise_start, nn); noise_amplitude*randn(nstep - noise_start, nn)]';
  u = u_zero;
  r = 1 ./ (1 + exp(-beta*u));
  dt = 1;

  % -- Initialize the threshold
  x = (1:field_size) - fixation_pole;
  % old: tau = 0.1; beta0 = 10.0;
  % best fit from oroginal DINASAUR (see branch noiseparameters):
  % tau = 1.3586 and beta0 = 11.4967
  % manually adjusted from best fit: tau = 1.4 and beta0 = 10
  tau_threshold = 1.4; beta_threshold = 10.0;
  threshold_func = zeros(1, field_size);
  threshold_func(1, 1:fixation_pole) = 0.82*exp(x(1:fixation_pole)/20) + 1; % + 0.85 by default
  threshold_func(1, fixation_pole:end) = 0.82*exp(-x(fixation_pole:end)/20) + 1;

  % -- Computation Loop (Euler Method):
  for t=1:nstep
   % move the inputs according to new center_of_gaze (from drift/saccade)
   % FIXME : commented temporarily
  %  projected_input = projectInput(input_map(:, t)', border, field_size, ...
  %                                 round(center_of_inputmap - center_of_gaze));
    projected_input = input_map(:,t)';
    record_input(t, :) = projected_input;
    % update the DNF with Euler Method
    u = u + tau_inv * (- u + projected_input' + mat_connections * r); % u is the current membrane potential
    r = 1 ./ (1 + exp(-beta*u)); 
    firingrate(:,t) = r;
    membrane_potential(:, t) = u;
    % we check whether there are locations where the threshold was passed:
    [triggered_locations, ~, ~] = applyStochasticThreshold(r', ...
    threshold_func, tau_threshold, beta_threshold, field_size, dt);
    if ~isempty(triggered_locations)
     % if yes: compute the saccadic vector, update center_of_gaze position
      if length(triggered_locations) == 1 % we want to give a boost to the winner
        winner = triggered_locations;
      else % if it is > 1, we need to select a winner randomly
        winner = randsample(triggered_locations, 1);
      end
      % FIXME : commented temporarily
      % saccadic_vector = getSaccadicVector(r', LLBN_weight, ...
      %                                     winner, winner_boost);
      saccadic_vector = winner - fixation_pole;
      center_of_gaze = center_of_gaze + saccadic_vector;
      % need to update the fixation memory map, even when no drift:
      % FIXME : commented temporarily
      % [cc, fix_map, shift_gaze] = getEyesDrift(field_size, false, true);
      % record some variables
      % 'winner_ecc' 'saccade_ecc' 'gaze_pos' 'time'
      event_recording(t,:) = [winner - fixation_pole, saccadic_vector, center_of_gaze, t];
    else
     % if not: compute fixation drift, update drift_gaze position
     % FIXME : commented temporarily
      % [cc, fix_map, shift_gaze] = getEyesDrift(field_size, true, true);
      % center_of_gaze = center_of_gaze + shift_gaze;
      event_recording(t,:) = [NaN, NaN, center_of_gaze, t];
    end
  end
end
