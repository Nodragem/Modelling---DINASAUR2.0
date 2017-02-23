%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 1-d Continuous Attractor Neural Network with mexican hat mutual inhibition
% one gaussian signal (SC simulation) Aline Bompas 06/2010
% Modified and Adapted from the original code of Trappenberg et al. (2011)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [srt_targ_all,srt_dist_all,srt_err_all,srt_targo_all]= runDinasaur2(soa,no_trials,noise_amplitude)

%soa is positive when distractor comes after target
%soa=-50 in Trappenberg 2001
%noise_amplitude = 50 gives reasonable distributions
randn('state', 10000); %sum(100*clock));
if_figure=1;

srt_targ_all  = [];
srt_dist_all  = [];
srt_err_all   = [];
srt_targo_all = [];

%% SET UT PARAMETER OF THE DNF:
ini_thres=.85;
% number of nodes and distance btw nodes in radians:
nn = 200; 
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
w = gaussianConnection1D(nn, node_to_radian, sig_w, A, I) * node_to_radian;;
noise_start = 200 % ms
 

%% SET UT INPUT LOCATIONS:
loc_fix     = pi; % center of the map
node_fix    = round(loc_fix/node_to_radian);
loc_targ    = loc_fix-1.82*mm_to_radian;
node_targ   = round(loc_targ/node_to_radian);
loc_dist    = loc_fix+1.82*mm_to_radian;
node_dist   = round(loc_dist/node_to_radian);
% loc_dist/node_to_radian --> that divide the location of the distractor in radians dy node_to_radian to get it position into node indices.
% thus I guess that in 1.82*[mm_to_radian],
% the term in [] is it is to transform position on the SC in cm to radians visual space (assuming that the SC is 10 cm)

%% SET UP INPUT EVENTS:
targ_on = 700; targ_dur = + 300;
targ_off = targ_on + targ_dur ;
fix_on = 0; gap = 0;
fix_off = targ_on - gap;
dist_on = targ_on+soa; dist_dur=50;
dist_off = targ_on+soa+dist_dur
end_simulation = targ_on+500
step_simulation = 1 % millisecond for us
time = 1:step_simulation:end_simulation; 
nstep=size(time, 2); 

%% CONNECTIONS OF THE INPUTS WITH THE DNF:
% make gaussian shapes at the target, distractor and fixation locations.
% here the parameters of the gaussian (sigma and amplitudes):
sig = mm_to_radian*0.7;
aendo_fix  = 10; aendo_fix_gap  = 0; aexo_fix  = 10;
aendo_targ = 14; aendo_targ_gap = 0; aexo_targ = 80;
aendo_dist =  0; aendo_dist_gap = 0; aexo_dist = aexo_targ;

fix_conn = mirrorGaussian(loc_fix, 1, sig, nn, node_to_radian)';
targ_conn = mirrorGaussian(loc_targ, 1, sig, nn, node_to_radian)';
dist_conn = mirrorGaussian(loc_dist, 1, sig, nn, node_to_radian)';
I_conn = [fix_conn; targ_conn; dist_conn]';

%% CREATION OF THE INPUT SIGNAL TO THE DNF:
% those will be the interpolated signals, i.e. the actual inputs time series
I_fix =  stepFunction(time, aendo_fix,  fix_on  + dendo, fix_off  + dendo);
I_targ = stepFunction(time, aendo_targ, targ_on + dendo, targ_off + dendo)... 
         + expDecrease(time, aexo_targ, targ_on + dexo, tau_on);
I_dist = stepFunction(time, aendo_dist, dist_on + dendo, dist_off + dendo)... 
         + expDecrease(time, aexo_dist, dist_on + dexo, tau_on);
I_all = [I_fix; I_targ; I_dist];
I_map = I_conn * I_all % the time course of I_fix (col 1) will  be mapped to the connection pattern if fix_conn (row 1), etc...
surf(I_conn * I_all, 'EdgeColor','none','LineStyle','none','FaceLighting','phong')


