function sync(read_dir, output_dir, study, subject, ref_date,phoenix_dir)

%% Study and subject 
stdy=study; 
sb1=subject; 
mn=datenum(ref_date);   % Choose 1st day as the actigraphy reference

%% Input and output directory
display('Sync Pipeline.')
display('Checking input directory.');
adr=read_dir;
% Check if the path is properly formatted
if ~ endsWith(adr, '/')
    adr = strcat(adr, '/');
end

display('Checking output directory.');
adrq=output_dir;
% Check if the path is properly formatted
if ~ endsWith(adrq, '/')
    adrq = strcat(adrq, '/');
end

display('Checking phoenix directory.');
adrph=phoenix_dir;
% Check if the path is properly formatted
if ~ endsWith(adrph, '/')
    adrph = strcat(adrph, '/');
end

%% Find the files related to the day + some days before and after that day
display('Finding files.');
d3=dir(strcat(adr,'*.mat'));

files_len = length(d3);
% Exit if there are no files to read
if files_len == 0
    display('Files do not exist under this directory.');
    exit(1);
end

%% Parameters/ Read data
display('Initializing adresses.');
load(strcat(adr,'/',d3.name))
outp=strcat(adrph,'GENERAL/',stdy,'/',sb1,'/phone/processed/mtl_plt');
tpa=length(indf_act(1,:));
if exist(strcat(outp,'/',sb1,'_gps.mat'), 'file') == 2
    load(strcat(outp,'/',sb1,'_gps.mat'))

    %% Plot GPS
    ff1=figure(1);
    set(gcf,'position',get(0,'screensize')-[0,0,0,0])
    set(gcf,'color','white')
    epc_lbl={' 6PM',' 7PM',' 8PM',' 9PM','10PM','11PM','12AM',' 1AM',' 2AM',' 3PM',' 4AM',' 5AM',' 6AM',' 7AM',' 8AM',' 9AM','10AM','11AM','12PM',' 1PM',' 2PM',' 3PM',' 4PM',' 5PM',' 6PM'};
    indv_gps=reshape(indf_gps,1,1440*length(indf_gps(1,:)));
    indv2_gps=[max(indv_gps)*ones(1,4*60) indv_gps(1:end-4*60)];
    indf_gps=reshape(indv2_gps,1440,length(indf_gps(1,:)));
    indfd1=indf_gps;
    %% Time Zone
    ilnk=find(isnan(lnkc));
    for ill=1:length(ilnk)
        indf_gps(indf_gps==ilnk(ill))=max(indf_gps(:))-1;
    end
    lnkc=lnkc(~isnan(lnkc));
    ltkc=ltkc(~isnan(ltkc));
    
    tdl=timezone(lnkc,'degree')-timezone(lnkc(1),'degree');
    tdl2=[tdl;0;0];
    ddfk=deg2km(distance(ltkc,lnkc,ltkc(1),lnkc(1)));
    hp2=length(ddfk);
    lblf2{1,1}=' ';
    for fh=1:hp2-1
        if fh>=10
            fmt='%02d';
        elseif fh<10
            fmt='%02d';
        end
        if ddfk(fh)>=1000
            fmt2='%4.0f';
        elseif ddfk(fh)>=100
            fmt2='%3.1f';
        elseif ddfk(fh)>=10
            fmt2='%2.1f';
        elseif ddfk(fh)>=1
            fmt2='%1.2f';
        elseif ddfk(fh)<1
            fmt2='%0.2f';
        end
        lblf2{fh+1,1}=strcat('-',sprintf(fmt2,ddfk(fh+1)));
    end
    lblf2{hp2+1,1}=' '; lblf2{hp2+2,1}=' '; %#ok<*SAGROW>
    %% Colors
    clp1=unique(indf_gps);
    wnt=winter(30);
    spr=spring(30);
    sumr=summer(30);
    autm=autumn(20);
    copr=copper(17);
    colll=[autm(1:12,:);wnt(1:15,:);sumr(1:12,:);spr(1:10,:);copr;sumr(15:26,:);spr(18:25,:);wnt(21:30,:);autm(16:20,:)];
    colr=[colll;colll;colll;colll; colll; colll];
    clrr3=colr(1:(length(clp1)-3),:);
    clrss=[[.75 .75 .75];clrr3; [.9 .9 .9];[1 1 1]]; %#ok<*AGROW>    
    %% Labels for time zone
    tdls=num2str(tdl);
    if length(tdls(1,:))==1
        tdls=[tdls;' ';' '];
    elseif length(tdls(1,:))==3
        tdls=[tdls;'   ';'   '];
    else
        tdls=[tdls;'  ';'  '];
    end
    %disp('Fine1')
    indf_gpss=indf_gps;
    for ccl=1:length(clp1)
        indf_gpss(indf_gps==clp1(ccl))=ccl;
    end
    indq_gps=indf_gpss;
    tdlx=tdls;
    lblfx=lblf2;
    clr_gps=clrss;
    %disp('Fine2')
    colormap(gca,clr_gps)
    hhind=imagesc(flip(indf_gpss,1));
    axi = ancestor(hhind, 'axes');
    xrule = axi.XAxis;  yrule = axi.YAxis;
    h25fpp=colorbar;
    set(gca, 'FontWeight','b')
    ylabel('GPS','FontWeight','b','FontSize',32)
    tpd1=length(indf_gpss(1,:));
    tpd=tpd1-1;
    set(h25fpp,'YTick',1:.995:length(clp1),'YTickLabel',strcat(tdlx,lblfx),'FontSize',32)
    %set(h2,'YTick',.5:0.99:hp2+2,'YTickLabel',lblf2)
    set(gca,'YTick',0.5:60:1440.5,'YTickLabel',epc_lbl(1:1:end)) 
    set(gca,'XTick',.5:2:tpd+.5,'XTickLabel',0:2:tpd,'XTickLabelRotation',90)
    title(strcat('study=',num2str(study),'/sb=',sb1(1:3),'/GPS'),'Rotation',0, 'FontSize',32, 'FontWeight','b')
    xrule.FontSize = 32;
    grid on
    xlim([.5,tpd+.5])

    %% Save figures
    outpp=adrq;
    if exist(outpp,'dir')~=7
    mkdir(outpp) 
    end
    savefig(strcat(outpp,stdy,'-',sb1(1:3),'-gps.fig'))
    img = getframe(gcf);
    imwrite(img.cdata, strcat(outpp,stdy,'-',sb1(1:3),'-gps.png'));
    display('GPS saved');

    %% Add time zone
    ind_tmz=zeros(size(indf_gps));
    for k1=1:length(clp1)-2
        ind_tmz(indf_gps==k1)=tdl(k1);
    end
    ind_tmz(indf_gps==length(clp1)-1)=NaN;
    ind_tmz(indf_gps==length(clp1))=NaN;

    ind_vmz=reshape(ind_tmz,1,1440*length(ind_tmz(1,:)));
    txq=1:1:length(ind_vmz);
    txp=txq(~isnan(ind_vmz));
    typ=ind_vmz(~isnan(ind_vmz));
    ind_tmz1=interp1(txp,typ,txq,'previous','extrap');
    txp=txq(~isnan(ind_tmz1));
    typ=ind_tmz1(~isnan(ind_tmz1));
    ind_tmz2=interp1(txp,typ,txq,'next','extrap');
    txqm=txq-(ind_tmz2*60);
    txqm(txqm<1)=1;
    txqm(txqm>max(txq))=max(txq);
    %% Build Replacing indecies
    tpa=min(tpa,length(ind_tmz(1,:)));
    txa=1:1:tpa*1440;
    txam=txa-(ind_tmz2(1:1:tpa*1440)*60);
    txam(txam<1)=1;
    txam(txam>max(txa))=max(txa);
    [a11,a22,a33]=unique(txam,'last');
    %%
    indv_gps=reshape(indf_gps,1,1440*length(indf_gps(1,:)));
    indvm2_gps=max(indv_gps)*ones(size(indv_gps));
    [a1,a2,a3]=unique(txqm,'last');
    indvm2_gps(a1)=indv_gps(a2);
    indm2_gps=reshape(indvm2_gps,1440,length(indf_gps(1,:)));
    ind_tmzz=reshape(ind_tmz2,1440,length(ind_tmz(1,:)));
    ind_tmzz=ind_tmzz(:,1:tpa);
    utmz=unique(ind_tmzz);
    utmn=strcat(num2str(utmz),'(h)');
    indf_tmz=zeros(size(ind_tmzz));
    for k2=1:length(utmz)
        indf_tmz(ind_tmzz==utmz(k2))=k2;
    end
    display('Time zone added.')

    %% Plot timezone
    ff2=figure(2);
    set(gcf,'position',get(0,'screensize')-[0,0,0,0])
    set(gcf,'color','white')
    clr5=[[0 0 0];[1 0 0 ];[1 1 0];[ 0 1 0]; [0 0 1]; [0 1 1 ]; [1 0 1];[.5 0 0 ];[0 .5 0];[0 0 .5]];
    %clr5=[[1 0 0 ];[1 0 1];[ .75 .75 .75]; [0 0 1]];
    clr6=[clr5(1:length(utmz),:)];
    colormap(gca,clr6)
    hhind=imagesc(flip(indf_tmz,1));
    axi = ancestor(hhind, 'axes');
    xrule = axi.XAxis;  yrule = axi.YAxis;
    h25fpp=colorbar;
    set(gca, 'FontWeight','b')
    set(h25fpp,'YTick',1.5:.7:length(utmz)+.5,'YTickLabel',utmn,'FontSize',24)
    set(gca,'YTick',0.5:60:1440.5,'YTickLabel',epc_lbl(1:1:end)) 
    set(gca,'XTick',.5:4:tpa+.5,'XTickLabel',0:4:tpa,'XTickLabelRotation',90)
    %title(strcat('study=',num2str(study),'/sb=',sb1(1:3),'/TimeZone'),'Rotation',0, 'FontSize',14, 'FontWeight','b')
    xrule.FontSize = 24;
    yrule.FontSize = 24;
    xlabel('Relative Days','FontWeight','b','FontSize',24)
    grid on
    xlim([.5,tpa+.5])
    savefig(strcat(outpp,stdy,'-',sb1(1:3),'-tmzn.fig'))
    img = getframe(gcf);
    imwrite(img.cdata, strcat(outpp,stdy,'-',sb1(1:3),'-tmzn.png'));
    display('TimeZone Saved.');
    ldy=tpa;
    %% Plot time-zoned GPS
    ff3=figure(3);
    set(gcf,'position',get(0,'screensize')-[0,0,0,0])
    set(gcf,'color','white')
    indtm=indm2_gps(:,1:tpa);
    clpt=unique(indtm);
    indfs=zeros(size(indtm));
    ltkn=[]; lnkn=[];
    for k=1:length(clpt)
        indfs(indtm==clpt(k))=k;
    end
    for k=1:length(clpt)-2
        ltkn(k)=ltkc(clpt(k));
        lnkn(k)=lnkc(clpt(k));
    end
    indf_gaz=indfs;
    tdlxx=tdls;
    lblfxx=lblf2;
    clr_gaz=clrss;
    colormap(gca,clr_gaz)
    
    hhind=imagesc(flip(indfs,1));
    axi = ancestor(hhind, 'axes');
    xrule = axi.XAxis;   yrule = axi.YAxis;
    epc_lbl2={' 6PM',' 3PM', '12PM', ' 9AM',' 6AM',' 3AM','12AM',' 9PM',' 6PM'};
    set(gca,'YTick',(0.5:3*60:24*60+0.5),'YTickLabel',epc_lbl2(1:1:end),'TickDir','out', 'Linewidth',4,'FontName','Arial','FontWeight','b','FontSize',32,'Ygrid','off')           
    set(gca,'XTick',[1 25.5:25:ldy+.5],'XTickLabel',{'1','25','50','75','100','125','150','175','200','225','250'},'XTickLabelRotation',0,'FontSize',32)
    a = gca;                                % get handle to current axes
    set(a,'box','off','color','none')           % set box property to off and remove background color
    b = axes('Position',get(a,'Position'),'box','on','xtick',[],'ytick',[],'linewidth',4);   % create new, empty axes with box but without ticks
    axes(a)          % set original axes as active
    linkaxes([a b])  % link axes in case of zooming
    xlabel('Relative Days','FontWeight','b','FontSize',32)
    xlim([.5,tpa+.5])
    savefig(strcat(outpp,stdy,'-',sb1(1:3),'-tmzngps.fig'))
    img = getframe(gcf);
    imwrite(img.cdata, strcat(outpp,stdy,'-',sb1(1:3),'-tmzngps.png'));
    display('GPS TimeZone Saved.');

    figg1=figure(555);
    set(gcf,'position',get(0,'screensize')-[0,0,0,0])
    set(gcf,'color','white')
    subplot(4,1,1)
    gind=imagesc(flip(indfs,1));
    axi = ancestor(gind, 'axes');
    xrule = axi.XAxis;   yrule = axi.YAxis;
    epc_lbl2={' 6PM',' 6PM'};
    set(gca,'YTick',[],'YTickLabel',[],'TickDir','out', 'Linewidth',4,'FontName','Arial','FontWeight','b','FontSize',32,'Ygrid','off')
    set(gca,'XTick',[],'XTickLabel',[],'XTickLabelRotation',0,'FontSize',32)
    xlim([.5,tpa+.5])
    savefig(strcat(outpp,stdy,'-',sb1(1:3),'-clin1.fig'))
    img = getframe(gcf);
    imwrite(img.cdata, strcat(outpp,stdy,'-',sb1(1:3),'-clin1.png'));

    gpsi=0;
