% ---------------------------------------------------------------------------
% Modified and Adapted from the original code of Trappenberg et al. (2001)
% By Aline Bompas (2010-2011-2015) and Geoffrey Megardon (2016-2017).
% ----------------------------------------------------------------------------
function [list_RT_targ,list_RT_dist, rall, uall]= runDinasaur2(args)
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
ini_thres=.85;
% number of nodes:
nn = 200;
space = -nn/2:1:(nn/2-1);
node_to_radian = 2*pi/nn; % need to keep the metric for now
% ---------
%FIXME: replace A and I by 1.2566 and 1.7279 to get rid of the metric
% system
% ----------
% delta exo and delta endo are the delay between stimulus appearance and exogenous/endogenous signals
dexo=50; dendo=75; non_decision_time=20;
% time constant of memb. potential and of inputs:
tau_u=10; tau_on=10; tau_off=1;
% slope of the gain function:
beta=0.07;
% parameters of lateral connections:
A=40; % amplitude excitation
I=55; % amplitude of global inhibition
sig_w = 14.0; % corresponds to the 0.7 mm in the SC (see function doc for metrics) as in Trappenberg 2001
% this will compute the connection matrix (N x N matrix if N is the number of neurons):
w = gaussianConnection1D(nn, sig_w, A, I) * node_to_radian; % to keep things as in Trappenberg
noise_amplitude = args{1, 'noise_amplitude'};
noise_start = 200; % ms


%% SET UT INPUT LOCATIONS:
% now the locations are specified in model nodes, the metrics should be encapsulated in
% functions outside this one;
loc_fix    = 0;
loc_targ   = args{1, 'TargetPos'};
loc_dist   = args{1, 'DistractorPos'};

%% SET UP INPUT EVENTS:
soa = args{1, 'SOA'};
targ_on = 700; targ_dur = + 300;
targ_off = targ_on + targ_dur ;
fix_on = 0; gap = 0;
fix_off = targ_on - gap;
dist_on = targ_on+soa; dist_dur=50;
dist_off = targ_on+soa+dist_dur;
end_simulation = targ_on+500;
step_simulation = 1; % millisecond for us
time = 1:step_simulation:end_simulation;
nstep=size(time, 2);

%% CONNECTIONS OF THE INPUTS WITH THE DNF:
% make gaussian shapes at the target, distractor and fixation locations.
% here the parameters of the gaussian (sigma and amplitudes):
sig = 14.0; % corresponds to 0.7 mm on the SC (see function doc for metrics) as in Trappenberg 2001
aendo_fix  = 10; aendo_fix_gap  = 3; aexo_fix  = 10;
aendo_targ = 14; aendo_targ_gap = 0; aexo_targ = 80;
aendo_dist = 14; aendo_dist_gap = 0; aexo_dist = aexo_targ;
% note that if the weight are put to zero, that cancels the values above
targ_weight = args{1, 'TargetWeight'};
dist_weight = args{1, 'DistractorWeight'};

fix_conn = mirrorGaussian(loc_fix, 1, sig, nn)';
targ_conn = mirrorGaussian(loc_targ, targ_weight, sig, nn)';
dist_conn = mirrorGaussian(loc_dist, dist_weight, sig, nn)';
I_conn = [fix_conn; targ_conn; dist_conn]';

%% CREATION OF THE INPUT SIGNAL TO THE DNF:
% those will be the interpolated signals, i.e. the actual inputs time series
I_fix =  stepFunction(time, aendo_fix,  fix_on  + dendo, fix_off  + dendo);
I_targ = stepFunction(time, aendo_targ, targ_on + dendo, targ_off + dendo)...
         + expDecrease(time, aexo_targ, targ_on + dexo, tau_on);
I_dist = stepFunction(time, aendo_dist, dist_on + dendo, dist_off + dendo)...
         + expDecrease(time, aexo_dist, dist_on + dexo, tau_on);
I_all = [I_fix; I_targ; I_dist];
I_map = I_conn * I_all; % the time course of I_fix (col 1) will  be mapped to the connection pattern if fix_conn (row 1), etc...
% figure();
% surf(I_conn * I_all, 'EdgeColor','none','LineStyle','none','FaceLighting','phong')


%% SIMULATION OF THE MODEL WITH THE COMPUTED INPUT, RUN [no_trials] ITERATIONS WITH noise_amplitude
list_RT_targ  = [];
list_RT_dist  = [];
for trial=1:args{1, 'nbTrials'};
  % note that the model was initially run twice for each iteration/trial,
  % in order to compute a control trial (rall_no) for each trial (rall).

    %% SIMULATION:
    noise_t = [zeros(noise_start, nn); noise_amplitude*randn(nstep - noise_start, nn)]'; % was bugged in Aline code
    % -- I removed the computation of the control trial:
    [rall, uall] = computeNeuralFieldStep(nstep, zeros(nn, 1)-10, w, I_map, noise_t, tau_u, beta, nn);

    %% EXTRACT RESULTS:
    % 1 - FIND WHEN THE THRESHOLD WAS REACHED for different locations on the map:
    tmp_dist=time(rall(:,loc_dist) > ini_thres);
    tmp_targ=time(rall(:,loc_targ) > ini_thres);

    % 2 - DEFINE THE RESPONSE and THE REACTION TIME OF THE MODEL:
    if (not(isempty(tmp_dist)))
        srt_dist=tmp_dist(1) - targ_on + non_decision_time;
    else
        srt_dist=NaN;
    end
    if (not(isempty(tmp_targ)))
        srt_targ=tmp_targ(1) - targ_on + non_decision_time;
    else
        srt_targ=NaN;
    end

    if (srt_targ <= srt_dist), srt_dist = NaN;
    elseif (srt_dist < srt_targ), srt_targ = NaN;
    end

    list_RT_targ(trial)=srt_targ;
    list_RT_dist(trial)=srt_dist;

end
return
