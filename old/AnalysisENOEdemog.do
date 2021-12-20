
if "`c(username)'"=="gehrk001" {
	cap cd "C:\Users\gehrk001\Dropbox\MigrationShocks\"
}

if "`c(username)'"=="Claire" {
	cap cd "C:\Users\Claire\Dropbox\MigrationShocks\"
}
*


/*
********************************************************************************
*trying with aggregation at the municipality/year/month level
use Data_built\ENOE\ENOE_migr_shock_muni_quart, clear


global munife i.file_time_yq i.file_time_yq##i.geo1_mx2000 i.geo2_mx2000


reghdfe sum_return   f12_sc2 f9_sc2 f6_sc2 f3_sc2 sc_shock2 l3_sc2 l6_sc2 l9_sc2 l12_sc2 l15_sc2 l18_sc2 l21_sc2 l24_sc2  c.migr_share#i.year if migr_share>0 , a($munife) cluster(geo2_mx2000)

reghdfe sum_return  f24_sc2 f21_sc2 f18_sc2 f15_sc2 f12_sc2 f9_sc2 f6_sc2 f3_sc2 sc_shock2 l3_sc2 l6_sc2 l9_sc2 l12_sc2 l15_sc2 l18_sc2 l21_sc2 l24_sc2 l27_sc2 l30_sc2 l33_sc2 l36_sc2 c.migr_share#i.file_time_yq if migr_share>0, a($munife) cluster(geo2_mx2000)

stop


********************************************************************************
use Data_built\ENOE\ENOE_migr_shock_by_quarter, clear
keep if year<=2014
keep if year>=2005
keep if migr_share>0

global fe i.year##i.month i.year##i.geo1_mx2000 i.d_mes i.geo2_mx2000

eststo clear
eststo: reghdfe return_3m  f12_sc2 f6_sc2 sc_shock2 l6_sc2 l12_sc2 l18_sc2 c.migr_share#i.year [aw=fac], a($fe) cluster(geo2_mx2000)
eststo: reghdfe return_3m  f12_sc2 sc_shock2 l6_sc2 l12_sc2 l18_sc2 l24_sc2 c.migr_share#i.year [aw=fac], a($fe) cluster(geo2_mx2000)

eststo: reghdfe anyreturn_3m  f12_sc2 f6_sc2 sc_shock2 l6_sc2 l12_sc2 l18_sc2 c.migr_share#i.year [aw=fac], a($fe) cluster(geo2_mx2000)
eststo: reghdfe anyreturn_3m  f12_sc2 sc_shock2 l6_sc2 l12_sc2 l18_sc2 l24_sc2 c.migr_share#i.year [aw=fac], a($fe) cluster(geo2_mx2000)

eststo: reghdfe migr_3m  f12_sc2 f6_sc2 sc_shock2 l6_sc2 l12_sc2 l18_sc2 c.migr_share#i.year [aw=fac], a($fe) cluster(geo2_mx2000)
eststo: reghdfe migr_3m  f12_sc2 sc_shock2 l6_sc2 l12_sc2 l18_sc2 l24_sc2 c.migr_share#i.year [aw=fac], a($fe) cluster(geo2_mx2000)

eststo: reghdfe anymigrant_3m  f12_sc2 f6_sc2 sc_shock2 l6_sc2 l12_sc2 l18_sc2 c.migr_share#i.year [aw=fac], a($fe) cluster(geo2_mx2000)
eststo: reghdfe anymigrant_3m  f12_sc2 sc_shock2 l6_sc2 l12_sc2 l18_sc2 l24_sc2 c.migr_share#i.year [aw=fac], a($fe) cluster(geo2_mx2000)

esttab est* using "Output\SC_migr_all_quarter.tex", b(3) se(3)  ///
	replace label ar2 drop(_cons ) ///
	nomtitles star(* 0.10 ** 0.05 *** 0.01)  ///
	addnotes(Each regression controls for municipality, state-by-year, quarter-by-year, and month fixed effects.) ///
	title(Effect of Secure Communities on migration\label{SCmigr})	
*/