else
    indf_gps=zeros(size(indf_act));
    indq_gps=indf_gps;
    clr_gps=[1 1 1];
    indf_gaz=indf_gps;
    ltkn=0; lnkn=0;
    gpsi=1;
    ldy=tpa;
    outpp=adrq;
    if exist(outpp,'dir')~=7
        mkdir(outpp) 
    end
    display('No GPS Data')
end

%% Phone Use
if exist(strcat(outp,'/',sb1,'_pow.mat'), 'file') == 2
    load(strcat(outp,'/',sb1,'_pow.mat'))
else
    indf_pow=zeros(size(indf_gps));
end
ff4=figure(4);
set(gcf,'position',get(0,'screensize')-[0,0,0,0])
set(gcf,'color','white')
indv_pow=reshape(indf_pow,1,1440*length(indf_pow(1,:)));
indv2_pow=[zeros(1,4*60) indv_pow(1:end-4*60)];
indq_pow=reshape(indv2_pow,1440,length(indf_pow(1,:)));
indfd1=indq_pow;
indfdv=reshape(indfd1,1,1440*length(indfd1(1,:)));
if gpsi==0
    indfdv2=zeros(size(indfdv));
    aa1=a1(a2<1440*length(indfd1(1,:)));
    aa2=a2(a2<1440*length(indfd1(1,:)));
    indfdv2(aa1)=indfdv(aa2);
else
    indfdv2=indfdv;
end
indfd2=reshape(indfdv2,1440,length(indfd1(1,:)));
indfd=indfd2(:,1:tpa);
indf_phone1=indfd;
clps=unique(indfd);
clrs=[0 0 1;1 1 1;1 0 0;0 1 0];
excl=clps+2;
excl1=excl;
clr_pow=clrs(excl,:);
colormap(gca,clr_pow)
hhind=imagesc(flip(indf_phone1,1));
axi = ancestor(hhind, 'axes');
xrule = axi.XAxis;   yrule = axi.YAxis;
epc_lbl2={' 6PM',' 3PM', '12PM', ' 9AM',' 6AM',' 3AM','12AM',' 9PM',' 6PM'};
set(gca,'YTick',(0.5:3*60:24*60+0.5),'YTickLabel',epc_lbl2(1:1:end),'TickDir','out', 'Linewidth',4,'FontName','Arial','FontWeight','b','FontSize',32,'Ygrid','off')           
set(gca,'XTick',[1 25.5:25:ldy+.5],'XTickLabel',{'1','25','50','75','100','125','150','175','200','225','250'},'XTickLabelRotation',0,'FontSize',32)
a = gca;                                % get handle to current axes
set(a,'box','off','color','none')           % set box property to off and remove background color
b = axes('Position',get(a,'Position'),'box','on','xtick',[],'ytick',[],'linewidth',4);   % create new, empty axes with box but without ticks
axes(a)          % set original axes as active
linkaxes([a b])  % link axes in case of zooming
xlabel('Relative Days','FontWeight','b','FontSize',32)
xlim([.5,tpa+.5])
savefig(strcat(outpp,stdy,'-',sb1(1:3),'-phone.fig'))
img = getframe(gcf);
imwrite(img.cdata, strcat(outpp,stdy,'-',sb1(1:3),'-phone.png'));

figg1=figure(555);
set(gcf,'position',get(0,'screensize')-[0,0,0,0])
set(gcf,'color','white')
subplot(4,1,2)
gind=imagesc(flip(indf_phone1,1));
axi = ancestor(gind, 'axes');
xrule = axi.XAxis;   yrule = axi.YAxis;
epc_lbl2={' 6PM',' 6PM'};
set(gca,'YTick',[],'YTickLabel',[],'TickDir','out', 'Linewidth',4,'FontName','Arial','FontWeight','b','FontSize',32,'Ygrid','off')
set(gca,'XTick',[],'XTickLabel',[],'XTickLabelRotation',0,'FontSize',32)
xlim([.5,tpa+.5])
savefig(strcat(outpp,stdy,'-',sb1(1:3),'-clin1.fig'))
img = getframe(gcf);
imwrite(img.cdata, strcat(outpp,stdy,'-',sb1(1:3),'-clin1.png'));

display('Phone Use Saved.');

%% Accelerometer
if exist(strcat(outp,'/',sb1,'_accel.mat'), 'file') == 2
    load(strcat(outp,'/',sb1,'_accel.mat'))
else
    indf_accel=zeros(size(indf_gps));
end
ff5=figure(5);
set(gcf,'position',get(0,'screensize')-[0,0,0,0])
set(gcf,'color','white')
indv_accel=reshape(indf_accel,1,1440*length(indf_accel(1,:)));
indv2_accel=[zeros(1,4*60) indv_accel(1:end-4*60)];
indq_accel=reshape(indv2_accel,1440,length(indf_accel(1,:)));
indfd1=indq_accel;
indfdv=reshape(indfd1,1,1440*length(indfd1(1,:)));
if gpsi==0
    indfdv2=zeros(size(indfdv));
    ab1=a1(a2<1440*length(indfd1(1,:)));
    ab2=a2(a2<1440*length(indfd1(1,:)));
    indfdv2(ab1)=indfdv(ab2);
else
    indfdv2=indfdv;
end
indfd2=reshape(indfdv2,1440,length(indfd1(1,:)));
indfd=indfd2(:,1:tpa);
indf_phone2=indfd;
clps=unique(indfd);
clrs=[1 1 1; .9 .9 .9;1 1 0 ;1 0 0];
excl=clps+1;
excl2=excl;
clr_accel=clrs(excl,:);
colormap(gca,clr_accel)
hhind=imagesc(flip(indfd,1));
axi = ancestor(hhind, 'axes');
xrule = axi.XAxis;   yrule = axi.YAxis;
epc_lbl2={' 6PM',' 3PM', '12PM', ' 9AM',' 6AM',' 3AM','12AM',' 9PM',' 6PM'};
set(gca,'YTick',(0.5:3*60:24*60+0.5),'YTickLabel',epc_lbl2(1:1:end),'TickDir','out', 'Linewidth',4,'FontName','Arial','FontWeight','b','FontSize',32,'Ygrid','off')           
set(gca,'XTick',[1 25.5:25:ldy+.5],'XTickLabel',{'1','25','50','75','100','125','150','175','200','225','250'},'XTickLabelRotation',0,'FontSize',32)
a = gca;                                % get handle to current axes
set(a,'box','off','color','none')           % set box property to off and remove background color
b = axes('Position',get(a,'Position'),'box','on','xtick',[],'ytick',[],'linewidth',4);   % create new, empty axes with box but without ticks
axes(a)          % set original axes as active
linkaxes([a b])  % link axes in case of zooming
xlabel('Relative Days','FontWeight','b','FontSize',32)
xlim([.5,tpa+.5])
savefig(strcat(outpp,stdy,'-',sb1(1:3),'-accel.fig'))
img = getframe(gcf);
imwrite(img.cdata, strcat(outpp,stdy,'-',sb1(1:3),'-accel.png'));

