

clear all

*esther
if "`c(username)'"=="gehrk001" {
	cap cd "C:\Users\gehrk001\Dropbox\MigrationShocks\"
}

*claire laptop
if "`c(username)'"=="Claire" {
	cap cd "C:\Users\Claire\Dropbox\MigrationShocks\"
}

*Claire Desktop
if "`c(username)'"=="johnh" {
	cap cd "C:\Users\johnh\Dropbox\MigrationShocks\"
}


global output = "`c(pwd)'\output\"


*************************************************************************************

cap log close
log using ENOEenroll_windows, text replace

use Data_built\ENOE\ENOE_eduall_windows.dta, clear


keep if int_year>=2005
keep if int_year<=2014
keep if migr_share>0
keep if eda>=12
keep if eda<=21

*seperate regressions

gen female=0
replace female=1 if sex==2


label variable avg_treat0811_0510  "Mean exposure"
label variable enroll "Enrolled"

global fe_modate3  i.modate##i.geo1_mx2000 i.geo2_mx2000

*seperate regressions boys
eststo clear
forval i=12/21{
eststo:reghdfe enroll  avg_treat0811_0510 c.migr_share#i.modate [aw=fac] if eda==`i' & female==0, a($fe_modate3) cluster(geo2_mx2000)
estadd local migsharetime "Yes"  
estadd local modategeo1_mx2000 "Yes" 
estadd local geo2_mx2000 "Yes"

}
*
esttab using "$output/Tables/migration_table/sep_reg_enrollboys.tex", replace keep(avg_treat0811_0510)  mtitle("Age 12" "Age 13" "Age 14" "Age 15" "Age 16" "Age 17" "Age 18" "Age 19" "Age 20" "Age 21") s(migsharetime modategeo1_mx2000  geo2_mx2000  N , label("Controls: Month/Year x Mig. Share " "FE: Month/Year x State"  "FE: Municipality" )) se label   constant nonotes nonumbers


eststo clear
forval i=12/21{

eststo:reghdfe enroll  avg_treat0811_0510 c.migr_share#i.modate [aw=fac] if eda==`i' & female==1, a($fe_modate3) cluster(geo2_mx2000)
estadd local migsharetime "Yes"  
estadd local modategeo1_mx2000 "Yes" 
estadd local geo2_mx2000 "Yes"
}

esttab using "$output/Tables/migration_table/sep_reg_enrollgirls.tex", replace keep(avg_treat0811_0510)  mtitle("Age 12" "Age 13" "Age 14" "Age 15" "Age 16" "Age 17" "Age 18" "Age 19" "Age 20" "Age 21") s(migsharetime modategeo1_mx2000  geo2_mx2000  N , label("Controls: Month/Year x Mig. Share " "FE: Month/Year x State"  "FE: Municipality" )) se label   constant nonotes nonumbers


gen school_level=0
replace school_level=1 if eda<=14
replace school_level=1 if eda==15 & int_month<=7
replace school_level=1 if eda==15 & int_month>7
replace school_level=2 if inlist(eda, 16,17)
replace school_level=2 if eda==18 & int_month<=7
replace school_level=3 if eda==18 & int_month>7
replace school_level=3 if eda>18 

eststo clear
forval i=1/3{
eststo:reghdfe enroll  avg_treat0811_0510 c.migr_share#i.modate [aw=fac] if school_level==`i' & female==1, a($fe_modate3) cluster(geo2_mx2000)
estadd local migsharetime "Yes"  
estadd local modategeo1_mx2000 "Yes" 
estadd local geo2_mx2000 "Yes"
}

esttab using "$output/Tables/migration_table/sep_reg_enrollgirls_level.tex", replace keep(avg_treat0811_0510)  mtitle("Middle School" "High School" "Higher Education") s(migsharetime modategeo1_mx2000  geo2_mx2000  N , label("Controls: Month/Year x Mig. Share " "FE: Month/Year x State"  "FE: Municipality" )) se label   constant nonotes nonumbers



eststo clear

forval i=1/3{
eststo:reghdfe enroll  avg_treat0811_0510 c.migr_share#i.modate [aw=fac] if school_level==`i' & female==0, a($fe_modate3) cluster(geo2_mx2000)
estadd local migsharetime "Yes"  
estadd local modategeo1_mx2000 "Yes" 
estadd local geo2_mx2000 "Yes"
}

esttab using "$output/Tables/migration_table/sep_reg_enrollboys_level.tex", replace keep(avg_treat0811_0510)  mtitle("Middle School" "High School" "Higher Education") s(migsharetime modategeo1_mx2000  geo2_mx2000  N , label("Controls: Month/Year x Mig. Share " "FE: Month/Year x State"  "FE: Municipality" )) se label   constant nonotes nonumbers

forval i=1/3{
gen level_`i'=0
replace level_`i'=1 if school_level==`i'
gen treat_level_`i'=level_`i'*avg_treat0811_0510
 }
 
global fe_modate  i.school_level i.modate##i.geo1_mx2000 i.geo2_mx2000

reghdfe enroll  avg_treat0811_0510 treat_level_* c.migr_share#i.modate [aw=fac] if female==1, a($fe_modate) cluster(geo2_mx2000)

