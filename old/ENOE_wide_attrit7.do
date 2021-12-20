

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

*Output Files:

********************************************************************************
********************************************************************************
********************************************************************************
*select individual constants want to keep

use  Data_built\ENOE\wide_build.dta, replace
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

********************************************************************************

* minor modifications to the shocks file
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


********************************************************************************


********************************************************************************
*merging the wide builds and files built above

use  Data_built\ENOE\indiv_attrit_wide.dta
merge m:1 hh_id using  Data_built\ENOE\hh_attrit_wide.dta
keep if _m==3
drop _m

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



*****individual fiel
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

gen sk21p=0
replace sk21p=1  if bsline_age>=21 & bsline_edu>=9

gen lsk21p=0
replace lsk21p=1  if bsline_age>=21 & bsline_edu<9


save Data_built\ENOE\ind_attrit_FD.dta, replace
******************************************
cap erase Data_built\ENOE\wide_build_mini.dta
cap erase Data_built\ENOE\hh_attrit_FD.dta




********************************************************************************
********************************************************************************
********************************************************************************
********************************************************************************
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
*
foreach i in `3'{
local new = "pwm"+"`i'"+"_sum"+"`4'"
rename  `i'	`new'
}
*

tempfile saver
save `saver', replace

use Data_built\ENOE\ind_attrit_FD2.dta, clear
keep if `1'

collapse (mean) `2' (sum) `3' , by(quarter year geo2_mx2000 geo1_mx2000)

foreach i in `2'{
local new = "m"+"`i'"+"_mn"+"`4'"
rename `i'	`new'
}
*
foreach i in `3'{
local new = "m"+"`i'"+"_sum"+"`4'"
rename `i'	`new'
}
*

merge 1:1 quarter year geo2_mx2000 geo1_mx2000 using `saver'
drop _m
save "Data_built\ENOE\ENOE_myoyagg`4'.dta", replace
clear
end 


********************************************************************************
********************************************************************************
********************************************************************************
********************************************************************************


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
YOY_muniagg_subgroup_prog "fac_ent_1!=. & fac_ent_5!=. &  sk21p==1" "`meanindivent15'" "`sumindivent15'" "sk21p" "fac_ent_1"
YOY_muniagg_subgroup_prog "fac_ent_1!=. & fac_ent_5!=. &  lsk21p==1" "`meanindivent15'" "`sumindivent15'" "lsk21p" "fac_ent_1"


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
merge 1:1 quarter year geo2_mx2000 geo1_mx2000 using Data_built\ENOE\ENOE_myoyaggsk21p.dta
drop _m
merge 1:1 quarter year geo2_mx2000 geo1_mx2000 using Data_built\ENOE\ENOE_myoyagglsk21p.dta
drop _m
save Data_built\ENOE\ENOE_myoyagg.dta, replace

foreach y in hh5 hh15 in1 in5 in15 21p 1214 1517 1820 sk21p lsk21p {
cap erase "Data_built\ENOE\ENOE_myoyagg`y'.dta"
}
*

********************************************************************************
********************************************************************************
********************************************************************************
********************************************************************************
*hh AND individual ANALYSIS
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
*
********************************************************************************

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
*

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
*
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
*

********************************************************************************

***** muni level yoy regressions





global fes fes geo2_mx2000 q_ent



log using muniyoy, replace
set linesize 200
foreach y in myoy_hhdeparts1_mnhh1 myoy_hhdeparts2_sumhh1 myoy_hharrives1_mnhh5 myoy_hharrives2_sumhh5 myoy_hhsize_mnhh15 myoy_hhv_kids_mnhh15 myoy_hhv_teen_f_mnhh15 myoy_hhv_teen_m_mnhh15 myoy_hhv_youngadult_f_mnhh15 myoy_hhv_youngadult_m_mnhh15 myoy_hhv_adult_f_mnhh15 myoy_hhv_adult_m_mnhh15 myoy_hh_report_remit1_mnhh15 myoy_hh_earn_mo_mnhh15 myoy_hh_report_remit2_sumhh15 myoy_migrant1_mnin1 myoy_dom_migrant1_mnin1 myoy_disappears1_mnin1 myoy_migrant2_sumin1 myoy_dom_migrant2_sumin1 myoy_disappears2_sumin1 myoy_returnee1_mnin5 myoy_dom_returnee1_mnin5 myoy_appears1_mnin5 myoy_returnee2_sumin5 myoy_dom_returnee2_sumin5 myoy_appears2_sumin5 myoy_study1_mnin15 myoy_lfp1_mnin15 myoy_unempl1_mnin15 myoy_ls_hrs_mnin15 myoy_wage_hr_mnin15 myoy_inc_mo_mnin15 myoy_chores_mnin15 myoy_study_hrs_mnin15 myoy_enroll1_mnin15 myoy_logwage_hr_mnin15 myoy_study2_sumin15 myoy_lfp2_sumin15 myoy_unempl2_sumin15 myoy_enroll2_sumin15 myoy_study1_mn21p myoy_lfp1_mn21p myoy_unempl1_mn21p myoy_ls_hrs_mn21p myoy_wage_hr_mn21p myoy_inc_mo_mn21p myoy_chores_mn21p myoy_study_hrs_mn21p myoy_enroll1_mn21p myoy_logwage_hr_mn21p myoy_study2_sum21p myoy_lfp2_sum21p myoy_unempl2_sum21p myoy_enroll2_sum21p myoy_study1_mn1214  myoy_ls_hrs_mn1214 myoy_wage_hr_mn1214 myoy_inc_mo_mn1214 myoy_chores_mn1214 myoy_study_hrs_mn1214 myoy_enroll1_mn1214 myoy_logwage_hr_mn1214 myoy_study2_sum1214 myoy_lfp2_sum1214 myoy_unempl2_sum1214 myoy_enroll2_sum1214 myoy_study1_mn1517 myoy_lfp1_mn1517 myoy_unempl1_mn1517 myoy_ls_hrs_mn1517 myoy_wage_hr_mn1517 myoy_inc_mo_mn1517 myoy_chores_mn1517 myoy_study_hrs_mn1517 myoy_enroll1_mn1517 myoy_logwage_hr_mn1517 myoy_study2_sum1517 myoy_lfp2_sum1517 myoy_unempl2_sum1517 myoy_enroll2_sum1517 myoy_study1_mn1820 myoy_lfp1_mn1820 myoy_unempl1_mn1820 myoy_ls_hrs_mn1820 myoy_wage_hr_mn1820 myoy_inc_mo_mn1820 myoy_chores_mn1820 myoy_study_hrs_mn1820 myoy_enroll1_mn1820 myoy_logwage_hr_mn1820 myoy_study2_sum1820 myoy_lfp2_sum1820 myoy_unempl2_sum1820 myoy_enroll2_sum1820 {
	
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
*
log close

********************************************************************************


*******************************************
*Function writing
*******************************************
*generate a function the will use certain shock (5) to produce both weighted shocks/not weighted shock graphs for a particular dependent variable 
*funtion inputs: 
*`1' shocknumbr
*`2' outcome variable 
*`3' fe vector
*`4' control vector
*`5' "*" if so not want to produce all individual graphs. 
*
cap prog drop makegraph_yoy
prog def makegraph_yoy, rclass



local pw2 = "pw"+"`2'"
eststo clear
eststo: reghdfe `pw2'  yoy_f2sc_shock_5 yoy_f1sc_shock_5 yoy_sc_shock_5  yoy_l1sc_shock_5  yoy_l2sc_shock_5  $`4' [pw=muni_popweights], a($`3') 
local obs=e(N)
local N=e(N_clust)
sum year if e(sample)
local year_start = r(min)
local year_end = r(max)
local month_start = 1
local month_end = 12
estimates store beta_incr