figg1=figure(555);
set(gcf,'position',get(0,'screensize')-[0,0,0,0])
set(gcf,'color','white')
subplot(4,1,3)
gind=imagesc(flip(indf_phone2,1));
axi = ancestor(gind, 'axes');
xrule = axi.XAxis;   yrule = axi.YAxis;
epc_lbl2={' 6PM',' 6PM'};
set(gca,'YTick',[],'YTickLabel',[],'TickDir','out', 'Linewidth',4,'FontName','Arial','FontWeight','b','FontSize',32,'Ygrid','off')
set(gca,'XTick',[],'XTickLabel',[],'XTickLabelRotation',0,'FontSize',32)
xlim([.5,tpa+.5])
savefig(strcat(outpp,stdy,'-',sb1(1:3),'-clin1.fig'))
img = getframe(gcf);
imwrite(img.cdata, strcat(outpp,stdy,'-',sb1(1:3),'-clin1.png'));
display('Phone Acceleration Saved.');

%% activity Raw
load(strcat(adr,'/',d3.name))
ff6=figure(6);
set(gcf,'position',get(0,'screensize')-[0,0,0,0])
set(gcf,'color','white')
%indf_xp(indf_xp==20)=0;
indv_act=reshape(indf_xp,1,1440*length(indf_xp(1,:)));
indv2_act=[zeros(1,0*60) indv_act(1:end-0*60)];
indf_act1=reshape(indv2_act,1440,length(indf_xp(1,:)));
indfd1=indf_act1;
indfdv=reshape(indfd1,1,1440*length(indfd1(1,:)));
if gpsi==0
    indfdv2=zeros(size(indfdv));
    indfdv2(a11)=indfdv(a22);
else
    indfdv2=indfdv;
end
indbv2=[indfdv2(6*60+1:end) zeros(1,6*60)];
indb_act=reshape(indbv2,1440,length(indfd1(1,:)));
indb_actm=[indb_act(:,2:end) zeros(1440,1)];
indb_active=[indb_act;indb_actm];
indfd=reshape(indfdv2,1440,length(indfd1(1,:)));
indf_active=indfd;
clps=unique(indfd);
excl=clps;
clrex=jet(length(excl));
clrx=[1 1 1;clrex(1:end,:)];
colormap(gca,clrx)
hhind=imagesc(flip(indfd,1));
axi = ancestor(hhind, 'axes');
xrule = axi.XAxis;   yrule = axi.YAxis;
epc_lbl2={' 6PM',' 3PM', '12PM', ' 9AM',' 6AM',' 3AM','12AM',' 9PM',' 6PM'};
set(gca,'YTick',(0.5:3*60:24*60+0.5),'YTickLabel',epc_lbl2(1:1:end),'TickDir','out', 'Linewidth',4,'FontName','Arial','FontWeight','b','FontSize',32,'Ygrid','off')           
set(gca,'XTick',[1 25.5:25:ldy+.5],'XTickLabel',{'1','25','50','75','100','125','150','175','200','225','250'},'XTickLabelRotation',0,'FontSize',32)
%set(gca,'XTick',[1 2:2:ldy],'XTickLabel',{'C','1','3','5','7','9','11','13','15','17','19','21','23','25','27','29'},'XTickLabelRotation',0,'FontSize',32)
a = gca;                                % get handle to current axes
set(a,'box','off','color','none')           % set box property to off and remove background color
b = axes('Position',get(a,'Position'),'box','on','xtick',[],'ytick',[],'linewidth',4);   % create new, empty axes with box but without ticks
axes(a)          % set original axes as active
linkaxes([a b])  % link axes in case of zooming
xlabel('Nights','FontWeight','b','FontSize',32)
xlim([.5,tpa+.5])
savefig(strcat(outpp,stdy,'-',sb1(1:3),'-rawact.fig'))
img = getframe(gcf);
imwrite(img.cdata, strcat(outpp,stdy,'-',sb1(1:3),'-rawact.png'));
display('Raw Actigraphy Saved.');

%% activity Raw not percentiled
indf_activer=zeros(size(indf_active));
if exist('indf_xpd')==1
    ff6r=figure(60);
    set(gcf,'position',get(0,'screensize')-[0,0,0,0])
    set(gcf,'color','white')
    %indf_xp(indf_xp==20)=0;
    indv_act=reshape(indf_xpd,1,1440*length(indf_xpd(1,:)));
    indv2_act=[zeros(1,0*60) indv_act(1:end-0*60)];
    indf_act1=reshape(indv2_act,1440,length(indf_xpd(1,:)));
    indfd1=indf_act1;
    indfdv=reshape(indfd1,1,1440*length(indfd1(1,:)));
    if gpsi==0
        indfdv2=zeros(size(indfdv));
        indfdv2(a11)=indfdv(a22);
    else
        indfdv2=indfdv;
    end
    indfd=reshape(indfdv2,1440,length(indfd1(1,:)));
    indf_activer=indfd;
    clps=unique(indfd);
    excl=clps;
    clrex=jet(length(excl));
    clrx=[clrex(1:end,:)];
    colormap(gca,clrx)
    hhind=imagesc(flip(indfd,1));
    axi = ancestor(hhind, 'axes');
    xrule = axi.XAxis;   yrule = axi.YAxis;
    epc_lbl2={' 6PM',' 3PM', '12PM', ' 9AM',' 6AM',' 3AM','12AM',' 9PM',' 6PM'};
    set(gca,'YTick',(0.5:3*60:24*60+0.5),'YTickLabel',epc_lbl2(1:1:end),'TickDir','out', 'Linewidth',4,'FontName','Arial','FontWeight','b','FontSize',32,'Ygrid','off')           
    set(gca,'XTick',[1 25.5:25:ldy+.5],'XTickLabel',{'1','25','50','75','100','125','150','175','200','225','250'},'XTickLabelRotation',0,'FontSize',32)
    %set(gca,'XTick',[1 2:2:ldy],'XTickLabel',{'C','1','3','5','7','9','11','13','15','17','19','21','23','25','27','29'},'XTickLabelRotation',0,'FontSize',32)
    a = gca;                                % get handle to current axes
    set(a,'box','off','color','none')           % set box property to off and remove background color
    b = axes('Position',get(a,'Position'),'box','on','xtick',[],'ytick',[],'linewidth',4);   % create new, empty axes with box but without ticks
    axes(a)          % set original axes as active
    linkaxes([a b])  % link axes in case of zooming
    xlabel('Days','FontWeight','b','FontSize',32)
    xlim([.5,tpa+.5])
    savefig(strcat(outpp,stdy,'-',sb1(1:3),'-rawactr.fig'))
    img = getframe(gcf);
    imwrite(img.cdata, strcat(outpp,stdy,'-',sb1(1:3),'-rawactr.png'));
    display('Very Raw Actigraphy Saved.');
end


%% activity Rawest 
indf_activest=zeros(size(indf_active));
if exist('indf_saf')==1
    ff6r1=figure(61);
    set(gcf,'position',get(0,'screensize')-[0,0,0,0])
    set(gcf,'color','white')
    indv_act=reshape(indf_saf,1,1440*length(indf_saf(1,:)));
    indv2_act=[zeros(1,0*60) indv_act(1:end-0*60)];
    indf_act1=reshape(indv2_act,1440,length(indf_saf(1,:)));
    indfd1=indf_act1;
    indfdv=reshape(indfd1,1,1440*length(indfd1(1,:)));
    if gpsi==0
        indfdv2=zeros(size(indfdv));
        indfdv2(a11)=indfdv(a22);
    else
        indfdv2=indfdv;
    end
    indfd=reshape(indfdv2,1440,length(indfd1(1,:)));
    indf_activest=indfd;
    clps=unique(indfd);
    excl=clps;
    clrex=jet(length(excl));
    clrx=[clrex(1:end,:)];
    colormap(gca,clrx)
    hhind=imagesc(flip(indfd,1));
    axi = ancestor(hhind, 'axes');
    xrule = axi.XAxis;   yrule = axi.YAxis;
    epc_lbl2={' 6PM',' 3PM', '12PM', ' 9AM',' 6AM',' 3AM','12AM',' 9PM',' 6PM'};
    set(gca,'YTick',(0.5:3*60:24*60+0.5),'YTickLabel',epc_lbl2(1:1:end),'TickDir','out', 'Linewidth',4,'FontName','Arial','FontWeight','b','FontSize',32,'Ygrid','off')           
    set(gca,'XTick',[1 25.5:25:ldy+.5],'XTickLabel',{'1','25','50','75','100','125','150','175','200','225','250'},'XTickLabelRotation',0,'FontSize',32)
    %set(gca,'XTick',[1 2:2:ldy],'XTickLabel',{'C','1','3','5','7','9','11','13','15','17','19','21','23','25','27','29'},'XTickLabelRotation',0,'FontSize',32)
    a = gca;                                % get handle to current axes
    set(a,'box','off','color','none')           % set box property to off and remove background color
    b = axes('Position',get(a,'Position'),'box','on','xtick',[],'ytick',[],'linewidth',4);   % create new, empty axes with box but without ticks
    axes(a)          % set original axes as active
    linkaxes([a b])  % link axes in case of zooming
    xlabel('Days','FontWeight','b','FontSize',32)
    xlim([.5,tpa+.5])
    savefig(strcat(outpp,stdy,'-',sb1(1:3),'-rawactst.fig'))
    img = getframe(gcf);
    imwrite(img.cdata, strcat(outpp,stdy,'-',sb1(1:3),'-rawactst.png'));
    display('The Rawest Actigraphy Saved.');
end

ff66=figure(66);
set(gcf,'position',get(0,'screensize')-[0,0,0,0])
set(gcf,'color','white')
colormap(gca,clrx)
hhind=imagesc(transpose(indb_active));
axi = ancestor(hhind, 'axes');
xrule = axi.XAxis;   yrule = axi.YAxis;
epc_lbl3={'12AM',  ' 6AM','12PM', ' 6PM','12AM', ' 6AM', '12PM', ' 6PM','12AM'};
set(gca,'XTick',(0.5:6*60:24*60+0.5),'XTickLabel',epc_lbl3(1:1:end),'TickDir','out', 'Linewidth',4,'FontName','Arial','FontWeight','b','FontSize',32,'Xgrid','off')         
set(gca,'YTick',[1 25.5:25:ldy+.5],'YTickLabel',{'1','25','50','75','100','125','150','175','200','225','250'},'YTickLabelRotation',0,'FontSize',32)
%set(gca,'XTick',[1 2:2:ldy],'XTickLabel',{'C','1','3','5','7','9','11','13','15','17','19','21','23','25','27','29'},'XTickLabelRotation',0,'FontSize',32)
a = gca;                                % get handle to current axes
set(a,'box','off','color','none')           % set box property to off and remove background color
b = axes('Position',get(a,'Position'),'box','on','xtick',[],'ytick',[],'linewidth',4);   % create new, empty axes with box but without ticks
axes(a)          % set original axes as active
linkaxes([a b])  % link axes in case of zooming
ylabel('Days','FontWeight','b','FontSize',32)
ylim([.5,tpa+.5])
savefig(strcat(outpp,stdy,'-',sb1(1:3),'-rawactb.fig'))
img = getframe(gcf);
imwrite(img.cdata, strcat(outpp,stdy,'-',sb1(1:3),'-rawactb.png'));
display('Raw Actigraphy Sleep-format Saved.');

