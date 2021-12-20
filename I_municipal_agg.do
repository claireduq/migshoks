


************************
*Write program to get municipal variables of interest for specific population subgoups.
*************************
*`1' string defining observation caracteristics conditioning once
*`2' global list of variables that want to calculate the mean of
*`3' global list of variables that want to calculate the sum of
*`4' variable name reflecting subgroup

program def muniagg_subgroup_prog, rclass

use $Data_built\time_use_all_merge2, clear
keep if `1'

collapse (mean) `2' (sum) `3' [pw=fac], by(quarter year geo2_mx2000 geo1_mx2000)

foreach i in `2'{
local new = "pwmuni_"+"`i'"+"_mean"+"`4'"
rename `i'	`new'
}

foreach i in `3'{
local new = "pwmuni_"+"`i'"+"_sum"+"`4'"
rename `i'	`new'
}

foreach i in `3' {
local new = "pwmuni_"+"`i'"+"_log"+"`4'"
local name= "pwmuni_"+"`i'"+"_sum"+"`4'"
gen loger=log(`name')	
rename loger `new'
}


tempfile saver
save `saver', replace

use $Data_built\time_use_all_merge2, clear
keep if `1'

collapse (mean) `2' (sum) `3' , by(quarter year geo2_mx2000 geo1_mx2000)

foreach i in `2'{
local new = "muni_"+"`i'"+"_mean"+"`4'"
rename `i'	`new'
}

foreach i in `3'{
local new = "muni_"+"`i'"+"_sum"+"`4'"
rename `i'	`new'
}

foreach i in `3' {
local new = "muni_"+"`i'"+"_log"+"`4'"
local name= "muni_"+"`i'"+"_sum"+"`4'"
gen loger=log(`name')	
rename loger `new'
}
merge 1:1 quarter year geo2_mx2000 geo1_mx2000 using `saver'
drop _merge
save "$Data_built\ENOE_muniagg`4'.dta", replace
clear
end 
*************************
*************************
*************************

*** total pop
local meantot eda
local sumtot pop
muniagg_subgroup_prog "pop==1" "`meantot'" "`sumtot'" "totpop" 

***all 15 and up
local mean15 inc_mo wage_hr logwage_hr wage_loweduc wage_higheduc anios_esc ls_dum1_low ls_dum1_high lfp unempl ls_hrs migrant1 dom_migrant1 returnee1 dom_returnee1
local sum15 pop ls_dum2_low ls_dum2_high migrant2 dom_migrant2 returnee2 dom_returnee2
muniagg_subgroup_prog "eda>=15" "`mean15'" "`sum15'" "15plus"

***20 and under
local mean20u study1 lfp unempl ls_hrs wage_hr inc_mo chores study_hrs enroll1 yrs_offtrack female migrant1 dom_migrant1 returnee1 dom_returnee1
local sum20u pop study2 enroll2 migrant2 dom_migrant2 returnee2 dom_returnee2
muniagg_subgroup_prog "eda<=20" "`mean20u'" "`sum20u'" "20und"

***20 and under female
local mean20uf study1 lfp unempl ls_hrs wage_hr inc_mo chores study_hrs enroll1 yrs_offtrack migrant1 dom_migrant1 returnee1 dom_returnee1
local sum20uf pop study2 enroll2 migrant2 dom_migrant2 returnee2 dom_returnee2
muniagg_subgroup_prog "eda<=20 & female==1" "`mean20uf'" "`sum20uf'" "f20und"

***20 and under male
local mean20um study1 lfp unempl ls_hrs wage_hr inc_mo chores study_hrs enroll1 yrs_offtrack migrant1 dom_migrant1 returnee1 dom_returnee1
local sum20um pop study2 enroll2 migrant2 dom_migrant2 returnee2 dom_returnee2
muniagg_subgroup_prog "eda<=20 & female==0" "`mean20um'" "`sum20um'" "m20und"