reghdfe enroll  avg_treat0811_0510 treat_level_* c.migr_share#i.modate [aw=fac] if female==0, a($fe_modate) cluster(geo2_mx2000)

*generating level specific fe
egen mo_lv=concat(modate school_level)
encode mo_lv, gen(mo_lv_co)
egen mo_st_lv=concat(mo_lv geo1_mx2000)
encode mo_st_lv, gen(mo_st_lv_co)

egen muni_lv=concat(geo2_mx2000 school_level)
encode muni_lv, gen(muni_lev_co)

global fe_modate_lv  i.school_level i.mo_st_lv_co i.muni_lev_co

reghdfe enroll  avg_treat0811_0510 treat_level_* c.migr_share#i.mo_lv_co [aw=fac] if female==1, a($fe_modate_lv) cluster(geo2_mx2000)



*NOTE: When not run seperately with pooled fixed effects do get significance but that does not seem like the correct specification.
global fe i.sex i.int_year##i.int_month i.int_year##i.geo1_mx2000 i.geo2_mx2000


forval i=12/21{
gen age_`i'=0
replace age_`i'=1 if eda==`i'
gen treat_age_`i'=age_`i'*avg_treat0811_0510
}
*
/*
reghdfe enroll avg_treat0811_0510  age_* treat_age_* c.migr_share#i.int_year [aw=fac], a($fe) cluster(geo2_mx2000)
 
forval i=12/21{
test avg_treat0811_0510+treat_age_`i'=0
}
* 
*/
reghdfe enroll  avg_treat0811_0510 age_* treat_age_* c.migr_share#i.modate [aw=fac], a($fe_modate) cluster(geo2_mx2000)

forval i=12/21{
test avg_treat0811_0510+treat_age_`i'=0
}
*



log close


*********************

cap log close
log using ENOEstudy_windows, text replace
use Data_built\ENOE\ENOE_timeuse_windows.dta, clear


keep if int_year>=2005
keep if int_year<=2014
keep if migr_share>0
keep if eda<=21


*seperate regressions

gen female=0
replace female=1 if sex==2


label variable avg_treat0811_0510  "Mean exposure"
label variable study "Time studying"

global fe_modate3  i.modate##i.geo1_mx2000 i.geo2_mx2000

*seperate regressions boys
eststo clear
forval i=12/21{
eststo:reghdfe study  avg_treat0811_0510 c.migr_share#i.modate [aw=fac] if eda==`i' & female==0, a($fe_modate3) cluster(geo2_mx2000)
estadd local migsharetime "Yes"  
estadd local modategeo1_mx2000 "Yes" 
estadd local geo2_mx2000 "Yes"

}
*
esttab using "$output/Tables/migration_table/sep_reg_studyboys.tex", replace keep(avg_treat0811_0510)  mtitle("Age 12" "Age 13" "Age 14" "Age 15" "Age 16" "Age 17" "Age 18" "Age 19" "Age 20" "Age 21") s(migsharetime modategeo1_mx2000  geo2_mx2000  N , label("Controls: Month/Year x Mig. Share " "FE: Month/Year x State"  "FE: Municipality" )) se label   constant nonotes nonumbers


eststo clear
forval i=12/21{

eststo:reghdfe study  avg_treat0811_0510 c.migr_share#i.modate [aw=fac] if eda==`i' & female==1, a($fe_modate3) cluster(geo2_mx2000)
estadd local migsharetime "Yes"  
estadd local modategeo1_mx2000 "Yes" 
estadd local geo2_mx2000 "Yes"
}

esttab using "$output/Tables/migration_table/sep_reg_studygirls.tex", replace keep(avg_treat0811_0510)  mtitle("Age 12" "Age 13" "Age 14" "Age 15" "Age 16" "Age 17" "Age 18" "Age 19" "Age 20" "Age 21") s(migsharetime modategeo1_mx2000  geo2_mx2000  N , label("Controls: Month/Year x Mig. Share " "FE: Month/Year x State"  "FE: Municipality" )) se label   constant nonotes nonumbers


gen school_level=0
replace school_level=1 if eda<=14
replace school_level=1 if eda==15 & int_month<=7
replace school_level=1 if eda==15 & int_month>7
replace school_level=2 if inlist(eda, 16,17)
replace school_level=2 if eda==18 & int_month<=7
replace school_level=3 if eda==18 & int_month>7
replace school_level=3 if eda>18 

eststo clear
forval i=1/3{
eststo:reghdfe study avg_treat0811_0510 c.migr_share#i.modate [aw=fac] if school_level==`i' & female==1, a($fe_modate3) cluster(geo2_mx2000)
estadd local migsharetime "Yes"  
estadd local modategeo1_mx2000 "Yes" 
estadd local geo2_mx2000 "Yes"
}

esttab using "$output/Tables/migration_table/sep_reg_studygirls_level.tex", replace keep(avg_treat0811_0510)  mtitle("Middle School" "High School" "Higher Education") s(migsharetime modategeo1_mx2000  geo2_mx2000  N , label("Controls: Month/Year x Mig. Share " "FE: Month/Year x State"  "FE: Municipality" )) se label   constant nonotes nonumbers