%% Sleep Scored Raw
ff7=figure(7);
set(gcf,'position',get(0,'screensize')-[0,0,0,0])
set(gcf,'color','white')
indv_act=reshape(indf_act,1,1440*length(indf_act(1,:)));
indv2_act=[zeros(1,0*60) indv_act(1:end-0*60)];
indf_act2=reshape(indv2_act,1440,length(indf_act(1,:)));
indq_scr=indf_act2;
indfd1=indf_act2;
indfdv=reshape(indfd1,1,1440*length(indfd1(1,:)));
if gpsi==0
    indfdv2=zeros(size(indfdv));
    indfdv2(a11)=indfdv(a22);
else
    indfdv2=indfdv;
end
indbv2=[indfdv2(6*60+1:end) zeros(1,6*60)];
indb_sc=reshape(indbv2,1440,length(indfd1(1,:)));
indb_scm=[indb_sc(:,2:end) zeros(1440,1)];
indb_score=[indb_sc;indb_scm];
indfd=reshape(indfdv2,1440,length(indfd1(1,:)));
indf_score=indfd;
exd=unique(indfd);
if isempty(find(indfd==0)) %#ok<*EFIND>
    clrs=[0 0 1;0 1 1; 0 1 0; 1 0.65 0;1 0 0; 0 0 0];
else 
    clrs=[1 1 1; 0 0 1;0 1 1; 0.466 .67 0.188; 1 0.65 0;1 0 0; 1 1 0];
end
%clrx1=[1 1 1;1 1 .75;.9 .9 .9;1 .5 1;.5 1 1;.25 .25 1;0 0 1;0 1 0; 1 .55 .0; 1 0 0;0 0 0];
clrx1=clrs;
clr_scr=clrx1;
colormap(gca,clrx1)
hhind=imagesc(flip(indf_score,1));
axi = ancestor(hhind, 'axes');
xrule = axi.XAxis;   yrule = axi.YAxis;
epc_lbl2={' 6PM',' 3PM', '12PM', ' 9AM',' 6AM',' 3AM','12AM',' 9PM',' 6PM'};
set(gca,'YTick',(0.5:3*60:48*60+0.5),'YTickLabel',epc_lbl2(1:1:end),'TickDir','out', 'Linewidth',4,'FontName','Arial','FontWeight','b','FontSize',32,'Ygrid','off')           
%set(gca,'XTick',[1 25.5:25:ldy+.5],'XTickLabel',{'1','25','50','75','100','125','150','175','200','225','250'},'XTickLabelRotation',0,'FontSize',32)
set(gca,'XTick',[1 2:2:ldy],'XTickLabel',{'C','1','3','5','7','9','11','13','15','17','19','21','23','25','27','29'},'XTickLabelRotation',0,'FontSize',32)
a = gca;                                % get handle to current axes
set(a,'box','off','color','none')           % set box property to off and remove background color
b = axes('Position',get(a,'Position'),'box','on','xtick',[],'ytick',[],'linewidth',4);   % create new, empty axes with box but without ticks
axes(a)          % set original axes as active
linkaxes([a b])  % link axes in case of zooming
xlabel('Nights','FontWeight','b','FontSize',32)
xlim([.5,tpa+.5])
savefig(strcat(outpp,stdy,'-',sb1(1:3),'-slpact.fig'))
img = getframe(gcf);
imwrite(img.cdata, strcat(outpp,stdy,'-',sb1(1:3),'-slpact.png'));

figg1=figure(555);
set(gcf,'position',get(0,'screensize')-[0,0,0,0])
set(gcf,'color','white')
subplot(4,1,4)
gind=imagesc(flip(indf_score,1));
axi = ancestor(gind, 'axes');
xrule = axi.XAxis;   yrule = axi.YAxis;
epc_lbl2={' 6PM',' 6PM'};
set(gca,'YTick',[],'YTickLabel',[],'TickDir','out', 'Linewidth',4,'FontName','Arial','FontWeight','b','FontSize',32,'Ygrid','off')
set(gca,'XTick',[],'XTickLabel',[],'XTickLabelRotation',0,'FontSize',32)
xlim([.5,tpa+.5])
savefig(strcat(outpp,stdy,'-',sb1(1:3),'-clin1.fig'))
img = getframe(gcf);
imwrite(img.cdata, strcat(outpp,stdy,'-',sb1(1:3),'-clin1.png'));
display('Raw Sleep Score Saved.');

%% Aligned all with maximum days
tpmx=max([length(indq_gps(1,:));length(indq_pow(1,:));length(indq_accel(1,:));length(indq_scr(1,:))]);
tpst=floor(tpmx/10);
figg2=figure(666);
set(gcf,'position',get(0,'screensize')-[0,0,0,0])
set(gcf,'color','white')
%Actigraphy
subplot(4,1,1)
colormap(gca,clr_scr)
gind=imagesc(indq_scr);
axi = ancestor(gind, 'axes');
xrule = axi.XAxis;   yrule = axi.YAxis;
epc_lbl2={' 6PM',' 6PM'};
set(gca,'YTick',[],'YTickLabel',[],'TickDir','out', 'Linewidth',4,'FontName','Arial','FontWeight','b','FontSize',32,'Ygrid','off')
set(gca,'XTick',[],'XTickLabel',[],'XTickLabelRotation',0,'FontSize',32)
xlim([.5,tpmx+.5])
%Phone GPS
subplot(4,1,2)
colormap(gca,clr_gps)
gind=imagesc(indq_gps);
axi = ancestor(gind, 'axes');
xrule = axi.XAxis;   yrule = axi.YAxis;
epc_lbl2={' 6PM',' 6PM'};
set(gca,'YTick',[],'YTickLabel',[],'TickDir','out', 'Linewidth',4,'FontName','Arial','FontWeight','b','FontSize',32,'Ygrid','off')
set(gca,'XTick',[],'XTickLabel',[],'XTickLabelRotation',0,'FontSize',32)
xlim([.5,tpmx+.5])
%Phone Power
subplot(4,1,3)
colormap(gca,clr_pow)
gind=imagesc(indq_pow);
axi = ancestor(gind, 'axes');
xrule = axi.XAxis;   yrule = axi.YAxis;
epc_lbl2={' 6PM',' 6PM'};
set(gca,'YTick',[],'YTickLabel',[],'TickDir','out', 'Linewidth',4,'FontName','Arial','FontWeight','b','FontSize',32,'Ygrid','off')
set(gca,'XTick',[],'XTickLabel',[],'XTickLabelRotation',0,'FontSize',32)
xlim([.5,tpmx+.5])
%Phone Acceleration
subplot(4,1,4)
colormap(gca,clr_accel)
gind=imagesc(indq_accel);
axi = ancestor(gind, 'axes');
xrule = axi.XAxis;   yrule = axi.YAxis;
epc_lbl2={' 6PM',' 6PM'};
set(gca,'YTick',[],'YTickLabel',[],'TickDir','out', 'Linewidth',4,'FontName','Arial','FontWeight','b','FontSize',32,'Ygrid','off','TickLength',[0 0])
set(gca,'XTick',tpst:tpst:tpmx,'XTickLabel',tpst:tpst:tpmx,'XTickLabelRotation',0,'FontSize',32)
xlim([.5,tpmx+.5])
savefig(strcat(outpp,stdy,'-',sb1(1:3),'-clin2.fig'))
img = getframe(gcf);
imwrite(img.cdata, strcat(outpp,stdy,'-',sb1(1:3),'-clin2.png'));



ff77=figure(77);
set(gcf,'position',get(0,'screensize')-[0,0,0,0])
set(gcf,'color','white')
colormap(gca,clrx1)
hhind=imagesc(transpose(indb_score));
axi = ancestor(hhind, 'axes');
xrule = axi.XAxis;   yrule = axi.YAxis;
epc_lbl3={'12AM', ' 6AM', '12PM', ' 6PM','12AM', ' 6AM', '12PM', ' 6PM','12AM'};
set(gca,'XTick',(0.5:6*60:48*60+0.5),'XTickLabel',epc_lbl3(1:1:end),'TickDir','out', 'Linewidth',4,'FontName','Arial','FontWeight','b','FontSize',32,'Xgrid','off')         
set(gca,'YTick',[1 25.5:25:ldy+.5],'YTickLabel',{'1','25','50','75','100','125','150','175','200','225','250'},'YTickLabelRotation',0,'FontSize',32)
%set(gca,'XTick',[1 2:2:ldy],'XTickLabel',{'C','1','3','5','7','9','11','13','15','17','19','21','23','25','27','29'},'XTickLabelRotation',0,'FontSize',32)
a = gca;                                % get handle to current axes
set(a,'box','off','color','none')           % set box property to off and remove background color
b = axes('Position',get(a,'Position'),'box','on','xtick',[],'ytick',[],'linewidth',4);   % create new, empty axes with box but without ticks
axes(a)          % set original axes as active
linkaxes([a b])  % link axes in case of zooming
ylabel('Days','FontWeight','b','FontSize',32)
ylim([.5,tpa+.5])
savefig(strcat(outpp,stdy,'-',sb1(1:3),'-slpactb.fig'))
img = getframe(gcf);
imwrite(img.cdata, strcat(outpp,stdy,'-',sb1(1:3),'-slpactb.png'));
display('Raw Sleep Score Sleep-format Saved.');

