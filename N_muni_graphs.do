

mata : st_numscalar("OK", direxists("$output\muni"))
di scalar(OK)

if  scalar(OK)==0 {
	
mkdir $output\muni

}


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
	(-(_b[sc_shock_`1']+_b[f6_sc_`1']+_b[f12_sc_`1']+_b[f18_sc_`1'])) ///
	(-(_b[sc_shock_`1']+_b[f6_sc_`1']+_b[f12_sc_`1'])) ///
	(-(_b[sc_shock_`1']+_b[f6_sc_`1'])) ///
	(-_b[sc_shock_`1']) ///
	(0) ///
	(_b[l6_sc_`1']) ///
	(_b[l6_sc_`1']+_b[l12_sc_`1']) ///
	(_b[l6_sc_`1']+_b[l12_sc_`1']+_b[l18_sc_`1']) ///
	(_b[l6_sc_`1']+_b[l12_sc_`1']+_b[l18_sc_`1']+_b[l24_sc_`1']) /// 
	(_b[l6_sc_`1']+_b[l12_sc_`1']+_b[l18_sc_`1']+_b[l24_sc_`1']+_b[l30_sc_`1']) ///
	(_b[l6_sc_`1']+_b[l12_sc_`1']+_b[l18_sc_`1']+_b[l24_sc_`1']+_b[l30_sc_`1']+_b[l36_sc_`1']) ///
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
`5' graph export "$output/muni/`2'_`1'_pw.pdf", replace

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
	(-(_b[sc_noweight_`1']+_b[f6_scnw_`1']+_b[f12_scnw_`1']+_b[f18_scnw_`1'])) ///
	(-(_b[sc_noweight_`1']+_b[f6_scnw_`1']+_b[f12_scnw_`1'])) ///
	(-(_b[sc_noweight_`1']+_b[f6_scnw_`1'])) ///
	(-_b[sc_noweight_`1']) ///
	(0) ///
	(_b[l6_scnw_`1']) ///
	(_b[l6_scnw_`1']+_b[l12_scnw_`1']) ///
	(_b[l6_scnw_`1']+_b[l12_scnw_`1']+_b[l18_scnw_`1']) ///
	(_b[l6_scnw_`1']+_b[l12_scnw_`1']+_b[l18_scnw_`1']+_b[l24_scnw_`1']) /// 
	(_b[l6_scnw_`1']+_b[l12_scnw_`1']+_b[l18_scnw_`1']+_b[l24_scnw_`1']+_b[l30_scnw_`1']) ///
	(_b[l6_scnw_`1']+_b[l12_scnw_`1']+_b[l18_scnw_`1']+_b[l24_scnw_`1']+_b[l30_scnw_`1']+_b[l36_scnw_`1']) ///
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
`5' graph export "$output/muni/`2'_`1'_noscwgt_pw.pdf", replace



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
(-(_b[sc_shock_`1']+_b[f6_sc_`1']+_b[f12_sc_`1']+_b[f18_sc_`1'])) ///
	(-(_b[sc_shock_`1']+_b[f6_sc_`1']+_b[f12_sc_`1'])) ///
	(-(_b[sc_shock_`1']+_b[f6_sc_`1'])) ///
	(-_b[sc_shock_`1']) ///
	(0) ///
	(_b[l6_sc_`1']) ///
	(_b[l6_sc_`1']+_b[l12_sc_`1']) ///
	(_b[l6_sc_`1']+_b[l12_sc_`1']+_b[l18_sc_`1']) ///
	(_b[l6_sc_`1']+_b[l12_sc_`1']+_b[l18_sc_`1']+_b[l24_sc_`1']) /// 
	(_b[l6_sc_`1']+_b[l12_sc_`1']+_b[l18_sc_`1']+_b[l24_sc_`1']+_b[l30_sc_`1']) ///
	(_b[l6_sc_`1']+_b[l12_sc_`1']+_b[l18_sc_`1']+_b[l24_sc_`1']+_b[l30_sc_`1']+_b[l36_sc_`1']) ///
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
`5' graph export "$output/muni/`2'_`1'_nopw.pdf", replace

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
	(-(_b[sc_noweight_`1']+_b[f6_scnw_`1']+_b[f12_scnw_`1']+_b[f18_scnw_`1'])) ///
	(-(_b[sc_noweight_`1']+_b[f6_scnw_`1']+_b[f12_scnw_`1'])) ///
	(-(_b[sc_noweight_`1']+_b[f6_scnw_`1'])) ///
	(-_b[sc_noweight_`1']) ///
	(0) ///
	(_b[l6_scnw_`1']) ///
	(_b[l6_scnw_`1']+_b[l12_scnw_`1']) ///
	(_b[l6_scnw_`1']+_b[l12_scnw_`1']+_b[l18_scnw_`1']) ///
	(_b[l6_scnw_`1']+_b[l12_scnw_`1']+_b[l18_scnw_`1']+_b[l24_scnw_`1']) /// 
	(_b[l6_scnw_`1']+_b[l12_scnw_`1']+_b[l18_scnw_`1']+_b[l24_scnw_`1']+_b[l30_scnw_`1']) ///
	(_b[l6_scnw_`1']+_b[l12_scnw_`1']+_b[l18_scnw_`1']+_b[l24_scnw_`1']+_b[l30_scnw_`1']+_b[l36_scnw_`1']) ///
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
`5' graph export "$output/muni/`2'_`1'_noscwgt_nopw.pdf", replace

****combingin all iterations

 gr combine  1.gph 2.gph 3.gph 4.gph, title("`2'")
 
 gr export "$output/muni/`2'_`1'.pdf",replace

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

use $Data_built\ENOE_muniagg_prog.dta, clear
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
foreach y in muni_inc_mo_mean15plus muni_logwage_hr_mean15plus muni_wage_loweduc_mean15plus muni_wage_higheduc_mean15plus muni_ls_dum1_low_mean15plus muni_ls_dum1_high_mean15plus muni_lfp_mean15plus muni_unempl_mean15plus muni_ls_hrs_mean15plus  muni_pop_sum15plus  muni_ls_dum2_low_sum15plus muni_ls_dum2_high_sum15plus muni_migrant2_sum15plus muni_dom_migrant2_sum15plus muni_returnee2_sum15plus muni_dom_returnee2_sum15plus muni_migrant1_mean15plus muni_dom_migrant1_mean15plus muni_returnee1_mean15plus muni_dom_returnee1_mean15plus muni_pop_sum15plus muni_pop_log15plus{
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

 
cap erase 1.gph 
cap erase 2.gph
cap erase 3.gph
cap erase 4.gph



