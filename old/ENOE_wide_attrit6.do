

clear all
set more off


********************************************************************************
** This dofile creates the mexican dataset on time use of adolescents
* Esther Gehrke
* March, 20 2019


********************************************************************************
if "`c(username)'"=="gehrk001" {
	cap cd "C:\Users\gehrk001\Dropbox\MigrationShocks\"
}
if "`c(username)'"=="esthe" {
	cap cd "C:\Users\esthe\Dropbox\MigrationShocks\"
}
if "`c(username)'"=="Claire" {
	cap cd "C:\Users\Claire\Dropbox\MigrationShocks\"
}
if "`c(username)'"=="johnh" {
	cap cd "C:\Users\johnh\Dropbox\MigrationShocks\"
}

********************************************************************************
*PREP:
*Input Files: 
*files of type: 
*Data_raw\ENOE\SDEMT`x'`y'.dta
*Data_raw\ENOE\HOGT`x'`y'.dta 
*Data_built\Claves\Claves_1960_2015.dta
*Data_built\EMIF\Shock_EMIF_SecComm_Sanc_2.dta


*Output Files:
*files of type: Data_built\ENOE\educT`x'`y'.dta
*Data_built\ENOE\educENOE.dta
*Data_built\ENOE\ENOE_educ_shock.dta



*******
*to integrate a queston from the sociodemographic survey: Just add once in section below

*to integrate a queston from the extended ampliado questionaire or the basic add twice for 
*the older versions 1,2,3 and newer versions 4,5 in two different sections. 

/*

*********************************************************************************
*********************************************************************************
* Sociodemographico
* birth order, number of siblings (older and younger), gender, migration history


* 1a, 2a, 3a, 4a 
foreach x in 1 2 3 4 {
foreach y in 05 06 07 08 09 10 11 12 13 14 15 16 17 18 {



use Data_raw\ENOE\SDEMT`x'`y'.dta, clear
keep if r_def==00 // keep only those obs with completed survey

*GENERATE HOUSEHOLD IDENTIFIER:
*calculate 1 quarter hh is interviewed
gen first_int_yq="."
replace first_int_yq="`y'"+"`x'" if n_ent==1


gen a=`y'-1
gen b=`y'-1
tostring b, replace
replace b="0"+b if a<10


if `x'==1{
replace first_int_yq=b+"4" if n_ent==2
replace first_int_yq=b+"3" if n_ent==3
replace first_int_yq=b+"2" if n_ent==4
replace first_int_yq=b+"1" if n_ent==5
}
*
if `x'==2{
replace first_int_yq="`y'"+"1" if n_ent==2
replace first_int_yq=b+"4" if n_ent==3
replace first_int_yq=b+"3" if n_ent==4
replace first_int_yq=b+"2" if n_ent==5
}
*
if `x'==3{
replace first_int_yq="`y'"+"2" if n_ent==2
replace first_int_yq="`y'"+"1" if n_ent==3
replace first_int_yq=b+"4" if n_ent==4
replace first_int_yq=b+"3" if n_ent==5
}
*
if `x'==4{
replace first_int_yq="`y'"+"3" if n_ent==2
replace first_int_yq="`y'"+"2" if n_ent==3
replace first_int_yq="`y'"+"1" if n_ent==4
replace first_int_yq=b+"4" if n_ent==5
}
*
drop a b

 *note h_mod indicates the hh has moved and should not be included for panel tracking
gen hh_id=first_int_yq+"_"+ string(cd_a)+ "_" + string(ent)+"_"+string(con)+"_"+string(v_sel)+"_"+string(n_hog)
gen hh_id_visit=hh_id+"_visit"+string(n_ent)

gen indiv_id= hh_id+"_"+string(n_ren)
gen indiv_id_visit=indiv_id+"_visit"+string(n_ent)

*one observation per individual
isid indiv_id


*SCHOOLING VARIABLES
ren cs_p17 enroll 
recode enroll 9=. 2=0


keep loc mun est est_d ageb t_loc cd_a ent con upm d_sem n_pro_viv v_sel n_hog ///
	h_mud n_ent hh_id hh_id_visit indiv_id indiv_id_visit per n_ren  sex eda enroll anios_esc hrsocup ingocup ///
	ing_x_hrs c_res n_ent first_int_yq  anios_esc cs_ad_des cs_nr_ori fac  cs_ad_mot cs_nr_mot


save Data_built\ENOE\socioT`x'`y'_wide_mini.dta, replace

}
}
*

clear
gen per=.
save Data_built\ENOE\wide_build.dta, replace

foreach x in 1 2 3 4 {
foreach y in 05 06 07 08 09 10 11 12 13 14 15 16 17 18 {
append using Data_built\ENOE\socioT`x'`y'_wide_mini.dta
}
}
*
*/

use Data_built\ENOE\time_use_all_merge.dta

sort indiv_id

*figuring out quarter of all scheduled houshold interviews
destring first_int_yq, replace
drop if first_int_yq<51
drop if first_int_yq>134

gen first_int_yq_2=first_int_yq
gen str3  first_int_yq_3 = string(first_int_yq_2,"%03.0f")
tostring first_int_yq, replace
gen x=substr(first_int_yq_3,3,1) 
gen y=substr(first_int_yq_3,1,2) 

destring x y, replace
replace y=y+2000

gen xmo=.
replace xmo=2 if x==1
replace xmo=5 if x==2
replace xmo=8 if x==3
replace xmo=11 if x==4
tostring xmo y, replace
gen date1=xmo+"-1-"+y
gen edate = date(date1,"MDY")
gen qy_ent1 = qofd(edate)

forval i=2/5{
local a=`i'-1
gen qy_ent`i'=qy_ent`a'+1
}

forval i=1/5{
gen y_ent`i'=yofd(dofq(qy_ent`i'))    
gen q_ent`i'=quarter(dofq(qy_ent`i'))    
}

gen geo2_mx2015 = ent*1000 + mun


merge m:1 geo2_mx2015 using Data_built\Claves\Claves_1960_2015.dta
drop if _m==2 // not all municipalities coevered in any round? 
drop _m geo1_mx2015 geo1_mx2010 geo2_mx2010 geo1_mx2005 geo2_mx2005

