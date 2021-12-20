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
*files of type: Data_built\ENOE\educT`x'`y'.dta
*Data_built\ENOE\educENOE.dta
*Data_built\ENOE\ENOE_educ_shock.dta


*********************************************************************************
* Sociodemographico
* birth order, number of siblings (older and younger), gender, migration history

* 1a, 2a, 3a, 4a 
foreach x in 1 2 3 4 {
foreach y in 05 06 07 08 09 10 11 12 13 14 15 16 17 18 {
use Data_raw\ENOE\SDEMT`x'`y'.dta, clear
keep if r_def==00 // keep only those obs with completed survey
gen parent = 1 if par_c>100 & par_c<300
bysort cd_a ent con v_sel n_hog h_mud: egen parent_hh = count(parent) 
drop parent
gen migr =1 if c_res==2 & cs_ad_des==3 // identifies hh members who were in hh 3 months previously and now in the US 
bysort cd_a ent con v_sel n_hog h_mud: egen migr_3m = count(migr) 
drop migr
gen ret=1 if c_res==3 & cs_nr_ori==3 // identifies hh members who were in the US 3 months previously and now in the hh
bysort cd_a ent con v_sel n_hog h_mud: egen return_3m = count(ret) 
drop ret
ren cs_p17 enroll 
recode enroll 9=. 2=0

drop if c_res==2	
bysort cd_a ent con v_sel n_hog h_mud: egen inc_hh = total(ingocup) 
bysort cd_a ent con v_sel n_hog h_mud: gen hhsize=_N

keep if eda>=6 & eda<=25
gen cohab=1 if par_c>300 & par_c<400
recode cohab .=0
replace parent_hh=0 if cohab==0
replace cohab=0 if parent_hh==0

** construct birth order variable
gen hijo=1 if par_c >=300 & par_c<400
sort cd_a ent con v_sel n_hog h_mud nac_anio
bysort  cd_a ent con v_sel n_hog h_mud hijo: gen birthorder=_n
replace birthorder=. if hijo==.
bysort cd_a ent con v_sel n_hog h_mud hijo: gen cohabsib=_N
replace cohabsib=. if hijo==.
recode anios_esc 99=. 
gen yearsschool =.
recode cs_p13_2 99=. 
recode cs_p13_1 99=. 9=0
replace yearsschool = cs_p13_2 if cs_p13_1==1  
replace yearsschool = cs_p13_2 if cs_p13_1==2  
replace yearsschool = 6 + cs_p13_2 if cs_p13_1==3  
replace yearsschool = 9 + cs_p13_2 if cs_p13_1==4  
replace yearsschool = 9 + cs_p13_2 if cs_p13_1==5  
replace yearsschool = 9 + cs_p13_2 if cs_p13_1==6  
replace yearsschool = 12 + cs_p13_2 if cs_p13_1==7  
replace yearsschool = 16 + cs_p13_2 if cs_p13_1==8  
replace yearsschool = 18 + cs_p13_2 if cs_p13_1==9

keep loc mun est est_d ageb t_loc cd_a ent con upm d_sem n_pro_viv v_sel n_hog ///
	h_mud n_ent per n_ren return migr sex eda enroll anios_esc hrsocup ingocup ///
	ing_x_hrs inc_hh c_res hhsize cohabsib birthorder par_c n_ent cohab parent_hh ur fac yearsschool
	
merge m:1 cd_a ent con v_sel n_hog h_mud using Data_built\ENOE\HogarT`x'`y'.dta // not all hh have children in relevant age group
drop if _merge==2

keep loc mun est est_d ageb t_loc cd_a ent con upm d_sem n_pro_viv v_sel n_hog ur ///
	h_mud n_ent per n_ren return migr sex eda enroll anios_esc hrsocup ingocup fac ///
	ing_x_hrs inc_hh c_res hhsize cohabsib birthorder par_c d_dia d_mes d_anio n_ent cohab parent_hh yearsschool
	
save Data_built\ENOE\educT`x'`y'.dta, replace
}
}	

*********************************************************************************
* Final changes
clear 
gen year=.
save Data_built\ENOE\educENOE.dta, replace

foreach x in 1 2 3 4 {
foreach y in 05 06 07 08 09 10 11 12 13 14 15 16 17 18 {
use Data_built\ENOE\educT`x'`y'.dta, clear
gen year = 2000 + `y'
gen quarter = `x'
append using Data_built\ENOE\educENOE.dta
save Data_built\ENOE\educENOE.dta, replace
}
}

use Data_built\ENOE\educENOE.dta, clear
gen time_yq=yq(year,quarter)
format time_yq %tq

ta n_ent migr_3m 
replace migr_3m =. if n_ent==1
replace return_3m = . if n_ent==1
recode parent_hh 4=2 3=2

label var parent_hh "No of parents present"
label var cohab "Lives with parents"
label var migr_3m "number of hh members who migrated in last 3 months (not available for hh in 1. round)" 
label var return_3m "number of hh members who returned in last 3 months (not available for hh in 1. round)" 

save Data_built\ENOE\educENOE.dta, replace

**********

use Data_built\ENOE\educENOE, clear
gen geo2_mx2015 = ent*1000 + mun

rename d_mes month 
ta month 
drop year
ta d_anio 
rename d_anio year
replace year = 2000+ year
keep if year <=2014
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

save Data_built\ENOE\ENOE_educ_shock.dta, replace
