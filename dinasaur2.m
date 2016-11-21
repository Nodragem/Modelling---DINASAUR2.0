%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 1-d Continuous Attractor Neural Network with mexican hat mutual inhibition
% one gaussian signal (SC simulation) Aline Bompas 06/2010
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [srt_targ_all,srt_dist_all,srt_err_all,srt_targo_all]=dinasaur2(soa,no_trials,noise)

%soa is positive when distractor comes after target
%soa=-50 in Trappenberg 2001
%noise = 50 gives reasonable distributions


randn('state', 10000); %sum(100*clock));
if_figure=1;

srt_targ_all=[];
srt_dist_all=[];
srt_err_all=[];
srt_targo_all=[];

% SET UT PARAMETER OF THE DNF:
ini_thres=.85;
tau_u=10; tau_on=10; tau_off=1;
% delta exo and delta endo are the delay between stimulus appearance and exogenous/endogenous signals
dexo=50; dendo=75; OT=20;
nn = 200; dx=2*pi/nn; % number of nodes and distance btw nodes in radians

% SET UT THE INPUT LOCATION
targ_on=700; targ_dur=300; gap=0;
fix_off=targ_on-gap;
dist_dur=50;

loc_fix=pi;
node_fix=round(loc_fix/dx); aendo_fix=10; aendo_fix_gap=3; aexo_fix=10;
loc_targ=loc_fix-1.82*2*pi/10;
node_targ=round(loc_targ/dx); aendo_targ=14;
aendo_targ_gap=0; aexo_targ=80;
loc_dist=loc_fix+1.82*2*pi/10;
node_dist=round(loc_dist/dx); aendo_dist=0; aendo_dist_gap=0; aexo_dist=aexo_targ;
% loc_dist/dx --> that divide the location of the distractor in radians dy dx to get it position into node indices.
% thus I guess that in 1.82*[2*pi/10],
% the term in [] is it is to transform position on the SC in cm to radians visual space (assuming that the SC is 10 cm)



% LATERAL CONNECTIONS
A=40;
I=55;
sig_w = 2*pi/10*0.7; %we simulate 2*5mm of SC with sig=0.7mm
% hebb_A computes the connection matrix:
w = hebb_A(nn,dx,sig_w,A,I);

off_signal=zeros(nn,1)';

% CONNECTIONS OF THE INPUT WITH THE DNF:
% make gaussian shapes at the target, distractor and fixation locations:
sig = 2*pi/10*0.7;
% for the exogenous signal (amplitude of the signal on the map):
fix_signal_exo=in_signal_pbc(loc_fix,aexo_fix,sig,nn,dx)';
targ_signal_exo=in_signal_pbc(loc_targ,aexo_targ,sig,nn,dx)';
dist_signal_exo=in_signal_pbc(loc_dist,aexo_dist,sig,nn,dx)';
% for the endogenous signal (amplitude):
fix_signal_endo=in_signal_pbc(loc_fix,aendo_fix,sig,nn,dx)';
targ_signal_endo=in_signal_pbc(loc_targ,aendo_targ,sig,nn,dx)';
dist_signal_endo=in_signal_pbc(loc_dist,aendo_dist,sig,nn,dx)';
% for the endogenous signal during the gap (amplitude):
fix_signal_endo_gap=in_signal_pbc(loc_fix,aendo_fix_gap,sig,nn,dx)';
targ_signal_endo_gap=in_signal_pbc(loc_targ,aendo_targ_gap,sig,nn,dx)';
dist_signal_endo_gap=in_signal_pbc(loc_dist,aendo_dist_gap,sig,nn,dx)';

