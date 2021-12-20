
if "`c(username)'"=="gehrk001" {
	cap cd "C:\Users\gehrk001\Dropbox\MigrationShocks\"
}

if "`c(username)'"=="Claire" {
	cap cd "C:\Users\Claire\Dropbox\MigrationShocks\"
}
*************************************************************************************

use Data_built\ENOE\ENOE_timeuse_shock.dta, clear
keep if int_year>=2005
keep if int_year<=2012
keep if migr_share>0
keep if eda<21

global fe i.sex i.eda i.time_yq i.int_year##i.geo1_mx2000 i.int_month i.geo2_mx2000

eststo clear 	
foreach y in study enroll lfp {
eststo: reghdfe `y' f12_sc_2 sc_shock_2 l12_sc_2 l24_sc_2 l36_sc_2 c.migr_share#i.int_year [aw=fac], a($fe) cluster(geo2_mx2000)

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
	
graph export "Output/Graphs/GES_SC2_`y'_all_12m_norm0.pdf", replace
}

esttab est* using "Output\Tables\SC2_attend_enroll_all.tex", b(3) se(3)  ///
	replace label ar2 drop(_cons ) ///
	mtitles("Study" "Enroll" "Work") star(* 0.10 ** 0.05 *** 0.01)  ///
	addnotes(Each regression controls for municipality, state-by-year, quarter-by-year, month, age and gender fixed effects.) ///
	title(Effect of Secure Communities on enrollment in Mexico\label{SCenroll})	


