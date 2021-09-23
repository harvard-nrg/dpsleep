function qcact(read_dir, output_dir, study, subject, ref_date)

%% Study and subject 
stdy=study; 
sb1=subject; 
mn=datenum(ref_date);   % Choose 1st day as the actigraphy reference

%% Input and output directory
display('QC Pipeline.')
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
ndy=length(indf_score(1,:));

for dy1=1:ndy
    comnt=[];
   try        
        [sts1,sts2,bts1,bts2,nst1,nsp1,nst2,nsp2,comnt,indf_out,indf_prc,indf_all,indf_light,indf_phone,indf_wlk,indoff,ff1]=process_actigraphy_qcplots(sb1,dy1,stdy,adr);
        updm=process_actigraphy_update(sts1,sts2,bts1,bts2,nst1,nsp1,nst2,nsp2,indf_out,indf_prc,indf_light,indf_phone,indf_wlk);
   catch ME
        disp(sb1)
        dy1
       updm=[NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,0];
        comnt=[comnt '/ no data'];
    end            
    %%
    
    outp=adrq;
    if exist(strcat(outp,'/',sb1,'_tabl_foc.mat'), 'file') == 2
        load(strcat(outp,'/',sb1,'_tabl_foc.mat'))
    end
    %% Original
    bed_start{dy1,1}=bts1;
    bed_up{dy1,1}=bts2;
    sleep_start{dy1,1}=sts1;
    sleep_wake{dy1,1}=sts2;

    nap1_str{dy1,1}=nst1;    
    nap1_stp{dy1,1}=nsp1;
    nap2_str{dy1,1}=nst2;    
    nap2_stp{dy1,1}=nsp2;
    
    %  updm=[indoff,durb,durs,slat,ngt,mgt,npt,mpt,glat,indim,nph_old,mph_old,acst,acwt,nsbt,nwbt,msbt,mwbt,slef_new,nimob,nmob,pimob,pmob,nph,n1mph,pph,sfi,durn1,durn2,indbw,indaw,indbr,indar,indbm,indam,indbmp,indamp,indok];
    off_wrist{dy1,1}=num2str(updm(1));
    bed_dur{dy1,1}=num2str(updm(2));
    sleep_dur{dy1,1}=num2str(updm(3));
    sleep_lat{dy1,1}=num2str(updm(4));
   
    
    light_nbout{dy1,1}=num2str(updm(5));
    light_mins{dy1,1}=num2str(updm(6));
    phone_nbout{dy1,1}=num2str(updm(7));
    phone_mins{dy1,1}=num2str(updm(8));
    
    sleep_glat{dy1,1}=num2str(updm(9));
    sleep_imob_old{dy1,1}=num2str(updm(10));
    sleep_nphase_old{dy1,1}=num2str(updm(11));
    sleep_mphase_old{dy1,1}=num2str(updm(12));
    
    actual_sleep_time{dy1,1}=num2str(updm(13));
    actual_wake_time{dy1,1}=num2str(updm(14));
    sleep_bout_num{dy1,1}=num2str(updm(15));
    wake_bout_num{dy1,1}=num2str(updm(16));

    sleep_bout_mn{dy1,1}=num2str(updm(17));
    wake_bout_mn{dy1,1}=num2str(updm(18));
    sleep_eff{dy1,1}=num2str(updm(19));   
    
    sleep_imob_mins{dy1,1}=num2str(updm(20));
    sleep_move_mins{dy1,1}=num2str(updm(21));
    sleep_imob_per{dy1,1}=num2str(updm(22));
    sleep_move_per{dy1,1}=num2str(updm(23));

    sleep_phase_num{dy1,1}=num2str(updm(24));
    sleep_phase1_num{dy1,1}=num2str(updm(25));
    sleep_phase_per{dy1,1}=num2str(updm(26));
    sleep_frag_inx{dy1,1}=num2str(updm(27));

    
    nap1_durn{dy1,1}=num2str(updm(28));
    nap2_durn{dy1,1}=num2str(updm(29));
    
    
    walk_before_min{dy1,1}=num2str(updm(30));
    walk_after_min{dy1,1}=num2str(updm(31));
    run_before_min{dy1,1}=num2str(updm(32));
    run_after_min{dy1,1}=num2str(updm(33));
    active_before_min{dy1,1}=num2str(updm(34));
    active_after_min{dy1,1}=num2str(updm(35));
    active_before_per{dy1,1}=num2str(updm(36));
    active_after_per{dy1,1}=num2str(updm(37));

    data_accpt{dy1,1}=num2str(updm(38));
    cmnt{dy1,1}=comnt;

    %% qc
    bed_start_qc{dy1,1}=bts1;
    bed_up_qc{dy1,1}=bts2;
    sleep_start_qc{dy1,1}=sts1;
    sleep_wake_qc{dy1,1}=sts2;

    nap1_str_qc{dy1,1}=nst1;    
    nap1_stp_qc{dy1,1}=nsp1;
    nap2_str_qc{dy1,1}=nst2;    
    nap2_stp_qc{dy1,1}=nsp2;

    off_wrist_qc{dy1,1}=num2str(updm(1));
    bed_dur_qc{dy1,1}=num2str(updm(2));
    sleep_dur_qc{dy1,1}=num2str(updm(3));        
    sleep_lat_qc{dy1,1}=num2str(updm(4));
    
    light_nbout_qc{dy1,1}=num2str(updm(5));
    light_mins_qc{dy1,1}=num2str(updm(6));
    phone_nbout_qc{dy1,1}=num2str(updm(7));
    phone_mins_qc{dy1,1}=num2str(updm(8));
    
    sleep_glat_qc{dy1,1}=num2str(updm(9));
    sleep_imob_old_qc{dy1,1}=num2str(updm(10));
    sleep_nphase_old_qc{dy1,1}=num2str(updm(11));
    sleep_mphase_old_qc{dy1,1}=num2str(updm(12));
    
    actual_sleep_time_qc{dy1,1}=num2str(updm(13));
    actual_wake_time_qc{dy1,1}=num2str(updm(14));
    sleep_bout_num_qc{dy1,1}=num2str(updm(15));
    wake_bout_num_qc{dy1,1}=num2str(updm(16));

    sleep_bout_mn_qc{dy1,1}=num2str(updm(17));
    wake_bout_mn_qc{dy1,1}=num2str(updm(18));
    sleep_eff_qc{dy1,1}=num2str(updm(19));   
    
    sleep_imob_mins_qc{dy1,1}=num2str(updm(20));
    sleep_move_mins_qc{dy1,1}=num2str(updm(21));
    sleep_imob_per_qc{dy1,1}=num2str(updm(22));
    sleep_move_per_qc{dy1,1}=num2str(updm(23));

    sleep_phase_num_qc{dy1,1}=num2str(updm(24));
    sleep_phase1_num_qc{dy1,1}=num2str(updm(25));
    sleep_phase_per_qc{dy1,1}=num2str(updm(26));
    sleep_frag_inx_qc{dy1,1}=num2str(updm(27));

    
    nap1_durn_qc{dy1,1}=num2str(updm(28));
    nap2_durn_qc{dy1,1}=num2str(updm(29));
    
    walk_before_min_qc{dy1,1}=num2str(updm(30));
    walk_after_min_qc{dy1,1}=num2str(updm(31));
    run_before_min_qc{dy1,1}=num2str(updm(32));
    run_after_min_qc{dy1,1}=num2str(updm(33));
    active_before_min_qc{dy1,1}=num2str(updm(34));
    active_after_min_qc{dy1,1}=num2str(updm(35));
    active_before_per_qc{dy1,1}=num2str(updm(36));
    active_after_per_qc{dy1,1}=num2str(updm(37));

    data_accpt_qc{dy1,1}=num2str(updm(38));
    cmnt_qc{dy1,1}=comnt;

    save(strcat(outp,'/',sb1,'_tabl_foc.mat'),'bed_start','bed_up','sleep_start','sleep_wake','bed_dur','sleep_dur','off_wrist','sleep_lat', ...
        'light_nbout','light_mins','phone_nbout','phone_mins', ...
        'sleep_glat','sleep_imob_old','sleep_nphase_old','sleep_mphase_old', ...
        'actual_sleep_time','actual_wake_time','sleep_bout_num','wake_bout_num','sleep_bout_mn','wake_bout_mn','sleep_eff', ...
        'sleep_imob_mins','sleep_move_mins','sleep_imob_per','sleep_move_per', 'sleep_phase_num','sleep_phase1_num','sleep_phase_per','sleep_frag_inx', ...
        'nap1_str','nap1_stp','nap1_durn','nap2_str','nap2_stp','nap2_durn','walk_before_min','walk_after_min','run_before_min','run_after_min','active_before_min',             'active_after_min','active_before_per','active_after_per','data_accpt','cmnt', ...        
        'bed_start_qc','bed_up_qc','sleep_start_qc','sleep_wake_qc','bed_dur_qc','sleep_dur_qc','off_wrist_qc','sleep_lat_qc', ...
        'light_nbout_qc','light_mins_qc','phone_nbout_qc','phone_mins_qc', ...
        'sleep_glat_qc','sleep_imob_old_qc','sleep_nphase_old_qc','sleep_mphase_old_qc', ...
        'actual_sleep_time_qc','actual_wake_time_qc','sleep_bout_num_qc','wake_bout_num_qc','sleep_bout_mn_qc','sleep_bout_mn_qc','sleep_eff_qc', ...
        'sleep_imob_mins_qc','sleep_move_mins_qc','sleep_imob_per_qc','sleep_move_per_qc', 'sleep_phase_num_qc','sleep_phase1_num_qc','sleep_phase_per_qc','sleep_frag_inx_qc', ...
        'nap1_str_qc','nap1_stp_qc','nap1_durn_qc','nap2_str_qc','nap2_stp_qc','nap2_durn_qc','walk_before_min_qc','walk_after_min_qc','run_before_min_qc','run_after_min_qc','active_before_min_qc',             'active_after_min_qc','active_before_per_qc','active_after_per_qc','data_accpt_qc','cmnt_qc')

    %% scan figure   
    outf=strcat(outp,'/sleep_results2');
    if exist(outf,'dir')~=7
        mkdir(outf) 
        try 
            fileattrib(outf,'+w','a')
        catch ME
            mess='Not your folder';
        end
    end
    %% scan figure   
    outf3=strcat(outp,'/sleep_results3');
    if exist(outf3,'dir')~=7
        mkdir(outf3) 
        try 
            fileattrib(outf3,'+w','a')
        catch ME
            mess='Not your folder';
        end
    end

    savefig(ff1,strcat(outf3,'/',sb1(1:3),'_',num2str(dy1)));
    img = getframe(ff1);
    if dy1<10
    imwrite(img.cdata, strcat(outf,'/',sb1(1:3),'_00',num2str(dy1),'.png'));
    elseif dy1<100
        imwrite(img.cdata, strcat(outf,'/',sb1(1:3),'_0',num2str(dy1),'.png'));
    else
        imwrite(img.cdata, strcat(outf,'/',sb1(1:3),'_',num2str(dy1),'.png'));
    end
