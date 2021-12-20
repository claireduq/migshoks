clear all
set more off


********************************************************************************
** This dofile creates the mexican dataset on time use of adolescents
* Esther Gehrke
* March, 20 2019


********************************************************************************
*Esther 
*cd "C:\Users\gehrk001\Dropbox\MigrationShocks\Data"


*Claire
cd "C:\Users\Claire\Dropbox\MigrationShocks\"

********************************************************************************
*PREP:
*Input Files: 
*files of type: 
*Data_raw\ENOE\SDEMT`x'`y'.dta
*Data_raw\ENOE\HOGT`x'`y'.dta 
*Data_built\Claves\Claves_1960_2015.dta
*Data_built\EMIF\Shock_EMIF_SecComm_Sanc_2.dta


*Output Files:
*files of type: Data_built\ENOE\HogarT`x'`y'.dta
*Data_built\ENOE\movHhT`x'`y'.dta
*Data_built\ENOE\movedENOEhh.dta.dta
*Data_built\ENOE\ENOE_moved_hh_shock.dta


*********************************************************************************

*********************************************************************************
* Hogar, restrict to those with complete interviews
foreach x in 1 2 3 4 {
foreach y in 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 {
use Data_raw\ENOE\HOGT`x'`y'.dta, clear
 rename *, lower
keep if r_def==0
save Data_built\ENOE\HogarT`x'`y'.dta, replace
sleep 100
}
}
*******************************************************************************
* Sociodemographico
* birth order, number of siblings (older and younger), gender, migration history

* 1a, 2a, 3a, 4a 
foreach x in 1 2 3 4 {
foreach y in 05 06 07 08 09 10 11 12 13 14 15 16 17 18 {
use Data_raw\ENOE\SDEMT`x'`y'.dta, clear
keep if r_def==00 // keep only those obs with completed survey
drop if c_res==2 // drop migrants	
bysort cd_a ent con v_sel n_hog: gen hhsize=_N
bysort cd_a ent con v_sel n_hog: egen inc_hh = total(ingocup) 

keep loc mun est est_d ageb t_loc cd_a ent con upm d_sem n_pro_viv v_sel n_hog ///
	h_mud n_ent per n_ren sex eda anios_esc hrsocup ingocup inc_hh ///
	ing_x_hrs c_res hhsize par_c n_ent ur fac 
	
sort cd_a ent con v_sel n_hog h_mud par_c
bysort cd_a ent con v_sel n_hog: gen count=_n
keep if count==1
drop count

merge m:1 cd_a ent con v_sel n_hog using Data_built\ENOE\HogarT`x'`y'.dta
*ta r_def if _m==2
drop if _merge==2 // hh with incomplete interviews

keep loc mun est est_d ageb t_loc cd_a ent con upm d_sem n_pro_viv v_sel n_hog ur ///
	h_mud n_ent per n_ren sex eda anios_esc hrsocup ingocup fac inc_hh ///
	ing_x_hrs c_res hhsize par_c d_dia d_mes d_anio r_def p_dia p_mes p_anio n_ent 
	
rename per per1
rename c_res c_res1
rename n_ent n_ent1
rename r_def r_def1
drop if n_ent1==5

gen hh_moved = . 

*link hh by id in next file using  
if "`x'" == "4" {
	if "`y'" >= "05" & "`y'"<"09" {
	local z = `y'+1
	merge 1:1 cd_a ent con v_sel n_hog h_mud using Data_built\ENOE\HogarT10`z'.dta  
	}
	if "`y'" >= "09" {
	local z = `y'+1
	merge 1:1 cd_a ent con v_sel n_hog h_mud using Data_built\ENOE\HogarT1`z'.dta  
	}
}
if "`x'" == "1" | "`x'" == "2" | "`x'" == "3" {
local w = `x'+1
di `w'`y'
merge 1:1 cd_a ent con v_sel n_hog h_mud using Data_built\ENOE\HogarT`w'`y'.dta  
}
drop if n_ent==1
cap drop if _merge==2
replace hh_moved=1 if _m==1
replace hh_moved=0 if _m==3
drop _m
	
keep loc mun est est_d ageb t_loc cd_a ent con upm d_sem n_pro_viv v_sel n_hog ///
	h_mud n_ent per n_ren sex eda anios_esc hrsocup ingocup ///
	ing_x_hrs c_res hhsize inc_hh par_c d_dia d_mes d_anio c_res* fac ///
	per1 hh_moved n_ent*	
	
save Data_built\ENOE\movHhT`x'`y'.dta, replace
}
}	

*********************************************************************************
* Final changes
clear 
gen year=.
save Data_built\ENOE\movedENOEhh.dta, replace

foreach x in 1 2 3 4 {
foreach y in 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19{
if "`x'" != "4" & "`y'"!="19" {
use Data_built\ENOE\movHhT`x'`y'.dta, clear
gen year = 2000 + `y'
gen quarter = `x'
append using Data_built\ENOE\movedENOEhh.dta
save Data_built\ENOE\movedENOEhh.dta, replace
sleep 100
}
}
}

use Data_built\ENOE\movedENOEhh.dta, clear
gen time_yq=yq(year,quarter)
format time_yq %tq

label var hh_moved "Household could not be found in follow-up"
save Data_built\ENOE\movedENOEhh.dta, replace

**********



use Data_built\ENOE\movedENOEhh, clear
keep if year <=2014
rename d_mes month 
ta month 
gen geo2_mx2015 = ent*1000 + mun
drop year
ta d_anio 
rename d_anio year
replace year = 2000+ year

merge m:1 geo2_mx2015 using Data_built\Claves\Claves_1960_2015.dta
drop if _m==2
drop _m geo1_mx2015 geo1_mx2010 geo2_mx2010 geo1_mx2005 geo2_mx2005

merge m:1 geo2_mx2000 year month using Data_built\EMIF\Shock_EMIF_SecComm_Sanc_2.dta
drop if _m==2 // not all municipalities covered in each round...
drop if _m==1 // very few interviews that took place in 2015, even though belonged to round of 414   
drop _m

save Data_built\ENOE\ENOE_moved_hh_shock.dta, replace


/*
use Data_built\ENOE\ENOE_moved_hh_shock.dta, clear
log using hh_moved, replace text 
reghdfe hh_moved sc_shock2 c.migr_share#c.ym if migr_share>0 [aw=fac], a(i.year##i.quarter i.year##i.geo1_mx2000 i.month i.geo2_mx2000) cluster(geo2_mx2000)
reghdfe hh_moved sc_shock2 l1_sc2 c.migr_share#c.ym if migr_share>0 [aw=fac], a(i.year##i.quarter i.year##i.geo1_mx2000 i.month i.geo2_mx2000) cluster(geo2_mx2000)

gen inc_pc = inc_hh/ hhsize
xtile inc_quart = inc_pc, n(4)

reghdfe hh_moved c.sc_shock2##i.inc_quart c.migr_share#c.ym if migr_share>0 [aw=fac], a(i.year##i.quarter i.year##i.geo1_mx2000 i.month i.geo2_mx2000) cluster(geo2_mx2000)
reghdfe hh_moved sc_shock2 c.l1_sc2##i.inc_quart c.migr_share#c.ym if migr_share>0 [aw=fac], a(i.year##i.quarter i.year##i.geo1_mx2000 i.month i.geo2_mx2000) cluster(geo2_mx2000)
log close
*/
