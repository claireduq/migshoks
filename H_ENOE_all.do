

* 1a, 2a, 3a, 4a 
foreach x in 1 2 3 4 {
foreach y in 05 06 07 08 09 10 11 12 13 14 {

use $Data_raw\ENOE\SDEMT`x'`y'.dta, clear
keep if r_def==00 // keep only those obs with completed survey

*GENERATE HOUSEHOLD IDENTIFIER:
*calculate 1 quarter hh is interviewed
gen first_int_yq="."
replace first_int_yq="`y'"+"`x'" if n_ent==1

gen a=`y'-1
gen b=`y'-1
tostring b, replace
replace b="0"+b if a<10


if `x'==1{
replace first_int_yq=b+"4" if n_ent==2
replace first_int_yq=b+"3" if n_ent==3
replace first_int_yq=b+"2" if n_ent==4
replace first_int_yq=b+"1" if n_ent==5
}
*
if `x'==2{
replace first_int_yq="`y'"+"1" if n_ent==2
replace first_int_yq=b+"4" if n_ent==3
replace first_int_yq=b+"3" if n_ent==4
replace first_int_yq=b+"2" if n_ent==5
}
*
if `x'==3{
replace first_int_yq="`y'"+"2" if n_ent==2
replace first_int_yq="`y'"+"1" if n_ent==3
replace first_int_yq=b+"4" if n_ent==4
replace first_int_yq=b+"3" if n_ent==5
}
*
if `x'==4{
replace first_int_yq="`y'"+"3" if n_ent==2
replace first_int_yq="`y'"+"2" if n_ent==3
replace first_int_yq="`y'"+"1" if n_ent==4
replace first_int_yq=b+"4" if n_ent==5
}
*
drop a b

 *note h_mod indicates the hh has moved and should not be included for panel tracking
gen hh_id=first_int_yq+"_"+ string(cd_a)+ "_" + string(ent)+"_"+string(con)+"_"+string(v_sel)+"_"+string(n_hog)
gen hh_id_visit=hh_id+"_visit"+string(n_ent)

gen indiv_id= hh_id+"_"+string(n_ren)
gen indiv_id_visit=indiv_id+"_visit"+string(n_ent)

*one observation per individual
isid indiv_id


gen migrated =1 if c_res==2 & cs_ad_des==3 
bysort hh_id_visit: egen migr_3m = count(migrated) 
gen any_migrant_3m=0
replace any_migrant_3m=1 if migr_3m>=1

gen dom_migrated =1 if c_res==2 & inlist(cs_ad_des,1,2) 
bysort hh_id_visit: egen dom_migr_3m = count(dom_migrated) 
gen any_dom_migrant_3m=0
replace any_dom_migrant_3m=1 if dom_migr_3m >=1

gen returned=1 if c_res==3 & cs_nr_ori==3
*replace returned=0 if returned==. & n_ent!=1
bysort hh_id_visit: egen return_3m = count(returned) 
gen any_return_3m=0
replace any_return_3m=1 if return_3m>=1

gen dom_returned=1 if c_res==3 & inlist(cs_nr_ori,1,2)
*replace dom_returned=0 if dom_returned==. & n_ent!=1
bysort hh_id_visit: egen dom_return_3m = count(dom_returned)
gen any_dom_return_3m=0
replace any_dom_return_3m=1 if dom_return_3m>=1

replace migr_3m =. if n_ent==1
replace return_3m = . if n_ent==1 // can construct only for hh that were interviewed at least once before

replace dom_migr_3m =. if n_ent==1
replace dom_return_3m = . if n_ent==1 

replace any_migrant_3m  =. if n_ent==1
replace any_dom_migrant_3m  =. if n_ent==1
replace any_return_3m  =. if n_ent==1
replace any_dom_return_3m =. if n_ent==1


*SCHOOLING VARIABLES
ren cs_p17 enroll 
recode enroll 9=. 2=0


*note should just use anios_esc

/*
*highest grade completed
*tab2 cs_p13_1 cs_p13_2
gen highest_grade=.
replace highest_grade=1 if cs_p13_1==2 & cs_p13_2==1
replace highest_grade=2 if cs_p13_1==2 & cs_p13_2==2
replace highest_grade=3 if cs_p13_1==2 & cs_p13_2==3
replace highest_grade=4 if cs_p13_1==2 & cs_p13_2==4
replace highest_grade=5 if cs_p13_1==2 & cs_p13_2==5
replace highest_grade=6 if cs_p13_1==2 & cs_p13_2==6
replace highest_grade=7 if cs_p13_1==3 & cs_p13_2==1
replace highest_grade=8 if cs_p13_1==3 & cs_p13_2==2
replace highest_grade=9 if cs_p13_1==3 & cs_p13_2==3
replace highest_grade=10 if inlist(cs_p13_1,4,5,6) & cs_p13_2==1
replace highest_grade=11 if inlist(cs_p13_1,4,5,6) & cs_p13_2==2
replace highest_grade=12 if inlist(cs_p13_1,4,5,6) & cs_p13_2==3
replace highest_grade=13 if inlist(cs_p13_1,7) & cs_p13_2==1
replace highest_grade=14 if inlist(cs_p13_1,7) & cs_p13_2==2
replace highest_grade=15 if inlist(cs_p13_1,7) & cs_p13_2==3
replace highest_grade=16 if inlist(cs_p13_1,7) & cs_p13_2==4
replace highest_grade=17 if inlist(cs_p13_1,7) & cs_p13_2==5
replace highest_grade=18 if inlist(cs_p13_1,7) & cs_p13_2==6
replace highest_grade=19 if inlist(cs_p13_1,7) & cs_p13_2==7
replace highest_grade=17 if cs_p13_1==8 & cs_p13_2==1
replace highest_grade=18 if cs_p13_1==8 & cs_p13_2==2
replace highest_grade=19 if cs_p13_1==8 & cs_p13_2==3
replace highest_grade=19 if cs_p13_1==9 & cs_p13_2==1
replace highest_grade=20 if cs_p13_1==9 & cs_p13_2==2
replace highest_grade=21 if cs_p13_1==9 & cs_p13_2==3
replace highest_grade=22 if cs_p13_1==9 & cs_p13_2==4
replace highest_grade=0 if cs_p13_1==0 & cs_p13_2==0

*leave rest as NA. includes preschoolers
*/


*get month of birth and year to calculate if on track.
gen late_yr_birth=0
replace late_yr_birth=1 if inlist(nac_mes, 9,10,11,12)
replace late_yr_birth=. if nac_mes==99