%    print(ff1,strcat(outf,'/',sb1(1:3),'_',num2str(dy1)),'-dpdf','-bestfit')
end


%% DPdash format
%%  Call study data
dys=[1:1:ndy]';
mdys=dys+mn-1;
wdys=weekday(mdys+1);
jdys=(mdys-datenum('1970-01-01'))*1000*3600*24;
days=num2str(dys);
reftime=num2str(jdys);
weekday1=num2str(wdys);
timeofday=[];
for k=1:ndy
    timeofday=[timeofday;'00:00:00'];
end
tab1=table(reftime,days,timeofday,weekday1,bed_start,bed_up,sleep_start,sleep_wake,bed_dur,sleep_dur,off_wrist,sleep_lat, ...
        light_nbout,light_mins,phone_nbout,phone_mins, ...
        sleep_glat,sleep_imob_old,sleep_nphase_old,sleep_mphase_old, ...
        actual_sleep_time,actual_wake_time,sleep_bout_num,wake_bout_num,sleep_bout_mn,wake_bout_mn,sleep_eff, ...
        sleep_imob_mins,sleep_move_mins,sleep_imob_per,sleep_move_per, sleep_phase_num,sleep_phase1_num,sleep_phase_per,sleep_frag_inx, ...
        nap1_str,nap1_stp,nap1_durn,nap2_str,nap2_stp,nap2_durn,walk_before_min,walk_after_min,run_before_min,run_after_min,active_before_min,active_after_min,active_before_per,active_after_per,data_accpt,cmnt, ...        
        bed_start_qc,bed_up_qc,sleep_start_qc,sleep_wake_qc,bed_dur_qc,sleep_dur_qc,off_wrist_qc,sleep_lat_qc, ...
        light_nbout_qc,light_mins_qc,phone_nbout_qc,phone_mins_qc, ...
        sleep_glat_qc,sleep_imob_old_qc,sleep_nphase_old_qc,sleep_mphase_old_qc, ...
        actual_sleep_time_qc,actual_wake_time_qc,sleep_bout_num_qc,wake_bout_num_qc,sleep_bout_mn_qc,wake_bout_mn_qc,sleep_eff_qc, ...
        sleep_imob_mins_qc,sleep_move_mins_qc,sleep_imob_per_qc,sleep_move_per_qc, sleep_phase_num_qc,sleep_phase1_num_qc,sleep_phase_per_qc,sleep_frag_inx_qc, ...
        nap1_str_qc,nap1_stp_qc,nap1_durn_qc,nap2_str_qc,nap2_stp_qc,nap2_durn_qc,walk_before_min_qc,walk_after_min_qc,run_before_min_qc,run_after_min_qc,active_before_min_qc,active_after_min_qc,active_before_per_qc,active_after_per_qc,data_accpt_qc,cmnt_qc);

tab1.Properties.VariableNames{'days'} = 'day';
tab1.Properties.VariableNames{'weekday1'} = 'weekday';

writetable(tab1,strcat(outp,'/',sb1,'_res_foc.csv'),'Delimiter',',','QuoteStrings',false)
%% make pdf
strg=strcat('convert -adjoin',{' '},outp,'/sleep_results2/*.png',{' '},outp,'/plots2_',sb1,'.pdf');
system(strg{1,1})
clearvars -except s

display('COMPLETE');
exit(0);
