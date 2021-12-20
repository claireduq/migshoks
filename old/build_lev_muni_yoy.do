

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

egen qy_enta=concat(q_ent y_ent)
encode qy_enta, gen(qy_ent)

save Data_built\ENOE\ENOE_myoyagg.dta, replace