coefplot , ///
  	vertical ///
  	keep (yoy_f2sc_shock_5 yoy_f1sc_shock_5 yoy_sc_shock_5  yoy_l1sc_shock_5  yoy_l2sc_shock_5) ///
  	coeflabel(yoy_f2sc_shock_5=yoyf2 yoy_f1sc_shock_5=yoyf1 yoy_sc_shock_5=yoy0  yoy_l1sc_shock_5=yoyl1  yoy_l2sc_shock_5=yoyl2) ///
  	xline(3, lpattern(dash) lwidth(thin) lcolor(black)) xlabel(,labsize(medlarge)) ///
 	yline(0, lcolor(black) lwidth(thin)) ylabel(,labsize(medlarge)) ///
 	graphregion(color(white)) ///
  	xtitle (" " "Secure communities shock in Year", size(medlarge)) ytitle (" " " ", size(medlarge)) ///
	legend(off) ///
	note(" " " Weighted shocks and population weights. Observations: `obs', Municipalities: `N', Period: `month_start'/`year_start' - `month_end'/`year_end'.", size(small)) ///
	saving(1, replace)
`5' graph export "Output/Graphs/selected/SC`1'_`2'_yoy_pw.pdf", replace


eststo clear
eststo: reghdfe  `pw2' myoy_hhdeparts1_mnhh1  yoy_f2sc_noweight_5 yoy_f1sc_noweight_5 yoy_sc_noweight_5 yoy_l1sc_noweight_5 yoy_l2sc_noweight_5  $`4' [pw=muni_popweights], a($`3') 
local obs=e(N)
local N=e(N_clust)
sum year if e(sample)
local year_start = r(min)
local year_end = r(max)
local month_start = 1
local month_end = 12
estimates store beta_incr

coefplot , ///
  	vertical ///
  	keep ( yoy_f2sc_noweight_5 yoy_f1sc_noweight_5 yoy_sc_noweight_5 yoy_l1sc_noweight_5 yoy_l2sc_noweight_5) ///
  	coeflabel(yoy_f2sc_noweight_5=yoynwf2 yoy_f1sc_noweight_5=yoynwf1 yoy_sc_noweight_5=yoynw0  yoy_l1sc_noweight_5=yoynwl1  yoy_l2sc_noweight_5=yoynwl2) ///
  	xline(3, lpattern(dash) lwidth(thin) lcolor(black)) xlabel(,labsize(medlarge)) ///
 	yline(0, lcolor(black) lwidth(thin)) ylabel(,labsize(medlarge)) ///
 	graphregion(color(white)) ///
  	xtitle (" " "Secure communities shock in Year", size(medlarge)) ytitle (" " " ", size(medlarge)) ///
	legend(off) ///
	note(" " " Unweighted shocks and population weights. Observations: `obs', Municipalities: `N', Period: `month_start'/`year_start' - `month_end'/`year_end'.", size(small)) ///
	saving(2, replace)
`5' graph export  "Output/Graphs/selected/SC`1'_`2'_yoy_noscwgt_pw.pdf", replace




eststo clear
eststo: reghdfe `2'  yoy_f2sc_shock_5 yoy_f1sc_shock_5 yoy_sc_shock_5  yoy_l1sc_shock_5  yoy_l2sc_shock_5 $`4' [pw=muni_popweights], a($`3') 
local obs=e(N)
local N=e(N_clust)
sum year if e(sample)
local year_start = r(min)
local year_end = r(max)
local month_start = 1
local month_end = 12
estimates store beta_incr

coefplot , ///
  	vertical ///
  	keep (yoy_f2sc_shock_5 yoy_f1sc_shock_5 yoy_sc_shock_5  yoy_l1sc_shock_5  yoy_l2sc_shock_5) ///
  	coeflabel(yoy_f2sc_shock_5=yoyf2 yoy_f1sc_shock_5=yoyf1 yoy_sc_shock_5=yoy0  yoy_l1sc_shock_5=yoyl1  yoy_l2sc_shock_5=yoyl2) ///
  	xline(3, lpattern(dash) lwidth(thin) lcolor(black)) xlabel(,labsize(medlarge)) ///
 	yline(0, lcolor(black) lwidth(thin)) ylabel(,labsize(medlarge)) ///
 	graphregion(color(white)) ///
  	xtitle (" " "Secure communities shock in Year", size(medlarge)) ytitle (" " " ", size(medlarge)) ///
	legend(off) ///
	note(" " " Weighted shocks and no population weights. Observations: `obs', Municipalities: `N', Period: `month_start'/`year_start' - `month_end'/`year_end'.", size(small)) ///
	saving(3, replace)
