clear all
set more off


********************************************************************************
** This dofile creates the mexican dataset on time use of adolescents
* Esther Gehrke
* March, 20 2019


********************************************************************************
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

********************************************************************************
*PREP:
*Input Files: 
*files of type: 
*Data_raw\ENOE\SDEMT`x'`y'.dta
*Data_raw\ENOE\HOGT`x'`y'.dta 
*Data_built\Claves\Claves_1960_2015.dta
*Data_built\EMIF\Shock_EMIF_SecComm_Sanc_2.dta


*Output Files:
*files of type: Data_built\ENOE\educT`x'`y'.dta
*Data_built\ENOE\educENOE.dta
*Data_built\ENOE\ENOE_educ_shock.dta



*******
*to integrate a queston from the sociodemographic survey: Just add once in section below

*to integrate a queston from the extended ampliado questionaire or the basic add twice for 
*the older versions 1,2,3 and newer versions 4,5 in two different sections. 


*********************************************************************************
*********************************************************************************
* Sociodemographico
* birth order, number of siblings (older and younger), gender, migration history
foreach x in 1 2 3 4 {
foreach y in 05 06 07 08 09 10 11 12 13 14 15  {
use Data_raw\ENOE\SDEMT`x'`y'.dta, clear
 rename *, lower
 save Data_raw\ENOE\SDEMT`x'`y'.dta, replace
}
}
*

* 1a, 2a, 3a, 4a 
foreach x in 1 2 3 4 {
foreach y in 05 06 07 08 09 10 11 12 13 14 15 16 17 18 {

use Data_raw\ENOE\SDEMT`x'`y'.dta, clear
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

merge m:1 cd_a ent con v_sel n_hog h_mud using Data_raw\ENOE\HOGT`x'`y'.dta
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
	merge 1:1 cd_a ent con v_sel n_hog  n_ren using Data_raw\ENOE\SDEMT10`z'.dta  
	}
	if "`y'" >= "09" {
	local z = `y'+1
	merge 1:1 cd_a ent con v_sel n_hog  n_ren using Data_raw\ENOE\SDEMT1`z'.dta  
	}
}
if "`x'" == "1" | "`x'" == "2" | "`x'" == "3" {
local w = `x'+1
merge 1:1 cd_a ent con v_sel n_hog  n_ren  using Data_raw\ENOE\SDEMT`w'`y'.dta  
}
cap drop if _merge==2
replace match=1 if _m==3
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
    kids teen_f  teen_m ya_f  ya_m  adult_f  adult_m  hhv_kids hhv_teen_f  hhv_teen_m  hhv_youngadult_f  hhv_youngadult_m hhv_adult_m  hhv_adult_f ///
	ing_x_hrs hhsize cohabsib birthorder par_c d_dia d_mes d_anio c_res ///
	 n_ent  first_int_yq migrated returned late_yr_birth anios_esc dom_migrated dom_returned dom_return_3m dom_migr_3m  any_migrant_3m any_dom_migrant_3m any_return_3m  any_dom_return_3m cs_ad_des cs_nr_ori migrant match dom_migrant returnee dom_returnee


	
save Data_built\ENOE\socioT`x'`y'_all.dta, replace
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
save Data_built\ENOE\time_use_4a_all.dta, replace

