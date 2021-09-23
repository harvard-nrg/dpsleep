function [tst1,tst2,bst1,bst2,nst1,nsp1,nst2,nsp2,comnt,indf_out,indf_prc,indf_all,indf_light1, indf_phone,indoff,ff1]=process_actigraphy_qcplots(subject,day,study,adr)
%%
tst=18; tsp=18;
sb1=subject;
stdy=study;

%%
outp=strcat('/ncf/cnl03/PHOENIX/GENERAL/',stdy,'/',sb1,'/actigraphy/processed/mtl5');
outm=strcat('/ncf/cnl03/PHOENIX/GENERAL/',stdy,'/',sb1,'/actigraphy/processed/mtl6');

%%
d3=dir(strcat(adr,'*.mat'));
files_len = length(d3);
% Exit if there are no files to read
if files_len == 0
    display('Files do not exist under this directory.');
    exit(1);
end
load(strcat(adr,'/',d3.name))

%% Plot All
ff1=figure(1);
set(gcf,'position',get(0,'screensize')-[0,0,200,0])
set(gcf,'color','white')

%% GPS
subplot(7,1,7)
indfd1=indf_gaz(:,day);
%% Time Zone
tdl=timezone(lnkc,'degree')-timezone(lnkc(1),'degree');
ddfk=deg2km(distance(ltkc,lnkc,ltkc(1),lnkc(1)));
hp2=length(ddfk);
if hp2==1
   lblf2=' ';
   indfd=indfd1;

    clrs=[1 1 1]; %#ok<*AGROW>

    lblfx=lblf2;

    colormap(gca,clrs)
    indfs=indfd;
    hhind=imagesc(indfs');
    axi = ancestor(hhind, 'axes');
    xrule = axi.XAxis;  yrule = axi.YAxis;
    h25fpp=colorbar;
    set(gca, 'FontWeight','b')
    datefmt = 'HH:MM';  %adjust as appropriate
    xlabels = cellstr( datestr( tst/24:1.5/6/24:(1+tsp/24), datefmt ) );  %time labels
    slabs = cellstr( datestr( tst/24+1/60/24:1/60/24:(1+tsp/24), datefmt ) );  %time labels
    %xlabs={'6PM','' ,'' ,'' ,'' ,'' ,'' ,'' ,'' ,'' ,'' ,'' ,'9PM','' ,'' ,'' ,'' ,'' ,'' ,'' ,'' ,'' ,'' ,'' ,'12AM','' ,'' ,'' ,'' ,'' ,'' ,'' ,'' ,'' ,'' ,'' ,'3AM','' ,'' ,'' ,'' ,'' ,'' ,'' ,'' ,'' ,'' ,'' ,'6AM','' ,'' ,'' ,%'' ,'' ,'' ,'' ,'' ,'' ,'' ,'' ,'9AM','' ,'' ,'' ,'' ,'' ,'' ,'' ,'' ,'' ,'' ,'' ,'12PM','' ,'' ,'' ,'' ,'' ,'' ,'' ,'' ,'' ,'' ,'' ,'3PM','' ,'' ,'' ,'' ,'' ,'' ,'' ,'' ,'' ,'' ,'' ,'6PM'};
    set(gca,'XTick',0.5:15:((24+tsp-tst)*60+0.5),'XTickLabel',xlabels,'XTickLabelRotation',90)  
    set(gca,'YTickLabel',' ') 
    xrule.FontSize = 8;
    ylabel('GPS','FontWeight','b','FontSize',14)
    grid on
    grid minor
    set(h25fpp,'YTick',1,'YTickLabel',lblf2,'FontSize',10)
else
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
        lblf2{fh+1,1}=strcat('-',sprintf(fmt2,ddfk(fh)));
    end
    lblf2{hp2+1,1}=' '; lblf2{hp2+2,1}=' '; %#ok<*SAGROW>
    indfd=indfd1;
    %% Colors
    clpg=unique(indfd);
    clp1=unique(indf_gaz);
    wnt=winter(30);
    spr=spring(30);
    sumr=summer(30);
    autm=autumn(20);
    copr=copper(17);
    colll=[autm(1:12,:);wnt(1:15,:);sumr(1:12,:);spr(1:10,:);copr;sumr(15:26,:);spr(18:25,:);wnt(21:30,:);autm(16:20,:)];
    colr=[colll;colll;colll];
    clrr3=colr(1:(length(clp1)-3),:);
    clrs=[[.75 .75 .75];clrr3; [.9 .9 .9];[1 1 1]]; %#ok<*AGROW>
    exl=clpg;
    tdls=num2str(tdl);
    if length(tdls(1,:))==1
        tdls=[tdls;' ';' '];
    elseif length(tdls(1,:))==3
        tdls=[tdls;'   ';'   '];
    else
        tdls=[tdls;'  ';'  '];
    end
    tdlx=tdls(exl,:);
    lblfx=lblf2(exl,:);
    clrex=clrs(exl,:);
    colormap(gca,clrex)
    indfs=zeros(size(indfd));
    for k=1:length(clpg)
        indfs(indfd==clpg(k))=k;
    end
    hhind=imagesc(indfs');
    axi = ancestor(hhind, 'axes');
    xrule = axi.XAxis;  yrule = axi.YAxis;
    h25fpp=colorbar;
    set(gca, 'FontWeight','b')
    datefmt = 'HH:MM';  %adjust as appropriate
    xlabels = cellstr( datestr( tst/24:1.5/6/24:(1+tsp/24), datefmt ) );  %time labels
    slabs = cellstr( datestr( tst/24+1/60/24:1/60/24:(1+tsp/24), datefmt ) );  %time labels
    %xlabs={'6PM','' ,'' ,'' ,'' ,'' ,'' ,'' ,'' ,'' ,'' ,'' ,'9PM','' ,'' ,'' ,'' ,'' ,'' ,'' ,'' ,'' ,'' ,'' ,'12AM','' ,'' ,'' ,'' ,'' ,'' ,'' ,'' ,'' ,'' ,'' ,'3AM','' ,'' ,'' ,'' ,'' ,'' ,'' ,'' ,'' ,'' ,'' ,'6AM','' ,'' ,'' ,%'' ,'' ,'' ,'' ,'' ,'' ,'' ,'' ,'9AM','' ,'' ,'' ,'' ,'' ,'' ,'' ,'' ,'' ,'' ,'' ,'12PM','' ,'' ,'' ,'' ,'' ,'' ,'' ,'' ,'' ,'' ,'' ,'3PM','' ,'' ,'' ,'' ,'' ,'' ,'' ,'' ,'' ,'' ,'' ,'6PM'};
    set(gca,'XTick',0.5:15:((24+tsp-tst)*60+0.5),'XTickLabel',xlabels,'XTickLabelRotation',90)  
    set(gca,'YTickLabel',' ') 
    xrule.FontSize = 8;
    ylabel('GPS','FontWeight','b','FontSize',14)
    grid on
    grid minor
    set(h25fpp,'YTick',1:.99:length(clpg),'YTickLabel',strcat(tdlx,lblfx),'FontSize',10)
end
%% activity 
subplot(7,1,1)
indfd=indf_active(:,day);
indf_prc=indfd;
hhind=bar(.5:1:24*60-.5,indf_prc,1,'FaceColor','k','EdgeColor','k');
axi = ancestor(hhind, 'axes');
xrule = axi.XAxis;  yrule = axi.YAxis;
set(gca, 'FontWeight','b')
%set(gca,'XAxisLocation','top')
%set(gca,'XTick',0.5:15:((24+tsp-tst)*60+0.5),'XTickLabel',xlabels,'XTickLabelRotation',90)  
set(gca,'XTick',0.5:15:((24+tsp-tst)*60+0.5),'XTickLabel',' ','XTickLabelRotation',90)
xrule.FontSize = 8;        
ylabel('Activity','FontWeight','b','FontSize',14)
title(num2str(day),'FontWeight','b','FontSize',14)
set(gca,'YTickLabel',' ')
ylim([8 22])
xlim([0 24*60+.5]);
grid on
grid minor
colormap(gca,[1 1 1])
h25fpp=colorbar;
set(h25fpp,'YTick',1,'YTickLabel','     ','FontSize',10)

%% Actigraphy
subplot(7,1,2)
indfd=indf_score(:,day);
indf_out=indfd;
indf_but=zeros(size(indf_out));
indf_but(indf_out==6)=1;
%% Off-wrist minutes 6pm-6pm
ind6=indf_out(1:end-240);
indoff=length(ind6(ind6==0));
%%
indf_low=zeros(size(indf_out));
indf_low(indf_out==1 | indf_out==2)=1;
indf_vlw=zeros(size(indf_out));
indf_vlw(indf_out==1)=1;
indf_lwf=movmean(indf_low,[0 2]);
indf_lwb=movmean(indf_low,[2 0]);
indf_lwm=zeros(size(indf_out));
indf_lwm(indf_lwf>0 & indf_lwb>0 )=1;
%%
indf_hg=zeros(size(indf_out));
indf_hg(indf_out==3 | indf_out==4 |indf_out==5 )=1;
indf_hgf=movmean(indf_hg,[0 2]);
indf_hgb=movmean(indf_hg,[2 0]);
indf_hgm=zeros(size(indf_out));
indf_hgm(indf_hgf>0 & indf_hgb>0 )=1;
ibt=find(indf_but==1);
if ~isempty(ibt)
dibt=[0;diff(ibt)];
ibtfi=ibt(dibt~=1);
else
 ibtfi=[];
end
indfm=indfd;
indfmm=zeros(size(indfm));
clps=unique(indfm);
for k=1:length(clps)
    indfmm(indfm==clps(k))=k;
end
if ismember(0,clps)
    clrs=[1 1 1; 0 0 1;0 1 1; 0 1 0; 1 0.65 0;1 0 0; 0 0 0];
    lblf2={'Off'; '<10%';'<25%';'<50%';'>50%'; '>75%';'Bton'};
    excl=[clps+1];
    clrex=clrs(excl,:);
    lblf3=lblf2(excl);
else
    clrs=[0 0 1;0 1 1; 0 1 0; 1 0.65 0;1 0 0; 0 0 0];
    lblf2={'<10%';'<25%';'<50%';'>50%'; '>75%';'Bton'};
    excl=clps;
    clrex=clrs(excl,:);
    lblf3=lblf2(excl);
end
colormap(gca,clrex)
hhind=imagesc(indfmm');
axi = ancestor(hhind, 'axes');
xrule = axi.XAxis;  yrule = axi.YAxis;
h25fpp=colorbar;
set(gca, 'FontWeight','b')
set(gca,'XTick',0.5:15:((24+tsp-tst)*60+0.5),'XTickLabel',' ','XTickLabelRotation',90)            

set(gca,'YTickLabel',' ')
ylabel('Score','FontWeight','b','FontSize',14)
grid on
grid minor
set(h25fpp,'YTick',min(excl)+.5:.85:length(excl)+.5,'YTickLabel',lblf3,'FontSize',10)

%% Sleep
subplot(7,1,3)
indfd=indf_sleep(:,day);
indfss=4*ones(size(indfd));
indfss(indfd==0)=0;
indfsb=4*ones(size(indfd));
indfsb(indfd==0)=0;
indfds=indfd;
indfds(indfds==0)=0;
indfds(indfds==2)=0;

indif=diff(indfds);
its1=find(indif==1);
its2=find(indif==-1);
indf_lw2=zeros(size(indf_out));
tst1='0:0';
tst2='0:0';
bst1='0:0';
bst2='0:0';
nst1='0:0';
nsp1='0:0';
nst2='0:0';
nsp2='0:0';
comnt=' ';
if (~isempty(its1) && ~isempty(its2))
    %% Algorithm results
    it1=1;   it2=1;
    if (length(its1)==1 && length(its2)==1)  %% one sleep onset %% one wake
        if its2>its1
            tst1=slabs(its1);
            tst2=slabs(its2);
            it1=its1; it2=its2;
        end
    end
    if (length(its1)==1 && length(its2)==2)  %% one sleep onset %% two wake
        if its2(1)>its1
            tst1=slabs(its1);
            tst2=slabs(its2(1));
            it1=its1; it2=its2(1);
        elseif its2(2)>its1
            tst1=slabs(its1);
            tst2=slabs(its2(2));
            it1=its1; it2=its2(2);
        end
    end
    if (length(its1)==2 && length(its2)==1)  %% two sleep onset %% one wake
        if its2>its1(1)
            tst1=slabs(its1(1));
            tst2=slabs(its2);
            it1=its1(1); it2=its2;
        elseif its2>its1(2)
            tst1=slabs(its1(2));
            tst2=slabs(its2);
            it1=its1(2); it2=its2;
        end
    end
    if (length(its1)>=2 && length(its2)>=2)
        if its1(1)>=its2(1)
            its2=its2(2:end);
        end
        if its1(end)>=its2(end)
            its1=its1(1:end-1);
        end
        if (length(its1)==1 && length(its2)==1) 
            if its2>its1
                tst1=slabs(its1);
                tst2=slabs(its2);
                it1=its1; it2=its2;
            end
        else
            itd=its1(2:end)-its2(1:end-1);
            ii=find(itd<120);
            its2(ii)=[];
            its1(ii+1)=[];
            its=its2-its1;
            [ma,im]=max(its);
            tst1=slabs(its1(im));
            tst2=slabs(its2(im));
            it1=its1(im); it2=its2(im);
            nits1=its1(~im);
            nits2=its2(~im);
        end
    end
    %% Find Parameters from algorithm
    iit1=it1; iit2=it2; iit3=it1; iit4=it2;
    % iit1=sleep start  % iit2=sleep end
    % iit3=bed start    % iit4=bed end
    ibtf1=ibtfi(ibtfi>it1-60 & ibtfi<it1+60);
    ibtf2=ibtfi(ibtfi>it2-60 & ibtfi<it2+60);
    %% Only one button press
    %if (it1>0 && it2>0) && ((length(ibtf)==1 ))
    if (it1>0 && it2>0)               
        if indf_lwm(it1)==1
            indf_lwm1=indf_lwm(1:it1);
            itw1=find(indf_lwm1==0,1,'last');
            ibtf11=ibtf1(ibtf1<itw1);
            ibtf12=ibtf1(ibtf1>itw1);
            if ~isempty(ibtf11) && ~isempty(ibtf12)
                tst1=slabs(ibtf12(1));
                bst1=slabs(ibtf11(end));
                iit1=ibtf12(1);    iit3=ibtf11(end);         
            elseif isempty(ibtf11) && ~isempty(ibtf12)
                tst1=slabs(ibtf12(1));
                bst1=slabs(itw1);
                iit1=ibtf12(1);    iit3=itw1;
            elseif ~isempty(ibtf11) && isempty(ibtf12)
                tst1=slabs(itw1);
                bst1=slabs(ibtf11(end));
                iit1=itw1;    iit3=ibtf11(end);
            else
                indf_hgm1=indf_hgm(1:itw1);
                itw3=find(indf_hgm1==1,1,'last');
                tst1=slabs(itw1);
                bst1=slabs(itw3);
                iit1=itw1;    iit3=itw3;
            end
        else
            indf_lwm1=indf_lwm(it1:end);
            itw1=find(indf_lwm1==1,1,'first');
            ttw1=it1:length(indf_lwm);
            iitw1=ttw1(itw1);
            indf_hgm1=indf_hgm(1:iitw1);
            iitw3=find(indf_hgm1==1,1,'last');
            ibtf11=ibtf1(ibtf1<iitw1);
            ibtf12=ibtf1(ibtf1>iitw1);
            if ~isempty(ibtf11) && ~isempty(ibtf12)
                tst1=slabs(ibtf12(1));
                bst1=slabs(ibtf11(end));
                iit1=ibtf12(1);    iit3=ibtf11(end);         
            elseif isempty(ibtf11) && ~isempty(ibtf12)
                tst1=slabs(iitw3);
                bst1=slabs(ibtf12(1));
                iit1=iitw3;    iit3=ibtf12(1);
            elseif ~isempty(ibtf11) && isempty(ibtf12)
                tst1=slabs(iitw1);
                bst1=slabs(ibtf11(end));
                iit1=iitw1;    iit3=ibtf11(end);
            else
                tst1=slabs(iitw1);
                bst1=slabs(iitw3);
                iit1=iitw1;    iit3=iitw3;
            end
        end

        if indf_lwm(it2)~=1
            indf_lwm1=indf_lwm(1:it2);
            itw2=find(indf_lwm1==1,1,'last');
            indf_hgm1=indf_hgm(itw2:end);
            itw4=find(indf_hgm1==1,1,'first');
            ttw2=itw2:length(indf_hgm);
            iitw4=ttw2(itw4);
            ibtf21=ibtf2(ibtf2<itw2);
            ibtf22=ibtf2(ibtf2>itw2);
            if ~isempty(ibtf21) && ~isempty(ibtf22)
                tst2=slabs(ibtf21(end));
                bst2=slabs(ibtf22(1));
                iit2=ibtf21(end);    iit4=ibtf22(1);         
            elseif isempty(ibtf21) && ~isempty(ibtf22)
                tst2=slabs(itw2);
                bst2=slabs(ibtf22(1));
                iit2=itw2;    iit4=ibtf22(1);
            elseif ~isempty(ibtf21) && isempty(ibtf22)
                tst2=slabs(ibtf21(end));
                bst2=slabs(iitw4);
                iit2=ibtf21(end);    iit4=iitw4;
            else
                tst2=slabs(itw2);
                bst2=slabs(iitw4);
                iit2=itw2;    iit4=iitw4;
            end
        else
            indf_lwm1=indf_lwm(it2:end);
            itw2=find(indf_lwm1==0,1,'first');
            ttw2=it2:length(indf_lwm);
            iitw2=ttw2(itw2);
            indf_hgm1=indf_hgm(iitw2:end);
            itw4=find(indf_hgm1==1,1,'first');
            ttw4=iitw2:length(indf_hgm);
            iitw4=ttw4(itw4);
            ibtf21=ibtf2(ibtf2<iitw2);
            ibtf22=ibtf2(ibtf2>iitw2);
            if ~isempty(ibtf21) && ~isempty(ibtf22)
                tst2=slabs(ibtf21(end));
                bst2=slabs(ibtf22(1));
                iit2=ibtf21(end);    iit4=ibtf22(1);         
            elseif isempty(ibtf21) && ~isempty(ibtf22)
                tst2=slabs(iitw2);
                bst2=slabs(ibtf22(1));
                iit2=iitw2;    iit4=ibtf22(1);
            elseif ~isempty(ibtf21) && isempty(ibtf22)
                tst2=slabs(ibtf21(end));
                bst2=slabs(iitw4);
                iit2=ibtf21(end);    iit4=iitw4;
            else
                tst2=slabs(iitw2);
                bst2=slabs(iitw4);
                iit2=iitw2;    iit4=iitw4;
            end
        end  
    end
    if isempty(tst1)
        if isempty(bst1)
            bst1='18:05';
            tst1='18:07';
        else
            tst1=bst1;
            iit1=iit3;
        end
    else
        if isempty(bst1)
            bst1=tst1;
            iit3=iit1;
        end
    end
    
    if isempty(tst2)
        if isempty(bst2)
            bst2='21:55';
            tst2='21:53';
        else
            tst2=bst2;
            iit2=iit4;
        end
    else
        if isempty(bst2)
            bst2=tst2;
            iit4=iit2;
        end
    end      
    %% Find Naps
    if ~isempty(indf_low(iit3:iit4))
        indf_low(iit3:iit4)=0;
        indf_lwff=movmean(indf_low,[0 15]);
        indf_lwbb=movmean(indf_low,[15 0]);
        indf_vlwff=movmean(indf_vlw,[0 5]);
        indf_vlwbb=movmean(indf_vlw,[5 0]);
        indf_lw1=zeros(size(indf_out));
        indf_lw1(indf_lwff>.9 | indf_lwbb>.9 )=1;
        indf_lw1f=movmean(indf_lw1,[0 25]);
        indf_lw1b=movmean(indf_lw1,[25 0]);
        indf_lw2=zeros(size(indf_out));
        indf_lw2(indf_lw1f>.50 & indf_lw1b>0 )=1;
        indf_lw2(indf_lw1f>.0 & indf_lw1b>.5 )=1;
        dlw=[0;diff(indf_lw2)];
        ilw1=find(dlw==1);
        ilw2=find(dlw==-1);
        if (length(ilw1)>=1 && length(ilw2)>=1)
            if ilw1(1)>ilw2(1)
                ilw2(1)=[];
            end
            if (length(ilw1)>=1 && length(ilw2)>=1)
                if ilw1(end)>ilw2(end)
                    ilw1(end)=[];
                end
                if (length(ilw1)>=1 && length(ilw2)>=1)
                    dlw1=ilw2-ilw1;
                    if length(ilw1)==1
                        if indf_vlwff(ilw1:ilw2)>=0
                            nst1=slabs(ilw1);
                            nsp1=slabs(ilw2);
                        end
                        if ilw1<iit1
                            comnt='Nap before sleep';
                        end
                    else    
                        dlw2=ilw1(2:end)-ilw2(1:end-1);
                        [dlw1s,iw1s]=sort(dlw1,'descend');
                        nst1=slabs(ilw1(iw1s(1)));
                        nsp1=slabs(ilw2(iw1s(1)));
                        nst2=slabs(ilw1(iw1s(2)));
                        nsp2=slabs(ilw2(iw1s(2)));
                        if ilw2(iw1s(1))<=iit2 || ilw2(iw1s(2))<=iit2
                            comnt='Nap before sleep';
                        end            
                    end
                end
            end
        end
    else
        indf_low(iit3:iit4)=0;
        indf_lwff=movmean(indf_low,[0 15]);
        indf_lwbb=movmean(indf_low,[15 0]);
        indf_vlwff=movmean(indf_vlw,[0 5]);
        indf_vlwbb=movmean(indf_vlw,[5 0]);
        indf_lw1=zeros(size(indf_out));
        indf_lw1(indf_lwff>.9 | indf_lwbb>.9 )=1;
        indf_lw1f=movmean(indf_lw1,[0 25]);
        indf_lw1b=movmean(indf_lw1,[25 0]);
        indf_lw2=zeros(size(indf_out));
        indf_lw2(indf_lw1f>.50 & indf_lw1b>0 )=1;
        indf_lw2(indf_lw1f>.0 & indf_lw1b>.5 )=1;
        dlw=[0;diff(indf_lw2)];
        ilw1=find(dlw==1);
        ilw2=find(dlw==-1);
        if (length(ilw1)>=1 && length(ilw2)>=1)
            if ilw1(1)>ilw2(1)
                ilw2(1)=[];
            end
            if (length(ilw1)>=1 && length(ilw2)>=1)
                if ilw1(end)>ilw2(end)
                    ilw1(end)=[];
                end
                if (length(ilw1)>=1 && length(ilw2)>=1)
                    dlw1=ilw2-ilw1;
                    if length(ilw1)==1
                        if indf_vlwff(ilw1:ilw2)>=0
                            tst1=slabs(ilw1);
                            tst2=slabs(ilw2);
                            bst1=tst1;
                            bst2=tst2;
                            iit1=ilw1; iit2=ilw2;
                            iit3=ilw1; iit4=ilw2;
                        end
                    elseif length(ilw1)==2    
                        dlw2=ilw1(2:end)-ilw2(1:end-1);
                        [dlw1s,iw1s]=sort(dlw1,'descend');
                        tst1=slabs(ilw1(iw1s(1)));
                        tst2=slabs(ilw2(iw1s(1)));
                        bst1=tst1;  bst2=tst2;
                        iit1=ilw1(iw1s(1)); iit2=ilw2(iw1s(1));
                        iit3=iit1; iit4=iit2;
                        nst1=slabs(ilw1(iw1s(2)));
                        nsp1=slabs(ilw2(iw1s(2)));
                        if ilw2(iw1s(2))<=iit2 
                            comnt='Nap before sleep';
                        end
                     elseif length(ilw1)>2    
                        dlw2=ilw1(2:end)-ilw2(1:end-1);
                        [dlw1s,iw1s]=sort(dlw1,'descend');
                        tst1=slabs(ilw1(iw1s(1)));
                        tst2=slabs(ilw2(iw1s(1)));
                        bst1=tst1;  bst2=tst2;
                        iit1=ilw1(iw1s(1)); iit2=ilw2(iw1s(1));
                        iit3=iit1; iit4=iit2;
                        nst1=slabs(ilw1(iw1s(2)));
                        nsp1=slabs(ilw2(iw1s(2)));
                        nst2=slabs(ilw1(iw1s(3)));
                        nsp2=slabs(ilw2(iw1s(3)));
                        if ilw2(iw1s(2))<=iit2 || ilw2(iw1s(3))<=iit2
                            comnt='Nap before sleep';
                        end            
                    end
                end
            end
        end
    end
else
    if indoff<120
        indf_lwff=movmean(indf_low,[0 15]);
        indf_lwbb=movmean(indf_low,[15 0]);
        indf_vlwff=movmean(indf_vlw,[0 5]);
        indf_vlwbb=movmean(indf_vlw,[5 0]);
        indf_lw1=zeros(size(indf_out));
        indf_lw1(indf_lwff>.9 | indf_lwbb>.9 )=1;
        indf_lw1f=movmean(indf_lw1,[0 25]);
        indf_lw1b=movmean(indf_lw1,[25 0]);
        indf_lw2=zeros(size(indf_out));
        indf_lw2(indf_lw1f>.50 & indf_lw1b>0 )=1;
        indf_lw2(indf_lw1f>.0 & indf_lw1b>.5 )=1;
        dlw=[0;diff(indf_lw2)];
        ilw1=find(dlw==1);
        ilw2=find(dlw==-1);
        if (length(ilw1)>=1 && length(ilw2)>=1)
            if ilw1(1)>ilw2(1)
                ilw2(1)=[];
            end
            if (length(ilw1)>=1 && length(ilw2)>=1)
                if ilw1(end)>ilw2(end)
                    ilw1(end)=[];
                end
                if (length(ilw1)>=1 && length(ilw2)>=1)
                    dlw1=ilw2-ilw1;
                    if length(ilw1)==1
                        if indf_vlwff(ilw1:ilw2)>=0
                            tst1=slabs(ilw1);
                            tst2=slabs(ilw2);
                            bst1=tst1;
                            bst2=tst2;
                            iit1=ilw1; iit2=ilw2;
                            iit3=ilw1; iit4=ilw2;
                        end
                    elseif length(ilw1)==2    
                        dlw2=ilw1(2:end)-ilw2(1:end-1);
                        [dlw1s,iw1s]=sort(dlw1,'descend');
                        tst1=slabs(ilw1(iw1s(1)));
                        tst2=slabs(ilw2(iw1s(1)));
                        bst1=tst1;  bst2=tst2;
                        iit1=ilw1(iw1s(1)); iit2=ilw2(iw1s(1));
                        iit3=iit1; iit4=iit2;
                        nst1=slabs(ilw1(iw1s(2)));
                        nsp1=slabs(ilw2(iw1s(2)));
                        if ilw2(iw1s(2))<=iit2 
                            comnt='Nap before sleep';
                        end
                     elseif length(ilw1)>2    
                        dlw2=ilw1(2:end)-ilw2(1:end-1);
                        [dlw1s,iw1s]=sort(dlw1,'descend');
                        tst1=slabs(ilw1(iw1s(1)));
                        tst2=slabs(ilw2(iw1s(1)));
                        bst1=tst1;  bst2=tst2;
                        iit1=ilw1(iw1s(1)); iit2=ilw2(iw1s(1));
                        iit3=iit1; iit4=iit2;
                        nst1=slabs(ilw1(iw1s(2)));
                        nsp1=slabs(ilw2(iw1s(2)));
                        nst2=slabs(ilw1(iw1s(3)));
                        nsp2=slabs(ilw2(iw1s(3)));
                        if ilw2(iw1s(2))<=iit2 || ilw2(iw1s(3))<=iit2
                            comnt='Nap before sleep';
                        end            
                    end
                end
            end
        end
    else
        comnt='Watch off';
        iit1=1; iit2=1; iit3=1; iit4=1;
    end
end
    
   
%% plot
% iit1=sleep start   % iit2=sleep end
% iit3=bed start     % iit4=bed end
% indfd(iit1)=3; indfd(iit2)=3; 
% indfd(iit3)=3; indfd(iit4)=3;
%assignin('base','indd',indfd)
indfss(indf_lw2==1)=5;
indfss(iit1:iit2)=2;
indfsb(iit3:iit4)=3;
indfd(indfd==2)=4;
indf_all=[indfsb indfss indfd];
indf_alm=indf_all;
clps=unique(indf_all);
for k=1:length(clps)
    indf_alm(indf_all==clps(k))=k;
end
clrs=[1 1 1;1 1 .75;0.4660 0.6740 0.1880;0.3010 0.7450 0.9330;.9 .9 .9;0.8660 0.6740 0.1880];
excl=clps+1;
clrex=clrs(excl,:);
colormap(gca,clrex)
hhind=imagesc(indf_alm');
axi = ancestor(hhind, 'axes');
xrule = axi.XAxis;  yrule = axi.YAxis;
h25fpp=colorbar;
set(gca, 'FontWeight','b')
set(gca,'XTick',0.5:15:((24+tsp-tst)*60+0.5),'XTickLabel',' ','XTickLabelRotation',90)           
ylabel('Sleep','FontWeight','b','FontSize',14)
set(gca,'YTickLabel',' ')
grid on
grid minor
lblf2={'Off'; 'Alg';'Slp';'Bed'; 'Oth';'Nap'};
lblf3=lblf2(excl);
set(h25fpp,'YTick',(excl-1),'YTickLabel',lblf3,'FontSize',10)

%% Light
subplot(7,1,4)
indfd=indf_light(:,day);
indf_light1=indfd;
indfd(indfd>100)=100;
colormap(gca,jet)
hhind=imagesc(indfd');
axi = ancestor(hhind, 'axes');
xrule = axi.XAxis;  yrule = axi.YAxis;
h25fpp=colorbar;
set(gca, 'FontWeight','b')
set(gca,'XTick',0.5:15:((24+tsp-tst)*60+0.5),'XTickLabel',' ','XTickLabelRotation',90)           
ylabel('Light','FontWeight','b','FontSize',14)
set(gca,'YTickLabel',' ')
grid on
grid minor

%% Phone Use
subplot(7,1,5)
indfd=indf_phone1(:,day);
indf_phone=indfd;
clps=unique(indfd);
clrs=[0 0 1;1 1 1;1 0 0;0 1 0];
excl=clps+2;
clrex=clrs(excl,:);
colormap(gca,clrex)
hhind=imagesc(indfd');
axi = ancestor(hhind, 'axes');
xrule = axi.XAxis;  yrule = axi.YAxis;
h25fpp=colorbar;
set(gca, 'FontWeight','b')
set(gca,'XTick',0.5:15:((24+tsp-tst)*60+0.5),'XTickLabel',' ','XTickLabelRotation',90)          
ylabel('Phone','FontWeight','b','FontSize',14)
set(gca,'YTickLabel',' ')
grid on
grid minor
lblf2={ 'Unlk'; 'NoEv';'Lock';'Used'};
lblf3=lblf2(excl);
set(h25fpp,'YTick',excl-2,'YTickLabel',lblf3,'FontSize',10)

%% Accelerometer
subplot(7,1,6)
indfd=indf_phone2(:,day);
indf_accel=indfd;
clps=unique(indfd);
clrs=[1 1 1; .9 .9 .9;1 1 0 ;1 0 0];
excl=clps+1;
clrex=clrs(excl,:);
colormap(gca,clrex)
hhind=imagesc(indfd');
axi = ancestor(hhind, 'axes');
xrule = axi.XAxis;  yrule = axi.YAxis;
h25fpp=colorbar;
set(gca, 'FontWeight','b')
set(gca,'XTick',0.5:15:((24+tsp-tst)*60+0.5),'XTickLabel',' ','XTickLabelRotation',90)            
xrule.FontSize = 8;
set(gca,'YTickLabel',' ')
ylabel('Accel','FontWeight','b','FontSize',14)
grid on
grid minor
lblf2={ 'NoDa';'Low '; '>75%';'>90%'};
lblf3=lblf2(excl);
set(h25fpp,'YTick',excl-1,'YTickLabel',lblf3,'FontSize',10)



disp(strcat('Day ',num2str(day), ' is done.'))