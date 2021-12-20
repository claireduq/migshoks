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
*Data_built\EMIF\Shock_EMIF_SecComm_Sanc_3.dta


*Output Files:
*files of type:  Data_built\ENOE\migrHhT`x'`y'.dta
*Data_built\ENOE\ENOE_migr_shock.dta
*Data_built\ENOE\migrHhENOE.dta

*********************************************************************************

*********************************************************************************
* Sociodemographico
* birth order, number of siblings (older and younger), gender, migration history


/*
* 1a, 2a, 3a, 4a 
foreach x in 1 2 3 4 {
foreach y in 05 06 07 08 09 10 11 12 13 14 15 16 17 18 {
*local x="1"
*local y="05"

use Data_raw\ENOE\SDEMT`x'`y'.dta, clear

*unique identifier:  isid cd_a ent con v_sel n_hog h_mud n_ren (city state control# home house movedhouse row number)
*unique identifier: isid cd_a ent con v_sel n_hog  n_ren


keep if r_def==00 // keep only those obs with completed survey
gen migr =1 if c_res==2 & cs_ad_des==3 
bysort cd_a ent con v_sel n_hog h_mud: egen migr_3m = count(migr)

*CLAIRE: specifying those that give work or other motivation
* tried with & inlist(cs_nr_mot,1,10) to pinpoint work related returns but no difference. 
gen ret=1 if c_res==3 & cs_nr_ori==3 
bysort cd_a ent con v_sel n_hog h_mud: egen return_3m = count(ret) 

drop ret
drop migr

drop if c_res==2	
bysort cd_a ent con v_sel n_hog h_mud: egen inc_hh = total(ingocup) 
bysort cd_a ent con v_sel n_hog h_mud: gen hhsize=_N

*CLAIRE: make at household level
keep cd_a ent con v_sel n_hog h_mud n_ent migr_3m return_3m inc_hh hhsize 
duplicates drop

/*
sort cd_a ent con v_sel n_hog h_mud par_c
bysort cd_a ent con v_sel n_hog: gen count=_n
keep if count==1
drop count

keep loc mun est est_d ageb t_loc cd_a ent con upm d_sem n_pro_viv v_sel n_hog ///
	h_mud n_ent per n_ren return migr sex eda anios_esc hrsocup ingocup ///
	ing_x_hrs inc_hh c_res hhsize par_c n_ent ur fac 
*/	
merge 1:1 cd_a ent con v_sel n_hog h_mud using Data_built\ENOE\HogarT`x'`y'.dta 
drop if _merge==2
/*
keep loc mun est est_d ageb t_loc cd_a ent con upm d_sem n_pro_viv v_sel n_hog ur ///
	h_mud n_ent per n_ren return migr sex eda anios_esc hrsocup ingocup fac ///
	ing_x_hrs inc_hh c_res hhsize par_c d_dia d_mes d_anio n_ent 
	
*/	
save Data_built\ENOE\migrHhT`x'`y'_C.dta, replace
sleep 100
}
}	

*********************************************************************************

clear 
gen file_year=.
save Data_built\ENOE\migrHhENOE_C.dta, replace



foreach x in 1 2 3 4 {
foreach y in 05 06 07 08 09 10 11 12 13 14 15 16 17 18 {
use Data_built\ENOE\migrHhT`x'`y'_C.dta, clear
gen file_year = 2000 + `y'
gen file_quarter = `x'
append using Data_built\ENOE\migrHhENOE_C.dta
save Data_built\ENOE\migrHhENOE_C.dta, replace
sleep 200
}
}

use Data_built\ENOE\migrHhENOE_C.dta, clear
gen file_time_yq=yq(file_year,file_quarter)
format file_time_yq %tq

sort cd_a ent con v_sel n_hog h_mud file_year file_quarter
isid cd_a ent con v_sel n_hog h_mud file_year file_quarter

*issue: does not identify a household across time. 
*calculate starting quarter: 
gen q_start= file_time_yq-n_ent
format q_start %tq

bysort cd_a ent con v_sel n_hog h_mud q_start: gen hhobs=_N

gen id = string(cd_a) + string(ent) + string(con)+ string(v_sel) + string(n_hog)+string(h_mud)+string(q_start)

sort id n_ent


tab2 n_ent migr_3m , miss


replace migr_3m=. if n_ent==1
replace return_3m=. if n_ent==1
tab2 n_ent migr_3m , miss

label var migr_3m "number of hh members who migrated in last 3 months (not available for hh in 1. round)" 
label var return_3m "number of hh members who returned in last 3 months (not available for hh in 1. round)" 

save Data_built\ENOE\migrHhENOE_C.dta, replace
*/
**********

use Data_built\ENOE\migrHhENOE, clear
keep if file_year <=2014
rename d_mes month 
ta month 
gen geo2_mx2015 = ent*1000 + mun
ta d_anio 
rename d_anio year
replace year = 2000+ year
drop _m

merge m:1 geo2_mx2015 using Data_built\Claves\Claves_1960_2015.dta
drop if _m==2
drop _m geo1_mx2015 geo1_mx2010 geo2_mx2010 geo1_mx2005 geo2_mx2005

merge m:1 geo2_mx2000 using Data_built\EMIF\EMIF_migr_shock_avg0811_0510.dta
drop if _m!=3 // not all municipalities covered in each round...   
drop _m

gen modate = ym(year, month) 

rename month int_month
rename year int_year

drop if modate>=586 & modate<=604
forvalues i=1/5{
replace avg_treat_`i'=0 if modate<=585
}
*

gen anyreturn_3m=1 if return_3m>0 & return_3m!=.
recode anyreturn .=0 if return_3m!=.
gen anymigrant_3m=1 if migr_3m>0 & migr_3m!=.
recode anymigrant .=0 if migr_3m!=.


save Data_built\ENOE\ENOE_migr_shock_windows.dta, replace