* 2013, 2014, 2015, 16, 17, 18
foreach y in 13 14 15 16 17 18 {
use Data_raw\ENOE\COE1T1`y'.dta, clear 
merge 1:1 n_ren n_ent n_hog n_pro_viv upm per ent d_sem cd_a using Data_raw\ENOE\COE2T1`y'.dta
keep if r_def==00

*LABOR FORCE PARTICIPATION/HRS (ocupados)
egen lfp = anymatch(p1 p1a1 p1d), v(1)
replace lfp = 1 if p1a2==2 & p1a1==.
replace lfp = 1 if (p1d==2 & p1e==1) | (p1d==9 & p1e==1) 
replace lfp =1 if p1c==01 |  p1c==02 |  p1c==03 |  p1c==04

* Unemployed / desocupados
gen unempl =1 if p1c==11 // people who started a new job this week)
replace unempl =1 if p1b==2 & (p2_1==1 | p2_2==2 | p2_3==3) & p2b==1 & p2c!=2 & p2c!=9
replace unempl =1 if (p1d==2 | p1d==9) & (p2_1==1 | p2_2==2 | p2_3==3) & p2b==1 & p2c!=2 & p2c!=9
//recode unempl .=0

*Hours worked, wages (as calculated for ENOE statistics)
recode p5c_thrs 999=.
gen ls_hrs = p5c_thrs
replace ls_hrs=. if lfp==0 // ENOE also calculates hours onle for people who are working
recode p6b2 999998=.
gen inc_mo = p6b2 if lfp==1
gen wage_hr=inc_mo/(ls_hrs*4.3)
gen logwage_hr = log(wage_hr)

/*LABOR FORCE PARTICIPATION/HRS
egen lfp = anymatch(p1 p1a1 p1b), v(1)
replace lfp = 1 if p1a2==2

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
	 ls_hrs inc_mo wage_hr logwage unempl  hh_earn_mo  ///
	rep_ret_dep dep_yr dep_mo  chores* study* ur fac 

gen svy_type="extended_new"
gen quarter =1
gen year = 20`y'
merge 1:1 cd_a ent con v_sel n_hog h_mud n_ren using Data_built\ENOE\socioT1`y'_all.dta
drop if _merge==2
drop _merge
append using Data_built\ENOE\time_use_4a_all.dta
drop if per==.
save Data_built\ENOE\time_use_4a_all.dta, replace
}
*

******************************************************************************
clear
gen per=.
save Data_built\ENOE\time_use_5a_all.dta, replace

* basico, cuarta y quinta version

foreach x in 2 3 4 {
foreach y in 13 14 15 16 17 18 {
use Data_raw\ENOE\COE1T`x'`y'.dta, clear 
merge 1:1 n_ren n_ent n_hog n_pro_viv upm per ent d_sem cd_a using Data_raw\ENOE\COE2T`x'`y'.dta
keep if r_def==00

*LABOR FORCE PARTICIPATION/HRS (ocupados)
egen lfp = anymatch(p1 p1a1 p1d), v(1)
replace lfp = 1 if p1a2==2 & p1a1==.
replace lfp = 1 if (p1d==2 & p1e==1) | (p1d==9 & p1e==1) 
replace lfp =1 if p1c==01 |  p1c==02 |  p1c==03 |  p1c==04

* Unemployed / desocupados
gen unempl =1 if p1c==11 // people who started a new job this week)
replace unempl =1 if p1b==2 & (p2_1==1 | p2_2==2 | p2_3==3) & p2b==1 & p2c!=2 & p2c!=9
replace unempl =1 if (p1d==2 | p1d==9) & (p2_1==1 | p2_2==2 | p2_3==3) & p2b==1 & p2c!=2 & p2c!=9
//recode unempl .=0

*Hours worked, wages (as calculated for ENOE statistics)
recode p5b_thrs 999=.
gen ls_hrs = p5b_thrs
replace ls_hrs=. if lfp==0 // ENOE also calculates hours onle for people who are working
recode p6b2 999998=.
gen inc_mo = p6b2 if lfp==1
gen wage_hr=inc_mo/(ls_hrs*4.3)
gen logwage_hr = log(wage_hr)

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
	ls_hrs inc_mo wage_hr logwage unempl  hh_earn_mo  ///
	rep_ret_dep dep_yr dep_mo  chores* study* ur fac

gen svy_type="basic_new"
gen quarter =`x'
gen year = 20`y'

merge 1:1 cd_a ent con v_sel n_hog h_mud n_ren using Data_built\ENOE\socioT`x'`y'_all.dta
drop if _merge==2
drop _merge
append using Data_built\ENOE\time_use_5a_all.dta
save Data_built\ENOE\time_use_5a_all.dta, replace
}
}
*



* ampliado, 1a, 2a, 3a version
// time use only collects 6 instead of 8 categories, will have to control for this in the estimation!
clear
gen per=.
save Data_built\ENOE\time_use_1a_all.dta, replace

* 2005 - 2012
foreach y in 105 205 305 405 106 206 207 208 109 110 111 112 {

use Data_raw\ENOE\COE1T`y'.dta, clear 
merge 1:1 n_ren n_ent n_hog n_pro_viv v_sel con upm per ent d_sem cd_a using Data_raw\ENOE\COE2T`y'.dta
keep if r_def==00

*LABOR FORCE PARTICIPATION/HRS (ocupados)
egen lfp = anymatch(p1 p1a1 p1d), v(1)
replace lfp = 1 if p1a2==2 & p1a1==.
replace lfp = 1 if (p1d==2 & p1e==1) | (p1d==9 & p1e==1) 
replace lfp =1 if p1c==01 |  p1c==02 |  p1c==03 |  p1c==04

* Unemployed / desocupados
gen unempl =1 if p1c==11 // people who started a new job this week)
replace unempl =1 if p1b==2 & (p2_1==1 | p2_2==2 | p2_3==3) & p2b==1 & p2c!=2 & p2c!=9
replace unempl =1 if (p1d==2 | p1d==9) & (p2_1==1 | p2_2==2 | p2_3==3) & p2b==1 & p2c!=2 & p2c!=9
//recode unempl .=0

*Hours worked, wages (as calculated for ENOE statistics)
recode p5c_thrs 999=.
gen ls_hrs = p5c_thrs
replace ls_hrs=. if lfp==0 // ENOE also calculates hours onle for people who are working
recode p6b2 999998=.
gen inc_mo = p6b2 if lfp==1
gen wage_hr=inc_mo/(ls_hrs*4.3)
gen logwage_hr = log(wage_hr)

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
	ls_hrs inc_mo wage_hr unempl logwage hh_earn_mo ///
	rep_ret_dep dep_yr dep_mo chores* study* ur fac ///
	

gen svy_type="extended_old"
gen quarter =substr("`y'", 1, 1)
gen year = "20" + substr("`y'",2,.)
destring quarter, replace
destring year, replace
merge 1:1 cd_a ent con v_sel n_hog h_mud n_ren using Data_built\ENOE\socioT`y'_all.dta
drop if _merge==2
drop _merge
append using Data_built\ENOE\time_use_1a_all.dta
drop if per==.
save Data_built\ENOE\time_use_1a_all.dta, replace
sleep 250
}

***************************************


clear
gen per=.
save Data_built\ENOE\time_use_2a_all.dta, replace

* basico, 1a, 2a 3a version

foreach y in 306 406 107 307 407 108 308 408 209 309 409 210 310 410 211 311 411 212 312 412 {

use Data_raw\ENOE\COE1T`y'.dta, clear 
merge 1:1 n_ren n_ent n_hog n_pro_viv upm per ent d_sem cd_a using Data_raw\ENOE\COE2T`y'.dta
keep if r_def==00
*keep if eda<25

*LABOR FORCE PARTICIPATION/HRS (ocupados)
egen lfp = anymatch(p1 p1a1 p1d), v(1)
replace lfp = 1 if p1a2==2 & p1a1==.
replace lfp = 1 if (p1d==2 & p1e==1) | (p1d==9 & p1e==1) 
replace lfp =1 if p1c==01 |  p1c==02 |  p1c==03 |  p1c==04

* Unemployed / desocupados
gen unempl =1 if p1c==11 // people who started a new job this week)
replace unempl =1 if p1b==2 & (p2_1==1 | p2_2==2 | p2_3==3) & p2b==1 & p2c!=2 & p2c!=9
replace unempl =1 if (p1d==2 | p1d==9) & (p2_1==1 | p2_2==2 | p2_3==3) & p2b==1 & p2c!=2 & p2c!=9
//recode unempl .=0

*Hours worked, wages (as calculated for ENOE statistics)
recode p5b_thrs 999=.
gen ls_hrs = p5b_thrs
replace ls_hrs=. if lfp==0 // ENOE also calculates hours onle for people who are working
recode p6b2 999998=.
gen inc_mo = p6b2 if lfp==1
gen wage_hr=inc_mo/(ls_hrs*4.3)
gen logwage_hr = log(wage_hr)

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
	ls_hrs inc_mo wage_hr logwage unempl  hh_earn_mo ///
	rep_ret_dep dep_yr dep_mo  chores* study* ur fac 

gen svy_type="basic_old"
gen quarter =substr("`y'", 1, 1)
gen year = "20" + substr("`y'",2,.)
destring quarter, replace
destring year, replace
merge 1:1 cd_a ent con v_sel n_hog h_mud n_ren using Data_built\ENOE\socioT`y'_all.dta
drop if _merge==2
drop _merge
append using Data_built\ENOE\time_use_2a_all.dta
save Data_built\ENOE\time_use_2a_all.dta, replace
sleep 250
}

*********************************************************************************
* Final changes
use Data_built\ENOE\time_use_1a_all.dta, clear
append using Data_built\ENOE\time_use_2a_all.dta
append using Data_built\ENOE\time_use_4a_all.dta
append using Data_built\ENOE\time_use_5a_all.dta
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
replace hh_bslin=1 if count==1
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
replace ind_bslin=1 if count==1
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

save Data_built\ENOE\time_use_all_merge.dta, replace

cap erase Data_built\ENOE\time_use_1a_all.dta 
cap erase Data_built\ENOE\time_use_2a_all.dta
cap erase Data_built\ENOE\time_use_4a_all.dta
cap erase Data_built\ENOE\time_use_5a_all.dta



*********************************************************************************

use Data_built\ENOE\time_use_all_merge, clear
gen geo2_mx2015 = ent*1000 + mun
//keep if eda>=12 & eda<=21 | hh_vari==1

rename d_mes month 
ta month 
drop year
ta d_anio 
rename d_anio year
replace year = 2000+ year
keep if year <=2014
gen time_ym=ym(year,month)
format time_ym %tm

merge m:1 geo2_mx2015 using Data_built\Claves\Claves_1960_2015.dta
drop if _m==2 // not all municipalities coevered in any round? 
drop _m geo1_mx2015 geo1_mx2010 geo2_mx2010 geo1_mx2005 geo2_mx2005

/*merge m:1 geo2_mx2000 year month using Data_built\EMIF\Shock_EMIF_SecComm_Sanc_1.dta
drop if _m==2
drop _m

merge m:1 geo2_mx2000 year month using Data_built\EMIF\Shock_EMIF_SecComm_Sanc_2.dta
drop if _m==2
drop _m

merge m:1 geo2_mx2000 year month using Data_built\EMIF\Shock_EMIF_SecComm_Sanc_3.dta
drop if _m==2
drop _m

merge m:1 geo2_mx2000 year month using Data_built\EMIF\Shock_EMIF_SecComm_Sanc_4.dta
drop if _m==2 // not all municipalities covered in each round...   
drop _m


merge m:1 geo2_mx2000 year month using Data_built\Matriculas\Shock_Mat_SecComm_Sanc_5.dta
drop if _m==2 
drop _m
*/ 

merge m:1 geo2_mx2000 year month using Data_built\Matriculas\Shock_Mat_SecComm_Sanc_all.dta
drop if _m==2 
drop _m

rename month int_month
rename year int_year
drop if int_year==2015

gen net_3m=migr_3m-return_3m
gen net_dom_migr_3m=dom_migr_3m-dom_return_3m


save Data_built\ENOE\ENOE_timeuse_shock_all.dta, replace

**********************************************************************************
*smaller datasets (could also selected appropriate variables.)
use Data_built\ENOE\ENOE_timeuse_shock_all.dta, replace
keep if eda<=21
save Data_built\ENOE\ENOE_timeuse_shock_1221.dta, replace

use Data_built\ENOE\ENOE_timeuse_shock_all.dta, replace
keep if hh_vari==1
save Data_built\ENOE\ENOE_timeuse_shock_hh_vari.dta, replace

use Data_built\ENOE\ENOE_timeuse_shock_all.dta, replace
keep if hh_bsline==1
save Data_built\ENOE\ENOE_timeuse_shock_hh_bsline.dta, replace

***********************************************************************************

use Data_built\ENOE\hh_attrit_FD.dta, clear

keep hh_id  yoy_hhdeparts yoy_hharrives
drop if hh_id==""
merge 1:m hh_id using  Data_built\ENOE\time_use_all_merge
drop _m 
*missing observations mainly in years that will later be dropped
gen geo2_mx2015 = ent*1000 + mun
keep if year <=2014
merge m:1 geo2_mx2015 using Data_built\Claves\Claves_1960_2015.dta
drop if _m==2 // not all municipalities coevered in any round? 
drop _m geo1_mx2015 geo1_mx2010 geo2_mx2010 geo1_mx2005 geo2_mx2005
gen pop=1

replace inc_mo  =. if lfp==0
replace wage_hr =. if lfp==0
replace logwage =. if lfp==0
rename lfp ls_dum
egen lfp=rowmax(unempl ls_dum)
gen wage_loweduc = wage_hr if anios_esc<=9
gen wage_higheduc = wage_hr if anios_esc>9
gen ls_dum1_low = ls_dum if anios_esc<=9
gen ls_dum1_high = ls_dum if anios_esc>9

*generating duplicate variables for variables that will be looked at with mean and sum
gen ls_dum2_low= ls_dum1_low
gen ls_dum2_high= ls_dum1_high

foreach i in study enroll migrant dom_migrant returnee dom_returnee yoy_hhdeparts yoy_hharrives {
rename `i' `i'1
gen `i'2=`i'1	
}

/*
rename study study1
gen study2=study1
rename enroll enroll1
gen enroll2=enroll1
rename migrant migrant1
gen migrant2=migrant1
rename dom_migrant dom_migrant1
gen dom_migrant2=dom_migrant1
rename returnee returnee1
gen returnee2=returnee1
rename dom_returnee dom_returnee1
gen dom_returnee2=dom_returnee1
rename yoy_hhdeparts yoy_hhdeparts1
gen yoy_hhdeparts2=yoy_hhdeparts1
rename  yoy_hharrives yoy_hharrives1
gen yoy_hharrives2=yoy_hharrives1
*/



save Data_built\ENOE\time_use_all_merge2.dta, replace


************************
*Write program to get municipal variables of interest for specific population subgoups.
*************************
*`1' string defining observation caracteristics conditioning once
*`2' global list of variables that want to calculate the mean of
*`3' global list of variables that want to calculate the sum of
*`4' variable name reflecting subgroup

program def muniagg_subgroup_prog, rclass

use Data_built\ENOE\time_use_all_merge2, clear
keep if `1'

collapse (mean) `2' (sum) `3' [pw=fac], by(quarter year geo2_mx2000 geo1_mx2000)

foreach i in `2'{
local new = "pwmuni_"+"`i'"+"_mean"+"`4'"
rename `i'	`new'
}