eststo clear

forval i=1/3{
eststo:reghdfe study  avg_treat0811_0510 c.migr_share#i.modate [aw=fac] if school_level==`i' & female==0, a($fe_modate3) cluster(geo2_mx2000)
estadd local migsharetime "Yes"  
estadd local modategeo1_mx2000 "Yes" 
estadd local geo2_mx2000 "Yes"
}

esttab using "$output/Tables/migration_table/sep_reg_studyboys_level.tex", replace keep(avg_treat0811_0510)  mtitle("Middle School" "High School" "Higher Education") s(migsharetime modategeo1_mx2000  geo2_mx2000  N , label("Controls: Month/Year x Mig. Share " "FE: Month/Year x State"  "FE: Municipality" )) se label   constant nonotes nonumbers




























forval i=12/21{
gen age_`i'=0
replace age_`i'=1 if eda==`i'
gen treat_age_`i'=age_`i'*avg_treat0811_0510
}
*
/*
global fe i.sex  i.int_year##i.quarter i.int_year##i.geo1_mx2000 i.int_month i.geo2_mx2000
reghdfe study avg_treat0811_0510  age_* treat_age_* c.migr_share#i.int_year   [aw=fac], a($fe) cluster(geo2_mx2000)

forval i=12/21{
test avg_treat0811_0510+treat_age_`i'=0
}
*

global fe_modate i.sex  i.time_yq##i.geo1_mx2000 i.geo2_mx2000
reghdfe study  avg_treat0811_0510 age_* treat_age_*  c.migr_share#i.time_yq  [aw=fac], a($fe_modate) cluster(geo2_mx2000)
forval i=12/21{
test avg_treat0811_0510+treat_age_`i'=age_`i'
}
*
*/
global fe_modate2 i.sex   i.modate##i.geo1_mx2000 i.geo2_mx2000
reghdfe study  avg_treat0811_0510 age_* treat_age_*  c.migr_share#i.modate  [aw=fac], a($fe_modate2) cluster(geo2_mx2000)
forval i=12/21{
test avg_treat0811_0510+treat_age_`i'=0
}
*


forval i=12/21{
reghdfe study  avg_treat0811_0510 c.migr_share#i.modate [aw=fac] if eda==`i' & sex==1, a($fe_modate2) cluster(geo2_mx2000)
}
*

log close






/*
reghdfe study  avg_treat0811_0510  c.migr_share#i.time_yq if eda>=14 & eda<=18 & int_month>=3 & int_month<=7 [aw=fac], a($fe_modate) cluster(geo2_mx2000)


reghdfe study  avg_treat0811_0510  c.migr_share#i.time_yq if eda==15 [aw=fac], a($fe_modate) cluster(geo2_mx2000)
reghdfe study  avg_treat0811_0510  c.migr_share#i.time_yq if eda==16 [aw=fac], a($fe_modate) cluster(geo2_mx2000)
reghdfe study  avg_treat0811_0510  c.migr_share#i.time_yq if eda==17 [aw=fac], a($fe_modate) cluster(geo2_mx2000)


reghdfe study avg_treat0811_0510  c.migr_share#i.int_year if eda==12 [aw=fac], a($fe) cluster(geo2_mx2000)
reghdfe study avg_treat0811_0510  c.migr_share#i.int_year if eda==13 [aw=fac], a($fe) cluster(geo2_mx2000)
reghdfe study avg_treat0811_0510  c.migr_share#i.int_year if eda==14 [aw=fac], a($fe) cluster(geo2_mx2000)
reghdfe study avg_treat0811_0510  c.migr_share#i.int_year if eda==15 [aw=fac], a($fe) cluster(geo2_mx2000)
reghdfe study avg_treat0811_0510  c.migr_share#i.int_year if eda==16 [aw=fac], a($fe) cluster(geo2_mx2000)
reghdfe study avg_treat0811_0510  c.migr_share#i.int_year if eda==17 [aw=fac], a($fe) cluster(geo2_mx2000)
reghdfe study avg_treat0811_0510  c.migr_share#i.int_year if eda==18 [aw=fac], a($fe) cluster(geo2_mx2000)
*/





*****************************************
use Data_built\ENOE\ENOE_educ_shock.dta, clear
collapse (mean) enroll yearsschool [aw=fac], by(eda sex year)
graph tw line enroll eda  if year==2008 & sex==1, legend(label( 1 male 2008)) || line enroll eda  if year==2008 & sex==2, legend(label(2 female 2008)) || line enroll eda  if year==2012 & sex==1, legend(label( 3 male 2012)) || line enroll eda  if year==2012 & sex==2, legend(label(4 female 2012))
graph save Enroll_age_2008_12, replace

use Preparation\ENOE_educ_shock.dta, clear

collapse (mean) enroll yearsschool sc_shock2 sc_shock (sum) fac [aw=fac], by(eda sex month year geo1_mx2000 geo2_mx2000 migr_share)

save Preparation\ENOE_educ_shock_cohorts.dta, replace

cap log close
log using ENOEall_4, text replace
*log using ENOEall_1, text append
// gen time_ym = ym(year, month)
// format time_ym %tm