`5' graph export "Output/Graphs/selected/SC`1'_`2'_yoy.pdf", replace

eststo clear
eststo: reghdfe `2' myoy_hhdeparts1_mnhh1  yoy_f2sc_noweight_5 yoy_f1sc_noweight_5 yoy_sc_noweight_5 yoy_l1sc_noweight_5 yoy_l2sc_noweight_5  $`4' [pw=muni_popweights], a($`3') 
local obs=e(N)
local N=e(N_clust)
sum year if e(sample)
local year_start = r(min)
local year_end = r(max)
local month_start = 1
local month_end = 12
estimates store beta_incr

coefplot , ///
  	vertical ///
  	keep ( yoy_f2sc_noweight_5 yoy_f1sc_noweight_5 yoy_sc_noweight_5 yoy_l1sc_noweight_5 yoy_l2sc_noweight_5) ///
  	coeflabel(yoy_f2sc_noweight_5=yoynwf2 yoy_f1sc_noweight_5=yoynwf1 yoy_sc_noweight_5=yoynw0  yoy_l1sc_noweight_5=yoynwl1  yoy_l2sc_noweight_5=yoynwl2) ///
  	xline(3, lpattern(dash) lwidth(thin) lcolor(black)) xlabel(,labsize(medlarge)) ///
 	yline(0, lcolor(black) lwidth(thin)) ylabel(,labsize(medlarge)) ///
 	graphregion(color(white)) ///
  	xtitle (" " "Secure communities shock in Year", size(medlarge)) ytitle (" " " ", size(medlarge)) ///
	legend(off) ///
	note(" " "Unweighted shocks and no population weights. Observations: `obs', Municipalities: `N', Period: `month_start'/`year_start' - `month_end'/`year_end'.", size(small)) ///
	saving(4, replace)
`5' graph export  "Output/Graphs/selected/SC`1'_`2'_yoy_noscwgt.pdf", replace



 gr combine  1.gph 2.gph 3.gph 4.gph, title("`2'")
 
 gr export "Output/Graphs/selected/SC`1'_`2'_yoy.pdf",replace

end



global fe i.int_yq i.year##i.geo1_mx2000 /*i.geo2_mx2000*/
global controls c.migr_share#i.int_yq


foreach y in myoy_hhdeparts1_mnhh1 myoy_hhdeparts2_sumhh1 myoy_hharrives1_mnhh5 myoy_hharrives2_sumhh5 myoy_hhsize_mnhh15 myoy_hhv_kids_mnhh15 myoy_hhv_teen_f_mnhh15 myoy_hhv_teen_m_mnhh15 myoy_hhv_youngadult_f_mnhh15 myoy_hhv_youngadult_m_mnhh15 myoy_hhv_adult_f_mnhh15 myoy_hhv_adult_m_mnhh15 myoy_hh_report_remit1_mnhh15 myoy_hh_earn_mo_mnhh15 myoy_hh_report_remit2_sumhh15 myoy_migrant1_mnin1 myoy_dom_migrant1_mnin1 myoy_disappears1_mnin1 myoy_migrant2_sumin1 myoy_dom_migrant2_sumin1 myoy_disappears2_sumin1 myoy_returnee1_mnin5 myoy_dom_returnee1_mnin5 myoy_appears1_mnin5 myoy_returnee2_sumin5 myoy_dom_returnee2_sumin5 myoy_appears2_sumin5 myoy_study1_mnin15 myoy_lfp1_mnin15 myoy_unempl1_mnin15 myoy_ls_hrs_mnin15 myoy_wage_hr_mnin15 myoy_inc_mo_mnin15 myoy_chores_mnin15 myoy_study_hrs_mnin15 myoy_enroll1_mnin15 myoy_logwage_hr_mnin15 myoy_study2_sumin15 myoy_lfp2_sumin15 myoy_unempl2_sumin15 myoy_enroll2_sumin15 myoy_study1_mn21p myoy_lfp1_mn21p myoy_unempl1_mn21p myoy_ls_hrs_mn21p myoy_wage_hr_mn21p myoy_inc_mo_mn21p myoy_chores_mn21p myoy_study_hrs_mn21p myoy_enroll1_mn21p myoy_logwage_hr_mn21p myoy_study2_sum21p myoy_lfp2_sum21p myoy_unempl2_sum21p myoy_enroll2_sum21p myoy_study1_mn1214  myoy_ls_hrs_mn1214 myoy_wage_hr_mn1214 myoy_inc_mo_mn1214 myoy_chores_mn1214 myoy_study_hrs_mn1214 myoy_enroll1_mn1214 myoy_logwage_hr_mn1214 myoy_study2_sum1214 myoy_lfp2_sum1214 myoy_unempl2_sum1214 myoy_enroll2_sum1214 myoy_study1_mn1517 myoy_lfp1_mn1517 myoy_unempl1_mn1517 myoy_ls_hrs_mn1517 myoy_wage_hr_mn1517 myoy_inc_mo_mn1517 myoy_chores_mn1517 myoy_study_hrs_mn1517 myoy_enroll1_mn1517 myoy_logwage_hr_mn1517 myoy_study2_sum1517 myoy_lfp2_sum1517 myoy_unempl2_sum1517 myoy_enroll2_sum1517 myoy_study1_mn1820 myoy_lfp1_mn1820 myoy_unempl1_mn1820 myoy_ls_hrs_mn1820 myoy_wage_hr_mn1820 myoy_inc_mo_mn1820 myoy_chores_mn1820 myoy_study_hrs_mn1820 myoy_enroll1_mn1820 myoy_logwage_hr_mn1820 myoy_study2_sum1820 myoy_lfp2_sum1820 myoy_unempl2_sum1820 myoy_enroll2_sum1820 myoy_study1_mnsk21p myoy_lfp1_mnsk21p myoy_unempl1_mnsk21p myoy_ls_hrs_mnsk21p myoy_wage_hr_mnsk21p myoy_inc_mo_mnsk21p myoy_chores_mnsk21p myoy_study_hrs_mnsk21p myoy_enroll1_mnsk21p myoy_logwage_hr_mnsk21p myoy_study2_sumsk21p myoy_lfp2_sumsk21p myoy_unempl2_sumsk21p myoy_enroll2_sumsk21p myoy_study1_mnlsk21p myoy_lfp1_mnlsk21p myoy_unempl1_mnlsk21p myoy_ls_hrs_mnlsk21p myoy_wage_hr_mnlsk21p myoy_inc_mo_mnlsk21p myoy_chores_mnlsk21p myoy_study_hrs_mnlsk21p myoy_enroll1_mnlsk21p myoy_logwage_hr_mnlsk21p myoy_study2_sumlsk21p myoy_lfp2_sumlsk21p myoy_unempl2_sumlsk21p myoy_enroll2_sumlsk21p {
makegraph_yoy 5 `y' fe controls "*"
}


























*******************************************
*Function writing
*******************************************
*generate a function the will use certain shock (5) to produce both weighted shocks/not weighted shock graphs for a particular dependent variable 
*funtion inputs: 
*`1' shocknumbr
*`2' outcome variable 
*`3' fe vector
*`4' control vector
*`5' "*" if so not want to produce all individual graphs. 
*
cap prog drop makegraph_yoy
prog def makegraph_yoy, rclass


*use Data_built\ENOE\ENOE_muniagg_prog.dta, clear

*get pw variable name

local pw2 = "pw"+"`2'"

eststo clear
eststo: reghdfe `pw2'  yoy_f2sc_shock_5 yoy_f1sc_shock_5 yoy_sc_shock_5  yoy_l1sc_shock_5  yoy_l2sc_shock_5 $`4' [pw=muni_popweights], a($`3') cluster(geo2_mx2000)
local obs=e(N)
local N=e(N_clust)
sum year if e(sample)
local year_start = r(min)
local year_end = r(max)
local month_start = 1
local month_end = 12