foreach i in `3'{
local new = "pwmuni_"+"`i'"+"_sum"+"`4'"
rename `i'	`new'
}

foreach i in `3' {
local new = "pwmuni_"+"`i'"+"_log"+"`4'"
local name= "pwmuni_"+"`i'"+"_sum"+"`4'"
gen loger=log(`name')	
rename loger `new'
}


tempfile saver
save `saver', replace

use Data_built\ENOE\time_use_all_merge2, clear
keep if `1'

collapse (mean) `2' (sum) `3' , by(quarter year geo2_mx2000 geo1_mx2000)

foreach i in `2'{
local new = "muni_"+"`i'"+"_mean"+"`4'"
rename `i'	`new'
}

foreach i in `3'{
local new = "muni_"+"`i'"+"_sum"+"`4'"
rename `i'	`new'
}

foreach i in `3' {
local new = "muni_"+"`i'"+"_log"+"`4'"
local name= "muni_"+"`i'"+"_sum"+"`4'"
gen loger=log(`name')	
rename loger `new'
}
merge 1:1 quarter year geo2_mx2000 geo1_mx2000 using `saver'
drop _m
save "Data_built\ENOE\ENOE_muniagg`4'.dta", replace
clear
end 
*************************
*************************
*************************

*** total pop
local meantot eda
local sumtot pop
muniagg_subgroup_prog "pop==1" "`meantot'" "`sumtot'" "totpop" "`logsumtot'"

***all 15 and up
local mean15 inc_mo wage_hr logwage wage_loweduc wage_higheduc anios_esc ls_dum1_low ls_dum1_high lfp unempl ls_hrs migrant1 dom_migrant1 returnee1 dom_returnee1
local sum15 pop ls_dum2_low ls_dum2_high migrant2 dom_migrant2 returnee2 dom_returnee2
muniagg_subgroup_prog "eda>=15" "`mean15'" "`sum15'" "15plus"