** Enrollment 
// eststo clear
// eststo: reghdfe enroll sc_shock2 if migr_share>0 & eda <=16 & year<=2011 [aw=fac], ///
// 	a(i.sex i.eda i.year##i.quarter i.geo2_mx2000 ) cluster(geo2_mx2000)
// eststo: reghdfe enroll sc_shock2 if migr_share>0 & eda <=16 & year<=2011 [aw=fac], ///
// 	a(i.sex i.eda i.year##i.quarter i.year##i.geo1_mx2000 i.geo2_mx2000) cluster(geo2_mx2000)
// eststo: reghdfe enroll c.sc_shock2 c.migr_share##c.year if migr_share>0 & eda <=16 & year<=2011  , ///
// 	a(i.sex i.year##i.quarter i.year##i.geo1_mx2000 i.geo2_mx2000) cluster(geo2_mx2000)
//
// eststo: reghdfe enroll sc_shock2 if migr_share>0 & eda>16 [aw=fac], ///
// 	a(i.sex i.eda i.year##i.quarter i.geo2_mx2000) cluster(geo2_mx2000)
// eststo: reghdfe enroll sc_shock2 if migr_share>0 & eda>16 [aw=fac], ///
// 	a(i.sex i.eda i.year##i.quarter i.year##i.geo1_mx2000 i.geo2_mx2000) cluster(geo2_mx2000)
// eststo: reghdfe enroll sc_shock2 c.migr_share##i.year if migr_share>0 & eda>16 [aw=fac], ///
// 	a(i.sex i.eda i.year##i.quarter i.year##i.geo1_mx2000 i.geo2_mx2000 i.month) cluster(geo2_mx2000)
//
//
// reghdfe enroll c.migr_share##ib9.time_ym if eda<=16 & year>=2007  , ///
// 	a(i.sex i.eda i.time_ym i.year##i.geo1_mx2000 i.geo2_mx2000) cluster(geo2_mx2000)

****************************************************************************************************

use Data_built\ENOE\ENOE_educ_shock.dta, clear

global fe i.sex i.eda i.year##i.quarter i.year##i.geo1_mx2000 i.month i.geo2_mx2000

keep if year>=2005
keep if year<=2014
keep if migr_share>0
keep if eda>=12
keep if eda<=20

eststo clear
eststo: reghdfe enroll sc_shock2 if eda<=14 [aw=fac], a($fe) cluster(geo2_mx2000)
eststo: reghdfe enroll sc_shock2 l12_sc2 if eda<=14 [aw=fac], a($fe) cluster(geo2_mx2000)
// test (sc_shock2 + l1_sc2) = 0
// eststo: reghdfe enroll sc_shock2 l1_sc2 c.migr_share#c.ym if eda<=16 [aw=fac], a($fe) cluster(geo2_mx2000)
// test (sc_shock2 + l1_sc2) = 0
 
eststo: reghdfe enroll sc_shock2 if eda>=15 & eda<=17 [aw=fac], a($fe) cluster(geo2_mx2000)
eststo: reghdfe enroll sc_shock2 l12_sc2 if eda>=15 & eda<=17 [aw=fac], a($fe) cluster(geo2_mx2000)

eststo: reghdfe enroll sc_shock2 if eda>=18 [aw=fac], a($fe) cluster(geo2_mx2000)
eststo: reghdfe enroll sc_shock2 l12_sc2 if eda>=18 [aw=fac], a($fe) cluster(geo2_mx2000)
*eststo: reghdfe enroll sc_shock2 l12_sc2 c.migr_share#c.ym if eda>16 [aw=fac], a($fe) cluster(geo2_mx2000)
//test (sc_shock2 + l1_sc2) = 0

esttab est* using "Output\SC_enroll_12-20.tex", b(3) se(3)  ///
	replace label ar2 drop(_cons ) ///
	nomtitles star(* 0.10 ** 0.05 *** 0.01)  ///
	addnotes(Each regression controls for municipality, state-by-year, quarter-by-year, month, age and gender fixed effects.) ///
	title(Effect of Secure Communities on enrollment in Mexico\label{SCenroll})	

* event study	
eststo clear
eststo: reghdfe enroll f12_sc2 sc_shock2 l6_sc2 l12_sc2 [aw=fac], a($fe) cluster(geo2_mx2000)
eststo: reghdfe enroll sc_shock2 l12_sc2 [aw=fac], a($fe) cluster(geo2_mx2000)
eststo: reghdfe enroll f12_sc2 sc_shock2 l6_sc2 l12_sc2 l18_sc2 [aw=fac], a($fe) cluster(geo2_mx2000)

esttab est* using "Output\SC_enroll_all.tex", b(3) se(3)  ///
	replace label ar2 drop(_cons ) ///
	nomtitles star(* 0.10 ** 0.05 *** 0.01)  ///
	addnotes(Each regression controls for municipality, state-by-year, quarter-by-year, month, age and gender fixed effects.) ///
	title(Effect of Secure Communities on enrollment in Mexico\label{SCenroll})	

	