%% Missing
ff8=figure(8);
set(gcf,'position',get(0,'screensize')-[0,0,0,0])
set(gcf,'color','white')
indfd3=zeros(size(indfd));
indfd3(indfd==0)=1;
clps=unique(indfd);
clrs=[1 1 1; 0 0 0];
excl=clps;
clrex=jet(length(excl));
colormap(gca,clrs)
indf_miss=indfd3;
hhind=imagesc(flip(indfd3,1));
axi = ancestor(hhind, 'axes');
xrule = axi.XAxis;   yrule = axi.YAxis;
epc_lbl2={' 6PM',' 3PM', '12PM', ' 9AM',' 6AM',' 3AM','12AM',' 9PM',' 6PM'};
set(gca,'YTick',(0.5:3*60:24*60+0.5),'YTickLabel',epc_lbl2(1:1:end),'TickDir','out', 'Linewidth',4,'FontName','Arial','FontWeight','b','FontSize',32,'Ygrid','off')           
set(gca,'XTick',[1 25.5:25:ldy+.5],'XTickLabel',{'1','25','50','75','100','125','150','175','200','225','250'},'XTickLabelRotation',0,'FontSize',32)
a = gca;                                % get handle to current axes
set(a,'box','off','color','none')           % set box property to off and remove background color
b = axes('Position',get(a,'Position'),'box','on','xtick',[],'ytick',[],'linewidth',4);   % create new, empty axes with box but without ticks
axes(a)          % set original axes as active
linkaxes([a b])  % link axes in case of zooming
xlabel('Relative Days','FontWeight','b','FontSize',32)
xlim([.5,tpa+.5])
savefig(strcat(outpp,stdy,'-',sb1(1:3),'-missing.fig'))
img = getframe(gcf);
imwrite(img.cdata, strcat(outpp,stdy,'-',sb1(1:3),'-missing.png'));
display('Missing Data Saved.');

%% Sleep
ff9=figure(9);
set(gcf,'position',get(0,'screensize')-[0,0,0,0])
set(gcf,'color','white')
indv_slp=reshape(indf_slp,1,1440*length(indf_slp(1,:)));
indv2_slp=[zeros(1,0*60) indv_slp(1:end-0*60)];
indf_slp=reshape(indv2_slp,1440,length(indf_slp(1,:)));
indfd1=indf_slp;
indfdv=reshape(indfd1,1,1440*length(indfd1(1,:)));
if gpsi==0
    indfdv2=zeros(size(indfdv));
    indfdv2(a11)=indfdv(a22);
else
    indfdv2=indfdv;
end
indbv2=[indfdv2(6*60+1:end) zeros(1,6*60)];
indb_sl=reshape(indbv2,1440,length(indfd1(1,:)));
indb_slm=[indb_sl(:,2:end) zeros(1440,1)];
indb_sleep=[indb_sl;indb_slm];
indfd=reshape(indfdv2,1440,length(indfd1(1,:)));
%clrs=[1 1 1; .9 .9 .9;1 1 0 ;1 0 0;0 1 1];
clrs=[1 1 1; 0 0 1; 0.9 0.9 0.9];
colormap(gca,clrs)
indf_sleep=indfd;
hhind=imagesc(flip(indfd,1));
axi = ancestor(hhind, 'axes');
xrule = axi.XAxis;   yrule = axi.YAxis;
epc_lbl2={' 6PM',' 3PM', '12PM', ' 9AM',' 6AM',' 3AM','12AM',' 9PM',' 6PM'};
set(gca,'YTick',(0.5:3*60:24*60+0.5),'YTickLabel',epc_lbl2(1:1:end),'TickDir','out', 'Linewidth',4,'FontName','Arial','FontWeight','b','FontSize',32,'Ygrid','off')         
set(gca,'XTick',[1 25.5:25:ldy+.5],'XTickLabel',{'1','25','50','75','100','125','150','175','200','225','250'},'XTickLabelRotation',0,'FontSize',32)
%set(gca,'XTick',[1 2:2:ldy],'XTickLabel',{'C','1','3','5','7','9','11','13','15','17','19','21','23','25','27','29'},'XTickLabelRotation',0,'FontSize',32)
a = gca;                                % get handle to current axes
set(a,'box','off','color','none')           % set box property to off and remove background color
b = axes('Position',get(a,'Position'),'box','on','xtick',[],'ytick',[],'linewidth',4);   % create new, empty axes with box but without ticks
axes(a)          % set original axes as active
linkaxes([a b])  % link axes in case of zooming
xlabel('Nights','FontWeight','b','FontSize',32)
xlim([.5,tpa+.5])
savefig(strcat(outpp,stdy,'-',sb1(1:3),'-sleep.fig'))
img = getframe(gcf);
imwrite(img.cdata, strcat(outpp,stdy,'-',sb1(1:3),'-sleep.png'));
display('Sleep Data Saved.');

ff99=figure(99);
set(gcf,'position',get(0,'screensize')-[0,0,0,0])
set(gcf,'color','white')
colormap(gca,clrs)
hhind=imagesc(transpose(indb_sleep));
axi = ancestor(hhind, 'axes');
xrule = axi.XAxis;   yrule = axi.YAxis;
epc_lbl3={'12AM', ' 6AM', '12PM', ' 6PM','12AM', ' 6AM', '12PM', ' 6PM','12AM'};
set(gca,'XTick',(0.5:6*60:48*60+0.5),'XTickLabel',epc_lbl3(1:1:end),'TickDir','out', 'Linewidth',4,'FontName','Arial','FontWeight','b','FontSize',32,'Xgrid','off')         
set(gca,'YTick',[1 25.5:25:ldy+.5],'YTickLabel',{'1','25','50','75','100','125','150','175','200','225','250'},'YTickLabelRotation',0,'FontSize',32)
%set(gca,'XTick',[1 2:2:ldy],'XTickLabel',{'C','1','3','5','7','9','11','13','15','17','19','21','23','25','27','29'},'XTickLabelRotation',0,'FontSize',32)
a = gca;                                % get handle to current axes
set(a,'box','off','color','none')           % set box property to off and remove background color
b = axes('Position',get(a,'Position'),'box','on','xtick',[],'ytick',[],'linewidth',4);   % create new, empty axes with box but without ticks
axes(a)          % set original axes as active
linkaxes([a b])  % link axes in case of zooming
ylabel('Days','FontWeight','b','FontSize',32)
ylim([.5,tpa+.5])
savefig(strcat(outpp,stdy,'-',sb1(1:3),'-sleepb.fig'))
img = getframe(gcf);
imwrite(img.cdata, strcat(outpp,stdy,'-',sb1(1:3),'-sleepb.png'));
display('Sleep Sleep-format Saved.');

% button press
indv_bp=reshape(indf_bp,1,1440*length(indf_bp(1,:)));
indv2_bp=[zeros(1,0*60) indv_bp(1:end-0*60)];
indf_bp=reshape(indv2_bp,1440,length(indf_bp(1,:)));
indfd1=indf_bp;
indfdv=reshape(indfd1,1,1440*length(indfd1(1,:)));
if gpsi==0
    indfdv2=zeros(size(indfdv));
    indfdv2(a11)=indfdv(a22);
else
    indfdv2=indfdv;
end
indf_btp=reshape(indfdv2,1440,length(indfd1(1,:)));
display('Button Press Data Saved.');

%% Light
ff10=figure(10);
set(gcf,'position',get(0,'screensize')-[0,0,0,0])
set(gcf,'color','white')
indv_mgf=reshape(indf_mgf,1,1440*length(indf_mgf(1,:)));
indv2_mgf=[zeros(1,0*60) indv_mgf(1:end-0*60)];
indf_mgf=reshape(indv2_mgf,1440,length(indf_mgf(1,:)));
indfd1=indf_mgf;
indfdv=reshape(indfd1,1,1440*length(indfd1(1,:)));
if gpsi==0
    indfdv2=zeros(size(indfdv));
    indfdv2(a11)=indfdv(a22);
else
    indfdv2=indfdv;
end
indfd=reshape(indfdv2,1440,length(indfd1(1,:)));
indfd(indfd>100)=100;
colormap(gca,[1 1 1;jet])
indf_light=indfd;
hhind=imagesc(flip(indfd,1));
axi = ancestor(hhind, 'axes');
xrule = axi.XAxis;   yrule = axi.YAxis;
epc_lbl2={' 6PM',' 3PM', '12PM', ' 9AM',' 6AM',' 3AM','12AM',' 9PM',' 6PM'};
set(gca,'YTick',(0.5:3*60:24*60+0.5),'YTickLabel',epc_lbl2(1:1:end),'TickDir','out', 'Linewidth',4,'FontName','Arial','FontWeight','b','FontSize',32,'Ygrid','off')           
%set(gca,'XTick',[1 25.5:25:ldy+.5],'XTickLabel',{'1','25','50','75','100','125','150','175','200','225','250'},'XTickLabelRotation',0,'FontSize',32)
set(gca,'XTick',[1 2:2:ldy],'XTickLabel',{'C','1','3','5','7','9','11','13','15','17','19','21','23','25','27','29'},'XTickLabelRotation',0,'FontSize',32)
a = gca;                                % get handle to current axes
set(a,'box','off','color','none')           % set box property to off and remove background color
b = axes('Position',get(a,'Position'),'box','on','xtick',[],'ytick',[],'linewidth',4);   % create new, empty axes with box but without ticks
axes(a)          % set original axes as active
linkaxes([a b])  % link axes in case of zooming
xlabel('Nights','FontWeight','b','FontSize',32)
xlim([.5,tpa+.5])
savefig(strcat(outpp,stdy,'-',sb1(1:3),'-light.fig'))
img = getframe(gcf);
imwrite(img.cdata, strcat(outpp,stdy,'-',sb1(1:3),'-light.png'));
display('Light Data Saved.');

%% Exclude missing and travel days
%sms1=nansum(indf_miss);
%dms=zeros(size(sms1));
%dms(sms1>3*60)=1;
%indtm=ind_tmzz;
%indtd=nansum(diff(indtm));
%indtm(indtm~=0)=1;
%sms2=nansum(indtm);
%dms(sms2>3*60 & sms2<24*60)=1;
%dms2=zeros(size(dms));
%dms2(dms==0)=1;
%idms=find(dms>0 | indtd~=0);
ltkc=ltkn;
lnkc=lnkn;

