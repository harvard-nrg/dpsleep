function upact(read_dir1, read_dir2, output_dir,output_dir0, study, subject, ref_date)

%% Study and subject 
stdy=study; 
sb1=subject; 
mn=datenum(ref_date);   % Choose 1st day as the actigraphy reference

%% Input and output directory
display('QC Pipeline.')
display('Checking input directory.');
adr1=read_dir1;
% Check if the path is properly formatted
if ~ endsWith(adr1, '/')
    adr1 = strcat(adr1, '/');
end

adr2=read_dir2;
% Check if the path is properly formatted
if ~ endsWith(adr2, '/')
    adr2 = strcat(adr2, '/');
end

display('Checking output directory.');
adrq=output_dir;
% Check if the path is properly formatted
if ~ endsWith(adrq, '/')
    adrq = strcat(adrq, '/');
end
adrq0=output_dir0;
% Check if the path is properly formatted
if ~ endsWith(adrq0, '/')
    adrq0 = strcat(adrq0, '/');
end

%% Find the files related to the day + some days before and after that day
display('Finding files.');
d3=dir(strcat(adr1,'*.mat'));

files_len = length(d3);
% Exit if there are no files to read
if files_len == 0
    display('Files do not exist under this directory.');
    exit(1);
end

%% Parameters/ Read data
display('Initializing adresses.');
load(strcat(adr1,'/',d3.name))
ndy=length(indf_score(1,:));

ins_active=indf_active;
ins_active(inds_qc==0)=NaN;
insd_active=nanmean(ins_active)';
inw_active=indf_active;
inw_active(inds_qc==1)=NaN;
inwd_active=nanmean(inw_active)';

ins_activer=indf_activer;
ins_activer(inds_qc==0)=NaN;
insd_activer=nanmean(ins_activer)';
inw_activer=indf_activer;
inw_activer(inds_qc==1)=NaN;
inwd_activer=nanmean(inw_activer)';

ins_activest=indf_activest;
ins_activest(inds_qc==0)=NaN;
insd_activest=nanmean(ins_activest)';
inw_activest=indf_activest;
inw_activest(inds_qc==1)=NaN;
inwd_activest=nanmean(inw_activest)';

indv0_act=reshape(indf_active,1,ndy*1440);
indv_act=[indv0_act(1,6*60+1:end) zeros(1,6*60)];
indv_act(indv_act==0)=NaN;
indf_act=reshape(indv_act,1440,ndy);
indd_active=nanmean(indf_act)';
indf_act2=reshape(indv_act,60,24*ndy);
indh_active1=nanmean(indf_act2);
indh_active=reshape(indh_active1,24,ndy)';

indv0_scr=reshape(indf_score,1,ndy*1440);
indv_scr=[indv0_scr(1,6*60+1:end) zeros(1,6*60)];
indv_scr(indv_scr==0)=NaN;  indv_scr(indv_scr==6)=NaN;
indf_scr=reshape(indv_scr,1440,ndy);
indd_score=nanmean(indf_scr)';
indf_scr2=reshape(indv_scr,60,24*ndy);
indh_score1=nanmean(indf_scr2);
indh_score=reshape(indh_score1,24,ndy)';

outp=adrq;
if exist(strcat(adr2,'/',sb1,'_res_foc_qcd.csv'), 'file') == 2
    qst=readtable(strcat(adr2,'/',sb1,'_res_foc_qcd.csv'));
else
    qst=readtable(strcat(adr2,'/',sb1,'_res_foc.csv'));