save Data_built\ENOE\wide_build.dta, replace




*select individual constants want to keep
sort indiv_id
by indiv_id: egen bsline_age=min(eda)
recode anios_esc 99=.
by indiv_id: egen bsline_edu=min(anios_esc)
gen bsline_highedu=0
replace bsline_highedu=1 if bsline_edu>9
by indiv_id: egen msex=mean(sex)
replace msex=round(msex) 
keep indiv_id msex bsline_age geo2_mx2015 bsline_edu bsline_highedu
duplicates drop
* a few (200+) duplicate ids 
duplicates tag indiv_id, gen(duple)
drop if duple==1
drop duple
save Data_built\ENOE\wide_build_mini.dta, replace



clear 
use  Data_built\Matriculas\Shock_Mat_SecComm_Sanc_5.dta
keep if inlist(month, 2, 5, 8,11)
gen quarter=.
replace quarter=1 if month==2
replace quarter=2 if month==5
replace quarter=3 if month==8
replace quarter=4 if month==11
gen q_ent=quarter
gen y_ent=year
gen int_yq= (year-2000)*10+quarter
isid    geo2_mx2000 int_yq
save  Data_built\Matriculas\Shock_Mat_SecComm_Sanc_5merge.dta, replace 





********************************************************
*get household yoy panel

use  Data_built\ENOE\wide_build.dta, 