*** 12to14
local mean1214 study1 lfp unempl ls_hrs chores chores_hrs study_hrs enroll1 yrs_offtrack female wage_hr migrant1 dom_migrant1 returnee1 dom_returnee1
local sum1214 pop study2 enroll2 migrant2 dom_migrant2 returnee2 dom_returnee2
muniagg_subgroup_prog "eda<=14" "`mean1214'" "`sum1214'" "1214"

*** 15 to 17
local mean1517  study1 lfp unempl ls_hrs chores chores_hrs study_hrs enroll1 yrs_offtrack female wage_hr migrant1 dom_migrant1 returnee1 dom_returnee1
local sum1517 pop study2 enroll2 migrant2 dom_migrant2 returnee2 dom_returnee2
muniagg_subgroup_prog "eda>=15 & eda <=17" "`mean1517'" "`sum1517'" "1517"

*** 18 to 20
local mean1820  study1 lfp unempl ls_hrs chores chores_hrs study_hrs enroll1  yrs_offtrack female wage_hr wage_loweduc wage_higheduc migrant1 dom_migrant1 returnee1 dom_returnee1
local sum1820 pop study2 enroll2 migrant2 dom_migrant2 returnee2 dom_returnee2
muniagg_subgroup_prog "eda>=18 & eda <=21" "`mean1820'" "`sum1820'" "1820"

*** 21 to 35
local mean2135 lfp unempl ls_hrs female wage_hr wage_loweduc wage_higheduc migrant1 dom_migrant1 returnee1 dom_returnee1
local sum2135 pop migrant2 dom_migrant2 returnee2 dom_returnee2
muniagg_subgroup_prog "eda>=21 & eda <=35" "`mean2135'" "`sum2135'" "2135"

*** 21plus
local mean21  lfp unempl ls_hrs female wage_hr wage_loweduc wage_higheduc migrant1 dom_migrant1 returnee1 dom_returnee1
local sum21  pop migrant2 dom_migrant2 returnee2 dom_returnee2
muniagg_subgroup_prog "eda>=21" "`mean21'" "`sum21'" "21plus"

*** 17under enrolled in ent1
local mean17en study1 lfp unempl ls_hrs chores chores_hrs study_hrs enroll1  yrs_offtrack female wage_hr migrant1 dom_migrant1 returnee1 dom_returnee1
local sum17en study2 enroll2 migrant2 dom_migrant2 returnee2 dom_returnee2
muniagg_subgroup_prog "eda<=17 & ent1_enroll==1" "`mean17en'" "`sum17en'" "17en"

*** 17under not enrolled in ent1
local mean17dr study1 lfp unempl ls_hrs chores chores_hrs study_hrs enroll1  yrs_offtrack female wage_hr migrant1 dom_migrant1 returnee1 dom_returnee1
local sum17dr study2 enroll2 migrant2 dom_migrant2 returnee2 dom_returnee2
muniagg_subgroup_prog "eda<=17 & ent1_enroll==0" "`mean17dr'" "`sum17dr'" "17dr"

*** hh values
local meanhh  any_migrant_3m any_return_3m any_dom_migrant_3m any_dom_return_3m hh_has_migrant hh_has_dom_migrant hh_earn_mo got_remit_3m hhv_* hhsize yoy_hhdeparts1 yoy_hharrives1
local sumhh pop yoy_hhdeparts2 yoy_hharrives2
muniagg_subgroup_prog "hh_vari==1" "`meanhh'" "`sumhh'" "hh"

*** hh values ent1
local meanhhent1  yoy_hhdeparts1 
local sumhhent1 pop yoy_hhdeparts2 
muniagg_subgroup_prog "hh_ent1==1" "`meanhhent1'" "`sumhhent1'" "hhent1"

*** hh values ent5
local meanhhent5  yoy_hharrives1
local sumhhent5 pop  yoy_hharrives2
muniagg_subgroup_prog "hh_ent5==1" "`meanhhent5'" "`sumhhent5'" "hhent5"