/*set matsize 10000
set emptycells drop

qui areg enroll c.sc_shock2##i.eda c.migr_share#c.ym i.sex i.year##i.quarter i.year##i.geo1_mx2000 i.month if migr_share>0 [aw=fac], a(geo2_mx2000) cluster(geo2_mx2000)
margins, dydx(sc_shock2) at(eda = (12(1)21))
marginsplot
graph save EffectSC_enroll_age_250220, replace

qui areg enroll sc_shock2 c.l1_sc2##i.eda c.migr_share#c.ym i.sex i.year##i.quarter i.year##i.geo1_mx2000 i.month if migr_share>0 [aw=fac], a(geo2_mx2000) cluster(geo2_mx2000)
margins, dydx(l1_sc2) at(eda = (12(1)21))
marginsplot
graph save EffectSClag_enroll_age_250220, replace
*/


use Data_built\ENOE\ENOE_educ_shock_by_quarter.dta, clear

global fe i.sex i.eda i.year##i.month i.year##i.geo1_mx2000 i.d_mes i.geo2_mx2000

keep if year>=2005
keep if year<=2014
keep if migr_share>0
keep if eda>=12
keep if eda<=20

eststo clear
eststo: reghdfe enroll sc_shock2 if eda<=14 [aw=fac], a($fe) cluster(geo2_mx2000)
eststo: reghdfe enroll sc_shock2 l12_sc2 if eda<=14 [aw=fac], a($fe) cluster(geo2_mx2000)
// test (sc_shock2 + l1_sc2) = 0
// eststo: reghdfe enroll sc_shock2 l1_sc2 c.migr_share#c.ym if eda<=16 [aw=fac], a($fe) cluster(geo2_mx2000)
// test (sc_shock2 + l1_sc2) = 0
 
eststo: reghdfe enroll sc_shock2 if eda>=15 & eda<=17 [aw=fac], a($fe) cluster(geo2_mx2000)
eststo: reghdfe enroll sc_shock2 l12_sc2 if eda>=15 & eda<=17 [aw=fac], a($fe) cluster(geo2_mx2000)

eststo: reghdfe enroll sc_shock2 if eda>=18 [aw=fac], a($fe) cluster(geo2_mx2000)
eststo: reghdfe enroll sc_shock2 l12_sc2 if eda>=18 [aw=fac], a($fe) cluster(geo2_mx2000)
*eststo: reghdfe enroll sc_shock2 l12_sc2 c.migr_share#c.ym if eda>16 [aw=fac], a($fe) cluster(geo2_mx2000)
//test (sc_shock2 + l1_sc2) = 0

esttab est* using "Output\SC_enroll_12-20_quarter.tex", b(3) se(3)  ///
	replace label ar2 drop(_cons ) ///
	nomtitles star(* 0.10 ** 0.05 *** 0.01)  ///
	addnotes(Each regression controls for municipality, state-by-year, quarter-by-year, month, age and gender fixed effects.) ///
	title(Effect of Secure Communities on enrollment in Mexico\label{SCenroll})	

* event study	
eststo clear
eststo: reghdfe enroll f12_sc2 sc_shock2 l6_sc2 l12_sc2 [aw=fac], a($fe) cluster(geo2_mx2000)
eststo: reghdfe enroll sc_shock2 l12_sc2 [aw=fac], a($fe) cluster(geo2_mx2000)
eststo: reghdfe enroll f12_sc2 sc_shock2 l6_sc2 l12_sc2 l18_sc2 [aw=fac], a($fe) cluster(geo2_mx2000)

esttab est* using "Output\SC_enroll_all_quarter.tex", b(3) se(3)  ///
	replace label ar2 drop(_cons ) ///
	nomtitles star(* 0.10 ** 0.05 *** 0.01)  ///
	addnotes(Each regression controls for municipality, state-by-year, quarter-by-year, month, age and gender fixed effects.) ///
	title(Effect of Secure Communities on enrollment in Mexico\label{SCenroll})	





*************************************************************************************************************************
use Generated\ENOE_timeuse_shock.dta, clear

global fe i.sex i.eda i.year##i.quarter i.year##i.geo1_mx2000 i.month i.geo2_mx2000

keep if year>=2006
keep if year<=2014
keep if migr_share>0
keep if eda<=21

eststo est7: reghdfe study sc_shock2 [aw=fac], a($fe) cluster(geo2_mx2000)
eststo est8: reghdfe study sc_shock2 l1_sc2 [aw=fac], a($fe) cluster(geo2_mx2000)
// test (sc_shock2 + l1_sc2) = 0
eststo est9: reghdfe study sc_shock2 c.migr_share#c.ym [aw=fac], a($fe) cluster(geo2_mx2000)
//test (sc_shock2 + l1_sc2) = 0	


eststo est10: reghdfe enroll sc_shock2 [aw=fac], a($fe) cluster(geo2_mx2000)
eststo est11: reghdfe enroll sc_shock2 l1_sc2 [aw=fac], a($fe) cluster(geo2_mx2000)
// test (sc_shock2 + l1_sc2) = 0
eststo est12: reghdfe enroll sc_shock2 l1_sc2 c.migr_share#c.ym [aw=fac], a($fe) cluster(geo2_mx2000)
// test (sc_shock2 + l1_sc2) = 0	
//

