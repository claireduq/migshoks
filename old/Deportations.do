
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

*******************************************************************
clear
use Data_built\ENOE\ENOE_timeuse_shock_all.dta


gen int_moyr=ym(int_year+2000,int_month)
gen dep_moyr=ym(dep_yr, dep_mo)



*need to calculate the weighted sum of people who could report a deportation in each municipality month 

/*
merge m:1 geo2_mx2015 using Data_built\Claves\Claves_1960_2015.dta
drop if _m==2 // not all municipalities coevered in any round? 
drop _m geo1_mx2015 geo1_mx2010 geo2_mx2010 geo1_mx2005 geo2_mx2005
*/

*forval j=1/12{

local i=2005
local j=11	
	
	
local moyr=ym( `i', `j')

gen this_or_last_yr=0
replace this_or_last_yr=1 if `i'==int_year+2000
replace this_or_last_yr=1 if `i'==int_year+2000-1

gen could_rep=0
replace could_rep=1 if `moyr'<=int_moyr & this_or_last_yr==1

gen wt_could_report=could_rep*fac
sort geo2_mx2000
by geo2_mx2000: egen could_rep_dep_sum`i'`j'=total(wt_could_report)

gen dep_in_tg_ym=0
replace dep_in_tg_ym=1 if dep_moyr==`moyr'
gen wt_dep_report=could_rep*fac*dep_in_tg_ym
sort geo2_mx2000
by geo2_mx2000: egen rep_dep_sum`i'`j'=total(wt_dep_report)

gen rep_dep_share`i'`j'=rep_dep_sum`i'`j'/could_rep_dep_sum`i'`j'
drop  wt_dep_report dep_in_tg_ym wt_could_report could_rep this_or_last_yr
}
}
*
save Data_built\ENOE\rep_dep_combined.dta, replace


keep geo1_mx2000 geo2_mx2000 rep_dep_sum* could_rep_dep_sum* rep_dep_share*
duplicates drop

reshape long rep_dep_sum could_rep_dep_sum  rep_dep_share, i(geo1_mx2000 geo2_mx2000) j(moyear)

tostring moyear, replace
gen year=substr(moyear,1,4)
gen month=substr(moyear,5,2)

destring year month, replace
drop moyear
sort geo1_mx2000 geo2_mx2000 year month

gen modate=ym(year, month)

save Data_built\ENOE\deport_shock_new_construct.dta, replace


merge m:1 geo2_mx2000 year month using Data_built\Matriculas\Shock_Mat_SecComm_Sanc_all.dta
drop if _m==2 
drop _m

keep if year <=2014
keep if year >=2005


save Data_built\ENOE\deport_shock_new_construct_continuous.dta, replace



*ANALYSIS
gen sc_shock_5_a = sc_shock_5 / migr_share
gen f24_sc_5_a = f24_sc_5/ migr_share 
gen f12_sc_5_a = f12_sc_5/ migr_share 
gen l12_sc_5_a = l12_sc_5 / migr_share
gen l24_sc_5_a = l24_sc_5 / migr_share 
gen l36_sc_5_a =  l36_sc_5 / migr_share

global fe   i.year##i.geo1_mx2000  i.geo2_mx2000

reghdfe rep_dep_share f12_sc_5_a sc_shock_5_a l12_sc_5_a l24_sc_5_a l36_sc_5_a c.migr_share#i.year   , a($fe) cluster(geo2_mx2000)
