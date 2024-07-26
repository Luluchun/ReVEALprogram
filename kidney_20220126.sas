/*Title: Rural-Urban Health Disparity in Patients with Chronic Kidney Disease in Taiwan  */
/***************************************************************************************************************************/
/*data processing*/
/*1. data import*/
PROC IMPORT OUT= WORK.DATA 
            DATAFILE= "D:\Dropbox\2019_1_Kidney\#paper 1, disparity\data\survey.csv" 
            DBMS=CSV REPLACE;
     GETNAMES=YES;
     DATAROW=2; 
RUN;
/*proc contents data=data short;run;*/

/*2. data clean*/
data data_correct;
set data;
if ID=" " or eGFR=" " or Proteinuria=" " then delete;
if height<120 or height>220 then height_new=.;
else height_new=height;
if weight<30 or weight>150 then weight_new=.;
else weight_new=weight;
bmi_cor=weight_new/((height_new/100)*(height_new/100));
if bmi_cor>60 then bmi_new=.;
else bmi_new=bmi_cor;
if waist<50 or waist>150 then waist_new=.;
else waist_new=waist;
if sbp<70 or sbp>230 then sbp_new=.;
else sbp_new=sbp;
if dbp<30 or dbp>150 then dbp_new=.;
else dbp_new=dbp;
if hr<40 or hr>150 then hr_new=.;
else hr_new=hr;
age=substr(Date,5,4)*1-substr(Birth,5,4)*1;
in_date=mdy(substr(Date,9,2),substr(Date,11,2),substr(Date,5,4)*1);
if age<20 then delete;
else age_new=age;
survey=scan(No_,1, "-");
run;

/*3. baseline*/
proc sort data=data_correct;
by ID in_date;
run;
data survey_person;set data_correct;
by ID in_date;
if first.ID then seq=0;
retain seq;
seq=seq+1;
if first.ID then output;
run;

/*4. define the category of variables*/
data survey_person_cut;
set survey_person;
if survey in ("1" "5" "6" "7" "9" "12" "14" "16" "17" "23" "24" "25" "26" "28" "29" "31" "33" "34" "35" "36" "37" "38" "39" "40" "41" "42" "44" "45" "46" "47" "48" "49" "51" "53" "54" "55" "58" "59" "61" "62" "63" "64" "65" "67" "68" "70" "72" "73" "76" "79" "81" "83" "85" "86" "87" "89" "90" "91") then urban=1;
else if survey in ("2" "3" "4" "8" "10" "11" "13" "15" "18" "21" "22" "27" "30" "32" "43" "50" "52" "56" "57" "60" "66" "69" "74" "75" "77" "78" "80" "82" "84" "88" "92") then urban=0;
eGFR=eGFR*1;
IF eGFR=. then egfr_group=.;
ELSE IF 0<eGFR<60 then egfr_group=1;
ELSE egfr_group=0;
IF Proteinuria=. then Proteinuria_group=.;
ELSE IF Proteinuria>=150 then Proteinuria_group=1;
ELSE Proteinuria_group=0;
/*upcr group*/
IF Proteinuria=. then upcr_group=.;
ELSE IF 0<=Proteinuria<150 then upcr_group=0;
ELSE IF 150<=Proteinuria<150  then upcr_group=1;
ELSE IF 0<=Proteinuria<150  then upcr_group=2;
ELSE IF Proteinuria>3000  then upcr_group=3;
IF Proteinuria=. or egfr=. then stage_new=.;
ELSE IF 0<=egfr<15 then stage_new=5;
ELSE IF 30>egfr>=15 then stage_new=4;
ELSE IF 60>egfr>=30 then stage_new=3;
ELSE IF 90>egfr>=60 and (Proteinuria>=150) then stage_new=2;
ELSE IF egfr>=90 and (Proteinuria>=150) then stage_new=1;
ELSE IF egfr>=60 and (0<=Proteinuria<150) then stage_new=0;
/*ELSE IF 90>egfr>=60 and (Proteinuria>=150 or P_Kidneydisease=1) then stage_new=2;
ELSE IF egfr>=90 and (Proteinuria>=150 or P_Kidneydisease=1) then stage_new=1;
ELSE IF egfr>=60 and (0<=Proteinuria<150 or P_Kidneydisease=0) then stage_new=0;*/
ELSE stage_new=.;
if eGFR=. then ckd=.;
else if 0<=eGFR <60 then ckd=1;
else if Proteinuria>=150 then ckd=1;
/*else if P_Kidneydisease=1 then ckd=1;*/
else ckd=0;
IF ckd=0 or P_Kidneydisease=. then aware=.;
ELSE IF ckd=1 and P_Kidneydisease=1 then aware=1;
ELSE IF ckd=1 and P_Kidneydisease=0 then aware=0;
IF stage_new=1 or stage_new=2 or stage_new=3 then late_ckd=0;
ELSE IF stage_new=4 or stage_new=5 then late_ckd=1;
ELSE late_ckd=.;
IF bmi_new=. then  bmi_group=.;
ELSE IF bmi_new<18.5 then bmi_group=0;
ELSE IF 18.5<=bmi_new<24 then bmi_group=1;
ELSE IF 24<=bmi_new<27 then bmi_group=2;
ELSE IF bmi_new>=27 then bmi_group=3;
IF bmi_group=. then overweight=.;
ELSE IF bmi_group<=1 then overweight=0;
ELSE overweight=1;
IF bmi_group=. then obesity=.;
ELSE IF bmi_group<=2 then obesity=0;
ELSE obesity=1;
IF waist_new=. then  waist_group=.;
ELSE IF waist_new<80 and gender=0 then waist_group=0;
ELSE IF waist_new<90 and gender=1 then waist_group=0;
ELSE waist_group=1;
IF sbp_new=. or dbp_new=. then  bp_group=.;
ELSE IF sbp_new>=140 or dbp_new>=90 then bp_group=1;
ELSE bp_group=0;
age2=age_new*age_new;
IF age_new>=65 then age_gp=1;
ELSE IF age_new<65 then age_gp=0;
IF age_new=. then age_gp2="NA";
ELSE IF age_new<40 then age_gp2="20-39";
ELSE IF 40<=age_new<50 then age_gp2="40-49";
ELSE IF 50<=age_new<60 then age_gp2="50-59";
ELSE IF 60<=age_new<70 then age_gp2="60-69";
ELSE IF 70<=age_new then age_gp2="70+";
IF age_new=. then age_gp3="NA";
ELSE IF 20<=age_new<25 then agegroup=4;
ELSE IF 25<=age_new<30 then agegroup=5;
ELSE IF 30<=age_new<35 then agegroup=6;
ELSE IF 35<=age_new<40 then agegroup=7;
ELSE IF 40<=age_new<45 then agegroup=8;
ELSE IF 45<=age_new<50 then agegroup=9;
ELSE IF 50<=age_new<55 then agegroup=10;
ELSE IF 55<=age_new<60 then agegroup=11;
ELSE IF 60<=age_new<65 then agegroup=12;
ELSE IF 65<=age_new<70 then agegroup=13;
ELSE IF 70<=age_new<75 then agegroup=14;
ELSE IF 75<=age_new<80 then agegroup=15;
ELSE IF 80<=age_new<85 then agegroup=16;
ELSE IF 85<=age_new<90 then agegroup=17;
ELSE IF 90<=age_new<95 then agegroup=18;
ELSE IF 95<=age_new<100 then agegroup=19;
ELSE IF 100<=age_new then agegroup=20;
IF gender=. or creatinine_blood=. or age_new=. then egfr_epi=.;
ELSE IF gender=1 & creatinine_blood<=0.9 then egfr_epi=141*(creatinine_blood/0.9)**(-0.411)*0.993**age_new;
ELSE IF gender=1 & creatinine_blood>0.9 then egfr_epi=141*(creatinine_blood/0.9)**(-1.209)*0.993**age_new;
ELSE IF gender=0 & creatinine_blood<=0.7 then egfr_epi=144*(creatinine_blood/0.9)**(-0.329)*0.993**age_new;
ELSE IF gender=0 & creatinine_blood>0.7 then egfr_epi=144*(creatinine_blood/0.9)**(-1.209)*0.993**age_new;
IF Sugar_AC=. then glucose_uncontrolled=.;
ELSE IF Sugar_AC>126 then glucose_uncontrolled=1;
ELSE glucose_uncontrolled=0;
IF Uric_Acid=. then gout_uncontrolled=.;
ELSE IF gender=1 & Uric_Acid>7.5 then gout_uncontrolled=1;
ELSE IF gender=0 & Uric_Acid>6 then gout_uncontrolled=1;
ELSE gout_uncontrolled=0;
IF Cholesterol=. and Triglyceride=. then lipid_uncontrolled=.;
ELSE IF Cholesterol>200 or Triglyceride>150 then lipid_uncontrolled=1;
ELSE lipid_uncontrolled=0;
IF Med_NY=. then China_med=. ;
ELSE IF Med_NY=10 then China_med=0;
ELSE China_med=1;
IF None=. then NoDRmed=. ;
ELSE IF None=1 then NoDRmed=0;
ELSE NoDRmed=1;
IF Painkiller=. or  Liver_Sup=. or Kidney_Sup=. or Diet_Pill=. then NoDRmed2=. ;
ELSE IF Painkiller=1 or  Liver_Sup=1 or Kidney_Sup=1 or Diet_Pill=1 then NoDRmed2=1 ;
ELSE NoDRmed2=0;
IF Painkiller=. or  Liver_Sup=. or Kidney_Sup=. then NoDRmed3=. ;
ELSE IF Painkiller=1 or  Liver_Sup=1 or Kidney_Sup=1 then NoDRmed3=1 ;
ELSE NoDRmed3=0;
IF Smoke_Hist=. then smk=.;
ELSE IF Smoke_Hist=10 then smk=0;
ELSE smk=1;
IF Drink_Hist=. then alcohol=.;
ELSE IF Drink_Hist=10 then alcohol=0;
ELSE alcohol=1;
IF Eat_Hist=. then betelnut=.;
ELSE IF Eat_Hist=10 then betelnut=0;
ELSE betelnut=1;
IF betelnut=1 & alcohol=1 & smk=1 then bad3=3;
ELSE IF (betelnut=1 & alcohol=1 & smk=0) or (betelnut=1 & alcohol=0 & smk=1) or (betelnut=0 & alcohol=1 & smk=1) then bad3=2;
ELSE IF betelnut=0 & alcohol=0 & smk=0 then bad3=0;
ELSE bad3=1;
IF betelnut=1 or  alcohol=1 or smk=1 then bad=1;
ELSE bad=0;
IF glucose_uncontrolled=. and P_DM=. then DM_prev=.;
ELSE IF glucose_uncontrolled=1 then DM_prev=1;
ELSE IF P_DM=1 then DM_prev=1;
ELSE DM_prev=0;
IF gout_uncontrolled=. and P_hyperuricemia=. then Gout_prev=.;
ELSE IF gout_uncontrolled=1 then Gout_prev=1;
ELSE IF P_hyperuricemia=1 then Gout_prev=1;
ELSE Gout_prev=0;
IF lipid_uncontrolled=. and P_hyperlipidemia=. then Lipid_prev=.;
ELSE IF lipid_uncontrolled=1 then Lipid_prev=1;
ELSE IF P_hyperlipidemia=1 then Lipid_prev=1;
ELSE Lipid_prev=0;
IF bp_group=. and P_hypertension=. then Hypertension_prev=.;
IF bp_group=1 then Hypertension_prev=1;
ELSE IF P_hypertension=1 then Hypertension_prev=1;
ELSE Hypertension_prev=0;
IF Educ_level=. then edu=.;
ELSE IF Educ_level=10 then edu=0;
ELSE IF Educ_level=20 then edu=6;
ELSE IF Educ_level=30 then edu=9;
ELSE IF Educ_level=40 then edu=12;
ELSE IF Educ_level=50 then edu=16;
IF edu=. then edu_gp=.;
ELSE IF 0<=edu<12 then edu_gp=0;
ELSE edu_gp=1;
IF waist=. then waist_gp=.;
ELSE IF gender=1 & waist>=90 then waist_gp=1;
ELSE IF gender=0 & waist>=80 then waist_gp=1;
ELSE waist_gp=0;
IF Career=. then Career1=.;
ELSE IF Career=50 then Career1=1;
ELSE Career1=0;
run;

