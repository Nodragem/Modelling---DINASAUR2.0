%clear all;
clearvars;
close all;
sim_tab=[
%  1 -60 1200 50;
 %2 -40 1200 50
 %3 -20 1200 50
 4 0 1200 50;
 5 20 1200 50
 6 40 1200 50;
 7 60 1200 50;
   ];
% sim_tab=[
%     1 0 50 50; 
%     ];


no_sim=size(sim_tab,1);
for sim=1:no_sim
    sim_number=sim_tab(sim,1);
    soa=sim_tab(sim,2);
    no_trials=sim_tab(sim,3);
    noise=sim_tab(sim,4);
    
    %         [srt_targ_all,srt_dist_all,srt_err_all,srt_targo_all]=Aline(soa,no_trials,noise);
    [srt_targ_all,srt_dist_all,srt_err_all,srt_targo_all]=dinasaur2(soa,no_trials,noise);
    
    srt_targ_allsoa(:,sim)=srt_targ_all;
    srt_dist_allsoa(:,sim)=srt_dist_all;
    srt_err_allsoa(:,sim)=srt_err_all;
    
    
    
    RTmin=0;
    RTmax=500;
    xrange=[RTmin 300]; %yrange=[0 22];
    bin_size=4;
    x = [RTmin:bin_size:RTmax];
    xx=x(1):500;
    n=5; sigma=1;
    filter1=gaussfilter(n,sigma);
    
    figure(1); subplot(size(sim_tab,1),1,sim); hold on;
    Hno=hist(srt_targo_all,x);
    Herr=hist(srt_dist_all,x);
    Herr_no=hist(srt_err_all,x);
    Hdi=hist(srt_targ_all,x);
    
    yy=conv(Hno,filter1);
    y=yy((n+1)/2:end-(n-1)/2)';
    Hno_f=interp1(x,y,xx,'cubic',nan);
    
    yy=conv(Hdi,filter1);
    y=yy((n+1)/2:end-(n-1)/2)';
    Hdi_f=interp1(x,y,xx,'cubic',nan); % 1 = Scone / 2 = Lum

    xlim(xrange); %ylim(yrange);
    plot(xx,Hno_f,'LineWidth',2,'Color',[0.7 0.7 0.7]);
    plot(xx,Hdi_f,'LineWidth',2,'Color','black');
    plot(x,Herr, 'k-');
    plot(x,Herr_no, 'Color',[0.7 0.7 0.7]);
    set(gca,'XTick',100:100:300,'FontSize',12)
    set(gca,'XTickLabel',{'100','200','300'},'FontSize',12)
    set(gca,'YTick',[],'FontSize',12);
   %plot([soa soa],yrange,'k--');

    for xx=1:length(x)
        if Hno(xx)>0 Hratio(xx)=max(-1,min(1,(Hno(xx)-Hdi(xx))./Hno(xx)));
        else Hratio(xx)=NaN;
        end
    end
    Hratiod(:,sim)=Hratio';
    DipRatio(sim)=max(Hratio(1:50));
%     figure(2); subplot(5,1,sim); hold on;
%     %         plot(x,(Hno-Hdi),'g-');
%     plot(x,Hratio,'r-');
    
    mn_targ(sim)=mean(srt_targ_all(srt_targ_all>0));
    mn_dist(sim)=mean(srt_dist_all(srt_dist_all>0));
    mn_err(sim)=mean(srt_err_all(srt_err_all>0));
    mn_targo(sim)=mean(srt_targo_all(srt_targo_all>0));
    rde(sim)=mn_targ(sim)-mn_targo(sim);
    mdn_targ(sim)=median(srt_targ_all(srt_targ_all>0));
    mdn_dist(sim)=median(srt_dist_all(srt_dist_all>0));
    mdn_err(sim)=median(srt_err_all(srt_err_all>0));
    mdn_targo(sim)=median(srt_targo_all(srt_targo_all>0));
    rdemdn(sim)=mdn_targ(sim)-mdn_targo(sim);
    std_no=std(srt_targo_all(srt_targo_all>0));
    sk_no=skewness(srt_targo_all(srt_targo_all>0));
    
    l_targo=length(srt_targo_all(srt_targo_all>0));
    l_err=length(srt_err_all(srt_err_all>0));
    l_targ=length(srt_targ_all(srt_targ_all>0));
    l_dist=length(srt_dist_all(srt_dist_all>0));
    err_rate_dist(sim)=l_dist*100/(l_dist+l_targ);
    err_rate_no(sim)=l_err*100/(l_targo+l_err);
    err_rate_p(sim)=l_err*100/(l_targ);
    
    
