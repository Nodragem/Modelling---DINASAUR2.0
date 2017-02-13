% ---------------------------------------------------------------------------
% Modified and Adapted from the original code of Trappenberg et al. (2001)
% By Aline Bompas (2010-2011-2015) and Geoffrey Megardon (2016-2017).
% ----------------------------------------------------------------------------
function [event_table, I_map, rall]= runDinasaur2(simulation_details, condition_ID, nb_trials, record_firing, only_input_map)
  if (nargin < 4); record_firing = false; only_input_map=false; end;
  if (nargin < 5); only_input_map=false; end;
  % The following code is running of a 1D DNF with mutual inhibition to simulate the
  % motor map of the visuo-oculomotor system.
  % Several iterations are run to create distributions of RT/landing positions.
  % Metric:
  % ----------
  % node_to_radian = 2*pi/nn;   % if multiply, transform nb. nodes to radians, if divide, transform radians to nb. nodes.
  % mm_to_radian = 2*pi/10;     % similar as above, Trappenberg. assumes a size of 10 mm of the SC/DNF
  %
  % Parameters:
  % ----------
  % On the 30 nov. 2016, args is a table of 1 row that contains:
  % ['ID' 'SOA' 'TargetPos' 'DistractorPos' 'TargetAmp' 'DistractorAmp' 'nbTrials' 'noise_amplitude'];
  % args table is accessible with args{1, 'nameVar'}
  %
  % SOA: (float) millisecond
  %   SOA is the time distance between the Target stimulus and the Distractor stimulus
  %   It is positive when distractor comes after target. In Trappenberg 2001, SOA = -50.
  % noise_amplitude: (float) no unit
  %   = 50 gives reasonable distributions
  %
  % Return:
  % ----------
  % rall: (type matrix)
  %	  describes the firing rate of all the neurons of the field (rows) for all the time steps (columns)
  % uall: (type matrix)
  %	  describes the membrane potential of all the neurons of the field (rows) for all the time steps (columns)
  % -----------------------------------------------------------------------------------------------------------

  randn('state', 10000);
  %% SET UT PARAMETER OF THE DNF:
  ini_thres=.85;            % not used for now
  nn = 200;                 % number of nodes
  node_to_radian = 2*pi/nn; % need to keep the metric for now
  tau_u=10;                 % time decay constant of u
  beta=0.07;                % slope of the gain function:
  fixation_node = simulation_details.fixation_node;
  % parameters of lateral connections:
  % the lateral connections are made of a gaussian function minus a constant
  % sig_w corresponds to 0.7 mm in the SC (see function doc for metrics) as in Trappenberg 2001
  %FIXME: replace A and I by 1.2566 and 1.7279 to get rid of the metric
  % system
  A=40;                     % amplitude excitation
  I=55;                     % amplitude of global inhibition
  sig_w = 14.0;             % width of the gaussian

  % this will compute the connection matrix (N x N matrix if N is the number of neurons):
  weight_matrix = gaussianConnection1D(nn, sig_w, A, I) * node_to_radian; % to keep things as in Trappenberg
  [I_map, nstep] = generateInputMapFromJSON(simulation_details);
  if only_input_map
    return
  end

  %% SIMULATION OF THE MODEL WITH THE COMPUTED INPUT, RUN [nb_trials] ITERATIONS
  if record_firing
    rall = zeros([nb_trials, nn, nstep]);
  end
  table_keys = {'trial_ID', 'condition_ID' 'winner_ecc' 'saccade_ecc' 'gaze_pos' 'time'};
  event_table = zeros([nb_trials*nstep, 6]); % that is the largest it can get
  bookmark = 1;
  for trial=1:nb_trials;
      %% SIMULATION:
      clear getEyesDrift;
      [e, r] = computeMapActivityAcrossSaccades(nstep, zeros(nn, 1)-10, ...
                                          weight_matrix, I_map, tau_u, beta, fixation_node, nn);
      %% EXTRACT RESULTS:
      event_table(bookmark:(bookmark+size(e, 1)-1), :) = ...
       [repmat([trial, condition_ID],[+size(e, 1) 1]), e]; % we need -1 because MATLAB indexing starts at 1
      bookmark = bookmark + size(e, 1);
      if record_firing
        rall(trial, :, :) = r;
      end
  end
  event_table = array2table(event_table(event_table(:, 4) > 0, :), ... % removes empty rows
                          'VariableNames', table_keys);
  return