/*4+. test for ckdepi equation*/
data survey_person_cut2;
set survey_person_cut;
IF gender=0 and Creatinine_Blood<=0.7 then ckdepi=144*((Creatinine_Blood/0.7)**(-0.329))*(0.993**age);
ELSE IF gender=0 and Creatinine_Blood>0.7 then ckdepi=144*((Creatinine_Blood/0.7)**(-1.209))*(0.993**age);
IF gender=1 and Creatinine_Blood<=0.9 then ckdepi=141*((Creatinine_Blood/0.9)**(-0.411))*(0.993**age);
ELSE IF gender=1 and Creatinine_Blood>0.9 then ckdepi=141*((Creatinine_Blood/0.9)**(-1.209))*(0.993**age);
IF Proteinuria=. or ckdepi=. then stage_new_ckdepi=.;
ELSE IF 0<=ckdepi<15 then stage_new_ckdepi=5;
ELSE IF 30>ckdepi>=15 then stage_new_ckdepi=4;
ELSE IF 60>ckdepi>=30 then stage_new_ckdepi=3;
ELSE IF 90>ckdepi>=60 and (Proteinuria>=150) then stage_new_ckdepi=2;
ELSE IF ckdepi>=90 and (Proteinuria>=150) then stage_new_ckdepi=1;
ELSE IF ckdepi>=60 and (0<=Proteinuria<150) then stage_new_ckdepi=0;
run;

/***************************************************************************************************************************/
/*data analysis*/
/*Table 1*/
/*using MDRD equation for CKD*/
proc freq data=survey_person_cut;
table urban*(age_gp2 gender edu smk betelnut alcohol waist_group bmi_group stage_new DM_prev Gout_prev Lipid_prev Hypertension_prev NoDRmed China_med)/nopercent nocol chisq;
run;
/*Supplement Painkiller Liver_Sup Kidney_Sup Diet_Pill*/
proc freq data=survey_person_cut;
table urban*(NoDRmed2 China_med)/nopercent nocol chisq;
run;
/**
proc means data=survey_person_cut;
class urban;
var age_new bmi_new waist_new bmi_new Proteinuria Uric_Acid Sugar_AC Cholesterol Triglyceride sbp_new dbp_new;
run;
**/

/*Figure 2*/
/*Results saved in D:\Dropbox\2019_1_Kidney\#paper 1, disparity\data\prevalence.csv*/
/*Figure generated by using R and R code saved in D:\Dropbox\2019_1_Kidney\#paper 1, disparity\code\Kidney_Figures.R*/
/*(A). CKD*/
proc sort data=survey_person_cut;
by gender;
run;
proc freq  data=survey_person_cut ;
table gender*urban*age_gp2*ckd/nopercent nocol out=A;
run;
proc transpose data=A out=B;
var count;
by gender urban age_gp2;
run;
data C;
set B;
total =COL1+COL2;
drop _name_ _label_;
run;
data D;
set C;
p=round ((col2/total),.0001);
if p=0 then CI_LOW=0;
if p=1 then CI_HIGH=1;
if p ne 0 then CI_LOW=round((1-betainv(.975,(total-col2+1),col2)),.0001);
if p ne 1 then CI_HIGH=round((1-betainv(.025,(total-col2),col2+1)),.0001);
run;
PROC EXPORT DATA= WORK.D 
            OUTFILE= "C:\Users\Lu\Dropbox\2020_10_CKD\1. urban rural ineqaulity\3. data\ckd.csv" 
            DBMS=CSV REPLACE;
     PUTNAMES=YES;
RUN;

/*(B). DM*/
proc sort data=survey_person_cut;
by gender;
run;
proc freq  data=survey_person_cut ;
table gender*urban*age_gp2*dm_prev/nopercent nocol out=A;
run;
proc transpose data=A out=B;
var count;
by gender urban age_gp2;
run;
data C;
set B;
total =COL1+COL2;
drop _name_ _label_;
run;
data D;
set C;
p=round ((col2/total),.0001);
if p=0 then CI_LOW=0;
if p=1 then CI_HIGH=1;
if p ne 0 then CI_LOW=round((1-betainv(.975,(total-col2+1),col2)),.0001);
if p ne 1 then CI_HIGH=round((1-betainv(.025,(total-col2),col2+1)),.0001);
run;
PROC EXPORT DATA= WORK.D 
            OUTFILE= "C:\Users\Lu\Dropbox\2020_10_CKD\1. urban rural ineqaulity\3. data\dm.csv" 
            DBMS=CSV REPLACE;
     PUTNAMES=YES;
RUN;

/*(C). Gout*/
proc sort data=survey_person_cut;
by gender;
run;
proc freq  data=survey_person_cut ;
table gender*urban*age_gp2*gout_prev/nopercent nocol out=A;
run;
proc transpose data=A out=B;
var count;
by gender urban age_gp2;
run;
data C;
set B;
total =COL1+COL2;
drop _name_ _label_;
run;
data D;
set C;
p=round ((col2/total),.0001);
if p=0 then CI_LOW=0;
if p=1 then CI_HIGH=1;
if p ne 0 then CI_LOW=round((1-betainv(.975,(total-col2+1),col2)),.0001);
if p ne 1 then CI_HIGH=round((1-betainv(.025,(total-col2),col2+1)),.0001);
run;
PROC EXPORT DATA= WORK.D 
            OUTFILE= "C:\Users\Lu\Dropbox\2020_10_CKD\1. urban rural ineqaulity\3. data\gout.csv" 
            DBMS=CSV REPLACE;
     PUTNAMES=YES;
RUN;

/*(D). Hypertension*/
proc sort data=survey_person_cut;
by gender;
run;
proc freq  data=survey_person_cut ;
table gender*urban*age_gp2*Hypertension_prev/nopercent nocol out=A;
run;
proc transpose data=A out=B;
var count;
by gender urban age_gp2;
run;
data C;
set B;
total =COL1+COL2;
drop _name_ _label_;
run;
data D;
set C;
p=round ((col2/total),.0001);
if p=0 then CI_LOW=0;
if p=1 then CI_HIGH=1;
if p ne 0 then CI_LOW=round((1-betainv(.975,(total-col2+1),col2)),.0001);
if p ne 1 then CI_HIGH=round((1-betainv(.025,(total-col2),col2+1)),.0001);
run;
PROC EXPORT DATA= WORK.D 
            OUTFILE= "C:\Users\Lu\Dropbox\2020_10_CKD\1. urban rural ineqaulity\3. data\Hypertension.csv" 
            DBMS=CSV REPLACE;
     PUTNAMES=YES;
RUN;

/*Figure 3*/
/*Results saved in D:\Dropbox\2019_1_Kidney\#paper 1, disparity\data\prevalence.csv*/
/*Figure generated by using R and R code saved in D:\Dropbox\2019_1_Kidney\#paper 1, disparity\code\Kidney_Figures.R*/

/* (A). Alcohol*/
data alcohol;
set survey_person_cut;
if alcohol=. then delete;
run;
proc freq  data=alcohol ;
table gender*urban*age_gp2*alcohol/nopercent nocol out=A;
run;
proc transpose data=A out=B;
var count;
by gender urban age_gp2;
run;
data C;
set B;
total =COL1+COL2;
drop _name_ _label_;
run;
data D;
set C;
p=round ((col2/total),.0001);
if p=0 then CI_LOW=0;
if p=1 then CI_HIGH=1;
if p ne 0 then CI_LOW=round((1-betainv(.975,(total-col2+1),col2)),.0001);
if p ne 1 then CI_HIGH=round((1-betainv(.025,(total-col2),col2+1)),.0001);
run;
PROC EXPORT DATA= WORK.D 
            OUTFILE= "C:\Users\Lu\Dropbox\2020_10_CKD\1. urban rural ineqaulity\3. data\alcohol.csv" 
            DBMS=CSV REPLACE;
     PUTNAMES=YES;
RUN;

/*(B). Smoking*/
data smk;
set survey_person_cut;
if smk=. then delete;
run;
proc freq  data=smk ;
table gender*urban*age_gp2*smk/nopercent nocol out=A;
run;
proc transpose data=A out=B;
var count;
by gender urban age_gp2;
run;
data C;
set B;
total =COL1+COL2;
drop _name_ _label_;
run;
data D;
set C;
p=round ((col2/total),.0001);
if p=0 then CI_LOW=0;
if p=1 then CI_HIGH=1;
if p ne 0 then CI_LOW=round((1-betainv(.975,(total-col2+1),col2)),.0001);
if p ne 1 then CI_HIGH=round((1-betainv(.025,(total-col2),col2+1)),.0001);
run;
PROC EXPORT DATA= WORK.D 
            OUTFILE= "C:\Users\Lu\Dropbox\2020_10_CKD\1. urban rural ineqaulity\3. data\smk.csv" 
            DBMS=CSV REPLACE;
     PUTNAMES=YES;
RUN;

/*(C). Betel nut*/
data betelnut;
set survey_person_cut;
if betelnut=. then delete;
run;
proc freq  data=betelnut ;
table gender*urban*age_gp2*betelnut/nopercent nocol out=A;
run;
proc transpose data=A out=B;
var count;
by gender urban age_gp2;
run;
data C;
set B;
total =COL1+COL2;
drop _name_ _label_;
run;
data D;
set C;
p=round ((col2/total),.0001);
if p=0 then CI_LOW=0;
if p=1 then CI_HIGH=1;
if p ne 0 then CI_LOW=round((1-betainv(.975,(total-col2+1),col2)),.0001);
if p ne 1 then CI_HIGH=round((1-betainv(.025,(total-col2),col2+1)),.0001);
run;
PROC EXPORT DATA= WORK.D 
            OUTFILE= "C:\Users\Lu\Dropbox\2020_10_CKD\1. urban rural ineqaulity\3. data\betelnut.csv" 
            DBMS=CSV REPLACE;
     PUTNAMES=YES;
RUN;