nlcom ///
	(-(_b[sc_shock_]+_b[f6_sc_]+_b[f12_sc_]+_b[f18_sc_])) ///
	(-(_b[sc_shock_]+_b[f6_sc_]+_b[f12_sc_])) ///
	(-(_b[sc_shock_]+_b[f6_sc_])) ///
	(-_b[sc_shock_]) ///
	(0) ///
	(_b[l6_sc_]) ///
	(_b[l6_sc_]+_b[l12_sc_]) ///
	(_b[l6_sc_]+_b[l12_sc_]+_b[l18_sc_]) ///
	(_b[l6_sc_]+_b[l12_sc_]+_b[l18_sc_]+_b[l24_sc_]) /// 
	(_b[l6_sc_]+_b[l12_sc_]+_b[l18_sc_]+_b[l24_sc_]+_b[l30_sc_]) ///
	(_b[l6_sc_]+_b[l12_sc_]+_b[l18_sc_]+_b[l24_sc_]+_b[l30_sc_]+_b[l36_sc_]) ///
	(_b[l6_sc_]+_b[l12_sc_]+_b[l18_sc_]+_b[l24_sc_]+_b[l30_sc_]+_b[l36_sc_]+_b[l42_sc_]) ///
	, post level(90)

estimates store beta_incr

* plot beta coefficients
coefplot (beta_incr, ciopts(recast(rcap)) recast(connected) level(90)), ///
  	vertical ///
  	keep (_nl_*) ///
  	coeflabel(_nl_1 = -24 _nl_2 = -18 _nl_3 = -12 _nl_4 = -6 _nl_5 = 0 _nl_6 = 6 _nl_7 = 12 _nl_8 = 18 _nl_9 = 24 _nl_10 = 30 _nl_11 = 36 _nl_12 = 42) ///
  	xline(5, lpattern(dash) lwidth(thin) lcolor(black)) xlabel(,labsize(medlarge)) ///
 	yline(0, lcolor(black) lwidth(thin)) ylabel(,labsize(medlarge)) ///
 	graphregion(color(white)) ///
  	xtitle (" " "Months relative to Secure communities shock", size(medlarge)) ytitle (" " " ", size(medlarge)) ///
	legend(off) ///
	note(" " " Weighted shocks and population weights. Observations: `obs', Municipalities: `N', Period: `month_start'/`year_start' - `month_end'/`year_end'.", size(small)) ///
	saving(1, replace)
`5' graph export "Output/Graphs/selected/SC`1'_`2'_norm0_pw.pdf", replace