%% Walk and Run Data
indf_walk=zeros(1440,tpmx);
indf_wall=zeros(1440,2*tpmx);
if exist('indf_wk')==1
    ff6wp=figure(633);
    set(gcf,'position',get(0,'screensize')-[0,0,0,0])
    set(gcf,'color','white')
    indv_act=reshape(indf_wk,1,1440*length(indf_wk(1,:)));
    indv2_act=[zeros(1,0*60) indv_act(1:end-0*60)];
    indf_act1=reshape(indv2_act,1440,length(indf_wk(1,:)));
    indfd1=indf_act1;
    indfdv=reshape(indfd1,1,1440*length(indfd1(1,:)));
    if gpsi==0
        indfdv2=zeros(size(indfdv));
        indfdv2(a11)=indfdv(a22);
    else
        indfdv2=indfdv;
    end
    indfd=reshape(indfdv2,1440,length(indfd1(1,:)));
    indf_walk=indfd;
    clr_walk=[1 1 1; .9 .9 .9; 0 1 0; 1 1 0; 1 0 0];
    colormap(gca,clr_walk)
    %   h25w=colorbar;
    hhind=imagesc(flip(indf_walk,1));
    axi = ancestor(hhind, 'axes');
    xrule = axi.XAxis;   yrule = axi.YAxis;
    epc_lbl2={' 6PM',' 3PM', '12PM', ' 9AM',' 6AM',' 3AM','12AM',' 9PM',' 6PM'};
    set(gca,'YTick',(0.5:3*60:24*60+0.5),'YTickLabel',epc_lbl2(1:1:end),'TickDir','out', 'Linewidth',4,'FontName','Arial','FontWeight','b','FontSize',32,'Ygrid','off')           
    set(gca,'XTick',[1 25.5:25:ldy+.5],'XTickLabel',[1 25.5:25:ldy+.5],'XTickLabelRotation',0,'FontSize',32)
    %set(gca,'XTick',[1 2:2:ldy],'XTickLabel',{'C','1','3','5','7','9','11','13','15','17','19','21','23','25','27','29'},'XTickLabelRotation',0,'FontSize',32)
    a = gca;                                % get handle to current axes
    set(a,'box','off','color','none')           % set box property to off and remove background color
    b = axes('Position',get(a,'Position'),'box','on','xtick',[],'ytick',[],'linewidth',4);   % create new, empty axes with box but without ticks
    axes(a)          % set original axes as active
    linkaxes([a b])  % link axes in case of zooming
    %  lblf2={'Watch Off';'Idle';'Active';'Walk'; 'Run'};
    %  set(h25w,'YTick',.5:.87:8.5,'YTickLabel',lblf2,'FontSize',18)
    xlabel('Days','FontWeight','b','FontSize',32)
    xlim([.5,tpa+.5])
    savefig(strcat(outpp,stdy,'-',sb1(1:3),'-walkact.fig'))
    img = getframe(gcf);
    imwrite(img.cdata, strcat(outpp,stdy,'-',sb1(1:3),'-walkact.png'));
    display('Walk-Run Actigraphy Saved.');

    ff6wall=figure(644);
    set(gcf,'position',get(0,'screensize')-[0,0,0,0])
    set(gcf,'color','white')
    ukg=unique(indq_gps);    ukgm=max(ukg);
    uka=unique(indq_accel);  
    indr_accel=zeros(size(indq_accel));
    ukp=unique(indq_pow);    
    indr_pow=zeros(size(indq_pow));
    ukw=unique(indf_walk);   
    indr_wslp=zeros(size(indf_walk));
    for ik=1:length(ukw)
        indr_wslp(indf_walk==ukw(ik))=ukgm+ik;
    end
    ukwm=ukgm+ik;
    for ik=1:length(uka)
        indr_accel(indq_accel==uka(ik))=ukwm+ik;
    end
    ukam=ukwm+ik;
    for ik=1:length(ukp)
        indr_pow(indq_pow==ukp(ik))=ukam+ik;
    end
    ukpm=ukam+ik;
    indf_wall=(ukwm+1)*ones(1440,2*tpmx);
    alph_wall=zeros(1440,2*tpmx);
    indv_wslp=reshape(indr_wslp,1,1440*length(indr_wslp(1,:)));
    indv_wslp2=[indv_wslp((12*60+1):end) min(indv_wslp)*ones(1,12*60)];
    indr_wslp=reshape(indv_wslp2,1440,length(indr_wslp(1,:)));
    alph_wslp=ones(size(indr_wslp));
    indv_gps=reshape(indq_gps,1,1440*length(indq_gps(1,:)));
    indv_gps2=[indv_gps((12*60+1):end) max(indv_gps)*ones(1,12*60)];
    indq_gps=reshape(indv_gps2,1440,length(indq_gps(1,:)));
    alph_gps=0.4*ones(size(indq_gps));
    indf_wall(:,1:2:2*length(indr_wslp(1,:)))=indr_wslp;
    alph_wall(:,1:2:2*length(alph_wslp(1,:)))=alph_wslp;
    %indf_wall(:,2:4:4*length(indr_pow(1,:)))=indr_pow;
    %indf_wall(:,3:4:4*length(indr_accel(1,:)))=indr_accel;
    indf_wall(:,2:2:2*length(indq_gps(1,:)))=indq_gps;
    alph_wall(:,2:2:2*length(alph_gps(1,:)))=alph_gps;
    clr_all=[clr_gps;clr_walk;1 1 1];        %clr_accel;clr_pow;1 1 1];
    colormap(gca,clr_all)
    hhind=imagesc(flip(indf_wall,1),'AlphaData',flip(alph_wall,1));
    axi = ancestor(hhind, 'axes');
    xrule = axi.XAxis;   yrule = axi.YAxis;
    epc_lbl2={' 6AM',' 3AM','12AM',' 9PM',' 6PM',' 3PM', '12PM', ' 9AM',' 6AM'};
    set(gca,'YTick',(0.5:3*60:24*60+0.5),'YTickLabel',epc_lbl2(1:1:end),'TickDir','out', 'Linewidth',4,'FontName','Arial','FontWeight','b','FontSize',32,'Ygrid','off')           
    set(gca,'XTick',[1 2*25.5:2*25:2*tpmx+.5],'XTickLabel',[1 50:50:2*tpmx],'XTickLabelRotation',0,'FontSize',32)
    
    a = gca;                                % get handle to current axes
    set(a,'box','off','color','none')           % set box property to off and remove background color
    b = axes('Position',get(a,'Position'),'box','on','xtick',[],'ytick',[],'linewidth',4);   % create new, empty axes with box but without ticks
    axes(a)          % set original axes as active
    linkaxes([a b])  % link axes in case of zooming
%  lblf2={'Watch Off';'Idle';'Active';'Walk'; 'Run'};
%  set(h25w,'YTick',.5:.87:8.5,'YTickLabel',lblf2,'FontSize',18)
    xlabel('Days','FontWeight','b','FontSize',32)
    xlim([.5,2*tpmx+.5])
    savefig(strcat(outpp,stdy,'-',sb1(1:3),'-wallact.fig'))
    img = getframe(gcf);
    imwrite(img.cdata, strcat(outpp,stdy,'-',sb1(1:3),'-wallact.png'));
    display('Walk-Run Actigraphy All Saved.');
end

%% Walk and Run Frequency Data
indf_pfreq=zeros(1440,tpmx);
if exist('indf_pf')==1    
    indv_act=reshape(indf_pf,1,1440*length(indf_wk(1,:)));
    indv2_act=[zeros(1,0*60) indv_act(1:end-0*60)];
    indf_act1=reshape(indv2_act,1440,length(indf_wk(1,:)));
    indfd1=indf_act1;
    indfdv=reshape(indfd1,1,1440*length(indfd1(1,:)));
    if gpsi==0
        indfdv2=zeros(size(indfdv));
        indfdv2(a11)=indfdv(a22);
    else
        indfdv2=indfdv;
    end
    indfd=reshape(indfdv2,1440,length(indfd1(1,:)));
    indf_pfreq=indfd;
end