sort hh_id
foreach y in fac hhsize hhv_kids hhv_teen_f hhv_teen_m hhv_youngadult_f hhv_youngadult_m hhv_adult_f hhv_adult_m hh_report_remit hh_earn_mo{
forval i=1/5{
gen `y'_ent_`i'a=.
replace `y'_ent_`i'a=`y' if n_ent==`i'
by hh_id: egen `y'_ent_`i'=max(`y'_ent_`i'a)
drop `y'_ent_`i'a 
}
}
*

forval i=1/5{
gen hh_shouldbe_int`i'=1	
gen hh_home1vaway_ent_`i'a=.
replace hh_home1vaway_ent_`i'a=1 if n_ent==`i'
by hh_id: egen hh_home1vaway_ent_`i'=max(hh_home1vaway_ent_`i'a)
drop hh_home1vaway_ent_`i'a 
}

keep hh_id qy_ent* y_ent* q_ent* geo1_mx2000 geo2_mx2000 hh_home1vaway_ent_*  hh_shouldbe_int*  fac_* hhsize_* hhv_kids_* hhv_teen_f_* hhv_teen_m_* hhv_youngadult_f_* hhv_youngadult_m_* hhv_adult_f_* hhv_adult_m_* hh_report_remit_* hh_earn_mo_*
duplicates drop

egen hh_obs_rounds=rowtotal(hh_home1vaway_ent_1 hh_home1vaway_ent_2 hh_home1vaway_ent_3 hh_home1vaway_ent_4 hh_home1vaway_ent_5)
*tab hh_home1vaway_ent_5, miss
*Share of missing households by round
*1:7.45%  2:7.43%  3:7.76%  4:8.16%  5:8.07%


*one miscoded observation: drop
duplicates tag hh_id, gen(duple)
drop if duple==1
duplicates drop
save Data_built\ENOE\hh_attrit_wide.dta, replace


*FD build
use  Data_built\ENOE\hh_attrit_wide.dta

forval i=1/5{
replace hh_home1vaway_ent_`i'=0 if hh_home1vaway_ent_`i'==.	
}

*yoy hh attrits: -1 for joining hh, 0 no change, 1 for disappearing
gen yoy_hhattrits=(-1)*(hh_home1vaway_ent_5-hh_home1vaway_ent_1)

gen yoy_hhdeparts=(-1)*(hh_home1vaway_ent_5-hh_home1vaway_ent_1) 
replace yoy_hhdeparts=. if hh_home1vaway_ent_1==0

gen yoy_hharrives=(hh_home1vaway_ent_5-hh_home1vaway_ent_1) 
replace yoy_hharrives=. if hh_home1vaway_ent_5==0

foreach y in hhsize hhv_kids hhv_teen_f hhv_teen_m hhv_youngadult_f hhv_youngadult_m hhv_adult_f hhv_adult_m hh_report_remit hh_earn_mo{
gen yoy_`y'= `y'_ent_5- `y'_ent_1	
}

keep hh_id  qy_ent1 y_ent1 q_ent1 geo1_mx2000 geo2_mx2000  fac_ent_1 fac_ent_5 yoy_*
isid hh_id
rename (qy_ent1 y_ent1 q_ent1)(qy_ent y_ent q_ent)

merge m:1  y_ent q_ent  geo2_mx2000 using Data_built\Matriculas\Shock_Mat_SecComm_Sanc_5merge.dta
keep if _m==3
drop _m

gen yoy_sc_shock_5=sc_shock_5-l12_sc_5
gen yoy_sc_noweight_5=sc_noweight_5-l12_scnw_5



gen yoy_f1sc_shock_5=f12_sc_5-sc_shock_5
gen yoy_f1sc_noweight_5=f12_scnw_5-sc_noweight_5

gen yoy_f2sc_shock_5=f24_sc_5-f12_sc_5
gen yoy_f2sc_noweight_5=f24_scnw_5-f12_scnw_5

gen yoy_l1sc_shock_5=l12_sc_5-l24_sc_5
gen yoy_l1sc_noweight_5=l12_scnw_5-l24_scnw_5

gen yoy_l2sc_shock_5=l24_sc_5-l36_sc_5
gen yoy_l2sc_noweight_5=l24_scnw_5-l36_scnw_5

isid hh_id
save Data_built\ENOE\hh_attrit_FD.dta, replace
******************************************


********************************************************
*get individual yoy panel
use  Data_built\ENOE\wide_build.dta, 

sort indiv_id
foreach y in fac study lfp unempl ls_hrs wage_hr inc_mo chores study_hrs enroll yrs_offtrack  logwage_hr  migrant dom_migrant returnee dom_returnee {
forval i=1/5{
gen `y'_ent_`i'a=.
replace `y'_ent_`i'a=`y' if n_ent==`i'
by indiv_id: egen `y'_ent_`i'=max(`y'_ent_`i'a)
drop `y'_ent_`i'a 
}
}
*

forval i=1/5{
gen ind_shouldbe_int`i'=1	
gen ind_home1vaway_ent_`i'a=.
replace ind_home1vaway_ent_`i'a=1 if n_ent==`i'
by indiv_id: egen ind_home1vaway_ent_`i'=max(ind_home1vaway_ent_`i'a)
drop ind_home1vaway_ent_`i'a 
}

keep indiv_id hh_id qy_ent* y_ent* q_ent* geo1_mx2000 geo2_mx2000 ind_home1vaway_ent_*  ind_shouldbe_int*  fac_ent_* study_ent_* lfp_ent_* unempl_ent_* ls_hrs_ent_* wage_hr_ent_* inc_mo_ent_* chores_ent_* study_hrs_ent_* enroll_ent_* yrs_offtrack_ent_*  logwage_hr_ent_*  migrant_ent_* dom_migrant_ent_* returnee_ent_* dom_returnee_ent_*
duplicates drop

*one miscoded observation: drop
duplicates tag indiv_id, gen(duple)
drop if duple==1
duplicates drop
save Data_built\ENOE\indiv_attrit_wide.dta, replace



*FD build
use  Data_built\ENOE\indiv_attrit_wide.dta

foreach y in migrant dom_migrant {
egen all`y'= rowtotal(`y'_ent_1 `y'_ent_2 `y'_ent_3 `y'_ent_4 )
gen yoy_`y'=0
replace yoy_`y'=1 if all`y'>0 & ind_home1vaway_ent_5==.
drop all`y'
}

foreach y in returnee dom_returnee{
egen all`y'= rowtotal(`y'_ent_2 `y'_ent_3 `y'_ent_4 `y'_ent_5 )
gen yoy_`y'=0 
replace yoy_`y'=1 if all`y'>0 & ind_home1vaway_ent_5==1
drop all`y'
}

gen yoy_appears=0
replace yoy_appears=1 if ind_home1vaway_ent_5==1 & ind_home1vaway_ent_1==.

gen yoy_disappears=0
replace yoy_disappears=1 if ind_home1vaway_ent_5==. & ind_home1vaway_ent_1==1



foreach y in  study lfp unempl ls_hrs wage_hr inc_mo chores study_hrs enroll yrs_offtrack  logwage_hr {
gen yoy_`y'= `y'_ent_5- `y'_ent_1	
}


keep indiv_id hh_id qy_ent1 y_ent1 q_ent1 geo1_mx2000 geo2_mx2000  fac_ent_1 fac_ent_5 yoy_*  ind_home1vaway_ent_5 ind_home1vaway_ent_1
isid indiv_id
rename (qy_ent1 y_ent1 q_ent1)(qy_ent y_ent q_ent)

merge m:1 hh_id using  Data_built\ENOE\hh_attrit_FD.dta
keep if _m==3
drop _m

/*
merge m:1  y_ent q_ent  geo2_mx2000 using Data_built\Matriculas\Shock_Mat_SecComm_Sanc_5merge.dta
keep if _m==3
drop _m
gen yoy_sc_shock_5=sc_shock_5-l12_sc_5
gen yoy_sc_noweight_5=sc_noweight_5-l12_scnw_5

gen yoy_f1sc_shock_5=f12_sc_5-sc_shock_5
gen yoy_f1sc_noweight_5=f12_scnw_5-sc_noweight_5

gen yoy_f2sc_shock_5=f24_sc_5-f12_sc_5
gen yoy_f2sc_noweight_5=f24_scnw_5-f12_scnw_5

gen yoy_l1sc_shock_5=l12_sc_5-l24_sc_5
gen yoy_l1sc_noweight_5=l12_scnw_5-l24_scnw_5

gen yoy_l2sc_shock_5=l24_sc_5-l36_sc_5
gen yoy_l2sc_noweight_5=l24_scnw_5-l36_scnw_5
*/
merge 1:1 indiv_id using  Data_built\ENOE\wide_build_mini.dta
drop _m

gen pop=1

sort hh_id 
by  hh_id: gen count=_n
gen hh_singleobs=.
replace hh_singleobs=1 if count==1

gen is21plus=0
replace is21plus=1 if bsline_age>=21

gen is1214=0
replace is1214=1 if bsline_age>=12 & bsline_age<=14

gen is1517=0
replace is1517=1 if bsline_age>=15 & bsline_age<=17

gen is1820=0
replace is1820=1 if bsline_age>=18 & bsline_age<=20

save Data_built\ENOE\ind_attrit_FD.dta, replace
******************************************


*****
*HH yoy regressions

log using yoy, replace
set linesize 200

use Data_built\ENOE\ind_attrit_FD.dta, replace
keep if hh_singleobs==1

egen fes=concat(y_ent geo1_mx2000)

global fes fes geo2_mx2000 q_ent

*notice weighting and selection in these regressions: fac_ent_* is not available for households if they are unobserved.
eststo clear
eststo: quietly reghdfe yoy_hhdeparts yoy_sc_shock_5 c.migr_share#i.qy_ent [aw=fac_ent_1], a($fes) cluster(geo2_mx2000)
eststo: quietly reghdfe yoy_hhdeparts yoy_sc_noweight_5 c.migr_share#i.qy_ent [aw=fac_ent_1], a($fes) cluster(geo2_mx2000)
eststo: quietly reghdfe yoy_hhdeparts yoy_sc_shock_5 c.migr_share#i.qy_ent if fac_ent_1!=. , a($fes) cluster(geo2_mx2000)
eststo: quietly reghdfe yoy_hhdeparts yoy_sc_noweight_5 c.migr_share#i.qy_ent if fac_ent_1!=., a($fes) cluster(geo2_mx2000)
eststo: quietly reghdfe yoy_hhdeparts yoy_f2sc_shock_5 yoy_f1sc_shock_5 yoy_sc_shock_5  yoy_l1sc_shock_5  yoy_l2sc_shock_5 c.migr_share#i.qy_ent [aw=fac_ent_1], a($fes) cluster(geo2_mx2000)
eststo: quietly reghdfe yoy_hhdeparts yoy_f2sc_noweight_5 yoy_f1sc_noweight_5 yoy_sc_noweight_5 yoy_l1sc_noweight_5 yoy_l2sc_noweight_5 c.migr_share#i.qy_ent [aw=fac_ent_1], a($fes) cluster(geo2_mx2000)
eststo: quietly reghdfe yoy_hhdeparts yoy_f2sc_shock_5 yoy_f1sc_shock_5 yoy_sc_shock_5  yoy_l1sc_shock_5  yoy_l2sc_shock_5 c.migr_share#i.qy_ent  if fac_ent_1!=., a($fes) cluster(geo2_mx2000)
eststo: quietly reghdfe yoy_hhdeparts yoy_f2sc_noweight_5 yoy_f1sc_noweight_5 yoy_sc_noweight_5 yoy_l1sc_noweight_5 yoy_l2sc_noweight_5 c.migr_share#i.qy_ent if fac_ent_1!=., a($fes) cluster(geo2_mx2000)

esttab, se keep( yoy_sc_shock_5 yoy_sc_noweight_5 yoy_f2sc_shock_5 yoy_f1sc_shock_5   yoy_l1sc_shock_5  yoy_l2sc_shock_5 yoy_f2sc_noweight_5 yoy_f1sc_noweight_5  yoy_l1sc_noweight_5 yoy_l2sc_noweight_5)

eststo clear
eststo: quietly reghdfe yoy_hharrives yoy_sc_shock_5 c.migr_share#i.qy_ent [aw=fac_ent_5], a($fes) cluster(geo2_mx2000)
eststo: quietly reghdfe yoy_hharrives yoy_sc_noweight_5 c.migr_share#i.qy_ent [aw=fac_ent_5], a($fes) cluster(geo2_mx2000)
eststo: quietly reghdfe yoy_hharrives yoy_sc_shock_5 c.migr_share#i.qy_ent if fac_ent_5!=. , a($fes) cluster(geo2_mx2000)
eststo: quietly reghdfe yoy_hharrives yoy_sc_noweight_5 c.migr_share#i.qy_ent if fac_ent_5!=., a($fes) cluster(geo2_mx2000)
eststo: quietly reghdfe yoy_hharrives yoy_f2sc_shock_5 yoy_f1sc_shock_5 yoy_sc_shock_5  yoy_l1sc_shock_5  yoy_l2sc_shock_5 c.migr_share#i.qy_ent [aw=fac_ent_5], a($fes) cluster(geo2_mx2000)
eststo: quietly reghdfe yoy_hharrives yoy_f2sc_noweight_5 yoy_f1sc_noweight_5 yoy_sc_noweight_5 yoy_l1sc_noweight_5 yoy_l2sc_noweight_5 c.migr_share#i.qy_ent [aw=fac_ent_5], a($fes) cluster(geo2_mx2000)
eststo: quietly reghdfe yoy_hharrives yoy_f2sc_shock_5 yoy_f1sc_shock_5 yoy_sc_shock_5  yoy_l1sc_shock_5  yoy_l2sc_shock_5 c.migr_share#i.qy_ent  if fac_ent_5!=., a($fes) cluster(geo2_mx2000)
eststo: quietly reghdfe yoy_hharrives yoy_f2sc_noweight_5 yoy_f1sc_noweight_5 yoy_sc_noweight_5 yoy_l1sc_noweight_5 yoy_l2sc_noweight_5 c.migr_share#i.qy_ent if fac_ent_5!=., a($fes) cluster(geo2_mx2000)

esttab, se keep( yoy_sc_shock_5 yoy_sc_noweight_5 yoy_f2sc_shock_5 yoy_f1sc_shock_5   yoy_l1sc_shock_5  yoy_l2sc_shock_5 yoy_f2sc_noweight_5 yoy_f1sc_noweight_5  yoy_l1sc_noweight_5 yoy_l2sc_noweight_5)


keep if fac_ent_1!=. & fac_ent_5!=.

foreach y in hhsize hhv_kids hhv_teen_f hhv_teen_m hhv_youngadult_f hhv_youngadult_m hhv_adult_f hhv_adult_m hh_report_remit hh_earn_mo{
eststo clear
eststo: quietly reghdfe yoy_`y' yoy_sc_shock_5 c.migr_share#i.qy_ent [aw=fac_ent_1], a($fes) cluster(geo2_mx2000)
eststo: quietly reghdfe yoy_`y' yoy_sc_noweight_5 c.migr_share#i.qy_ent [aw=fac_ent_1], a($fes) cluster(geo2_mx2000)
eststo: quietly reghdfe yoy_`y' yoy_sc_shock_5 c.migr_share#i.qy_ent , a($fes) cluster(geo2_mx2000)
eststo: quietly reghdfe yoy_`y' yoy_sc_noweight_5 c.migr_share#i.qy_ent , a($fes) cluster(geo2_mx2000)
eststo: quietly reghdfe yoy_`y' yoy_f2sc_shock_5 yoy_f1sc_shock_5 yoy_sc_shock_5  yoy_l1sc_shock_5  yoy_l2sc_shock_5 c.migr_share#i.qy_ent [aw=fac_ent_1], a($fes) cluster(geo2_mx2000)
eststo: quietly reghdfe yoy_`y' yoy_f2sc_noweight_5 yoy_f1sc_noweight_5 yoy_sc_noweight_5 yoy_l1sc_noweight_5 yoy_l2sc_noweight_5 c.migr_share#i.qy_ent [aw=fac_ent_1], a($fes) cluster(geo2_mx2000)
eststo: quietly reghdfe yoy_`y' yoy_f2sc_shock_5 yoy_f1sc_shock_5 yoy_sc_shock_5  yoy_l1sc_shock_5  yoy_l2sc_shock_5 c.migr_share#i.qy_ent  , a($fes) cluster(geo2_mx2000)
eststo: quietly reghdfe yoy_`y' yoy_f2sc_noweight_5 yoy_f1sc_noweight_5 yoy_sc_noweight_5 yoy_l1sc_noweight_5 yoy_l2sc_noweight_5 c.migr_share#i.qy_ent , a($fes) cluster(geo2_mx2000)

esttab, se keep( yoy_sc_shock_5 yoy_sc_noweight_5 yoy_f2sc_shock_5 yoy_f1sc_shock_5   yoy_l1sc_shock_5  yoy_l2sc_shock_5 yoy_f2sc_noweight_5 yoy_f1sc_noweight_5  yoy_l1sc_noweight_5 yoy_l2sc_noweight_5)
	
}

*individual level
use Data_built\ENOE\ind_attrit_FD.dta, replace

egen fes=concat(y_ent geo1_mx2000)

global fes fes geo2_mx2000 q_ent

foreach y in migrant dom_migrant disappears{
eststo clear
eststo: quietly reghdfe yoy_`y' yoy_sc_shock_5 c.migr_share#i.qy_ent [aw=fac_ent_1], a($fes) cluster(geo2_mx2000)
eststo: quietly reghdfe yoy_`y' yoy_sc_noweight_5 c.migr_share#i.qy_ent [aw=fac_ent_1], a($fes) cluster(geo2_mx2000)
eststo: quietly reghdfe yoy_`y' yoy_sc_shock_5 c.migr_share#i.qy_ent if fac_ent_1!=. , a($fes) cluster(geo2_mx2000)
eststo: quietly reghdfe yoy_`y' yoy_sc_noweight_5 c.migr_share#i.qy_ent if fac_ent_1!=., a($fes) cluster(geo2_mx2000)
eststo: quietly reghdfe yoy_`y' yoy_f2sc_shock_5 yoy_f1sc_shock_5 yoy_sc_shock_5  yoy_l1sc_shock_5  yoy_l2sc_shock_5 c.migr_share#i.qy_ent [aw=fac_ent_1], a($fes) cluster(geo2_mx2000)
eststo: quietly reghdfe yoy_`y' yoy_f2sc_noweight_5 yoy_f1sc_noweight_5 yoy_sc_noweight_5 yoy_l1sc_noweight_5 yoy_l2sc_noweight_5 c.migr_share#i.qy_ent [aw=fac_ent_1], a($fes) cluster(geo2_mx2000)
eststo: quietly reghdfe yoy_`y' yoy_f2sc_shock_5 yoy_f1sc_shock_5 yoy_sc_shock_5  yoy_l1sc_shock_5  yoy_l2sc_shock_5 c.migr_share#i.qy_ent if fac_ent_1!=.  , a($fes) cluster(geo2_mx2000)
eststo: quietly reghdfe yoy_`y' yoy_f2sc_noweight_5 yoy_f1sc_noweight_5 yoy_sc_noweight_5 yoy_l1sc_noweight_5 yoy_l2sc_noweight_5 c.migr_share#i.qy_ent if fac_ent_1!=. , a($fes) cluster(geo2_mx2000)
esttab, se keep( yoy_sc_shock_5 yoy_sc_noweight_5 yoy_f2sc_shock_5 yoy_f1sc_shock_5   yoy_l1sc_shock_5  yoy_l2sc_shock_5 yoy_f2sc_noweight_5 yoy_f1sc_noweight_5  yoy_l1sc_noweight_5 yoy_l2sc_noweight_5)
}


foreach y in returnee dom_returnee appears{
eststo clear
eststo: quietly reghdfe yoy_`y' yoy_sc_shock_5 c.migr_share#i.qy_ent [aw=fac_ent_5], a($fes) cluster(geo2_mx2000)
eststo: quietly reghdfe yoy_`y' yoy_sc_noweight_5 c.migr_share#i.qy_ent [aw=fac_ent_5], a($fes) cluster(geo2_mx2000)
eststo: quietly reghdfe yoy_`y' yoy_sc_shock_5 c.migr_share#i.qy_ent if fac_ent_5!=. , a($fes) cluster(geo2_mx2000)
eststo: quietly reghdfe yoy_`y' yoy_sc_noweight_5 c.migr_share#i.qy_ent if fac_ent_5!=., a($fes) cluster(geo2_mx2000)
eststo: quietly reghdfe yoy_`y' yoy_f2sc_shock_5 yoy_f1sc_shock_5 yoy_sc_shock_5  yoy_l1sc_shock_5  yoy_l2sc_shock_5 c.migr_share#i.qy_ent [aw=fac_ent_5], a($fes) cluster(geo2_mx2000)
eststo: quietly reghdfe yoy_`y' yoy_f2sc_noweight_5 yoy_f1sc_noweight_5 yoy_sc_noweight_5 yoy_l1sc_noweight_5 yoy_l2sc_noweight_5 c.migr_share#i.qy_ent [aw=fac_ent_5], a($fes) cluster(geo2_mx2000)
eststo: quietly reghdfe yoy_`y' yoy_f2sc_shock_5 yoy_f1sc_shock_5 yoy_sc_shock_5  yoy_l1sc_shock_5  yoy_l2sc_shock_5 c.migr_share#i.qy_ent  if fac_ent_5!=., a($fes) cluster(geo2_mx2000)
eststo: quietly reghdfe yoy_`y' yoy_f2sc_noweight_5 yoy_f1sc_noweight_5 yoy_sc_noweight_5 yoy_l1sc_noweight_5 yoy_l2sc_noweight_5 c.migr_share#i.qy_ent if fac_ent_5!=., a($fes) cluster(geo2_mx2000)
esttab, se keep( yoy_sc_shock_5 yoy_sc_noweight_5 yoy_f2sc_shock_5 yoy_f1sc_shock_5   yoy_l1sc_shock_5  yoy_l2sc_shock_5 yoy_f2sc_noweight_5 yoy_f1sc_noweight_5  yoy_l1sc_noweight_5 yoy_l2sc_noweight_5)
}

log close

keep if ind_home1vaway_ent_1==1 & ind_home1vaway_ent_5==1


foreach x in is21plus is1214 is1517 is1820{
log using yoy_`x', replace
set linesize 200

/*
eststo clear
eststo: quietly reghdfe yoy_`y' yoy_sc_shock_5 c.migr_share#i.qy_ent [aw=fac_ent_1] if `x'==1, a($fes) cluster(geo2_mx2000)
eststo: quietly reghdfe yoy_`y' yoy_sc_noweight_5 c.migr_share#i.qy_ent [aw=fac_ent_1] if `x'==1, a($fes) cluster(geo2_mx2000)
eststo: quietly reghdfe yoy_`y' yoy_sc_shock_5 c.migr_share#i.qy_ent if fac_ent_1!=. & `x'==1 , a($fes) cluster(geo2_mx2000)
eststo: quietly reghdfe yoy_`y' yoy_sc_noweight_5 c.migr_share#i.qy_ent if fac_ent_1!=. & `x'==1, a($fes) cluster(geo2_mx2000)
esttab, keep( yoy_sc_shock_5 yoy_sc_noweight_5)
*/
foreach y in study lfp unempl ls_hrs wage_hr inc_mo chores study_hrs enroll  logwage_hr{
eststo clear
eststo: quietly reghdfe yoy_`y' yoy_sc_shock_5 c.migr_share#i.qy_ent [aw=fac_ent_1] if `x'==1, a($fes) cluster(geo2_mx2000)
eststo: quietly reghdfe yoy_`y' yoy_sc_noweight_5 c.migr_share#i.qy_ent [aw=fac_ent_1] if `x'==1, a($fes) cluster(geo2_mx2000)
eststo: quietly reghdfe yoy_`y' yoy_sc_shock_5 c.migr_share#i.qy_ent if fac_ent_1!=. & `x'==1 , a($fes) cluster(geo2_mx2000)
eststo: quietly reghdfe yoy_`y' yoy_sc_noweight_5 c.migr_share#i.qy_ent if fac_ent_1!=. & `x'==1, a($fes) cluster(geo2_mx2000)
eststo: quietly reghdfe yoy_`y' yoy_f2sc_shock_5 yoy_f1sc_shock_5 yoy_sc_shock_5  yoy_l1sc_shock_5  yoy_l2sc_shock_5 c.migr_share#i.qy_ent [aw=fac_ent_1] if `x'==1, a($fes) cluster(geo2_mx2000)
eststo: quietly reghdfe yoy_`y' yoy_f2sc_noweight_5 yoy_f1sc_noweight_5 yoy_sc_noweight_5 yoy_l1sc_noweight_5 yoy_l2sc_noweight_5 c.migr_share#i.qy_ent [aw=fac_ent_1] if `x'==1, a($fes) cluster(geo2_mx2000)
eststo: quietly reghdfe yoy_`y' yoy_f2sc_shock_5 yoy_f1sc_shock_5 yoy_sc_shock_5  yoy_l1sc_shock_5  yoy_l2sc_shock_5 c.migr_share#i.qy_ent  if fac_ent_1!=. & `x'==1 , a($fes) cluster(geo2_mx2000)
eststo: quietly reghdfe yoy_`y' yoy_f2sc_noweight_5 yoy_f1sc_noweight_5 yoy_sc_noweight_5 yoy_l1sc_noweight_5 yoy_l2sc_noweight_5 c.migr_share#i.qy_ent if fac_ent_1!=. & `x'==1 , a($fes) cluster(geo2_mx2000)
esttab, se keep( yoy_sc_shock_5 yoy_sc_noweight_5 yoy_f2sc_shock_5 yoy_f1sc_shock_5   yoy_l1sc_shock_5  yoy_l2sc_shock_5 yoy_f2sc_noweight_5 yoy_f1sc_noweight_5  yoy_l1sc_noweight_5 yoy_l2sc_noweight_5)
}
log close
}


