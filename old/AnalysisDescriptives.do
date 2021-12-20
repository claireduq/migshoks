

clear all
set more off


if "`c(username)'"=="gehrk001" {
	cap cd "C:\Users\gehrk001\Dropbox\MigrationShocks\"
}

if "`c(username)'"=="Claire" {
	cap cd "C:\Users\Claire\Dropbox\MigrationShocks\"
}
*
if "`c(username)'"=="johnh" {
	cap cd "C:\Users\johnh\Dropbox\MigrationShocks\"
}
*

*output file 
global graphs "Output\Graphs\"
global tables "Output\Tables\"




*************************************************************************************

*******************************
*individual summary stats for table
*******************************
use Data_built\ENOE\ENOE_timeuse_shock_all.dta, clear


egen muni_age=concat(eda geo2_mx2000)

label var will_migrate "Individual will migrate"
label var hh_has_migrant "Household member will migrate"
label var hhsize "Household size"

eststo clear

eststo:reghdfe  eda will_migrate if ind_bsline==1  , a(geo2_mx2000)
estadd local muni "Yes"
estadd local muniage "No"
sum eda if will_migrate==1 & ind_bsline==1 
estadd  local migmean= round(r(mean), 0.01)
sum eda if will_migrate==0 & ind_bsline==1 
estadd  local nonmigmean= round(r(mean), 0.01)


eststo: reghdfe female  will_migrate if ind_bsline==1 , a(muni_age)
estadd local muni "."
estadd local muniage "Yes"
sum female if will_migrate==1 & ind_bsline==1 
estadd  local migmean= round(r(mean), 0.01)
sum female if will_migrate==0 & ind_bsline==1 
estadd  local nonmigmean= round(r(mean), 0.01)

eststo: reghdfe  anios_esc will_migrate if eda>=22 & ind_bsline==1 , a(muni_age)
estadd local muni "."
estadd local muniage "Yes"
sum anios_esc if will_migrate==1 & eda>=22 & ind_bsline==1 
estadd  local migmean= round(r(mean), 0.01)
sum anios_esc if will_migrate==0 & eda>=22 & ind_bsline==1 
estadd  local nonmigmean= round(r(mean), 0.01)

eststo: reghdfe  lfp  will_migrate if ind_bsline==1 , a(muni_age)
estadd local muni "."
estadd local muniage "Yes"
sum lfp if will_migrate==1  & ind_bsline==1 
estadd  local migmean= round(r(mean), 0.01)
sum lfp if will_migrate==0  & ind_bsline==1 
estadd  local nonmigmean= round(r(mean), 0.01)

eststo: reghdfe estim_wage will_migrate  if ind_bsline==1 , a(muni_age)
estadd local muni "."
estadd local muniage "Yes"
sum estim_wage if will_migrate==1  & ind_bsline==1 
estadd  local migmean= round(r(mean), 0.01)
sum estim_wage if will_migrate==0  & ind_bsline==1 
estadd  local nonmigmean= round(r(mean), 0.01)


eststo: reghdfe hhsize hh_has_migrant if hh_bsline==1, a(geo2_mx2000)
estadd local muni "Yes"
estadd local muniage "No"
sum hhsize if hh_has_migrant==1  & hh_bsline==1 
estadd  local migmean= round(r(mean), 0.01)
sum hhsize if hh_has_migrant==0  & hh_bsline==1 
estadd  local nonmigmean= round(r(mean), 0.01)

eststo: reghdfe hhv_teen_m hh_has_migrant hhsize if hh_bsline==1, a(geo2_mx2000)
estadd local muni "Yes"
estadd local muniage "No"
sum hhv_teen_m if hh_has_migrant==1  & hh_bsline==1 
estadd  local migmean= round(r(mean), 0.01)
sum hhv_teen_m if hh_has_migrant==0  & hh_bsline==1 
estadd  local nonmigmean= round(r(mean), 0.01)