/*(D) Obesity*/
data obesity;
set survey_person_cut;
if obesity=. then delete;
run;
proc freq  data=obesity ;
table gender*urban*age_gp2*obesity/nopercent nocol out=A;
run;
proc transpose data=A out=B;
var count;
by gender urban age_gp2;
run;
data C;
set B;
total =COL1+COL2;
drop _name_ _label_;
run;
data D;
set C;
p=round ((col2/total),.0001);
if p=0 then CI_LOW=0;
if p=1 then CI_HIGH=1;
if p ne 0 then CI_LOW=round((1-betainv(.975,(total-col2+1),col2)),.0001);
if p ne 1 then CI_HIGH=round((1-betainv(.025,(total-col2),col2+1)),.0001);
run;
PROC EXPORT DATA= WORK.D 
            OUTFILE= "C:\Users\Lu\Dropbox\2020_10_CKD\1. urban rural ineqaulity\3. data\obesity.csv" 
            DBMS=CSV REPLACE;
     PUTNAMES=YES;
RUN;

/*overweight*/
/**data overweight;
set survey_person_cut;
if overweight=. then delete;
run;
proc freq  data=overweight ;
table gender*urban*age_gp2*overweight/nopercent nocol out=A;
run;
proc transpose data=A out=B;
var count;
by gender urban age_gp2;
run;
data C;
set B;
total =COL1+COL2;
drop _name_ _label_;
run;
data D;
set C;
p=round ((col2/total),.0001);
if p=0 then CI_LOW=0;
if p=1 then CI_HIGH=1;
if p ne 0 then CI_LOW=round((1-betainv(.975,(total-col2+1),col2)),.0001);
if p ne 1 then CI_HIGH=round((1-betainv(.025,(total-col2),col2+1)),.0001);
run;
PROC EXPORT DATA= WORK.D 
            OUTFILE= "C:\Users\Lu\Dropbox\2020_10_CKD\1. urban rural ineqaulity\3. data\overweight.csv" 
            DBMS=CSV REPLACE;
     PUTNAMES=YES;
RUN;

proc freq data =survey_person_cut;
table CKDStage*ckd;
run;
**/

/*Table 2. Crude and age-standardized prevalence by CKD stage and rural/urban area*/
/**********************************************************************************************************************************************************/
/*ckd stage*/
data ckd_stage;
set survey_person_cut;
if stage_new=. then delete;
run;
proc freq data=ckd_stage;
table urban*ckd/;
run;

proc freq  data=ckd_stage ;
table urban*stage_new/nopercent nocol out=A;
run;
proc transpose data=A out=B;
var count;
by urban;
run;
data C;
set B;
total =COL1+COL2+COL3+COL4+COL5+COL6;
drop _name_ _label_;
run;
data D;
set C;
p1=round((col2/total),.0001);
p2=round((col3/total),.0001);
p3=round((col4/total),.0001);
p4=round((col5/total),.0001);
p5=round((col6/total),.0001);

if p1=0 then CI_LOW1=0;
if p1=1 then CI_HIGH1=1;
if p1 ne 0 then CI_LOW1=round((1-betainv(.975,(total-col2+1),col2)),.0001);
if p1 ne 1 then CI_HIGH1=round((1-betainv(.025,(total-col2),col2+1)),.0001);

if p2=0 then CI_LOW2=0;
if p2=1 then CI_HIGH2=1;
if p2 ne 0 then CI_LOW2=round((1-betainv(.975,(total-col3+1),col3)),.0001);
if p2 ne 1 then CI_HIGH2=round((1-betainv(.025,(total-col3),col3+1)),.0001);

if p3=0 then CI_LOW3=0;
if p3=1 then CI_HIGH3=1;
if p3 ne 0 then CI_LOW3=round((1-betainv(.975,(total-col4+1),col4)),.0001);
if p3 ne 1 then CI_HIGH3=round((1-betainv(.025,(total-col4),col4+1)),.0001);

if p4=0 then CI_LOW4=0;
if p4=1 then CI_HIGH4=1;
if p4 ne 0 then CI_LOW4=round((1-betainv(.975,(total-col5+1),col5)),.0001);
if p4 ne 1 then CI_HIGH4=round((1-betainv(.025,(total-col5),col5+1)),.0001);

if p5=0 then CI_LOW5=0;
if p5=1 then CI_HIGH5=1;
if p5 ne 0 then CI_LOW5=round((1-betainv(.975,(total-col6+1),col6)),.0001);
if p5 ne 1 then CI_HIGH5=round((1-betainv(.025,(total-col6),col6+1)),.0001);
run;

/*ckd stage-combine rural and urban*/
data ckd_stage;
set survey_person_cut;
if stage_new=. then delete;
run;
proc freq  data=ckd_stage ;
table stage_new/nopercent nocol out=A;
run;
proc transpose data=A out=B;
var count;
run;
data C;
set B;
total =COL1+COL2+COL3+COL4+COL5+COL6;
drop _name_ _label_;
run;
data D;
set C;
p1=round((col2/total),.0001);
p2=round((col3/total),.0001);
p3=round((col4/total),.0001);
p4=round((col5/total),.0001);
p5=round((col6/total),.0001);

if p1=0 then CI_LOW1=0;
if p1=1 then CI_HIGH1=1;
if p1 ne 0 then CI_LOW1=round((1-betainv(.975,(total-col2+1),col2)),.0001);
if p1 ne 1 then CI_HIGH1=round((1-betainv(.025,(total-col2),col2+1)),.0001);

if p2=0 then CI_LOW2=0;
if p2=1 then CI_HIGH2=1;
if p2 ne 0 then CI_LOW2=round((1-betainv(.975,(total-col3+1),col3)),.0001);
if p2 ne 1 then CI_HIGH2=round((1-betainv(.025,(total-col3),col3+1)),.0001);

if p3=0 then CI_LOW3=0;
if p3=1 then CI_HIGH3=1;
if p3 ne 0 then CI_LOW3=round((1-betainv(.975,(total-col4+1),col4)),.0001);
if p3 ne 1 then CI_HIGH3=round((1-betainv(.025,(total-col4),col4+1)),.0001);

if p4=0 then CI_LOW4=0;
if p4=1 then CI_HIGH4=1;
if p4 ne 0 then CI_LOW4=round((1-betainv(.975,(total-col5+1),col5)),.0001);
if p4 ne 1 then CI_HIGH4=round((1-betainv(.025,(total-col5),col5+1)),.0001);

if p5=0 then CI_LOW5=0;
if p5=1 then CI_HIGH5=1;
if p5 ne 0 then CI_LOW5=round((1-betainv(.975,(total-col6+1),col6)),.0001);
if p5 ne 1 then CI_HIGH5=round((1-betainv(.025,(total-col6),col6+1)),.0001);
run;

/*ckd stage-combine all*/
data ckd_stage;
set survey_person_cut;
if stage_new=. then delete;
run;
proc freq  data=ckd_stage ;
table ckd/nopercent nocol out=A;
run;
proc transpose data=A out=B;
var count;
run;
data C;
set B;
total =COL1+COL2;
drop _name_ _label_;
run;
data D;
set C;
p=round ((col2/total),.0001);
if p=0 then CI_LOW=0;
if p=1 then CI_HIGH=1;
if p ne 0 then CI_LOW=round((1-betainv(.975,(total-col2+1),col2)),.0001);
if p ne 1 then CI_HIGH=round((1-betainv(.025,(total-col2),col2+1)),.0001);
run;


/*ckd stage-combine all*/
data ckd_stage;
set survey_person_cut;
if stage_new=. then delete;
run;
proc freq  data=ckd_stage ;
table urban*ckd/nopercent nocol out=A;
run;
proc transpose data=A out=B;
var count;
run;
data C;
set B;
total1=COL1+COL2;
total2=COL3+COL4;
drop _name_ _label_;
run;
data D;
set C;
p1=round((col2/total1),.0001);
p2=round((col4/total2),.0001);

if p1=0 then CI_LOW1=0;
if p1=1 then CI_HIGH1=1;
if p1 ne 0 then CI_LOW1=round((1-betainv(.975,(total1-col2+1),col2)),.0001);
if p1 ne 1 then CI_HIGH1=round((1-betainv(.025,(total1-col2),col2+1)),.0001);

if p2=0 then CI_LOW2=0;
if p2=1 then CI_HIGH2=1;
if p2 ne 0 then CI_LOW2=round((1-betainv(.975,(total2-col4+1),col4)),.0001);
if p2 ne 1 then CI_HIGH2=round((1-betainv(.025,(total2-col4),col4+1)),.0001);
run;

PROC IMPORT OUT= WORK.twnpop2018 
            DATAFILE= "C:\Users\Lu\Dropbox\2019_1_Kidney\#paper 1, disparity\data\TWNpopulation2018.csv" 
            DBMS=CSV REPLACE;
     GETNAMES=YES;
     DATAROW=2; 
RUN;
/*total*/
PROC FREQ DATA=Survey_person_cut;
table ckd*agegroup/out=case;
run;
PROC FREQ DATA=Survey_person_cut;
table agegroup/out=total;
run;
data case2;
set case;
if ckd=1;
drop ckd percent;
rename count=case;
run;
data total2;
set total;
rename count=total;
drop percent;
run;
data study_data;
merge case2 total2;
by agegroup;
run;
data Twnpop2018_drop20;
set Twnpop2018;
if agegroup=20 then delete;
run;

ods table STDRATE=EX_STDRATE; /*Store results in dataset if needed*/
proc stdrate data=study_data  /*Specify data that contains events and population*/
                  refdata=Twnpop2018_drop20 /*Specify dataset that contains reference population*/
                  method=direct  /*Specify the method of standardizaton*/
                  stat=rate (mult=100000) /*Specify that the stat of interest is Rate(vs Risk) and per 100,000 population*/
                  CL=Normal /*Specify the type of CI required - Gamma, lognormal, none, normal, poisson*/
                  ;
 

      population  event=case total=total; /*Specify variables from event data*/
      reference total=N; /*Specify the population variable from the reference data*/
      strata agegroup; /*Specify the category (ie age group)*/
run;

/*urban and rural*/
PROC FREQ DATA=Survey_person_cut;
table urban*ckd*agegroup/out=case_byloc;
run;
data case_urban;
set case_byloc;
if urban=1;
if ckd=1;
drop urban ckd percent;
rename count=case;
run;
data case_rural;
set case_byloc;
if urban=0;
if ckd=1;
drop urban ckd percent;
rename count=case;
run;
PROC FREQ DATA=Survey_person_cut;
table urban*agegroup/out=totalbyloc;
run;
data total_rural;
set totalbyloc;
if urban=0;
rename count=total;
drop urban percent;
run;

data total_urban;
set totalbyloc;
if urban=1;
rename count=total;
drop urban percent;
run;

data study_data_urban;
merge case_urban total_urban;
by agegroup;
if case=. then case=0;
run;
data study_data_rural;
merge case_rural total_rural;
by agegroup;
if case=. then case=0;
run;

data Twnpop2018_drop1920;
set Twnpop2018;
if agegroup=20 or agegroup=19 then delete;
run;


ods table STDRATE=EX_STDRATE_rural; /*Store results in dataset if needed*/
proc stdrate data=study_data_rural  /*Specify data that contains events and population*/
                  refdata=Twnpop2018_drop20 /*Specify dataset that contains reference population*/
                  method=direct  /*Specify the method of standardizaton*/
                  stat=rate (mult=100000) /*Specify that the stat of interest is Rate(vs Risk) and per 100,000 population*/
                  CL=Normal /*Specify the type of CI required - Gamma, lognormal, none, normal, poisson*/
                  ;
 

      population  event=case total=total; /*Specify variables from event data*/
      reference total=N; /*Specify the population variable from the reference data*/
      strata agegroup; /*Specify the category (ie age group)*/
run;