*********************************
*MUNI LEVEL YOY 
*create duplicate variables for sums and means 
use Data_built\ENOE\ind_attrit_FD.dta, clear

foreach i in yoy_hh_report_remit yoy_hhdeparts yoy_hharrives yoy_migrant yoy_dom_migrant yoy_disappears yoy_returnee yoy_dom_returnee yoy_appears  yoy_study  yoy_lfp  yoy_unempl   yoy_enroll  {
rename `i' `i'1
gen `i'2=`i'1	
}

save Data_built\ENOE\ind_attrit_FD2.dta, replace

************************
*Write program to get YOY municipal variables of interest for specific population subgoups.
*************************
*`1' string defining observation caracteristics conditioning once
*`2' global list of variables that want to calculate the mean of
*`3' global list of variables that want to calculate the sum of
*`4' variable name reflecting subgroup
*`5' weighting factor

program def YOY_muniagg_subgroup_prog, rclass

use Data_built\ENOE\ind_attrit_FD2.dta, clear
keep if `1'


collapse (mean) `2' (sum) `3' [pw=`5'], by(quarter year geo2_mx2000 geo1_mx2000)

foreach i in `2'{
local new = "pwm"+"`i'"+"_mn"+"`4'"
rename  `i'	`new'
}

foreach i in `3'{
local new = "pwm"+"`i'"+"_sum"+"`4'"
rename  `i'	`new'
}



