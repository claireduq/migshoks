
********************************************************************************
********************************************************************************
********************************************************************************
*select individual constants want to keep

use  $Data_built\wide_build.dta, replace


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

save $Data_built\wide_build_mini.dta, replace

********************************************************************************

* minor modifications to the shocks file
clear 
use  $Data_built\Shock_Mat_SecComm_Sanc_5.dta
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
save  $Data_built\Shock_Mat_SecComm_Sanc_5merge.dta, replace 


********************************************************************************


********************************************************************************
*merging the wide builds and files built above

use   $Data_built\indiv_hh_attrit_wide.dta


merge m:1  y_ent q_ent  geo2_mx2000 using $Data_built\Shock_Mat_SecComm_Sanc_5merge.dta
keep if _merge==3
drop _merge

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
merge 1:1 indiv_id using  $Data_built\wide_build_mini.dta
drop _merge

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

*create duplicate variables for sums and means 
foreach i in yoy_hh_report_remit yoy_hhdeparts yoy_hharrives yoy_migrant yoy_dom_migrant yoy_disappears yoy_returnee yoy_dom_returnee yoy_appears  yoy_study  yoy_lfp  yoy_unempl   yoy_enroll  {
rename `i' `i'1
gen `i'2=`i'1	
}


save $Data_built\ind_attrit_FD.dta, replace
******************************************
cap erase $Data_built\wide_build_mini.dta
cap erase $Data_built\Shock_Mat_SecComm_Sanc_5merge.dta
