
clear all

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

*output file 
global graphs "Output\Graphs\"
global tables "Output\Tables\"
set more off
//ssc install coefplot

/* To check if data reproduce national statistics
use Data_built\ENOE\ENOE_muniagg_prog.dta, clear
collapse (sum) poptotal pwmuni_pop_sum15plus, by(quarter year)

use Data_built\ENOE\ENOE_muniagg_prog.dta, clear
su pwmuni_wage_hr_mean15plus pwmuni_lfp_mean15plus pwmuni_unempl_mean15plus pwmuni_ls_hrs_mean15plus [aw=pwmuni_pop_sum15plus] if year==2008 & quarter==4
// note the small discrepancies in the wage data which result from not obersing wages in all municipalities (and hence not properly weighting the sample)
*/


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
cap prog drop makegraph_1
prog def makegraph_1, rclass


*use Data_built\ENOE\ENOE_muniagg_prog.dta, clear

*get pw variable name

local pw2 = "pw"+"`2'"

eststo clear
eststo: reghdfe `pw2' f18_sc_`1' f12_sc_`1' f6_sc_`1' sc_shock_`1' l6_sc_`1' l12_sc_`1' l18_sc_`1' l24_sc_`1' l30_sc_`1' l36_sc_`1' l42_sc_`1' $`4' [pw=muni_popweights], a($`3') cluster(geo2_mx2000)
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
coefplot (beta_incr, ciopts(recast(rcap)) recast(connected) level(90)), ///
  	vertical ///
  	keep (_nl_*) ///
  	coeflabel(_nl_1 = -24 _nl_2 = -18 _nl_3 = -12 _nl_4 = -6 _nl_5 = 0 _nl_6 = 6 _nl_7 = 12 _nl_8 = 18 _nl_9 = 24 _nl_10 = 30 _nl_11 = 36 _nl_12 = 42) ///
  	xline(5, lpattern(dash) lwidth(thin) lcolor(black)) xlabel(,labsize(medlarge)) ///
 	yline(0, lcolor(black) lwidth(thin)) ylabel(,labsize(medlarge)) ///
 	graphregion(color(white)) ///
  	xtitle (" " "Months relative to Secure communities shock", size(medlarge)) ytitle (" " " ", size(medlarge)) ///
	legend(off) ///
	note(" " " Weighted shocks and population weights. Observations: `obs', Municipalities: `N', Period: `month_start'/`year_start' - `month_end'/`year_end'.", size(small)) ///
	saving(1, replace)
`5' graph export "Output/Graphs/selected/SC`1'_`2'_norm0_pw.pdf", replace