tempfile saver
save `saver', replace

use Data_built\ENOE\ind_attrit_FD2.dta, clear
keep if `1'



collapse (mean) `2' (sum) `3' , by(quarter year geo2_mx2000 geo1_mx2000)

foreach i in `2'{
local new = "m"+"`i'"+"_mn"+"`4'"
rename `i'	`new'
}

foreach i in `3'{
local new = "m"+"`i'"+"_sum"+"`4'"
rename `i'	`new'
}



merge 1:1 quarter year geo2_mx2000 geo1_mx2000 using `saver'
drop _m
save "Data_built\ENOE\ENOE_myoyagg`4'.dta", replace
clear
end 


*** hh observed at ent1 
local meanhhent1 yoy_hhdeparts1
local sumhhent1 yoy_hhdeparts2 
YOY_muniagg_subgroup_prog "hh_singleobs==1" "`meanhhent1'" "`sumhhent1'" "hh1" "fac_ent_1"

*** hh observed at ent1 
local meanhhent5 yoy_hharrives1 
local sumhhent5 yoy_hharrives2
YOY_muniagg_subgroup_prog "hh_singleobs==1" "`meanhhent5'" "`sumhhent5'" "hh5" "fac_ent_5"

*** hh observed both ent1 and ent5
local meanhhent15 yoy_hhsize yoy_hhv_kids yoy_hhv_teen_f yoy_hhv_teen_m yoy_hhv_youngadult_f yoy_hhv_youngadult_m yoy_hhv_adult_f yoy_hhv_adult_m yoy_hh_report_remit1 yoy_hh_earn_mo
local sumhhent15  yoy_hh_report_remit2
YOY_muniagg_subgroup_prog "hh_singleobs==1 & fac_ent_1!=. & fac_ent_5!=." "`meanhhent15'" "`sumhhent15'" "hh15" "fac_ent_1"