*FAMILY VARIABLES
** construct birth order variable
gen hijo=1 if par_c >=300 & par_c<400
sort hh_id nac_anio
bysort hh_id hijo: gen birthorder=_n
replace birthorder=. if hijo==.


* have to drop absent people for these calculations 
drop if c_res==2	
bysort hh_id_visit: gen hhsize=_N
bysort hh_id hijo: gen cohabsib=_N
replace cohabsib=. if hijo==.
recode anios_esc 99=.

gen kids =1 if eda<12 
gen teen_f =1 if eda>=12 & eda<=16 & sex==2
gen teen_m =1 if eda>=12 & eda<=16 & sex==1
gen ya_f =1 if eda>=17 & eda<=21 & sex==2
gen ya_m =1 if eda>=17 & eda<=21 & sex==1
gen adult_f =1 if eda>21  & sex==2
gen adult_m =1 if eda>21  & sex==1

bysort hh_id_visit: egen hhv_kids= count(kids)
bysort hh_id_visit: egen hhv_teen_f = count(teen_f)
bysort hh_id_visit: egen hhv_teen_m = count(teen_m)
bysort hh_id_visit: egen hhv_youngadult_f = count(ya_f)
bysort hh_id_visit: egen hhv_youngadult_m = count(ya_m)
bysort hh_id_visit: egen hhv_adult_m = count(adult_m)
bysort hh_id_visit: egen hhv_adult_f = count(adult_f)


keep loc mun est est_d ageb t_loc cd_a ent con upm d_sem n_pro_viv v_sel n_hog ///
	h_mud n_ent hh_id hh_id_visit indiv_id indiv_id_visit per n_ren return_3m migr_3m  sex eda enroll anios_esc hrsocup ingocup ///
	 kids teen_f  teen_m ya_f  ya_m  adult_f  adult_m  hhv_kids hhv_teen_f  hhv_teen_m  hhv_youngadult_f  hhv_youngadult_m hhv_adult_m  hhv_adult_f ///
	ing_x_hrs c_res hhsize cohabsib birthorder par_c n_ent  first_int_yq migrated returned late_yr_birth anios_esc dom_migrated dom_returned dom_return_3m dom_migr_3m any_migrant_3m any_dom_migrant_3m any_return_3m  any_dom_return_3m cs_ad_des cs_nr_ori

*keep if eda>=12 & eda <25

merge m:1 cd_a ent con v_sel n_hog h_mud using $Data_raw\ENOE\HOGT`x'`y'.dta
drop if _merge==2

keep loc mun est est_d ageb t_loc cd_a ent con upm d_sem n_pro_viv v_sel n_hog ///
	h_mud hh_id hh_id_visit indiv_id indiv_id_visit n_ent per n_ren return_3m migr_3m  sex eda enroll anios_esc hrsocup ingocup ///
		 kids teen_f  teen_m ya_f  ya_m  adult_f  adult_m  hhv_kids hhv_teen_f  hhv_teen_m  hhv_youngadult_f  hhv_youngadult_m hhv_adult_m  hhv_adult_f ///
	ing_x_hrs c_res hhsize cohabsib birthorder par_c d_dia d_mes d_anio n_ent  first_int_yq migrated returned late_yr_birth anios_esc dom_migrated dom_returned dom_return_3m dom_migr_3m any_migrant_3m any_dom_migrant_3m any_return_3m cs_ad_des cs_nr_ori any_dom_return_3m

	
gen returnee=1 if c_res==3 & cs_nr_ori==3
replace returnee=0 if returnee==. & n_ent!=1

gen dom_returnee=1 if c_res==3 & inlist(cs_nr_ori,1,2)
replace dom_returnee=0 if dom_returnee==. & n_ent!=1

*getting indicator for will migrant after having droped observation of absent migrant. 
rename per per1
rename c_res c_res1
*rename r_def r_def1
rename n_ent n_ent1
rename cs_ad_des cs_ad_des1

gen match =. 
*indicate that the person would migrate abroad in the next three months
gen migrant = . 

gen dom_migrant = . 

*Claire: removed h_mud to be able to match hh that moved
*link member by id in next file using  
if "`x'" == "4" {
	if "`y'" >= "05" & "`y'"<"09" {
	local z = `y'+1
	merge 1:1 cd_a ent con v_sel n_hog  n_ren using $Data_raw\ENOE\SDEMT10`z'.dta  
	}
	if "`y'" >= "09" {
	local z = `y'+1
	merge 1:1 cd_a ent con v_sel n_hog  n_ren using $Data_raw\ENOE\SDEMT1`z'.dta  
	}
}
if "`x'" == "1" | "`x'" == "2" | "`x'" == "3" {
local w = `x'+1
merge 1:1 cd_a ent con v_sel n_hog  n_ren  using $Data_raw\ENOE\SDEMT`w'`y'.dta  
}
cap drop if _merge==2
replace match=1 if _merge==3
replace match=0 if r_def!=00
replace migrant=1 if match==1 & c_res==2 & cs_ad_des==3
replace dom_migrant=1 if match==1 & c_res==2 & inlist(cs_ad_des,1,2)

recode match .=0
recode migrant .=0 if match==1
recode dom_migrant .=0 if match==1

replace match=. if n_ent1==5
replace migrant=. if n_ent1==5
replace dom_migrant=. if n_ent1==5

// replace match=. if n_ent==1
// replace migrant=. if n_ent==1
// replace dom_migrant=. if n_ent==1

drop per c_res r_def n_ent cs_ad_des 

rename per1 per
rename c_res1 c_res
*rename r_def1 r_def
rename n_ent1 n_ent
rename cs_ad_des1 cs_ad_des

keep loc mun est est_d ageb t_loc cd_a ent con upm d_sem n_pro_viv v_sel n_hog ///
	h_mud n_ent hh_id hh_id_visit indiv_id indiv_id_visit  per n_ren return_3m migr_3m sex eda enroll anios_esc hrsocup ingocup ///
    kids teen_f  teen_m ya_f  ya_m  adult_f  adult_m  hhv_kids hhv_teen_f  hhv_teen_m hhv_youngadult_f  hhv_youngadult_m hhv_adult_m  hhv_adult_f ///
	ing_x_hrs hhsize cohabsib birthorder par_c d_dia d_mes d_anio c_res ///
	 n_ent  first_int_yq migrated returned late_yr_birth anios_esc dom_migrated dom_returned dom_return_3m dom_migr_3m  any_migrant_3m any_dom_migrant_3m any_return_3m  any_dom_return_3m cs_ad_des cs_nr_ori migrant match dom_migrant returnee dom_returnee

save $Data_built\socioT`x'`y'_all.dta, replace
}
}	

***********************************************************************************
* Cuestionario de ocupacion y empleo
* lfp, employment, wages, time use, migration plans, remittances

