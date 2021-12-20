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

********************************************************************************
/*

*element extraction function

*funtion inputs: 
*`1' vector of coefficients care about
*`2' name for the file
*`2' vector of elements to extract
*`3' file to extract to
*`4' vector of ounding values
prog def valuesextract, rclass

local b =round(_b[`1'], `3')
local se =round(_se[`1'], `3')
local N =round(e(N))

file open myfile using $output/`4'`2'_b.txt, ///
 write text replace
 file write myfile "`b'" 
file close myfile

file open myfile using $output/`4'`2'_se.txt, ///
 write text replace
 file write myfile "`se'" 
file close myfile

file open myfile using $output/`4'`2'_N.txt, ///
 write text replace
 file write myfile "`N'" 
file close myfile

end

*valuesextract avg_treat0811_0510 return_3m_A 0.001 "Tables/migration_table/values/"

*
********************************************************************************

cap log close
log using ENOEmigration, text replace

use Data_built\ENOE\ENOE_migr_shock_windows.dta, clear
keep if int_year<=2014
keep if int_year>=2005
keep if migr_share>0

global fe i.int_year##i.int_month i.int_year##i.geo1_mx2000 i.geo2_mx2000
*A:
reghdfe migr_3m  avg_treat0811_0510  c.migr_share#i.int_year [aw=fac], a($fe) cluster(geo2_mx2000)
valuesextract avg_treat0811_0510 migr_3m_A 0.001 "Tables/migration_table/values/"
*A:
reghdfe anymigrant_3m   avg_treat0811_0510  c.migr_share#i.int_year [aw=fac], a($fe) cluster(geo2_mx2000)
valuesextract avg_treat0811_0510 anymigrant_3m_A 0.001 "Tables/migration_table/values/"


*more precise fixed effects
global fe_modate  i.modate##i.geo1_mx2000 i.geo2_mx2000

*B
reghdfe migr_3m  avg_treat0811_0510  c.migr_share#i.int_year [aw=fac], a($fe_modate) cluster(geo2_mx2000)
valuesextract avg_treat0811_0510 migr_3m_B 0.001 "Tables/migration_table/values/"
*B
reghdfe anymigrant_3m  avg_treat0811_0510  c.migr_share#i.int_year [aw=fac], a($fe_modate) cluster(geo2_mx2000)
valuesextract avg_treat0811_0510 anymigrant_3m_B 0.001 "Tables/migration_table/values/"

*more precise controls (takes some run time)-get similar result tighter se
*C
reghdfe migr_3m  avg_treat0811_0510  c.migr_share#i.modate [aw=fac], a($fe_modate) cluster(geo2_mx2000)
valuesextract avg_treat0811_0510 migr_3m_C 0.001 "Tables/migration_table/values/"
*C
reghdfe anymigrant_3m  avg_treat0811_0510  c.migr_share#i.modate [aw=fac], a($fe_modate) cluster(geo2_mx2000)
valuesextract avg_treat0811_0510 anymigrant_3m_C 0.001 "Tables/migration_table/values/"


/*
set matsize 10000
*how to weight a poisson?
poisson migr_3m  avg_treat0811_0510  c.migr_share#i.modate i.modate##i.geo1_mx2000 i.geo2_mx2000 ,  cluster(geo2_mx2000)
*/

log close

*/

cap log close
log using ENOEreturns, text replace


use Data_built\ENOE\ENOE_migr_shock_windows.dta, clear
keep if int_year<=2014
keep if int_year>=2005
keep if migr_share>0

label variable migr_3m  "Departures (count)"
label variable anymigrant_3m  "Any departures"
label variable return_3m  "Returns (count)"
label variable anyreturn_3m  "Any returns"
label variable avg_treat_5 "Mean exposure"


*global fe i.int_year##i.int_month i.int_year##i.geo1_mx2000 i.geo2_mx2000
global fe_modate  i.modate##i.geo1_mx2000 i.geo2_mx2000

eststo clear


*C
eststo:reghdfe migr_3m  avg_treat_2  c.migr_share#i.modate [aw=fac], a($fe_modate) cluster(geo2_mx2000)
estadd local migsharetime "Yes" 
estadd local modategeo1_mx2000 "Yes" 
estadd local geo2_mx2000 "Yes"
*C
eststo:reghdfe anymigrant_3m  avg_treat_2  c.migr_share#i.modate [aw=fac], a($fe_modate) cluster(geo2_mx2000)
estadd local migsharetime "Yes" 
estadd local modategeo1_mx2000 "Yes" 
estadd local geo2_mx2000 "Yes"

*A
*eststo: reghdfe return_3m   avg_treat0811_0510  c.migr_share#i.int_year [aw=fac], a($fe) cluster(geo2_mx2000)
 
*B
*eststo:reghdfe return_3m  avg_treat0811_0510  c.migr_share#i.int_year [aw=fac], a($fe_modate) cluster(geo2_mx2000)
*more precise controls (takes some run time)-get similar result tighter se
*C
eststo:reghdfe return_3m  avg_treat_2  c.migr_share#i.modate [aw=fac], a($fe_modate) cluster(geo2_mx2000)
estadd local migsharetime "Yes"  
estadd local modategeo1_mx2000 "Yes" 
estadd local geo2_mx2000 "Yes"


*A
*eststo:reghdfe anyreturn_3m   avg_treat0811_0510 c.migr_share#i.int_year [aw=fac], a($fe) cluster(geo2_mx2000)
*B
*eststo:reghdfe anyreturn_3m  avg_treat0811_0510  c.migr_share#i.int_year [aw=fac], a($fe_modate) cluster(geo2_mx2000)
*C
eststo:reghdfe anyreturn_3m  avg_treat_2  c.migr_share#i.modate [aw=fac], a($fe_modate) cluster(geo2_mx2000)
estadd local migsharetime "Yes" 
estadd local modategeo1_mx2000 "Yes" 
estadd local geo2_mx2000 "Yes"

esttab using "$output/Tables/migration_table/Migration_table_2.tex", replace keep(avg_treat_5) s(migsharetime modategeo1_mx2000  geo2_mx2000  N , label("Controls: Month/Year x Mig. Share " "FE: Month/Year x State"  "FE: Municipality" )) se label   constant nonotes nonumbers  mgroups( "Departures Abroad" "Returns from Abroad", pattern( 1 0 1 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) 
  

/*
set matsize 10000
*how to weight a poisson?
poisson return_3m  avg_treat0811_0510  c.migr_share#i.modate i.modate##i.geo1_mx2000 i.geo2_mx2000 ,  cluster(geo2_mx2000)
*/
log close