ods table STDRATE=EX_STDRATE_urban; /*Store results in dataset if needed*/
proc stdrate data=study_data_urban  /*Specify data that contains events and population*/
                  refdata=Twnpop2018_drop20 /*Specify dataset that contains reference population*/
                  method=direct  /*Specify the method of standardizaton*/
                  stat=rate (mult=100000) /*Specify that the stat of interest is Rate(vs Risk) and per 100,000 population*/
                  CL=Normal /*Specify the type of CI required - Gamma, lognormal, none, normal, poisson*/
                  ;
 

      population  event=case total=total; /*Specify variables from event data*/
      reference total=N; /*Specify the population variable from the reference data*/
      strata agegroup; /*Specify the category (ie age group)*/
run;



/*ckd stage5*/
PROC FREQ DATA=Survey_person_cut;
table stage_new*agegroup/out=case_bystage;
run;
data case_5;
set case_bystage;
if stage_new=5;
drop stage_new percent;
rename count=case;
run;
PROC FREQ DATA=Survey_person_cut;
table agegroup/out=totalbystage;
run;
data total_stage5;
set totalbystage;
rename count=total;
drop  percent;
run;
data study_data_stage5;
merge case_5 total_stage5;
by agegroup;
if case=. then case=0;
run;

data Twnpop2018_drop20;
set Twnpop2018;
if agegroup=20 then delete;
run;

ods table STDRATE=EX_STDRATE_stage5; /*Store results in dataset if needed*/
proc stdrate data=study_data_stage5  /*Specify data that contains events and population*/
                  refdata=Twnpop2018_drop20 /*Specify dataset that contains reference population*/
                  method=direct  /*Specify the method of standardizaton*/
                  stat=rate (mult=100000) /*Specify that the stat of interest is Rate(vs Risk) and per 100,000 population*/
                  CL=Normal /*Specify the type of CI required - Gamma, lognormal, none, normal, poisson*/
                  ;
 

      population  event=case total=total; /*Specify variables from event data*/
      reference total=N; /*Specify the population variable from the reference data*/
      strata agegroup; /*Specify the category (ie age group)*/
run;

/*ckd stage4*/
data case_4;
set case_bystage;
if stage_new=4;
drop stage_new percent;
rename count=case;
run;
data study_data_stage4;
merge case_4 total_stage5;
by agegroup;
if case=. then case=0;
run;

ods table STDRATE=EX_STDRATE_stage4; /*Store results in dataset if needed*/
proc stdrate data=study_data_stage4  /*Specify data that contains events and population*/
                  refdata=Twnpop2018_drop20 /*Specify dataset that contains reference population*/
                  method=direct  /*Specify the method of standardizaton*/
                  stat=rate (mult=100000) /*Specify that the stat of interest is Rate(vs Risk) and per 100,000 population*/
                  CL=Normal /*Specify the type of CI required - Gamma, lognormal, none, normal, poisson*/
                  ;
 

      population  event=case total=total; /*Specify variables from event data*/
      reference total=N; /*Specify the population variable from the reference data*/
      strata agegroup; /*Specify the category (ie age group)*/
run;

/*ckd stage3*/
data case_3;
set case_bystage;
if stage_new=3;
drop stage_new percent;
rename count=case;
run;
data study_data_stage3;
merge case_3 total_stage5;
by agegroup;
if case=. then case=0;
run;

ods table STDRATE=EX_STDRATE_stage3; /*Store results in dataset if needed*/
proc stdrate data=study_data_stage3  /*Specify data that contains events and population*/
                  refdata=Twnpop2018_drop20 /*Specify dataset that contains reference population*/
                  method=direct  /*Specify the method of standardizaton*/
                  stat=rate (mult=100000) /*Specify that the stat of interest is Rate(vs Risk) and per 100,000 population*/
                  CL=Normal /*Specify the type of CI required - Gamma, lognormal, none, normal, poisson*/
                  ;
 

      population  event=case total=total; /*Specify variables from event data*/
      reference total=N; /*Specify the population variable from the reference data*/
      strata agegroup; /*Specify the category (ie age group)*/
run;

data case_2;
set case_bystage;
if stage_new=2;
drop stage_new percent;
rename count=case;
run;
data study_data_stage2;
merge case_2 total_stage5;
by agegroup;
if case=. then case=0;
run;

ods table STDRATE=EX_STDRATE_stage2; /*Store results in dataset if needed*/
proc stdrate data=study_data_stage2  /*Specify data that contains events and population*/
                  refdata=Twnpop2018_drop20 /*Specify dataset that contains reference population*/
                  method=direct  /*Specify the method of standardizaton*/
                  stat=rate (mult=100000) /*Specify that the stat of interest is Rate(vs Risk) and per 100,000 population*/
                  CL=Normal /*Specify the type of CI required - Gamma, lognormal, none, normal, poisson*/
                  ;
 

      population  event=case total=total; /*Specify variables from event data*/
      reference total=N; /*Specify the population variable from the reference data*/
      strata agegroup; /*Specify the category (ie age group)*/
run;


data case_1;
set case_bystage;
if stage_new=1;
drop stage_new percent;
rename count=case;
run;
data study_data_stage1;
merge case_1 total_stage5;
by agegroup;
if case=. then case=0;
run;

ods table STDRATE=EX_STDRATE_stage1; /*Store results in dataset if needed*/
proc stdrate data=study_data_stage1  /*Specify data that contains events and population*/
                  refdata=Twnpop2018_drop20 /*Specify dataset that contains reference population*/
                  method=direct  /*Specify the method of standardizaton*/
                  stat=rate (mult=100000) /*Specify that the stat of interest is Rate(vs Risk) and per 100,000 population*/
                  CL=Normal /*Specify the type of CI required - Gamma, lognormal, none, normal, poisson*/
                  ;
 

      population  event=case total=total; /*Specify variables from event data*/
      reference total=N; /*Specify the population variable from the reference data*/
      strata agegroup; /*Specify the category (ie age group)*/
run;
data total_urban;
set totalbyloc;
if urban=1;
rename count=total;
drop urban percent;
run;

data study_data_urban;
merge case_urban total_urban;
by agegroup;
if case=. then case=0;
run;
data study_data_rural;
merge case_rural total_rural;
by agegroup;
if case=. then case=0;
run;

data Twnpop2018_drop1920;
set Twnpop2018;
if agegroup=20 or agegroup=19 then delete;
run;


ods table STDRATE=EX_STDRATE_rural; /*Store results in dataset if needed*/
proc stdrate data=study_data_rural  /*Specify data that contains events and population*/
                  refdata=Twnpop2018_drop20 /*Specify dataset that contains reference population*/
                  method=direct  /*Specify the method of standardizaton*/
                  stat=rate (mult=100000) /*Specify that the stat of interest is Rate(vs Risk) and per 100,000 population*/
                  CL=Normal /*Specify the type of CI required - Gamma, lognormal, none, normal, poisson*/
                  ;
 

      population  event=case total=total; /*Specify variables from event data*/
      reference total=N; /*Specify the population variable from the reference data*/
      strata agegroup; /*Specify the category (ie age group)*/
run;

ods table STDRATE=EX_STDRATE_urban; /*Store results in dataset if needed*/
proc stdrate data=study_data_urban  /*Specify data that contains events and population*/
                  refdata=Twnpop2018_drop20 /*Specify dataset that contains reference population*/
                  method=direct  /*Specify the method of standardizaton*/
                  stat=rate (mult=100000) /*Specify that the stat of interest is Rate(vs Risk) and per 100,000 population*/
                  CL=Normal /*Specify the type of CI required - Gamma, lognormal, none, normal, poisson*/
                  ;
 

      population  event=case total=total; /*Specify variables from event data*/
      reference total=N; /*Specify the population variable from the reference data*/
      strata agegroup; /*Specify the category (ie age group)*/
run;



/*urban and rural*** stage_ new*/
data case_urban_stage1;
set case_bylocstage;
if urban=1;
if stage_new=1;
drop urban stage_new percent;
rename count=case;
run;
data total_urban;
set totalbyloc;
if urban=1;
rename count=total;
drop urban percent;
run;
data study_data_urban_stage1;
merge case_urban_stage1 total_urban;
by agegroup;
if case=. then case=0;
run;
data case_rural_stage1;
set case_bylocstage;
if urban=0;
if stage_new=1;
drop urban stage_new percent;
rename count=case;
run;
data study_data_rural_stage1;
merge case_rural_stage1 total_rural;
by agegroup;
if case=. then case=0;
run;


data Twnpop2018_drop1920;
set Twnpop2018;
if agegroup=20 or agegroup=19 then delete;
run;


ods table STDRATE=EX_STDRATE_urban_stage1; /*Store results in dataset if needed*/
proc stdrate data=study_data_urban_stage1  /*Specify data that contains events and population*/
                  refdata=Twnpop2018_drop20 /*Specify dataset that contains reference population*/
                  method=direct  /*Specify the method of standardizaton*/
                  stat=rate (mult=100000) /*Specify that the stat of interest is Rate(vs Risk) and per 100,000 population*/
                  CL=Normal /*Specify the type of CI required - Gamma, lognormal, none, normal, poisson*/
                  ;
 

      population  event=case total=total; /*Specify variables from event data*/
      reference total=N; /*Specify the population variable from the reference data*/
      strata agegroup; /*Specify the category (ie age group)*/
run;

ods table STDRATE=EX_STDRATE_rural_stage1; /*Store results in dataset if needed*/
proc stdrate data=study_data_rural_stage1  /*Specify data that contains events and population*/
                  refdata=Twnpop2018_drop20 /*Specify dataset that contains reference population*/
                  method=direct  /*Specify the method of standardizaton*/
                  stat=rate (mult=100000) /*Specify that the stat of interest is Rate(vs Risk) and per 100,000 population*/
                  CL=Normal /*Specify the type of CI required - Gamma, lognormal, none, normal, poisson*/
                  ;
 

      population  event=case total=total; /*Specify variables from event data*/
      reference total=N; /*Specify the population variable from the reference data*/
      strata agegroup; /*Specify the category (ie age group)*/
run;


/*urban and rural*** stage_ new*/
data case_urban_stage2;
set case_bylocstage;
if urban=1;
if stage_new=2;
drop urban stage_new percent;
rename count=case;
run;
data total_urban;
set totalbyloc;
if urban=1;
rename count=total;
drop urban percent;
run;
data study_data_urban_stage2;
merge case_urban_stage2 total_urban;
by agegroup;
if case=. then case=0;
run;
data case_rural_stage2;
set case_bylocstage;
if urban=0;
if stage_new=2;
drop urban stage_new percent;
rename count=case;
run;
data study_data_rural_stage2;
merge case_rural_stage2 total_rural;
by agegroup;
if case=. then case=0;
run;


data Twnpop2018_drop1920;
set Twnpop2018;
if agegroup=20 or agegroup=19 then delete;
run;


ods table STDRATE=EX_STDRATE_urban_stage2; /*Store results in dataset if needed*/
proc stdrate data=study_data_urban_stage2  /*Specify data that contains events and population*/
                  refdata=Twnpop2018_drop20 /*Specify dataset that contains reference population*/
                  method=direct  /*Specify the method of standardizaton*/
                  stat=rate (mult=100000) /*Specify that the stat of interest is Rate(vs Risk) and per 100,000 population*/
                  CL=Normal /*Specify the type of CI required - Gamma, lognormal, none, normal, poisson*/
                  ;
 

      population  event=case total=total; /*Specify variables from event data*/
      reference total=N; /*Specify the population variable from the reference data*/
      strata agegroup; /*Specify the category (ie age group)*/
