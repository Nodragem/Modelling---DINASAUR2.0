clear all;
close all;
pathname=pwd;
soa=[0:20:80];
no_soa=length(soa);
k=[];
RTmin=70; RTmax=500;

%     figure; hold on;


for s=1:no_soa
    k=[];
    load([pathname '/Aline_hebb_final/Aline_soa_' num2str(soa(s)) 'hebb_final.mat'],'srt_targ_all','srt_dist_all');
    k=cat(1,k,[ones(length(srt_targ_all),1) srt_targ_all' (srt_targ_all-soa(s))']);
    k=cat(1,k,[2*ones(length(srt_dist_all),1) srt_dist_all' (srt_dist_all-soa(s))']);

    load([pathname '/Aline_hebb_final2/Aline_soa_' num2str(soa(s)) 'hebb_final.mat'],'srt_targ_all','srt_dist_all');
    k=cat(1,k,[ones(length(srt_targ_all),1) srt_targ_all' (srt_targ_all-soa(s))']);
    k=cat(1,k,[2*ones(length(srt_dist_all),1) srt_dist_all' (srt_dist_all-soa(s))']);

    %     load([pathname '/Aline_hebb_final3/Aline_soa_' num2str(soa(s)) 'hebb_final.mat'],'srt_targ_all','srt_dist_all');
    %     k=cat(1,k,[ones(length(srt_targ_all),1) srt_targ_all' (srt_targ_all-soa(s))']);
    %     k=cat(1,k,[2*ones(length(srt_dist_all),1) srt_dist_all' (srt_dist_all-soa(s))']);

    for ss=1:no_soa
        load([pathname '/Aline_hebb_final/Aline_soa_' num2str(soa(ss)) 'hebb_final.mat'],'srt_targo_all');
        k=cat(1,k,[zeros(length(srt_targo_all),1) srt_targo_all' srt_targo_all']);
        load([pathname '/Aline_hebb_final2/Aline_soa_' num2str(soa(ss)) 'hebb_final.mat'],'srt_targo_all');
        k=cat(1,k,[zeros(length(srt_targo_all),1) srt_targo_all' srt_targo_all']);
        %     load([pathname '/Aline_hebb_final3/Aline_soa_' num2str(soa(ss)) 'hebb_final.mat'],'srt_targo_all');
        %     k=cat(1,k,[zeros(length(srt_targo_all),1) srt_targo_all' srt_targo_all']);
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % individual data, kernel smoothed

    bin_size=4;
    x=(0:bin_size:RTmax-bin_size);

    yrange=[0 55];
    subplot(5,3,s*3); hold on;
    %             ylim(yrange);
    xlim([0 300]);
    distr=k(k(:,1)==1 & k(:,2)>RTmin & k(:,2)<RTmax,2);
    Hdi=hist(distr,x);

    no=k(k(:,1)==0 & k(:,2)>RTmin & k(:,2)<RTmax,2);

    Hno=hist(no,x)/no_soa;
    mno(s)=mean(k(k(:,1)==0 & k(:,2)>RTmin & k(:,2)<RTmax,2));
    stdno(s)=std(k(k(:,1)==0 & k(:,2)>RTmin & k(:,2)<RTmax,2));
    mdi(s)=mean(k(k(:,1)==1 & k(:,2)>RTmin & k(:,2)<RTmax,2));
    rde(s)=mdi(s)-mno(s);

    err=k(k(:,1)==2 & k(:,3)>RTmin & k(:,3)<RTmax,2);
    err_rate(s)=length(err)/(length(distr)+length(err));
    Herr=hist(err,x);
    plot(x,Herr,'k')

    %         h=hist(srt_targo_all(find(srt_dist_all>0))-soa(s),x);
    % plot(x,h,'m')

    xx=1:x(end);
    n=5; sigma=1;
    filter1=gaussfilter(n,sigma);

    yy=conv(Hno,filter1);
    y=yy((n+1)/2:end-(n-1)/2)';
    Hno_f=interp1(x,y,xx,'cubic',nan); % 1 = Scone / 2 = Lum

    yy=conv(Hdi,filter1);
    y=yy((n+1)/2:end-(n-1)/2)';
    Hdi_f=interp1(x,y,xx,'cubic',nan); % 1 = Scone / 2 = Lum

    plot([soa(s) soa(s)],yrange,'k--');
    plot(xx,Hno_f,'LineWidth',2,'Color',[0.7 0.7 0.7]);
    plot(xx,Hdi_f,'LineWidth',2,'Color','black');

    Hdiff=Hno_f-Hdi_f;
    for t=1:length(Hno_f)
        if Hno_f(t)>2
            Hratio(t)=max(0,min(1,Hdiff(t)./Hno_f(t)));
        else Hratio(t)=NaN;
        end
    end %for t=1:1+RTmax/bin_size(j)
    %     plot(xx,Hratio*10, 'g:');

    max_dip_amp(s)=max(Hratio);
    tmax=find(Hratio==max_dip_amp(s));
    max_dip_t(s)=tmax(1);

    separation_t(s)=max_dip_t(s);
    while Hratio(separation_t(s))>0.01 && Hno_f(separation_t(s)-1)>1
        separation_t(s)=separation_t(s)-1;
    end

    if max_dip_amp(s)<0.05
        separation_t(s)=NaN;
        max_dip_t(s)=NaN;
    else
        plot(separation_t(s),Hdi_f(separation_t(s)),'bo','MarkerFaceColor','b');
        plot(max_dip_t(s),Hdi_f(max_dip_t(s)),'ro','MarkerFaceColor','r');
    end
    set(gca,'XTick',0:100:300)
    set(gca,'XTickLabel',{'0','100','200','300'})
    set(gca,'YTick',yrange(2))
end