esttab est7 est8 est9 est10 est11 est12 using "$tex\SC_attend_enroll_12to21.tex", b(3) se(3)  ///
	replace label ar2 drop(_cons ) ///
	nomtitles star(* 0.10 ** 0.05 *** 0.01)  ///
	addnotes(Each regression controls for municipality, state-by-year, quarter-by-year, month, age and gender fixed effects.) ///
	title(Effect of Secure Communities on enrollment in Mexico\label{SCenroll})	

gen f1=1	

eststo est12: reghdfe enroll f2_sc2 f1 sc_shock2 l1_sc2 l2_sc2 [aw=fac] , a($fe) cluster(geo2_mx2000)	
coefplot est12, keep(f2_sc2 f1 sc_shock2 l1_sc2 l2_sc2) yline(0) vertical levels(90) omitt
graph save "$tex\SC_enroll_eventstudy.gph", replace

eststo est13: reghdfe study f2_sc2 f1 sc_shock2 l1_sc2 l2_sc2 [aw=fac], a($fe) cluster(geo2_mx2000)	
coefplot est13, keep(f2_sc2 f1 sc_shock2 l1_sc2 l2_sc2) yline(0) vertical levels(90) omitt
graph save "$tex\SC_attend_eventstudy.gph", replace


eststo clear
eststo: reghdfe study sc_shock2 if eda<=16 [aw=fac], a($fe) cluster(geo2_mx2000)
eststo: reghdfe study sc_shock2 l1_sc2 if eda<=16 [aw=fac], a($fe) cluster(geo2_mx2000)
test (sc_shock2 + l1_sc2) = 0
eststo: reghdfe study sc_shock2 l1_sc2 c.migr_share#c.ym [aw=fac], a($fe) cluster(geo2_mx2000)
test (sc_shock2 + l1_sc2) = 0

eststo: reghdfe study sc_shock2 if eda>16 [aw=fac], a($fe) cluster(geo2_mx2000)
eststo: reghdfe study sc_shock2 l1_sc2 if eda>16 [aw=fac], a($fe) cluster(geo2_mx2000)
test (sc_shock2 + l1_sc2) = 0
eststo: reghdfe study sc_shock2 l1_sc2 c.migr_share#c.ym if eda>16 [aw=fac], a($fe) cluster(geo2_mx2000)
test (sc_shock2 + l1_sc2) = 0

esttab est1 est2 est3 est4 est5 est6 using "$tex\SC_attend12to21.tex", b(3) se(3)  ///
	replace label ar2 drop(_cons ) ///
	nomtitles star(* 0.10 ** 0.05 *** 0.01)  ///
	addnotes(Each regression controls for municipality, state-by-year, quarter-by-year, month, age and gender fixed effects.) ///
	title(Effect of Secure Communities on enrollment in Mexico\label{SCenroll})	


set matsize 10000
set emptycells drop

qui areg study c.sc_shock2##i.eda c.migr_share#c.ym i.sex i.year##i.quarter i.year##i.geo1_mx2000 i.month if migr_share>0 [aw=fac], a(geo2_mx2000) cluster(geo2_mx2000)
margins, dydx(sc_shock2) at(eda = (12(1)21))
marginsplot
graph save EffectSC_attend_age_250220, replace

qui areg study sc_shock2 c.l1_sc2##i.eda c.migr_share#c.ym i.sex i.year##i.quarter i.year##i.geo1_mx2000 i.month if migr_share>0 [aw=fac], a(geo2_mx2000) cluster(geo2_mx2000)
margins, dydx(l1_sc2) at(eda = (12(1)21))
marginsplot
graph save EffectSClag_attend_age_250220, replace


*************************************************************************************************************************

qui areg enroll sc_shock2 c.l1_sc2##i.eda c.migr_share#c.ym i.sex i.year##i.quarter i.year##i.geo1_mx2000 i.month if migr_share>0 [aw=fac], a(geo2_mx2000) cluster(geo2_mx2000)
margins, dydx(l1_sc2) at(eda = (6(1)25))
marginsplot
graph save EffectSClag_enroll_age, replace

qui areg yearsschool sc_shock2 c.l1_sc2##i.eda c.migr_share#c.ym i.sex i.year##i.quarter i.year##i.geo1_mx2000 i.month if migr_share>0 [aw=fac], a(geo2_mx2000) cluster(geo2_mx2000)
margins, dydx(l1_sc2) at(eda = (6(1)25))
marginsplot
graph save EffectSClag_att_age, replace

qui areg cohab c.sc_shock2##i.eda c.migr_share#c.ym i.sex i.year##i.quarter i.year##i.geo1_mx2000 i.month if migr_share>0 [aw=fac], a(geo2_mx2000) cluster(geo2_mx2000)
margins, dydx(sc_shock2) at(eda = (6(1)25))
marginsplot
graph save EffectSC_cohab_age, replace

qui areg parent_hh c.sc_shock2##i.eda c.migr_share#c.ym i.sex i.year##i.quarter i.year##i.geo1_mx2000 i.month if migr_share>0 [aw=fac], a(geo2_mx2000) cluster(geo2_mx2000)
margins, dydx(sc_shock2) at(eda = (6(1)25))
marginsplot
graph save EffectSC_parentshh_age, replace

