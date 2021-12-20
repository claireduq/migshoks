
********************************************************************************

***** muni level yoy regressions
log close _all

use $Data_built\ENOE_myoyagg.dta, replace






log using $output/muni_yoy_reg, replace
set linesize 200


***household attrition indicators
local hh_attr myoy_hhdeparts1_mnhh1 myoy_hhdeparts2_sumhh1 myoy_hharrives1_mnhh5 myoy_hharrives2_sumhh5 

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

egen fes=concat(year geo1_mx2000)
global fes fes geo2_mx2000 quarter

foreach y in `graphers'{
	
	di "`y'"
eststo clear
eststo: quietly reghdfe `y' yoy_sc_shock_5 c.migr_share#i.int_yq [aw=muni_popweights], a($fes) 
eststo: quietly reghdfe `y' yoy_sc_noweight_5 c.migr_share#i.int_yq [aw=muni_popweights], a($fes)
eststo: quietly reghdfe `y' yoy_f2sc_shock_5 yoy_f1sc_shock_5 yoy_sc_shock_5  yoy_l1sc_shock_5  yoy_l2sc_shock_5 c.migr_share#i.int_yq [aw=muni_popweights] , a($fes) 
eststo: quietly reghdfe `y' yoy_f2sc_noweight_5 yoy_f1sc_noweight_5 yoy_sc_noweight_5 yoy_l1sc_noweight_5 yoy_l2sc_noweight_5 c.migr_share#i.int_yq [aw=muni_popweights], a($fes) 
eststo: quietly reghdfe pw`y' yoy_sc_shock_5 c.migr_share#i.int_yq [aw=muni_popweights], a($fes) 
eststo: quietly reghdfe pw`y' yoy_sc_noweight_5 c.migr_share#i.int_yq [aw=muni_popweights], a($fes)
eststo: quietly reghdfe pw`y' yoy_f2sc_shock_5 yoy_f1sc_shock_5 yoy_sc_shock_5  yoy_l1sc_shock_5  yoy_l2sc_shock_5 c.migr_share#i.int_yq [aw=muni_popweights] , a($fes) 
eststo: quietly reghdfe pw`y' yoy_f2sc_noweight_5 yoy_f1sc_noweight_5 yoy_sc_noweight_5 yoy_l1sc_noweight_5 yoy_l2sc_noweight_5 c.migr_share#i.int_yq [aw=muni_popweights], a($fes) 
esttab, se keep( yoy_sc_shock_5 yoy_sc_noweight_5 yoy_f2sc_shock_5 yoy_f1sc_shock_5  yoy_l1sc_shock_5  yoy_l2sc_shock_5 yoy_f2sc_noweight_5 yoy_f1sc_noweight_5  yoy_l1sc_noweight_5 yoy_l2sc_noweight_5)
}
*
log close

********************************************************************************
