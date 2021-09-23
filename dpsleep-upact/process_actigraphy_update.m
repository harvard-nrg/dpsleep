function updm=process_actigraphy_update(tst1,tst2,bst1,bst2,nst1,nsp1,nst2,nsp2,indf_out,indf_prc,indf_light,indf_phone,indf_wlk)
indf=indf_out;
indr=indf_prc;
indg=indf_light;
indp=indf_phone;
indw=indf_wlk;
%% Goto sleep epoch
s1=datenum(tst1,'HH:MM');
s2=datenum(tst2,'HH:MM');
b1=datenum(bst1,'HH:MM');
b2=datenum(bst2,'HH:MM');
s11=s1;
s22=s2;
sr=datenum('18:00','HH:MM');
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
slpt=id1/60;
wkt=id2/60;
inds=indf(id1:id2);
indsr=indr(id1:id2);
indsg=indg(id1:id2);
indsp=indp(id1:id2);
%% Activities: indbw indaw indbr indar indbm indam indbmp indamp
indwkb=indw(1:id1);     indwka=indw(id2:1440);
indrb=indr(1:id1);       indra=indr(id2:1440);              % activity levels before and after
indbw=length(indwkb(indwkb==3));   indaw=length(indwka(indwka==3));      % Minutes of walking
indbr=length(indwkb(indwkb==2 | indwkb==4));   indar=length(indwka(indwka==2 | indwka==4));  % Minutes of running or vigorous activity
indbm=length(indrb(indrb>=15));   indam=length(indra(indra>15));      % Number of minutes with higher than 75 percentile activity
indbsm=5*nansum(indrb(indrb>0));   indasm=5*nansum(indra(indra>0));  % Sum of activity levels before and after sleep (not averaged)
durbf=length(indrb);      duraf=length(indra);     % Active duration before and after sleep (minutes)

%% Off-wrist minutes 6pm-6pm
ind6=indf;
indoff=length(ind6(ind6==0));
%% Inside Sleep Epoch
if ((id1==id2) || isempty(b1) || isempty(b2) || isempty(s1) || isempty(s2))    
    updm=[indoff,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,indbw,indaw,indbr,indar,indbm,indam,indbsm,indasm,durbf,duraf,0];
else    
    %% Bout detection
    indbt1=zeros(size(inds));
    indbt=zeros(size(inds));
    indbt1(indsr>8)=1;
    nmob=length(indbt1(indbt1==1));    % # of mobile minutes 
    nimob=length(indbt1(indbt1==0));   % # of immobile minutes 
    pmob=100*nmob/length(indbt1);      % % of mobile minutes
    pimob=100*nimob/length(indbt1);    % % of immobile minutes
    indbt=indbt1;
    dndbt=diff([0;indbt;0]);
    ibt1=find(dndbt==1);    % jumps to active
    ibt2=find(dndbt==-1);   % jumps to immobile

    %% Phase detection (Detailed_new)
    indpht2=zeros(size(inds));
    indpht=zeros(size(inds));
    indpht2(indsr>8)=1;
    indphmv=movmean(indpht2,[4 5]);
    indpht(indphmv>.88)=1;
    dndphta=diff([0;indpht;0]);  % The first detected change is active and the last one is sleep
    iphta1=find(dndphta==1);      % jumps to active
    iphta2=find(dndphta==-1);      % jumps to sleep
    dndphts=diff([1;indpht;1]);    % The first detected change is sleep and the last one is active
    iphts1=find(dndphts==1);      % jumps to active
    iphts2=find(dndphts==-1);      % jumps to sleep
    

    %% Phase detection (Coarse_old)
    indph1=zeros(size(inds));
    indph=zeros(size(inds));
    indph1(inds==4)=1;
    indphmv=movmean(indph1,[4 5]);
    indph(indphmv>.88)=1;
    dndph=diff([0;indph;0]);
    iph1=find(dndph==1);
    iph2=find(dndph==-1);

    %% Light Detection
    indgt1=zeros(size(indsg));
    indgt=zeros(size(indsg));
    indgt1(indsg>1)=1;
    mgt=length(indgt1(indgt1==1));
    indgtf=movmean(indgt1,[0 2]);
    indgtb=movmean(indgt1,[2 0]);
    indgt(indgtf>.4 | indgtb>.4)=1;
    dndgt=diff([0;indgt;0]);
    igt1=find(dndgt==1);
    igt2=find(dndgt==-1);

    %% Phone Detection
    indpt1=zeros(size(indsp));
    indpt=zeros(size(indsp));
    indpt1(indsp==-1 | indsp==1 | indsp==2)=1;
    mpt=length(indpt1(indpt1==1));
    indptf=movmean(indpt1,[0 2]);
    indptb=movmean(indpt1,[2 0]);
    indpt(indptf>.4 | indptb>.4)=1;
    dndpt=diff([0;indpt;0]);
    ipt1=find(dndpt==1);
    ipt2=find(dndpt==-1);

    %% Sleep Latency:  slat
    if b1>s11
        slat=round(24*60*(s11+1-b1));
    else
        slat=round(24*60*(s11-b1));
    end

    %% Get up Latency: glat
    if b2<s22
        glat=round(24*60*(b2+1-s22));
    else
        glat=round(24*60*(b2-s22));
    end

    %% Sleep Duration: durs
    slp1=s11;
    slp2=s22;
    if slp1>slp2
        durs=round((slp2+1-slp1)*60*24);
    else
        durs=round((slp2-slp1)*60*24);
    end

    %% Bed Duration: durb
    bd1=b1;
    bd2=b2;
    if bd1>bd2
        durb=round((bd2+1-bd1)*60*24);
    else
        durb=round((bd2-bd1)*60*24);
    end

    %% Activity Level Average during sleep
    indsrm=5*nansum(indsr(indsr>0))/durs;
    
    %% Immobile minutes: indim
    indim=length(inds(inds==4));
    %indim1=length(inds(inds==3 | inds==4));
    %% Moving minutes (sleepless): indmv
    indmov=length(inds(inds>=5 & inds<10));
    %% Bad sleep minutes: indmv2
    indbad=length(inds((inds>=5 & inds<10) | inds==1));

    %% Sleep Efficiency: slef
    slef_old=100*(durs-indbad)/durb;
    
    %% Phases: nph_old mph_old
    if ~isempty(indph)
        phdur=[];
        if (length(iph1)<1 || length(iph2)<1)
            if mean(indph)>1
                nph_old=1;
                mph_old=durs;
            else
                nph_old=0;
                mph_old=0;
            end
        else
            phdur=iph2-iph1+10;        
            nph_old=length(phdur);
            mph_old=median(phdur);
        end
    end    

    %% Immobile Phases: nph n1mph pph
    btdur=[];
    nph=0;  sfi_evnt=0;
    if ~isempty(indbt)
        btdur=[];
        if (length(ibt1)<1 || length(ibt2)<1)
            nph=0;
            n1mph=0;
            pph=0;
            sfi_evnt=0;
        else
            btdur=ibt1-ibt2;       %ibt1= jump to active, ibt2=jump to sleep => duration of sleep phases
            nph=length(btdur);
            n1mph=length(find(btdur==1));
            pph=100*n1mph/nph;
            sfi_evnt=60*nph/length(indbt1);
        end
    end
    

    
    %% Wake/Sleep Bouts: nsbt nwbt msbt mwbt
    if ~isempty(indpht)
        phdurw=[];  phdurs=[];
        if (length(iphta1)<1 || length(iphts1)<1)