***20 and under
local mean20u study1 lfp unempl ls_hrs wage_hr inc_mo chores study_hrs enroll1 yrs_offtrack female migrant1 dom_migrant1 returnee1 dom_returnee1
local sum20u pop study2 enroll2 migrant2 dom_migrant2 returnee2 dom_returnee2
muniagg_subgroup_prog "eda<=20" "`mean20u'" "`sum20u'" "20und"

***20 and under female
local mean20uf study1 lfp unempl ls_hrs wage_hr inc_mo chores study_hrs enroll1 yrs_offtrack migrant1 dom_migrant1 returnee1 dom_returnee1
local sum20uf pop study2 enroll2 migrant2 dom_migrant2 returnee2 dom_returnee2
muniagg_subgroup_prog "eda<=20 & female==1" "`mean20uf'" "`sum20uf'" "f20und"

***20 and under male
local mean20um study1 lfp unempl ls_hrs wage_hr inc_mo chores study_hrs enroll1 yrs_offtrack migrant1 dom_migrant1 returnee1 dom_returnee1
local sum20um pop study2 enroll2 migrant2 dom_migrant2 returnee2 dom_returnee2
muniagg_subgroup_prog "eda<=20 & female==0" "`mean20um'" "`sum20um'" "m20und"

*** 12to14
local mean1214 study1 lfp unempl ls_hrs chores chores_hrs study_hrs enroll1 yrs_offtrack female wage_hr migrant1 dom_migrant1 returnee1 dom_returnee1
local sum1214 pop study2 enroll2 migrant2 dom_migrant2 returnee2 dom_returnee2
muniagg_subgroup_prog "eda<=14" "`mean1214'" "`sum1214'" "1214"

*** 15 to 17
local mean1517  study1 lfp unempl ls_hrs chores chores_hrs study_hrs enroll1 yrs_offtrack female wage_hr migrant1 dom_migrant1 returnee1 dom_returnee1
local sum1517 pop study2 enroll2 migrant2 dom_migrant2 returnee2 dom_returnee2
muniagg_subgroup_prog "eda>=15 & eda <=17" "`mean1517'" "`sum1517'" "1517"

*** 18 to 20
local mean1820  study1 lfp unempl ls_hrs chores chores_hrs study_hrs enroll1  yrs_offtrack female wage_hr wage_loweduc wage_higheduc migrant1 dom_migrant1 returnee1 dom_returnee1
local sum1820 pop study2 enroll2 migrant2 dom_migrant2 returnee2 dom_returnee2
muniagg_subgroup_prog "eda>=18 & eda <=21" "`mean1820'" "`sum1820'" "1820"

*** 21 to 35
local mean2135 lfp unempl ls_hrs female wage_hr wage_loweduc wage_higheduc migrant1 dom_migrant1 returnee1 dom_returnee1
local sum2135 pop migrant2 dom_migrant2 returnee2 dom_returnee2
muniagg_subgroup_prog "eda>=21 & eda <=35" "`mean2135'" "`sum2135'" "2135"

*** 21plus
local mean21  lfp unempl ls_hrs hrs female wage_hr wage_loweduc wage_higheduc migrant1 dom_migrant1 returnee1 dom_returnee1
local sum21  pop migrant2 dom_migrant2 returnee2 dom_returnee2
muniagg_subgroup_prog "eda>=21" "`mean21'" "`sum21'" "21plus"

*** 17under enrolled in ent1
local mean17en study1 lfp unempl ls_hrs chores chores_hrs study_hrs enroll1  yrs_offtrack female wage_hr migrant1 dom_migrant1 returnee1 dom_returnee1
local sum17en study2 enroll2 migrant2 dom_migrant2 returnee2 dom_returnee2
muniagg_subgroup_prog "eda<=17 & ent1_enroll==1" "`mean17en'" "`sum17en'" "17en"

*** 17under not enrolled in ent1
local mean17dr study1 lfp unempl ls_hrs chores chores_hrs study_hrs enroll1  yrs_offtrack female wage_hr migrant1 dom_migrant1 returnee1 dom_returnee1
local sum17dr study2 enroll2 migrant2 dom_migrant2 returnee2 dom_returnee2
muniagg_subgroup_prog "eda<=17 & ent1_enroll==0" "`mean17dr'" "`sum17dr'" "17dr"

*** hh values
local meanhh  any_migrant_3m any_return_3m any_dom_migrant_3m any_dom_return_3m hh_has_migrant hh_has_dom_migrant hh_earn_mo got_remit_3m hhv_* hhsize yoy_hhdeparts1 yoy_hharrives1
local sumhh pop yoy_hhdeparts2 yoy_hharrives2
muniagg_subgroup_prog "hh_vari==1" "`meanhh'" "`sumhh'" "hh"

*** hh values ent1
local meanhhent1  yoy_hhdeparts1 
local sumhhent1 pop yoy_hhdeparts2 
muniagg_subgroup_prog "hh_ent1==1" "`meanhhent1'" "`sumhhent1'" "hhent1"

*** hh values ent5
local meanhhent5  yoy_hharrives1
local sumhhent5 pop  yoy_hharrives2
muniagg_subgroup_prog "hh_ent5==1" "`meanhhent5'" "`sumhhent5'" "hhent5"

* migration_share
use Data_built\ENOE\time_use_all_merge2, clear
keep if year<=2008
collapse (mean) migr_3m any_migrant hh_has_migrant [pw=fac], by(per geo2_mx2000)
drop migr_3m any_migrant
reshape wide hh_has_migrant, i(geo2_mx2000) j(per)
order *105 *205 *305 *405 *106 *206 *306 *406 *107 *207 *307 *407 *108 *208 *308 *408, after(geo2)
egen migr_share_enoe = rowmean(*108 *208 *308 *408)
replace migr_share=. if hh_has_migrant408==. | hh_has_migrant308==. | hh_has_migrant208==. | hh_has_migrant108==.
egen migr_early = rowmean(*107 *207 *307 *407 *106 *206 *306 *406 *105 *205 *305 *405)
replace migr_share=migr_early if migr_share==.
keep migr_share_enoe geo2
save Data_built\ENOE\munmigration.dta, replace

*need to weight by population. But want population weights at baseline? in 2008? 
*using average population of muni in pre 2008 observations
use Data_built\ENOE\ENOE_muniaggtotpop.dta
keep if year <=2008
collapse (mean) pwmuni_pop_sumtotpop , by( geo2_mx2000 geo1_mx2000)
rename pwmuni_pop_sumtotpop muni_popweights
save Data_built\ENOE\munpopweights.dta, replace


use Data_built\ENOE\munmigration.dta, clear
merge 1:1 geo2_mx2000 using Data_built\ENOE\munpopweights.dta
drop _m

merge 1:m geo2_mx2000 using Data_built\ENOE\ENOE_muniaggtotpop.dta
drop _m