run;

ods table STDRATE=EX_STDRATE_rural_stage2; /*Store results in dataset if needed*/
proc stdrate data=study_data_rural_stage2  /*Specify data that contains events and population*/
                  refdata=Twnpop2018_drop20 /*Specify dataset that contains reference population*/
                  method=direct  /*Specify the method of standardizaton*/
                  stat=rate (mult=100000) /*Specify that the stat of interest is Rate(vs Risk) and per 100,000 population*/
                  CL=Normal /*Specify the type of CI required - Gamma, lognormal, none, normal, poisson*/
                  ;
 

      population  event=case total=total; /*Specify variables from event data*/
      reference total=N; /*Specify the population variable from the reference data*/
      strata agegroup; /*Specify the category (ie age group)*/
run;


/*urban and rural*** stage_ new*/
data case_urban_stage3;
set case_bylocstage;
if urban=1;
if stage_new=3;
drop urban stage_new percent;
rename count=case;
run;
data total_urban;
set totalbyloc;
if urban=1;
rename count=total;
drop urban percent;
run;
data study_data_urban_stage3;
merge case_urban_stage3 total_urban;
by agegroup;
if case=. then case=0;
run;
data case_rural_stage3;
set case_bylocstage;
if urban=0;
if stage_new=3;
drop urban stage_new percent;
rename count=case;
run;
data study_data_rural_stage3;
merge case_rural_stage3 total_rural;
by agegroup;
if case=. then case=0;
run;


data Twnpop2018_drop1920;
set Twnpop2018;
if agegroup=20 or agegroup=19 then delete;
run;


ods table STDRATE=EX_STDRATE_urban_stage3; /*Store results in dataset if needed*/
proc stdrate data=study_data_urban_stage3  /*Specify data that contains events and population*/
                  refdata=Twnpop2018_drop20 /*Specify dataset that contains reference population*/
                  method=direct  /*Specify the method of standardizaton*/
                  stat=rate (mult=100000) /*Specify that the stat of interest is Rate(vs Risk) and per 100,000 population*/
                  CL=Normal /*Specify the type of CI required - Gamma, lognormal, none, normal, poisson*/
                  ;
 

      population  event=case total=total; /*Specify variables from event data*/
      reference total=N; /*Specify the population variable from the reference data*/
      strata agegroup; /*Specify the category (ie age group)*/
run;

ods table STDRATE=EX_STDRATE_rural_stage3; /*Store results in dataset if needed*/
proc stdrate data=study_data_rural_stage3  /*Specify data that contains events and population*/
                  refdata=Twnpop2018_drop20 /*Specify dataset that contains reference population*/
                  method=direct  /*Specify the method of standardizaton*/
                  stat=rate (mult=100000) /*Specify that the stat of interest is Rate(vs Risk) and per 100,000 population*/
                  CL=Normal /*Specify the type of CI required - Gamma, lognormal, none, normal, poisson*/
                  ;
 

      population  event=case total=total; /*Specify variables from event data*/
      reference total=N; /*Specify the population variable from the reference data*/
      strata agegroup; /*Specify the category (ie age group)*/
run;


/*urban and rural*** stage_ new*/
data case_urban_stage4;
set case_bylocstage;
if urban=1;
if stage_new=4;
drop urban stage_new percent;
rename count=case;
run;
data total_urban;
set totalbyloc;
if urban=1;
rename count=total;
drop urban percent;
run;
data study_data_urban_stage4;
merge case_urban_stage4 total_urban;
by agegroup;
if case=. then case=0;
run;
data case_rural_stage4;
set case_bylocstage;
if urban=0;
if stage_new=4;
drop urban stage_new percent;
rename count=case;
run;
data study_data_rural_stage4;
merge case_rural_stage4 total_rural;
by agegroup;
if case=. then case=0;
run;


data Twnpop2018_drop1920;
set Twnpop2018;
if agegroup=20 or agegroup=19 then delete;
run;


ods table STDRATE=EX_STDRATE_urban_stage4; /*Store results in dataset if needed*/
proc stdrate data=study_data_urban_stage4  /*Specify data that contains events and population*/
                  refdata=Twnpop2018_drop20 /*Specify dataset that contains reference population*/
                  method=direct  /*Specify the method of standardizaton*/
                  stat=rate (mult=100000) /*Specify that the stat of interest is Rate(vs Risk) and per 100,000 population*/
                  CL=Normal /*Specify the type of CI required - Gamma, lognormal, none, normal, poisson*/
                  ;
 

      population  event=case total=total; /*Specify variables from event data*/
      reference total=N; /*Specify the population variable from the reference data*/
      strata agegroup; /*Specify the category (ie age group)*/
run;

ods table STDRATE=EX_STDRATE_rural_stage4; /*Store results in dataset if needed*/
proc stdrate data=study_data_rural_stage4  /*Specify data that contains events and population*/
                  refdata=Twnpop2018_drop20 /*Specify dataset that contains reference population*/
                  method=direct  /*Specify the method of standardizaton*/
                  stat=rate (mult=100000) /*Specify that the stat of interest is Rate(vs Risk) and per 100,000 population*/
                  CL=Normal /*Specify the type of CI required - Gamma, lognormal, none, normal, poisson*/
                  ;
 

      population  event=case total=total; /*Specify variables from event data*/
      reference total=N; /*Specify the population variable from the reference data*/
      strata agegroup; /*Specify the category (ie age group)*/
run;


/*urban and rural*** stage_ new*/
data case_urban_stage5;
set case_bylocstage;
if urban=1;
if stage_new=5;
drop urban stage_new percent;
rename count=case;
run;
data total_urban;
set totalbyloc;
if urban=1;
rename count=total;
drop urban percent;
run;
data study_data_urban_stage5;
merge case_urban_stage5 total_urban;
by agegroup;
if case=. then case=0;
run;
data case_rural_stage5;
set case_bylocstage;
if urban=0;
if stage_new=5;
drop urban stage_new percent;
rename count=case;
run;
data study_data_rural_stage5;
merge case_rural_stage5 total_rural;
by agegroup;
if case=. then case=0;
run;
data Twnpop2018_drop1920;
set Twnpop2018;
if agegroup=20 or agegroup=19 then delete;
run;


ods table STDRATE=EX_STDRATE_urban_stage5; /*Store results in dataset if needed*/
proc stdrate data=study_data_urban_stage5  /*Specify data that contains events and population*/
                  refdata=Twnpop2018_drop20 /*Specify dataset that contains reference population*/
                  method=direct  /*Specify the method of standardizaton*/
                  stat=rate (mult=100000) /*Specify that the stat of interest is Rate(vs Risk) and per 100,000 population*/
                  CL=Normal /*Specify the type of CI required - Gamma, lognormal, none, normal, poisson*/
                  ;
 

      population  event=case total=total; /*Specify variables from event data*/
      reference total=N; /*Specify the population variable from the reference data*/
      strata agegroup; /*Specify the category (ie age group)*/
run;

ods table STDRATE=EX_STDRATE_rural_stage5; /*Store results in dataset if needed*/
proc stdrate data=study_data_rural_stage5  /*Specify data that contains events and population*/
                  refdata=Twnpop2018_drop20 /*Specify dataset that contains reference population*/
                  method=direct  /*Specify the method of standardizaton*/
                  stat=rate (mult=100000) /*Specify that the stat of interest is Rate(vs Risk) and per 100,000 population*/
                  CL=Normal /*Specify the type of CI required - Gamma, lognormal, none, normal, poisson*/
                  ;
 

      population  event=case total=total; /*Specify variables from event data*/
      reference total=N; /*Specify the population variable from the reference data*/
      strata agegroup; /*Specify the category (ie age group)*/
run;
/*Table 3. The adjusted odds ratio of CKD in relation to risk factors*/
proc logistic data=survey_person_cut desc;
class urban(ref='1'); 
model ckd=urban;
run;
proc logistic data=survey_person_cut desc;
class urban(ref='1') gender(ref='0') edu(ref='0'); 
model ckd=urban age gender edu NoDRmed3;
run;
proc logistic data=survey_person_cut desc;
class urban(ref='1') gender(ref='0') edu(ref='0') smk(ref='0') betelnut(ref='0') alcohol(ref='0'); 
model ckd=urban age gender edu smk betelnut alcohol NoDRmed3;
run;
proc logistic data=survey_person_cut desc;
class urban(ref='1') gender(ref='0') edu(ref='0') smk(ref='0') betelnut(ref='0') alcohol(ref='0') waist_group(ref='0') bmi_group(ref='1'); 
model ckd=urban age gender edu smk betelnut alcohol waist_group bmi_group NoDRmed3;
run;
proc logistic data=survey_person_cut desc;
class urban(ref='1') gender(ref='0') edu(ref='0') smk(ref='0') betelnut(ref='0') alcohol(ref='0') waist_group(ref='0') bmi_group(ref='1') DM_prev(ref='0') Gout_prev(ref='0') Hypertension_prev(ref='0') Lipid_prev(ref='0'); 
model ckd=urban age gender edu smk betelnut alcohol waist_group bmi_group DM_prev Gout_prev Hypertension_prev Lipid_prev NoDRmed3;
run;


data survey_person_cut_young;set survey_person_cut;if age_gp=0;run;
data survey_person_cut_old;set survey_person_cut;if age_gp=1;run;
data survey_person_cut_male;set survey_person_cut;if gender=1;run;
data survey_person_cut_female;set survey_person_cut;if gender=0;run;
data survey_person_cut_edu;set survey_person_cut;if edu_gp=1;run;
data survey_person_cut_noedu;set survey_person_cut;if edu_gp=0;run;
data survey_person_cut_dm;set survey_person_cut;if DM_prev=1;run;
data survey_person_cut_nondm;set survey_person_cut;if DM_prev=0;run;
data survey_person_cut_htn;set survey_person_cut;if Hypertension_prev=1;run;
data survey_person_cut_nonhtn;set survey_person_cut;if Hypertension_prev=0;run;
data survey_person_cut_htn;set survey_person_cut;if Hypertension_prev=1;run;
data survey_person_cut_nonhtn;set survey_person_cut;if Hypertension_prev=0;run;
data survey_person_cut_gout;set survey_person_cut;if Gout_prev=1;run;
data survey_person_cut_nongout;set survey_person_cut;if Gout_prev=0;run;
data survey_person_cut_smk;set survey_person_cut;if smk=1;run;
data survey_person_cut_nonsmk;set survey_person_cut;if smk=0;run;
data survey_person_cut_alc;set survey_person_cut;if alcohol=1;run;
data survey_person_cut_nonalc;set survey_person_cut;if alcohol=0;run;
data survey_person_cut_bet;set survey_person_cut;if betelnut=1;run;
data survey_person_cut_nonbet;set survey_person_cut;if betelnut=0;run;

/*mediator*/
proc causalmed data=survey_person_cut;
class Program(descending) Gender SES Introversion;
model ckd = urban DM_prev urban*DM_prev;
mediator DM_prev = urban;
covar smk alcohol betelnut age gender edu_gp Gout_prev Hypertension_prev ;
run;

proc causalmed data=Cognitive;
   model    CogPerform  = Encourage Motivation;
   mediator Motivation  = Encourage;
   covar FamSize SocStatus;