% TABLES OF INPUT EVENTS:
% on the first colums, the timing of changes in signal,
% on the second columns the amplitude of the signal of the map at these times
% Note that these tables does not give the dynamics of the signal
% in between those times yet, the signal on the map are kind of keyframes,
% and will need to be interpolated in a following part of the code.
if soa>=0
    event_exo=[
        0                      fix_signal_exo;              % fixation on
        fix_off                off_signal;
        targ_on                targ_signal_exo;             % targ on
        targ_on+soa            targ_signal_exo+dist_signal_exo; % dist on
        targ_on+soa+dist_dur   targ_signal_exo;             % dist off
        targ_on+targ_dur       off_signal;              % targ off
        targ_on+500            off_signal;              % end simulation
        ];

    event_exo_no=[ %% without distractor
        0                      fix_signal_exo;              % fixation on
        fix_off                off_signal;
        targ_on                targ_signal_exo;             % targ on
        targ_on+soa            targ_signal_exo % dist on
        targ_on+soa+dist_dur   targ_signal_exo;             % dist off
        targ_on+targ_dur       off_signal;              % targ off
        targ_on+500            off_signal;              % end simulation
        ];

    event_endo=[
        0                      fix_signal_endo;%+targ_signal_endo_gap+dist_signal_endo_gap;              % fixation on
        fix_off                fix_signal_endo_gap+targ_signal_endo_gap;%+dist_signal_endo_gap;
        targ_on                targ_signal_endo;             % targ on
        targ_on+soa            targ_signal_endo;%+dist_signal_endo; % dist on
        targ_on+soa+dist_dur   targ_signal_endo;             % dist off
        targ_on+targ_dur       off_signal;              % targ off
        targ_on+500            off_signal;              % end simulation
        ];

elseif soa<-dist_dur
    event_exo=[
        0                      fix_signal_exo;              % fixation on
        targ_on+soa            fix_signal_exo+dist_signal_exo;             % dist on
        targ_on+soa+dist_dur   fix_signal_exo;             % dist off
        targ_on                targ_signal_exo;             % targ on
        targ_on+targ_dur       off_signal;              % targ off
        targ_on+500            off_signal;              % end simulation
        ];

    event_exo_no=[
        0                      fix_signal_exo;              % fixation on
        targ_on+soa            fix_signal_exo;             % dist on
        targ_on+soa+dist_dur   fix_signal_exo;             % dist off
        targ_on                targ_signal_exo;             % targ on
        targ_on+targ_dur       off_signal;              % targ off
        targ_on+500            off_signal;              % end simulation
        ];

    event_endo=[
        0                      fix_signal_endo+targ_signal_endo_gap+dist_signal_endo_gap;              % fixation on
        targ_on+soa            dist_signal_endo+fix_signal_endo+targ_signal_endo_gap;             % dist on
        targ_on+soa+dist_dur   fix_signal_endo;             % dist off
        targ_on                targ_signal_endo;             % targ on
        targ_on+targ_dur       off_signal;              % targ off
        targ_on+500            off_signal;              % end simulation
        ];

elseif soa>=-dist_dur
    event_exo=[
        0                      fix_signal_exo;              % fixation on
        targ_on+soa            fix_signal_exo+dist_signal_exo;             % dist on
        targ_on                dist_signal_exo+targ_signal_exo;             % targ on
        targ_on+soa+dist_dur   targ_signal_exo;             % dist off
        targ_on+targ_dur       off_signal;              % targ off
        targ_on+500            off_signal;              % end simulation
        ];

    event_exo_no=[
        0                      fix_signal_exo;              % fixation on
        targ_on+soa            fix_signal_exo;             %
        targ_on                targ_signal_exo;             % targ on
        targ_on+soa+dist_dur   targ_signal_exo;             %
        targ_on+targ_dur       off_signal;              % targ off
        targ_on+500            off_signal;              % end simulation
        ];

    event_endo=[
        0                      fix_signal_endo+targ_signal_endo_gap+dist_signal_endo_gap;              % fixation on
        targ_on+soa            fix_signal_endo+dist_signal_endo+targ_signal_endo_gap;             % dist on
        targ_on                dist_signal_endo+targ_signal_endo;             % targ on
        targ_on+soa+dist_dur   targ_signal_endo;             % dist off
        targ_on+targ_dur       off_signal;              % targ off
        targ_on+500            off_signal;              % end simulation
        ];
end

% CREATION OF THE INPUT SIGNAL FROM THE TABLE OF EVENTS:
% those will be the interpolated signals, i.e. the actual inputs time series
uexo = zeros(1,nn); uendo=zeros(1,nn); uexo_no = zeros(1,nn);
t = 0;
tend = event_exo(1,1);
% Geoffrey: I don't understand why they are making an array that have the size of the endo/exo delay
% Geoffrey: I know now: they will append the signal computed in 'uexo' to 'uexoall',
% so that the delay is taken into account.
uexoall=zeros(dexo,nn); uendoall=zeros(dendo,nn); uexoall_no=zeros(dexo,nn);
% Exogenous input baseline?
I_exo0=zeros(nn,1); I_exo0_no=zeros(nn,1);

