
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

*********************************
*MIGRATION PLANS

log using ENOEmigplans, text replace

use Data_built\ENOE\rep_retplans_windows, clear

keep if int_year<=2014
keep if int_year>=2005
keep if migr_share>0


*these questions are only asked in the extended questionair which is administered once per housheold
*month Fe don't make sense?
*tab2 d_amio d_mes

/*
global fe  i.int_year##i.geo1_mx2000 i.geo2_mx2000

*nothing significant here.
reghdfe unemp_border_cross  avg_treat0811_0510  c.migr_share#i.int_year [aw=fac], a($fe) cluster(geo2_mx2000)
reghdfe newjob_border_cross  avg_treat0811_0510  c.migr_share#i.int_year [aw=fac], a($fe) cluster(geo2_mx2000)
*/
eststo clear
label variable unemp_border_cross  "Unemployed with migration plans"
label variable newjob_border_cross  "Plan to seek new job abroad"

label variable avg_treat0811_0510  "Mean exposure"


global fe_modate  i.modate##i.geo1_mx2000 i.geo2_mx2000
eststo: reghdfe unemp_border_cross  avg_treat0811_0510  c.migr_share#i.modate [aw=fac], a($fe_modate) cluster(geo2_mx2000)
estadd local migsharetime "Yes"  
estadd local modategeo1_mx2000 "Yes" 
estadd local geo2_mx2000 "Yes"

eststo: reghdfe newjob_border_cross  avg_treat0811_0510  c.migr_share#i.modate [aw=fac], a($fe_modate) cluster(geo2_mx2000)
estadd local migsharetime "Yes"  
estadd local modategeo1_mx2000 "Yes" 
estadd local geo2_mx2000 "Yes"

esttab using "$output/Tables/migration_table/Migrationplans_table_1.tex", replace keep(avg_treat0811_0510) s(migsharetime modategeo1_mx2000  geo2_mx2000  N , label("Controls: Month/Year x Mig. Share " "FE: Month/Year x State"  "FE: Municipality" )) se label   constant nonotes nonumbers

/*
poisson unemp_border_cross  avg_treat0811_0510  c.migr_share#i.modate i.modate##i.geo1_mx2000 i.geo2_mx2000,  cluster(geo2_mx2000)
poisson newjob_border_cross  avg_treat0811_0510  c.migr_share#i.modate i.modate##i.geo1_mx2000 i.geo2_mx2000,  cluster(geo2_mx2000)
*/
log close


*********************************
*REMITTANCES
log using ENOEremittances, text replace

use Data_built\ENOE\ENOE_remit_shock_windows, clear

keep if int_year<=2014
keep if int_year>=2005
keep if migr_share>0

/*
global fe i.int_year##i.geo1_mx2000 i.geo2_mx2000
reghdfe hh_remit  avg_treat0811_0510  c.migr_share#i.int_year [aw=fac], a($fe) cluster(geo2_mx2000)

*how to weight these?
set matsize 10000
poisson hh_remit  avg_treat0811_0510  c.migr_share#i.modate i.modate##i.geo1_mx2000 i.geo2_mx2000,  cluster(geo2_mx2000)
*/

eststo clear
label variable hh_remit  "Receives remittances"
label variable avg_treat0811_0510  "Mean exposure"

global fe_modate  i.modate##i.geo1_mx2000 i.geo2_mx2000
eststo: reghdfe hh_remit  avg_treat0811_0510  c.migr_share#i.modate [aw=fac], a($fe_modate) cluster(geo2_mx2000)

estadd local migsharetime "Yes"  
estadd local modategeo1_mx2000 "Yes" 
estadd local geo2_mx2000 "Yes"

esttab using "$output/Tables/migration_table/Remittances_table_1.tex", replace keep(avg_treat0811_0510) s(migsharetime modategeo1_mx2000  geo2_mx2000  N , label("Controls: Month/Year x Mig. Share " "FE: Month/Year x State"  "FE: Municipality" )) se label   constant nonotes nonumbers  
 

log close


