


mata : st_numscalar("OK", direxists("$output\yoy_ind"))
di scalar(OK)

if  scalar(OK)==0 {
	
mkdir $output\yoy_ind

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
*`6' conditioning statement
*`7' probability weights
cap prog drop makegraph_yoy_ind
prog def makegraph_yoy_ind, rclass


eststo clear
eststo: reghdfe `2'  yoy_f2sc_shock_5 yoy_f1sc_shock_5 yoy_sc_shock_5  yoy_l1sc_shock_5  yoy_l2sc_shock_5  $`4' [pw=`7'] if `6', a($`3') 
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
	note(" " " Weighted shocks and population weights. Observations: `obs', Municipalities: `N', Period: `month_start'/`year_start' - `month_end'/`year_end'.", size(small)) ///
	saving(1, replace)
`5' graph export "$output\yoy_ind\`2'_`1'_pw.pdf", replace


eststo clear
eststo: reghdfe  `2'  yoy_f2sc_noweight_5 yoy_f1sc_noweight_5 yoy_sc_noweight_5 yoy_l1sc_noweight_5 yoy_l2sc_noweight_5  $`4' [pw=`7'] if `6', a($`3') 
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
`5' graph export  "$output\yoy_ind\`2'_`1'_noscwgt_pw.pdf", replace




eststo clear
eststo: reghdfe `2'  yoy_f2sc_shock_5 yoy_f1sc_shock_5 yoy_sc_shock_5  yoy_l1sc_shock_5  yoy_l2sc_shock_5 $`4' if `6', a($`3') 
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
`5' graph export "$output\yoy_ind\`2'_`1'_a.pdf", replace

eststo clear
eststo: reghdfe `2'  yoy_f2sc_noweight_5 yoy_f1sc_noweight_5 yoy_sc_noweight_5 yoy_l1sc_noweight_5 yoy_l2sc_noweight_5  $`4' if `6', a($`3') 
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
`5' graph export  "$output\yoy_ind\`2'_`1'_noscwgt.pdf", replace



 graph combine  1.gph 2.gph 3.gph 4.gph, title("`2'")
 
 graph export "$output\yoy_ind\yoy_`2'.pdf", replace

end




********************************************************************************
********************************************************************************
********************************************************************************
********************************************************************************
*hh AND individual ANALYSIS
*****
*HH yoy regressions

*log using hh_indiv_yoy, replace
*set linesize 200

use $Data_built\ind_attrit_FD.dta, replace


egen fes=concat(y_ent geo1_mx2000)

global fes fes geo2_mx2000 q_ent
global controls c.migr_share#i.int_yq


local hh_departs yoy_hhdeparts1
***household attrition indicators
foreach y in `hh_departs'  {
makegraph_yoy_ind 5 `y' fes controls "*" "fac_ent_1!=. & hh_singleobs==1" fac_ent_1
}



local hh_arrives yoy_hharrives1
foreach y in `hh_arrives' {
makegraph_yoy_ind 5 `y' fes controls "*" "fac_ent_5!=.  & hh_singleobs==1" fac_ent_5
}

***household demographic indicators
local hh_demo yoy_hhsize yoy_hhv_kids yoy_hhv_teen_f yoy_hhv_teen_m yoy_hhv_youngadult_f yoy_hhv_youngadult_m yoy_hhv_adult_f yoy_hhv_adult_m

***household level variables
local hh_var yoy_hh_report_remit1 yoy_hh_earn_mo 

local hh_all `hh_demo' `hh_var'
foreach y in `hh_all' {
makegraph_yoy_ind 5 `y' fes controls "*" "fac_ent_1!=. & fac_ent_5!=.  & hh_singleobs==1" fac_ent_1
}




*** indiv attrition and migration for individuals observed in ent 1 or 5 
local ind_attr yoy_migrant1 yoy_dom_migrant1 yoy_disappears1 
foreach y in `ind_attr' {
makegraph_yoy_ind 5 `y' fes controls "*" "fac_ent_1!=.  " fac_ent_1
}


local ind_arr  yoy_returnee1 yoy_dom_returnee1 yoy_appears1

foreach y in `ind_arr' {
makegraph_yoy_ind 5 `y' fes controls "*" " fac_ent_5!=. " fac_ent_5
}


*** all indiv observed both ent1 and ent5
local all_indiv yoy_study1 yoy_lfp1 yoy_unempl1 yoy_ls_hrs yoy_wage_hr yoy_inc_mo yoy_chores yoy_study_hrs yoy_enroll1 yoy_logwage_hr 
foreach y in `all_indiv' {
makegraph_yoy_ind 5 `y' fes controls "*" "fac_ent_1!=. & fac_ent_5!=. " fac_ent_1
}

********************************************************************************
********************************************************************************
********************************************************************************
********************************************************************************