run;



proc logistic data=survey_person_cut desc;
class edu_gp(ref='1');
model urban=age edu_gp  alcohol betelnut  DM_prev Gout_prev Hypertension_prev;
run;

/*****Table 3. Final model 20220126******/
proc logistic data=survey_person_cut desc;
class urban(ref='1'); 
model ckd=urban ;
run;
proc logistic data=survey_person_cut desc;
class urban(ref='1') edu_gp(ref='0') gender(ref='0'); 
model ckd=urban  age gender edu_gp  ;
run;
proc logistic data=survey_person_cut desc;
class urban(ref='1') edu_gp(ref='0') gender(ref='0'); 
model ckd=urban  age gender edu_gp ;
run;
proc logistic data=survey_person_cut desc;
class urban(ref='1') edu_gp(ref='0') gender(ref='0'); 
model ckd=urban  age gender edu_gp DM_prev  Gout_prev Hypertension_prev;
run;
proc logistic data=survey_person_cut desc;
class urban(ref='1') edu_gp(ref='0') gender(ref='0'); 
model ckd=urban  age gender edu_gp DM_prev  Gout_prev Hypertension_prev   obesity;
run;
proc logistic data=survey_person_cut desc;
class urban(ref='1') edu_gp(ref='0') gender(ref='0'); 
model ckd=urban  age gender edu_gp DM_prev  Gout_prev Hypertension_prev   obesity china_med NoDRmed2;
run;

proc logistic data=survey_person_cut desc;
class urban(ref='1'); 
model ckd=urban age gender edu_gp alcohol smk betelnut DM_prev Gout_prev Hypertension_prev;
run;
proc logistic data=survey_person_cut desc;
class urban(ref='1'); 
model ckd=urban age gender ;
run;
proc logistic data=survey_person_cut desc;
class urban(ref='1'); 
model ckd=urban age gender edu_gp;
run;
proc logistic data=survey_person_cut desc;
class urban(ref='1'); 
model ckd=urban age gender  alcohol smk betelnut ;
run;
proc logistic data=survey_person_cut desc;
class urban(ref='1'); 
model ckd=urban alcohol smk betelnut ;
run;
proc logistic data=survey_person_cut desc;
model ckd=  smk betelnut DM_prev Gout_prev Hypertension_prev; ;
run;
proc logistic data=survey_person_cut desc;
class urban(ref='1'); 
model ckd=urban age gender edu_gp alcohol smk betelnut ;
run;
proc logistic data=survey_person_cut desc;
class urban(ref='1'); 
model ckd=urban age gender edu_gp alcohol smk betelnut DM_prev Gout_prev Hypertension_prev;
run;


proc corr data=survey_person_cut;
var urban alcohol smk betelnut;
run;
proc freq data=survey_person_cut;
table alcohol*urban*ckd/cmh ;
run;
proc freq data=survey_person_cut;
table smk*urban*ckd/cmh ;
run;


proc freq data=survey_person_cut;
table urban*smk*betelnut*alcohol/cmh ;
run;
proc logistic data=survey_person_cut_male desc;class urban(ref='1'); 
model ckd=urban;
run;
proc logistic data=survey_person_cut_female desc;class urban(ref='1'); 
model ckd=urban;
run;


proc freq data=survey_person_cut;
table age_gp*urban*ckd/cmh ;
run;
proc logistic data=survey_person_cut_young desc;class urban(ref='1'); 
model ckd=urban;
run;
proc logistic data=survey_person_cut_old desc;class urban(ref='1'); 
model ckd=urban;
run;


proc freq data=survey_person_cut;
table urban*aware/cmh;
run;
proc freq data=survey_person_cut;
table urban*late_ckd*aware;
run;
proc freq data=survey_person_cut;
table late_ckd*aware;
run;
proc freq data=survey_person_cut;
table urban*aware/cmh ;
run;
proc freq data=survey_person_cut;
table urban*Proteinuria_group/cmh ;
run;
proc freq data=survey_person_cut;
table urban*egfr_group/cmh ;
run;
proc freq data=survey_person_cut;
table urban*ckd/cmh ;
run;
proc logistic data=survey_person_cut_edu desc;class urban(ref='1');
model ckd=urban ;
run;
proc logistic data=survey_person_cut_noedu desc;class urban(ref='1');
model ckd=urban ;
run;



proc freq data=survey_person_cut;
table DM_prev*urban*ckd/cmh ;
run;
proc logistic data=survey_person_cut_dm desc;class urban(ref='1'); 
model ckd=urban;
run;
proc logistic data=survey_person_cut_nondm desc;class urban(ref='1') ; 
model ckd=urban;
run;


proc freq data=survey_person_cut;
table Hypertension_prev*urban*ckd/cmh ;
run;
proc logistic data=survey_person_cut_htn desc;class urban(ref='1') ;
model ckd=urban ;
run;
proc logistic data=survey_person_cut_nonhtn desc;class urban(ref='1');
model ckd=urban ;
run;


proc freq data=survey_person_cut;
table Gout_prev*urban*ckd/cmh ;
run;
proc logistic data=survey_person_cut_gout desc;class urban(ref='1') gender(ref='0'); 
model ckd=urban;
run;
proc logistic data=survey_person_cut_nongout desc;class urban(ref='1') gender(ref='0'); 
model ckd=urban;
run;



proc freq data=survey_person_cut;
table smk*urban*ckd/cmh ;
run;
proc logistic data=survey_person_cut_smk desc;class urban(ref='1') ;
model ckd=urban ;
run;
proc logistic data=survey_person_cut_nonsmk desc;class urban(ref='1');
model ckd=urban ;
run;

proc freq data=survey_person_cut;
table alcohol*urban*ckd/cmh ;
run;
proc logistic data=survey_person_cut_alc desc;class urban(ref='1') ; 
model ckd=urban ;
run;
proc logistic data=survey_person_cut_nonalc desc;class urban(ref='1') ; 
model ckd=urban;
run;

proc freq data=survey_person_cut;
table betelnut*urban*ckd/cmh ;
run;
proc logistic data=survey_person_cut_bet desc;class urban(ref='1') ; 
model ckd=urban ;
run;
proc logistic data=survey_person_cut_nonbet desc;class urban(ref='1') ; 
model ckd=urban ;
run;

proc logistic data=survey_person_cut desc;class gender(ref='0') DM_prev(ref='0') Hypertension_prev(ref='0') Gout_prev(ref='0')  obesity(ref='0')   urban(ref='1'); 
model ckd=age gender  urban DM_prev Hypertension_prev Gout_prev  obesity;
run;
proc logistic data=survey_person_cut desc;class  spring_water(ref='0') gender(ref='0') DM_prev(ref='0') Hypertension_prev(ref='0') Gout_prev(ref='0')  obesity(ref='0')   urban(ref='1'); 
model ckd=age gender  urban DM_prev Hypertension_prev Gout_prev  obesity spring_water;
run;
proc logistic data=survey_person_cut desc;class  alcohol(ref='0'); 
model ckd=age ;
run;
proc corr data=survey_person_cut;
var age gender edu_gp urban DM_prev Hypertension_prev Gout_prev obesity smk alcohol betelnut;
run;


data male;set survey_person_cut;if gender=1;run;
data female;set survey_person_cut;if gender=0;run;
proc logistic data=male desc;
class  edu_gp(ref='1') DM_prev(ref='0') Hypertension_prev(ref='0') Gout_prev(ref='0')  bmi_group(ref='1') smk(ref='0') alcohol(ref='0') betelnut(ref='1')  urban(ref='1'); 
model ckd=age gender  edu_gp urban DM_prev Hypertension_prev Gout_prev smk alcohol betelnut;
run;
proc logistic data=female desc;
class edu_gp(ref='1') DM_prev(ref='0') Hypertension_prev(ref='0') Gout_prev(ref='0')  bmi_group(ref='1') smk(ref='0') alcohol(ref='0') betelnut(ref='1')  urban(ref='1'); 
model ckd=age gender edu_gp urban DM_prev Hypertension_prev Gout_prev smk alcohol betelnut;
run;

data dm;set survey_person_cut;if DM_prev=1;run;
data nondm;set survey_person_cut;if DM_prev=0;run;
proc logistic data=dm desc;
class gender(ref='0') edu_gp(ref='1') Hypertension_prev(ref='0') Gout_prev(ref='0')  bmi_group(ref='1') smk(ref='0') alcohol(ref='0') betelnut(ref='1')  urban(ref='1'); 
model ckd=age gender  edu_gp urban Hypertension_prev Gout_prev smk alcohol betelnut;
run;
proc logistic data=nondm desc;
class gender(ref='0') edu_gp(ref='1') Hypertension_prev(ref='0') Gout_prev(ref='0')  bmi_group(ref='1') smk(ref='0') alcohol(ref='0') betelnut(ref='1')  urban(ref='1'); 
model ckd=age gender edu_gp urban Hypertension_prev Gout_prev smk alcohol betelnut;
run;

data htn;set survey_person_cut;if Hypertension_prev=1;run;
data nonhtn;set survey_person_cut;if Hypertension_prev=0;run;
proc logistic data=htn desc;
class gender(ref='0') edu_gp(ref='1') DM_prev(ref='0') Gout_prev(ref='0')  bmi_group(ref='1') smk(ref='0') alcohol(ref='0') betelnut(ref='1')  urban(ref='1'); 
model ckd=age gender  edu_gp urban DM_prev Gout_prev smk alcohol betelnut;
run;
proc logistic data=nonhtn desc;
class gender(ref='0') edu_gp(ref='1') DM_prev(ref='0') Gout_prev(ref='0')  bmi_group(ref='1') smk(ref='0') alcohol(ref='0') betelnut(ref='1')  urban(ref='1'); 
model ckd=age gender edu_gp urban DM_prev Gout_prev smk alcohol betelnut;
run;

data edu;set survey_person_cut;if edu_gp=1;run;
data nonedu;set survey_person_cut;if edu_gp=0;run;
proc logistic data=edu desc;class gender(ref='0') DM_prev(ref='0')  Hypertension_prev(ref='0') Gout_prev(ref='0')  bmi_group(ref='1') smk(ref='0') alcohol(ref='0') betelnut(ref='1')  urban(ref='1'); 
model ckd=age gender urban DM_prev Hypertension_prev Gout_prev smk alcohol betelnut;
run;
proc logistic data=nonedu desc;class gender(ref='0') edu_gp(ref='1') DM_prev(ref='0')  Hypertension_prev(ref='0') Gout_prev(ref='0')  bmi_group(ref='1') smk(ref='0') alcohol(ref='0') betelnut(ref='1')  urban(ref='1'); 
model ckd=age gender urban DM_prev Hypertension_prev Gout_prev smk alcohol betelnut;
run;






proc corr data=survey_person_cut;
var age gender  DM_prev Hypertension_prev Gout_prev smk alcohol betelnut;
run;




proc freq data=survey_person_cut;
table urban;
run;
proc ttest data=survey_person_cut;
class urban;
var age;
run;

