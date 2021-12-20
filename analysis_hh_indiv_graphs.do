
use $Data_built\ENOE_timeuse_shock_all.dta, clear
keep if int_year>=2005
keep if int_year<=2012
keep if migr_share>0
*keep if eda<21

gen age_group=.
replace age_group=1 if eda<=14
replace age_group=2 if eda>=15 & eda<=17
replace age_group=3 if eda>=18 & eda<=22
replace age_group=4 if eda>=23 & eda<=35
replace age_group=5 if eda>=36 




global fe i.sex i.eda i.time_yq i.time_yq##i.geo1_mx2000 i.int_month i.geo2_mx2000
global fehhvari  i.time_yq i.time_yq##i.geo1_mx2000 i.int_month i.geo2_mx2000



*******************************************
*Function writing
*******************************************
*generate a function the will use certain shock (5) to produce both weighted shocks/not weighted shock graphs for a particular dependent variable 
*funtion inputs: 
*`1' shocknumbr
*`2' outcome variable 
*`3' fe vector
*`4' control vector
*`5' "*" if so not want to produce all individual graphs. 
*
cap prog drop makegraph_ind
prog def makegraph_ind, rclass
local pw2 = "pw"+"`2'"
eststo clear

eststo: reghdfe `pw2' f18_sc_`1' f12_sc_`1' f6_sc_`1' sc_shock_`1' l6_sc_`1' l12_sc_`1' l18_sc_`1' l24_sc_`1' l30_sc_`1' l36_sc_`1' l42_sc_`1' $`4'[aw=fac], a($`3') cluster(geo2_mx2000)
local obs=e(N)
local N=e(N_clust)
sum year if e(sample)
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
	(_b[l6_sc_]+_b[l12_sc_]+_b[l18_sc_]+_b[l24_sc_]+_b[l30_sc_]+_b[l36_sc_]) ///
	(_b[l6_sc_]+_b[l12_sc_]+_b[l18_sc_]+_b[l24_sc_]+_b[l30_sc_]+_b[l36_sc_]+_b[l42_sc_]) ///
	, post level(90)

estimates store beta_incr

* plot beta coefficients
coefplot (beta_incr, ciopts(recast(rcap)) recast(connected) level(90)) ///
  	, ///
  	vertical ///
  	keep (_nl_*) ///
	coeflabel(_nl_1 = -24 _nl_2 = -18 _nl_3 = -12 _nl_4 = -6 _nl_5 = 0 _nl_6 = 6 _nl_7 = 12 _nl_8 = 18 _nl_9 = 24 _nl_10 = 30 _nl_11 = 36 _nl_12 = 42) ///
 	xline(3, lpattern(dash) lwidth(thin) lcolor(black)) xlabel(,labsize(medlarge)) ///
 	yline(0, lcolor(black) lwidth(thin)) ylabel(,labsize(medlarge)) ///
 	graphregion(color(white)) ///
  	xtitle (" " "Months relative to Secure communities shock", size(medlarge)) ytitle ("Treatment effect (90% c.i.)" " ", size(medlarge)) ///
	legend(off) ///
	note(" " "Observations: `obs', Period: `month_start'/`year_start' - `month_end'/`year_end'.", size(small))
	
`5' graph export  "$output/`2'_`1'_pw.pdf", replace



local pw2 = "pw"+"`2'"
eststo clear