end
for dy1=1:ndy
    comnt=[];
    try 
            indf_out=indf_score(:,dy1);
            indf_prc=indf_active(:,dy1);
            indf_light1=indf_light(:,dy1);
            indf_phone=indf_phone1(:,dy1);
            indf_wlk=indf_walk(:,dy1);
            
            bts1=qst.bed_start_qc{dy1,1};
            bts2=qst.bed_up_qc{dy1,1};
            sts1=qst.sleep_start_qc{dy1,1};
            sts2=qst.sleep_wake_qc{dy1,1};

            nst1=qst.nap1_str_qc{dy1,1};    
            nsp1=qst.nap1_stp_qc{dy1,1};
            nst2=qst.nap2_str_qc{dy1,1};    
            nsp2=qst.nap2_stp_qc{dy1,1};
                
            updm=process_actigraphy_update(sts1,sts2,bts1,bts2,nst1,nsp1,nst2,nsp2,indf_out,indf_prc,indf_light1,indf_phone,indf_wlk);
    catch ME
            disp(sb1)
            dy1
            updm=[NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,0];
            comnt=[comnt '/ no data'];
    end            
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
    sleep6pm_onst_qc{dy1,1}=num2str(18+updm(2));
    wake6pm_time_qc{dy1,1}=num2str(updm(3)-6);
    bed_dur_qc{dy1,1}=num2str(updm(4));
    sleep_dur_qc{dy1,1}=num2str(updm(5));        
    sleep_lat_qc{dy1,1}=num2str(updm(6));
    
    light_nbout_qc{dy1,1}=num2str(updm(7));
    light_mins_qc{dy1,1}=num2str(updm(8));
    phone_nbout_qc{dy1,1}=num2str(updm(9));
    phone_mins_qc{dy1,1}=num2str(updm(10));
    
    sleep_glat_qc{dy1,1}=num2str(updm(11));
    sleep_imob_old_qc{dy1,1}=num2str(updm(12));
    sleep_nphase_old_qc{dy1,1}=num2str(updm(13));
    sleep_mphase_old_qc{dy1,1}=num2str(updm(14));
    
    actual_sleep_time_qc{dy1,1}=num2str(updm(15));
    actual_wake_time_qc{dy1,1}=num2str(updm(16));
    sleep_bout_num_qc{dy1,1}=num2str(updm(17));
    wake_bout_num_qc{dy1,1}=num2str(updm(18));

    sleep_bout_mn_qc{dy1,1}=num2str(updm(19));
    wake_bout_mn_qc{dy1,1}=num2str(updm(20));
    sleep_eff_qc{dy1,1}=num2str(updm(21));   
    
    sleep_imob_mins_qc{dy1,1}=num2str(updm(22));
    sleep_move_mins_qc{dy1,1}=num2str(updm(23));
    sleep_imob_per_qc{dy1,1}=num2str(updm(24));
    sleep_move_per_qc{dy1,1}=num2str(updm(25));

    sleep_phase_num_qc{dy1,1}=num2str(updm(26));
    sleep_phase1_num_qc{dy1,1}=num2str(updm(27));
    sleep_phase_per_qc{dy1,1}=num2str(updm(28));
    sleep_frag_inx_qc{dy1,1}=num2str(updm(29));
    sleep_frag_evnt_qc{dy1,1}=num2str(updm(30));
    

    
    nap1_durn_qc{dy1,1}=num2str(updm(31));
    nap2_durn_qc{dy1,1}=num2str(updm(32));
    sleep_activity_qc{dy1,1}=num2str(updm(33));
    walk_before_min_qc{dy1,1}=num2str(updm(34));
    walk_after_min_qc{dy1,1}=num2str(updm(35));
    run_before_min_qc{dy1,1}=num2str(updm(36));
    run_after_min_qc{dy1,1}=num2str(updm(37));
    active_before_min_qc{dy1,1}=num2str(updm(38));
    active_after_min_qc{dy1,1}=num2str(updm(39));
    activlev_before_min_qc{dy1,1}=num2str(updm(40));
    activlev_after_min_qc{dy1,1}=num2str(updm(41));
    activdur_before_min_qc{dy1,1}=num2str(updm(42));
    activdur_after_min_qc{dy1,1}=num2str(updm(43));

    data_accpt_qc{dy1,1}=num2str(updm(44));
    cmnt_qc{dy1,1}=comnt;
end
wlkb=str2double(walk_before_min_qc);
wlka=str2double(walk_after_min_qc);
wlkd=wlka+[wlkb(2:end);NaN];
walk_day_min_qc=cellstr(num2str(wlkd));

runb=str2double(run_before_min_qc);
runa=str2double(run_after_min_qc);
rund=runa+[runb(2:end);NaN];
run_day_min_qc=cellstr(num2str(rund));

actb=str2double(active_before_min_qc);
acta=str2double(active_after_min_qc);
actd=acta+[actb(2:end);NaN];
active_day_min_qc=cellstr(num2str(actd));

aclb=str2double(activlev_before_min_qc);
acla=str2double(activlev_after_min_qc);
acld=acla+[aclb(2:end);NaN];
acdb=str2double(activdur_before_min_qc);
acda=str2double(activdur_after_min_qc);
acdd=acda+[acdb(2:end);NaN];
actw=100*actd./acdd;
acts=str2double(sleep_activity_qc);
actswr=acts./actw;
active_sleep_wake_qc=cellstr(num2str(actswr));
activlevp_day_per_qc=cellstr(num2str(100*actd./acdd));
activdur_day_min_qc=cellstr(num2str(acdd));


