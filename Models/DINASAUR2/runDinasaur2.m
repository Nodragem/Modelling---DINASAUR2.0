% ---------------------------------------------------------------------------
% Modified and Adapted from the original code of Trappenberg et al. (2001)
% By Aline Bompas (2010-2011-2015) and Geoffrey Megardon (2016-2017).
% ----------------------------------------------------------------------------
function [rall, uall]= runDinasaur2(args)
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
randn('state', 10000); %sum(100*clock));

%% SET UT PARAMETER OF THE DNF:
ini_thres=.85; % not used for now
% number of nodes:
nn = 200;
node_to_radian = 2*pi/nn; % need to keep the metric for now
% ---------
%FIXME: replace A and I by 1.2566 and 1.7279 to get rid of the metric
% system
% ----------
% time constant of memb. potential and of inputs:
tau_u=10;
% slope of the gain function:
beta=0.07;
% parameters of lateral connections:
A=40; % amplitude excitation
I=55; % amplitude of global inhibition
sig_w = 14.0; % corresponds to the 0.7 mm in the SC (see function doc for metrics) as in Trappenberg 2001
% this will compute the connection matrix (N x N matrix if N is the number of neurons):
weight_matrix = gaussianConnection1D(nn, sig_w, A, I) * node_to_radian; % to keep things as in Trappenberg
input_info = loadjson('input_map.json');
[I_map, nstep] = generateInputMapFromJSON(input_info);

%% SIMULATION OF THE MODEL WITH THE COMPUTED INPUT, RUN [no_trials] ITERATIONS WITH noise_amplitude
nb_trials = args{1, 'nbTrials'};
rall = zeros([nb_trials, nn, nstep]);
uall = zeros([nb_trials, nn, nstep]);
for trial=1:nb_trials;
    %% SIMULATION:
    [r, u] = computeMapActivityAcrossSaccades(nstep, zeros(nn, 1)-10, ...
                                        weight_matrix, I_map, tau_u, beta, nn);
    %% EXTRACT RESULTS:
    rall(trial, :, :) = r;
    uall(trial, :, :) = u;
end
return