merge 1:1 geo2_mx2000 quarter year using Data_built\ENOE\ENOE_muniagg15plus.dta
drop _m

merge 1:1 geo2_mx2000 quarter year using Data_built\ENOE\ENOE_muniagg20und.dta
drop _m

merge 1:1 geo2_mx2000 quarter year using Data_built\ENOE\ENOE_muniaggf20und.dta
drop _m

merge 1:1 geo2_mx2000 quarter year using Data_built\ENOE\ENOE_muniaggm20und.dta
drop _m

merge 1:1 geo2_mx2000 quarter year using Data_built\ENOE\ENOE_muniagg1214.dta
drop _m

merge 1:1 geo2_mx2000 quarter year using Data_built\ENOE\ENOE_muniagg1517.dta
drop _m

merge 1:1 geo2_mx2000 quarter year using Data_built\ENOE\ENOE_muniagg1820.dta
drop _m

merge 1:1 geo2_mx2000 quarter year using Data_built\ENOE\ENOE_muniagg2135.dta
drop _m

merge 1:1 geo2_mx2000 quarter year using Data_built\ENOE\ENOE_muniagg21plus.dta
drop _m

merge 1:1 geo2_mx2000 quarter year using Data_built\ENOE\ENOE_muniagg17en.dta
drop _m

merge 1:1 geo2_mx2000 quarter year using Data_built\ENOE\ENOE_muniagg17dr.dta
drop _m

merge 1:1 geo2_mx2000 quarter year using Data_built\ENOE\ENOE_muniagghh.dta
drop _m

merge 1:1 geo2_mx2000 quarter year using Data_built\ENOE\ENOE_muniagghh.dta
drop _m

merge 1:1 geo2_mx2000 quarter year using Data_built\ENOE\ENOE_muniagghh.dta
drop _m


merge 1:1 geo2_mx2000 quarter year using Data_built\Matriculas\Shock_SecComm_Sanc_all_yq_med.dta
drop if _m==2 // 55,631 out of ... muni-by-quater obs cannot be merged in ENOE!
drop _m

ta quarter year 
ta geo2_mx2000 
codebook geo2_mx2000 // 1,523
bysort geo2_mx2000: gen count_mun=_N
ta count_mun // about 4% of sample is from muns with less than 10 obs!
drop if count_mun==1

gen poptotal = pwmuni_hhsize_meanhh* pwmuni_pop_sumhh
replace poptotal=round(poptotal)

save Data_built\ENOE\ENOE_muniagg_prog.dta, replace


/*
*************************
* Muni-by-quarter controls

use Data_built\ENOE\time_use_all_merge2, clear


keep if eda>=15 
/*
replace inc_mo  =. if lfp==0
replace wage_hr =. if lfp==0
replace logwage =. if lfp==0
rename lfp ls_dum
egen lfp=rowmax(unempl ls_dum)
gen wage_loweduc = wage_hr if anios_esc<=9
gen wage_higheduc = wage_hr if anios_esc>9
gen ls_dum_low = ls_dum if anios_esc<=9
gen ls_dum_high = ls_dum if anios_esc>9
gen emp_n_un_low= ls_dum_low
gen emp_n_un_high= ls_dum_high
gen emp_n_un_1518=ls_dum if eda<=18
gen emp_n_un_old=ls_dum if eda>18
gen emp_n_un_old_low=ls_dum_low if eda>18
gen emp_n_un_old_high=ls_dum_high if eda>18
*/
collapse (mean) inc_mo hh_earn_mo logwage wage_* anios_esc ls_dum* lfp unempl ls_hrs  (sum) pop emp_n_un_low emp_n_un_high emp_n_un_1518 emp_n_un_old emp_n_un_old_low emp_n_un_old_high migr_3m return_3m migrant dom_migrant returnee dom_returnee [pw=fac] , by(quarter year geo2_mx2000 geo1_mx2000)

rename (logwage wage_hr wage_loweduc wage_higheduc anios_esc ls_dum ls_dum_low ls_dum_high emp_n_un_low emp_n_un_high emp_n_un_1518 emp_n_un_old emp_n_un_old_low emp_n_un_old_high migr_3m return_3m ) ///
	(mun_logwage mun_wage_hr mun_wage_low mun_wage_high mun_yearschool mun_ls_share mun_ls_loweduc mun_ls_higheduc mun_sumlfp_low mun_sumlfp_high mun_sumlfp_1518 mun_sumlfp_old mun_sumlfp_old_low  mun_sumlfp_old_high mun_migr_3m mun_return_3m)
drop inc_mo
rename (hh_earn_mo lfp unempl ls_hrs pop) (mun_hh_earn mun_lfp mun_unempl mun_ls_hrs mun_pop)
label var mun_logwage "Log hourly wage, employed pop. >=15, mun. av."
label var mun_wage_hr "Hourly wage, employed pop. >=15, mun. av."
label var mun_wage_low "Hourly wage, employed pop. >=15, schooling <=9 years, mun. av."
label var mun_wage_high "Hourly wage, employed pop. >=15, schooling > 9 years, mun. av."
label var mun_hh_earn "Household labour income, mun. av."
label var mun_yearschool "Average schooling (years), employed pop. >= 15"
label var mun_ls_share "Employed pop/ Total pop, > 15"
label var mun_ls_low "Employed pop. with <=9 years"
label var mun_ls_high "Employed pop. with >9 years"
label var mun_ls_hrs "Hours worked per week, employed pop. >= 15"
label var mun_pop "Municipality population >= 15 years"
label var mun_lfp "Economically active pop. / Total pop., >=15"
label var mun_unempl "Unemployed pop./ Total pop., >=15 years"

save Data_built\ENOE\ENOE_muncontrols_2000.dta, replace
*/

/*
* total pop
use Data_built\ENOE\time_use_all_merge2, clear

collapse (sum) pop [pw=fac] , by(per year geo2_mx2000 geo1_mx2000)
rename pop mun_totalpop 
label var mun_total "Municipality population"
merge 1:1 per year geo2_mx2000 geo1_mx2000 using Data_built\ENOE\ENOE_muncontrols_2000.dta
drop _m
save Data_built\ENOE\ENOE_muncontrols_2000.dta, replace
*/


/*
***************************************************************************************
* Municipality-level outcomes
*all
use Data_built\ENOE\time_use_all_merge2, clear
keep if eda<=20
collapse (mean) study lfp unempl ls_hrs wage_hr inc_mo chores study_hrs enroll yrs_offtrack female (sum) students=study enrolled=enroll migrant dom_migrant returnee dom_returnee [pw=fac], by(geo2_mx2000 quarter year)
rename (study lfp unempl ls_hrs wage_hr inc_mo chores study_hrs enroll migrant dom_migrant returnee dom_returnee yrs_offtrack female ) ///
(study_12to20 lfp_12to20 unempl_12to20 ls_hrs_12to20 wage_hr_12to20 inc_mo_12to20 chores_12to20 study_hrs_12to20 enroll_12to20 migrant_12to20 dom_migrant_12to20 returnee_12to20 dom_returnee_12to20 yrs_offtrack_12to20 female_12to20)
/*
gen logenroll_12to20=log(enrolled)
gen logstudents_12to20=log(students)
*/
cap drop students enrolled
save Data_built\ENOE\ENOE_timeuse_munbyquarter_12to20.dta, replace