tab1=table(bed_start_qc,bed_up_qc,sleep_start_qc,sleep_wake_qc,sleep6pm_onst_qc,wake6pm_time_qc,bed_dur_qc,sleep_dur_qc,off_wrist_qc,sleep_lat_qc, ...
        light_nbout_qc,light_mins_qc,phone_nbout_qc,phone_mins_qc, ...
        sleep_glat_qc,sleep_imob_old_qc,sleep_nphase_old_qc,sleep_mphase_old_qc, ...
        actual_sleep_time_qc,actual_wake_time_qc,sleep_bout_num_qc,wake_bout_num_qc,sleep_bout_mn_qc,wake_bout_mn_qc,sleep_eff_qc, ...
        sleep_imob_mins_qc,sleep_move_mins_qc,sleep_imob_per_qc,sleep_move_per_qc, sleep_phase_num_qc,sleep_phase1_num_qc,sleep_phase_per_qc,sleep_frag_inx_qc, sleep_frag_evnt_qc, sleep_activity_qc, ...
        nap1_str_qc,nap1_stp_qc,nap1_durn_qc,nap2_str_qc,nap2_stp_qc,nap2_durn_qc,walk_day_min_qc,run_day_min_qc,active_day_min_qc,activlevp_day_per_qc,activdur_day_min_qc,active_sleep_wake_qc,data_accpt_qc,cmnt_qc);
tab0=qst(:,1:8);
tabb=[tab0 tab1];
writetable(tabb,strcat(outp,'/',sb1,'_res_foc_qcd.csv'),'Delimiter',',','QuoteStrings',false)

%% DPdash format
dys=[];
timeofday=[];
tdys=[];
tday=['00:00:00';'01:00:00';'02:00:00';'03:00:00';'04:00:00';'05:00:00';'06:00:00';'07:00:00';'08:00:00';'09:00:00';'10:00:00';'11:00:00';'12:00:00';...
'13:00:00';'14:00:00';'15:00:00';'16:00:00';'17:00:00';'18:00:00';'19:00:00';'20:00:00';'21:00:00';'22:00:00';'23:00:00'];
tdy=[0:1/24:23/24]';
for k=1:1:ndy
    dys=[dys;repmat(k,24,1)];
    tdys=[tdys;repmat(k,24,1)+tdy];
    timeofday=[timeofday;tday];
end
mdys=dys+mn-1;
wdys=weekday(mdys+1);
jdys=(tdys-datenum('1970-01-01'))*1000*3600*24;    
days=num2str(dys);
reftime=num2str(jdys);
weekday1=num2str(wdys);

tab_hdp=table(reftime,days,timeofday,weekday1);
tab_ddp=qst(:,1:4);
try 
    tab_ddp.Properties.VariableNames{'days'} = 'day';
catch ME

end
try 
    tab_ddp.Properties.VariableNames{'weekday1'} = 'weekday';
catch ME

end

%% Sleep Parameters (Daily Detailed)
tab_sleep_qcdc=tab1(:,[3:4 36:37 39:40 49]);
tab_sleep_qcdn=tab1(:,[5:6 8:9 19:35 38 41:48]);
arr1=table2array(tab_sleep_qcdn);
arr=str2double(arr1);
tabv=tab_sleep_qcdn.Properties.VariableNames;
arrs=string(arr);
arrt=array2table(arrs);
arrt.Properties.VariableNames=tabv;
tabd=[tab_ddp tab_sleep_qcdc arrt];
%% scan figure   
outf3=strcat(adrq0,'/accel');
if exist(outf3,'dir')~=7
    mkdir(outf3) 
    try 
        fileattrib(outf3,'+w','a')
    catch ME
        mess='Not your folder';
    end
end

flp=dir(strcat(adrq0,'/accel/',study,'-',sb1,'-actigraphy_GENEActiv_sleep*.csv'));
if ~isempty(flp)
    for k=1:length(flp)
        filen=flp(k,1).name;
        delete(strcat(adrq0,'/accel/',filen));
    end
end
writetable(tabd,strcat(adrq0,'/accel/',study,'-',sb1,'-actigraphy_GENEActiv_sleep_detailed_daily-day1to',num2str(ndy),'.csv'),'Delimiter',',','QuoteStrings',true)

%% Sleep Parameters (Daily Simple)
tab_sleep2_qcdc=tab1(:,[3:4]);
tab_sleep2_qcdn=tab1(:,[5:6 8 47 33 35 45 48]);
arr2=table2array(tab_sleep2_qcdn);
arr0=str2double(arr2);
arrs0=string(arr0);
arrt0=array2table(arrs0);
tab_sleep2_qcd=[tab_sleep2_qcdc arrt0];
tab_sleep2_qcd.Properties.VariableNames={'SleepOnset_t','SleepOffset_t','SleepOnset_hr','SleepOffset_hr','SleepDuration_hr','SleepWakeActivityRatio','SleepFragmentationInx_perc','SleepActivity_perc','WakeActivity_perc','dataAccept'};
tabs=[tab_ddp tab_sleep2_qcd];
writetable(tabs,strcat(adrq0,'/accel/',study,'-',sb1,'-actigraphy_GENEActiv_sleep_simple_daily-day1to',num2str(ndy),'.csv'),'Delimiter',',','QuoteStrings',false)