eststo clear
eststo clear
eststo: reghdfe `pw2' f18_scnw_`1' f12_scnw_`1' f6_scnw_`1' sc_noweight_`1' l6_scnw_`1' l12_scnw_`1' l18_scnw_`1' l24_scnw_`1' l30_scnw_`1' l36_scnw_`1'  $`4' [pw=muni_popweights], a($`3') cluster(geo2_mx2000)
local obs=e(N)
local N=e(N_clust)
sum year if e(sample)
local year_start = r(min)
local year_end = r(max)
local month_start = 1
local month_end = 12

nlcom ///
	(-(_b[sc_noweight_]+_b[f6_scnw_]+_b[f12_scnw_]+_b[f18_scnw_])) ///
	(-(_b[sc_noweight_]+_b[f6_scnw_]+_b[f12_scnw_])) ///
	(-(_b[sc_noweight_]+_b[f6_scnw_])) ///
	(-_b[sc_noweight_]) ///
	(0) ///
	(_b[l6_scnw_]) ///
	(_b[l6_scnw_]+_b[l12_scnw_]) ///
	(_b[l6_scnw_]+_b[l12_scnw_]+_b[l18_scnw_]) ///
	(_b[l6_scnw_]+_b[l12_scnw_]+_b[l18_scnw_]+_b[l24_scnw_]) /// 
	(_b[l6_scnw_]+_b[l12_scnw_]+_b[l18_scnw_]+_b[l24_scnw_]+_b[l30_scnw_]) ///
	(_b[l6_scnw_]+_b[l12_scnw_]+_b[l18_scnw_]+_b[l24_scnw_]+_b[l30_scnw_]+_b[l36_scnw_]) ///
	, post level(90)

estimates store beta_incr

* plot beta coefficients
coefplot (beta_incr, ciopts(recast(rcap)) recast(connected) level(90)), ///
  	vertical ///
  	keep (_nl_*) ///
  	coeflabel(_nl_1 = -24 _nl_2 = -18 _nl_3 = -12 _nl_4 = -6 _nl_5 = 0 _nl_6 = 6 _nl_7 = 12 _nl_8 = 18 _nl_9 = 24 _nl_10 = 30 _nl_11 = 36 ) ///
  	xline(5, lpattern(dash) lwidth(thin) lcolor(black)) xlabel(,labsize(medlarge)) ///
 	yline(0, lcolor(black) lwidth(thin)) ylabel(,labsize(medlarge)) ///
 	graphregion(color(white)) ///
  	xtitle (" " "Months relative to Secure communities shock", size(medlarge)) ytitle (" " " ", size(medlarge)) ///
	legend(off) ///
	note(" " "Unweighted shocks and population weights. Observations: `obs', Municipalities: `N', Period: `month_start'/`year_start' - `month_end'/`year_end'.  ", size(small))	///
	saving(2, replace)
`5' graph export "Output/Graphs/selected/SC`1'_`2'_norm0_noscwgt_pw.pdf", replace



***************************

***with no probability weights
eststo clear
eststo: reghdfe `2' f18_sc_`1' f12_sc_`1' f6_sc_`1' sc_shock_`1' l6_sc_`1' l12_sc_`1' l18_sc_`1' l24_sc_`1' l30_sc_`1' l36_sc_`1'  $`4' [pw=muni_popweights], a($`3') cluster(geo2_mx2000)
local obs=e(N)
local N=e(N_clust)
sum year if e(sample)
local year_start = r(min)
local year_end = r(max)
local month_start = 1
local month_end = 12

nlcom ///
	(-(_b[sc_shock_]+_b[f6_sc_]+_b[f12_sc_]+_b[f18_sc_])) ///
	(-(_b[sc_shock_]+_b[f6_sc_]+_b[f12_sc_])) ///
	(-(_b[sc_shock_]+_b[f6_sc_])) ///
	(-_b[sc_shock_]) ///
	(0) ///
	(_b[l6_sc_]) ///
	(_b[l6_sc_]+_b[l12_sc_]) ///
	(_b[l6_sc_]+_b[l12_sc_]+_b[l18_sc_]) ///
	(_b[l6_sc_]+_b[l12_sc_]+_b[l18_sc_]+_b[l24_sc_]) /// 
	(_b[l6_sc_]+_b[l12_sc_]+_b[l18_sc_]+_b[l24_sc_]+_b[l30_sc_]) ///
	(_b[l6_sc_]+_b[l12_sc_]+_b[l18_sc_]+_b[l24_sc_]+_b[l30_sc_]+_b[l36_sc_]) ///
	, post level(90)

estimates store beta_incr

* plot beta coefficients
coefplot (beta_incr, ciopts(recast(rcap)) recast(connected) level(90)), ///
  	vertical ///
  	keep (_nl_*) ///
  	coeflabel(_nl_1 = -24 _nl_2 = -18 _nl_3 = -12 _nl_4 = -6 _nl_5 = 0 _nl_6 = 6 _nl_7 = 12 _nl_8 = 18 _nl_9 = 24 _nl_10 = 30 _nl_11 = 36 ) ///
  	xline(5, lpattern(dash) lwidth(thin) lcolor(black)) xlabel(,labsize(medlarge)) ///
 	yline(0, lcolor(black) lwidth(thin)) ylabel(,labsize(medlarge)) ///
 	graphregion(color(white)) ///
  	xtitle (" " "Months relative to Secure communities shock", size(medlarge)) ytitle (" " " ", size(medlarge)) ///
	legend(off) ///
	note(" " " Weighted shocks and no population weights. Observations: `obs', Municipalities: `N', Period: `month_start'/`year_start' - `month_end'/`year_end'.", size(small)) ///
	saving(3, replace)
`5' graph export "Output/Graphs/selected/SC`1'_`2'_norm0_nopw.pdf", replace

eststo clear
eststo clear
eststo: reghdfe `2' f18_scnw_`1' f12_scnw_`1' f6_scnw_`1' sc_noweight_`1' l6_scnw_`1' l12_scnw_`1' l18_scnw_`1' l24_scnw_`1' l30_scnw_`1' l36_scnw_`1'  $`4' [pw=muni_popweights], a($`3') cluster(geo2_mx2000)
local obs=e(N)
local N=e(N_clust)
sum year if e(sample)
local year_start = r(min)
local year_end = r(max)
local month_start = 1
local month_end = 12

nlcom ///
	(-(_b[sc_noweight_]+_b[f6_scnw_]+_b[f12_scnw_]+_b[f18_scnw_])) ///
	(-(_b[sc_noweight_]+_b[f6_scnw_]+_b[f12_scnw_])) ///
	(-(_b[sc_noweight_]+_b[f6_scnw_])) ///
	(-_b[sc_noweight_]) ///
	(0) ///
	(_b[l6_scnw_]) ///
	(_b[l6_scnw_]+_b[l12_scnw_]) ///
	(_b[l6_scnw_]+_b[l12_scnw_]+_b[l18_scnw_]) ///
	(_b[l6_scnw_]+_b[l12_scnw_]+_b[l18_scnw_]+_b[l24_scnw_]) /// 
	(_b[l6_scnw_]+_b[l12_scnw_]+_b[l18_scnw_]+_b[l24_scnw_]+_b[l30_scnw_]) ///
	(_b[l6_scnw_]+_b[l12_scnw_]+_b[l18_scnw_]+_b[l24_scnw_]+_b[l30_scnw_]+_b[l36_scnw_]) ///
	, post level(90)

estimates store beta_incr

* plot beta coefficients
coefplot (beta_incr, ciopts(recast(rcap)) recast(connected) level(90)), ///
  	vertical ///
  	keep (_nl_*) ///
  	coeflabel(_nl_1 = -24 _nl_2 = -18 _nl_3 = -12 _nl_4 = -6 _nl_5 = 0 _nl_6 = 6 _nl_7 = 12 _nl_8 = 18 _nl_9 = 24 _nl_10 = 30 _nl_11 = 36 ) ///
  	xline(5, lpattern(dash) lwidth(thin) lcolor(black)) xlabel(,labsize(medlarge)) ///
 	yline(0, lcolor(black) lwidth(thin)) ylabel(,labsize(medlarge)) ///
 	graphregion(color(white)) ///
  	xtitle (" " "Months relative to Secure communities shock", size(medlarge)) ytitle (" " " ", size(medlarge)) ///
	legend(off) ///
	note(" " "Unweighted shocks and no population weights. Observations: `obs', Municipalities: `N', Period: `month_start'/`year_start' - `month_end'/`year_end'.  ", size(small))	///
	saving(4, replace)
`5' graph export "Output/Graphs/selected/SC`1'_`2'_norm0_noscwgt_nopw.pdf", replace

****combingin all iterations

 gr combine  1.gph 2.gph 3.gph 4.gph, title("`2'")
 
 gr export "Output/Graphs/selected/SC`1'_`2'_norm0.pdf",replace

end

***************************************************************************************
***************************************************************************************
***************************************************************************************
***************************************************************************************
***************************************************************************************
***************************************************************************************






















*******************************************
*Function writing
*******************************************
*generate a function the will use certain shock (5) to produce both weighted shocks/not weighted shock graphs for a particular dependent variable 
*funtion inputs: 
*`1' shocknumbr
*`2' outcome variable 
*`3' fe vector
*`4' control vector
*`5' "*" if so not want to produce all individual graphs. 
*
cap prog drop makegraph_1
prog def makegraph_1, rclass


*use Data_built\ENOE\ENOE_muniagg_prog.dta, clear

*get pw variable name

local pw2 = "pw"+"`2'"

eststo clear
eststo: reghdfe `pw2' f18_sc_`1' f12_sc_`1' f6_sc_`1' sc_shock_`1' l6_sc_`1' l12_sc_`1' l18_sc_`1' l24_sc_`1' l30_sc_`1' l36_sc_`1' l42_sc_`1' $`4' [pw=muni_popweights], a($`3') cluster(geo2_mx2000)
local obs=e(N)
local N=e(N_clust)
sum year if e(sample)
local year_start = r(min)
local year_end = r(max)
local month_start = 1
local month_end = 12

nlcom ///
	(-(_b[sc_shock_]+_b[f6_sc_]+_b[f12_sc_]+_b[f18_sc_])) ///
	(-(_b[sc_shock_]+_b[f6_sc_]+_b[f12_sc_])) ///
	(-(_b[sc_shock_]+_b[f6_sc_])) ///
	(-_b[sc_shock_]) ///
	(0) ///
	(_b[l6_sc_]) ///
	(_b[l6_sc_]+_b[l12_sc_]) ///
	(_b[l6_sc_]+_b[l12_sc_]+_b[l18_sc_]) ///
	(_b[l6_sc_]+_b[l12_sc_]+_b[l18_sc_]+_b[l24_sc_]) /// 
	(_b[l6_sc_]+_b[l12_sc_]+_b[l18_sc_]+_b[l24_sc_]+_b[l30_sc_]) ///
	(_b[l6_sc_]+_b[l12_sc_]+_b[l18_sc_]+_b[l24_sc_]+_b[l30_sc_]+_b[l36_sc_]) ///
	(_b[l6_sc_]+_b[l12_sc_]+_b[l18_sc_]+_b[l24_sc_]+_b[l30_sc_]+_b[l36_sc_]+_b[l42_sc_]) ///
	, post level(90)

estimates store beta_incr

* plot beta coefficients
coefplot (beta_incr, ciopts(recast(rcap)) recast(connected) level(90)), ///
  	vertical ///
  	keep (_nl_*) ///
  	coeflabel(_nl_1 = -24 _nl_2 = -18 _nl_3 = -12 _nl_4 = -6 _nl_5 = 0 _nl_6 = 6 _nl_7 = 12 _nl_8 = 18 _nl_9 = 24 _nl_10 = 30 _nl_11 = 36 _nl_12 = 42) ///
  	xline(5, lpattern(dash) lwidth(thin) lcolor(black)) xlabel(,labsize(medlarge)) ///
 	yline(0, lcolor(black) lwidth(thin)) ylabel(,labsize(medlarge)) ///
 	graphregion(color(white)) ///
  	xtitle (" " "Months relative to Secure communities shock", size(medlarge)) ytitle (" " " ", size(medlarge)) ///
	legend(off) ///
	note(" " " Weighted shocks and population weights. Observations: `obs', Municipalities: `N', Period: `month_start'/`year_start' - `month_end'/`year_end'.", size(small)) ///
	saving(1, replace)
`5' graph export "Output/Graphs/selected/SC`1'_`2'_norm0_pw.pdf", replace

eststo clear
eststo clear
eststo: reghdfe `pw2' f18_scnw_`1' f12_scnw_`1' f6_scnw_`1' sc_noweight_`1' l6_scnw_`1' l12_scnw_`1' l18_scnw_`1' l24_scnw_`1' l30_scnw_`1' l36_scnw_`1'  $`4' [pw=muni_popweights], a($`3') cluster(geo2_mx2000)
local obs=e(N)
local N=e(N_clust)
sum year if e(sample)
local year_start = r(min)
local year_end = r(max)
local month_start = 1
local month_end = 12

nlcom ///
	(-(_b[sc_noweight_]+_b[f6_scnw_]+_b[f12_scnw_]+_b[f18_scnw_])) ///
	(-(_b[sc_noweight_]+_b[f6_scnw_]+_b[f12_scnw_])) ///
	(-(_b[sc_noweight_]+_b[f6_scnw_])) ///
	(-_b[sc_noweight_]) ///
	(0) ///
	(_b[l6_scnw_]) ///
	(_b[l6_scnw_]+_b[l12_scnw_]) ///
	(_b[l6_scnw_]+_b[l12_scnw_]+_b[l18_scnw_]) ///
	(_b[l6_scnw_]+_b[l12_scnw_]+_b[l18_scnw_]+_b[l24_scnw_]) /// 
	(_b[l6_scnw_]+_b[l12_scnw_]+_b[l18_scnw_]+_b[l24_scnw_]+_b[l30_scnw_]) ///
	(_b[l6_scnw_]+_b[l12_scnw_]+_b[l18_scnw_]+_b[l24_scnw_]+_b[l30_scnw_]+_b[l36_scnw_]) ///
	, post level(90)

estimates store beta_incr

* plot beta coefficients
coefplot (beta_incr, ciopts(recast(rcap)) recast(connected) level(90)), ///
  	vertical ///
  	keep (_nl_*) ///
  	coeflabel(_nl_1 = -24 _nl_2 = -18 _nl_3 = -12 _nl_4 = -6 _nl_5 = 0 _nl_6 = 6 _nl_7 = 12 _nl_8 = 18 _nl_9 = 24 _nl_10 = 30 _nl_11 = 36 ) ///
  	xline(5, lpattern(dash) lwidth(thin) lcolor(black)) xlabel(,labsize(medlarge)) ///
 	yline(0, lcolor(black) lwidth(thin)) ylabel(,labsize(medlarge)) ///
 	graphregion(color(white)) ///
  	xtitle (" " "Months relative to Secure communities shock", size(medlarge)) ytitle (" " " ", size(medlarge)) ///
	legend(off) ///
	note(" " "Unweighted shocks and population weights. Observations: `obs', Municipalities: `N', Period: `month_start'/`year_start' - `month_end'/`year_end'.  ", size(small))	///
	saving(2, replace)
`5' graph export "Output/Graphs/selected/SC`1'_`2'_norm0_noscwgt_pw.pdf", replace



***************************

***with no probability weights
eststo clear
eststo: reghdfe `2' f18_sc_`1' f12_sc_`1' f6_sc_`1' sc_shock_`1' l6_sc_`1' l12_sc_`1' l18_sc_`1' l24_sc_`1' l30_sc_`1' l36_sc_`1'  $`4' [pw=muni_popweights], a($`3') cluster(geo2_mx2000)
local obs=e(N)
local N=e(N_clust)
sum year if e(sample)
local year_start = r(min)
local year_end = r(max)
local month_start = 1
local month_end = 12

nlcom ///
	(-(_b[sc_shock_]+_b[f6_sc_]+_b[f12_sc_]+_b[f18_sc_])) ///
	(-(_b[sc_shock_]+_b[f6_sc_]+_b[f12_sc_])) ///
	(-(_b[sc_shock_]+_b[f6_sc_])) ///
	(-_b[sc_shock_]) ///
	(0) ///
	(_b[l6_sc_]) ///
	(_b[l6_sc_]+_b[l12_sc_]) ///
	(_b[l6_sc_]+_b[l12_sc_]+_b[l18_sc_]) ///
	(_b[l6_sc_]+_b[l12_sc_]+_b[l18_sc_]+_b[l24_sc_]) /// 
	(_b[l6_sc_]+_b[l12_sc_]+_b[l18_sc_]+_b[l24_sc_]+_b[l30_sc_]) ///
	(_b[l6_sc_]+_b[l12_sc_]+_b[l18_sc_]+_b[l24_sc_]+_b[l30_sc_]+_b[l36_sc_]) ///
	, post level(90)

estimates store beta_incr

* plot beta coefficients
coefplot (beta_incr, ciopts(recast(rcap)) recast(connected) level(90)), ///
  	vertical ///
  	keep (_nl_*) ///
  	coeflabel(_nl_1 = -24 _nl_2 = -18 _nl_3 = -12 _nl_4 = -6 _nl_5 = 0 _nl_6 = 6 _nl_7 = 12 _nl_8 = 18 _nl_9 = 24 _nl_10 = 30 _nl_11 = 36 ) ///
  	xline(5, lpattern(dash) lwidth(thin) lcolor(black)) xlabel(,labsize(medlarge)) ///
 	yline(0, lcolor(black) lwidth(thin)) ylabel(,labsize(medlarge)) ///
 	graphregion(color(white)) ///
  	xtitle (" " "Months relative to Secure communities shock", size(medlarge)) ytitle (" " " ", size(medlarge)) ///
	legend(off) ///
	note(" " " Weighted shocks and no population weights. Observations: `obs', Municipalities: `N', Period: `month_start'/`year_start' - `month_end'/`year_end'.", size(small)) ///
	saving(3, replace)
`5' graph export "Output/Graphs/selected/SC`1'_`2'_norm0_nopw.pdf", replace

eststo clear
eststo clear
eststo: reghdfe `2' f18_scnw_`1' f12_scnw_`1' f6_scnw_`1' sc_noweight_`1' l6_scnw_`1' l12_scnw_`1' l18_scnw_`1' l24_scnw_`1' l30_scnw_`1' l36_scnw_`1'  $`4' [pw=muni_popweights], a($`3') cluster(geo2_mx2000)
local obs=e(N)
local N=e(N_clust)
sum year if e(sample)
local year_start = r(min)
local year_end = r(max)
local month_start = 1
local month_end = 12

nlcom ///
	(-(_b[sc_noweight_]+_b[f6_scnw_]+_b[f12_scnw_]+_b[f18_scnw_])) ///
	(-(_b[sc_noweight_]+_b[f6_scnw_]+_b[f12_scnw_])) ///
	(-(_b[sc_noweight_]+_b[f6_scnw_])) ///
	(-_b[sc_noweight_]) ///
	(0) ///
	(_b[l6_scnw_]) ///
	(_b[l6_scnw_]+_b[l12_scnw_]) ///
	(_b[l6_scnw_]+_b[l12_scnw_]+_b[l18_scnw_]) ///
	(_b[l6_scnw_]+_b[l12_scnw_]+_b[l18_scnw_]+_b[l24_scnw_]) /// 
	(_b[l6_scnw_]+_b[l12_scnw_]+_b[l18_scnw_]+_b[l24_scnw_]+_b[l30_scnw_]) ///
	(_b[l6_scnw_]+_b[l12_scnw_]+_b[l18_scnw_]+_b[l24_scnw_]+_b[l30_scnw_]+_b[l36_scnw_]) ///
	, post level(90)

estimates store beta_incr

* plot beta coefficients
coefplot (beta_incr, ciopts(recast(rcap)) recast(connected) level(90)), ///
  	vertical ///
  	keep (_nl_*) ///
  	coeflabel(_nl_1 = -24 _nl_2 = -18 _nl_3 = -12 _nl_4 = -6 _nl_5 = 0 _nl_6 = 6 _nl_7 = 12 _nl_8 = 18 _nl_9 = 24 _nl_10 = 30 _nl_11 = 36 ) ///
  	xline(5, lpattern(dash) lwidth(thin) lcolor(black)) xlabel(,labsize(medlarge)) ///
 	yline(0, lcolor(black) lwidth(thin)) ylabel(,labsize(medlarge)) ///
 	graphregion(color(white)) ///
  	xtitle (" " "Months relative to Secure communities shock", size(medlarge)) ytitle (" " " ", size(medlarge)) ///
	legend(off) ///
	note(" " "Unweighted shocks and no population weights. Observations: `obs', Municipalities: `N', Period: `month_start'/`year_start' - `month_end'/`year_end'.  ", size(small))	///
	saving(4, replace)
`5' graph export "Output/Graphs/selected/SC`1'_`2'_norm0_noscwgt_nopw.pdf", replace

****combingin all iterations

 gr combine  1.gph 2.gph 3.gph 4.gph, title("`2'")
 
 gr export "Output/Graphs/selected/SC`1'_`2'_norm0.pdf",replace

end

***************************************************************************************
***************************************************************************************
***************************************************************************************
***************************************************************************************
***************************************************************************************
***************************************************************************************



***************************************************************************************
*MAKING GRAPHS
***************************************************************************************


global fe i.int_yq i.year##i.geo1_mx2000 i.geo2_mx2000
global controls c.migr_share#i.int_yq





foreach y in myoy_hhdeparts1_mnhh1 myoy_hhdeparts2_sumhh1 myoy_hharrives1_mnhh5 myoy_hharrives2_sumhh5 myoy_hhsize_mnhh15 myoy_hhv_kids_mnhh15 myoy_hhv_teen_f_mnhh15 myoy_hhv_teen_m_mnhh15 myoy_hhv_youngadult_f_mnhh15 myoy_hhv_youngadult_m_mnhh15 myoy_hhv_adult_f_mnhh15 myoy_hhv_adult_m_mnhh15 myoy_hh_report_remit1_mnhh15 myoy_hh_earn_mo_mnhh15 myoy_hh_report_remit2_sumhh15 myoy_migrant1_mnin1 myoy_dom_migrant1_mnin1 myoy_disappears1_mnin1 myoy_migrant2_sumin1 myoy_dom_migrant2_sumin1 myoy_disappears2_sumin1 myoy_returnee1_mnin5 myoy_dom_returnee1_mnin5 myoy_appears1_mnin5 myoy_returnee2_sumin5 myoy_dom_returnee2_sumin5 myoy_appears2_sumin5 myoy_study1_mnin15 myoy_lfp1_mnin15 myoy_unempl1_mnin15 myoy_ls_hrs_mnin15 myoy_wage_hr_mnin15 myoy_inc_mo_mnin15 myoy_chores_mnin15 myoy_study_hrs_mnin15 myoy_enroll1_mnin15 myoy_logwage_hr_mnin15 myoy_study2_sumin15 myoy_lfp2_sumin15 myoy_unempl2_sumin15 myoy_enroll2_sumin15 myoy_study1_mn21p myoy_lfp1_mn21p myoy_unempl1_mn21p myoy_ls_hrs_mn21p myoy_wage_hr_mn21p myoy_inc_mo_mn21p myoy_chores_mn21p myoy_study_hrs_mn21p myoy_enroll1_mn21p myoy_logwage_hr_mn21p myoy_study2_sum21p myoy_lfp2_sum21p myoy_unempl2_sum21p myoy_enroll2_sum21p myoy_study1_mn1214  myoy_ls_hrs_mn1214 myoy_wage_hr_mn1214 myoy_inc_mo_mn1214 myoy_chores_mn1214 myoy_study_hrs_mn1214 myoy_enroll1_mn1214 myoy_logwage_hr_mn1214 myoy_study2_sum1214 myoy_lfp2_sum1214 myoy_unempl2_sum1214 myoy_enroll2_sum1214 myoy_study1_mn1517 myoy_lfp1_mn1517 myoy_unempl1_mn1517 myoy_ls_hrs_mn1517 myoy_wage_hr_mn1517 myoy_inc_mo_mn1517 myoy_chores_mn1517 myoy_study_hrs_mn1517 myoy_enroll1_mn1517 myoy_logwage_hr_mn1517 myoy_study2_sum1517 myoy_lfp2_sum1517 myoy_unempl2_sum1517 myoy_enroll2_sum1517 myoy_study1_mn1820 myoy_lfp1_mn1820 myoy_unempl1_mn1820 myoy_ls_hrs_mn1820 myoy_wage_hr_mn1820 myoy_inc_mo_mn1820 myoy_chores_mn1820 myoy_study_hrs_mn1820 myoy_enroll1_mn1820 myoy_logwage_hr_mn1820 myoy_study2_sum1820 myoy_lfp2_sum1820 myoy_unempl2_sum1820 myoy_enroll2_sum1820{
makegraph_1 5 `y' fe controls "*"
}