qui areg anymigrant_3m c.sc_shock2##i.eda c.migr_share#c.ym i.sex i.year##i.quarter i.year##i.geo1_mx2000 i.month if migr_share>0 [aw=fac], a(geo2_mx2000) cluster(geo2_mx2000)
margins, dydx(sc_shock2) at(eda = (6(1)25))
marginsplot
graph save EffectSC_anymigr_age, replace

qui areg anyreturn_3m c.sc_shock2##i.eda c.migr_share#c.ym i.sex i.year##i.quarter i.year##i.geo1_mx2000 i.month if migr_share>0 [aw=fac], a(geo2_mx2000) cluster(geo2_mx2000)
margins, dydx(sc_shock2) at(eda = (6(1)25))
marginsplot
graph save EffectSC_anyret_age, replace


* Age 6 to 10
reghdfe enroll sc_shock2 c.migr_share#c.ym if eda>=6 & eda<=10 & migr_share>0 [aw=fac], a(i.sex i.eda i.year##i.quarter i.year##i.geo1_mx2000 i.month i.geo2_mx2000) cluster(geo2_mx2000)
reghdfe enroll sc_shock2 l1_sc2 c.migr_share#c.ym if eda>=6 & eda<=10 & migr_share>0 [aw=fac], a(i.sex i.eda i.year##i.quarter i.year##i.geo1_mx2000 i.month i.geo2_mx2000) cluster(geo2_mx2000)

* Age 11 to 15
reghdfe enroll sc_shock2 c.migr_share#c.ym if eda>=11 & eda<=15 & migr_share>0 [aw=fac], a(i.sex i.eda i.year##i.quarter i.year##i.geo1_mx2000 i.month  i.geo2_mx2000) cluster(geo2_mx2000)
reghdfe enroll sc_shock2 l1_sc2 c.migr_share#c.ym if eda>=11 & eda<=15 & migr_share>0 [aw=fac], a(i.sex i.eda i.year##i.quarter i.year##i.geo1_mx2000 i.month i.geo2_mx2000) cluster(geo2_mx2000)

* Age 16 to 20
reghdfe enroll sc_shock2 c.migr_share#c.ym if eda>=16 & eda<=20 & migr_share>0 [aw=fac], a(i.sex i.eda i.year##i.quarter i.year##i.geo1_mx2000 i.month  i.geo2_mx2000) cluster(geo2_mx2000)
reghdfe enroll sc_shock2 l1_sc2 c.migr_share#c.ym if eda>=16 & eda<=20 & migr_share>0 [aw=fac], a(i.sex i.eda i.year##i.quarter i.year##i.geo1_mx2000 i.month i.geo2_mx2000) cluster(geo2_mx2000)

* Age 21 to 25
reghdfe enroll sc_shock2 c.migr_share#c.ym if eda>=21 & eda<=25 & migr_share>0 [aw=fac], a(i.sex i.eda i.year##i.quarter i.year##i.geo1_mx2000 i.month  i.geo2_mx2000) cluster(geo2_mx2000)
reghdfe enroll sc_shock2 l1_sc2 c.migr_share#c.ym if eda>=21 & eda<=25 & migr_share>0 [aw=fac], a(i.sex i.eda i.year##i.quarter i.year##i.geo1_mx2000 i.month i.geo2_mx2000) cluster(geo2_mx2000)

** Attainment  

reghdfe yearssc sc_shock2 c.migr_share#c.ym if  eda<=17 & migr_share>0 [aw=fac], a(i.sex i.eda i.year##i.quarter i.year##i.geo1_mx2000 i.month  i.geo2_mx2000) cluster(geo2_mx2000)
reghdfe yearssc sc_shock2 l1_sc2 c.migr_share#c.ym if eda<=17 & migr_share>0 [aw=fac], a(i.sex i.eda i.year##i.quarter i.year##i.geo1_mx2000 i.month i.geo2_mx2000) cluster(geo2_mx2000)
reghdfe yearssc sc_shock2 l1_sc2 l2_sc2 c.migr_share#c.ym if eda>=11 & eda<=15 & migr_share>0 [aw=fac], a(i.sex i.eda i.year##i.quarter i.year##i.geo1_mx2000 i.month i.geo2_mx2000) cluster(geo2_mx2000)

reghdfe yearssc sc_shock2 c.migr_share#c.ym if eda>=16 & eda<=20 & migr_share>0 [aw=fac], a(i.sex i.eda i.year##i.quarter i.year##i.geo1_mx2000 i.month  i.geo2_mx2000) cluster(geo2_mx2000)
reghdfe yearssc sc_shock2 l1_sc2 c.migr_share#c.ym if eda>=16 & eda<=20 & migr_share>0 [aw=fac], a(i.sex i.eda i.year##i.quarter i.year##i.geo1_mx2000 i.month i.geo2_mx2000) cluster(geo2_mx2000)
reghdfe yearssc sc_shock2 l1_sc2 l2_sc2 c.migr_share#c.ym if eda>=16 & eda<=20 & migr_share>0 [aw=fac], a(i.sex i.eda i.year##i.quarter i.year##i.geo1_mx2000 i.month i.geo2_mx2000) cluster(geo2_mx2000)


