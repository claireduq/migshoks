
if "`c(username)'"=="gehrk001" {
	cap cd "C:\Users\gehrk001\Dropbox\MigrationShocks\"
}
if "`c(username)'"=="esthe" {
	cap cd "C:\Users\esthe\Dropbox\MigrationShocks\"
}
if "`c(username)'"=="Claire" {
	cap cd "C:\Users\Claire\Dropbox\MigrationShocks\"
}

*output file 
global graphs "Output\Graphs\"
global tables "Output\Tables\"
set more off
//ssc install coefplot
*************************************************************************************
use Data_built\ENOE\ENOE_timeuse_shock_hh_vari.dta, clear

keep if int_year>=2005
keep if int_year<=2012
keep if migr_share>0

global fehh  i.time_yq##i.geo1_mx2000 i.int_mont##i.time_yq i.geo2_mx2000



eststo clear
foreach x in 5 { 	
foreach y in hh_report_remit  {
*remit question only in ampliado questionair so will only be asked to hh once. 
eststo: reghdfe `y' f24_sc_`x' f12_sc_`x' sc_shock_`x' l12_sc_`x' l24_sc_`x' l36_sc_`x' c.migr_share#i.int_year [aw=fac] if hh_extend_single==1  , a($fehh) cluster(geo2_mx2000)

local obs=e(N)
local N=e(N_clust)
sum int_year if e(sample)
local year_start = r(min)
local year_end = r(max)
sum int_month if int_year==`year_start' & e(sample)
local month_start = r(min)
sum int_month if int_year==`year_end' & e(sample)
local month_end = r(max)

nlcom ///
	(-(_b[f12_sc_]+_b[f24_sc_])) ///
	(-_b[f12_sc_]) ///
	(0) ///
	(_b[sc_shock_]) ///
	(_b[sc_shock_]+_b[l12_sc_]) ///
	(_b[sc_shock_]+_b[l12_sc_]+_b[l24_sc_]) ///
	(_b[sc_shock_]+_b[l12_sc_]+_b[l24_sc_]+_b[l36_sc_]) ///
	, post level(90)

estimates store beta_incr_`y'

* plot beta coefficients
coefplot (beta_incr_`y', ciopts(recast(rcap)) recast(connected) level(90)), ///
  	vertical ///
  	keep (_nl_*) ///
  	coeflabel(_nl_1 = -36 _nl_2 = -24 _nl_3 = -12 _nl_4 = 0 _nl_5 = 12 _nl_6 = 24 _nl_7 = 36) ///
  	xline(3.5, lpattern(dash) lwidth(thin) lcolor(black)) xlabel(,labsize(medlarge)) ///
 	yline(0, lcolor(black) lwidth(thin)) ylabel(,labsize(medlarge)) ///
 	graphregion(color(white)) ///
  	xtitle (" " "Months relative to Secure communities shock", size(medlarge)) ytitle ("Treatment effect (90% c.i.)" " ", size(medlarge)) ///
	legend(off) ///
	note(" " "Observations: `obs', Municipalities: `N', Period: `month_start'/`year_start' - `month_end'/`year_end'.", size(small))
	
graph export "Output/Graphs/GES_SC`x'_`y'_all_12m_normneg1_all.pdf", replace
}
}
esttab est* using "Output\Tables\SC`x'_remit_all.tex", b(3) se(3)  ///
	replace label ar2 drop(_cons ) ///
	mtitles("Remittances" ) star(* 0.10 ** 0.05 *** 0.01)  ///
	addnotes(Each regression controls for municipality, state-by-year, quarter-by-year, month, age and gender fixed effects.) ///
	title(Effect of Secure Communities on  in Mexico\label{SCremit})	

	
*family composition
eststo clear
foreach x in 5 { 	
foreach y in hhv_kids hhv_teen_f hhv_teen_m hhv_youngadult_f hhv_youngadult_m  hhv_adult_f  hhv_adult_m {
*remit question only in ampliado questionair so will only be asked to hh once. 
eststo: reghdfe `y' f12_sc_`x' sc_shock_`x' l12_sc_`x' l24_sc_`x' l36_sc_`x' c.migr_share#i.int_year [aw=fac]  , a($fehh) cluster(geo2_mx2000)

local obs=e(N)
local N=e(N_clust)
sum int_year if e(sample)
local year_start = r(min)
local year_end = r(max)
sum int_month if int_year==`year_start' & e(sample)
local month_start = r(min)
sum int_month if int_year==`year_end' & e(sample)
local month_end = r(max)

nlcom ///
	(-(_b[sc_shock_]+_b[f12_sc_])) ///
	(-_b[sc_shock_]) ///
	(0) ///
	(_b[l12_sc_]) ///
	(_b[l12_sc_]+_b[l24_sc_]) ///
	(_b[l12_sc_]+_b[l24_sc_]+_b[l36_sc_]) ///
	, post level(90)

estimates store beta_incr_`y'

* plot beta coefficients
coefplot (beta_incr_`y', ciopts(recast(rcap)) recast(connected) level(90)) ///
  	, ///
  	vertical ///
  	keep (_nl_*) ///
  	coeflabel(_nl_1 = -24 _nl_2 = -12 _nl_3 = 0 _nl_4 = 12 _nl_5 = 24 _nl_6 = 36) ///
  	xline(3, lpattern(dash) lwidth(thin) lcolor(black)) xlabel(,labsize(medlarge)) ///
 	yline(0, lcolor(black) lwidth(thin)) ylabel(,labsize(medlarge)) ///
 	graphregion(color(white)) ///
  	xtitle (" " "Months relative to Secure communities shock", size(medlarge)) ytitle ("Treatment effect (90% c.i.)" " ", size(medlarge)) ///
	legend(off) ///
	note(" " "Observations: `obs', Municipalities: `N', Period: `month_start'/`year_start' - `month_end'/`year_end'.", size(small))
	
graph export "Output/Graphs/GES_SC`x'_`y'_all_12m_norm0_all.pdf", replace
}
}
esttab est* using "Output\Tables\SC`x'_demog_all.tex", b(3) se(3)  ///
	replace label ar2 drop(_cons ) ///
	mtitles("Kids" "Females 12-16" "Males 12-16" "Females 17-21" "Males 17-21" "Adult Females" "Adult Males") star(* 0.10 ** 0.05 *** 0.01)  ///
	addnotes(Each regression controls for municipality, state-by-year, quarter-by-year, month, age and gender fixed effects.) ///
	title(Effect of Secure Communities on household composition in Mexico\label{SCremit})	

	
*domestic migration 

eststo clear
foreach x in 5 { 	
foreach y in dom_migr_3m {
*remit question only in ampliado questionair so will only be asked to hh once. 
eststo: reghdfe `y' f24_sc_`x' f12_sc_`x' sc_shock_`x' l12_sc_`x' l24_sc_`x' l36_sc_`x' c.migr_share#i.int_year [aw=fac] if hh_vari==1 , a($fehh) cluster(geo2_mx2000)

local obs=e(N)
local N=e(N_clust)
sum int_year if e(sample)
local year_start = r(min)
local year_end = r(max)
sum int_month if int_year==`year_start' & e(sample)
local month_start = r(min)
sum int_month if int_year==`year_end' & e(sample)
local month_end = r(max)

nlcom ///
	(-(_b[f12_sc_]+_b[f24_sc_])) ///
	(-_b[f12_sc_]) ///
	(0) ///
	(_b[sc_shock_]) ///
	(_b[sc_shock_]+_b[l12_sc_]) ///
	(_b[sc_shock_]+_b[l12_sc_]+_b[l24_sc_]) ///
	(_b[sc_shock_]+_b[l12_sc_]+_b[l24_sc_]+_b[l36_sc_]) ///
	, post level(90)

estimates store beta_incr_`y'

* plot beta coefficients
coefplot (beta_incr_`y', ciopts(recast(rcap)) recast(connected) level(90)) ///
  	, ///
  	vertical ///
  	keep (_nl_*) ///
  	coeflabel(_nl_1 = -36 _nl_2 = -24 _nl_3 = -12 _nl_4 = 0 _nl_5 = 12 _nl_6 = 24 _nl_7 = 36) ///
  	xline(3, lpattern(dash) lwidth(thin) lcolor(black)) xlabel(,labsize(medlarge)) ///
 	yline(0, lcolor(black) lwidth(thin)) ylabel(,labsize(medlarge)) ///
 	graphregion(color(white)) ///
  	xtitle (" " "Months relative to Secure communities shock", size(medlarge)) ytitle ("Treatment effect (90% c.i.)" " ", size(medlarge)) ///
	legend(off) ///
	note(" " "Observations: `obs', Municipalities: `N', Period: `month_start'/`year_start' - `month_end'/`year_end'.", size(small))
	
graph export "Output/Graphs/GES_SC`x'_`y'_all_12m_norm0_all.pdf", replace
}
}
esttab est* using "Output\Tables\SC`x'_dommig_all.tex", b(3) se(3)  ///
	replace label ar2 drop(_cons ) ///
	mtitles("Domestic Migration") star(* 0.10 ** 0.05 *** 0.01)  ///
	addnotes(Each regression controls for municipality, state-by-year, quarter-by-year, month, age and gender fixed effects.) ///
	title(Effect of Secure Communities on domestic migration in Mexico\label{SCremit})	

********************************************************************************************	
* International migration
use Data_built\ENOE\ENOE_timeuse_shock_hh_vari.dta, clear
keep if int_year>=2005
keep if int_year<=2012
keep if migr_share>0
*keep if sc_shock_2!=.

global fehh i.time_yq##i.geo1_mx2000 i.time_ym i.geo2_mx2000  

eststo clear 
foreach x in 5 {
foreach y in any_migrant_3m   { //migr_3m any_return_3m return_3m
eststo: reghdfe `y' f24_sc_`x' f12_sc_`x' sc_shock_`x' l12_sc_`x' l24_sc_`x' l36_sc_`x' l48_sc_`x' c.migr_share#i.int_year [aw=fac], a($fehh) cluster(geo2_mx2000)

local obs=e(N)
local N=e(N_clust)
sum int_year if e(sample)
local year_start = r(min)
local year_end = r(max)
sum int_month if int_year==`year_start' & e(sample)
local month_start = r(min)
sum int_month if int_year==`year_end' & e(sample)
local month_end = r(max)


nlcom ///
	(-(_b[f12_sc_]+_b[f24_sc_])) ///
	(-_b[f12_sc_]) ///
	(0) ///
	(_b[sc_shock_]) ///
	(_b[sc_shock_]+_b[l12_sc_]) ///
	(_b[sc_shock_]+_b[l12_sc_]+_b[l24_sc_]) ///
	(_b[sc_shock_]+_b[l12_sc_]+_b[l24_sc_]+_b[l36_sc_]) ///
	(_b[sc_shock_]+_b[l12_sc_]+_b[l24_sc_]+_b[l36_sc_]+_b[l48_sc_]) ///
	, post level(90)

estimates store beta_incr_`y'

* plot beta coefficients
coefplot (beta_incr_`y', ciopts(recast(rcap)) recast(connected) level(90)) ///
  	, ///
  	vertical ///
  	keep (_nl_*) ///
  	coeflabel(_nl_1 = -36 _nl_2 = -24 _nl_3 = -12 _nl_4 = 0 _nl_5 = 12 _nl_6 = 24 _nl_7 = 36) ///
  	xline(3.5, lpattern(dash) lwidth(thin) lcolor(black)) xlabel(,labsize(medlarge)) ///
 	yline(0, lcolor(black) lwidth(thin)) ylabel(,labsize(medlarge)) ///
 	graphregion(color(white)) ///
  	xtitle (" " "Months relative to Secure communities shock", size(medlarge)) ytitle ("Treatment effect (90% c.i.)" " ", size(medlarge)) ///
	legend(off) ///
	note(" " "Observations: `obs', Municipalities: `N', Period: `month_start'/`year_start' - `month_end'/`year_end'.", size(small))
	
graph export "Output/Graphs/GES_SC`x'_`y'_12m_normneg1.pdf", replace
*/
}
}
esttab est* using "Output\SC`x'_migr_countoutcomes.tex", b(3) se(3)  ///
	replace label ar2 drop(_cons ) ///
	mtitles("Any migrant" "No. migr." "Any return" "No. returned" ) star(* 0.10 ** 0.05 *** 0.01)  ///
	addnotes(Each regression controls for municipality, state-by-year, quarter-by-year, and month fixed effects.) ///
	title(Effect of Secure Communities on migration\label{SCmigr})		
	
	
***************************************************************************************	
**** Schooling

use Data_built\ENOE\ENOE_timeuse_shock_1221.dta, clear

*keep if int_year>=2005
keep if int_year<=2012
keep if migr_share>0
keep if eda>=12 & eda<20

global fe i.female i.eda  i.time_yq##i.geo1_mx2000 i.time_ym i.geo2_mx2000



eststo clear
foreach x in 5 { 	
foreach y in study enroll yrs_off lfp  {
*remit question only in ampliado questionair so will only be asked to hh once. 
eststo: reghdfe `y' f18_sc_`x' f12_sc_`x' f6_sc_`x' sc_shock_`x' l6_sc_`x' l12_sc_`x' l18_sc_`x' l24_sc_`x' l30_sc_`x' c.migr_share#i.int_year [pw=fac], a($fe) cluster(geo2_mx2000)

local obs=e(N)
local N=e(N_clust)
sum iny_year if e(sample)
local year_start = r(min)
local year_end = r(max)
local month_start = 1
local month_end = 12

nlcom ///
	(-(_b[sc_shock_]+_b[f6_sc_]+_b[f12_sc_]+_b[f18_sc_])) ///
	(-(_b[sc_shock_]+_b[f6_sc_]+_b[f12_sc_])) ///
	(-(_b[sc_shock_]+_b[f6_sc_])) ///
	(-_b[sc_shock_]) ///
	(0) ///
	(_b[l6_sc_]) ///
	(_b[l6_sc_]+_b[l12_sc_]) ///
	(_b[l6_sc_]+_b[l12_sc_]+_b[l18_sc_]) ///
	(_b[l6_sc_]+_b[l12_sc_]+_b[l18_sc_]+_b[l24_sc_]) /// 
	(_b[l6_sc_]+_b[l12_sc_]+_b[l18_sc_]+_b[l24_sc_]+_b[l30_sc_]) ///
	, post level(90)

estimates store beta_incr_`y'

* plot beta coefficients
coefplot (beta_incr_`y', ciopts(recast(rcap)) recast(connected) level(90)), ///
  	vertical ///
  	keep (_nl_*) ///
  	coeflabel(_nl_1 = -24 _nl_2 = -18 _nl_3 = -12 _nl_4 = -6 _nl_5 = 0 _nl_6 = 6 _nl_7 = 12 _nl_8 = 18 _nl_9 = 24 ) ///
  	xline(5, lpattern(dash) lwidth(thin) lcolor(black)) xlabel(,labsize(medlarge)) ///
 	yline(0, lcolor(black) lwidth(thin)) ylabel(,labsize(medlarge)) ///
 	graphregion(color(white)) ///
  	xtitle (" " "Months relative to Secure communities shock", size(medlarge)) ytitle ("Treatment effect (90% c.i.)" " ", size(medlarge)) ///
	legend(off) ///
	note(" " "Observations: `obs', Municipalities: `N', Period: `month_start'/`year_start' - `month_end'/`year_end'.", size(small))
	
graph export "Output/Graphs/GES_SC`x'_`y'_6m_norm0.pdf", replace
}
}




eststo clear 	
foreach x in 5 {
foreach y in study enroll yrs_off migrant { //
eststo: reghdfe `y' f24_sc_`x' f12_sc_`x' sc_shock_`x' l12_sc_`x' l24_sc_`x' l36_sc_`x' c.migr_share#i.int_year [aw=fac], a($fe) cluster(geo2_mx2000)

local obs=e(N)
local N=e(N_clust)
sum int_year if e(sample)
local year_start = r(min)
local year_end = r(max)
sum int_month if int_year==`year_start' & e(sample)
local month_start = r(min)
sum int_month if int_year==`year_end' & e(sample)
local month_end = r(max)

nlcom ///
	(-(_b[f12_sc_]+_b[f24_sc_])) ///
	(-_b[f12_sc_]) ///
	(0) ///
	(_b[sc_shock_]) ///
	(_b[sc_shock_]+_b[l12_sc_]) ///
	(_b[sc_shock_]+_b[l12_sc_]+_b[l24_sc_]) ///
	(_b[sc_shock_]+_b[l12_sc_]+_b[l24_sc_]+_b[l36_sc_]) /// //(_b[sc_shock_]+_b[l12_sc_]+_b[l24_sc_]+_b[l36_sc_]+_b[l48_sc_]) ///
	, post level(90)

estimates store beta_incr_`y'

* plot beta coefficients
coefplot (beta_incr_`y', ciopts(recast(rcap)) recast(connected) level(90)) ///
  	, ///
  	vertical ///
  	keep (_nl_*) ///0
  	coeflabel(_nl_1 = -36 _nl_2 = -24 _nl_3 = -12 _nl_4 = 0 _nl_5 = 12 _nl_6 = 24 _nl_7 = 36)  /// _nl_8= "48+")
  	xline(3, lpattern(dash) lwidth(thin) lcolor(black)) xlabel(,labsize(medlarge)) ///
 	yline(0, lcolor(black) lwidth(thin)) ylabel(,labsize(medlarge)) ///
 	graphregion(color(white)) ///
  	xtitle (" " "Months relative to Secure communities shock", size(medlarge)) ytitle ("Treatment effect (90% c.i.)" " ", size(medlarge)) ///
	legend(off) ///
	note(" " "Observations: `obs', Municipalities: `N', Period: `month_start'/`year_start' - `month_end'/`year_end'.", size(small))
	
graph export "Output/Graphs/GES_SC`x'_`y'_all_12m_normneg1.pdf", replace
}
}
esttab est* using "Output\Tables\SC`x'_attend_enroll_all.tex", b(3) se(3)  ///
	replace label ar2 drop(_cons ) ///
	mtitles("Study" "Enroll" "On-track" "Migrate") star(* 0.10 ** 0.05 *** 0.01)  ///
	addnotes(Each regression controls for municipality, state-by-year, quarter-by-year, month, age and gender fixed effects.) ///
	title(Effect of Secure Communities on enrollment in Mexico\label{SCenroll})	


/*eststo clear 	
foreach y in study enroll ontrack {
eststo: reghdfe `y' f24_sc_2 f12_sc_2 sc_shock_2 l12_sc_2 l24_sc_2 l36_sc_2 c.migr_share#i.int_year [aw=fac], a($fe) cluster(geo2_mx2000)

local obs=e(N)
local N=e(N_clust)
sum int_year if e(sample)
local year_start = r(min)
local year_end = r(max)
sum int_month if int_year==`year_start' & e(sample)
local month_start = r(min)
sum int_month if int_year==`year_end' & e(sample)
local month_end = r(max)

nlcom ///
	(-(_b[f12_sc_]+_b[f24_sc_])) ///
	(-_b[f12_sc_]) ///
	(0) ///
	(_b[sc_shock_]) ///
	(_b[sc_shock_]+_b[l12_sc_]) ///
	(_b[sc_shock_]+_b[l12_sc_]+_b[l24_sc_]) ///
	(_b[sc_shock_]+_b[l12_sc_]+_b[l24_sc_]+_b[l36_sc_]) ///
	, post level(90)

estimates store beta_incr_`y'

* plot beta coefficients
coefplot (beta_incr_`y', ciopts(recast(rcap)) recast(connected) level(90)) ///
  	, ///
  	vertical ///
  	keep (_nl_*) ///
  	coeflabel(_nl_1 = -36 _nl_2 = -24 _nl_3 = -12 _nl_4 = 0 _nl_5 = 12 _nl_6 = 24 _nl_7 = 36) ///
  	xline(3, lpattern(dash) lwidth(thin) lcolor(black)) xlabel(,labsize(medlarge)) ///
 	yline(0, lcolor(black) lwidth(thin)) ylabel(,labsize(medlarge)) ///
 	graphregion(color(white)) ///
  	xtitle (" " "Months relative to Secure communities shock", size(medlarge)) ytitle ("Treatment effect (90% c.i.)" " ", size(medlarge)) ///
	legend(off) ///
	note(" " "Observations: `obs', Municipalities: `N', Period: `month_start'/`year_start' - `month_end'/`year_end'.", size(small))
	
graph export "Output/Graphs/GES_SC2_`y'_all_12m_normlag1.pdf", replace
} 
*/

eststo clear 
foreach x in 5 {	
foreach y in study enroll yrs_offtrack migrant {
eststo: reghdfe `y' f12_sc_`x' sc_shock_`x' l12_sc_`x' l24_sc_`x' l36_sc_`x' c.migr_share#i.int_year [aw=fac] if eda<=14, a($fe) cluster(geo2_mx2000)

local obs=e(N)
local N=e(N_clust)
sum int_year if e(sample)
local year_start = r(min)
local year_end = r(max)
sum int_month if int_year==`year_start' & e(sample)
local month_start = r(min)
sum int_month if int_year==`year_end' & e(sample)
local month_end = r(max)

nlcom ///
	(-(_b[sc_shock_]+_b[f12_sc_])) ///
	(-_b[sc_shock_]) ///
	(0) ///
	(_b[l12_sc_]) ///
	(_b[l12_sc_]+_b[l24_sc_]) ///
	(_b[l12_sc_]+_b[l24_sc_]+_b[l36_sc_]) ///
	, post level(90)

estimates store beta_incr_`y'

* plot beta coefficients
coefplot (beta_incr_`y', ciopts(recast(rcap)) recast(connected) level(90)) ///
  	, ///
  	vertical ///
  	keep (_nl_*) ///
  	coeflabel(_nl_1 = -24 _nl_2 = -12 _nl_3 = 0 _nl_4 = 12 _nl_5 = 24 _nl_6 = 36) ///
  	xline(3, lpattern(dash) lwidth(thin) lcolor(black)) xlabel(,labsize(medlarge)) ///
 	yline(0, lcolor(black) lwidth(thin)) ylabel(,labsize(medlarge)) ///
 	graphregion(color(white)) ///
  	xtitle (" " "Months relative to Secure communities shock", size(medlarge)) ytitle ("Treatment effect (90% c.i.)" " ", size(medlarge)) ///
	legend(off) ///
	note(" " "Observations: `obs', Municipalities: `N', Period: `month_start'/`year_start' - `month_end'/`year_end'.", size(small))
	
graph export "Output/Graphs/GES_SC`x'_`y'_12to14_12m_norm0.pdf", replace
}
}
esttab est* using "Output\Tables\SC`x'_attend_enroll_12to14.tex", b(3) se(3)  ///
	replace label ar2 drop(_cons ) ///
	mtitles("Study" "Enroll" "On track" "Migrate") star(* 0.10 ** 0.05 *** 0.01)  ///
	addnotes(Each regression controls for municipality, state-by-year, quarter-by-year, month, age and gender fixed effects.) ///
	title(Effect of Secure Communities on enrollment in Mexico\label{SCenroll})	
	
eststo clear 
foreach x in 5 {	
foreach y in study enroll yrs_off migrant {
eststo: reghdfe `y' f12_sc_`x' sc_shock_`x' l12_sc_`x' l24_sc_`x' l36_sc_`x' c.migr_share#i.int_year [aw=fac] if eda>14 & eda<18, a($fe) cluster(geo2_mx2000)

local obs=e(N)
local N=e(N_clust)
sum int_year if e(sample)
local year_start = r(min)
local year_end = r(max)
sum int_month if int_year==`year_start' & e(sample)
local month_start = r(min)
sum int_month if int_year==`year_end' & e(sample)
local month_end = r(max)

nlcom ///
	(-(_b[sc_shock_]+_b[f12_sc_])) ///
	(-_b[sc_shock_]) ///
	(0) ///
	(_b[l12_sc_]) ///
	(_b[l12_sc_]+_b[l24_sc_]) ///
	(_b[l12_sc_]+_b[l24_sc_]+_b[l36_sc_]) ///
	, post level(90)

estimates store beta_incr_`y'

* plot beta coefficients
coefplot (beta_incr_`y', ciopts(recast(rcap)) recast(connected) level(90)) ///
  	, ///
  	vertical ///
  	keep (_nl_*) ///
  	coeflabel(_nl_1 = -24 _nl_2 = -12 _nl_3 = 0 _nl_4 = 12 _nl_5 = 24 _nl_6 = 36) ///
  	xline(3, lpattern(dash) lwidth(thin) lcolor(black)) xlabel(,labsize(medlarge)) ///
 	yline(0, lcolor(black) lwidth(thin)) ylabel(,labsize(medlarge)) ///
 	graphregion(color(white)) ///
  	xtitle (" " "Months relative to Secure communities shock", size(medlarge)) ytitle ("Treatment effect (90% c.i.)" " ", size(medlarge)) ///
	legend(off) ///
	note(" " "Observations: `obs', Municipalities: `N', Period: `month_start'/`year_start' - `month_end'/`year_end'.", size(small))
	
graph export "Output/Graphs/GES_SC`x'_`y'_15to17_12m_norm0.pdf", replace
}
}
esttab est* using "Output\Tables\SC`x'_attend_enroll_15to17.tex", b(3) se(3)  ///
	replace label ar2 drop(_cons ) ///
	mtitles("Study" "Enroll" "Ontrack" "Migrate") star(* 0.10 ** 0.05 *** 0.01)  ///
	addnotes(Each regression controls for municipality, state-by-year, quarter-by-year, month, age and gender fixed effects.) ///
	title(Effect of Secure Communities on enrollment in Mexico\label{SCenroll})	

** Age 18 to 20	
eststo clear 
foreach x in 5 {	
foreach y in study enroll yrs_off migrant {
eststo: reghdfe `y' f12_sc_`x' sc_shock_`x' l12_sc_`x' l24_sc_`x' l36_sc_`x' c.migr_share#i.int_year [aw=fac] if eda>=18, a($fe) cluster(geo2_mx2000)

local obs=e(N)
local N=e(N_clust)
sum int_year if e(sample)
local year_start = r(min)
local year_end = r(max)
sum int_month if int_year==`year_start' & e(sample)
local month_start = r(min)
sum int_month if int_year==`year_end' & e(sample)
local month_end = r(max)

nlcom ///
	(-(_b[sc_shock_]+_b[f12_sc_])) ///
	(-_b[sc_shock_]) ///
	(0) ///
	(_b[l12_sc_]) ///
	(_b[l12_sc_]+_b[l24_sc_]) ///
	(_b[l12_sc_]+_b[l24_sc_]+_b[l36_sc_]) ///
	, post level(90)

estimates store beta_incr_`y'

* plot beta coefficients
coefplot (beta_incr_`y', ciopts(recast(rcap)) recast(connected) level(90)) ///
  	, ///
  	vertical ///
  	keep (_nl_*) ///
  	coeflabel(_nl_1 = -24 _nl_2 = -12 _nl_3 = 0 _nl_4 = 12 _nl_5 = 24 _nl_6 = 36) ///
  	xline(3, lpattern(dash) lwidth(thin) lcolor(black)) xlabel(,labsize(medlarge)) ///
 	yline(0, lcolor(black) lwidth(thin)) ylabel(,labsize(medlarge)) ///
 	graphregion(color(white)) ///
  	xtitle (" " "Months relative to Secure communities shock", size(medlarge)) ytitle ("Treatment effect (90% c.i.)" " ", size(medlarge)) ///
	legend(off) ///
	note(" " "Observations: `obs', Municipalities: `N', Period: `month_start'/`year_start' - `month_end'/`year_end'.", size(small))
	
graph export "Output/Graphs/GES_SC`x'_`y'_18to20_12m_norm0.pdf", replace
}
}
esttab est* using "Output\Tables\SC`x'_attend_enroll_18to20.tex", b(3) se(3)  ///
	replace label ar2 drop(_cons ) ///
	mtitles("Study" "Enroll" "Work") star(* 0.10 ** 0.05 *** 0.01)  ///
	addnotes(Each regression controls for municipality, state-by-year, quarter-by-year, month, age and gender fixed effects.) ///
	title(Effect of Secure Communities on enrollment in Mexico\label{SCenroll})	
		