********************************************************************************
use Data_built\ENOE\ENOE_migr_shock, clear
keep if int_year<=2012
keep if int_year>=2005
keep if migr_share>0

global fe i.file_time_yq i.int_year##i.geo1_mx2000 i.int_month i.geo2_mx2000

gen modate = ym(int_year, int_month) 


global fe_modate  i.modate##i.geo1_mx2000 i.geo2_mx2000

eststo clear

eststo: reghdfe hhsize  sc_shock_2 c.migr_share#i.int_year [aw=fac], a($fe) cluster(geo2_mx2000)
eststo: reghdfe hhsize  f12_sc_2  sc_shock_2  l12_sc_2  l24_sc_2  l36_sc_2 c.migr_share#i.int_year [aw=fac], a($fe) cluster(geo2_mx2000)
eststo: reghdfe youngadult_m  f12_sc_2  sc_shock_2  l12_sc_2  l24_sc_2  l36_sc_2 c.migr_share#i.modate [aw=fac], a($fe_modate) cluster(geo2_mx2000)
eststo: reghdfe  migr_3m  f12_sc_5  sc_shock_5  l12_sc_5  l24_sc_5  l36_sc_5 c.migr_share#i.modate [aw=fac], a($fe_modate) cluster(geo2_mx2000)


foreach x in 6 12 18 24 {
eststo: reghdfe return_3m  l`x'_sc_2 c.migr_share#i.int_year [aw=fac], a($fe) cluster(geo2_mx2000)
eststo: reghdfe return_3m  f`x'_sc_2 c.migr_share#i.int_year [aw=fac], a($fe) cluster(geo2_mx2000)
}
eststo: reghdfe anyreturn_3m  sc_shock_2 c.migr_share#i.int_year [aw=fac], a($fe) cluster(geo2_mx2000)
foreach x in 6 12 18 24 {
eststo: reghdfe anyreturn_3m  l`x'_sc_2 c.migr_share#i.int_year [aw=fac], a($fe) cluster(geo2_mx2000)
eststo: reghdfe anyreturn_3m  f`x'_sc_2 c.migr_share#i.int_year [aw=fac], a($fe) cluster(geo2_mx2000)
}


eststo clear 
eststo: reghdfe anymigrant_3m  sc_shock_2 c.migr_share#i.int_year [aw=fac], a($fe) cluster(geo2_mx2000)
foreach x in 6 12 18 24 {
eststo: reghdfe anymigrant_3m  l`x'_sc_2 c.migr_share#i.int_year [aw=fac], a($fe) cluster(geo2_mx2000)
eststo: reghdfe anymigrant_3m  f`x'_sc_2 c.migr_share#i.int_year [aw=fac], a($fe) cluster(geo2_mx2000)
} 
eststo: reghdfe migr_3m  sc_shock_2 c.migr_share#i.int_year [aw=fac], a($fe) cluster(geo2_mx2000)
foreach x in 6 12 18 24 {
eststo: reghdfe migr_3m  l`x'_sc_2 c.migr_share#i.int_year [aw=fac], a($fe) cluster(geo2_mx2000)
eststo: reghdfe migr_3m  f`x'_sc_2 c.migr_share#i.int_year [aw=fac], a($fe) cluster(geo2_mx2000)
}

esttab est* using "Output\SC_anymigrant_leadslags.tex", b(3) se(3)  ///
	replace label ar2 drop(_cons ) ///
	mtitles("Any migr." "No. migr." "Any migr." "No. migr.") star(* 0.10 ** 0.05 *** 0.01)  ///
	addnotes(Each regression controls for municipality, state-by-year, quarter-by-year, and month fixed effects.) ///
	title(Effect of Secure Communities on migration\label{SCmigr})	