eststo clear 	
foreach y in study enroll lfp {
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

eststo clear 	
foreach y in study enroll lfp {
eststo: reghdfe `y' f12_sc_2 sc_shock_2 l12_sc_2 l24_sc_2 l36_sc_2 c.migr_share#i.int_year [aw=fac] if eda<=14, a($fe) cluster(geo2_mx2000)

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
	
graph export "Output/Graphs/GES_SC2_`y'_12to14_12m_norm0.pdf", replace
}

esttab est* using "Output\Tables\SC2_attend_enroll_12to14.tex", b(3) se(3)  ///
	replace label ar2 drop(_cons ) ///
	mtitles("Study" "Enroll" "Work") star(* 0.10 ** 0.05 *** 0.01)  ///
	addnotes(Each regression controls for municipality, state-by-year, quarter-by-year, month, age and gender fixed effects.) ///
	title(Effect of Secure Communities on enrollment in Mexico\label{SCenroll})	
	
eststo clear 	
foreach y in study enroll lfp {
eststo: reghdfe `y' f12_sc_2 sc_shock_2 l12_sc_2 l24_sc_2 l36_sc_2 c.migr_share#i.int_year [aw=fac] if eda>14 & eda<18, a($fe) cluster(geo2_mx2000)

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
	
graph export "Output/Graphs/GES_SC2_`y'_15to17_12m_norm0.pdf", replace
}

esttab est* using "Output\Tables\SC2_attend_enroll_15to17.tex", b(3) se(3)  ///
	replace label ar2 drop(_cons ) ///
	mtitles("Study" "Enroll" "Work") star(* 0.10 ** 0.05 *** 0.01)  ///
	addnotes(Each regression controls for municipality, state-by-year, quarter-by-year, month, age and gender fixed effects.) ///
	title(Effect of Secure Communities on enrollment in Mexico\label{SCenroll})	

** Age 18 to 20	
eststo clear 	
foreach y in study enroll lfp {
eststo: reghdfe `y' f12_sc_2 sc_shock_2 l12_sc_2 l24_sc_2 l36_sc_2 c.migr_share#i.int_year [aw=fac] if eda>=18, a($fe) cluster(geo2_mx2000)

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
	
graph export "Output/Graphs/GES_SC2_`y'_18to20_12m_norm0.pdf", replace
}

esttab est* using "Output\Tables\SC2_attend_enroll_18to20.tex", b(3) se(3)  ///
	replace label ar2 drop(_cons ) ///
	mtitles("Study" "Enroll" "Work") star(* 0.10 ** 0.05 *** 0.01)  ///
	addnotes(Each regression controls for municipality, state-by-year, quarter-by-year, month, age and gender fixed effects.) ///
	title(Effect of Secure Communities on enrollment in Mexico\label{SCenroll})	
		
/*eststo clear 	
forvalues x=1/5 {
*eststo: reghdfe anymigrant_3m  f12_sc_1 sc_shock_1 l12_sc_1 l24_sc_1 c.migr_share#i.int_year [aw=fac] if int_year<=2012, a($fe) cluster(geo2_mx2000)
*eststo: reghdfe study  f12_sc_`x' sc_shock_`x' l12_sc_`x' l24_sc_`x' l36_sc_`x' c.migr_share#i.int_year [aw=fac] if int_year<=2012, a($fe) cluster(geo2_mx2000)
*eststo: reghdfe enroll  f12_sc_`x' sc_shock_`x' l12_sc_`x' l24_sc_`x' l36_sc_`x' c.migr_share#i.int_year [aw=fac] if int_year<=2012, a($fe) cluster(geo2_mx2000)
eststo: reghdfe study  f12_sc_`x' sc_shock_`x' l12_sc_`x' l24_sc_`x'  c.migr_share#i.time_yq [aw=fac] if int_year<=2012 & eda<18, a($fe) cluster(geo2_mx2000)
eststo: reghdfe enroll  f12_sc_`x' sc_shock_`x' l12_sc_`x' l24_sc_`x'  c.migr_share#i.time_yq [aw=fac] if int_year<=2012  & eda<18, a($fe) cluster(geo2_mx2000)
}

esttab est* using "Output\Tables\SC_attend_enroll_alttreatments2.tex", b(3) se(3)  ///
	replace label ar2 drop(_cons ) ///
	mtitles("Study" "Enroll" "Study" "Enroll" "Study" "Enroll" "Study" "Enroll" "Study" "Enroll") star(* 0.10 ** 0.05 *** 0.01)  ///
	addnotes(Each regression controls for municipality, state-by-year, quarter-by-year, month, age and gender fixed effects.) ///
	title(Effect of Secure Communities on enrollment in Mexico\label{SCenroll})	



eststo clear
eststo: reghdfe study sc_shock_2 c.migr_share#i.int_year [aw=fac], a($fe) cluster(geo2_mx2000)
foreach x in 6 12 18 24 {
eststo: reghdfe study l`x'_sc_2 c.migr_share#i.int_year [aw=fac], a($fe) cluster(geo2_mx2000)
eststo: reghdfe study f`x'_sc_2 c.migr_share#i.int_year [aw=fac], a($fe) cluster(geo2_mx2000)
} 	

eststo: reghdfe enroll sc_shock_2 c.migr_share#i.int_year [aw=fac], a($fe) cluster(geo2_mx2000)
foreach x in 6 12 18 24 {
eststo: reghdfe enroll l`x'_sc_2 c.migr_share#i.int_year [aw=fac], a($fe) cluster(geo2_mx2000)
eststo: reghdfe enroll f`x'_sc_2 c.migr_share#i.int_year [aw=fac], a($fe) cluster(geo2_mx2000)
} 	

esttab est* using "Output\Tables\SC_attend_enroll_1eadslags.tex", b(3) se(3)  ///
	replace label ar2 drop(_cons ) ///
	nomtitles star(* 0.10 ** 0.05 *** 0.01)  ///
	addnotes(Each regression controls for municipality, state-by-year, quarter-by-year, month, age and gender fixed effects.) ///
	title(Effect of Secure Communities on enrollment in Mexico\label{SCenroll})	

eststo est12: reghdfe enroll f2_sc2 f1 sc_shock2 l1_sc2 l2_sc2 [aw=fac] , a($fe) cluster(geo2_mx2000)	
coefplot est12, keep(f2_sc2 f1 sc_shock2 l1_sc2 l2_sc2) yline(0) vertical levels(90) omitt
graph save "$tex\SC_enroll_eventstudy.gph", replace

eststo est13: reghdfe study f2_sc2 f1 sc_shock2 l1_sc2 l2_sc2 [aw=fac], a($fe) cluster(geo2_mx2000)	
coefplot est13, keep(f2_sc2 f1 sc_shock2 l1_sc2 l2_sc2) yline(0) vertical levels(90) omitt
graph save "$tex\SC_attend_eventstudy.gph", replace
*/

/*
eststo clear
eststo: reghdfe study sc_shock2 if eda<=16 [aw=fac], a($fe) cluster(geo2_mx2000)
eststo: reghdfe study sc_shock2 l1_sc2 c.migr_share#c.ym [aw=fac], a($fe) cluster(geo2_mx2000)

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
global fe_modate i.sex i.eda i.ym i.year##i.quarter##i.geo1_mx2000 i.month i.geo2_mx2000

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
 
eststo: reghdfe enroll sc_shock2 if eda>=15 & eda<=17 [aw=fac] , a($fe) cluster(geo2_mx2000)
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
eststo: reghdfe enroll f12_sc2 f6_sc2 sc_shock2 l6_sc2 l12_sc2 [aw=fac], a($fe) cluster(geo2_mx2000)
eststo: reghdfe enroll f12_sc2 sc_shock2 l12_sc2 [aw=fac], a($fe) cluster(geo2_mx2000)
eststo: reghdfe enroll f12_sc2 f6_sc2 sc_shock2 l6_sc2 l12_sc2 l18_sc2 l24_sc2 if obs>=2.66 [aw=fac], a($fe) cluster(geo2_mx2000)

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

*************************************************************************************************************************
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



log close