*females
use Data_built\ENOE\time_use_all_merge2, clear
keep if eda<=20
keep if female==1

collapse (mean) study lfp unempl ls_hrs chores study_hrs enroll migrant dom_migrant returnee dom_returnee yrs_offtrack wage_hr (sum) students=study enrolled=enroll migrant dom_migrant returnee dom_returnee [pw=fac], by(geo2_mx2000 quarter year)
rename (study lfp unempl ls_hrs  chores study_hrs enroll migrant dom_migrant returnee dom_returnee yrs_offtrack wage_hr ) ///
(study_12to20_f lfp_12to20_f unempl_12to20_f ls_hrs_12to20_f chores_12to20_f study_hrs_12to20_f enroll_12to20_f migrant_12to20_f dom_migrant_12to20_f returnee_12to20_f dom_returnee_12to20_f yrs_offtrack_12to20_f wage_hr_12to20_f)
/*
gen logenroll_females=log(enrolled)
gen logstudents_females=log(students)
*/
cap drop students enrolled
save Data_built\ENOE\ENOE_timeuse_munbyquarter_fem.dta, replace

*males
use Data_built\ENOE\time_use_all_merge2, clear
keep if eda<=20
keep if female==0

collapse (mean) study lfp unempl ls_hrs chores study_hrs enroll migrant  dom_migrant  returnee dom_returnee yrs_offtrack wage_hr (sum) students=study enrolled=enroll migrant  dom_migrant  returnee dom_returnee [pw=fac], by(geo2_mx2000 quarter year)
rename (study lfp unempl ls_hrs  chores study_hrs enroll migrant dom_migrant returnee dom_returnee yrs_offtrack wage_hr ) ///
(study_12to20_m lfp_12to20_m unempl_12to20_m ls_hrs_12to20_m chores_12to20_m study_hrs_12to20_m enroll_12to20_m migrant_12to20_m dom_migrant_12to20_m returnee_12to20_m dom_returnee_12to20_m yrs_offtrack_12to20_m wage_hr_12to20_m)
gen logenroll_males=log(enrolled)
gen logstudents_males=log(students)
cap drop students enrolled
save Data_built\ENOE\ENOE_timeuse_munbyquarter_males.dta, replace



* 12 to 14
use Data_built\ENOE\time_use_all_merge2, clear

keep if eda<=14
replace wage_hr =. if lfp==0

collapse (mean) study lfp unempl ls_hrs chores chores_hrs study_hrs enroll migrant  dom_migrant  returnee dom_returnee yrs_offtrack female wage_hr (sum) students=study enrolled=enroll migrant  dom_migrant  returnee dom_returnee [pw=fac], by(geo2_mx2000 quarter year)
rename (study lfp unempl ls_hrs chores chores_hrs study_hrs enroll migrant dom_migrant  returnee dom_returnee  yrs_offtrack female wage_hr) ///
(study_12to14 lfp_12to14 unempl_12to14 ls_hrs_12to14 chores_12to14 chores_hrs_12to14 study_hrs_12to14 enroll_12to14 migrant_12to14 dom_migrant_12to14  returnee_12to14  dom_returnee_12to14   yrs_offtrack_12to14 female_12to14 wage_hr_12to14)
gen logenroll_12to14=log(enrolled)
gen logstudents_12to14=log(students)
cap drop students enrolled
save Data_built\ENOE\ENOE_timeuse_munbyquarter_12to14.dta, replace



* 15 to 17
use Data_built\ENOE\time_use_all_merge2, clear

keep if eda>=15 & eda <=17
replace wage_hr =. if lfp==0

collapse (mean) study lfp unempl ls_hrs chores chores_hrs study_hrs enroll migrant dom_migrant  returnee dom_returnee  yrs_offtrack female wage_hr (sum) students=study enrolled=enroll migrant dom_migrant  returnee dom_returnee[pw=fac], by(geo2_mx2000 quarter year)
rename (study lfp unempl ls_hrs chores chores_hrs study_hrs enroll migrant dom_migrant  returnee dom_returnee  yrs_offtrack female wage_hr) ///
(study_15to17 lfp_15to17 unempl_15to17 ls_hrs_15to17 chores_15to17 chores_hrs_15to17 study_hrs_15to17 enroll_15to17 migrant_15to17 dom_migrant_15to17  returnee_15to17 dom_returnee_15to17  yrs_offtrack_15to17 female_15to17 wage_hr_15to17)
gen logenroll_15to17=log(enrolled)
gen logstudents_15to17=log(students)
cap drop students enrolled
save Data_built\ENOE\ENOE_timeuse_munbyquarter_15to17.dta, replace

* 18 to 20
use Data_built\ENOE\time_use_all_merge2, clear

keep if eda>=18 & eda <=20
/*
replace wage_hr =. if lfp==0
gen wage_loweduc = wage_hr if anios_esc<=9
gen wage_higheduc = wage_hr if anios_esc>9
*/
collapse (mean) study lfp unempl ls_hrs chores chores_hrs study_hrs enroll migrant  dom_migrant  returnee dom_returnee yrs_offtrack female wage_hr wage_loweduc wage_higheduc (sum) students=study enrolled=enroll migrant  dom_migrant  returnee dom_returnee [pw=fac], by(geo2_mx2000 quarter year)
rename (study lfp unempl ls_hrs chores chores_hrs study_hrs enroll migrant dom_migrant  returnee dom_returnee  yrs_offtrack female wage_hr wage_loweduc wage_higheduc) ///
(study_18to20 lfp_18to20 unempl_18to20 ls_hrs_18to20 chores_18to20 chores_hrs_18to20 study_hrs_18to20 enroll_18to20 migrant_18to20 dom_migrant_18to20  returnee_18to20 dom_returnee_18to20  yrs_offtrack_18to20 female_18to20 wage_hr_18to20 wage_loweduc_18to20 wage_higheduc_18to20)
/*
gen logenroll_18to20=log(enrolled)
gen logstudents_18to20=log(students)
*/
cap drop students enrolled
save Data_built\ENOE\ENOE_timeuse_munbyquarter_18to20.dta, replace