* Parents present

* Age 6 to 15
reghdfe cohab sc_shock2 c.migr_share#c.ym if eda<=15 & migr_share>0 [aw=fac], a(i.sex i.eda i.year##i.quarter i.year##i.geo1_mx2000 i.month i.geo2_mx2000) cluster(geo2_mx2000)
reghdfe cohab sc_shock2 l1_sc2 c.migr_share#c.ym if eda>=6 & eda<=15 & migr_share>0 [aw=fac], a(i.sex i.eda i.year##i.quarter i.year##i.geo1_mx2000 i.month i.geo2_mx2000) cluster(geo2_mx2000)

reghdfe parent_hh sc_shock2 c.migr_share#c.ym if eda>=6 & eda<=10 & migr_share>0 [aw=fac], a(i.sex i.eda i.year##i.quarter i.year##i.geo1_mx2000 i.month i.geo2_mx2000) cluster(geo2_mx2000)
reghdfe parent_hh sc_shock2 l1_sc2 c.migr_share#c.ym if eda>=6 & eda<=10 & migr_share>0 [aw=fac], a(i.sex i.eda i.year##i.quarter i.year##i.geo1_mx2000 i.month i.geo2_mx2000) cluster(geo2_mx2000)

reghdfe anyreturn_3m sc_shock2 c.migr_share#c.ym if eda>=6 & eda<=10 & migr_share>0 & cohab==1 [aw=fac], a(i.sex i.eda i.year##i.quarter i.year##i.geo1_mx2000 i.month i.geo2_mx2000) cluster(geo2_mx2000)
reghdfe anyreturn_3m sc_shock2 l1_sc2 c.migr_share#c.ym if eda>=6 & eda<=10 & migr_share>0 & cohab==1 [aw=fac], a(i.sex i.eda i.year##i.quarter i.year##i.geo1_mx2000 i.month i.geo2_mx2000) cluster(geo2_mx2000)

reghdfe anymigrant_3m sc_shock2 c.migr_share#c.ym if eda>=6 & eda<=10 & migr_share>0 & cohab==1 [aw=fac], a(i.sex i.eda i.year##i.quarter i.year##i.geo1_mx2000 i.month i.geo2_mx2000) cluster(geo2_mx2000)
reghdfe anymigrant_3m sc_shock2 l1_sc2 c.migr_share#c.ym if eda>=6 & eda<=10 & migr_share>0 & cohab==1 [aw=fac], a(i.sex i.eda i.year##i.quarter i.year##i.geo1_mx2000 i.month i.geo2_mx2000) cluster(geo2_mx2000)

* Age 6 to 10
reghdfe cohab sc_shock2 c.migr_share#c.ym if eda>=11 & eda<=15 & migr_share>0 [aw=fac], a(i.sex i.eda i.year##i.quarter i.year##i.geo1_mx2000 i.month i.geo2_mx2000) cluster(geo2_mx2000)
reghdfe cohab sc_shock2 l1_sc2 c.migr_share#c.ym if eda>=11 & eda<=15 & migr_share>0 [aw=fac], a(i.sex i.eda i.year##i.quarter i.year##i.geo1_mx2000 i.month i.geo2_mx2000) cluster(geo2_mx2000)

reghdfe parent_hh sc_shock2 c.migr_share#c.ym if eda>=11 & eda<=15 & migr_share>0 [aw=fac], a(i.sex i.eda i.year##i.quarter i.year##i.geo1_mx2000 i.month i.geo2_mx2000) cluster(geo2_mx2000)
reghdfe parent_hh sc_shock2 l1_sc2 c.migr_share#c.ym if eda>=11 & eda<=15 & migr_share>0 [aw=fac], a(i.sex i.eda i.year##i.quarter i.year##i.geo1_mx2000 i.month i.geo2_mx2000) cluster(geo2_mx2000)

reghdfe anyreturn_3m sc_shock2 c.migr_share#c.ym if eda>=11 & eda<=15 & migr_share>0 & cohab==1 [aw=fac], a(i.sex i.eda i.year##i.quarter i.year##i.geo1_mx2000 i.month i.geo2_mx2000) cluster(geo2_mx2000)
reghdfe anyreturn_3m sc_shock2 l1_sc2 c.migr_share#c.ym if eda>=11 & eda<=15 & migr_share>0 & cohab==1 [aw=fac], a(i.sex i.eda i.year##i.quarter i.year##i.geo1_mx2000 i.month i.geo2_mx2000) cluster(geo2_mx2000)

reghdfe anymigrant_3m sc_shock2 c.migr_share#c.ym if eda>=11 & eda<=15 & migr_share>0 & cohab==1 [aw=fac], a(i.sex i.eda i.year##i.quarter i.year##i.geo1_mx2000 i.month i.geo2_mx2000) cluster(geo2_mx2000)
reghdfe anymigrant_3m sc_shock2 l1_sc2 c.migr_share#c.ym if eda>=11 & eda<=15 & migr_share>0 & cohab==1 [aw=fac], a(i.sex i.eda i.year##i.quarter i.year##i.geo1_mx2000 i.month i.geo2_mx2000) cluster(geo2_mx2000)


log close