%% After QC this file will be available
qcd=strcat(adrph,'GENERAL/',stdy,'/',sb1,'/actigraphy/processed/mtl6/',sb1,'_res_foc_qcd.csv');
inds_nqc=zeros(size(indf_sleep));
inds_ntqc=zeros(size(indf_sleep));
inds_qc=zeros(size(indf_sleep));
inds_psg=zeros(size(indf_sleep));
inds_psgqc=zeros(length(indf_sleep(:,1)),20*length(indf_sleep(1,:)));
indf_wslp=zeros(1440,tpmx);
if exist(qcd)
    qst=readtable(qcd);
    ndy=height(qst);
    qst1=qst(:,1:30);
    %%
    for dy1=1:ndy
        tst1=qst.sleep_start_qc{dy1};
        tst2=qst.sleep_wake_qc{dy1};
        tsn1=qst.sleep_start{dy1};
        tsn2=qst.sleep_wake{dy1};
        ns1=qst.nap1_str_qc{dy1};
        np1=qst.nap1_stp_qc{dy1};
        ns2=qst.nap2_str_qc{dy1};
        np2=qst.nap2_stp_qc{dy1};
        try 
            pst1=qst.psg_on_qc{dy1};
            pst2=qst.psg_off_qc{dy1};
        catch ME
            pst1='00:00';
            pst2='00:00';
        end        
        accp=qst.data_accpt_qc(dy1);
        accpnt=qst.data_accpt(dy1);
        if accpnt==1
            %% Goto not QCed sleep epoch
            sn1=datenum(tsn1,'HH:MM');
            sn2=datenum(tsn2,'HH:MM');
            sr=datenum('17:59','HH:MM');
            if sr>sn1
                sn1=sn1+1;
            end
            if sr>sn2
                sn2=sn2+1;
            end
            if sn1>sn2
                sn2=sn2+1;
            end
            idn1=round(24*60*(sn1-sr)); % Sleep beginning
            idn2=round(24*60*(sn2-sr));   % Sleep End
            inds_ntqc(idn1:idn2,dy1)=1;
        end
        if accp==1
            %% Goto sleep epoch
            s1=datenum(tst1,'HH:MM');
            s2=datenum(tst2,'HH:MM');
            sr=datenum('17:59','HH:MM');
            if sr>s1
                s1=s1+1;
            end
            if sr>s2
                s2=s2+1;
            end
            if s1>s2
                s2=s2+1;
            end
            id1=round(24*60*(s1-sr)); % Sleep beginning
            id2=round(24*60*(s2-sr));   % Sleep End
            inds_qc(id1:id2,dy1)=1;
            inds_nqc(id1:id2,dy1)=1;
            if id1==id2
            else
                inds_psgqc(id1:id2,(20*dy1-9):(20*dy1-1))=1;
            end
            %% Goto nap1 epoch
            s1=datenum(ns1,'HH:MM');
            s2=datenum(np1,'HH:MM');
            sr=datenum('17:59','HH:MM');
            if sr>s1
                s1=s1+1;
            end
            if sr>s2
                s2=s2+1;
            end
            if s1>s2
                s2=s2+1;
            end
            id1=round(24*60*(s1-sr)); % Nap beginning
            id2=round(24*60*(s2-sr));   % Nap End
            if (id2-id1)>220
                inds_nqc(id1:id2,dy1)=2;
            end
            %% Goto nap2 epoch
            s1=datenum(ns2,'HH:MM');
            s2=datenum(np2,'HH:MM');
            sr=datenum('17:59','HH:MM');
            if sr>s1
                s1=s1+1;
            end
            if sr>s2
                s2=s2+1;
            end
            if s1>s2
                s2=s2+1;
            end
            id1=round(24*60*(s1-sr)); % Nap beginning
            id2=round(24*60*(s2-sr));   % Nap End
            if (id2-id1)>220
                inds_nqc(id1:id2,dy1)=2;
            end
            %% PSG sleep epoch
            s1=datenum(pst1,'HH:MM');
            s2=datenum(pst2,'HH:MM');
            sr=datenum('17:59','HH:MM');
            if sr>s1
                s1=s1+1;
            end
            if sr>s2
                s2=s2+1;
            end
            if s1>s2
                s2=s2+1;
            end
            id1=round(24*60*(s1-sr)); % Sleep beginning
            id2=round(24*60*(s2-sr));   % Sleep End
            inds_psg(id1:id2,dy1)=1;
            if id1==id2
            else
                inds_psgqc(id1:id2,20*dy1:(20*dy1+8))=2;
            end 
        end
    end

    ff11=figure(11);
    set(gcf,'position',get(0,'screensize')-[0,0,0,0])
    set(gcf,'color','white')
    clrs=[1 1 1; 0 0 1];
    colormap(gca,clrs)
    hhind=imagesc(flip(inds_qc,1));
    axi = ancestor(hhind, 'axes');
    xrule = axi.XAxis;   yrule = axi.YAxis;
    epc_lbl2={' 6PM',' 3PM', '12PM', ' 9AM',' 6AM',' 3AM','12AM',' 9PM',' 6PM'};
    set(gca,'YTick',(0.5:3*60:24*60+0.5),'YTickLabel',epc_lbl2(1:1:end),'TickDir','out', 'Linewidth',4,'FontName','Arial','FontWeight','b','FontSize',28,'Ygrid','off')           
  %  set(gca,'XTick',[1 25.5:25:ldy+.5],'XTickLabel',{'1','25','50','75','100','125','150','175','200','225','250'},'XTickLabelRotation',0,'FontSize',32)
  %      set(gca,'XTick',[1 50.5:50:ldy+.5],'XTickLabel',{'1','50','100','150','200','250','300','350','400','450','500','550'},'XTickLabelRotation',0,'FontSize',32)

    %set(gca,'XTick',[1 5.5:5:ldy+.5],'XTickLabel',{'1','5','10','15','20','25','30','35','40','45','50','55','60','65','70'},'XTickLabelRotation',0,'FontSize',28)

    %set(gca,'XTick',[1 2:2:ldy],'XTickLabel',{'C','1','3','5','7','9','11','13','15','17','19','21','23','25','27','29'},'XTickLabelRotation',0,'FontSize',32)
    a = gca;                                % get handle to current axes
    set(a,'box','off','color','none')           % set box property to off and remove background color
    b = axes('Position',get(a,'Position'),'box','on','xtick',[],'ytick',[],'linewidth',4);   % create new, empty axes with box but without ticks
    axes(a)          % set original axes as active
    linkaxes([a b])  % link axes in case of zooming
    xlabel('Days','FontWeight','b','FontSize',32)
    xlim([.5,tpa+.5])
    savefig(strcat(outpp,stdy,'-',sb1(1:3),'-sleepqcd.fig'))
    img = getframe(gcf);
    imwrite(img.cdata, strcat(outpp,stdy,'-',sb1(1:3),'-sleepqcd.png'));
    display('QCd Sleep Data Saved.');

    %% activity Walk-Run
    indf_wall=zeros(1440,2*tpmx);
    if exist('indf_wk')==1
        ff6w=figure(63);
        set(gcf,'position',get(0,'screensize')-[0,0,0,0])
        set(gcf,'color','white')
        
        indf_wslp=indf_walk;
        indf_wslp(indf_wslp==1 & inds_qc==1)=5;
        clr_wslp=[1 1 1; .9 .9 .9; 0 1 0; 1 1 0; 1 0 0;0 1 1];
        colormap(gca,clr_wslp)
    %   h25w=colorbar;
        hhind=imagesc(flip(indf_wslp,1));
        axi = ancestor(hhind, 'axes');
        xrule = axi.XAxis;   yrule = axi.YAxis;
        epc_lbl2={' 6PM',' 3PM', '12PM', ' 9AM',' 6AM',' 3AM','12AM',' 9PM',' 6PM'};
        set(gca,'YTick',(0.5:3*60:24*60+0.5),'YTickLabel',epc_lbl2(1:1:end),'TickDir','out', 'Linewidth',4,'FontName','Arial','FontWeight','b','FontSize',32,'Ygrid','off')           
        set(gca,'XTick',[1 25.5:25:ldy+.5],'XTickLabel',{'1','25','50','75','100','125','150','175','200','225','250','275'},'XTickLabelRotation',0,'FontSize',32)
        %set(gca,'XTick',[1 2:2:ldy],'XTickLabel',{'C','1','3','5','7','9','11','13','15','17','19','21','23','25','27','29'},'XTickLabelRotation',0,'FontSize',32)
        a = gca;                                % get handle to current axes
        set(a,'box','off','color','none')           % set box property to off and remove background color
        b = axes('Position',get(a,'Position'),'box','on','xtick',[],'ytick',[],'linewidth',4);   % create new, empty axes with box but without ticks
        axes(a)          % set original axes as active
        linkaxes([a b])  % link axes in case of zooming
    %  lblf2={'Watch Off';'Idle';'Active';'Walk'; 'Run'};
    %  set(h25w,'YTick',.5:.87:8.5,'YTickLabel',lblf2,'FontSize',18)
        xlabel('Days','FontWeight','b','FontSize',32)
        xlim([.5,tpa+.5])
        savefig(strcat(outpp,stdy,'-',sb1(1:3),'-walkactslp.fig'))
        img = getframe(gcf);
        imwrite(img.cdata, strcat(outpp,stdy,'-',sb1(1:3),'-walkactslp.png'));
        display('Walk-Run Actigraphy Saved with Sleep.');

        ff6wall=figure(64);
        set(gcf,'position',get(0,'screensize')-[0,0,0,0])
        set(gcf,'color','white')
        ukg=unique(indq_gps);    ukgm=max(ukg);
        uka=unique(indq_accel);  
        indr_accel=zeros(size(indq_accel));
        ukp=unique(indq_pow);    
        indr_pow=zeros(size(indq_pow));
        ukw=unique(indf_wslp);   
        indr_wslp=zeros(size(indf_wslp));
        for ik=1:length(ukw)
            indr_wslp(indf_wslp==ukw(ik))=ukgm+ik;
        end
        ukwm=ukgm+ik;
        for ik=1:length(uka)
            indr_accel(indq_accel==uka(ik))=ukwm+ik;
        end
        ukam=ukwm+ik;
        for ik=1:length(ukp)
            indr_pow(indq_pow==ukp(ik))=ukam+ik;
        end
        ukpm=ukam+ik;
        indf_wall=(ukwm+1)*ones(1440,2*tpmx);
        alph_wall=zeros(1440,2*tpmx);
        indv_wslp=reshape(indr_wslp,1,1440*length(indr_wslp(1,:)));
        indv_wslp2=[indv_wslp((12*60+1):end) min(indv_wslp)*ones(1,12*60)];
        indr_wslp=reshape(indv_wslp2,1440,length(indr_wslp(1,:)));
        alph_wslp=ones(size(indr_wslp));
        indv_gps=reshape(indq_gps,1,1440*length(indq_gps(1,:)));
        indv_gps2=[indv_gps((12*60+1):end) max(indv_gps)*ones(1,12*60)];
        indq_gps=reshape(indv_gps2,1440,length(indq_gps(1,:)));
        alph_gps=0.4*ones(size(indq_gps));
        indf_wall(:,1:2:2*length(indr_wslp(1,:)))=indr_wslp;
        alph_wall(:,1:2:2*length(alph_wslp(1,:)))=alph_wslp;
        %indf_wall(:,2:4:4*length(indr_pow(1,:)))=indr_pow;
        %indf_wall(:,3:4:4*length(indr_accel(1,:)))=indr_accel;
        indf_wall(:,2:2:2*length(indq_gps(1,:)))=indq_gps;
        alph_wall(:,2:2:2*length(alph_gps(1,:)))=alph_gps;
        clr_all=[clr_gps;clr_wslp;1 1 1];        %clr_accel;clr_pow;1 1 1];
        colormap(gca,clr_all)
    %   h25w=colorbar;
        hhind=imagesc(flip(indf_wall,1),'AlphaData',flip(alph_wall,1));
        axi = ancestor(hhind, 'axes');
        xrule = axi.XAxis;   yrule = axi.YAxis;
        epc_lbl2={' 6AM',' 3AM','12AM',' 9PM',' 6PM',' 3PM', '12PM', ' 9AM',' 6AM'};
        set(gca,'YTick',(0.5:3*60:24*60+0.5),'YTickLabel',epc_lbl2(1:1:end),'TickDir','out', 'Linewidth',4,'FontName','Arial','FontWeight','b','FontSize',32,'Ygrid','off')           
        set(gca,'XTick',[1 2*25.5:2*25:2*tpmx+.5],'XTickLabel',[1 50:50:2*tpmx],'XTickLabelRotation',0,'FontSize',32)
        
        a = gca;                                % get handle to current axes
        set(a,'box','off','color','none')           % set box property to off and remove background color
        b = axes('Position',get(a,'Position'),'box','on','xtick',[],'ytick',[],'linewidth',4);   % create new, empty axes with box but without ticks
        axes(a)          % set original axes as active
        linkaxes([a b])  % link axes in case of zooming
    %  lblf2={'Watch Off';'Idle';'Active';'Walk'; 'Run'};
    %  set(h25w,'YTick',.5:.87:8.5,'YTickLabel',lblf2,'FontSize',18)
        xlabel('Days','FontWeight','b','FontSize',32)
        xlim([.5,2*tpmx+.5])
        savefig(strcat(outpp,stdy,'-',sb1(1:3),'-wallact.fig'))
        img = getframe(gcf);
        imwrite(img.cdata, strcat(outpp,stdy,'-',sb1(1:3),'-wallact.png'));
        display('Walk-Run Actigraphy All Saved with Sleep.');
    end



    %% Sleep Medicine 
    indfd1=inds_qc;
    indfdv2=reshape(indfd1,1,1440*length(indfd1(1,:)));
    indbv2=[indfdv2(6*60+1:end) zeros(1,6*60)];
    indb_sl=reshape(indbv2,1440,length(indfd1(1,:)));
    indb_slm=[indb_sl(:,2:end) zeros(1440,1)];
    indb_qcd=[indb_sl;indb_slm];
    ff101=figure(101);
    set(gcf,'position',get(0,'screensize')-[0,0,0,0])
    set(gcf,'color','white')
    colormap(gca,clrs)
    hhind=imagesc(transpose(indb_qcd));
    axi = ancestor(hhind, 'axes');
    xrule = axi.XAxis;   yrule = axi.YAxis;
    epc_lbl3={'12AM', ' 6AM', '12PM', ' 6PM','12AM', ' 6AM', '12PM', ' 6PM','12AM'};
    set(gca,'XTick',(0.5:6*60:48*60+0.5),'XTickLabel',epc_lbl3(1:1:end),'TickDir','out', 'Linewidth',4,'FontName','Arial','FontWeight','b','FontSize',32,'Xgrid','off')         
    set(gca,'YTick',[1 25.5:25:ldy+.5],'YTickLabel',{'1','25','50','75','100','125','150','175','200','225','250'},'YTickLabelRotation',0,'FontSize',32)
    %set(gca,'XTick',[1 2:2:ldy],'XTickLabel',{'C','1','3','5','7','9','11','13','15','17','19','21','23','25','27','29'},'XTickLabelRotation',0,'FontSize',32)
    a = gca;                                % get handle to current axes
    set(a,'box','off','color','none')           % set box property to off and remove background color
    b = axes('Position',get(a,'Position'),'box','on','xtick',[],'ytick',[],'linewidth',4);   % create new, empty axes with box but without ticks
    axes(a)          % set original axes as active
    linkaxes([a b])  % link axes in case of zooming
    ylabel('Days','FontWeight','b','FontSize',32)
    ylim([.5,tpa+.5])
    savefig(strcat(outpp,stdy,'-',sb1(1:3),'-sleepbqcd.fig'))
    img = getframe(gcf);
    imwrite(img.cdata, strcat(outpp,stdy,'-',sb1(1:3),'-sleepbqcd.png'));
    display('QCD Sleep Sleep-format Saved.');
  
    ff110=figure(110);
    set(gcf,'position',get(0,'screensize')-[0,0,0,0])
    set(gcf,'color','white')
    clrs=[1 1 1; 0 0 1];
    colormap(gca,clrs)
    hhind=imagesc(flip(inds_ntqc,1));
    axi = ancestor(hhind, 'axes');
    xrule = axi.XAxis;   yrule = axi.YAxis;
    epc_lbl2={' 6PM',' 3PM', '12PM', ' 9AM',' 6AM',' 3AM','12AM',' 9PM',' 6PM'};
    set(gca,'YTick',(0.5:3*60:24*60+0.5),'YTickLabel',epc_lbl2(1:1:end),'TickDir','out', 'Linewidth',4,'FontName','Arial','FontWeight','b','FontSize',28,'Ygrid','off')           
  %  set(gca,'XTick',[1 25.5:25:ldy+.5],'XTickLabel',{'1','25','50','75','100','125','150','175','200','225','250'},'XTickLabelRotation',0,'FontSize',32)
  %      set(gca,'XTick',[1 50.5:50:ldy+.5],'XTickLabel',{'1','50','100','150','200','250','300','350','400','450','500','550'},'XTickLabelRotation',0,'FontSize',32)

    %set(gca,'XTick',[1 5.5:5:ldy+.5],'XTickLabel',{'1','5','10','15','20','25','30','35','40','45','50','55','60','65','70'},'XTickLabelRotation',0,'FontSize',28)

    %set(gca,'XTick',[1 2:2:ldy],'XTickLabel',{'C','1','3','5','7','9','11','13','15','17','19','21','23','25','27','29'},'XTickLabelRotation',0,'FontSize',32)
    a = gca;                                % get handle to current axes
    set(a,'box','off','color','none')           % set box property to off and remove background color
    b = axes('Position',get(a,'Position'),'box','on','xtick',[],'ytick',[],'linewidth',4);   % create new, empty axes with box but without ticks
    axes(a)          % set original axes as active
    linkaxes([a b])  % link axes in case of zooming
    xlabel('Days','FontWeight','b','FontSize',32)
    xlim([.5,tpa+.5])
    savefig(strcat(outpp,stdy,'-',sb1(1:3),'-sleepntqcd.fig'))
    img = getframe(gcf);
    imwrite(img.cdata, strcat(outpp,stdy,'-',sb1(1:3),'-sleepntqcd.png'));
    display('Corected Sleep Data Saved.');

    ff12=figure(12);
    set(gcf,'position',get(0,'screensize')-[0,0,0,0])
    set(gcf,'color','white')
    clrs=[1 1 1; 0 0 1];
    colormap(gca,clrs)
    hhind=imagesc(flip(inds_psg,1));
    axi = ancestor(hhind, 'axes');
    xrule = axi.XAxis;   yrule = axi.YAxis;
    epc_lbl2={' 6PM',' 3PM', '12PM', ' 9AM',' 6AM',' 3AM','12AM',' 9PM',' 6PM'};
    set(gca,'YTick',(0.5:3*60:24*60+0.5),'YTickLabel',epc_lbl2(1:1:end),'TickDir','out', 'Linewidth',4,'FontName','Arial','FontWeight','b','FontSize',28,'Ygrid','off')           