// can construct week of survey with per and d_sem variables... 
// but can also use d_dia d_mes d_anio from HogT file (date of interview)

* ampliado, cuarta y quinta version
clear
gen per=.
save $Data_built\time_use_4a_all.dta, replace

* 2013, 2014, 2015, 16, 17, 18
foreach y in 13 14 {
use $Data_raw\ENOE\COE1T1`y'.dta, clear 
merge 1:1 n_ren n_ent n_hog n_pro_viv upm per ent d_sem cd_a using $Data_raw\ENOE\COE2T1`y'.dta
keep if r_def==00

*LABOR FORCE PARTICIPATION/HRS (ocupados)
egen ls_dum = anymatch(p1 p1a1 p1d), v(1)
replace ls_dum = 1 if p1a2==2 & p1a1==.
replace ls_dum = 1 if (p1d==2 & p1e==1) | (p1d==9 & p1e==1) 
replace ls_dum = 1 if p1c==01 |  p1c==02 |  p1c==03 |  p1c==04

* Unemployed / desocupados
gen unempl =1 if p1c==11 // people who started a new job this week)
replace unempl =1 if p1b==2 & (p2_1==1 | p2_2==2 | p2_3==3) & p2b==1 & p2c!=2 & p2c!=9
replace unempl =1 if (p1d==2 | p1d==9) & (p2_1==1 | p2_2==2 | p2_3==3) & p2b==1 & p2c!=2 & p2c!=9
egen lfp=rowmax(unempl ls_dum)
recode unempl .=0 if lfp==1

*Hours worked, wages (as calculated for ENOE statistics)
recode p5c_thrs 999=.
gen ls_hrs = p5c_thrs
replace ls_hrs=. if lfp==0 // ENOE also calculates hours onle for people who are working
recode p6b2 999998=.
gen inc_mo = p6b2 if lfp==1
gen wage_hr=inc_mo/(ls_hrs*4.3)
gen logwage_hr = log(wage_hr)

replace inc_mo  =. if lfp==0
replace wage_hr =. if lfp==0
replace logwage_hr =. if lfp==0

/*
foreach var in p5c_mlu p5c_mma p5c_mmi p5c_mju p5c_mvi p5c_msa p5c_mdo {
replace `var'=`var'/60
}
foreach var in p5c_hlu p5c_hma p5c_hmi p5c_hju p5c_hvi p5c_hsa p5c_hdo {
recode `var' 99=. 98=.
}
egen ls_hrs = rowtotal(p5c_hlu p5c_hma p5c_hmi p5c_hju p5c_hvi p5c_hsa p5c_hdo p5c_mlu p5c_mma p5c_mmi p5c_mju p5c_mvi p5c_msa p5c_mdo), m 
gen inc_week = p6b2 if p6b1==3
replace inc_week = p6b2*7 if p6b1==4
replace inc_week = p6b2/2 if p6b1==2
replace inc_week = p6b2/4 if p6b1==1
gen wage_hr = inc_week/ls_hrs
gen logwage_hr = log(wage_hr)
*/

/*EARNINGS: 
*gen weekly days worked on main job
gen days_wrk=.
replace days_wrk=p5c_tdia if p5d==1
replace days_wrk=. if p5c_tdia==9
replace days_wrk=p5e_tdia if days_wrk==. & p5e_tdia!=9

*gen weekly hrs worked main job
gen weekhrs_wrk=.
replace weekhrs_wrk=p5c_thrs if p5d==1 & p5c_thrs!=999
replace weekhrs_wrk=. if p5d==2
replace weekhrs_wrk=p5e_thrs if weekhrs_wrk==. & p5e_thrs!=999
replace weekhrs_wrk=p5c_thrs if p5e1==2 & p5c_thrs!=999 // EG: replace only those that worked more than usual to get more money? Whats the rationale? 

*monthly earnings from main job(no scondary job earnings in any of the other questionairs so not counting)
gen earn_mo=.
replace earn_mo=p6b2 if p6b1==1
replace earn_mo=p6b2*2.1725 if p6b1==2
replace earn_mo=p6b2*4.345 if p6b1==3
replace earn_mo=p6b2*4.345*days_wrk if p6b1==4

*wage estimate from main job: 
gen estim_wage=earn_mo/(4.345*weekhrs_wrk)
gen log_estim_wage_hr = log(estim_wage)
*/

*household monthly earnings. 
sort cd_a ent con v_sel n_hog h_mud
by cd_a ent con v_sel n_hog h_mud: egen hh_earn_mo=total(inc_mo)

*OTHER TIME USE
egen chores=anymatch(p11_2 p11_3 p11_4 p11_5 p11_6 p11_7 p11_8), v(2 3 4 5 6 7 8)
foreach var in p11_m1 p11_m2 p11_m3 p11_m4 p11_m5 p11_m6 p11_m7 p11_m8 {
replace `var'=`var'/60
}
foreach var in p11_h1 p11_h2 p11_h3 p11_h4 p11_h5 p11_h6 p11_h7 p11_h8 {
recode `var' 99=. 98=.
}
egen chores_hrs = rowtotal(p11_h2 p11_h3 p11_h4 p11_h5 p11_h6 p11_h7 p11_h8 p11_m2 p11_m3 p11_m4 p11_m5 p11_m6 p11_m7 p11_m8), m 
egen study_hrs = rowtotal(p11_h1 p11_m1), m
ren p11_1 study 
recode study .=0

*BORDER CROSSING PLANS
gen unemp_border_cross=.
replace unemp_border_cross=0 if p2_2==2
replace unemp_border_cross=0 if p2_3==3
replace unemp_border_cross=1 if p2_1==1

gen newjob_border_cross=.
replace newjob_border_cross=1 if p8_1==1
replace newjob_border_cross=0 if p8_2==2
replace newjob_border_cross=0 if p8_3==3

*REMITTANCES QUESTION
gen got_remit_3m=0
replace got_remit_3m=1 if p10a1==1

*return DEPORTATION QUESTION
gen rep_ret_dep=0
replace rep_ret_dep=1 if p9a==6

*time of return deportation
gen dep_yr=.
replace dep_yr=p9f_anio if rep_ret_dep==1
replace dep_yr=. if dep_yr==9999
gen dep_mo=.
replace dep_mo=p9f_mes if rep_ret_dep==1
replace dep_mo=. if dep_mo==99

keep con v_sel h_mud n_ren n_ent n_hog n_pro_viv upm per ent d_sem cd_a eda lfp ///
	 unemp_border_cross newjob_border_cross got_remit_3m ///
	 ls_hrs ls_dum inc_mo wage_hr logwage_hr unempl  hh_earn_mo  ///
	rep_ret_dep dep_yr dep_mo  chores* study* ur fac 

gen svy_type="extended_new"
gen quarter =1
gen year = 20`y'
merge 1:1 cd_a ent con v_sel n_hog h_mud n_ren using $Data_built\socioT1`y'_all.dta
drop if _merge==2
drop _merge

gen wage_loweduc = wage_hr if anios_esc<=9
gen wage_higheduc = wage_hr if anios_esc>9
gen ls_dum1_low = ls_dum if anios_esc<=9
gen ls_dum1_high = ls_dum if anios_esc>9

append using $Data_built\time_use_4a_all.dta
drop if per==.
save $Data_built\time_use_4a_all.dta, replace
}
/* To recover ENOE aggregates (population
gen pop=1
keep if eda>=15
collapse (sum) pop [pw=fac], by( quarter year)
use Data_built\ENOE\time_use_4a_all.dta, clear
gen pop=1
keep if eda>=15
collapse (mean) wage_hr ls_hrs lfp unempl [pw=fac], by( quarter year)
*/

******************************************************************************
clear
gen per=.
save $Data_built\time_use_5a_all.dta, replace

* basico, cuarta y quinta version

foreach x in 2 3 4 {
foreach y in 13 14  {
use $Data_raw\ENOE\COE1T`x'`y'.dta, clear 
merge 1:1 n_ren n_ent n_hog n_pro_viv upm per ent d_sem cd_a using $Data_raw\ENOE\COE2T`x'`y'.dta
keep if r_def==00

*LABOR FORCE PARTICIPATION/HRS (ocupados)
egen ls_dum = anymatch(p1 p1a1 p1d), v(1)
replace ls_dum = 1 if p1a2==2 & p1a1==.
replace ls_dum = 1 if (p1d==2 & p1e==1) | (p1d==9 & p1e==1) 
replace ls_dum =1 if p1c==01 |  p1c==02 |  p1c==03 |  p1c==04

* Unemployed / desocupados
gen unempl =1 if p1c==11 // people who started a new job this week)
replace unempl =1 if p1b==2 & (p2_1==1 | p2_2==2 | p2_3==3) & p2b==1 & p2c!=2 & p2c!=9
replace unempl =1 if (p1d==2 | p1d==9) & (p2_1==1 | p2_2==2 | p2_3==3) & p2b==1 & p2c!=2 & p2c!=9
egen lfp=rowmax(unempl ls_dum)
recode unempl .=0 if lfp==1

*Hours worked, wages (as calculated for ENOE statistics)
recode p5b_thrs 999=.
gen ls_hrs = p5b_thrs
replace ls_hrs=. if lfp==0 // ENOE also calculates hours onle for people who are working
recode p6b2 999998=.
gen inc_mo = p6b2 if lfp==1
gen wage_hr=inc_mo/(ls_hrs*4.3)
gen logwage_hr = log(wage_hr)

replace inc_mo  =. if lfp==0
replace wage_hr =. if lfp==0
replace logwage_hr =. if lfp==0

/*
foreach var in p5b_mlu p5b_mma p5b_mmi p5b_mju p5b_mvi p5b_msa p5b_mdo {
replace `var'=`var'/60
}
foreach var in p5b_hlu p5b_hma p5b_hmi p5b_hju p5b_hvi p5b_hsa p5b_hdo {
recode `var' 99=. 98=.
}

egen ls_hrs = rowtotal(p5b_mlu p5b_mma p5b_mmi p5b_mju p5b_mvi p5b_msa p5b_mdo p5b_hlu p5b_hma p5b_hmi p5b_hju p5b_hvi p5b_hsa p5b_hdo), m 
gen inc_week = p6b2 if p6b1==3
replace inc_week = p6b2*7 if p6b1==4
replace inc_week = p6b2/2 if p6b1==2
replace inc_week = p6b2/4 if p6b1==1
gen wage_hr = inc_week/ls_hrs
gen logwage_hr = log(wage_hr)

*EARNINGS: 
*gen weekly days worked on main job
gen days_wrk=.
replace days_wrk=p5b_tdia if p5c==1
replace days_wrk=. if p5b_tdia==9
replace days_wrk=p5d_tdia if days_wrk==. & p5d_tdia!=9

*gen weekly hrs worked main job
gen weekhrs_wrk=.
replace weekhrs_wrk=p5b_thrs if p5c==1 & p5b_thrs!=999
replace weekhrs_wrk=. if p5c==2
replace weekhrs_wrk=p5d_thrs if weekhrs_wrk==. & p5d_thrs!=999
replace weekhrs_wrk=p5b_thrs if p5d1==2 & p5b_thrs!=999

*monthly earnings from main job
gen earn_mo=.
replace earn_mo=p6b2 if p6b1==1
replace earn_mo=p6b2*2.1725 if p6b1==2
replace earn_mo=p6b2*4.345 if p6b1==3
replace earn_mo=p6b2*4.345*days_wrk if p6b1==4

*wage estimate from main job: 
gen estim_wage=earn_mo/(4.345*weekhrs_wrk)
gen log_estim_wage_hr = log(estim_wage)
*/

*household monthly earnings. 
sort cd_a ent con v_sel n_hog h_mud
by cd_a ent con v_sel n_hog h_mud: egen hh_earn_mo=total(inc_mo)

*OTHER TIME USE
egen chores=anymatch(p9_2 p9_3 p9_4 p9_5 p9_6 p9_7 p9_8), v(2 3 4 5 6 7 8)
foreach var in p9_m1 p9_m2 p9_m3 p9_m4 p9_m5 p9_m6 p9_m7 p9_m8 {
replace `var'=`var'/60
}
foreach var in p9_h1 p9_h2 p9_h3 p9_h4 p9_h5 p9_h6 p9_h7 p9_h8 {
recode `var' 99=. 98=.
}
egen chores_hrs = rowtotal(p9_m2 p9_m3 p9_m4 p9_m5 p9_m6 p9_m7 p9_m8 p9_h2 p9_h3 p9_h4 p9_h5 p9_h6 p9_h7 p9_h8), m 
egen study_hrs = rowtotal(p9_h1 p9_m1), m
ren p9_1 study 
recode study .=0

*BORDER CROSSING PLANS
gen unemp_border_cross=.
replace unemp_border_cross=0 if p2_2==2
replace unemp_border_cross=0 if p2_3==3
replace unemp_border_cross=1 if p2_1==1

gen newjob_border_cross=.
replace newjob_border_cross=1 if p8_1==1
replace newjob_border_cross=0 if p8_2==2
replace newjob_border_cross=0 if p8_3==3

*return DEPORTATION QUESTION
gen rep_ret_dep=0
replace rep_ret_dep=1 if p2i==6
*time of return-deportation
gen dep_yr=.
replace dep_yr=p2k_anio if rep_ret_dep==1
replace dep_yr=. if dep_yr==9999
gen dep_mo=.
replace dep_mo=p2k_mes if rep_ret_dep==1
replace dep_mo=. if dep_mo==99

*no remittances question in basic version

keep con v_sel h_mud n_ren n_ent n_hog n_pro_viv upm per d_sem ent cd_a eda lfp ///
	unemp_border_cross newjob_border_cross  ///
	ls_hrs ls_dum inc_mo wage_hr logwage_hr unempl  hh_earn_mo  ///
	rep_ret_dep dep_yr dep_mo  chores* study* ur fac

gen svy_type="basic_new"
gen quarter =`x'
gen year = 20`y'

merge 1:1 cd_a ent con v_sel n_hog h_mud n_ren using $Data_built\socioT`x'`y'_all.dta
drop if _merge==2
drop _merge

gen wage_loweduc = wage_hr if anios_esc<=9
gen wage_higheduc = wage_hr if anios_esc>9
gen ls_dum1_low = ls_dum if anios_esc<=9
gen ls_dum1_high = ls_dum if anios_esc>9

append using $Data_built\time_use_5a_all.dta
save $Data_built\time_use_5a_all.dta, replace
}
}
*

* ampliado, 1a, 2a, 3a version
// time use only collects 6 instead of 8 categories, will have to control for this in the estimation!
clear
gen per=.
save $Data_built\time_use_1a_all.dta, replace

* 2005 - 2012
foreach y in 105 205 305 405 106 206 207 208 109 110 111 112 {

use $Data_raw\ENOE\COE1T`y'.dta, clear 
merge 1:1 n_ren n_ent n_hog n_pro_viv v_sel con upm per ent d_sem cd_a using $Data_raw\ENOE\COE2T`y'.dta
keep if r_def==00

*LABOR FORCE PARTICIPATION/HRS (ocupados)
egen ls_dum = anymatch(p1 p1a1 p1d), v(1)
replace ls_dum = 1 if p1a2==2 & p1a1==.
replace ls_dum = 1 if (p1d==2 & p1e==1) | (p1d==9 & p1e==1) 
replace ls_dum =1 if p1c==01 |  p1c==02 |  p1c==03 |  p1c==04

* Unemployed / desocupados
gen unempl =1 if p1c==11 // people who started a new job this week)
replace unempl =1 if p1b==2 & (p2_1==1 | p2_2==2 | p2_3==3) & p2b==1 & p2c!=2 & p2c!=9
replace unempl =1 if (p1d==2 | p1d==9) & (p2_1==1 | p2_2==2 | p2_3==3) & p2b==1 & p2c!=2 & p2c!=9
egen lfp=rowmax(unempl ls_dum)
recode unempl .=0 if lfp==1

*Hours worked, wages (as calculated for ENOE statistics)
recode p5c_thrs 999=.
gen ls_hrs = p5c_thrs
replace ls_hrs=. if lfp==0 // ENOE also calculates hours onle for people who are working
recode p6b2 999998=.
gen inc_mo = p6b2 if lfp==1
gen wage_hr=inc_mo/(ls_hrs*4.3)
gen logwage_hr = log(wage_hr)

replace inc_mo  =. if lfp==0
replace wage_hr =. if lfp==0
replace logwage_hr =. if lfp==0

/*
foreach var in p5c_mlu p5c_mma p5c_mmi p5c_mju p5c_mvi p5c_msa p5c_mdo {
replace `var'=`var'/60
}
foreach var in p5c_hlu p5c_hma p5c_hmi p5c_hju p5c_hvi p5c_hsa p5c_hdo {
recode `var' 99=. 98=.
}

egen ls_hrs = rowtotal(p5c_hlu p5c_hma p5c_hmi p5c_hju p5c_hvi p5c_hsa p5c_hdo p5c_mlu p5c_mma p5c_mmi p5c_mju p5c_mvi p5c_msa p5c_mdo), m 
replace ls_hrs=. if lfp==0 // ENOE also calculates hours onle for people who are working

gen inc_week = p6b2 if p6b1==3
replace inc_week = p6b2*7 if p6b1==4
replace inc_week = p6b2/2 if p6b1==2
replace inc_week = p6b2/4 if p6b1==1
gen wage_hr = inc_week/ls_hrs
gen logwage_hr = log(wage_hr)

*EARNINGS: 
*gen weekly days worked on main job
gen days_wrk=.
replace days_wrk=p5c_tdia if p5d==1
replace days_wrk=. if p5c_tdia==9
replace days_wrk=p5e_tdia if days_wrk==. & p5e_tdia!=9

*gen weekly hrs worked main job
gen weekhrs_wrk=.
replace weekhrs_wrk=p5c_thrs if p5d==1 & p5c_thrs!=999
replace weekhrs_wrk=. if p5d==2
replace weekhrs_wrk=p5e_thrs if weekhrs_wrk==. & p5e_thrs!=999
replace weekhrs_wrk=p5c_thrs if p5e1==2 & p5c_thrs!=999

*monthly earnings from main job
gen earn_mo=.
replace earn_mo=p6b2 if p6b1==1
replace earn_mo=p6b2*2.1725 if p6b1==2
replace earn_mo=p6b2*4.345 if p6b1==3
replace earn_mo=p6b2*4.345*days_wrk if p6b1==4

*wage estimate from main job: 
gen estim_wage=earn_mo/(4.345*weekhrs_wrk)
gen log_estim_wage_hr = log(estim_wage)
*/

*household monthly earnings. 
sort cd_a ent con v_sel n_hog h_mud
by cd_a ent con v_sel n_hog h_mud: egen hh_earn_mo=total(inc_mo)

*OTHER TIME USE
egen chores=anymatch(p11_2 p11_3 p11_4 p11_5 p11_6), v(2 3 4 5 6)
foreach var in p11_m1 p11_m2 p11_m3 p11_m4 p11_m5 p11_m6  {
replace `var'=`var'/60
}
foreach var in p11_h1 p11_h2 p11_h3 p11_h4 p11_h5 p11_h6  {
recode `var' 99=. 98=.
}
egen chores_hrs = rowtotal(p11_h2 p11_h3 p11_h4 p11_h5 p11_h6 p11_m2 p11_m3 p11_m4 p11_m5 p11_m6), m 
egen study_hrs = rowtotal(p11_h1 p11_m1), m
ren p11_1 study 
recode study .=0


*BORDER CROSSING PLANS
gen unemp_border_cross=.
replace unemp_border_cross=0 if p2_2==2
replace unemp_border_cross=0 if p2_3==3
replace unemp_border_cross=1 if p2_1==1

gen newjob_border_cross=.
replace newjob_border_cross=1 if p8_1==1
replace newjob_border_cross=0 if p8_2==2
replace newjob_border_cross=0 if p8_3==3


*REMITTANCES QUESTION
gen got_remit_3m=0
replace got_remit_3m=1 if p10a1==1

*Return DEPORTATION QUESTION
gen rep_ret_dep=0
replace rep_ret_dep=1 if p9a==6

*time of return deportation
gen dep_yr=.
replace dep_yr=p9f_anio if rep_ret_dep==1
replace dep_yr=. if dep_yr==9999
gen dep_mo=.
replace dep_mo=p9f_mes if rep_ret_dep==1
replace dep_mo=. if dep_mo==99

keep con v_sel h_mud n_ren n_ent n_hog n_pro_viv upm per  v_sel con  ent d_sem cd_a eda lfp ///
	unemp_border_cross newjob_border_cross got_remit_3m ///
	ls_hrs ls_dum inc_mo wage_hr unempl logwage_hr hh_earn_mo ///
	rep_ret_dep dep_yr dep_mo chores* study* ur fac ///
	
gen svy_type="extended_old"
gen quarter =substr("`y'", 1, 1)
gen year = "20" + substr("`y'",2,.)
destring quarter, replace
destring year, replace
merge 1:1 cd_a ent con v_sel n_hog h_mud n_ren using $Data_built\socioT`y'_all.dta
drop if _merge==2
drop _merge

gen wage_loweduc = wage_hr if anios_esc<=9
gen wage_higheduc = wage_hr if anios_esc>9
gen ls_dum1_low = ls_dum if anios_esc<=9
gen ls_dum1_high = ls_dum if anios_esc>9

append using $Data_built\time_use_1a_all.dta
drop if per==.
save $Data_built\time_use_1a_all.dta, replace
sleep 250
}

***************************************

clear
gen per=.
save $Data_built\time_use_2a_all.dta, replace

* basico, 1a, 2a 3a version

foreach y in 306 406 107 307 407 108 308 408 209 309 409 210 310 410 211 311 411 212 312 412 {

use $Data_raw\ENOE\COE1T`y'.dta, clear 
merge 1:1 n_ren n_ent n_hog n_pro_viv upm per ent d_sem cd_a using $Data_raw\ENOE\COE2T`y'.dta
keep if r_def==00
*keep if eda<25

*LABOR FORCE PARTICIPATION/HRS (ocupados)
egen ls_dum = anymatch(p1 p1a1 p1d), v(1)
replace ls_dum = 1 if p1a2==2 & p1a1==.
replace ls_dum = 1 if (p1d==2 & p1e==1) | (p1d==9 & p1e==1) 
replace ls_dum =1 if p1c==01 |  p1c==02 |  p1c==03 |  p1c==04

* Unemployed / desocupados
gen unempl =1 if p1c==11 // people who started a new job this week)
replace unempl =1 if p1b==2 & (p2_1==1 | p2_2==2 | p2_3==3) & p2b==1 & p2c!=2 & p2c!=9
replace unempl =1 if (p1d==2 | p1d==9) & (p2_1==1 | p2_2==2 | p2_3==3) & p2b==1 & p2c!=2 & p2c!=9
egen lfp=rowmax(unempl ls_dum)
recode unempl .=0 if lfp==1

*Hours worked, wages (as calculated for ENOE statistics)
recode p5b_thrs 999=.
gen ls_hrs = p5b_thrs
replace ls_hrs=. if lfp==0 // ENOE also calculates hours onle for people who are working
recode p6b2 999998=.
gen inc_mo = p6b2 if lfp==1
gen wage_hr=inc_mo/(ls_hrs*4.3)
gen logwage_hr = log(wage_hr)

replace inc_mo  =. if lfp==0
replace wage_hr =. if lfp==0
replace logwage_hr =. if lfp==0

/*LABOR FORCE PARTICIPATION/HRS
egen lfp = anymatch(p1 p1a1 p1b), v(1)
replace lfp = 1 if p1a2==2

foreach var in p5b_mlu p5b_mma p5b_mmi p5b_mju p5b_mvi p5b_msa p5b_mdo {
replace `var'=`var'/60
}
foreach var in p5b_hlu p5b_hma p5b_hmi p5b_hju p5b_hvi p5b_hsa p5b_hdo {
recode `var' 99=. 98=.
}

/*
egen ls_hrs = rowtotal(p5b_mlu p5b_mma p5b_mmi p5b_mju p5b_mvi p5b_msa p5b_mdo p5b_hlu p5b_hma p5b_hmi p5b_hju p5b_hvi p5b_hsa p5b_hdo), m 
gen inc_week = p6b2 if p6b1==3
replace inc_week = p6b2*7 if p6b1==4
replace inc_week = p6b2/2 if p6b1==2
replace inc_week = p6b2/4 if p6b1==1
gen wage_hr = inc_week/ls_hrs
gen logwage_hr = log(wage_hr)
*/

*EARNINGS: 
*gen weekly days worked on main job
gen days_wrk=.
replace days_wrk=p5b_tdia if p5c==1
replace days_wrk=. if p5b_tdia==9
replace days_wrk=p5d_tdia if days_wrk==. & p5d_tdia!=9

*gen weekly hrs worked main job
gen weekhrs_wrk=.
replace weekhrs_wrk=p5b_thrs if p5c==1 & p5b_thrs!=999
replace weekhrs_wrk=. if p5c==2
replace weekhrs_wrk=p5d_thrs if weekhrs_wrk==. & p5d_thrs!=999
replace weekhrs_wrk=p5b_thrs if p5d1==2 & p5b_thrs!=999

*monthly earnings from main job
gen earn_mo=.
replace earn_mo=p6b2 if p6b1==1
replace earn_mo=p6b2*2.1725 if p6b1==2
replace earn_mo=p6b2*4.345 if p6b1==3
replace earn_mo=p6b2*4.345*days_wrk if p6b1==4

*wage estimate from main job: 
gen estim_wage=earn_mo/(4.345*weekhrs_wrk)
gen log_estim_wage_hr = log(estim_wage)
*/

*household monthly earnings. 
sort cd_a ent con v_sel n_hog h_mud
by cd_a ent con v_sel n_hog h_mud: egen hh_earn_mo=total(inc_mo)

*OTHER TIME USE
egen chores=anymatch(p9_2 p9_3 p9_4 p9_5 p9_6), v(2 3 4 5 6)
foreach var in p9_m1 p9_m2 p9_m3 p9_m4 p9_m5 p9_m6 {
replace `var'=`var'/60
}
foreach var in p9_h1 p9_h2 p9_h3 p9_h4 p9_h5 p9_h6 {
recode `var' 99=. 98=.
}
egen chores_hrs = rowtotal(p9_m2 p9_m3 p9_m4 p9_m5 p9_m6 p9_h2 p9_h3 p9_h4 p9_h5 p9_h6), m 
egen study_hrs = rowtotal(p9_h1 p9_m1), m
ren p9_1 study 
recode study .=0

*BORDER CROSSING PLANS
gen unemp_border_cross=.
replace unemp_border_cross=0 if p2_2==2
replace unemp_border_cross=0 if p2_3==3
replace unemp_border_cross=1 if p2_1==1

gen newjob_border_cross=.
replace newjob_border_cross=1 if p8_1==1
replace newjob_border_cross=0 if p8_2==2
replace newjob_border_cross=0 if p8_3==3

*REMITTANCES QUESTION-not in basic

*return DEPORTATION QUESTION
gen rep_ret_dep=0
replace rep_ret_dep=1 if p2i==6
*time of return-deportation
gen dep_yr=.
replace dep_yr=p2k_anio if rep_ret_dep==1
replace dep_yr=. if dep_yr==9999
gen dep_mo=.
replace dep_mo=p2k_mes if rep_ret_dep==1
replace dep_mo=. if dep_mo==99

keep con v_sel h_mud n_ren n_ent n_hog n_pro_viv upm per d_sem ent cd_a eda lfp ///
	unemp_border_cross newjob_border_cross ///	
	ls_hrs ls_dum inc_mo wage_hr logwage_hr unempl  hh_earn_mo ///
	rep_ret_dep dep_yr dep_mo  chores* study* ur fac 

gen svy_type="basic_old"
gen quarter =substr("`y'", 1, 1)
gen year = "20" + substr("`y'",2,.)
destring quarter, replace
destring year, replace
merge 1:1 cd_a ent con v_sel n_hog h_mud n_ren using $Data_built\socioT`y'_all.dta
drop if _merge==2
drop _merge

gen wage_loweduc = wage_hr if anios_esc<=9
gen wage_higheduc = wage_hr if anios_esc>9
gen ls_dum1_low = ls_dum if anios_esc<=9
gen ls_dum1_high = ls_dum if anios_esc>9

append using $Data_built\time_use_2a_all.dta
save $Data_built\time_use_2a_all.dta, replace
sleep 250
}

*********************************************************************************
* Final changes
use $Data_built\time_use_1a_all.dta, clear
append using $Data_built\time_use_2a_all.dta
append using $Data_built\time_use_4a_all.dta
append using $Data_built\time_use_5a_all.dta

cap erase $Data_built\time_use_1a_all.dta 
cap erase $Data_built\time_use_2a_all.dta
cap erase $Data_built\time_use_4a_all.dta
cap erase $Data_built\time_use_5a_all.dta


foreach x in 1 2 3 4 {
foreach y in 05 06 07 08 09 10 11 12 13 14 15 16 17 18 {
cap erase $Data_built\socioT`x'`y'_all.dta
}
}
*


label drop per
*label drop _all
gen time_yq=yq(year,quarter)
format time_yq %tq

ta n_ent migr_3m 
replace migr_3m =. if n_ent==1
replace return_3m = . if n_ent==1
replace dom_migr_3m =. if n_ent==1
replace dom_return_3m = . if n_ent==1

gen obs=1
sort indiv_id
by indiv_id: egen times_obs=total(obs)
tab times_obs

gen cohab =1 if birthorder!=.
recode cohab .=0

*checking
*isid indiv_id_visit

*someone in hh reports remitnces
sort hh_id_visit n_ent
by  hh_id_visit: egen hh_report_remit=total(got_remit_3m)
replace hh_report_remit=1 if hh_report_remit>=1
replace hh_report_remit=. if inlist(svy_type, "basic_old","basic_new")


*gen target grade
gen ontrack_grade=.
replace ontrack_grade=eda-5 if late_yr_birth==0
replace ontrack_grade=eda-6 if late_yr_birth==1
replace ontrack_grade=. if eda>18
replace ontrack_grade=. if anios_esc>12

gen yrs_offtrack=anios_esc-ontrack_grade

sort indiv_id
by indiv_id: egen will_migrate=total(migrant)
replace will_migrate=1 if will_migrate>1

sort indiv_id
by indiv_id: egen will_dom_migrate=total(dom_migrant)
replace will_dom_migrate=1 if will_dom_migrate>1

sort indiv_id
by indiv_id: egen has_returned=total(returnee)
replace has_returned=1 if has_returned>1

sort indiv_id
by indiv_id: egen has_dom_returned=total(dom_returnee)
replace has_dom_returned=1 if has_dom_returned>1

sort hh_id
by hh_id: egen hh_has_migrant=total(migrant)
replace  hh_has_migrant=1 if  hh_has_migrant>=1

sort hh_id
by hh_id: egen hh_has_dom_migrant=total(dom_migrant)
replace  hh_has_dom_migrant=1 if  hh_has_dom_migrant>=1

sort hh_id
by hh_id: egen hh_has_return=total(returnee)
replace  hh_has_return=1 if  hh_has_return>=1

sort hh_id
by hh_id: egen hh_has_dom_return=total(dom_returnee)
replace  hh_has_dom_return=1 if  hh_has_dom_return>=1

sort hh_id

forval i=1/5{
by hh_id: gen hh_obs_ent`i'a=1 if n_ent==`i'	
by hh_id: egen hh_obs_ent`i'=max(hh_obs_ent`i'a)
drop hh_obs_ent`i'a
replace hh_obs_ent`i'=0 if hh_obs_ent`i'==.
}

sort indiv_id
forval i=1/5{
by indiv_id: gen indiv_obs_ent`i'a=1 if n_ent==`i'	
by indiv_id: egen indiv_obs_ent`i'=max(indiv_obs_ent`i'a)
drop indiv_obs_ent`i'a
replace indiv_obs_ent`i'=0 if indiv_obs_ent`i'==.
}

* create indicator for individuals who were still enrolled in first quarter of interviews
* identifies individuals who have not already made a hard to reverse drop out decision long ago
sort indiv_id
gen ent1_enroll_a=.
replace ent1_enroll_a=1 if enroll==1 & n_ent==1
replace ent1_enroll_a=0 if enroll==0 & n_ent==1

by indiv_id: egen ent1_enroll=max(ent1_enroll_a)
drop ent1_enroll_a

*generate variables to select on for regressions

*hh_const (set to one for one observation for each household)
*To get a household constants data set select observations hh_const==1 
sort hh_id n_ent
by  hh_id: gen count=_n
gen hh_bsline=.
replace hh_bsline=1 if count==1
drop count

*NOTE: for early households in 2005, observe them for fewer waves. Is this a problem for us? 
*tab2 hh_const n_ent
*ab time_yq if hh_const==1 & n_ent>1


*hh_vari (set to one for one observation for each household visit)
*To get a household-time panel data set select observations hh_vari==1 
sort hh_id_visit n_ent
by  hh_id_visit: gen count=_n
gen hh_vari=.
replace hh_vari=1 if count==1 
drop count

gen hh_ent1=. 
replace hh_ent1=1 if hh_vari==1 & n_ent==1
gen hh_ent5=. 
replace hh_ent5=1 if hh_vari==1 & n_ent==5

*hh_extend (set to one for one observation for each household extended questionaire visit)
*To get a household-time panel data set select observations hh_vari==1 
sort hh_id_visit n_ent
by  hh_id_visit: gen count=_n
gen hh_extend=.
replace hh_extend=1 if count==1 & svy_type=="extended_new"
replace hh_extend=1 if count==1 & svy_type=="extended_old"
drop count

*hh_extend_single (set to one for one observation for a single household extended questionaire visit)
*some households do the extended questionair multiple times is it is their 1st and 5th and if before 2006q2
sort hh_id_visit n_ent
by  hh_id_visit: gen count=_n
gen hh_extend_single=.
replace hh_extend_single=1 if count==1 & svy_type=="extended_new" & inlist(n_ent,1,2,3,4)
replace hh_extend_single=1 if count==1 & svy_type=="extended_old" & year>=2007 & inlist(n_ent,1,2,3,4)
replace hh_extend_single=1 if count==1 & svy_type=="extended_old" & time_yq<2007 & quarter==2 & inlist(n_ent,1,2,3,4)

drop count

*ind_const (set to one for one observation for each individual )
*To get individual constants data set select observations ind_const==1 
sort indiv_id n_ent
by  indiv_id: gen count=_n
gen ind_bsline=.
replace ind_bsline=1 if count==1
drop count

gen female=.
replace female=1 if sex==2
replace female=0 if sex==1

label var cohab "Lives with parents"
label var migr_3m "number of hh members who migrated in last 3 months (not available for hh in 1. round)" 
label var return_3m "number of hh members who returned in last 3 months (not available for hh in 1. round)" 
label var migrant "Person migrates whithin three months (not available for hh in 5. round)" 
label var hh_bsline "To get a household baseline data set select observations hh_bsline==1"
label var hh_vari "To get a household-time panel data set select observations hh_vari==1"
label var ind_bsline "To get individual baseline data set select observations ind_bsline==1"

gen geo2_mx2015 = ent*1000 + mun

merge m:1 geo2_mx2015 using $Data_built\Claves_1960_2015.dta
drop if _merge==2 // not all municipalities coevered in any round? 
drop _merge geo1_mx2015 geo1_mx2010 geo2_mx2010 geo1_mx2005 geo2_mx2005

save $Data_built\time_use_all_merge.dta, replace

/********************************************************************************
* This is to create an individual level file with shock variable

gen geo2_mx2015 = ent*1000 + mun

merge m:1 geo2_mx2015 using Data_built\Claves\Claves_1960_2015.dta
drop if _m==2 // not all municipalities coevered in any round? 
drop _m geo1_mx2015 geo1_mx2010 geo2_mx2010 geo1_mx2005 geo2_mx2005


rename d_mes month 
ta month 
drop year
ta d_anio 
rename d_anio year
replace year = 2000+ year
keep if year <=2014
gen time_ym=ym(year,month)
format time_ym %tm

merge m:1 geo2_mx2000 year month using Data_built\Matriculas\Shock_Mat_SecComm_Sanc_all.dta
drop if _m==2 
drop _m

rename month int_month
rename year int_year
drop if int_year==2015

gen net_3m=migr_3m-return_3m
gen net_dom_migr_3m=dom_migr_3m-dom_return_3m

save Data_built\ENOE\ENOE_timeuse_shock_all.dta, replace

*/




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

***********************************************************************************
*MERGE INDIVIDUALS AND HOUSEHOLD WIDE PANEL VARIABLES AND SELECT WHAT TO KEEP IN MAIN CROSS-SECTION DATA
***********************************************************************************
use  $Data_built\indiv_attrit_wide.dta
merge m:1 hh_id using  $Data_built\hh_attrit_wide.dta
keep if _merge==3
drop _merge

save $Data_built\indiv_hh_attrit_wide.dta, replace
cap erase  $Data_built\indiv_attrit_wide.dta
cap erase  $Data_built\hh_attrit_wide.dta

merge 1:m indiv_id using  $Data_built\time_use_all_merge.dta
drop _merge 

cap erase $Data_built\time_use_all_merge.dta

*gen year=int_year
keep if year <=2014

gen pop=1

*generating duplicate variables for variables that will be looked at with mean and sum
gen ls_dum2_low= ls_dum1_low
gen ls_dum2_high= ls_dum1_high

foreach i in study enroll migrant dom_migrant returnee dom_returnee yoy_hhdeparts yoy_hharrives {
rename `i' `i'1
gen `i'2=`i'1	
}
/*
cap drop geo2_mx2000 geo1_mx2000
gen geo2_mx2015 = ent*1000 + mun

merge m:1 geo2_mx2015 using $Data_built\Claves_1960_2015.dta
drop if _merge==2 // not all municipalities coevered in any round? 
drop _merge geo1_mx2015 geo1_mx2010 geo2_mx2010 geo1_mx2005 geo2_mx2005
*/
save $Data_built\time_use_all_merge2.dta, replace


*UNCOMMENT BELOW TO MAKE SMALLER FULL CROSS-SECTION DATA SETS. 
/*

**********************************************************************************
*smaller datasets (could also selected appropriate variables.)
use Data_built\ENOE\time_use_all_merge2.dta, replace
keep if eda<=21
save Data_built\ENOE\ENOE_timeuse_shock_1221.dta, replace

use Data_built\ENOE\time_use_all_merge2.dta, replace
keep if hh_vari==1
save Data_built\ENOE\ENOE_timeuse_shock_hh_vari.dta, replace

use Data_built\ENOE\time_use_all_merge2.dta, replace
keep if hh_bsline==1
save Data_built\ENOE\ENOE_timeuse_shock_hh_bsline.dta, replace

***********************************************************************************

*/