eststo clear
eststo clear
eststo: reghdfe `pw2' f18_scnw_`1' f12_scnw_`1' f6_scnw_`1' sc_noweight_`1' l6_scnw_`1' l12_scnw_`1' l18_scnw_`1' l24_scnw_`1' l30_scnw_`1' l36_scnw_`1'  $`4' [pw=muni_popweights], a($`3') cluster(geo2_mx2000)
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
coefplot (beta_incr, ciopts(recast(rcap)) recast(connected) level(90)), ///
  	vertical ///
  	keep (_nl_*) ///
  	coeflabel(_nl_1 = -24 _nl_2 = -18 _nl_3 = -12 _nl_4 = -6 _nl_5 = 0 _nl_6 = 6 _nl_7 = 12 _nl_8 = 18 _nl_9 = 24 _nl_10 = 30 _nl_11 = 36 ) ///
  	xline(5, lpattern(dash) lwidth(thin) lcolor(black)) xlabel(,labsize(medlarge)) ///
 	yline(0, lcolor(black) lwidth(thin)) ylabel(,labsize(medlarge)) ///
 	graphregion(color(white)) ///
  	xtitle (" " "Months relative to Secure communities shock", size(medlarge)) ytitle (" " " ", size(medlarge)) ///
	legend(off) ///
	note(" " "Unweighted shocks and population weights. Observations: `obs', Municipalities: `N', Period: `month_start'/`year_start' - `month_end'/`year_end'.  ", size(small))	///
	saving(2, replace)
`5' graph export "Output/Graphs/selected/SC`1'_`2'_norm0_noscwgt_pw.pdf", replace



***************************

***with no probability weights
eststo clear
eststo: reghdfe `2' f18_sc_`1' f12_sc_`1' f6_sc_`1' sc_shock_`1' l6_sc_`1' l12_sc_`1' l18_sc_`1' l24_sc_`1' l30_sc_`1' l36_sc_`1'  $`4' [pw=muni_popweights], a($`3') cluster(geo2_mx2000)
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
	, post level(90)

estimates store beta_incr

* plot beta coefficients
coefplot (beta_incr, ciopts(recast(rcap)) recast(connected) level(90)), ///
  	vertical ///
  	keep (_nl_*) ///
  	coeflabel(_nl_1 = -24 _nl_2 = -18 _nl_3 = -12 _nl_4 = -6 _nl_5 = 0 _nl_6 = 6 _nl_7 = 12 _nl_8 = 18 _nl_9 = 24 _nl_10 = 30 _nl_11 = 36 ) ///
  	xline(5, lpattern(dash) lwidth(thin) lcolor(black)) xlabel(,labsize(medlarge)) ///
 	yline(0, lcolor(black) lwidth(thin)) ylabel(,labsize(medlarge)) ///
 	graphregion(color(white)) ///
  	xtitle (" " "Months relative to Secure communities shock", size(medlarge)) ytitle (" " " ", size(medlarge)) ///
	legend(off) ///
	note(" " " Weighted shocks and no population weights. Observations: `obs', Municipalities: `N', Period: `month_start'/`year_start' - `month_end'/`year_end'.", size(small)) ///
	saving(3, replace)
`5' graph export "Output/Graphs/selected/SC`1'_`2'_norm0_nopw.pdf", replace

eststo clear
eststo clear
eststo: reghdfe `2' f18_scnw_`1' f12_scnw_`1' f6_scnw_`1' sc_noweight_`1' l6_scnw_`1' l12_scnw_`1' l18_scnw_`1' l24_scnw_`1' l30_scnw_`1' l36_scnw_`1'  $`4' [pw=muni_popweights], a($`3') cluster(geo2_mx2000)
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
coefplot (beta_incr, ciopts(recast(rcap)) recast(connected) level(90)), ///
  	vertical ///
  	keep (_nl_*) ///
  	coeflabel(_nl_1 = -24 _nl_2 = -18 _nl_3 = -12 _nl_4 = -6 _nl_5 = 0 _nl_6 = 6 _nl_7 = 12 _nl_8 = 18 _nl_9 = 24 _nl_10 = 30 _nl_11 = 36 ) ///
  	xline(5, lpattern(dash) lwidth(thin) lcolor(black)) xlabel(,labsize(medlarge)) ///
 	yline(0, lcolor(black) lwidth(thin)) ylabel(,labsize(medlarge)) ///
 	graphregion(color(white)) ///
  	xtitle (" " "Months relative to Secure communities shock", size(medlarge)) ytitle (" " " ", size(medlarge)) ///
	legend(off) ///
	note(" " "Unweighted shocks and no population weights. Observations: `obs', Municipalities: `N', Period: `month_start'/`year_start' - `month_end'/`year_end'.  ", size(small))	///
	saving(4, replace)
`5' graph export "Output/Graphs/selected/SC`1'_`2'_norm0_noscwgt_nopw.pdf", replace

****combingin all iterations

 gr combine  1.gph 2.gph 3.gph 4.gph, title("`2'")
 
 gr export "Output/Graphs/selected/SC`1'_`2'_norm0.pdf",replace

end

***************************************************************************************
***************************************************************************************
***************************************************************************************
***************************************************************************************
***************************************************************************************
***************************************************************************************




***************************************************************************************
*MAKING GRAPHS
***************************************************************************************

use Data_built\ENOE\ENOE_muniagg_prog.dta, clear
*keep if year<=2014
*keep if migr_share>0
global fe i.int_yq i.year##i.geo1_mx2000 i.geo2_mx2000
global controls c.migr_share#i.int_yq


***note I changed the population weights of the municipalities to use pre2008 average as measure in enoe  

*population and hh composition
foreach y in muni_pop_sum15plus muni_hh_earn_mo_meanhh  muni_got_remit_3m_meanhh muni_hhv_kids_meanhh  muni_hhv_teen_f_meanhh  muni_hhv_teen_m_meanhh  muni_hhv_youngadult_f_meanhh  muni_hhv_youngadult_m_meanhh  muni_hhv_adult_m_meanhh  muni_hhv_adult_f_meanhh  muni_hhsize_meanhh muni_pop_logtotpop  muni_yoy_hhdeparts2_sumhh muni_yoy_hharrives2_sumhh muni_yoy_hhdeparts1_meanhh muni_yoy_hharrives1_meanhh{
makegraph_1 5 `y' fe controls "*"
}




**15 and up
foreach y in muni_inc_mo_mean15plus muni_logwage_mean15plus muni_wage_loweduc_mean15plus muni_wage_higheduc_mean15plus muni_ls_dum1_low_mean15plus muni_ls_dum1_high_mean15plus muni_lfp_mean15plus muni_unempl_mean15plus muni_ls_hrs_mean15plus  muni_pop_sum15plus  muni_ls_dum2_low_sum15plus muni_ls_dum2_high_sum15plus muni_migrant2_sum15plus muni_dom_migrant2_sum15plus muni_returnee2_sum15plus muni_dom_returnee2_sum15plus muni_migrant1_mean15plus muni_dom_migrant1_mean15plus muni_returnee1_mean15plus muni_dom_returnee1_mean15plus muni_pop_sum15plus muni_pop_log15plus{
makegraph_1 5 `y' fe controls "*"
}
 
 
**20 and under
foreach y in muni_study1_mean20und muni_lfp_mean20und muni_unempl_mean20und muni_ls_hrs_mean20und muni_wage_hr_mean20und muni_inc_mo_mean20und muni_chores_mean20und muni_study_hrs_mean20und muni_enroll1_mean20und muni_yrs_offtrack_mean20und muni_female_mean20und muni_study2_sum20und muni_enroll2_sum20und muni_migrant2_sum20und muni_dom_migrant2_sum20und muni_returnee2_sum20und muni_dom_returnee2_sum20und  muni_migrant1_mean20und muni_dom_migrant1_mean20und muni_returnee1_mean20und muni_dom_returnee1_mean20und muni_pop_sum20und muni_pop_log20und muni_enroll2_log20und{
makegraph_1 5 `y' fe controls "*"
}
 
foreach y in muni_enroll2_log20und{
makegraph_1 5 `y' fe controls "*"
} 
 
*** 12to14
foreach y in muni_study1_mean1214 muni_lfp_mean1214 muni_unempl_mean1214 muni_ls_hrs_mean1214 muni_chores_mean1214 muni_chores_hrs_mean1214 muni_study_hrs_mean1214 muni_enroll1_mean1214 muni_yrs_offtrack_mean1214 muni_female_mean1214 muni_wage_hr_mean1214 muni_study2_sum1214 muni_enroll2_sum1214 muni_migrant2_sum1214 muni_dom_migrant2_sum1214 muni_returnee2_sum1214 muni_dom_returnee2_sum1214  muni_migrant1_mean1214 muni_dom_migrant1_mean1214 muni_returnee1_mean1214 muni_dom_returnee1_mean1214 muni_pop_sum1214 muni_pop_log1214 muni_enroll2_log1214{
makegraph_1 5 `y' fe controls "*"
}

*** 15to17 
foreach y in muni_study1_mean1517 muni_lfp_mean1517  muni_unempl_mean1517  muni_ls_hrs_mean1517  muni_chores_mean1517  muni_chores_hrs_mean1517  muni_study_hrs_mean1517  muni_enroll1_mean1517  muni_yrs_offtrack_mean1517  muni_female_mean1517  muni_wage_hr_mean1517  muni_study2_sum1517  muni_enroll2_sum1517  muni_migrant2_sum1517  muni_dom_migrant2_sum1517  muni_returnee2_sum1517  muni_dom_returnee2_sum1517   muni_migrant1_mean1517 muni_dom_migrant1_mean1517 muni_returnee1_mean1517 muni_dom_returnee1_mean1517 muni_pop_sum1517 muni_pop_log1517 muni_enroll2_log1517 {
makegraph_1 5 `y' fe controls "*"
}
 
 
***  18 to 20 
foreach y in muni_study1_mean1820 muni_lfp_mean1820  muni_unempl_mean1820  muni_ls_hrs_mean1820  muni_chores_mean1820  muni_chores_hrs_mean1820  muni_study_hrs_mean1820  muni_enroll1_mean1820  muni_yrs_offtrack_mean1820  muni_female_mean1820  muni_wage_hr_mean1820 muni_wage_loweduc_mean1820 muni_wage_higheduc_mean1820 muni_study2_sum1820  muni_enroll2_sum1820  muni_migrant2_sum1820  muni_dom_migrant2_sum1820  muni_returnee2_sum1820  muni_dom_returnee2_sum1820 muni_migrant1_mean1820 muni_dom_migrant1_mean1820 muni_returnee1_mean1820 muni_dom_returnee1_mean1820  muni_pop_sum1820 muni_pop_log1820 muni_enroll2_log1820  {
makegraph_1 5 `y' fe controls "*"
}
 
 *** 21 to 35
 foreach y in muni_lfp_mean2135 muni_unempl_mean2135 muni_ls_hrs_mean2135 muni_female_mean2135 muni_wage_hr_mean2135 muni_wage_loweduc_mean2135 muni_wage_higheduc_mean2135 muni_migrant2_sum2135 muni_dom_migrant2_sum2135 muni_returnee2_sum2135 muni_dom_returnee2_sum2135 muni_migrant1_mean2135 muni_dom_migrant1_mean2135 muni_returnee1_mean2135 muni_dom_returnee1_mean2135 muni_pop_sum2135 muni_pop_log2135 {
makegraph_1 5 `y' fe controls "*"
}

*** 21plus
 foreach y in muni_lfp_mean21plus muni_unempl_mean21plus muni_ls_hrs_mean21plus muni_female_mean21plus muni_wage_hr_mean21plus muni_wage_loweduc_mean21plus muni_wage_higheduc_mean21plus muni_migrant2_sum21plus muni_dom_migrant2_sum21plus muni_returnee2_sum21plus muni_dom_returnee2_sum21plus muni_migrant1_mean21plus muni_dom_migrant1_mean21plus muni_returnee1_mean21plus muni_dom_returnee1_mean21plus muni_pop_sum21plus muni_pop_log21plus{
makegraph_1 5 `y' fe controls "*"
 }


 STOP


 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 




******************************************************************************************
*Claire Wages
use Data_built\ENOE\ENOE_timeuse_shock_munbyquarter.dta, clear


*WEIGHTED
global fe i.int_yq i.year##i.geo1_mx2000 i.geo2_mx2000

gen net_mig_3m=mun_migr_3m-mun_return_3m
gen hh_earn_peradult=mun_hh_earn/(hhv_adult_m+hhv_adult_f)
gen wage_gap=log(mun_wage_high)- log(mun_wage_low)
gen wage_gap2=mun_wage_high- mun_wage_low

gen wage_gap_21to35=wage_higheduc_21to35-wage_loweduc_21to35 


gen H_over_L_over18=log(mun_sumlfp_old_high)-log(mun_sumlfp_old_low )

gen log_mun_wage_low=log(mun_wage_low)
gen log_mun_wage_high=log(mun_wage_high)
gen log_wage_loweduc_21to35=log(wage_loweduc_21to35)
gen log_wage_higheduc_21to35=log(wage_higheduc_21to35)


gen log_wage_loweduc_21plus=log(wage_loweduc_21plus)
gen log_wage_higheduc_21plus=log(wage_higheduc_21plus)

gen log_gap_21plus=log(wage_higheduc_21plus-wage_loweduc_21plus)
gen log_gap_21to35=log(wage_higheduc_21to35-wage_loweduc_21to35)
gen log_wage_ent1_drp_und18= log(wage_hr_ent1_drp_und18)


gen log_mun_pop=log(mun_totalpop )


*population and composition changes

eststo clear
foreach x in 5 { 	
foreach y in  logobs_21plus mun_pop  mun_totalpop  hhv_kids hhv_teen_f hhv_teen_m hhv_youngadult_f hhv_youngadult_m hhv_adult_m hhv_adult_f hhsize log_mun_pop{
*remit question only in ampliado questionair so will only be asked to hh once. 
eststo: reghdfe `y' f18_sc_`x' f12_sc_`x' f6_sc_`x' sc_shock_`x' l6_sc_`x' l12_sc_`x' l18_sc_`x' l24_sc_`x' l30_sc_`x' l36_sc_`x' c.migr_share#i.int_yq  [pw=mun_totalpop], a($fe) cluster(geo2_mx2000)

local obs=e(N)
local N=e(N_clust)
sum year if e(sample)
local year_start = r(min)
local year_end = r(max)
local month_start = 1
local month_end = 12

nlcom ///
	(-(_b[l12_sc_]+_b[l18_sc_]+_b[l6_sc_])) ///
	(-(_b[f12_sc_]+_b[f6_sc_])) ///
	(-_b[f6_sc_]) ///
	(0) ///
	(_b[sc_shock_]) ///
	(_b[sc_shock_]+_b[l6_sc_]) ///
	(_b[sc_shock_]+_b[l12_sc_]+_b[l6_sc_]) ///
	(_b[sc_shock_]+_b[l12_sc_]+_b[l6_sc_]+_b[l18_sc_]) /// 
	(_b[sc_shock_]+_b[l12_sc_]+_b[l6_sc_]+_b[l18_sc_]+_b[l24_sc_]) ///
	(_b[sc_shock_]+_b[l12_sc_]+_b[l6_sc_]+_b[l18_sc_]+_b[l24_sc_]+_b[l30_sc_]) ///
	(_b[sc_shock_]+_b[l12_sc_]+_b[l6_sc_]+_b[l18_sc_]+_b[l24_sc_]+_b[l30_sc_]+_b[l36_sc_]) ///
	, post level(90)

estimates store beta_incr_

* plot beta coefficients
coefplot (beta_incr_, ciopts(recast(rcap)) recast(connected) level(90)), ///
  	vertical ///
  	keep (_nl_*) ///
  	coeflabel(_nl_1 = -24 _nl_2 = -18 _nl_3 = -12 _nl_4 = -6 _nl_5 = 0 _nl_6 = 6 _nl_7 = 12 _nl_8 = 18 _nl_9 = 24 _nl_10 = 30 _nl_11 = 36) ///
  	xline(4.5, lpattern(dash) lwidth(thin) lcolor(black)) xlabel(,labsize(medlarge)) ///
 	yline(0, lcolor(black) lwidth(thin)) ylabel(,labsize(medlarge)) ///
 	graphregion(color(white)) ///
  	xtitle (" " "Months relative to Secure communities shock", size(medlarge)) ytitle ("Treatment effect (90% c.i.)" " ", size(medlarge)) ///
	legend(off) ///
	note(" " "Observations: `obs', Municipalities: `N', Period: `month_start'/`year_start' - `month_end'/`year_end'.", size(small))
	
graph export "Output/Graphs/GES_SC`x'_`y'_mun_norm0.pdf", replace
}
}
*




*migration of adults post schooling 
eststo clear
foreach x in 5 { 	
foreach y in migrant migrant_12to20 migrant_21plus dom_migrant dom_migrant_12to20 dom_migrant_21plus unempl_12to20 unempl_21to35 unempl_21plus unempl_15to17  {
*remit question only in ampliado questionair so will only be asked to hh once. 
eststo: reghdfe `y' f18_sc_`x' f12_sc_`x' f6_sc_`x' sc_shock_`x' l6_sc_`x' l12_sc_`x' l18_sc_`x' l24_sc_`x' l30_sc_`x' l36_sc_`x' c.migr_share#i.int_yq  [pw=mun_totalpop], a($fe) cluster(geo2_mx2000)

local obs=e(N)
local N=e(N_clust)
sum year if e(sample)
local year_start = r(min)
local year_end = r(max)
local month_start = 1
local month_end = 12

nlcom ///
	(-(_b[l12_sc_]+_b[l18_sc_]+_b[l6_sc_])) ///
	(-(_b[f12_sc_]+_b[f6_sc_])) ///
	(-_b[f6_sc_]) ///
	(0) ///
	(_b[sc_shock_]) ///
	(_b[sc_shock_]+_b[l6_sc_]) ///
	(_b[sc_shock_]+_b[l12_sc_]+_b[l6_sc_]) ///
	(_b[sc_shock_]+_b[l12_sc_]+_b[l6_sc_]+_b[l18_sc_]) /// 
	(_b[sc_shock_]+_b[l12_sc_]+_b[l6_sc_]+_b[l18_sc_]+_b[l24_sc_]) ///
	(_b[sc_shock_]+_b[l12_sc_]+_b[l6_sc_]+_b[l18_sc_]+_b[l24_sc_]+_b[l30_sc_]) ///
	(_b[sc_shock_]+_b[l12_sc_]+_b[l6_sc_]+_b[l18_sc_]+_b[l24_sc_]+_b[l30_sc_]+_b[l36_sc_]) ///
	, post level(90)

estimates store beta_incr_

* plot beta coefficients
coefplot (beta_incr_, ciopts(recast(rcap)) recast(connected) level(90)), ///
  	vertical ///
  	keep (_nl_*) ///
  	coeflabel(_nl_1 = -24 _nl_2 = -18 _nl_3 = -12 _nl_4 = -6 _nl_5 = 0 _nl_6 = 6 _nl_7 = 12 _nl_8 = 18 _nl_9 = 24 _nl_10 = 30 _nl_11 = 36) ///
  	xline(4.5, lpattern(dash) lwidth(thin) lcolor(black)) xlabel(,labsize(medlarge)) ///
 	yline(0, lcolor(black) lwidth(thin)) ylabel(,labsize(medlarge)) ///
 	graphregion(color(white)) ///
  	xtitle (" " "Months relative to Secure communities shock", size(medlarge)) ytitle ("Treatment effect (90% c.i.)" " ", size(medlarge)) ///
	legend(off) ///
	note(" " "Observations: `obs', Municipalities: `N', Period: `month_start'/`year_start' - `month_end'/`year_end'.", size(small))
	
graph export "Output/Graphs/GES_SC`x'_`y'_mun_norm0.pdf", replace
}
}
*



*returns 
eststo clear
foreach x in 5 { 	
foreach y in returned returned_12to20 returned_21plus dom_returned dom_returned_12to20 dom_returned_21plus   {
*remit question only in ampliado questionair so will only be asked to hh once. 
eststo: reghdfe `y' f18_sc_`x' f12_sc_`x' f6_sc_`x' sc_shock_`x' l6_sc_`x' l12_sc_`x' l18_sc_`x' l24_sc_`x' l30_sc_`x' l36_sc_`x' c.migr_share#i.int_yq  [pw=mun_totalpop], a($fe) cluster(geo2_mx2000)

local obs=e(N)
local N=e(N_clust)
sum year if e(sample)
local year_start = r(min)
local year_end = r(max)
local month_start = 1
local month_end = 12

nlcom ///
	(-(_b[l12_sc_]+_b[l18_sc_]+_b[l6_sc_])) ///
	(-(_b[f12_sc_]+_b[f6_sc_])) ///
	(-_b[f6_sc_]) ///
	(0) ///
	(_b[sc_shock_]) ///
	(_b[sc_shock_]+_b[l6_sc_]) ///
	(_b[sc_shock_]+_b[l12_sc_]+_b[l6_sc_]) ///
	(_b[sc_shock_]+_b[l12_sc_]+_b[l6_sc_]+_b[l18_sc_]) /// 
	(_b[sc_shock_]+_b[l12_sc_]+_b[l6_sc_]+_b[l18_sc_]+_b[l24_sc_]) ///
	(_b[sc_shock_]+_b[l12_sc_]+_b[l6_sc_]+_b[l18_sc_]+_b[l24_sc_]+_b[l30_sc_]) ///
	(_b[sc_shock_]+_b[l12_sc_]+_b[l6_sc_]+_b[l18_sc_]+_b[l24_sc_]+_b[l30_sc_]+_b[l36_sc_]) ///
	, post level(90)

estimates store beta_incr_

* plot beta coefficients
coefplot (beta_incr_, ciopts(recast(rcap)) recast(connected) level(90)), ///
  	vertical ///
  	keep (_nl_*) ///
  	coeflabel(_nl_1 = -24 _nl_2 = -18 _nl_3 = -12 _nl_4 = -6 _nl_5 = 0 _nl_6 = 6 _nl_7 = 12 _nl_8 = 18 _nl_9 = 24 _nl_10 = 30 _nl_11 = 36) ///
  	xline(4.5, lpattern(dash) lwidth(thin) lcolor(black)) xlabel(,labsize(medlarge)) ///
 	yline(0, lcolor(black) lwidth(thin)) ylabel(,labsize(medlarge)) ///
 	graphregion(color(white)) ///
  	xtitle (" " "Months relative to Secure communities shock", size(medlarge)) ytitle ("Treatment effect (90% c.i.)" " ", size(medlarge)) ///
	legend(off) ///
	note(" " "Observations: `obs', Municipalities: `N', Period: `month_start'/`year_start' - `month_end'/`year_end'.", size(small))
	
graph export "Output/Graphs/GES_SC`x'_`y'_mun_norm0.pdf", replace
}
}
*




*wages adults post schooling

eststo clear
foreach x in 5 { 	
foreach y in  log_wage_loweduc_21to35 log_wage_higheduc_21to35 log_wage_loweduc_21plus log_wage_higheduc_21plus log_gap_21plus log_gap_21to35 log_wage_ent1_drp_und18 logobs_ent1_drp_und18{
*remit question only in ampliado questionair so will only be asked to hh once. 
eststo: reghdfe `y' f18_sc_`x' f12_sc_`x' f6_sc_`x' sc_shock_`x' l6_sc_`x' l12_sc_`x' l18_sc_`x' l24_sc_`x' l30_sc_`x' l36_sc_`x' c.migr_share#i.int_yq  [pw=mun_totalpop], a($fe) cluster(geo2_mx2000)

local obs=e(N)
local N=e(N_clust)
sum year if e(sample)
local year_start = r(min)
local year_end = r(max)
local month_start = 1
local month_end = 12

nlcom ///
	(-(_b[l12_sc_]+_b[l18_sc_]+_b[l6_sc_])) ///
	(-(_b[f12_sc_]+_b[f6_sc_])) ///
	(-_b[f6_sc_]) ///
	(0) ///
	(_b[sc_shock_]) ///
	(_b[sc_shock_]+_b[l6_sc_]) ///
	(_b[sc_shock_]+_b[l12_sc_]+_b[l6_sc_]) ///
	(_b[sc_shock_]+_b[l12_sc_]+_b[l6_sc_]+_b[l18_sc_]) /// 
	(_b[sc_shock_]+_b[l12_sc_]+_b[l6_sc_]+_b[l18_sc_]+_b[l24_sc_]) ///
	(_b[sc_shock_]+_b[l12_sc_]+_b[l6_sc_]+_b[l18_sc_]+_b[l24_sc_]+_b[l30_sc_]) ///
	(_b[sc_shock_]+_b[l12_sc_]+_b[l6_sc_]+_b[l18_sc_]+_b[l24_sc_]+_b[l30_sc_]+_b[l36_sc_]) ///
	, post level(90)

estimates store beta_incr_

* plot beta coefficients
coefplot (beta_incr_, ciopts(recast(rcap)) recast(connected) level(90)), ///
  	vertical ///
  	keep (_nl_*) ///
  	coeflabel(_nl_1 = -24 _nl_2 = -18 _nl_3 = -12 _nl_4 = -6 _nl_5 = 0 _nl_6 = 6 _nl_7 = 12 _nl_8 = 18 _nl_9 = 24 _nl_10 = 30 _nl_11 = 36) ///
  	xline(4.5, lpattern(dash) lwidth(thin) lcolor(black)) xlabel(,labsize(medlarge)) ///
 	yline(0, lcolor(black) lwidth(thin)) ylabel(,labsize(medlarge)) ///
 	graphregion(color(white)) ///
  	xtitle (" " "Months relative to Secure communities shock", size(medlarge)) ytitle ("Treatment effect (90% c.i.)" " ", size(medlarge)) ///
	legend(off) ///
	note(" " "Observations: `obs', Municipalities: `N', Period: `month_start'/`year_start' - `month_end'/`year_end'.", size(small))
	
graph export "Output/Graphs/GES_SC`x'_`y'_mun_norm0.pdf", replace
}
}
*

*wages school age: issue of selection
eststo clear
foreach x in 5 { 	
foreach y in  wage_hr_12to20 wage_hr_12to14 wage_hr_15to17 wage_hr_18to20 {
*remit question only in ampliado questionair so will only be asked to hh once. 
eststo: reghdfe `y' f18_sc_`x' f12_sc_`x' f6_sc_`x' sc_shock_`x' l6_sc_`x' l12_sc_`x' l18_sc_`x' l24_sc_`x' l30_sc_`x' l36_sc_`x' c.migr_share#i.int_yq  [pw=mun_totalpop], a($fe) cluster(geo2_mx2000)

local obs=e(N)
local N=e(N_clust)
sum year if e(sample)
local year_start = r(min)
local year_end = r(max)
local month_start = 1
local month_end = 12

nlcom ///
	(-(_b[l12_sc_]+_b[l18_sc_]+_b[l6_sc_])) ///
	(-(_b[f12_sc_]+_b[f6_sc_])) ///
	(-_b[f6_sc_]) ///
	(0) ///
	(_b[sc_shock_]) ///
	(_b[sc_shock_]+_b[l6_sc_]) ///
	(_b[sc_shock_]+_b[l12_sc_]+_b[l6_sc_]) ///
	(_b[sc_shock_]+_b[l12_sc_]+_b[l6_sc_]+_b[l18_sc_]) /// 
	(_b[sc_shock_]+_b[l12_sc_]+_b[l6_sc_]+_b[l18_sc_]+_b[l24_sc_]) ///
	(_b[sc_shock_]+_b[l12_sc_]+_b[l6_sc_]+_b[l18_sc_]+_b[l24_sc_]+_b[l30_sc_]) ///
	(_b[sc_shock_]+_b[l12_sc_]+_b[l6_sc_]+_b[l18_sc_]+_b[l24_sc_]+_b[l30_sc_]+_b[l36_sc_]) ///
	, post level(90)

estimates store beta_incr_

* plot beta coefficients
coefplot (beta_incr_, ciopts(recast(rcap)) recast(connected) level(90)), ///
  	vertical ///
  	keep (_nl_*) ///
  	coeflabel(_nl_1 = -24 _nl_2 = -18 _nl_3 = -12 _nl_4 = -6 _nl_5 = 0 _nl_6 = 6 _nl_7 = 12 _nl_8 = 18 _nl_9 = 24 _nl_10 = 30 _nl_11 = 36) ///
  	xline(4.5, lpattern(dash) lwidth(thin) lcolor(black)) xlabel(,labsize(medlarge)) ///
 	yline(0, lcolor(black) lwidth(thin)) ylabel(,labsize(medlarge)) ///
 	graphregion(color(white)) ///
  	xtitle (" " "Months relative to Secure communities shock", size(medlarge)) ytitle ("Treatment effect (90% c.i.)" " ", size(medlarge)) ///
	legend(off) ///
	note(" " "Observations: `obs', Municipalities: `N', Period: `month_start'/`year_start' - `month_end'/`year_end'.", size(small))
	
graph export "Output/Graphs/GES_SC`x'_`y'_mun_norm0.pdf", replace
}
}
*

******************************************************************************************
*Claire ENROLL ON ENROLLED LAST YEAR 
use Data_built\ENOE\ENOE_timeuse_shock_munbyquarter.dta, clear


*WEIGHTED
global fe i.int_yq i.year##i.geo1_mx2000 i.geo2_mx2000

eststo clear
foreach x in 5 { 	
foreach y in enroll enroll_12to20 enroll_12to20_m enroll_12to20_f enroll_12to14 enroll_15to17 enroll_18to20 enroll_12to20_m enroll_12to20_f{
*remit question only in ampliado questionair so will only be asked to hh once. 
eststo: reghdfe `y' f18_sc_`x' f12_sc_`x' f6_sc_`x' sc_shock_`x' l6_sc_`x' l12_sc_`x' l18_sc_`x' l24_sc_`x' l30_sc_`x' l36_sc_`x' c.migr_share#i.int_yq  [pw=mun_totalpop], a($fe) cluster(geo2_mx2000)

local obs=e(N)
local N=e(N_clust)
sum year if e(sample)
local year_start = r(min)
local year_end = r(max)
local month_start = 1
local month_end = 12

nlcom ///
	(-(_b[l12_sc_]+_b[l18_sc_]+_b[l6_sc_])) ///
	(-(_b[f12_sc_]+_b[f6_sc_])) ///
	(-_b[f6_sc_]) ///
	(0) ///
	(_b[sc_shock_]) ///
	(_b[sc_shock_]+_b[l6_sc_]) ///
	(_b[sc_shock_]+_b[l12_sc_]+_b[l6_sc_]) ///
	(_b[sc_shock_]+_b[l12_sc_]+_b[l6_sc_]+_b[l18_sc_]) /// 
	(_b[sc_shock_]+_b[l12_sc_]+_b[l6_sc_]+_b[l18_sc_]+_b[l24_sc_]) ///
	(_b[sc_shock_]+_b[l12_sc_]+_b[l6_sc_]+_b[l18_sc_]+_b[l24_sc_]+_b[l30_sc_]) ///
	(_b[sc_shock_]+_b[l12_sc_]+_b[l6_sc_]+_b[l18_sc_]+_b[l24_sc_]+_b[l30_sc_]+_b[l36_sc_]) ///
	, post level(90)

estimates store beta_incr_

* plot beta coefficients
coefplot (beta_incr_, ciopts(recast(rcap)) recast(connected) level(90)), ///
  	vertical ///
  	keep (_nl_*) ///
  	coeflabel(_nl_1 = -24 _nl_2 = -18 _nl_3 = -12 _nl_4 = -6 _nl_5 = 0 _nl_6 = 6 _nl_7 = 12 _nl_8 = 18 _nl_9 = 24 _nl_10 = 30 _nl_11 = 36) ///
  	xline(4.5, lpattern(dash) lwidth(thin) lcolor(black)) xlabel(,labsize(medlarge)) ///
 	yline(0, lcolor(black) lwidth(thin)) ylabel(,labsize(medlarge)) ///
 	graphregion(color(white)) ///
  	xtitle (" " "Months relative to Secure communities shock", size(medlarge)) ytitle ("Treatment effect (90% c.i.)" " ", size(medlarge)) ///
	legend(off) ///
	note(" " "Observations: `obs', Municipalities: `N', Period: `month_start'/`year_start' - `month_end'/`year_end'.", size(small))
	
graph export "Output/Graphs/GES_SC`x'_`y'_mun_norm0.pdf", replace
}
}
*






*labor force participation action is in the 15-17 group
eststo clear
foreach x in 5 { 	
foreach y in lfp_12to20 lfp_12to20_f lfp_12to20_m lfp_12to14 lfp_15to17 lfp_18to20 lfp_21to35     {
*remit question only in ampliado questionair so will only be asked to hh once. 
eststo: reghdfe `y' f18_sc_`x' f12_sc_`x' f6_sc_`x' sc_shock_`x' l6_sc_`x' l12_sc_`x' l18_sc_`x' l24_sc_`x' l30_sc_`x' l36_sc_`x' c.migr_share#i.int_yq  [pw=mun_totalpop], a($fe) cluster(geo2_mx2000)

local obs=e(N)
local N=e(N_clust)
sum year if e(sample)
local year_start = r(min)
local year_end = r(max)
local month_start = 1
local month_end = 12

nlcom ///
	(-(_b[l12_sc_]+_b[l18_sc_]+_b[l6_sc_])) ///
	(-(_b[f12_sc_]+_b[f6_sc_])) ///
	(-_b[f6_sc_]) ///
	(0) ///
	(_b[sc_shock_]) ///
	(_b[sc_shock_]+_b[l6_sc_]) ///
	(_b[sc_shock_]+_b[l12_sc_]+_b[l6_sc_]) ///
	(_b[sc_shock_]+_b[l12_sc_]+_b[l6_sc_]+_b[l18_sc_]) /// 
	(_b[sc_shock_]+_b[l12_sc_]+_b[l6_sc_]+_b[l18_sc_]+_b[l24_sc_]) ///
	(_b[sc_shock_]+_b[l12_sc_]+_b[l6_sc_]+_b[l18_sc_]+_b[l24_sc_]+_b[l30_sc_]) ///
	(_b[sc_shock_]+_b[l12_sc_]+_b[l6_sc_]+_b[l18_sc_]+_b[l24_sc_]+_b[l30_sc_]+_b[l36_sc_]) ///
	, post level(90)

estimates store beta_incr_

* plot beta coefficients
coefplot (beta_incr_, ciopts(recast(rcap)) recast(connected) level(90)), ///
  	vertical ///
  	keep (_nl_*) ///
  	coeflabel(_nl_1 = -24 _nl_2 = -18 _nl_3 = -12 _nl_4 = -6 _nl_5 = 0 _nl_6 = 6 _nl_7 = 12 _nl_8 = 18 _nl_9 = 24 _nl_10 = 30 _nl_11 = 36) ///
  	xline(4.5, lpattern(dash) lwidth(thin) lcolor(black)) xlabel(,labsize(medlarge)) ///
 	yline(0, lcolor(black) lwidth(thin)) ylabel(,labsize(medlarge)) ///
 	graphregion(color(white)) ///
  	xtitle (" " "Months relative to Secure communities shock", size(medlarge)) ytitle ("Treatment effect (90% c.i.)" " ", size(medlarge)) ///
	legend(off) ///
	note(" " "Observations: `obs', Municipalities: `N', Period: `month_start'/`year_start' - `month_end'/`year_end'.", size(small))
	
graph export "Output/Graphs/GES_SC`x'_`y'_mun_norm0.pdf", replace
}
}

*migrants by age
eststo clear
foreach x in 5 { 	
foreach y in migrant mun_migr_3m migrant_12to20 migrant_12to20_m migrant_12to20_f  migrant_12to14 migrant_15to17 migrant_18to20 migrant_21to35{
*remit question only in ampliado questionair so will only be asked to hh once. 
eststo: reghdfe `y' f18_sc_`x' f12_sc_`x' f6_sc_`x' sc_shock_`x' l6_sc_`x' l12_sc_`x' l18_sc_`x' l24_sc_`x' l30_sc_`x' l36_sc_`x' c.migr_share#i.int_yq  [pw=mun_totalpop], a($fe) cluster(geo2_mx2000)

local obs=e(N)
local N=e(N_clust)
sum year if e(sample)
local year_start = r(min)
local year_end = r(max)
local month_start = 1
local month_end = 12

nlcom ///
	(-(_b[l12_sc_]+_b[l18_sc_]+_b[l6_sc_])) ///
	(-(_b[f12_sc_]+_b[f6_sc_])) ///
	(-_b[f6_sc_]) ///
	(0) ///
	(_b[sc_shock_]) ///
	(_b[sc_shock_]+_b[l6_sc_]) ///
	(_b[sc_shock_]+_b[l12_sc_]+_b[l6_sc_]) ///
	(_b[sc_shock_]+_b[l12_sc_]+_b[l6_sc_]+_b[l18_sc_]) /// 
	(_b[sc_shock_]+_b[l12_sc_]+_b[l6_sc_]+_b[l18_sc_]+_b[l24_sc_]) ///
	(_b[sc_shock_]+_b[l12_sc_]+_b[l6_sc_]+_b[l18_sc_]+_b[l24_sc_]+_b[l30_sc_]) ///
	(_b[sc_shock_]+_b[l12_sc_]+_b[l6_sc_]+_b[l18_sc_]+_b[l24_sc_]+_b[l30_sc_]+_b[l36_sc_]) ///
	, post level(90)

estimates store beta_incr_

* plot beta coefficients
coefplot (beta_incr_, ciopts(recast(rcap)) recast(connected) level(90)), ///
  	vertical ///
  	keep (_nl_*) ///
  	coeflabel(_nl_1 = -24 _nl_2 = -18 _nl_3 = -12 _nl_4 = -6 _nl_5 = 0 _nl_6 = 6 _nl_7 = 12 _nl_8 = 18 _nl_9 = 24 _nl_10 = 30 _nl_11 = 36) ///
  	xline(4.5, lpattern(dash) lwidth(thin) lcolor(black)) xlabel(,labsize(medlarge)) ///
 	yline(0, lcolor(black) lwidth(thin)) ylabel(,labsize(medlarge)) ///
 	graphregion(color(white)) ///
  	xtitle (" " "Months relative to Secure communities shock", size(medlarge)) ytitle ("Treatment effect (90% c.i.)" " ", size(medlarge)) ///
	legend(off) ///
	note(" " "Observations: `obs', Municipalities: `N', Period: `month_start'/`year_start' - `month_end'/`year_end'.", size(small))
	
graph export "Output/Graphs/GES_SC`x'_`y'_mun_norm0.pdf", replace
}
}

* returns
eststo clear
foreach x in 5 { 	
foreach y in any_return_3m any_dom_return_3m {
*remit question only in ampliado questionair so will only be asked to hh once. 
eststo: reghdfe `y' f18_sc_`x' f12_sc_`x' f6_sc_`x' sc_shock_`x' l6_sc_`x' l12_sc_`x' l18_sc_`x' l24_sc_`x' l30_sc_`x' l36_sc_`x' c.migr_share#i.int_yq  [pw=mun_totalpop], a($fe) cluster(geo2_mx2000)

local obs=e(N)
local N=e(N_clust)
sum year if e(sample)
local year_start = r(min)
local year_end = r(max)
local month_start = 1
local month_end = 12

nlcom ///
	(-(_b[l12_sc_]+_b[l18_sc_]+_b[l6_sc_])) ///
	(-(_b[f12_sc_]+_b[f6_sc_])) ///
	(-_b[f6_sc_]) ///
	(0) ///
	(_b[sc_shock_]) ///
	(_b[sc_shock_]+_b[l6_sc_]) ///
	(_b[sc_shock_]+_b[l12_sc_]+_b[l6_sc_]) ///
	(_b[sc_shock_]+_b[l12_sc_]+_b[l6_sc_]+_b[l18_sc_]) /// 
	(_b[sc_shock_]+_b[l12_sc_]+_b[l6_sc_]+_b[l18_sc_]+_b[l24_sc_]) ///
	(_b[sc_shock_]+_b[l12_sc_]+_b[l6_sc_]+_b[l18_sc_]+_b[l24_sc_]+_b[l30_sc_]) ///
	(_b[sc_shock_]+_b[l12_sc_]+_b[l6_sc_]+_b[l18_sc_]+_b[l24_sc_]+_b[l30_sc_]+_b[l36_sc_]) ///
	, post level(90)

estimates store beta_incr_

* plot beta coefficients
coefplot (beta_incr_, ciopts(recast(rcap)) recast(connected) level(90)), ///
  	vertical ///
  	keep (_nl_*) ///
  	coeflabel(_nl_1 = -24 _nl_2 = -18 _nl_3 = -12 _nl_4 = -6 _nl_5 = 0 _nl_6 = 6 _nl_7 = 12 _nl_8 = 18 _nl_9 = 24 _nl_10 = 30 _nl_11 = 36) ///
  	xline(4.5, lpattern(dash) lwidth(thin) lcolor(black)) xlabel(,labsize(medlarge)) ///
 	yline(0, lcolor(black) lwidth(thin)) ylabel(,labsize(medlarge)) ///
 	graphregion(color(white)) ///
  	xtitle (" " "Months relative to Secure communities shock", size(medlarge)) ytitle ("Treatment effect (90% c.i.)" " ", size(medlarge)) ///
	legend(off) ///
	note(" " "Observations: `obs', Municipalities: `N', Period: `month_start'/`year_start' - `month_end'/`year_end'.", size(small))
	
graph export "Output/Graphs/GES_SC`x'_`y'_mun_norm0.pdf", replace
}
}
*




*UNWEIGHTED
global fe i.int_yq i.year##i.geo1_mx2000 i.geo2_mx2000
global controls c.migr_share#i.int_yq 



eststo clear
foreach x in 5 { 	
foreach y in migrant migrant_12to20 migrant_12to20_m migrant_12to20_f  migrant_12to14 migrant_15to17 migrant_18to20 migrant_21to35 migrant_21plus{
eststo: reghdfe `y' f18_scnw_`x' f12_scnw_`x' f6_scnw_`x' sc_noweight_`x' l6_scnw_`x' l12_scnw_`x' l18_scnw_`x' l24_scnw_`x' l30_scnw_`x' l36_scnw_`x'  $controls [aw=mun_totalpop], a($fe) cluster(geo2_mx2000)

local obs=e(N)
local N=e(N_clust)
sum year if e(sample)
local year_start = r(min)
local year_end = r(max)
local month_start = 1
local month_end = 12

nlcom ///
	(-(_b[f12_scnw_]+_b[f18_scnw_]+_b[f6_scnw_])) ///
	(-(_b[f12_scnw_]+_b[f6_scnw_])) ///
	(-_b[f6_scnw_]) ///
	(0) ///
	(_b[sc_noweight_]) ///
	(_b[sc_noweight_]+_b[l6_scnw_]) ///
	(_b[sc_noweight_]+_b[l12_scnw_]+_b[l6_scnw_]) ///
	(_b[sc_noweight_]+_b[l12_scnw_]+_b[l6_scnw_]+_b[l18_scnw_]) /// 
	(_b[sc_noweight_]+_b[l12_scnw_]+_b[l6_scnw_]+_b[l18_scnw_]+_b[l24_scnw_]) ///
	(_b[sc_noweight_]+_b[l12_scnw_]+_b[l6_scnw_]+_b[l18_scnw_]+_b[l24_scnw_]+_b[l30_scnw_]) ///
	(_b[sc_noweight_]+_b[l12_scnw_]+_b[l6_scnw_]+_b[l18_scnw_]+_b[l24_scnw_]+_b[l30_scnw_]+_b[l36_scnw_]) ///
	, post level(90)

estimates store beta_incr_

* plot beta coefficients
coefplot (beta_incr_, ciopts(recast(rcap)) recast(connected) level(90)), ///
  	vertical ///
  	keep (_nl_*) ///
  	coeflabel(_nl_1 = -36 _nl_2 = -24 _nl_3 = -12 _nl_4 = 0 _nl_5 = 12 _nl_6 = 24 _nl_7 = 36 _nl_8 = 48) ///
  	xline(4, lpattern(dash) lwidth(thin) lcolor(black)) xlabel(,labsize(medlarge)) ///
 	yline(0, lcolor(black) lwidth(thin)) ylabel(,labsize(medlarge)) ///
 	graphregion(color(white)) ///
  	xtitle (" " "Months relative to Secure communities shock", size(medlarge)) ytitle ("Treatment effect (90% c.i.)" " ", size(medlarge)) ///
	legend(off) ///
	note(" " "Observations: `obs', Municipalities: `N', Period: `month_start'/`year_start' - `month_end'/`year_end'.", size(small))
	
graph export "Output/Graphs/GES_SC`x'_nw_`y'_mun_norm0_noweights.pdf", replace
}
}
*



eststo clear
foreach x in 5 { 	
foreach y in   H_over_L_over18 mun_sumlfp_old_high mun_sumlfp_old_low any_dom_migrant_3m   any_dom_return_3m  mun_sumlfp_old mun_totalpop net_mig_3m got_remit_3m{
*remit question only in ampliado questionair so will only be asked to hh once. 
eststo: reghdfe `y' f18_sc_`x' f12_sc_`x' f6_sc_`x' sc_shock_`x' l6_sc_`x' l12_sc_`x' l18_sc_`x' l24_sc_`x' l30_sc_`x' l36_sc_`x' c.migr_share#i.int_yq  [pw=mun_totalpop], a($fe) cluster(geo2_mx2000)

local obs=e(N)
local N=e(N_clust)
sum year if e(sample)
local year_start = r(min)
local year_end = r(max)
local month_start = 1
local month_end = 12

nlcom ///
	(-(_b[l12_sc_]+_b[l18_sc_]+_b[l6_sc_])) ///
	(-(_b[f12_sc_]+_b[f6_sc_])) ///
	(-_b[f6_sc_]) ///
	(0) ///
	(_b[sc_shock_]) ///
	(_b[sc_shock_]+_b[l6_sc_]) ///
	(_b[sc_shock_]+_b[l12_sc_]+_b[l6_sc_]) ///
	(_b[sc_shock_]+_b[l12_sc_]+_b[l6_sc_]+_b[l18_sc_]) /// 
	(_b[sc_shock_]+_b[l12_sc_]+_b[l6_sc_]+_b[l18_sc_]+_b[l24_sc_]) ///
	(_b[sc_shock_]+_b[l12_sc_]+_b[l6_sc_]+_b[l18_sc_]+_b[l24_sc_]+_b[l30_sc_]) ///
	(_b[sc_shock_]+_b[l12_sc_]+_b[l6_sc_]+_b[l18_sc_]+_b[l24_sc_]+_b[l30_sc_]+_b[l36_sc_]) ///
	, post level(90)

estimates store beta_incr_

* plot beta coefficients
coefplot (beta_incr_, ciopts(recast(rcap)) recast(connected) level(90)), ///
  	vertical ///
  	keep (_nl_*) ///
  	coeflabel(_nl_1 = -24 _nl_2 = -18 _nl_3 = -12 _nl_4 = -6 _nl_5 = 0 _nl_6 = 6 _nl_7 = 12 _nl_8 = 18 _nl_9 = 24 _nl_10 = 30 _nl_11 = 36) ///
  	xline(4.5, lpattern(dash) lwidth(thin) lcolor(black)) xlabel(,labsize(medlarge)) ///
 	yline(0, lcolor(black) lwidth(thin)) ylabel(,labsize(medlarge)) ///
 	graphregion(color(white)) ///
  	xtitle (" " "Months relative to Secure communities shock", size(medlarge)) ytitle ("Treatment effect (90% c.i.)" " ", size(medlarge)) ///
	legend(off) ///
	note(" " "Observations: `obs', Municipalities: `N', Period: `month_start'/`year_start' - `month_end'/`year_end'.", size(small))
	
graph export "Output/Graphs/GES_SC`x'_`y'_mun_norm0.pdf", replace
}
}





*UNWEIGHTED
global fe i.int_yq i.year##i.geo1_mx2000 i.geo2_mx2000
global controls c.migr_share#i.int_yq 



eststo clear
foreach x in 5 { 	
foreach y in any_migrant_3m  any_return_3m net_mig_3m {
eststo: reghdfe `y' f18_scnw_`x' f12_scnw_`x' f6_scnw_`x' sc_noweight_`x' l6_scnw_`x' l12_scnw_`x' l18_scnw_`x' l24_scnw_`x' l30_scnw_`x' l36_scnw_`x'  $controls [aw=mun_totalpop], a($fe) cluster(geo2_mx2000)

local obs=e(N)
local N=e(N_clust)
sum year if e(sample)
local year_start = r(min)
local year_end = r(max)
local month_start = 1
local month_end = 12

nlcom ///
	(-(_b[f12_scnw_]+_b[f18_scnw_]+_b[f6_scnw_])) ///
	(-(_b[f12_scnw_]+_b[f6_scnw_])) ///
	(-_b[f6_scnw_]) ///
	(0) ///
	(_b[sc_noweight_]) ///
	(_b[sc_noweight_]+_b[l6_scnw_]) ///
	(_b[sc_noweight_]+_b[l12_scnw_]+_b[l6_scnw_]) ///
	(_b[sc_noweight_]+_b[l12_scnw_]+_b[l6_scnw_]+_b[l18_scnw_]) /// 
	(_b[sc_noweight_]+_b[l12_scnw_]+_b[l6_scnw_]+_b[l18_scnw_]+_b[l24_scnw_]) ///
	(_b[sc_noweight_]+_b[l12_scnw_]+_b[l6_scnw_]+_b[l18_scnw_]+_b[l24_scnw_]+_b[l30_scnw_]) ///
	(_b[sc_noweight_]+_b[l12_scnw_]+_b[l6_scnw_]+_b[l18_scnw_]+_b[l24_scnw_]+_b[l30_scnw_]+_b[l36_scnw_]) ///
	, post level(90)

estimates store beta_incr_

* plot beta coefficients
coefplot (beta_incr_, ciopts(recast(rcap)) recast(connected) level(90)), ///
  	vertical ///
  	keep (_nl_*) ///
  	coeflabel(_nl_1 = -36 _nl_2 = -24 _nl_3 = -12 _nl_4 = 0 _nl_5 = 12 _nl_6 = 24 _nl_7 = 36 _nl_8 = 48) ///
  	xline(4, lpattern(dash) lwidth(thin) lcolor(black)) xlabel(,labsize(medlarge)) ///
 	yline(0, lcolor(black) lwidth(thin)) ylabel(,labsize(medlarge)) ///
 	graphregion(color(white)) ///
  	xtitle (" " "Months relative to Secure communities shock", size(medlarge)) ytitle ("Treatment effect (90% c.i.)" " ", size(medlarge)) ///
	legend(off) ///
	note(" " "Observations: `obs', Municipalities: `N', Period: `month_start'/`year_start' - `month_end'/`year_end'.", size(small))
	
graph export "Output/Graphs/GES_SC`x'_nw_`y'_mun_norm0.pdf", replace
}
}



*no endogenous controls

global fe i.int_yq i.year##i.geo1_mx2000 i.geo2_mx2000
global controls female_12to14 female_15to17 female_18to20 c.migr_share#i.int_yq 

*WEIGHTED
eststo clear
foreach x in 5 { 	
foreach y in logenroll_12to20 logenroll_females logenroll_males logenroll_12to14 logenroll_15to17 logenroll_18to20 logstudents_12to20 logstudents_females logstudents_males logstudents_12to14 logstudents_15to17 logstudents_18to20 {
*remit question only in ampliado questionair so will only be asked to hh once. 
eststo: reghdfe `y' f18_sc_`x' f12_sc_`x' f6_sc_`x' sc_shock_`x' l6_sc_`x' l12_sc_`x' l18_sc_`x' l24_sc_`x' l30_sc_`x' l36_sc_`x' l42_sc_`x' $controls [pw=mun_totalpop], a($fe) cluster(geo2_mx2000)

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
coefplot (beta_incr, ciopts(recast(rcap)) recast(connected) level(90)), ///
  	vertical ///
  	keep (_nl_*) ///
  	coeflabel(_nl_1 = -24 _nl_2 = -18 _nl_3 = -12 _nl_4 = -6 _nl_5 = 0 _nl_6 = 6 _nl_7 = 12 _nl_8 = 18 _nl_9 = 24 _nl_10 = 30 _nl_11 = 36 _nl_12 = 42) ///
  	xline(5, lpattern(dash) lwidth(thin) lcolor(black)) xlabel(,labsize(medlarge)) ///
 	yline(0, lcolor(black) lwidth(thin)) ylabel(,labsize(medlarge)) ///
 	graphregion(color(white)) ///
  	xtitle (" " "Months relative to Secure communities shock", size(medlarge)) ytitle ("Treatment effect (90% c.i.)" " ", size(medlarge)) ///
	legend(off) ///
	note(" " "Observations: `obs', Municipalities: `N', Period: `month_start'/`year_start' - `month_end'/`year_end'.", size(small))
	
graph export "Output/Graphs/GES_SC`x'_`y'_mun_norm0_noendog_cont.pdf", replace
}
}















*WEIGHTED
eststo clear
foreach x in 5 { 	
foreach y in logenroll_12to20{
*remit question only in ampliado questionair so will only be asked to hh once. 
eststo: reghdfe `y' f18_sc_`x' f12_sc_`x' f6_sc_`x' sc_shock_`x' l6_sc_`x' l12_sc_`x' l18_sc_`x' l24_sc_`x' l30_sc_`x' l36_sc_`x' l42_sc_`x'  mun_wage_high mun_wage_low $controls [pw=mun_totalpop], a($fe) cluster(geo2_mx2000)

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
coefplot (beta_incr, ciopts(recast(rcap)) recast(connected) level(90)), ///
  	vertical ///
  	keep (_nl_*) ///
  	coeflabel(_nl_1 = -24 _nl_2 = -18 _nl_3 = -12 _nl_4 = -6 _nl_5 = 0 _nl_6 = 6 _nl_7 = 12 _nl_8 = 18 _nl_9 = 24 _nl_10 = 30 _nl_11 = 36 _nl_12 = 42) ///
  	xline(5, lpattern(dash) lwidth(thin) lcolor(black)) xlabel(,labsize(medlarge)) ///
 	yline(0, lcolor(black) lwidth(thin)) ylabel(,labsize(medlarge)) ///
 	graphregion(color(white)) ///
  	xtitle (" " "Months relative to Secure communities shock", size(medlarge)) ytitle ("Treatment effect (90% c.i.)" " ", size(medlarge)) ///
	legend(off) ///
	note(" " "Observations: `obs', Municipalities: `N', Period: `month_start'/`year_start' - `month_end'/`year_end'.", size(small))
	
graph export "Output/Graphs/GES_SC`x'_`y'_mun_norm0_noendog_cont.pdf", replace
}
}



*
clear
use  Data_built\ENOE\ENOE_timeuse_shock_munbyquarter_test.dta



global fe i.int_yq i.year##i.geo1_mx2000 i.geo2_mx2000
global controls  c.migr_share#i.int_yq 

gen share_abroad=abroad_pop/mex_n_mig_pop
gen share_abroad2=abroad_pop/mex_n_mig_pop



eststo clear
foreach x in 5 { 	
foreach y in abroad_pop  share_abroad home_pop absent_pop unexp_abs_ind mun_pop mun_totalpop{
*remit question only in ampliado questionair so will only be asked to hh once. 
eststo: reghdfe `y' f18_sc_`x' f12_sc_`x' f6_sc_`x' sc_shock_`x' l6_sc_`x' l12_sc_`x' l18_sc_`x' l24_sc_`x' l30_sc_`x' l36_sc_`x' l42_sc_`x' $controls [pw=mun_totalpop], a($fe) cluster(geo2_mx2000)

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
coefplot (beta_incr, ciopts(recast(rcap)) recast(connected) level(90)), ///
  	vertical ///
  	keep (_nl_*) ///
  	coeflabel(_nl_1 = -24 _nl_2 = -18 _nl_3 = -12 _nl_4 = -6 _nl_5 = 0 _nl_6 = 6 _nl_7 = 12 _nl_8 = 18 _nl_9 = 24 _nl_10 = 30 _nl_11 = 36 _nl_12 = 42) ///
  	xline(5, lpattern(dash) lwidth(thin) lcolor(black)) xlabel(,labsize(medlarge)) ///
 	yline(0, lcolor(black) lwidth(thin)) ylabel(,labsize(medlarge)) ///
 	graphregion(color(white)) ///
  	xtitle (" " "Months relative to Secure communities shock", size(medlarge)) ytitle ("Treatment effect (90% c.i.)" " ", size(medlarge)) ///
	legend(off) ///
	note(" " "Observations: `obs', Municipalities: `N', Period: `month_start'/`year_start' - `month_end'/`year_end'.", size(small))
	
graph export "Output/Graphs/GES_SC`x'_`y'_mun_norm0.pdf", replace
}
}



*UNWEIGHTED
global fe i.int_yq i.year##i.geo1_mx2000 i.geo2_mx2000
global controls c.migr_share#i.int_yq 



eststo clear
foreach x in 5 { 	
foreach y in abroad_pop share_abroad home_pop absent_pop{
eststo: reghdfe `y' f18_scnw_`x' f12_scnw_`x' f6_scnw_`x' sc_noweight_`x' l6_scnw_`x' l12_scnw_`x' l18_scnw_`x' l24_scnw_`x' l30_scnw_`x' l36_scnw_`x'  $controls [aw=mun_totalpop], a($fe) cluster(geo2_mx2000)

local obs=e(N)
local N=e(N_clust)
sum year if e(sample)
local year_start = r(min)
local year_end = r(max)
local month_start = 1
local month_end = 12

nlcom ///
	(-(_b[f12_scnw_]+_b[f18_scnw_]+_b[f6_scnw_])) ///
	(-(_b[f12_scnw_]+_b[f6_scnw_])) ///
	(-_b[f6_scnw_]) ///
	(0) ///
	(_b[sc_noweight_]) ///
	(_b[sc_noweight_]+_b[l6_scnw_]) ///
	(_b[sc_noweight_]+_b[l12_scnw_]+_b[l6_scnw_]) ///
	(_b[sc_noweight_]+_b[l12_scnw_]+_b[l6_scnw_]+_b[l18_scnw_]) /// 
	(_b[sc_noweight_]+_b[l12_scnw_]+_b[l6_scnw_]+_b[l18_scnw_]+_b[l24_scnw_]) ///
	(_b[sc_noweight_]+_b[l12_scnw_]+_b[l6_scnw_]+_b[l18_scnw_]+_b[l24_scnw_]+_b[l30_scnw_]) ///
	(_b[sc_noweight_]+_b[l12_scnw_]+_b[l6_scnw_]+_b[l18_scnw_]+_b[l24_scnw_]+_b[l30_scnw_]+_b[l36_scnw_]) ///
	, post level(90)

estimates store beta_incr_

* plot beta coefficients
coefplot (beta_incr_, ciopts(recast(rcap)) recast(connected) level(90)), ///
  	vertical ///
  	keep (_nl_*) ///
  	coeflabel(_nl_1 = -36 _nl_2 = -24 _nl_3 = -12 _nl_4 = 0 _nl_5 = 12 _nl_6 = 24 _nl_7 = 36 _nl_8 = 48) ///
  	xline(4, lpattern(dash) lwidth(thin) lcolor(black)) xlabel(,labsize(medlarge)) ///
 	yline(0, lcolor(black) lwidth(thin)) ylabel(,labsize(medlarge)) ///
 	graphregion(color(white)) ///
  	xtitle (" " "Months relative to Secure communities shock", size(medlarge)) ytitle ("Treatment effect (90% c.i.)" " ", size(medlarge)) ///
	legend(off) ///
	note(" " "Observations: `obs', Municipalities: `N', Period: `month_start'/`year_start' - `month_end'/`year_end'.", size(small))
	
graph export "Output/Graphs/GES_SC`x'_nw_`y'_mun_norm0.pdf", replace
}
}