* 21 to 35
use Data_built\ENOE\time_use_all_merge2, clear
keep if eda>=21 & eda <=35
/*
replace wage_hr =. if lfp==0
gen wage_loweduc = wage_hr if anios_esc<=9
gen wage_higheduc = wage_hr if anios_esc>9
*/
collapse (mean) lfp unempl ls_hrs   female wage_hr wage_loweduc wage_higheduc  (sum)  migrant dom_migrant   returnee dom_returnee [pw=fac], by(geo2_mx2000 quarter year)
rename ( lfp unempl ls_hrs  migrant dom_migrant  returnee dom_returnee female wage_hr wage_loweduc wage_higheduc) ///
( lfp_21to35 unempl_21to35 ls_hrs_21to35 migrant_21to35 dom_migrant_21to35   returnee_21to35 dom_returnee_21to35   female_21to35 wage_hr_21to35 wage_loweduc_21to35 wage_higheduc_21to35)
save Data_built\ENOE\ENOE_timeuse_munbyquarter_21to35.dta, replace



* 21 plus
use Data_built\ENOE\time_use_all_merge2, clear
keep if eda>=21
/*
replace wage_hr =. if lfp==0
gen wage_loweduc = wage_hr if anios_esc<=9
gen wage_higheduc = wage_hr if anios_esc>9
*/
collapse (mean) lfp unempl ls_hrs hrs  migrant  dom_migrant  returnee dom_returnee  female wage_hr wage_loweduc wage_higheduc (sum) pop migrant  dom_migrant  returnee dom_returnee[pw=fac], by(geo2_mx2000 quarter year)
rename ( lfp unempl ls_hrs  migrant dom_migrant returnee dom_returnee female wage_hr wage_loweduc wage_higheduc) ///
( lfp_21plus unempl_21plus ls_hrs_21plus migrant_21plus dom_migrant_21plus returnee_21plus dom_returnee_21plus female_21plus wage_hr_21plus wage_loweduc_21plus wage_higheduc_21plus)
/*
gen logobs_21plus=log(pop)
*/
save Data_built\ENOE\ENOE_timeuse_munbyquarter_21plus.dta, replace




* enrolled in ent1
use Data_built\ENOE\time_use_all_merge2, clear

keep if ent1_enroll==1
keep if eda <=17
 
collapse (mean) study lfp unempl ls_hrs chores chores_hrs study_hrs enroll  yrs_offtrack female wage_hr (sum) students=study enrolled=enroll migrant returnee [pw=fac], by(geo2_mx2000 quarter year)
rename ( lfp unempl ls_hrs  migrant returnee female wage_hr ) ///
( lfp_ent1_erld_und18 unempl_ent1_erld_und18 ls_hrs_ent1_erld_und18 migrant_ent1_erld_und18 returnee_ent1_erld_und18 female_ent1_erld_und18 wage_hr_ent1_erld_und18)
/*
gen logenroll_ent1_erld_und18=log(enrolled)
gen logstudents_ent1_erld_und18=log(students)
*/
cap drop students enrolled
save Data_built\ENOE\ENOE_timeuse_munbyquarter_ent1_erld_und18.dta, replace


* dropouts in ent1
use Data_built\ENOE\time_use_all_merge2, clear
keep if ent1_enroll==0
keep if eda <=17

collapse (mean) lfp unempl ls_hrs enroll  female wage_hr (sum) pop migrant returnee [pw=fac], by(geo2_mx2000 quarter year)
rename (  lfp unempl ls_hrs enroll migrant returnee female wage_hr ) ///
( lfp_ent1_drp_und18 unempl_ent1_drp_und18 ls_hrs_ent1_drp_und18 enroll_ent1_drp_und18 migrant_ent1_drp_und18 returnee_ent1_drp_und18 female_ent1_drp_und18 wage_hr_ent1_drp_und18)
/*
gen logobs_ent1_drp_und18=log(pop)
cap drop observed
*/
save Data_built\ENOE\ENOE_timeuse_munbyquarter_ent1_drp_und18.dta, replace



*hh outcomes
use Data_built\ENOE\time_use_all_merge2, clear
keep if hh_vari==1 
collapse (mean) any_migrant_3m any_return_3m any_dom_migrant_3m any_dom_return_3m hh_has_migrant hh_has_dom_migrant hh_earn_mo got_remit_3m hhv_* hhsize [pw=fac], by(geo2_mx2000 quarter year)
save Data_built\ENOE\ENOE_timeuse_munbyquarter_hh.dta, replace


** merge, add controls and shock variable
use Data_built\ENOE\ENOE_timeuse_munbyquarter_hh.dta, clear

merge m:1 geo2_mx2000 quarter year using Data_built\ENOE\ENOE_timeuse_munbyquarter_12to20.dta
drop _m
merge m:1 geo2_mx2000 quarter year using Data_built\ENOE\ENOE_timeuse_munbyquarter_fem.dta
drop _m
merge m:1 geo2_mx2000 quarter year using Data_built\ENOE\ENOE_timeuse_munbyquarter_males.dta
drop _m
merge m:1 geo2_mx2000 quarter year using Data_built\ENOE\ENOE_timeuse_munbyquarter_12to14.dta
drop _m
merge m:1 geo2_mx2000 quarter year using Data_built\ENOE\ENOE_timeuse_munbyquarter_15to17.dta
drop _m
merge m:1 geo2_mx2000 quarter year using Data_built\ENOE\ENOE_timeuse_munbyquarter_18to20.dta
drop _m
merge m:1 geo2_mx2000 quarter year using Data_built\ENOE\ENOE_timeuse_munbyquarter_21to35.dta
drop _m
merge m:1 geo2_mx2000 quarter year using Data_built\ENOE\ENOE_timeuse_munbyquarter_21plus.dta
drop _m
merge m:1 geo2_mx2000 quarter year using Data_built\ENOE\ENOE_timeuse_munbyquarter_ent1_erld_und18.dta
drop _m
merge m:1 geo2_mx2000 quarter year using Data_built\ENOE\ENOE_timeuse_munbyquarter_ent1_drp_und18.dta
drop _m
merge m:1 geo2_mx2000 using Data_built\ENOE\munmigration.dta
drop _m
merge 1:1 geo2_mx2000 quarter year using Data_built\ENOE\ENOE_muncontrols_2000.dta
drop _m
merge 1:1 geo2_mx2000 quarter year using Data_built\Matriculas\Shock_SecComm_Sanc_all_yq_med.dta
drop if _m==2 // 55,631 out of ... muni-by-quater obs cannot be merged in ENOE!
drop _m

*also including young adults now so keeping
*keep if enroll_12to20!=. // drops 35 obs that have no adolescents in data!


ta quarter year // each cell >1000, except per 4 of 2014!
ta geo2_mx2000 // most mun>30 obs, but some <4! 
codebook geo2_mx2000 // 1,523
bysort geo2_mx2000: gen count_mun=_N
ta count_mun // about 4% of sample is from muns with less than 10 obs!
drop if count_mun==1

save Data_built\ENOE\ENOE_timeuse_shock_munbyquarter.dta, replace


*/







