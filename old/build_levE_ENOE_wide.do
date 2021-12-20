

***********************************************************************************
****WIDE PANEL SETUP
***********************************************************************************
use $Data_built\time_use_all_merge.dta, clear

sort indiv_id
*figuring out quarter of all scheduled houshold interviews
destring first_int_yq, replace
drop if first_int_yq<51
drop if first_int_yq>134

gen first_int_yq_2=first_int_yq
gen str3  first_int_yq_3 = string(first_int_yq_2,"%03.0f")
tostring first_int_yq, replace
gen x=substr(first_int_yq_3,3,1) 
gen y=substr(first_int_yq_3,1,2) 

destring x y, replace
replace y=y+2000

gen xmo=.
replace xmo=2 if x==1
replace xmo=5 if x==2
replace xmo=8 if x==3
replace xmo=11 if x==4
tostring xmo y, replace
gen date1=xmo+"-1-"+y
gen edate = date(date1,"MDY")
gen qy_ent1 = qofd(edate)

forval i=2/5{
local a=`i'-1
gen qy_ent`i'=qy_ent`a'+1
}
*
forval i=1/5{
gen y_ent`i'=yofd(dofq(qy_ent`i'))    
gen q_ent`i'=quarter(dofq(qy_ent`i'))    
}
*

save $Data_built\wide_build.dta, replace
***********************************************************************************

***********************************************************************************
****HOUSEHOLD WIDE PANEL VARIABLES
***********************************************************************************
use $Data_built\wide_build.dta
sort hh_id
forval i=1/5{
gen hh_shouldbe_int`i'=1	
gen hh_home1vaway_ent_`i'a=.
replace hh_home1vaway_ent_`i'a=1 if n_ent==`i'
by hh_id: egen hh_home1vaway_ent_`i'=max(hh_home1vaway_ent_`i'a)
drop hh_home1vaway_ent_`i'a 
}
*

foreach y in fac hhsize hhv_kids hhv_teen_f hhv_teen_m hhv_youngadult_f hhv_youngadult_m hhv_adult_f hhv_adult_m hh_report_remit hh_earn_mo{
forval i=1/5{
gen `y'_ent_`i'a=.
replace `y'_ent_`i'a=`y' if n_ent==`i'
by hh_id: egen `y'_ent_`i'=max(`y'_ent_`i'a)
drop `y'_ent_`i'a 
}
}
*

keep hh_id qy_ent* y_ent* q_ent* geo1_mx2000 geo2_mx2000 hh_home1vaway_ent_*  hh_shouldbe_int*  fac_* hhsize_* hhv_kids_* hhv_teen_f_* hhv_teen_m_* hhv_youngadult_f_* hhv_youngadult_m_* hhv_adult_f_* hhv_adult_m_* hh_report_remit_* hh_earn_mo_*
duplicates drop
*one miscoded observation: drop
duplicates tag hh_id, gen(duple)
drop if duple==1
duplicates drop
drop duple

forval i=1/5{
replace hh_home1vaway_ent_`i'=0 if hh_home1vaway_ent_`i'==.	
}
*
gen yoy_hhdeparts=(-1)*(hh_home1vaway_ent_5-hh_home1vaway_ent_1) 
replace yoy_hhdeparts=. if hh_home1vaway_ent_1==0

gen yoy_hharrives=(hh_home1vaway_ent_5-hh_home1vaway_ent_1) 
replace yoy_hharrives=. if hh_home1vaway_ent_5==0

foreach y in hhsize hhv_kids hhv_teen_f hhv_teen_m hhv_youngadult_f hhv_youngadult_m hhv_adult_f hhv_adult_m hh_report_remit hh_earn_mo{
gen yoy_`y'= `y'_ent_5- `y'_ent_1	
}
*
keep hh_id  qy_ent1 y_ent1 q_ent1 geo1_mx2000 geo2_mx2000  fac_ent_1 fac_ent_5 yoy_*
isid hh_id
rename (qy_ent1 y_ent1 q_ent1)(qy_ent y_ent q_ent)

save $Data_built\hh_attrit_wide.dta, replace
***********************************************************************************


***********************************************************************************
****INDIVIDUAL WIDE PANEL VARIABLES
***********************************************************************************
use  $Data_built\wide_build.dta, 

sort indiv_id
foreach y in fac study lfp unempl ls_hrs wage_hr inc_mo chores study_hrs enroll yrs_offtrack  logwage_hr  migrant dom_migrant returnee dom_returnee {
forval i=1/5{
gen `y'_ent_`i'a=.
replace `y'_ent_`i'a=`y' if n_ent==`i'
by indiv_id: egen `y'_ent_`i'=max(`y'_ent_`i'a)
drop `y'_ent_`i'a 
}
}
*

forval i=1/5{
gen ind_shouldbe_int`i'=1	
gen ind_home1vaway_ent_`i'a=.
replace ind_home1vaway_ent_`i'a=1 if n_ent==`i'
by indiv_id: egen ind_home1vaway_ent_`i'=max(ind_home1vaway_ent_`i'a)
drop ind_home1vaway_ent_`i'a 
}
*
keep indiv_id hh_id qy_ent* y_ent* q_ent* geo1_mx2000 geo2_mx2000 ind_home1vaway_ent_*  ind_shouldbe_int*  fac_ent_* study_ent_* lfp_ent_* unempl_ent_* ls_hrs_ent_* wage_hr_ent_* inc_mo_ent_* chores_ent_* study_hrs_ent_* enroll_ent_* yrs_offtrack_ent_*  logwage_hr_ent_*  migrant_ent_* dom_migrant_ent_* returnee_ent_* dom_returnee_ent_*
duplicates drop

*one miscoded observation: drop
duplicates tag indiv_id, gen(duple)
drop if duple==1
duplicates drop

foreach y in migrant dom_migrant {
egen all`y'= rowtotal(`y'_ent_1 `y'_ent_2 `y'_ent_3 `y'_ent_4 )
gen yoy_`y'=0
replace yoy_`y'=1 if all`y'>0 & ind_home1vaway_ent_5==.
drop all`y'
}
*
foreach y in returnee dom_returnee{
egen all`y'= rowtotal(`y'_ent_2 `y'_ent_3 `y'_ent_4 `y'_ent_5 )
gen yoy_`y'=0 
replace yoy_`y'=1 if all`y'>0 & ind_home1vaway_ent_5==1
drop all`y'
}
*
gen yoy_appears=0
replace yoy_appears=1 if ind_home1vaway_ent_5==1 & ind_home1vaway_ent_1==.

gen yoy_disappears=0
replace yoy_disappears=1 if ind_home1vaway_ent_5==. & ind_home1vaway_ent_1==1



foreach y in  study lfp unempl ls_hrs wage_hr inc_mo chores study_hrs enroll yrs_offtrack  logwage_hr {
gen yoy_`y'= `y'_ent_5- `y'_ent_1	
}
*

keep indiv_id hh_id qy_ent1 y_ent1 q_ent1 geo1_mx2000 geo2_mx2000  fac_ent_1 fac_ent_5 yoy_*  ind_home1vaway_ent_5 ind_home1vaway_ent_1
isid indiv_id
rename (qy_ent1 y_ent1 q_ent1)(qy_ent y_ent q_ent)

save $Data_built\indiv_attrit_wide.dta, replace


