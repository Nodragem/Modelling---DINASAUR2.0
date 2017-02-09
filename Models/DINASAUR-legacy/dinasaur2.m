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

nn = 200; dx=2*pi/nn; % number of nodes (SC fixation and buildup) and resolution in deg ## Geoffrey: I would say radians

targ_on=700; targ_dur=300; gap=0;
fix_off=targ_on-gap;
dist_dur=50;

loc_fix=pi;
node_fix=round(loc_fix/dx); aendo_fix=10; aendo_fix_gap=3; aexo_fix=10; %bompas 2011 settings:10, 3, 10
loc_targ=loc_fix-1.82*2*pi/10;%loc_fix-1.76*2*pi/10;
node_targ=round(loc_targ/dx); aendo_targ=14; %14
aendo_targ_gap=0; aexo_targ=80; %bompas 2011, 80;    aendo_targ_gap=0;(zero anticipatory activity in the gap) or 4 to simulate walker and benson -60 data
loc_dist=loc_fix+1.82*2*pi/10;%loc_fix+1.76*2*pi/10;
node_dist=round(loc_dist/dx); aendo_dist=0; aendo_dist_gap=0; aexo_dist=aexo_targ; % if soa>=0 aexo_dist=40; end %this is for walker and benson data


ini_thres=.85;   %B2011 =.85
tau_u=10; tau_on=10; tau_off=1; %endo_ramp=15; bompas 2011 settings: tau_u=10; tau_on=10; tau_off=1;
dexo=50; dendo=75; OT=20;   %bompas 2011 settings: 50, 75, 20

% Trappenberg's version
% a=144; b=-44; c=-16;
% sig_w = 2*pi/10*0.6; %we simulate 2*5mm of SC with sig=0.6mm
% w=mex_hat(nn,sig_w,dx,a,b,c);
% ---- Geoffrey notes:
% you can see below that the beta of the sigmoid function is set to 0.07
% tau_u = 10

A=40;
I=55;
sig_w = 2*pi/10*0.7;%0.7; %we simulate 2*5mm of SC with sig=0.6mm
%% hebb_A is the connection matrix computation function (not a diff of gaussian):
%% nn: number of nodes
%% dx: distance between nodes (in radians) cause we are on a circular field.
%% sig_w: sigma of the gaussian, note that the function is not a Diff of Gaussians
%% A: the amplitude of the gaussian
%% I: the y-offset (inhibition depth) of the gaussian
w = hebb_A(nn,dx,sig_w,A,I);

off_signal=zeros(nn,1)';

sig = 2*pi/10*0.7; 
fix_signal_exo=in_signal_pbc(loc_fix,aexo_fix,sig,nn,dx)';
targ_signal_exo=in_signal_pbc(loc_targ,aexo_targ,sig,nn,dx)';
dist_signal_exo=in_signal_pbc(loc_dist,aexo_dist,sig,nn,dx)';

fix_signal_endo=in_signal_pbc(loc_fix,aendo_fix,sig,nn,dx)';
targ_signal_endo=in_signal_pbc(loc_targ,aendo_targ,sig,nn,dx)';
dist_signal_endo=in_signal_pbc(loc_dist,aendo_dist,sig,nn,dx)';

fix_signal_endo_gap=in_signal_pbc(loc_fix,aendo_fix_gap,sig,nn,dx)';
targ_signal_endo_gap=in_signal_pbc(loc_targ,aendo_targ_gap,sig,nn,dx)';
dist_signal_endo_gap=in_signal_pbc(loc_dist,aendo_dist_gap,sig,nn,dx)';

% events (start-time I_ext;)
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

    event_exo_no=[
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



uexo = zeros(1,nn); uendo=zeros(1,nn); uexo_no = zeros(1,nn);
t = 0;
tend = event_exo(1,1);
uexoall=zeros(dexo,nn); uendoall=zeros(dendo,nn); uexoall_no=zeros(dexo,nn);

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
        dI_exo0 = uexoall(end,:)';
        tau=(tau_on*((dI_exo+dI_exo0)>0)+tau_off*((dI_exo+dI_exo0)<0)+1*((dI_exo+dI_exo0)==0));
        [t,uexo]=ode45('rnn_ode_exo',tspan,dI_exo + dI_exo0,[],tau);
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

for trial=1:no_trials;

    noise_t=[zeros(200,nn); noise*randn(1200,nn)];

    %% integration of field with event input and calculation of SRT
%{
    u = zeros(1,nn)-10; u_no = zeros(1,nn)-10;
    t = 0;
    tend = event_exo(1,1);
    tall = []; rall = []; rall_no = [];

    for i_event=1:size(event_exo,1)-1;
        tstart=tend;
        tend=event_exo(i_event+1,1)-1;
        tspan=[tstart:1:tend];
        if i_event==1 start_val=1;
        else start_val=2;
        end

        if length(tspan)>1
            u0 = u(size(t,1),:);
            u0_no = u_no(size(t,1),:);

            [t,u_no]=ode45('rnn_ode_u_A',tspan,u0_no,[],w,uexoall_no,uendoall,tau_u,dx,nn,noise_t);
            r=f1(u_no);
            tall=[tall;t(start_val:end)]; rall_no=[rall_no;r(start_val:end,:)];

            [t,u]=ode45('rnn_ode_u_A',tspan,u0,[],w,uexoall,uendoall,tau_u,dx,nn,noise_t);
            r=f1(u);
            rall=[rall;r(start_val:end,:)];

        end
    end
%}
%%%%
    tall = (event_exo(1,1):event_exo(end,1))';  nstep=tall(end)-tall(1);  beta=0.07; 
    rall_no= rnn_ode_u_A_fast(nstep, zeros(nn,1)-10, w, uexoall_no, uendoall, noise_t, tau_u,beta,dx,nn)';
    rall   = rnn_ode_u_A_fast(nstep, zeros(nn,1)-10, w, uexoall   , uendoall, noise_t, tau_u,beta,dx,nn)';
%%%%

    tmp_dist=tall(rall(:,node_dist)>ini_thres);
    tmp_targ=tall(rall(:,node_targ)>ini_thres);
    tmp_err=tall(rall_no(:,node_dist)>ini_thres);
    tmp_targo=tall(rall_no(:,node_targ)>ini_thres);

    around_targ=10;
    rall_no_around_targ=rall_no(targ_on:end,node_targ-around_targ:node_targ+around_targ)';
    sacc_diro=find(rall_no_around_targ>ini_thres,1);
    srto=floor(sacc_diro/(2*around_targ+1));
    sacc_diro=node_targ-around_targ-1+sacc_diro-(2*around_targ+1)*srto;
    srto=srto+OT-1;

    rall_around_targ=rall(targ_on:end,node_targ-around_targ:node_targ+around_targ)';
    sacc_dir=find(rall_around_targ>ini_thres,1);
    srt=floor(sacc_dir/(2*around_targ+1));
    sacc_dir=node_targ-around_targ-1+sacc_dir-(2*around_targ+1)*srt;
    srt=srt+OT-1;


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