/*eststo clear
foreach x in 2 5 {
*eststo: reghdfe anymigrant_3m  f12_sc_1 sc_shock_1 l12_sc_1 l24_sc_1 c.migr_share#i.int_year [aw=fac] if int_year<=2012, a($fe) cluster(geo2_mx2000)
*eststo: reghdfe anyreturn_3m  f12_sc_`x' sc_shock_`x' l12_sc_`x' l24_sc_`x' l36_sc_`x' c.migr_share#i.file_time_yq [aw=fac] if int_year<=2011, a($fe) cluster(geo2_mx2000)
*eststo: reghdfe return_3m  f12_sc_`x' sc_shock_`x' l12_sc_`x' l24_sc_`x' l36_sc_`x' c.migr_share#i.file_time_yq [aw=fac] if int_year<=2011, a($fe) cluster(geo2_mx2000)
eststo: reghdfe anymigrant_3m  f12_sc_`x' sc_shock_`x' l12_sc_`x' l24_sc_`x' l36_sc_`x' c.migr_share#i.file_time_yq [aw=fac] if int_year<=2012, a($fe) cluster(geo2_mx2000)
eststo: reghdfe migr_3m  f12_sc_`x' sc_shock_`x' l12_sc_`x' l24_sc_`x' l36_sc_`x' c.migr_share#i.file_time_yq [aw=fac] if int_year<=2012, a($fe) cluster(geo2_mx2000)
}

esttab est* using "Output\SC_migr_alttreatment2.tex", b(3) se(3)  ///
	replace label ar2 drop(_cons ) ///
	mtitles("Any migr." "No. migr." "Any migr." "No. migr.") star(* 0.10 ** 0.05 *** 0.01)  ///
	addnotes(Each regression controls for municipality, state-by-year, quarter-by-year, and month fixed effects.) ///
	title(Effect of Secure Communities on migration\label{SCmigr})	
*/





*log using Output\Log\hh_migration, replace text

use Data_built\ENOE\ENOE_migr_shock_C.dta, clear

global fe i.file_year##i.file_quarter i.file_time_yq##i.geo1_mx2000 i.int_month i.geo2_mx2000

reghdfe return_3m  f12_sc2 f9_sc2 f6_sc2 f3_sc2 sc_shock2 l3_sc2 l6_sc2 l9_sc2 l12_sc2 l15_sc2 l18_sc2 c.migr_share#i.int_year if migr_share>0 [aw=fac], a($fe) cluster(geo2_mx2000)
reghdfe return_3m  f12_sc2 f6_sc2  sc_shock2 l6_sc2 l12_sc2 l18_sc2 l24_sc2 c.migr_share#i.int_year if migr_share>0 [aw=fac], a($fe) cluster(geo2_mx2000)


reghdfe return_3m f24_sc2 f21_sc2 f18_sc2 f15_sc2 f12_sc2 f9_sc2 f6_sc2 f3_sc2 sc_shock2 l3_sc2 l6_sc2 l9_sc2 l12_sc2 l15_sc2 l18_sc2 l21_sc2 l24_sc2 l27_sc2 l30_sc2 l33_sc2 l36_sc2 c.migr_share#i.time_yq if migr_share>0 [aw=fac], a($fe) cluster(geo2_mx2000)
reghdfe return_3m  sc_shock2 l3_sc2 l6_sc2 l9_sc2 l12_sc2  c.migr_share#i.time_yq if migr_share>0 [aw=fac], a($fe) cluster(geo2_mx2000)

reghdfe migr_3m sc_shock2 c.migr_share#c.ym  if migr_share>0 [aw=fac], a($fe) cluster(geo2_mx2000)
reghdfe migr_3m sc_shock2 l12_sc2 c.migr_share#c.ym if migr_share>0 [aw=fac], a($fe) cluster(geo2_mx2000)
reghdfe migr_3m sc_shock2 l12_sc2 l24_sc2 c.migr_share#c.ym if migr_share>0 [aw=fac], a($fe) cluster(geo2_mx2000)