eststo: reghdfe hhv_youngadult_m hh_has_migrant hhsize if hh_bsline==1, a(geo2_mx2000)
estadd local muni "Yes"
estadd local muniage "No"
sum hhv_youngadult_m if hh_has_migrant==1  & hh_bsline==1 
estadd  local migmean= round(r(mean), 0.01)
sum hhv_youngadult_m if hh_has_migrant==0  & hh_bsline==1 
estadd  local nonmigmean= round(r(mean), 0.01)

eststo: reghdfe hh_earn_mo hh_has_migrant hhsize if hh_bsline==1, a(geo2_mx2000)
estadd local muni "Yes"
estadd local muniage "No"
sum hh_earn_mo if hh_has_migrant==1  & hh_bsline==1 
estadd  local migmean= round(r(mean), 0.01)
sum hh_earn_mo if hh_has_migrant==0  & hh_bsline==1 
estadd  local nonmigmean= round(r(mean), 0.01)

esttab using "$tables\sum_stats.tex", replace  s(muni muniage N migmean nonmigmean , label("FE: Municipality" "FE: Municipality x Age"  "N" "Migrant Mean" "Non-migrant Mean")) se label   constant nonotes nonumbers  mgroups( "Individual" "Household", pattern( 1 0 0 0 0 1 0 0 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) mtitles("Age" "Female" "Schooling (over 21yrs)" "LFP" "Wage" "Household size" "Males (12-17yrs)" "Males (18-21yrs)" "Household Earnings")

*******************************







*******************************
*age profiles
*******************************

use Data_built\ENOE\ENOE_timeuse_shock_all.dta, clear
 keep if ind_bsline==1 

*age profiles
twoway (histogram eda if will_migrate==0, frac width(5) lcolor(gs12) fcolor(gs12)) ///
		(histogram eda if will_migrate==1, frac width(5) fcolor(none) lcolor(red)) , ///   
       legend(order(1 "Non-migrants" 2 "Migrants" ))
graph export "$graphs\twoway_age.pdf", replace

*******************************


*******************************
*age profiles
*******************************

use Data_built\ENOE\ENOE_timeuse_shock_all.dta, clear
 keep if ind_bsline==1 
keep if eda <=20
keep if eda >=12

*age profiles
twoway (histogram eda if will_migrate==0, discrete frac width(1) lcolor(gs12) fcolor(gs12)) (histogram eda if will_migrate==1, discrete  frac width(1) fcolor(none) lcolor(red)) ,  legend(order(1 "Non-migrants" 2 "Migrants" )) 
graph export "$graphs\twoway_age2.pdf", replace

*******************************




*******************************
*education profiles
*******************************
use Data_built\ENOE\ENOE_timeuse_shock_all.dta, clear
keep if  ind_bsline==1 
keep if eda<=35 & eda>=22

twoway (histogram anios_esc if will_migrate==0, frac width(1) lcolor(gs12) fcolor(gs12)) ///
		(histogram anios_esc if will_migrate==1, frac width(1) fcolor(none) lcolor(red)) , ///   
       legend(order(1 "Non-migrants (22-35yrs)" 2 "Migrants(22-35yrs)" )) ///
	   graphregion(color(white)) xtitle("Years of Schooling", size(medlarge))
graph export "$graphs\twoway_schooling.pdf", replace

*******************************



*******************************
*education on track
*******************************
use Data_built\ENOE\ENOE_timeuse_shock_all.dta, clear
keep if  ind_bsline==1 

twoway (histogram yrs_offtrack if will_migrate==0, frac width(1) lcolor(gs12) fcolor(gs12)) ///
		(histogram yrs_offtrack if will_migrate==1, frac width(1) fcolor(none) lcolor(red)) , ///   
       legend(order(1 "Non-migrants (under 18 yrs)" 2 "Migrants (under 18 yrs)" ))
graph export "$graphs\twoway_offtrack.pdf", replace

*******************************
