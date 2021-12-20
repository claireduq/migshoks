

mata : st_numscalar("OK", direxists("$output\muni_yoy"))
di scalar(OK)

if  scalar(OK)==0 {
	
mkdir $output\muni_yoy

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


cap prog drop makegraph_yoy
prog def makegraph_yoy, rclass



local pw2 = "pw"+"`2'"
eststo clear
eststo: reghdfe `pw2'  yoy_f2sc_shock_5 yoy_f1sc_shock_5 yoy_sc_shock_5  yoy_l1sc_shock_5  yoy_l2sc_shock_5  $`4' [pw=muni_popweights], a($`3') 
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
`5' graph export "$output/muni_yoy/`2'_`1'_pw.pdf", replace


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
`5' graph export  "$output/muni_yoy/`2'_`1'_noscwgt_pw.pdf", replace




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
`5' graph export "$output/muni_yoy/`2'_`1'_a.pdf", replace

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
`5' graph export  "$output/muni_yoy/`2'_`1'_noscwgt.pdf", replace



 gr combine  1.gph 2.gph 3.gph 4.gph, title("`2'")
 
 gr export "$output/muni_yoy/`2'_`1'.pdf",replace

end

use $Data_built\ENOE_myoyagg.dta, clear

global fe i.int_yq i.year##i.geo1_mx2000 i.geo2_mx2000
global controls c.migr_share#i.int_yq

***household attrition indicators
global hh_attr myoy_hhdeparts1_mnhh1 myoy_hhdeparts2_sumhh1 myoy_hharrives1_mnhh5 myoy_hharrives2_sumhh5 

***household demographic indicators
local hh_demo myoy_hhsize_mnhh15 myoy_hhv_kids_mnhh15 myoy_hhv_teen_f_mnhh15 myoy_hhv_teen_m_mnhh15 myoy_hhv_youngadult_f_mnhh15 myoy_hhv_youngadult_m_mnhh15 myoy_hhv_adult_f_mnhh15 myoy_hhv_adult_m_mnhh15 

***household level variables
local hh_var myoy_hh_report_remit1_mnhh15 myoy_hh_earn_mo_mnhh15 myoy_hh_report_remit2_sumhh15 

*** indiv attrition and migration for individuals observed in ent 1 or 5 
local ind_attr_mig myoy_migrant1_mnin1 myoy_dom_migrant1_mnin1 myoy_disappears1_mnin1 myoy_migrant2_sumin1 myoy_dom_migrant2_sumin1 myoy_disappears2_sumin1 myoy_returnee1_mnin5 myoy_dom_returnee1_mnin5 myoy_appears1_mnin5 myoy_returnee2_sumin5 myoy_dom_returnee2_sumin5 myoy_appears2_sumin5

*** all indiv observed both ent1 and ent5
local all_indiv myoy_study1_mnin15 myoy_lfp1_mnin15 myoy_unempl1_mnin15 myoy_ls_hrs_mnin15 myoy_wage_hr_mnin15 myoy_inc_mo_mnin15 myoy_chores_mnin15 myoy_study_hrs_mnin15 myoy_enroll1_mnin15 myoy_logwage_hr_mnin15 myoy_study2_sumin15 myoy_lfp2_sumin15 myoy_unempl2_sumin15 myoy_enroll2_sumin15

*** 21 plus indiv observed both ent1 and ent5
local plus21  myoy_study1_mn21p myoy_lfp1_mn21p myoy_unempl1_mn21p myoy_ls_hrs_mn21p myoy_wage_hr_mn21p myoy_inc_mo_mn21p myoy_chores_mn21p myoy_study_hrs_mn21p myoy_enroll1_mn21p myoy_logwage_hr_mn21p myoy_study2_sum21p myoy_lfp2_sum21p myoy_unempl2_sum21p myoy_enroll2_sum21p

*** 12 to 14  indiv observed both ent1 and ent5
local is1214  myoy_study1_mn1214  myoy_ls_hrs_mn1214 myoy_wage_hr_mn1214 myoy_inc_mo_mn1214 myoy_chores_mn1214 myoy_study_hrs_mn1214 myoy_enroll1_mn1214 myoy_logwage_hr_mn1214 myoy_study2_sum1214 myoy_lfp2_sum1214 myoy_unempl2_sum1214 myoy_enroll2_sum1214

*** 15 to 17  indiv observed both ent1 and ent5
local is1517  myoy_study1_mn1517 myoy_lfp1_mn1517 myoy_unempl1_mn1517 myoy_ls_hrs_mn1517 myoy_wage_hr_mn1517 myoy_inc_mo_mn1517 myoy_chores_mn1517 myoy_study_hrs_mn1517 myoy_enroll1_mn1517 myoy_logwage_hr_mn1517 myoy_study2_sum1517 myoy_lfp2_sum1517 myoy_unempl2_sum1517 myoy_enroll2_sum1517 

*** 18 to 20  indiv observed both ent1 and ent5
local is1820 myoy_study1_mn1820 myoy_lfp1_mn1820 myoy_unempl1_mn1820 myoy_ls_hrs_mn1820 myoy_wage_hr_mn1820 myoy_inc_mo_mn1820 myoy_chores_mn1820 myoy_study_hrs_mn1820 myoy_enroll1_mn1820 myoy_logwage_hr_mn1820 myoy_study2_sum1820 myoy_lfp2_sum1820 myoy_unempl2_sum1820 myoy_enroll2_sum1820 

*** skilled 21 plus individuals
local sk21p myoy_study1_mnsk21p myoy_lfp1_mnsk21p myoy_unempl1_mnsk21p myoy_ls_hrs_mnsk21p myoy_wage_hr_mnsk21p myoy_inc_mo_mnsk21p myoy_chores_mnsk21p myoy_study_hrs_mnsk21p myoy_enroll1_mnsk21p myoy_logwage_hr_mnsk21p myoy_study2_sumsk21p myoy_lfp2_sumsk21p myoy_unempl2_sumsk21p myoy_enroll2_sumsk21p

***low skilled 21 plus individuals
local lsk21p myoy_study1_mnlsk21p myoy_lfp1_mnlsk21p myoy_unempl1_mnlsk21p myoy_ls_hrs_mnlsk21p myoy_wage_hr_mnlsk21p myoy_inc_mo_mnlsk21p myoy_chores_mnlsk21p myoy_study_hrs_mnlsk21p myoy_enroll1_mnlsk21p myoy_logwage_hr_mnlsk21p myoy_study2_sumlsk21p myoy_lfp2_sumlsk21p myoy_unempl2_sumlsk21p myoy_enroll2_sumlsk21p

local graphers `hh_attr' `hh_demo' `hh_var' `ind_attr_mig' `all_indiv' `plus21' `is1214' `is1517' `is1820' `sk21p' `lsk21p'
di $graphers

foreach y in `graphers' {
makegraph_yoy 5 `y' fe controls "*"
}

cap erase 1.gph 
cap erase 2.gph
cap erase 3.gph
cap erase 4.gph


