%     save(['dinasaur2_' num2str(soa) '.mat']);
end

% draw scatter figure of rde against baseline latency.
figure; 

for sim=1:no_sim
    RDEdistrib(:,sim)=srt_targ_allsoa(:,sim)'-srt_targo_all;
subplot(no_sim,1,sim); hold on; 
xlim(xrange);
ylim([0 200]);
scatter(srt_targo_all,srt_targ_allsoa(:,sim)'-srt_targo_all,4,[0 0 0]);
%plot(srt_targo_all,RDEdistrib(:,sim)','k.');
set(gca,'XTick',100:100:300,'FontSize',12)
set(gca,'XTickLabel',{'100','200','300'},'FontSize',12)
end
RDEcheck=nanmean(RDEdistrib);
RDEcheckmdn=nanmedian(RDEdistrib);


% draw histograms of rde for each trial.
figure;  hold on;
    
   xrange=[0 200]; %yrange=[0 22];
    bin_size=20;
    x = [0:bin_size:220];
    
    xlim(xrange); %ylim(yrange);
    B=[0 .2 .4 0 .6 .8 1]; R=[1 .8 .6 0 .4 .2 0];

for sim=1:no_sim
    RDEd=RDEdistrib(:,sim);
    RDEdx=RDEd(RDEd>1);
    RDE0=RDEd(RDEd<1.5);
    Hrde=hist(RDEdx,x);
    plot(x,Hrde,'LineWidth',2,'Color',[R(sim) 0 B(sim)]);
    propRDEdx(sim)=length(RDEdx)/(length(RDEdx)+length(RDE0));
    mnRDEd(sim)=mean(RDEdx);
    sdRDE(sim)=std(RDEdx);
end
    set(gca,'XTick',0:100:200,'FontSize',12)
    set(gca,'XTickLabel',{'0','100','200'},'FontSize',12)
    set(gca,'YTick',[],'FontSize',12);



% % redraw figures from existing stimulations
% no_sim=size(sim_tab,1);
% for sim=1:no_sim
%     sim_number=sim_tab(sim,1);
%     soa=sim_tab(sim,2);
%     no_trials=sim_tab(sim,3);
%     noise=sim_tab(sim,4);
%
%     load(['dinasaur2_' num2str(soa) '.mat']);
%
%     RTmin=0;
%     RTmax=500;
%     xrange=[RTmin 300];
%     yrange=[0 22];
%     bin_size=4;
%     x = [RTmin:bin_size:RTmax];
%     xx=x(1):500;
%     n=7; sigma=3;
%     filter1=gaussfilter(n,sigma);
%     yy=conv(Hno,filter1);
%     y=yy((n+1)/2:end-(n-1)/2)';
%     Hno_f=interp1(x,y,xx,'cubic',nan);
%
%     yy=conv(Hdi,filter1);
%     y=yy((n+1)/2:end-(n-1)/2)';
%     Hdi_f=interp1(x,y,xx,'cubic',nan); % 1 = Scone / 2 = Lum
%
%     figure(1); subplot(5,1,sim); hold on;
%     xlim(xrange); ylim(yrange);
%     plot(xx,Hno_f,'LineWidth',2,'Color',[0.7 0.7 0.7]);
%     plot(xx,Hdi_f,'LineWidth',2,'Color','black');
%     plot(x,Herr, 'k-');
%     plot(x,Herr_no, 'Color',[0.7 0.7 0.7]);
%     set(gca,'XTick',100:200:300,'FontSize',12)
%     set(gca,'XTickLabel',{'100','200','300'},'FontSize',12)
%     set(gca,'YTick',[],'FontSize',12);
%     plot([soa soa],yrange,'k--');
% end
%