%            if mean(indpht)>=0
                nsbt=1;
                msbt=durs;
                nwbt=0;
                mwbt=0;
                acst=durs;
                acwt=0;
%            else
%                nsbt=0;
%                msbt=0;
%                nwbt=0;
%                mwbt=0;
%                acst=0;
%                acwt=0;
%            end
        else
            phdurw=iphta2-iphta1+10;     % Wake 
            phdurs=iphts1-iphts2-10;     % Sleep      
            nsbt=length(phdurw);   % # of sleep bouts
            nwbt=length(phdurs);   % # of wake bouts
            mwbt=mean(phdurw);      % mean length of wake bouts
            msbt=mean(phdurs);      % mean length of sleep bouts
            acst=sum(phdurs);       % Actual sleep time
            acwt=sum(phdurw);       % Actual wake time
        end
    end

    %% New Sleep Efficiency
    slef_new=100*acst/durb;

    %% Sleep Fragmentation Index
    sfi=pmob+pph;

    %% Light Bouts: ngt
    gtdur=[];
    ngt=0;
    if ~isempty(indgt)
        gtdur=[];
        if (length(igt1)<1 || length(igt2)<1)
            ngt=0;
        else
            gtdur=igt2-igt1;        
            ngt=length(gtdur);
        end
    end
    
    %% Phone Bouts: npt
    ptdur=[];
    npt=0;
    if ~isempty(indpt)
        ptdur=[];
        if (length(ipt1)<1 || length(ipt2)<1)
            npt=0;
        else
            ptdur=ipt2-ipt1;        
            npt=length(ptdur);
        end
    end
    
    %% Naps: durn1 durn2
    sn1=datenum(nst1,'HH:MM');
    sn2=datenum(nsp1,'HH:MM');
    if sn1>sn2
        durn1=round((sn2+1-sn1)*60*24);
    else
        durn1=round((sn2-sn1)*60*24);
    end

    sq1=datenum(nst2,'HH:MM');
    sq2=datenum(nsp2,'HH:MM');
    if sq1>sq2
        durn2=round((sq2+1-sq1)*60*24);
    else
        durn2=round((sq2-sq1)*60*24);
    end
    %%
    indok=1;
    
    %% Build output matrix
    updm=[indoff,slpt,wkt,durb/60,durs/60,slat,ngt,mgt,npt,mpt,glat,indim,nph_old,mph_old,acst,acwt,nsbt,nwbt,msbt,mwbt,slef_new,nimob,nmob,pimob,pmob,nph,n1mph,pph,sfi,sfi_evnt,durn1,durn2,indsrm,indbw,indaw,indbr,indar,indbm,indam,indbsm,indasm,durbf,duraf,indok];
end