*** indiv observed at ent1 
local meanindivent1  yoy_migrant1 yoy_dom_migrant1 yoy_disappears1
local sumindivent1 yoy_migrant2 yoy_dom_migrant2 yoy_disappears2
YOY_muniagg_subgroup_prog "fac_ent_1!=." "`meanindivent1'" "`sumindivent1'" "in1" "fac_ent_1"


*** indiv observed at ent5 
local meanindivent5 yoy_returnee1 yoy_dom_returnee1 yoy_appears1
local sumindivent5 yoy_returnee2 yoy_dom_returnee2 yoy_appears2
YOY_muniagg_subgroup_prog "fac_ent_5!=." "`meanindivent5'" "`sumindivent5'" "in5" "fac_ent_5"

*** indiv observed both ent1 and ent5
local meanindivent15  yoy_study1  yoy_lfp1  yoy_unempl1  yoy_ls_hrs  yoy_wage_hr  yoy_inc_mo  yoy_chores  yoy_study_hrs  yoy_enroll1   yoy_logwage_hr
local sumindivent15   yoy_study2  yoy_lfp2  yoy_unempl2   yoy_enroll2  
YOY_muniagg_subgroup_prog "fac_ent_1!=. & fac_ent_5!=." "`meanindivent15'" "`sumindivent15'" "in15" "fac_ent_1"