%% SIMULATION OF THE MODEL WITH THE COMPUTED INPUT, RUN [no_trials] ITERATIONS WITH noise_amplitude
for trial=1:no_trials;
  % note that the model was initially run twice for each iteration/trial,
  % in order to compute a control trial (rall_no) for each trial (rall).
  % I commented out the control trial as in the python version we don't do it.
    
    %% SIMULATION:
    noise_t=[zeros(noise_start, nn); noise_amplitude*randn(nstep - noise_start, nn)]'; % was bugged in Aline code         
    % -- I removed the computation of the control trial:  
    rall = computeNeuralFieldStep(nstep, zeros(nn,1)-10, w, I_map, noise_t, tau_u, beta,node_to_radian, nn)';
    imshow(rall')
    rall_no = rall;

    %% EXTRACT RESULTS: 
    % 1 - FIND WHEN THE THRESHOLD WAS REACHED for different locations on the map:
    tmp_dist=time(rall(:,node_dist)>ini_thres);
    tmp_targ=time(rall(:,node_targ)>ini_thres);
    tmp_err=time(rall_no(:,node_dist)>ini_thres);
    tmp_targo=time(rall_no(:,node_targ)>ini_thres);
    
    % DEBUG CODE
    [x, y] = ind2sub(size(rall), find(rall>0.85));
    figure()
    ri = I_map;
    imshow(ri)
    hold on
    plot(x, y, 'o')
    for ii = 0:100:1100
         plot([ii ii], [0 200]);
    end
    figure(); plot(mean(rall(250:700, :), 1) )
      hold on;
       plot(ri(:, 250)/18)
      xx = 0:200;
      plot(gaussian2(xx, 99, 0.45, 16, false) + 0.06)
    disp([trial srt_targo srt_targ]);

    % 2 - DEFINE THE SACCADE DIRECTION/ BEHAVIORAL RESPONSE MADE BY THE MODEL:
    % look at the average of activity upper the threshold around the target,
    % at the time where one node first passed the threshold:
    around_targ=10;
    % here the author extract the time course of the activity around the target since the target onset:
    rall_no_around_targ=rall_no(targ_on:end,node_targ-around_targ:node_targ+around_targ)';
    % they want to find when one of the node passed the threshold:
    sacc_diro=find(rall_no_around_targ>ini_thres,1);
    % the function find() return just one number (for instance 1861), thus is an index position (index = column*nb_row + row%nb_row).
    % thus the authors had to divide the index by the number of node/columns in the original array to get the reaction time (the row)
    srto=floor(sacc_diro/(2*around_targ+1));
    % here, -1+sacc_diro-(2*around_targ+1)*srto is to transform the index into a node position (e.g. sacc amplitude).
    sacc_diro=node_targ-around_targ-1+sacc_diro-(2*around_targ+1)*srto;
    srto=srto+OT-1;

    rall_around_targ=rall(targ_on:end,node_targ-around_targ:node_targ+around_targ)';
    sacc_dir=find(rall_around_targ>ini_thres,1);
    srt=floor(sacc_dir/(2*around_targ+1));
    sacc_dir=node_targ-around_targ-1+sacc_dir-(2*around_targ+1)*srt;
    srt=srt+OT-1;
    % NOTE: NEITHER srt AND sacc_dir ARE RETURNED, so why did they computed it?


    if (isempty(tmp_dist)==0)
        srt_dist=tmp_dist(1)-targ_on+OT;
    else
        srt_dist=NaN;
    end
    if (isempty(tmp_targ)==0)
        srt_targ=tmp_targ(1)-targ_on+OT;
    else
        srt_targ=NaN;
    end
    if (isempty(tmp_err)==0)
        srt_err=tmp_err(1)-targ_on+OT;
    else
        srt_err=NaN;
    end
    if (isempty(tmp_targo)==0)
        srt_targo=tmp_targo(1)-targ_on+OT;
    else
        srt_targo=NaN;
    end

    if srt_targ<=srt_dist, srt_dist=NaN;
    elseif srt_dist<srt_targ, srt_targ=NaN;
    end
    if srt_targo<=srt_err, srt_err=NaN;
    elseif srt_err<srt_targo, srt_targo=NaN;
    end

    srt_targ_all(trial)=srt_targ;
    srt_dist_all(trial)=srt_dist;
    srt_err_all(trial)=srt_err;
    srt_targo_all(trial)=srt_targo;
    %disp([trial srt_targo srt_targ]);

end
mn_targo=mean(srt_targo_all(srt_targo_all>0 & srt_targo_all<300));
mn_targ=mean(srt_targ_all(srt_targ_all>0 & srt_targ_all<300));

return