reghdfe anymigrant_3m sc_shock2 c.migr_share#c.ym if migr_share>0 [aw=fac], a($fe) cluster(geo2_mx2000)
reghdfe anymigrant_3m sc_shock2 l12_sc2 c.migr_share#c.ym if migr_share>0 [aw=fac], a($fe) cluster(geo2_mx2000)
reghdfe anymigrant_3m sc_shock2 l12_sc2 l2_sc2 c.migr_share#c.ym if migr_share>0 [aw=fac], a($fe) cluster(geo2_mx2000)

reghdfe return_3m sc_shock2 c.migr_share#c.ym if migr_share>0 [aw=fac], a($fe) cluster(geo2_mx2000)
reghdfe return_3m sc_shock2 l12_sc2 c.migr_share#c.ym  if migr_share>0 [aw=fac], a($fe) cluster(geo2_mx2000)
reghdfe return_3m sc_shock2 l12_sc2 l24_sc2 c.migr_share#c.ym if migr_share>0 [aw=fac], a($fe) cluster(geo2_mx2000)

reghdfe anyreturn_3m sc_shock2 c.migr_share#c.ym if migr_share>0 [aw=fac], a($fe) cluster(geo2_mx2000)
reghdfe anyreturn_3m sc_shock2 l12_sc2 c.migr_share#c.ym if migr_share>0 [aw=fac], a($fe) cluster(geo2_mx2000)
reghdfe anyreturn_3m sc_shock2 l12_sc2 l24_sc2 c.migr_share#c.ym if migr_share>0 [aw=fac], a($fe) cluster(geo2_mx2000)

*reghdfe anymigrant_3m f4_sc2 f3_sc2 f2_sc2 f1_sc2 sc_shock2 l1_sc2 l2_sc2 l3_sc2 l4_sc2 c.migr_share#c.ym if migr_share>0 [aw=fac], a($fe) cluster(geo2_mx2000)


reghdfe hhsize sc_shock2 c.migr_share#c.ym  if migr_share>0 [aw=fac], a($fe) cluster(geo2_mx2000)
reghdfe hhsize sc_shock2 l1_sc2 c.migr_share#c.ym if migr_share>0 [aw=fac], a($fe) cluster(geo2_mx2000)
reghdfe hhsize sc_shock2 l1_sc2 l2_sc2 c.migr_share#c.ym if migr_share>0 [aw=fac], a($fe) cluster(geo2_mx2000)


reghdfe return_3m sc_shock2 c.migr_share#i.ym if migr_share>0 [aw=fac], a($fe) cluster(geo2_mx2000)
reghdfe return_3m sc_shock2 l12_sc2 c.migr_share#c.ym  if migr_share>0 [aw=fac], a($fe) cluster(geo2_mx2000)
reghdfe return_3m sc_shock2 l12_sc2 l24_sc2 c.migr_share#c.ym if migr_share>0 [aw=fac], a($fe) cluster(geo2_mx2000)

reghdfe return_3m f3_sc f2_sc f1_sc sc_shock l1_sc l2_sc l3_sc c.migr_share#i.time_yq if migr_share>0 [aw=fac], a($fe) cluster(geo2_mx2000)
reghdfe return_3m f3_sc2 f2_sc2 f1_sc2 sc_shock2 l1_sc2 l2_sc2 l3_sc2 c.migr_share#i.time_yq if migr_share>0 [aw=fac], a($fe) cluster(geo2_mx2000)

gen inc_pc = inc_hh/ hhsize
xtile inc_quart = inc_pc, n(4)
reghdfe migr_3m c.sc_shock2##i.inc_quart c.migr_share#c.ym if migr_share>0 [aw=fac], a($fe) cluster(geo2_mx2000)
reghdfe return_3m c.sc_shock2##i.inc_quart c.migr_share#c.ym if migr_share>0 [aw=fac], a($fe) cluster(geo2_mx2000)
reghdfe anymigrant_3m c.sc_shock2##i.inc_quart c.migr_share#c.ym if migr_share>0 [aw=fac], a($fe) cluster(geo2_mx2000)
reghdfe anyreturn_3m c.sc_shock2##i.inc_quart c.migr_share#c.ym if migr_share>0 [aw=fac], a($fe) cluster(geo2_mx2000)

log close