/*
************************************
*DEPORTATIONS_OLD
log using ENOEdeportationpoisson, text replace

*NoTE: to be observed here need to have been deported at that date but have not since re-migrated. 
use Data_built\ENOE\ENOE_deportation_shock_months_windows, clear
keep if year<=2014
keep if year>=2005
keep if migr_share>0

*global fe i.year##i.month i.year##i.geo1_mx2000 i.geo2_mx2000
*reghdfe sum_rep_dep  avg_treat0811_0510  c.migr_share#i.year, a($fe) cluster(geo2_mx2000)
*reghdfe weighted_sum_rep_dep  avg_treat0811_0510  c.migr_share#i.year, a($fe) cluster(geo2_mx2000)

global fe_modate  i.modate##i.geo1_mx2000 i.geo2_mx2000
*reghdfe sum_rep_dep  avg_treat0811_0510  c.migr_share#i.year, a($fe_modate) cluster(geo2_mx2000)
reghdfe sum_rep_dep  avg_treat0811_0510  c.migr_share#i.modate, a($fe_modate) cluster(geo2_mx2000)

*weighted... not sure if done correctly
*reghdfe weighted_sum_rep_dep  avg_treat0811_0510  c.migr_share#i.year, a($fe_modate) cluster(geo2_mx2000)
*reghdfe weighted_sum_rep_dep  avg_treat0811_0510  c.migr_share#i.modate , a($fe_modate) cluster(geo2_mx2000)

set matsize 10000
*how to weight these?
poisson sum_rep_dep  avg_treat0811_0510  c.migr_share#i.modate i.modate##i.geo1_mx2000 i.geo2_mx2000,  cluster(geo2_mx2000)

log close
*/

keep if year==2014
scatter avg_treat0811_0510 migr_share

*****************************************************
*DEPORTATIONS NEW: weighted observations that report controling for weighted observations that could report. Municipality level regressions
log using ENOEdeportation_new, text replace

use Data_built\ENOE\ENOE_deport_shock_windows_new.dta
keep if year<=2014
keep if year>=2005
keep if migr_share>0

/*
global fe i.year##i.month i.year##i.geo1_mx2000 i.geo2_mx2000
reghdfe sum_rep_dep  avg_treat0811_0510  c.migr_share#i.year, a($fe) cluster(geo2_mx2000)

global fe_modate  i.modate##i.geo1_mx2000 i.geo2_mx2000
reghdfe rep_dep_sum  avg_treat0811_0510  c.migr_share#i.year could_rep_dep_sum, a($fe_modate) cluster(geo2_mx2000)

reghdfe rep_dep_share  avg_treat0811_0510  c.migr_share#i.modate , a($fe_modate) cluster(geo2_mx2000)
*/

eststo clear
label variable rep_dep_sum  "Reported deportations"
label variable avg_treat0811_0510  "Mean exposure"
label variable could_rep_dep_sum "Pop. could report"

global fe_modate  i.modate##i.geo1_mx2000 i.geo2_mx2000
eststo: reghdfe rep_dep_sum  avg_treat0811_0510  c.migr_share#i.modate could_rep_dep_sum , a($fe_modate) cluster(geo2_mx2000)

estadd local migsharetime "Yes"  
estadd local modategeo1_mx2000 "Yes" 
estadd local geo2_mx2000 "Yes"

esttab using "$output/Tables/migration_table/Deportation_table_1.tex", replace keep(avg_treat0811_0510 could_rep_dep_sum) s(migsharetime modategeo1_mx2000  geo2_mx2000  N , label("Controls: Month/Year x Mig. Share " "FE: Month/Year x State"  "FE: Municipality" )) se label   constant nonotes nonumbers 
  
log close



/*
use Data_built\ENOE\deport_shock_new_construct_continuous.dta
global fem  i.modate##i.geo1_mx2000  i.geo2_mx2000

reghdfe rep_dep_sum   f12_sc2 f9_sc2  f6_sc2  f3_sc2  sc_shock2  l3_sc2 l6_sc2  l9_sc2 l12_sc2   l15_sc2 l18_sc2  l21_sc2 l24_sc2  c.migr_share#i.modate could_rep_dep_sum if migr_share>0 , a($fem) cluster(geo2_mx2000)
*/

/*
sort geo2_mx2000
by geo2_mx2000: egen max_avg_treat=max(avg_treat0811_0510)

reghdfe sum_rep_dep  c.max_avg_treat##i.year  c.migr_share#i.modate  , a($fe_modate) cluster(geo2_mx2000)
*/