digits(4)
activity=indh_active;
activity2=round(100*activity)/100;
activity1=string(activity2);
tab_act_hr1=array2table(activity1);
tab_act_hr1.Properties.VariableNames={'activityLevel_hour01','activityLevel_hour02', 'activityLevel_hour03','activityLevel_hour04','activityLevel_hour05','activityLevel_hour06','activityLevel_hour07','activityLevel_hour08','activityLevel_hour09','activityLevel_hour10','activityLevel_hour11','activityLevel_hour12','activityLevel_hour13','activityLevel_hour14','activityLevel_hour15','activityLevel_hour16','activityLevel_hour17','activityLevel_hour18','activityLevel_hour19','activityLevel_hour20','activityLevel_hour21','activityLevel_hour22','activityLevel_hour23','activityLevel_hour24'};
tab_act_hr=[tab_ddp tab_act_hr1];
writetable(tab_act_hr,strcat(adrq0,'/',study,'-',sb1,'-actigraphy_GENEActiv_accel_ActivityLevels_hourly-day1to',num2str(ndy),'.csv'),'Delimiter',',','QuoteStrings',false)

score=indh_score;
score2=round(100*score)/100;
score1=string(score2);
tab_scr_hr1 =array2table(score1);
tab_scr_hr1.Properties.VariableNames={'activityScore_hour01','activityScore_hour02', 'activityScore_hour03','activityScore_hour04','activityScore_hour05','activityScore_hour06','activityScore_hour07','activityScore_hour08','activityScore_hour09','activityScore_hour10','activityScore_hour11','activityScore_hour12','activityScore_hour13','activityScore_hour14','activityScore_hour15','activityScore_hour16','activityScore_hour17','activityScore_hour18','activityScore_hour19','activityScore_hour20','activityScore_hour21','activityScore_hour22','activityScore_hour23','activityScore_hour24'};
tab_scr_hr=[tab_ddp tab_scr_hr1];
writetable(tab_scr_hr,strcat(adrq0,'/',study,'-',sb1,'-actigraphy_GENEActiv_accel_ActivityScores_hourly-day1to',num2str(ndy),'.csv'),'Delimiter',',','QuoteStrings',false)

activity_daily=num2str(indd_active,'%4.2f');
tab_act0=table(activity_daily);
tab_act_d=[tab_ddp tab_act0];
writetable(tab_act_d,strcat(adrq0,'/',study,'-',sb1,'-actigraphy_GENEActiv_accel_ActivityLevels_daily-day1to',num2str(ndy),'.csv'),'Delimiter',',','QuoteStrings',false)

sactivity_daily=num2str(insd_active,'%4.4f');
tab_act1=table(sactivity_daily);
tab_acts_d=[tab_ddp tab_act1];
writetable(tab_acts_d,strcat(adrq0,'/',study,'-',sb1,'-actigraphy_GENEActiv_accel_SleepActivityLevels_daily-day1to',num2str(ndy),'.csv'),'Delimiter',',','QuoteStrings',false)

wactivity_daily=num2str(inwd_active,'%4.4f');
tab_act1=table(wactivity_daily);
tab_actw_d=[tab_ddp tab_act1];
writetable(tab_actw_d,strcat(adrq0,'/',study,'-',sb1,'-actigraphy_GENEActiv_accel_WakeActivityLevels_daily-day1to',num2str(ndy),'.csv'),'Delimiter',',','QuoteStrings',false)

score_daily=num2str(indd_score,'%4.2f');
tab_scr_d0=table(score_daily);
tab_scr_d=[tab_ddp tab_scr_d0];
writetable(tab_scr_d,strcat(adrq0,'/',study,'-',sb1,'-actigraphy_GENEActiv_accel_ActivityScores_daily-day1to',num2str(ndy),'.csv'),'Delimiter',',','QuoteStrings',false)

save(strcat(outp,'/',stdy,'-',sb1(1:3),'-all2.mat'),'tabb','dys','indd_active','indd_score','indh_score','indh_active','insd_active','inwd_active','insd_activer','inwd_activer','insd_activest','inwd_activest')

display('COMPLETE');
exit(0);