%  set(gca,'XTick',[1 25.5:25:ldy+.5],'XTickLabel',{'1','25','50','75','100','125','150','175','200','225','250'},'XTickLabelRotation',0,'FontSize',32)
%      set(gca,'XTick',[1 25.5:25:ldy+.5],'XTickLabel',{'1','25','50','75','100','125','150','175','200','225','250'},'XTickLabelRotation',0,'FontSize',32)

    %set(gca,'XTick',[1 5.5:5:ldy+.5],'XTickLabel',{'1','5','10','15','20','25','30','35','40','45','50','55','60','65','70'},'XTickLabelRotation',0,'FontSize',28)

    set(gca,'XTick',[1 2:2:ldy],'XTickLabel',{'C','1','3','5','7','9','11','13','15','17','19','21','23','25','27','29'},'XTickLabelRotation',0,'FontSize',32)
    a = gca;                                % get handle to current axes
    set(a,'box','off','color','none')           % set box property to off and remove background color
    b = axes('Position',get(a,'Position'),'box','on','xtick',[],'ytick',[],'linewidth',4);   % create new, empty axes with box but without ticks
    axes(a)          % set original axes as active
    linkaxes([a b])  % link axes in case of zooming
    xlabel('Nights','FontWeight','b','FontSize',32)
    xlim([.5,tpa+.5])
    savefig(strcat(outpp,stdy,'-',sb1(1:3),'-sleeppsg.fig'))
    img = getframe(gcf);
    imwrite(img.cdata, strcat(outpp,stdy,'-',sb1(1:3),'-sleeppsg.png'));
    display('QCd Sleep Data Saved.');

    ff13=figure(13);
    set(gcf,'position',get(0,'screensize')-[0,0,0,0])
    set(gcf,'color','white')
    clrs=[1 1 1; 0 0 1;1 0 0];
    colormap(gca,clrs)
    hhind=imagesc(flip(inds_psgqc,1));
    axi = ancestor(hhind, 'axes');
    xrule = axi.XAxis;   yrule = axi.YAxis;
    epc_lbl2={' 6PM',' 3PM', '12PM', ' 9AM',' 6AM',' 3AM','12AM',' 9PM',' 6PM'};
    set(gca,'YTick',(0.5:3*60:24*60+0.5),'YTickLabel',epc_lbl2(1:1:end),'TickDir','out', 'Linewidth',4,'FontName','Arial','FontWeight','b','FontSize',28,'Ygrid','off')           
%  set(gca,'XTick',[1 25.5:25:ldy+.5],'XTickLabel',{'1','25','50','75','100','125','150','175','200','225','250'},'XTickLabelRotation',0,'FontSize',32)
%      set(gca,'XTick',[1 25.5:25:ldy+.5],'XTickLabel',{'1','25','50','75','100','125','150','175','200','225','250'},'XTickLabelRotation',0,'FontSize',32)

    %set(gca,'XTick',[1 5.5:5:ldy+.5],'XTickLabel',{'1','5','10','15','20','25','30','35','40','45','50','55','60','65','70'},'XTickLabelRotation',0,'FontSize',28)

    set(gca,'XTick',[10 40:20:20*ldy],'XTickLabel',{'C','1','2','3','4','5','6','7','8','9','10','11','12','13','14','15','16','17','18','19','20','21','22','23','24','25','26','27','28','29'},'XTickLabelRotation',0,'FontSize',32)
    a = gca;                                % get handle to current axes
    set(a,'box','off','color','none')           % set box property to off and remove background color
    b = axes('Position',get(a,'Position'),'box','on','xtick',[],'ytick',[],'linewidth',4);   % create new, empty axes with box but without ticks
    axes(a)          % set original axes as active
    linkaxes([a b])  % link axes in case of zooming
    xlabel('Nights','FontWeight','b','FontSize',32)
    xlim([.5,20*tpa+1])
    savefig(strcat(outpp,stdy,'-',sb1(1:3),'-sleeppsgqc.fig'))
    img = getframe(gcf);
    imwrite(img.cdata, strcat(outpp,stdy,'-',sb1(1:3),'-sleeppsgqc.png'));
    display('PSG Sleep Data Saved.');
end


save(strcat(outpp,stdy,'-',sb1(1:3),'-all2.mat'),'indf_phone1','indf_phone2','indf_gaz','indf_light','indf_active','indf_score','indf_sleep','indf_btp','ltkc','lnkc','inds_nqc','inds_qc','indf_activer','indf_activest','inds_psg','inds_psgqc','indf_walk','indf_wall','indf_wslp','indf_pfreq')
clearvars -except s

display('COMPLETE');
exit(0);