flag=0;

for i_event=1:size(event_exo,1)-1;
    tstart=tend;
    tend=event_exo(i_event+1,1)-1;
    tspan=[tstart:1:tend];
    if i_event==1 start_val=1;
    else start_val=2;
    end

    if length(tspan)>1

        I_exo = event_exo(i_event,2:nn+1)';%+ 20*randn(nn,1);
        dI_exo = I_exo-I_exo0;
        if dI_exo<0, dI_exo=0; end %remove effect of offsets
        dI_exo0 = uexoall(end,:)'; % the baseline is where we let uexoall at the previous iteration
        % Geoffrey: if after the event tau = 10 if before tau = 1? is it that ?
        % Geoffrey: no, I think that is: if difference with baseline is positive use tau_on, if not use tau_off
        tau=(tau_on*((dI_exo+dI_exo0)>0)+tau_off*((dI_exo+dI_exo0)<0)+1*((dI_exo+dI_exo0)==0));
        % here they compute, over all the input map, an exponential convergence to baseline with tau_on/off according to the sing of the difference
        [t,uexo]=ode45('rnn_ode_exo',tspan,dI_exo + dI_exo0,[],tau);
        % here they append the signal to the matrix that was created with zeros for the duration of the endo delay
        uexoall=[uexoall;uexo(start_val:end,:)];

        I_exo_no = event_exo_no(i_event,2:nn+1)';%+ 20*randn(nn,1);
        dI_exo_no = I_exo_no-I_exo0_no;
        if dI_exo_no<0, dI_exo_no=0; end %remove effect of offsets
        dI_exo0_no = uexoall_no(end,:)';
        tau=(tau_on*(dI_exo_no+dI_exo0_no>0)+tau_off*(dI_exo_no+dI_exo0_no<0)+1*(dI_exo_no+dI_exo0_no==0));
        [t,uexo_no]=ode45('rnn_ode_exo',tspan,dI_exo_no + dI_exo0_no,[],tau);
        uexoall_no=[uexoall_no;uexo_no(start_val:end,:)];

        I_endo = event_endo(i_event,2:nn+1)';%+ 20*randn(nn,1);
        uendo=repmat((I_endo)',size(t),1);
        %         I_endo_0 = uendoall(end,:)';
        %         uendo(1:endo_ramp,:)=repmat(I_endo_0',endo_ramp,1) + [1:endo_ramp]' * (I_endo'-I_endo_0')/endo_ramp;
        uendoall=[uendoall;uendo(start_val:end,:)];
    end
    I_exo0=I_exo;
    I_exo0_no=I_exo_no;

end

% SIMULATION OF THE MODEL WITH THE COMPUTED INPUT, RUN [no_trials] ITERATIONS WITH NOISE
for trial=1:no_trials;
  % note that the model was initially run twice for each iteration/trial,
  % in order to compute a control trial (rall_no) for each trial (rall).
  % I commented out the control trial as in the python version we don't do it.

    noise_t=[zeros(200,nn); noise*randn(1200,nn)];

    tall = (event_exo(1,1):event_exo(end,1))';  nstep=tall(end)-tall(1);  beta=0.07;
    % -- I commented the computation of the control trial:
    %rall_no= rnn_ode_u_A_fast(nstep, zeros(nn,1)-10, w, uexoall_no, uendoall, noise_t, tau_u,beta,dx,nn)';
    rall   = rnn_ode_u_A_fast(nstep, zeros(nn,1)-10, w, uexoall   , uendoall, noise_t, tau_u,beta,dx,nn)';
    rall_no = rall;

    % FIND WHEN THE THRESHOLD WAS REACHED for different locations on the map:
    tmp_dist=tall(rall(:,node_dist)>ini_thres);
    tmp_targ=tall(rall(:,node_targ)>ini_thres);
    tmp_err=tall(rall_no(:,node_dist)>ini_thres);
    tmp_targo=tall(rall_no(:,node_targ)>ini_thres);

    % DEFINE THE SACCADE DIRECTION/ BEHAVIORAL RESPONSE MADE BY THE MODEL:
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