* migration_share
use $Data_built\time_use_all_merge2, clear
keep if year<=2008
collapse (mean) migr_3m any_migrant_3m hh_has_migrant [pw=fac], by(per geo2_mx2000)
drop migr_3m any_migrant_3m
reshape wide hh_has_migrant, i(geo2_mx2000) j(per)
order *105 *205 *305 *405 *106 *206 *306 *406 *107 *207 *307 *407 *108 *208 *308 *408, after(geo2_mx2000)
egen migr_share_enoe = rowmean(*108 *208 *308 *408)
replace migr_share_enoe=. if hh_has_migrant408==. | hh_has_migrant308==. | hh_has_migrant208==. | hh_has_migrant108==.
egen migr_early = rowmean(*107 *207 *307 *407 *106 *206 *306 *406 *105 *205 *305 *405)
replace migr_share_enoe=migr_early if migr_share_enoe==.
keep migr_share_enoe geo2_mx2000
save $Data_built\munmigration.dta, replace

*need to weight by population. But want population weights at baseline? in 2008? 
*using average population of muni in pre 2008 observations
use $Data_built\ENOE_muniaggtotpop.dta
keep if year <=2008
collapse (mean) pwmuni_pop_sumtotpop , by( geo2_mx2000 geo1_mx2000)
rename pwmuni_pop_sumtotpop muni_popweights
save $Data_built\munpopweights.dta, replace



***mERGE ALL MUNICIPAL LEVEL DATASETS. 
use $Data_built\munmigration.dta, clear
merge 1:1 geo2_mx2000 using $Data_built\munpopweights.dta
drop _merge

merge 1:m geo2_mx2000 using $Data_built\ENOE_muniaggtotpop.dta
drop _merge

merge 1:1 geo2_mx2000 quarter year using $Data_built\ENOE_muniagg15plus.dta
drop _merge

merge 1:1 geo2_mx2000 quarter year using $Data_built\ENOE_muniagg20und.dta
drop _merge

merge 1:1 geo2_mx2000 quarter year using $Data_built\ENOE_muniaggf20und.dta
drop _merge

merge 1:1 geo2_mx2000 quarter year using $Data_built\ENOE_muniaggm20und.dta
drop _merge

merge 1:1 geo2_mx2000 quarter year using $Data_built\ENOE_muniagg1214.dta
drop _merge

merge 1:1 geo2_mx2000 quarter year using $Data_built\ENOE_muniagg1517.dta
drop _merge

merge 1:1 geo2_mx2000 quarter year using $Data_built\ENOE_muniagg1820.dta
drop _merge

merge 1:1 geo2_mx2000 quarter year using $Data_built\ENOE_muniagg2135.dta
drop _merge

merge 1:1 geo2_mx2000 quarter year using $Data_built\ENOE_muniagg21plus.dta
drop _merge

merge 1:1 geo2_mx2000 quarter year using $Data_built\ENOE_muniagg17en.dta
drop _merge

merge 1:1 geo2_mx2000 quarter year using $Data_built\ENOE_muniagg17dr.dta
drop _merge

merge 1:1 geo2_mx2000 quarter year using $Data_built\ENOE_muniagghh.dta
drop _merge

merge 1:1 geo2_mx2000 quarter year using $Data_built\ENOE_muniagghhent1.dta
drop _merge

merge 1:1 geo2_mx2000 quarter year using $Data_built\ENOE_muniagghhent5.dta
drop _merge

foreach y in hhent5 hhent1 hh 17dr 17en 21plus 2135 1820 1517 1214 m20und f20und 20und 15plus totpop{
cap erase "$Data_built\ENOE_muniagg`y'.dta"
}
*
merge 1:1 geo2_mx2000 quarter year using $Data_built\Shock_SecComm_Sanc_all_yq_med.dta
drop if _merge==2 // 55,631 out of ... muni-by-quater obs cannot be merged in ENOE!
drop _merge

ta quarter year 
ta geo2_mx2000 
codebook geo2_mx2000 // 1,523
bysort geo2_mx2000: gen count_mun=_N
ta count_mun // about 4% of sample is from muns with less than 10 obs!
drop if count_mun==1

gen poptotal = pwmuni_hhsize_meanhh* pwmuni_pop_sumhh
replace poptotal=round(poptotal)



save $Data_built\ENOE_muniagg_prog.dta, replace