/*

************************************************************
*CLAIRE: 
*merge in aggregates calculated using the balanced panel of migration-location

use  Data_built\ENOE\ENOE_timeuse_shock_munbyquarter.dta

merge 1:1 geo2_mx2000 quarter year using Data_built\ENOE\ENOE_bal_muni_migall.dta
*look into merge failures. 
gen home_pop=mex_n_mig_pop-absent_pop- unexp_abs_ind

save  Data_built\ENOE\ENOE_timeuse_shock_munbyquarter_test.dta, replace

reg mun_totalpop home_pop

*wierd pattern in scatter plot: Due to weighting? not sure... 
scatter mun_totalpop home_pop
scatter mun_pop home_pop
scatter mun_totalpop mex_n_mig_pop

reg mun_totalpop mun_pop
scatter mun_totalpop mun_pop

gen migsh= abroad_pop/(mex_n_mig_pop)

reg migr_share migsh if year==2008
binscatter  migr_share migsh if year==2008

*/




/*
use Data_built\ENOE\ENOE_timeuse_shock_hh_vari.dta, clear
keep geo1_mx2000 geo2_mx2000 time_ym migrants_* migr_share scweight_* sc_shock_* ym int_year int_month
duplicates drop
save Data_built\ENOE\ENOE_munsample.dta, replace


collapse (mean) scweight_*  sc_shock_* , by(ym int_year)
tsline sc_shock_5, yaxis(2) || tsline scweight_5, yaxis(1)

tsline sc_shock_2, yaxis(2) || tsline scweight_2, yaxis(1)


use Data_built\ENOE\ENOE_munsample.dta, replace



drop year quarter
drop inc_mo hh_earn_mo logwage wage_* anios_esc ls_dum* lfp unempl ls_hrs
reshape wide  pop, i(geo2_mx2000) j(per)

gen month = quarter 
recode month (4=10) (3=7) (2=4) 
ta month 
gen time_ym=yq(year,month)
format time_ym %tm

ta month 
drop year
ta d_anio 
rename d_anio year
replace year = 2000+ year
keep if year <=2014
gen time_ym=ym(year,month)
format time_ym %tm

merge m:1 geo2_mx2015 using Data_built\Claves\Claves_1960_2015.dta
drop if _m==2 // not all municipalities coevered in any round? 
drop _m geo1_mx2015 geo1_mx2010 geo2_mx2010 geo1_mx2005 geo2_mx2005

/*merge m:1 geo2_mx2000 year month using Data_built\EMIF\Shock_EMIF_SecComm_Sanc_1.dta
drop if _m==2
drop _m

merge m:1 geo2_mx2000 year month using Data_built\EMIF\Shock_EMIF_SecComm_Sanc_2.dta
drop if _m==2
drop _m

merge m:1 geo2_mx2000 year month using Data_built\EMIF\Shock_EMIF_SecComm_Sanc_3.dta
drop if _m==2
drop _m

merge m:1 geo2_mx2000 year month using Data_built\EMIF\Shock_EMIF_SecComm_Sanc_4.dta
drop if _m==2 // not all municipalities covered in each round...   
drop _m


merge m:1 geo2_mx2000 year month using Data_built\Matriculas\Shock_Mat_SecComm_Sanc_5.dta
drop if _m==2 
drop _m
*/ 

merge m:1 geo2_mx2000 year month using Data_built\Matriculas\Shock_Mat_SecComm_Sanc_all.dta
drop if _m==2 
drop _m

rename month int_month
rename year int_year
drop if int_year==2015

gen net_3m=migr_3m-return_3m
gen net_dom_migr_3m=dom_migr_3m-dom_return_3m


save Data_built\ENOE\ENOE_timeuse_shock_all.dta, replace



/*
*********************************************************************************

collapse (mean) study* [pw=fac], by(time_yq eda)

tsset time eda

twoway line study time if eda ==15 || line study time if eda ==14 || line study time if eda ==13

twoway line study_hrs time if eda ==15 || line study time if eda ==14 || line study time if eda ==13

*********************************************************************************
** Descriptives of migrants

clear
gen cd_a =.
save Data_built\ENOE\migrants.dta, replace

foreach x in 1 2 3 4 {
foreach y in 05 06 07 08 09 10 11 12 13 14 15 16 17 18 {
use Data_raw\ENOE\SDEMT`x'`y'.dta, clear
keep if r_def==00 // keep only those obs with completed survey
keep if c_res==2 & cs_ad_des==3
keep cd_a ent con v_sel n_hog h_mud n_ren per
rename per per_1
*link member by id in last file merge using  
if "`x'" == "1" {
	if "`y'" != "05" & "`y'"<="10" {
	local z = `y'-1
	merge 1:1 cd_a ent con v_sel n_hog h_mud n_ren using Data_raw\ENOE\SDEMT40`z'.dta  
	}
	if "`y'" > "10" {
	local z = `y'-1
	merge 1:1 cd_a ent con v_sel n_hog h_mud n_ren using Data_raw\ENOE\SDEMT4`z'.dta  
	}
}
if "`x'" == "2" | "`x'" == "3" | "`x'" == "4" {
local w = `x'-1
merge 1:1 cd_a ent con v_sel n_hog h_mud n_ren  using Data_raw\ENOE\SDEMT`w'`y'.dta  
}
cap drop if _merge==2
cap drop _merge
cap drop cs_p14_c
append using  Data_built\ENOE\migrants.dta
drop if cd_a==.
save  Data_built\ENOE\migrants.dta, replace
}
}

su // merges 90% of migants

bysort per cd_a ent con v_sel n_hog h_mud: gen count=_N
* look only at those that went alone... 
su eda if count==1, det // mean 31, iqr 21 - 39, 10%tile 18, 5%tile 16, 90%tile 51
su anios_esc if count==1, det // mean 8.3, median 9, iqr 6-12...

*****************************************************************************
/* masterfile to link mexico US data
clear
gen ent=.
save ENOE\enoe_mun_month.dta, replace

foreach x in 1 2 3 4 {
foreach y in 05 06 07 08 09 10 11 12 13 14 15 16 17 18 {
use ENOE\HOGT`x'`y'.dta, clear
keep ent mun d_mes 
gen year = 20`y'
duplicates drop
append using ENOE\enoe_mun_month.dta
drop if ent==.
save ENOE\enoe_mun_month.dta, replace
}
}

****************************************************************************

* Migration dataset

use ENOE\SDEMT106.dta, clear
keep if r_def==00
*drop if c_res ==2 
keep cd_a ent con v_sel n_hog h_mud n_ren per d_sem n_ent sex eda nac_dia nac_mes nac_anio c_res 

//rename (d_sem c_res sex eda nac_dia nac_mes nac_anio) /// 
//	(d_sem1 c_res1 sex1 eda1 nac_dia1 nac_mes1 nac_anio1)
	
merge 1:1 cd_a ent con v_sel n_hog h_mud n_ren using ENOE\SDEMT206.dta	
gen match=1 if _m==3
gen migr=1 if match==1 & c_res==2 & cs_ad_des==3
recode match .=0
recode migr .=0 if match==1
keep if _m ==3
gen reliab = 1 if nac_anio==nac_anio1 & sex==sex1 
recode reliab .=0 if c_res!=2
su reliab
*/