eststo: reghdfe `pw2' f18_scnw_`1' f12_scnw_`1' f6_scnw_`1' sc_noweight_`1' l6_scnw_`1' l12_scnw_`1' l18_scnw_`1' l24_scnw_`1' l30_scnw_`1' l36_scnw_`1' $`4'[aw=fac], a($`3') cluster(geo2_mx2000)
local obs=e(N)
local N=e(N_clust)
sum year if e(sample)
local year_start = r(min)
local year_end = r(max)
local month_start = 1
local month_end = 12

nlcom ///
	(-(_b[sc_noweight_]+_b[f6_scnw_]+_b[f12_scnw_]+_b[f18_scnw_])) ///
	(-(_b[sc_noweight_]+_b[f6_scnw_]+_b[f12_scnw_])) ///
	(-(_b[sc_noweight_]+_b[f6_scnw_])) ///
	(-_b[sc_noweight_]) ///
	(0) ///
	(_b[l6_scnw_]) ///
	(_b[l6_scnw_]+_b[l12_scnw_]) ///
	(_b[l6_scnw_]+_b[l12_scnw_]+_b[l18_scnw_]) ///
	(_b[l6_scnw_]+_b[l12_scnw_]+_b[l18_scnw_]+_b[l24_scnw_]) /// 
	(_b[l6_scnw_]+_b[l12_scnw_]+_b[l18_scnw_]+_b[l24_scnw_]+_b[l30_scnw_]) ///
	(_b[l6_scnw_]+_b[l12_scnw_]+_b[l18_scnw_]+_b[l24_scnw_]+_b[l30_scnw_]+_b[l36_scnw_]) ///
	, post level(90)
	
estimates store beta_incr

* plot beta coefficients
coefplot (beta_incr, ciopts(recast(rcap)) recast(connected) level(90)) ///
  	, ///
  	vertical ///
  	keep (_nl_*) ///
	coeflabel(_nl_1 = -24 _nl_2 = -18 _nl_3 = -12 _nl_4 = -6 _nl_5 = 0 _nl_6 = 6 _nl_7 = 12 _nl_8 = 18 _nl_9 = 24 _nl_10 = 30 _nl_11 = 36 _nl_12 = 42) ///
 	xline(3, lpattern(dash) lwidth(thin) lcolor(black)) xlabel(,labsize(medlarge)) ///
 	yline(0, lcolor(black) lwidth(thin)) ylabel(,labsize(medlarge)) ///
 	graphregion(color(white)) ///
  	xtitle (" " "Months relative to Secure communities shock", size(medlarge)) ytitle ("Treatment effect (90% c.i.)" " ", size(medlarge)) ///
	legend(off) ///
	note(" " "Observations: `obs', Period: `month_start'/`year_start' - `month_end'/`year_end'.", size(small))
	
`5' graph export  "$output/`2'_`1'_pw.pdf", replace



local pw2 = "pw"+"`2'"
eststo clear
eststo: reghdfe `pw2' f12_sc_2 sc_shock_2 l12_sc_2 l24_sc_2 l36_sc_2 `4' [aw=fac], a(`3') cluster(geo2_mx2000)

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
	
`5' graph export  "$output/`2'_`1'_pw.pdf", replace

eststo clear
eststo: reghdfe  `pw2' myoy_hhdeparts1_mnhh1  yoy_f2sc_noweight_5 yoy_f1sc_noweight_5 yoy_sc_noweight_5 yoy_l1sc_noweight_5 yoy_l2sc_noweight_5  $`4' [pw=muni_popweights], a($`3') 
local obs=e(N)
local N=e(N_clust)
sum year if e(sample)
local year_start = r(min)
local year_end = r(max)
local month_start = 1
local month_end = 12
estimates store beta_incr

coefplot , ///
  	vertical ///
  	keep ( yoy_f2sc_noweight_5 yoy_f1sc_noweight_5 yoy_sc_noweight_5 yoy_l1sc_noweight_5 yoy_l2sc_noweight_5) ///
  	coeflabel(yoy_f2sc_noweight_5=yoynwf2 yoy_f1sc_noweight_5=yoynwf1 yoy_sc_noweight_5=yoynw0  yoy_l1sc_noweight_5=yoynwl1  yoy_l2sc_noweight_5=yoynwl2) ///
  	xline(3, lpattern(dash) lwidth(thin) lcolor(black)) xlabel(,labsize(medlarge)) ///
 	yline(0, lcolor(black) lwidth(thin)) ylabel(,labsize(medlarge)) ///
 	graphregion(color(white)) ///
  	xtitle (" " "Secure communities shock in Year", size(medlarge)) ytitle (" " " ", size(medlarge)) ///
	legend(off) ///
	note(" " " Unweighted shocks and population weights. Observations: `obs', Municipalities: `N', Period: `month_start'/`year_start' - `month_end'/`year_end'.", size(small)) ///
	saving(2, replace)
