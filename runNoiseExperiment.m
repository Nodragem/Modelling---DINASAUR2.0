%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 1-d Continuous Attractor Neural Network with mexican hat mutual inhibition
% one gaussian signal (SC simulation) Aline Bompas 06/2010
% Modified and Adapted from the original code of Trappenberg et al. (2011)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [rall]= runNoiseExperiment(soa,no_trials,noise_amplitude)

%soa is positive when distractor comes after target
%soa=-50 in Trappenberg 2001
%noise_amplitude = 50 gives reasonable distributions
randn('state', 10000); %sum(100*clock));
%% SET UT PARAMETER OF THE DNF:
ini_thres=.85;
% number of nodes and distance btw nodes in radians:
nn = 100;
node_to_radian = 2*pi/nn;   % if multiply, transform nb. nodes to radians, if divide, transform radians to nb. nodes.
mm_to_radian = 2*pi/10;     % similar as above, Trappenberg. assumes a size of 10 mm of the SC/DNF
% delta exo and delta endo are the delay between stimulus appearance and exogenous/endogenous signals
dexo=50; dendo=75; OT=20;
% time constant of memb. potential and of inputs:
tau_u=10; tau_on=10; tau_off=1;
% slope of the gain function:
beta=0.07;
% parameters of lateral connections:
A=40;
I=55;
sig_w = 0.7 * mm_to_radian;  % we simulate 10 mm of SC with sig=0.7mm
% this will compute the connection matrix (N x N matrix if N is the number of neurons):
w = gaussianConnection1D(nn, node_to_radian, sig_w, A, I);
noise_start = 0; % ms


%% SET UT INPUT LOCATIONS:
loc_fix     = pi; % center of the map
node_fix    = round(loc_fix/node_to_radian);
loc_targ    = pi;
node_targ   = round(loc_fix/node_to_radian);
loc_dist    = loc_fix+1.82*mm_to_radian;
node_dist   = round(loc_dist/node_to_radian);
% loc_dist/node_to_radian --> that divide the location of the distractor in radians dy node_to_radian to get it position into node indices.
% thus I guess that in 1.82*[mm_to_radian],
% the term in [] is it is to transform position on the SC in cm to radians visual space (assuming that the SC is 10 cm)

%% SET UP INPUT EVENTS:
targ_on = 50; targ_dur = 550;
targ_off = targ_on + targ_dur ;
fix_on = 0; gap = 0;
fix_off = targ_on - gap;
dist_on = targ_on + soa; dist_dur=50;
dist_off = targ_on + soa + dist_dur;
end_simulation = targ_on + targ_dur+dendo+100;
step_simulation = 1; % millisecond for us
time = 1:step_simulation:end_simulation;
nstep=size(time, 2);

%% CONNECTIONS OF THE INPUTS WITH THE DNF:
% make gaussian shapes at the target, distractor and fixation locations.
% here the parameters of the gaussian (sigma and amplitudes):
sig = mm_to_radian*0.7;
aendo_fix  = 0; aendo_fix_gap  = 3; aexo_fix  = 10;
aendo_targ = 30; aendo_targ_gap = 0; aexo_targ = 0;
aendo_dist =  0; aendo_dist_gap = 0; aexo_dist = aexo_targ;

fix_conn = mirrorGaussian(loc_fix, 1, sig, nn, node_to_radian)';
targ_conn = mirrorGaussian(loc_targ, 1, sig, nn, node_to_radian)';
dist_conn = mirrorGaussian(loc_dist, 1, sig, nn, node_to_radian)';
I_conn = [fix_conn; targ_conn; dist_conn]';

%% CREATION OF THE INPUT SIGNAL TO THE DNF:
% those will be the interpolated signals, i.e. the actual inputs time series
I_fix =  stepFunction(time, aendo_fix,  fix_on  + dendo, fix_off  + dendo);
I_targ = linearIncrease(time, aendo_targ, targ_on + dendo, targ_off + dendo)...
         + expDecrease(time, aexo_targ, targ_on + dexo, tau_on);
I_dist = stepFunction(time, aendo_dist, dist_on + dendo, dist_off + dendo)...
         + expDecrease(time, aexo_dist, dist_on + dexo, tau_on);
I_all = [I_fix; I_targ; I_dist];
I_map = I_conn * I_all; % the time course of I_fix (col 1) will  be mapped to the connection pattern if fix_conn (row 1), etc...
%surf(I_conn * I_all, 'EdgeColor','none','LineStyle','none','FaceLighting','phong')

rall = zeros([no_trials, nn, nstep]);
%% SIMULATION OF THE MODEL WITH THE COMPUTED INPUT, RUN [no_trials] ITERATIONS WITH noise_amplitude
for trial=1:no_trials;
  % note that the model was initially run twice for each iteration/trial,
  % in order to compute a control trial (rall_no) for each trial (rall).
  % I commented out the control trial as in the python version we don't do it.

    %% SIMULATION:
    noise_t=[zeros(noise_start, nn); noise_amplitude*randn(nstep - noise_start, nn)]'; % was bugged in Aline code
    % -- I removed the computation of the control trial:
    r = computeNeuralFieldStep(nstep, zeros(nn,1)-10, w, I_map, noise_t, tau_u, beta,node_to_radian, nn);
    rall(trial, :, :) = r;


end
