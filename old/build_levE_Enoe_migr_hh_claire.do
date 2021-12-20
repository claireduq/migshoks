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

gen ad_f =1 if eda>=12 & eda<=16 & sex==2
gen ad_m =1 if eda>=12 & eda<=16 & sex==1
gen ya_f =1 if eda>=17 & eda<=21 & sex==2
gen ya_m =1 if eda>=17 & eda<=21 & sex==1

bysort cd_a ent con v_sel n_hog h_mud: egen adolescent_f = count(ad_f)
bysort cd_a ent con v_sel n_hog h_mud: egen adolescent_m = count(ad_m)
bysort cd_a ent con v_sel n_hog h_mud: egen youngadult_f = count(ya_f)
bysort cd_a ent con v_sel n_hog h_mud: egen youngadult_m = count(ya_m)

drop if c_res==2	
bysort cd_a ent con v_sel n_hog h_mud: egen inc_hh = total(ingocup) 
bysort cd_a ent con v_sel n_hog h_mud: gen hhsize=_N

*make at household level
keep cd_a ent con v_sel n_hog h_mud n_ent migr_3m return_3m inc_hh hhsize adolescent_* youngadult_* 
duplicates drop

merge 1:1 cd_a ent con v_sel n_hog h_mud using Data_built\ENOE\HogarT`x'`y'.dta 
drop if _merge==2
	
save Data_built\ENOE\migrHhT`x'`y'.dta, replace
sleep 100
}
}	

*********************************************************************************

clear 
gen file_year=.
save Data_built\ENOE\migrHhENOE.dta, replace

foreach x in 1 2 3 4 {
foreach y in 05 06 07 08 09 10 11 12 13 14 15 16 17 18 {
use Data_built\ENOE\migrHhT`x'`y'.dta, clear
gen file_year = 2000 + `y'
gen file_quarter = `x'
append using Data_built\ENOE\migrHhENOE.dta
save Data_built\ENOE\migrHhENOE.dta, replace
sleep 200
}
}

use Data_built\ENOE\migrHhENOE.dta, clear
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
label var adolescent_f "number of female adolescents in household (age 12-16)"
label var adolescent_m "number of male adolescents in household (age 12-16)"
label var youngadult_f "number of female young adults in household (age 17-21)"
label var youngadult_m "number of male young adults in household (age 17-21)"

save Data_built\ENOE\migrHhENOE.dta, replace

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

merge m:1 geo2_mx2000 year month using Data_built\EMIF\Shock_EMIF_SecComm_Sanc_1.dta
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

merge m:1 geo2_mx2000 year month using Data_built\EMIF\Shock_EMIF_SecComm_Sanc_5.dta
drop if _m==2 // not all municipalities covered in each round...   
drop _m

rename month int_month
rename year int_year
drop if int_year==2015

gen anyreturn_3m=1 if return_3m>0 & return_3m!=.
recode anyreturn .=0 if return_3m!=.
gen anymigrant_3m=1 if migr_3m>0 & migr_3m!=.
recode anymigrant .=0 if migr_3m!=.
label var anymigrant_3m "any hh member migrated in last 3 months (not available for hh in 1. round)" 
label var anyreturn_3m "any hh member returned in last 3 months (not available for hh in 1. round)" 

save Data_built\ENOE\ENOE_migr_shock.dta, replace