`5' graph export  "$output/`2'_`1'_noscwgt_pw.pdf", replace




eststo clear
eststo: reghdfe `2'  yoy_f2sc_shock_5 yoy_f1sc_shock_5 yoy_sc_shock_5  yoy_l1sc_shock_5  yoy_l2sc_shock_5 $`4' [pw=muni_popweights], a($`3') 
local obs=e(N)
local N=e(N_clust)
sum year if e(sample)
local year_start = r(min)
local year_end = r(max)
local month_start = 1
local month_end = 12
estimates store beta_incr

coefplot , ///
  	vertical ///
  	keep (yoy_f2sc_shock_5 yoy_f1sc_shock_5 yoy_sc_shock_5  yoy_l1sc_shock_5  yoy_l2sc_shock_5) ///
  	coeflabel(yoy_f2sc_shock_5=yoyf2 yoy_f1sc_shock_5=yoyf1 yoy_sc_shock_5=yoy0  yoy_l1sc_shock_5=yoyl1  yoy_l2sc_shock_5=yoyl2) ///
  	xline(3, lpattern(dash) lwidth(thin) lcolor(black)) xlabel(,labsize(medlarge)) ///
 	yline(0, lcolor(black) lwidth(thin)) ylabel(,labsize(medlarge)) ///
 	graphregion(color(white)) ///
  	xtitle (" " "Secure communities shock in Year", size(medlarge)) ytitle (" " " ", size(medlarge)) ///
	legend(off) ///
	note(" " " Weighted shocks and no population weights. Observations: `obs', Municipalities: `N', Period: `month_start'/`year_start' - `month_end'/`year_end'.", size(small)) ///
	saving(3, replace)
`5' graph export "$output/`2'_`1'_a.pdf", replace

eststo clear
eststo: reghdfe `2' myoy_hhdeparts1_mnhh1  yoy_f2sc_noweight_5 yoy_f1sc_noweight_5 yoy_sc_noweight_5 yoy_l1sc_noweight_5 yoy_l2sc_noweight_5  $`4' [pw=muni_popweights], a($`3') 
local obs=e(N)
local N=e(N_clust)
sum year if e(sample)
local year_start = r(min)
local year_end = r(max)
local month_start = 1
local month_end = 12
estimates store beta_incr

coefplot , ///
  	vertical ///
  	keep ( yoy_f2sc_noweight_5 yoy_f1sc_noweight_5 yoy_sc_noweight_5 yoy_l1sc_noweight_5 yoy_l2sc_noweight_5) ///
  	coeflabel(yoy_f2sc_noweight_5=yoynwf2 yoy_f1sc_noweight_5=yoynwf1 yoy_sc_noweight_5=yoynw0  yoy_l1sc_noweight_5=yoynwl1  yoy_l2sc_noweight_5=yoynwl2) ///
  	xline(3, lpattern(dash) lwidth(thin) lcolor(black)) xlabel(,labsize(medlarge)) ///
 	yline(0, lcolor(black) lwidth(thin)) ylabel(,labsize(medlarge)) ///
 	graphregion(color(white)) ///
  	xtitle (" " "Secure communities shock in Year", size(medlarge)) ytitle (" " " ", size(medlarge)) ///
	legend(off) ///
	note(" " "Unweighted shocks and no population weights. Observations: `obs', Municipalities: `N', Period: `month_start'/`year_start' - `month_end'/`year_end'.", size(small)) ///
	saving(4, replace)
`5' graph export  "$output/`2'_`1'_noscwgt.pdf", replace



 gr combine  1.gph 2.gph 3.gph 4.gph, title("`2'")
 
 gr export "$output/`2'_`1'.pdf",replace

end


