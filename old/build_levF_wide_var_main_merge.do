***********************************************************************************
*MERGE INDIVIDUALS AND HOUSEHOLD WIDE PANEL VARIABLES AND SELECT WHAT TO KEEP IN MAIN CROSS-SECTION DATA
***********************************************************************************
use  $Data_built\indiv_attrit_wide.dta
merge m:1 hh_id using  $Data_built\hh_attrit_wide.dta
keep if _m==3
drop _m


merge 1:m indiv_id using  $Data_built\time_use_all_merge
drop _m 

*gen year=int_year
keep if year <=2014

gen pop=1

*generating duplicate variables for variables that will be looked at with mean and sum
gen ls_dum2_low= ls_dum1_low
gen ls_dum2_high= ls_dum1_high

foreach i in study enroll migrant dom_migrant returnee dom_returnee yoy_hhdeparts yoy_hharrives {
rename `i' `i'1
gen `i'2=`i'1	
}

cap drop geo2_mx2000 geo1_mx2000
gen geo2_mx2015 = ent*1000 + mun

merge m:1 geo2_mx2015 using $Data_built\Claves_1960_2015.dta
drop if _m==2 // not all municipalities coevered in any round? 
drop _m geo1_mx2015 geo1_mx2010 geo2_mx2010 geo1_mx2005 geo2_mx2005

save $Data_built\time_use_all_merge2.dta, replace


*UNCOMMENT BELOW TO MAKE SMALLER FULL CROSS-SECTION DATA SETS. 
/*

**********************************************************************************
*smaller datasets (could also selected appropriate variables.)
use Data_built\ENOE\time_use_all_merge2.dta, replace
keep if eda<=21
save Data_built\ENOE\ENOE_timeuse_shock_1221.dta, replace

use Data_built\ENOE\time_use_all_merge2.dta, replace
keep if hh_vari==1
save Data_built\ENOE\ENOE_timeuse_shock_hh_vari.dta, replace

use Data_built\ENOE\time_use_all_merge2.dta, replace
keep if hh_bsline==1
save Data_built\ENOE\ENOE_timeuse_shock_hh_bsline.dta, replace

***********************************************************************************

*/

