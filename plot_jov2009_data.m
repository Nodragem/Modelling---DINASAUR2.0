clear all; close all;

x=0:4:350;
xx=x(1):x(end);
n=5; sigma=1;
filter1=gaussfilter(n,sigma);
figure;

load(['jov2009_data.mat']);
c=no_contrast-1;

no=k(isnan(k(:,3))==1 & k(:,6)>0,6);
mno=mean(no);
medianno=median(no);
Hno=hist(no,x)/9;
yy=conv(Hno,filter1);
y=yy((n+1)/2:end-(n-1)/2)';
Hno_f=interp1(x,y,xx,'cubic',nan); % 1 = Scone / 2 = Lum

err_no=e(isnan(e(:,3))==1 & e(:,6)>0,6);
Herr_no=hist(err_no,x)/9;
yy=conv(Herr_no,filter1);
y=yy((n+1)/2:end-(n-1)/2)';
Herr_no_f=interp1(x,y,xx,'cubic',nan); % 1 = Scone / 2 = Lum

for s=2:no_soa-1
    dist=k(k(:,3)==soa(s) & (k(:,4)==c | k(:,4)==c+1) & k(:,6)>0,6);
    %     dist=k(k(:,3)==soa(s) & (k(:,4)==c) & k(:,6)>0,6);
    Hdi=hist(dist,x);
    mdi(s)=mean(dist);
    mediandi(s)=median(dist);
    yy=conv(Hdi,filter1);
    y=yy((n+1)/2:end-(n-1)/2)';
    Hdi_f=interp1(x,y,xx,'cubic',nan); % 1 = Scone / 2 = Lum

    err_dist=e(e(:,3)==soa(s) & (e(:,4)==c | e(:,4)==c+1) & e(:,6)>0,6);
    %     dist=k(k(:,3)==soa(s) & (k(:,4)==c) & k(:,6)>0,6);
    Herr_di=hist(err_dist,x);
    yy=conv(Herr_di,filter1);
    y=yy((n+1)/2:end-(n-1)/2)';
    Herr_di_f=interp1(x,y,xx,'cubic',nan); % 1 = Scone / 2 = Lum

    error_count(s)=length(err_dist(err_dist>0));
    dist_count(s)=length(dist(dist>0));
    errorrate(s)=error_count(s)/(error_count(s)+dist_count(s));
    
    subplot(no_soa-2,1,s-1); hold on; xlim([0 300]);
    plot(xx, Hno_f,'-','Color',[0.7 0.7 0.7],'LineWidth',2);
    plot(xx, Hdi_f,'k-','LineWidth',2);
    plot(xx, Herr_no_f,'-','Color',[0.7 0.7 0.7],'LineWidth',1);
    plot(xx, Herr_di_f,'k-','LineWidth',1);
    set(gca,'XTick',100:100:300,'FontSize',12)
    set(gca,'XTickLabel',{'100','200','300'},'FontSize',12)
    set(gca,'YTick',[],'FontSize',12);
end
 RDE=mdi-mno;
 RDEmedian=mediandi-medianno;