proc ttest data=survey_person_cut;
class urban;
var edu;
run;
proc ttest data=survey_person_cut;
class urban;
var bmi_new;
run;
proc ttest data=survey_person_cut;
class urban;
var waist_new;
run;
proc freq data=survey_person_cut;
table urban*(waist_group)/nopercent nocol chisq;
run;
proc freq data=survey_person_cut;
table urban*(gender smk alcohol betelnut Painkiller)/nopercent nocol chisq;
run;
proc freq data=survey_person_cut;
table urban*(China_med DM_prev Gout_prev Lipid_prev Hypertension_prev)/nopercent nocol chisq;
run;
proc freq data=survey_person_cut;
table urban*( DM_prev Gout_prev Lipid_prev Hypertension_prev)/nopercent nocol chisq;
run;

proc freq data=survey_person_cut;
table urban*(ckd bmi_group bp_group glucose_uncontrolled gout_uncontrolled lipid_uncontrolled)/nopercent nocol chisq;
run;

proc freq data=survey_person_cut;
table urban*(bmi_group)*gender/nopercent norow chisq;
run;


proc freq data=survey_person_cut;
table urban*bad3/nopercent nocol chisq;
run;
proc freq data=survey_person_cut;
table urban*Educ_level/nopercent nocol chisq;
run;
proc freq data=survey_person_cut;
table urban*ckd*P_Kidneydisease;
run;

proc logistic data=survey_person_cut desc;
class gender(ref='0') urban(ref='1');
model ckd=age gender urban;
run;
proc logistic data=survey_person_cut desc;
class gender(ref='0') urban(ref='1');
model ckd=age gender urban;
run;
proc logistic data=survey_person_cut desc;
class gender(ref='0') urban(ref='1');
model ckd=age gender urban;
run;
proc logistic data=survey_person_cut desc;
class gender(ref='0') urban(ref='1');
model ckd=age gender urban;
run;

proc logistic data=survey_person_cut desc;
class gender(ref='0') urban(ref='1');
model bp_group=age gender urban;
run;
proc logistic data=survey_person_cut desc;
class gender(ref='0') urban(ref='1');
model glucose_uncontrolled=age gender urban;
run;
proc logistic data=survey_person_cut desc;
class gender(ref='0') urban(ref='1');
model gout_uncontrolled=age gender urban;
run;
proc logistic data=survey_person_cut desc;
class gender(ref='0') urban(ref='1');
model lipid_uncontrolled=age gender urban;
run;

proc freq  data=survey_person_cut;
table  ckd_stage*urban;
run;
ods graphics on;
proc univariate data=survey_person_cut ;
where ckd=1;
var egfr;
class urban;
histogram egfr;
run;
proc univariate data=survey_person_cut ;
var egfr;
class urban;
histogram egfr;
run;

/*urban and rural*/
proc freq data=survey_person_cut;
table urban*edu_gp/ nocol chisq;
run;

proc freq data=survey_person_cut;
table urban*obesity/ nocol chisq;
run;
proc freq data=survey_person_cut;
table ckd*(smk betelnut alcohol obesity waist_group  dm_prev hypertension_prev gout_prev Lipid_prev)/nocol nopercent;
run;
data urban;
set survey_person_cut;
if urban=1;
run;
data rural;
set survey_person_cut;
if urban=0;
run;
proc freq data=urban;
table ckd*(smk betelnut alcohol obesity waist_group  dm_prev hypertension_prev gout_prev Lipid_prev)/nocol nopercent;
run;
proc freq data=rural;
table ckd*(smk betelnut alcohol obesity waist_group  dm_prev hypertension_prev gout_prev Lipid_prev)/nocol nopercent;
run;
proc logistic data=urban desc;
class smk(ref='0') ;
model ckd=age smk ;
run;
proc logistic data=urban desc;
class betelnut(ref='0') ;
model ckd=age betelnut ;
run;
proc logistic data=urban desc;
class alcohol(ref='0') ;
model ckd=age gender alcohol ;
run;
proc logistic data=urban desc;
class overweight(ref='0') ;
model ckd=age overweight ;
run;
proc logistic data=urban desc;
class waist_group(ref='0') ;
model ckd=age waist_group ;
run;
proc logistic data=urban desc;
class dm_prev(ref='0') ;
model ckd=age dm_prev ;
run;
proc logistic data=urban desc;
class hypertension_prev(ref='0') ;
model ckd=age hypertension_prev ;
run;
proc logistic data=urban desc;
class gout_prev(ref='0') ;
model ckd=age gout_prev ;
run;
proc logistic data=urban desc;
class Lipid_prev(ref='0') ;
model ckd=age Lipid_prev ;
run;
/*rural*/
proc logistic data=rural desc;
class smk(ref='0') ;
model ckd=age smk ;
run;
proc logistic data=rural desc;
class betelnut(ref='0') ;
model ckd=age betelnut ;
run;
proc logistic data=rural desc;
class alcohol(ref='0') ;
model ckd=age alcohol ;
run;
proc logistic data=rural desc;
class overweight(ref='0') ;
model ckd=age overweight ;
run;
proc logistic data=rural desc;
class waist_group(ref='0') ;
model ckd=age waist_group ;
run;
proc logistic data=rural desc;
class dm_prev(ref='0') ;
model ckd=age dm_prev ;
run;
proc logistic data=rural desc;
class hypertension_prev(ref='0') ;
model ckd=age hypertension_prev ;
run;
proc logistic data=rural desc;
class gout_prev(ref='0') ;
model ckd=age gout_prev ;
run;
proc logistic data=rural desc;
class Lipid_prev(ref='0') sex(ref='0') ;
model ckd=age sex Lipid_prev ;
run;
/*bmi_group smk  betelnut alcohol china_med waist_gp DM_prev Gout_prev Lipid_prev Hypertension_prev*/

proc freq data=urban;
table ckd*Educ_level/nopercent norow;
run;
proc freq data=rural;
table ckd*Educ_level/nopercent norow;
run;

proc freq data=urban;
table DM_prev/nopercent norow;
run;
proc freq data=rural;
table DM_prev/nopercent norow;
run;

proc logistic data=rural desc;
class gender(ref='0') bmi_group(ref='1') ;
model ckd=age gender bmi_group smk  betelnut alcohol china_med waist_gp DM_prev Gout_prev Lipid_prev Hypertension_prev/include=2 selection=stepwise slentry=0.15 slstay=0.15 details lackfit;
run;
proc logistic data=rural desc;
class gender(ref='0') bmi_group(ref='1') ;
model ckd=age gender bmi_group smk DM_prev Gout_prev  Hypertension_prev;
run;
proc logistic data=urban desc;
class gender(ref='0') bmi_group(ref='1') ;
model ckd=age gender  bmi_group smk  betelnut alcohol china_med waist_gp DM_prev Gout_prev Lipid_prev Hypertension_prev/include=2 selection=stepwise slentry=0.15 slstay=0.15 details lackfi;
run;
proc logistic data=urban desc;
class gender(ref='0') bmi_group(ref='1');
model ckd=age gender bmi_group  DM_prev Gout_prev Hypertension_prev;
run;




/*urban 2*/

/*proc freq data=survey_person_cut;
table urban2*(ckd bmi_group bp_group glucose_uncontrolled gout_uncontrolled lipid_uncontrolled)/nopercent nocol;
run;

proc logistic data=survey_person_cut desc;
class gender(ref='0') urban2(ref='1');
model ckd=age gender urban2;
run;
proc logistic data=survey_person_cut desc;
class gender(ref='0') urban2(ref='1');
model bp_group=age gender urban2;
run;
proc logistic data=survey_person_cut desc;
class gender(ref='0') urban2(ref='1');
model glucose_uncontrolled=age gender urban2;
run;
proc logistic data=survey_person_cut desc;
class gender(ref='0') urban2(ref='1');
model gout_uncontrolled=age gender urban2;
run;
proc logistic data=survey_person_cut desc;
class gender(ref='0') urban2(ref='1');
model lipid_uncontrolled=age gender urban2;
run;*/
/***Compare MDRD and CKD-EPI***************************/
data ckd_stage;
set survey_person_cut;
if egfr_epi>=90 then epi=0;
else if 60<=egfr_epi<90 then epi=1;
else if 45<=egfr_epi<60 then epi=2;
else if 30<=egfr_epi<45 then epi=3;
else if 15<=egfr_epi<30 then epi=4;
else if 0<=egfr_epi<15 then epi=5;
if egfr>=90 then mdrd=0;
else if 60<=egfr<90 then mdrd=1;
else if 45<=egfr<60 then mdrd=2;
else if 30<=egfr<45 then mdrd=3;
else if 15<=egfr<30 then mdrd=4;
else if 0<=egfr<15 then mdrd=5;
run;
data ckd_stage_upcr;
set survey_person_cut;
IF Proteinuria=. or egfr=. then stage_new=.;
ELSE IF 0<=egfr<15 then stage_new=5;
ELSE IF 30>egfr>=15 then stage_new=4;
ELSE IF 60>egfr>=30 then stage_new=3;
ELSE IF 90>egfr>=60 and (Proteinuria>=150 or P_Kidneydisease=1) then stage_new=2;
ELSE IF egfr>=90 and (Proteinuria>=150 or P_Kidneydisease=1) then stage_new=1;
ELSE IF egfr>=60 and (0<=Proteinuria<150 or P_Kidneydisease=0) then stage_new=0;
ELSE stage_new=.;
IF stage_new=. then stage_group=.;
ELSE IF stage_new=0 then stage_group=0;
ELSE IF stage_new=1 or stage_new=2 or stage_new=3 then stage_group=1;
ELSE IF stage_new=4 or stage_new=5 then stage_group=2;
run;
proc freq data=ckd_stage;
table mdrd*epi/nocol nopercent;
run;
proc freq data=ckd_stage_upcr;
table stage_new*CKDstage/norow nopercent;
run;
proc freq data=ckd_stage_upcr;
table stage_new;
run;
proc freq data=ckd_stage_upcr;
table stage_new*urban/norow ;
run;
data no_ckd_history;
set survey_person;
if P_Kidneydisease=1 then delete;
run;
data pre_esrd_80;set survey_person_cut;
if age_new>50;
run;
data pre_esrd_50;set survey_person_cut;
if age_new<=50;
run;
proc sort data=pre_esrd_80;by ckd;run;
proc surveyselect data=pre_esrd_80 samprate=.6667 out=dev80 seed=44444 outall; 
strata ckd;
run;
data train80 valid80;set dev80;
if selected then output train80;
else output valid80;
run;
proc sort data=pre_esrd_50;by ckd;run;
proc surveyselect data=pre_esrd_50 samprate=.6667 out=dev50 seed=44444 outall; 
strata ckd;
run;
data train50 valid50;set dev50;
if selected then output train50;
else output valid50;
run;
proc stdize data=train50 reponly method=median out=train50_impute outstat=med;
	var  BUN Career Cholesterol Cholesterol_HDL Drink_Hist Eat_Hist Educ_Level Exercise_Hist F_DM F_Hypertension F_Kidneydisease Gender Hemoglobin  Marry_Type Med_NY P_DM P_Heartdisease P_Hypertension P_Hyperuricemia P_Kidneydisease P_None P_Otherdisease P_Unknow P_hyperlipidemia Painkiller Proteinuria SamplingWeight Selected SelectionProb Smoke_Hist Sugar_AC Triglyceride Uric_Acid age_new bmi_group bmi_new bp_group ckd dbp_new eGFR hr_new in_date sbp_new seq waist_group waist_new;