local meanindivent15  yoy_study1  yoy_lfp1  yoy_unempl1  yoy_ls_hrs  yoy_wage_hr  yoy_inc_mo  yoy_chores  yoy_study_hrs  yoy_enroll1   yoy_logwage_hr
local sumindivent15   yoy_study2  yoy_lfp2  yoy_unempl2   yoy_enroll2  
YOY_muniagg_subgroup_prog "fac_ent_1!=. & fac_ent_5!=." "`meanindivent15'" "`sumindivent15'" "in15" "fac_ent_1"
YOY_muniagg_subgroup_prog "fac_ent_1!=. & fac_ent_5!=. &  is21plus==1" "`meanindivent15'" "`sumindivent15'" "21p" "fac_ent_1"
YOY_muniagg_subgroup_prog "fac_ent_1!=. & fac_ent_5!=. &  is1214==1" "`meanindivent15'" "`sumindivent15'" "1214" "fac_ent_1"
YOY_muniagg_subgroup_prog "fac_ent_1!=. & fac_ent_5!=. &  is1517==1" "`meanindivent15'" "`sumindivent15'" "1517" "fac_ent_1"
YOY_muniagg_subgroup_prog "fac_ent_1!=. & fac_ent_5!=. &  is1820==1" "`meanindivent15'" "`sumindivent15'" "1820" "fac_ent_1"


use Data_built\ENOE\ENOE_myoyagghh1.dta

merge 1:1 quarter year geo2_mx2000 geo1_mx2000 using Data_built\ENOE\ENOE_myoyagghh5.dta
drop _m 
merge 1:1 quarter year geo2_mx2000 geo1_mx2000 using Data_built\ENOE\ENOE_myoyagghh15.dta
drop _m
merge 1:1 quarter year geo2_mx2000 geo1_mx2000 using Data_built\ENOE\ENOE_myoyaggin1.dta
drop _m
merge 1:1 quarter year geo2_mx2000 geo1_mx2000 using Data_built\ENOE\ENOE_myoyaggin5.dta
drop _m
merge 1:1 quarter year geo2_mx2000 geo1_mx2000 using Data_built\ENOE\ENOE_myoyaggin15.dta
drop _m
merge 1:1 quarter year geo2_mx2000 geo1_mx2000 using Data_built\ENOE\ENOE_myoyagg21p.dta
drop _m
merge 1:1 quarter year geo2_mx2000 geo1_mx2000 using Data_built\ENOE\ENOE_myoyagg1214.dta
drop _m
merge 1:1 quarter year geo2_mx2000 geo1_mx2000 using Data_built\ENOE\ENOE_myoyagg1517.dta
drop _m
merge 1:1 quarter year geo2_mx2000 geo1_mx2000 using Data_built\ENOE\ENOE_myoyagg1820.dta
drop _m
save Data_built\ENOE\ENOE_myoyagg.dta, replace

***** muni level yoy regressions


*****
*HH yoy regressions


use Data_built\ENOE\ENOE_myoyagg.dta, replace

rename (year quarter)(y_ent q_ent)

merge m:1  y_ent q_ent  geo2_mx2000 using Data_built\Matriculas\Shock_Mat_SecComm_Sanc_5merge.dta
keep if _m==3
drop _m

merge m:1  geo2_mx2000 using Data_built\ENOE\munpopweights.dta
*loosing some observations here
keep if _m==3
drop _m



gen yoy_sc_shock_5=sc_shock_5-l12_sc_5
gen yoy_sc_noweight_5=sc_noweight_5-l12_scnw_5



gen yoy_f1sc_shock_5=f12_sc_5-sc_shock_5
gen yoy_f1sc_noweight_5=f12_scnw_5-sc_noweight_5

gen yoy_f2sc_shock_5=f24_sc_5-f12_sc_5
gen yoy_f2sc_noweight_5=f24_scnw_5-f12_scnw_5

gen yoy_l1sc_shock_5=l12_sc_5-l24_sc_5
gen yoy_l1sc_noweight_5=l12_scnw_5-l24_scnw_5

