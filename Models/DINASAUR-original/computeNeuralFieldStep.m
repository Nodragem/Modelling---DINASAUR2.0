function [firingrate, membrane_potential] = computeNeuralFieldStep(nstep, u_zero,...
   mat_connections, input_map, noise_t, tau, beta, field_size)
   % simulate a 1D neural field
   % we run a loop to compute the neural field firing rate evolution over all the time steps
   % Method d'Euler: g(t+1) = g(n) + dg/dt
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
   %	value of the input_map over time step (columns) and space (rows)
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
   tau_inv = 1./tau;      % inverse time constant
   sum_input = input_map(:, 1:nstep) + noise_t(:, 1:nstep);
   firingrate = zeros(field_size, nstep);
   membrane_potential = zeros(field_size, nstep);
   % we initialize the neural field at time t_0:
   u = u_zero;
   r = 1 ./ (1 + exp(-beta*u));  firingrate(:,1)=r;
   % Loop Euler Method:
   for t=1:nstep
     u = u + tau_inv * (sum_input(:,t) - u + mat_connections * r); % u is the current membrane potential
     r = 1 ./ (1 + exp(-beta*u));
     firingrate(:,t) = r;
     membrane_potential(:, t) = u;
   end

%% Geoffrey: line 36
%% 		- why do you multiply with dx? (dx: the space resolution of a neuron)

% Note that now I commented the code, I realised that you actually record the activity of all the neurons over time, so we can actually display a video :D cool!
