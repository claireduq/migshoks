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

if "`c(username)'"=="Claire" {
	cap cd "C:\Users\Claire\Dropbox\MigrationShocks\"
}

********************************************************************************
*PREP:
*Input Files: 
*files of type: 
*Data_raw\ENOE\SDEMT`x'`y'.dta
*Data_built\ENOE\HogarT`x'`y'.dta
*Data_built\Claves\Claves_1960_2015.dta
*Data_built\EMIF\Shock_EMIF_SecComm_Sanc_2.dta


*Output Files:
*files of type:  Data_built\ENOE\migrHhT`x'`y'.dta
*Data_built\ENOE\ENOE_migr_shock.dta
*Data_built\ENOE\migrHhENOE.dta

*********************************************************************************

*********************************************************************************
* Sociodemographico
* birth order, number of siblings (older and younger), gender, migration history

* 1a, 2a, 3a, 4a 
foreach x in 1 2 3 4 {
foreach y in 05 06 07 08 09 10 11 12 13 14 15 16 17 18 {
use Data_raw\ENOE\SDEMT`x'`y'.dta, clear
keep if r_def==00 // keep only those obs with completed survey
gen migr =1 if c_res==2 & cs_ad_des==3 
bysort cd_a ent con v_sel n_hog h_mud: egen migr_3m = count(migr) 
drop migr
gen ret=1 if c_res==3 & cs_nr_ori==3
bysort cd_a ent con v_sel n_hog h_mud: egen return_3m = count(ret) 
drop ret

drop if c_res==2	
bysort cd_a ent con v_sel n_hog h_mud: egen inc_hh = total(ingocup) 
bysort cd_a ent con v_sel n_hog h_mud: gen hhsize=_N

sort cd_a ent con v_sel n_hog h_mud par_c
bysort cd_a ent con v_sel n_hog: gen count=_n
keep if count==1
drop count

keep loc mun est est_d ageb t_loc cd_a ent con upm d_sem n_pro_viv v_sel n_hog ///
	h_mud n_ent per n_ren return migr sex eda anios_esc hrsocup ingocup ///
	ing_x_hrs inc_hh c_res hhsize par_c n_ent ur fac 
	
merge m:1 cd_a ent con v_sel n_hog h_mud using Data_built\ENOE\HogarT`x'`y'.dta 
drop if _merge==2

keep loc mun est est_d ageb t_loc cd_a ent con upm d_sem n_pro_viv v_sel n_hog ur ///
	h_mud n_ent per n_ren return migr sex eda anios_esc hrsocup ingocup fac ///
	ing_x_hrs inc_hh c_res hhsize par_c d_dia d_mes d_anio n_ent 
	
save Data_built\ENOE\migrHhT`x'`y'.dta, replace
}
}	

*********************************************************************************
* Final changes
clear 
gen year=.
save Data_built\ENOE\migrHhENOE.dta, replace

foreach x in 1 2 3 4 {
foreach y in 05 06 07 08 09 10 11 12 13 14 15 16 17 18 {
use Data_built\ENOE\migrHhT`x'`y'.dta, clear
gen year = 2000 + `y'
gen quarter = `x'
append using Data_built\ENOE\migrHhENOE.dta
save Data_built\ENOE\migrHhENOE.dta, replace
}
}

use Data_built\ENOE\migrHhENOE.dta, clear
gen time_yq=yq(year,quarter)
format time_yq %tq

ta n_ent migr_3m 
drop if n_ent==1

label var migr_3m "number of hh members who migrated in last 3 months (not available for hh in 1. round)" 
label var return_3m "number of hh members who returned in last 3 months (not available for hh in 1. round)" 

save Data_built\ENOE\migrHhENOE.dta, replace

**********

use Data_built\ENOE\migrHhENOE, clear
keep if year <=2014
gen geo2_mx2015 = ent*1000 + mun

rename quarter month
recode month (4=10) (3=7) (2=4) 
ta month 
gen time_ym=yq(year,month)
format time_ym %tm

merge m:1 geo2_mx2015 using Data_built\Claves\Claves_1960_2015.dta
drop if _m==2
drop _m geo1_mx2015 geo1_mx2010 geo2_mx2010 geo1_mx2005 geo2_mx2005

merge m:1 geo2_mx2000 year month using Data_built\EMIF\Shock_EMIF_SecComm_Sanc_2.dta
drop if _m==2 // not all municipalities covered in each round...   
drop _m

gen anyreturn_3m=1 if return_3m>0 & return_3m!=.
recode anyreturn .=0 if return_3m!=.
gen anymigrant_3m=1 if migr_3m>0 & migr_3m!=.
recode anymigrant .=0 if migr_3m!=.

save Data_built\ENOE\ENOE_migr_shock_by_quarter.dta, replace

**************************