run;
proc stdize data=valid50 reponly method=median out=valid50_impute outstat=med;
	var  BUN Career Cholesterol Cholesterol_HDL Drink_Hist Eat_Hist Educ_Level Exercise_Hist F_DM F_Hypertension F_Kidneydisease Gender Hemoglobin  Marry_Type Med_NY P_DM P_Heartdisease P_Hypertension P_Hyperuricemia P_Kidneydisease P_None P_Otherdisease P_Unknow P_hyperlipidemia Painkiller Proteinuria SamplingWeight Selected SelectionProb Smoke_Hist Sugar_AC Triglyceride Uric_Acid age_new bmi_group bmi_new bp_group ckd dbp_new eGFR hr_new in_date sbp_new seq waist_group waist_new;
run;
proc stdize data=train80 reponly method=median out=train80_impute outstat=med;
	var  BUN Career Cholesterol Cholesterol_HDL Drink_Hist Eat_Hist Educ_Level Exercise_Hist F_DM F_Hypertension F_Kidneydisease Gender Hemoglobin  Marry_Type Med_NY P_DM P_Heartdisease P_Hypertension P_Hyperuricemia P_Kidneydisease P_None P_Otherdisease P_Unknow P_hyperlipidemia Painkiller Proteinuria SamplingWeight Selected SelectionProb Smoke_Hist Sugar_AC Triglyceride Uric_Acid age_new bmi_group bmi_new bp_group ckd dbp_new eGFR hr_new in_date sbp_new seq waist_group waist_new;
run;
proc stdize data=valid80 reponly method=median out=valid80_impute outstat=med;
	var  BUN Career Cholesterol Cholesterol_HDL Drink_Hist Eat_Hist Educ_Level Exercise_Hist F_DM F_Hypertension F_Kidneydisease Gender Hemoglobin  Marry_Type Med_NY P_DM P_Heartdisease P_Hypertension P_Hyperuricemia P_Kidneydisease P_None P_Otherdisease P_Unknow P_hyperlipidemia Painkiller Proteinuria SamplingWeight Selected SelectionProb Smoke_Hist Sugar_AC Triglyceride Uric_Acid age_new bmi_group bmi_new bp_group ckd dbp_new eGFR hr_new in_date sbp_new seq waist_group waist_new;
run;
proc varclus data=train50 maxeigen=.7 short hi;
var BUN Career Cholesterol Cholesterol_HDL Drink_Hist Eat_Hist Educ_Level Exercise_Hist F_DM F_Hypertension F_Kidneydisease Gender Hemoglobin  Marry_Type Med_NY P_DM P_Heartdisease P_Hypertension P_Hyperuricemia P_Kidneydisease P_None P_Otherdisease P_Unknow P_hyperlipidemia Painkiller Proteinuria SamplingWeight Selected SelectionProb Smoke_Hist Sugar_AC Triglyceride Uric_Acid age_new bmi_group bmi_new bp_group ckd dbp_new eGFR hr_new in_date sbp_new seq waist_group waist_new;
run;

/*clinical range
IF sex2=. or Cr2=. or age2=. or eGFR_new=. then stage_new=.;
ELSE IF 0<=eGFR_new<15 then stage_new=5;
ELSE IF 30>eGFR_new>=15 then stage_new=4;
ELSE IF 45>eGFR_new>=30 then stage_new=3.5;
ELSE IF 60>eGFR_new>=45 	then stage_new=3;
ELSE IF 90>eGFR_new>=60 and (UPCR_new>=150 or dipstick_protein2>10 or UACR2>=30 or kd2=1) then stage_new=2;
ELSE IF eGFR_new>=90 and (UPCR_new>=150 or dipstick_protein2>10 or UACR2>=30 or kd2=1) then stage_new=1;
ELSE IF eGFR_new>=60 and (0<=UPCR_new<150 or dipstick_protein2=10 or  0<=UACR2<30 or kd2=0) then stage_new=0;
ELSE stage_new=.;
IF stage_new=. then stage_group=.;
ELSE IF stage_new=0 then stage_group=0;
ELSE IF stage_new=1 or stage_new=2 or stage_new=3 then stage_group=1;
ELSE IF stage_new=3.5 or stage_new=4 or stage_new=5 then stage_group=2;
IF edu2=. then edu_group=.;
ELSE IF edu2="10" or edu2="20" then edu_group=0;
ELSE edu_group=1;
proc univariate data=survey_person;
var age_new;
run;*/
data test;
set survey_person;
if age_new<=50 then output;
run;
proc means data=survey_person;
var age_new gender P_DM bmi_new sbp_new dbp_new hr_new waist_new Smoke_Hist Drink_Hist Eat_Hist Med_NY Exercise_Hist Painkiller P_Hypertension P_Hyperuricemia Educ_Level Marry_Type Career eGFR Proteinuria year;
run;
ods graphics on;
proc univariate data=survey_person plot;
var eGFR;
run;
proc univariate data=survey_person plot;
var age_new;
run;
proc univariate data=survey_person plot;
var bmi_new;
run;
proc sgplot data=survey_person;
title 'Age and eGFR';
scatter x=age_new y=eGFR/group=gender;
run;
ods listing close;
ods pdf file="D:\Dropbox\2019_1_Kidney\correlation.pdf";
proc corr data=survey_person cov plots=matrix;
var age_new gender 
P_DM P_Heartdisease P_Hypertension P_Hyperuricemia P_Kidneydisease P_hyperlipidemia
F_Kidneydisease F_DM F_Hypertension
bmi_new sbp_new dbp_new hr_new waist_new 
Smoke_Hist Drink_Hist Eat_Hist  Exercise_Hist 
Med_NY Painkiller 
Educ_Level Marry_Type Career 
eGFR Proteinuria Triglyceride Uric_Acid BUN Cholesterol Cholesterol_HDL Hemoglobin Sugar_AC;
run;
ods pdf close;
ods listing;

proc corr data=survey_person cov plots=matrix;
title 'sbp and dbp';
var sbp_new dbp_new;
run;
proc reg data=survey_person;
model eGFR=age_new ;
run;
proc reg data=survey_person;
model eGFR=gender;
run;
proc reg data=survey_person;
model eGFR=bmi_new;
run;
proc reg data=survey_person;
model eGFR=sbp_new;
run;
proc reg data=survey_person;
model eGFR=dbp_new;
run;
/*data ckd;set survey_person;
Proteinuria=Proteinuria*1;
eGFR=eGFR*1;
if Proteinuria >=150  then ckd=1;
else if eGFR <60 then ckd=1;
else ckd=0;
run;
proc freq data=ckd;table ckd*P_Kidneydisease;run;*/
/*AUC=0.808*/
proc logistic data=pre_esrd desc;
class gender(ref='0') ;
model ckd=age_new gender;
output out=pred_ckd predicted=prob;
run;
data test;set pred_ckd;
if prob>=0.2;
run;
proc freq data=test;
table ckd;
run;
/*AUC=0.832*/
proc logistic data=pre_esrd desc;
class gender(ref='0') P_Hypertension(ref='0') P_DM(ref='0');
model ckd=age_new gender P_Hypertension P_DM;
run;
/*AUC=0.834*/
proc logistic data=pre_esrd desc;
class gender(ref='0') P_Hypertension(ref='0') P_DM(ref='0');
model ckd=age_new gender P_Hypertension P_DM waist_new;
run;
/*AUC=0.846*/
proc logistic data=pre_esrd desc;
class gender(ref='0') P_Hypertension(ref='0') P_DM(ref='0') P_Heartdisease(ref='0') P_Hyperuricemia(ref='0') ;
model ckd=age_new gender  P_Hypertension P_DM P_Heartdisease P_Hyperuricemia bmi_group;
run;
proc logistic data=pre_esrd desc;
class gender(ref='0') ;
model ckd=age_new gender;
output out=pred_ckd predicted=prob;
run;
data test;set pred_ckd;
if prob>=0.2 and ckd=0;
run;
proc freq data=test;
table ckd;
run;
P_DM P_Heartdisease P_Hypertension P_Hyperuricemia P_Kidneydisease P_hyperlipidemia
bmi_new sbp_new dbp_new hr_new waist_new 
Smoke_Hist Drink_Hist Eat_Hist  Exercise_Hist 
Med_NY Painkiller 
Educ_Level Marry_Type Career 
eGFR Proteinuria Triglyceride Uric_Acid BUN Cholesterol Cholesterol_HDL Hemoglobin Sugar_AC;


proc logistic data=pre_esrd desc;
class gender(ref='0') P_Hypertension(ref='0') P_DM(ref='0') P_Heartdisease(ref='0') P_Hyperuricemia(ref='0') ;
model ckd=age_new gender bmi_group;
run;
proc logistic data=pre_esrd_50 desc;
class waist_group(ref='0') bmi_group(ref='1');
model ckd=age_new  bmi_group;
run;
proc logistic data=pre_esrd_50 desc;
class waist_group(ref='0') bmi_group(ref='1');
model ckd=age_new  bmi_group  P_DM sbp_new  Eat_hist;
run;


data pre_esrd_50_missing;set pre_esrd_50;
array vars{*} P_DM P_Heartdisease P_Hypertension P_Hyperuricemia P_Kidneydisease P_hyperlipidemia
		F_Kidneydisease F_DM F_Hypertension
		bmi_new sbp_new dbp_new hr_new waist_new 
		Smoke_Hist Drink_Hist Eat_Hist  Exercise_Hist 
		Med_NY Painkiller 
		Educ_Level Marry_Type Career 
		eGFR Proteinuria Triglyceride Uric_Acid BUN Cholesterol Cholesterol_HDL Hemoglobin Sugar_AC;
array mvars{*} m_P_DM m_P_Heartdisease m_P_Hypertension m_P_Hyperuricemia m_P_Kidneydisease m_P_hyperlipidemia
		m_F_Kidneydisease m_F_DM m_F_Hypertension
		m_bmi_new m_sbp_new m_dbp_new m_hr_new m_waist_new 
		m_Smoke_Hist m_Drink_Hist m_Eat_Hist  m_Exercise_Hist 
		m_Med_NY m_Painkiller 
		m_Educ_Level m_Marry_Type m_Career 
		m_eGFR m_Proteinuria m_Triglyceride m_Uric_Acid m_BUN m_Cholesterol m_Cholesterol_HDL m_Hemoglobin m_Sugar_AC;
	do i=1 to dim(vars);
		mvars{i}=(vars{i}=.);
	end;
run;


proc logistic data=SURVEY_PERSON_CUT desc;
class gender(ref='0') P_Hypertension(ref='0') P_DM(ref='0') P_Heartdisease(ref='0') P_Hyperuricemia(ref='0') ;
model ckd=age_new gender bmi_group waist_group P_Hypertension P_DM P_Heartdisease P_Hyperuricemia;
run;
proc logistic data=SURVEY_PERSON_CUT desc;
class gender(ref='0') P_Hypertension(ref='0') P_DM(ref='0') P_Heartdisease(ref='0') P_Hyperuricemia(ref='0') ;
model ckd=age_new gender bmi_group  waist_group P_Hypertension P_DM P_Heartdisease P_Hyperuricemia;
score data=SURVEY_PERSON_CUT;	
run;
proc reg data=SURVEY_PERSON_CUT ;
model ckd=age_new gender bmi_group  P_Hypertension P_DM P_Heartdisease P_Hyperuricemia /vif;
run;

proc freq data=SURVEY_PERSON_CUT;
table ckd*urban*P_Kidneydisease/chisq;
run;