********************************************************************************
/*
use Data_built\ENOE\ENOE_retplans_shock.dta, clear
global fem i.year##i.month i.year##i.geo1_mx2000 i.month i.geo2_mx2000

reghdfe migrated f12_sc2 f9_sc2  f6_sc2  f3_sc2  sc_shock2  l3_sc2 l6_sc2  l9_sc2 l12_sc2   l15_sc2 l18_sc2  l21_sc2 l24_sc2  c.migr_share#i.year if migr_share>0 , a($fem) cluster(geo2_mx2000)

reghdfe returned f12_sc2 f9_sc2  f6_sc2  f3_sc2  sc_shock2  l3_sc2 l6_sc2  l9_sc2 l12_sc2   l15_sc2 l18_sc2  l21_sc2 l24_sc2  c.migr_share#i.year if migr_share>0 , a($fem) cluster(geo2_mx2000)


reghdfe unemp_border_cross f12_sc2 f9_sc2  f6_sc2  f3_sc2  sc_shock2  l3_sc2 l6_sc2  l9_sc2 l12_sc2   l15_sc2 l18_sc2  l21_sc2 l24_sc2  c.migr_share#i.year if migr_share>0 , a($fem) cluster(geo2_mx2000)
reghdfe newjob_border_cross f12_sc2 f9_sc2  f6_sc2  f3_sc2  sc_shock2  l3_sc2 l6_sc2  l9_sc2 l12_sc2   l15_sc2 l18_sc2  l21_sc2 l24_sc2  c.migr_share#i.year if migr_share>0 , a($fem) cluster(geo2_mx2000)



use Data_built\ENOE\ENOE_remittances_shock.dta, clear
global fem i.year##i.month i.year##i.geo1_mx2000 i.month i.geo2_mx2000

reghdfe hh_remit f12_sc2 f9_sc2  f6_sc2  f3_sc2  sc_shock2  l3_sc2 l6_sc2  l9_sc2 l12_sc2   l15_sc2 l18_sc2  l21_sc2 l24_sc2  c.migr_share#i.year if migr_share>0 , a($fem) cluster(geo2_mx2000)


*log using Output\Log\hh_migration, replace text

use Data_built\ENOE\ENOE_deportation_shock_ym.dta, clear

global fem i.year##i.month i.edate##i.geo1_mx2000 i.month i.geo2_mx2000

*year month

*Effects by why the sign switch: 
*ALSO: not sure how to use weights 
reghdfe sum_rep_dep f12_sc2 f9_sc2  f6_sc2  f3_sc2  sc_shock2  l3_sc2 l6_sc2  l9_sc2 l12_sc2   l15_sc2 l18_sc2  l21_sc2 l24_sc2  c.migr_share#i.year if migr_share>0 , a($fem) cluster(geo2_mx2000)
reghdfe sum_rep_dep f12_sc2 f9_sc2  f6_sc2  f3_sc2  sc_shock2  l3_sc2 l6_sc2  l9_sc2 l12_sc2   l15_sc2 l18_sc2  l21_sc2 l24_sc2  c.migr_share#c.edate if migr_share>0 , a($fem) cluster(geo2_mx2000)


use Data_built\ENOE\ENOE_deportation_shock_y.dta, clear

global fe i.year i.year##i.geo1_mx2000  i.geo2_mx2000


reghdfe sum_rep_dep f12_sc2 sc_shock2 l12_sc2  c.migr_share#i.year if migr_share>0 , a($fe) cluster(geo2_mx2000)

reghdfe sum_rep_dep f24_sc2 f12_sc2 sc_shock2 l12_sc2 l24_sc2  c.migr_share#i.year if migr_share>0 , a($fe) cluster(geo2_mx2000)


reghdfe sum_rep_dep f12_sc2 sc_shock2 l12_sc2  c.migr_share#c.edate if migr_share>0 , a($fe) cluster(geo2_mx2000)

reghdfe sum_rep_dep f24_sc2 f12_sc2 sc_shock2 l12_sc2 l24_sc2  c.migr_share#c.edate if migr_share>0 , a($fe) cluster(geo2_mx2000)