gen yoy_l2sc_shock_5=l24_sc_5-l36_sc_5
gen yoy_l2sc_noweight_5=l24_scnw_5-l36_scnw_5


egen fes=concat(y_ent geo1_mx2000)

global fes fes geo2_mx2000 q_ent

egen qy_enta=concat(q_ent y_ent)
encode qy_enta, gen(qy_ent)

log using muniyoy, replace
set linesize 200
foreach y in myoy_hhdeparts1_mnhh1 myoy_hhdeparts2_sumhh1 myoy_hharrives1_mnhh5 myoy_hharrives2_sumhh5 myoy_hhsize_mnhh15 myoy_hhv_kids_mnhh15 myoy_hhv_teen_f_mnhh15 myoy_hhv_teen_m_mnhh15 myoy_hhv_youngadult_f_mnhh15 myoy_hhv_youngadult_m_mnhh15 myoy_hhv_adult_f_mnhh15 myoy_hhv_adult_m_mnhh15 myoy_hh_report_remit1_mnhh15 myoy_hh_earn_mo_mnhh15 myoy_hh_report_remit2_sumhh15 myoy_migrant1_mnin1 myoy_dom_migrant1_mnin1 myoy_disappears1_mnin1 myoy_migrant2_sumin1 myoy_dom_migrant2_sumin1 myoy_disappears2_sumin1 myoy_returnee1_mnin5 myoy_dom_returnee1_mnin5 myoy_appears1_mnin5 myoy_returnee2_sumin5 myoy_dom_returnee2_sumin5 myoy_appears2_sumin5 myoy_study1_mnin15 myoy_lfp1_mnin15 myoy_unempl1_mnin15 myoy_ls_hrs_mnin15 myoy_wage_hr_mnin15 myoy_inc_mo_mnin15 myoy_chores_mnin15 myoy_study_hrs_mnin15 myoy_enroll1_mnin15 myoy_logwage_hr_mnin15 myoy_study2_sumin15 myoy_lfp2_sumin15 myoy_unempl2_sumin15 myoy_enroll2_sumin15 myoy_study1_mn21p myoy_lfp1_mn21p myoy_unempl1_mn21p myoy_ls_hrs_mn21p myoy_wage_hr_mn21p myoy_inc_mo_mn21p myoy_chores_mn21p myoy_study_hrs_mn21p myoy_enroll1_mn21p myoy_logwage_hr_mn21p myoy_study2_sum21p myoy_lfp2_sum21p myoy_unempl2_sum21p myoy_enroll2_sum21p myoy_study1_mn1214 myoy_lfp1_mn1214 myoy_unempl1_mn1214 myoy_ls_hrs_mn1214 myoy_wage_hr_mn1214 myoy_inc_mo_mn1214 myoy_chores_mn1214 myoy_study_hrs_mn1214 myoy_enroll1_mn1214 myoy_logwage_hr_mn1214 myoy_study2_sum1214 myoy_lfp2_sum1214 myoy_unempl2_sum1214 myoy_enroll2_sum1214 myoy_study1_mn1517 myoy_lfp1_mn1517 myoy_unempl1_mn1517 myoy_ls_hrs_mn1517 myoy_wage_hr_mn1517 myoy_inc_mo_mn1517 myoy_chores_mn1517 myoy_study_hrs_mn1517 myoy_enroll1_mn1517 myoy_logwage_hr_mn1517 myoy_study2_sum1517 myoy_lfp2_sum1517 myoy_unempl2_sum1517 myoy_enroll2_sum1517 myoy_study1_mn1820 myoy_lfp1_mn1820 myoy_unempl1_mn1820 myoy_ls_hrs_mn1820 myoy_wage_hr_mn1820 myoy_inc_mo_mn1820 myoy_chores_mn1820 myoy_study_hrs_mn1820 myoy_enroll1_mn1820 myoy_logwage_hr_mn1820 myoy_study2_sum1820 myoy_lfp2_sum1820 myoy_unempl2_sum1820 myoy_enroll2_sum1820 {
	
	di "`y'"
eststo clear
eststo: quietly reghdfe `y' yoy_sc_shock_5 c.migr_share#i.qy_ent [aw=muni_popweights], a($fes) 
eststo: quietly reghdfe `y' yoy_sc_noweight_5 c.migr_share#i.qy_ent [aw=muni_popweights], a($fes)
eststo: quietly reghdfe `y' yoy_f2sc_shock_5 yoy_f1sc_shock_5 yoy_sc_shock_5  yoy_l1sc_shock_5  yoy_l2sc_shock_5 c.migr_share#i.qy_ent [aw=muni_popweights] , a($fes) 
eststo: quietly reghdfe `y' yoy_f2sc_noweight_5 yoy_f1sc_noweight_5 yoy_sc_noweight_5 yoy_l1sc_noweight_5 yoy_l2sc_noweight_5 c.migr_share#i.qy_ent [aw=muni_popweights], a($fes) 
eststo: quietly reghdfe pw`y' yoy_sc_shock_5 c.migr_share#i.qy_ent [aw=muni_popweights], a($fes) 
eststo: quietly reghdfe pw`y' yoy_sc_noweight_5 c.migr_share#i.qy_ent [aw=muni_popweights], a($fes)
eststo: quietly reghdfe pw`y' yoy_f2sc_shock_5 yoy_f1sc_shock_5 yoy_sc_shock_5  yoy_l1sc_shock_5  yoy_l2sc_shock_5 c.migr_share#i.qy_ent [aw=muni_popweights] , a($fes) 
eststo: quietly reghdfe pw`y' yoy_f2sc_noweight_5 yoy_f1sc_noweight_5 yoy_sc_noweight_5 yoy_l1sc_noweight_5 yoy_l2sc_noweight_5 c.migr_share#i.qy_ent [aw=muni_popweights], a($fes) 
esttab, se keep( yoy_sc_shock_5 yoy_sc_noweight_5 yoy_f2sc_shock_5 yoy_f1sc_shock_5  yoy_l1sc_shock_5  yoy_l2sc_shock_5 yoy_f2sc_noweight_5 yoy_f1sc_noweight_5  yoy_l1sc_noweight_5 yoy_l2sc_noweight_5)
}

log close




