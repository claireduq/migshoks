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
drop _m

gen anyreturn_3m=1 if return_3m>0 & return_3m!=.
recode anyreturn .=0 if return_3m!=.
gen anymigrant_3m=1 if migr_3m>0 & migr_3m!=.
recode anymigrant .=0 if migr_3m!=.
keep if year <=2014

save Data_built\ENOE\ENOE_migr_shock.dta, replace



**************************
*At muni quarter level


use Data_built\ENOE\migrHhENOE, clear
keep if year <=2014
rename d_mes month 
ta month 
gen geo2_mx2015 = ent*1000 + mun
drop year
ta d_anio 
rename d_anio year
replace year = 2000+ year


gen file_time_yq=yq(year,quarter)
format file_time_yq %tq

merge m:1 geo2_mx2015 using Data_built\Claves\Claves_1960_2015.dta
drop if _m==2
drop _m geo1_mx2015 geo1_mx2010 geo2_mx2010 geo1_mx2005 geo2_mx2005

sort file_time_yq geo2_mx2000
by file_time_yq geo2_mx2000: egen sum_return=total(return_3m)

keep  file_time_yq geo1_mx2000  geo2_mx2000 sum_return
duplicates drop
isid   file_time_yq  geo2_mx2000

tempfile muniquart
save `muniquart'

use Data_built\EMIF\Shock_EMIF_SecComm_Sanc_2.dta

keep if inlist(month, 1,4,7,10)

gen quarter=.
replace quarter=1 if  month==1
replace quarter=2 if month==4
replace quarter=3 if month==7 
replace quarter=4 if month ==10


gen file_time_yq=yq(year,quarter)
format file_time_yq %tq


merge m:1 geo2_mx2000 file_time_yq using `muniquart'
drop if _m==2 // not all municipalities covered in each round...   
drop _m


save Data_built\ENOE\ENOE_migr_shock_muni_quart.dta, replace
