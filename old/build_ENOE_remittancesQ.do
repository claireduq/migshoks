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
*files of type: Data_built\ENOE\educT`x'`y'.dta
*Data_built\ENOE\educENOE.dta
*Data_built\ENOE\ENOE_educ_shock.dta


*********************************************************************************
*********************************************************************************

* Sociodemographico
* birth order, number of siblings (older and younger), gender, migration history
foreach x in 1 2 3 4 {
foreach y in 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 {
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

keep if r_def==00 
bysort cd_a ent con v_sel n_hog h_mud: gen hhsize=_N
recode anios_esc 99=.

keep loc mun est est_d ageb t_loc cd_a ent con upm d_sem n_pro_viv v_sel n_hog ///
	h_mud n_ent per n_ren  sex eda anios_esc  ///
	 c_res hhsize par_c n_ent fac
	
	
	
merge m:1 cd_a ent con v_sel n_hog h_mud using Data_raw\ENOE\HOGT`x'`y'.dta
drop if _merge==2


keep loc mun est est_d ageb t_loc cd_a ent con upm d_sem n_pro_viv v_sel n_hog ///
	h_mud n_ent per n_ren sex eda  anios_esc  ///
	c_res hhsize par_c d_dia d_mes d_anio n_ent fac

	
save Data_built\ENOE\charact`x'`y'.dta, replace

}
}
*



*getting remittences question from the extended questionair.
*it is also asked in the basic questionairs.  (presumably would generate a lot of repeates? )

*so far only using extended. 
clear
gen per=.
save Data_built\ENOE\rep_remit.dta, replace

* 2013, 2014, 2015, 16, 17, 18
foreach y in 13 14 15 16 17 18 {
use Data_raw\ENOE\COE1T1`y'.dta, clear 
merge 1:1 n_ren n_ent n_hog n_pro_viv upm per ent d_sem cd_a using Data_raw\ENOE\COE2T1`y'.dta
keep if r_def==00


*get remitence question
gen got_remit=0
replace got_remit=1 if p10a1==1

*get plans to cross border Q
gen unemp_border_cross=.
replace unemp_border_cross=0 if p2_2==2
replace unemp_border_cross=0 if p2_3==3
replace unemp_border_cross=1 if p2_1==1

gen newjob_border_cross=0
replace newjob_border_cross=1 if p8_1==1
replace newjob_border_cross=. if p8_4==4


keep con v_sel h_mud n_ren n_ent n_hog n_pro_viv upm per ent d_sem cd_a eda unemp_border_cross newjob_border_cross got_remit
gen quarter =1
gen year = 20`y'
merge 1:1 cd_a ent con v_sel n_hog h_mud n_ren using Data_built\ENOE\charact1`y'.dta
*merge failures mostlt kids 
*tab eda if _m==2
drop if _merge==2
drop _merge
append using Data_built\ENOE\rep_remit.dta
drop if per==.
save Data_built\ENOE\rep_remit.dta, replace
}
*



* 2010, 2012, 2012
foreach y in 10 11 12 {
use Data_raw\ENOE\COE1T1`y'.dta, clear 
merge 1:1 n_ren n_ent n_hog n_pro_viv upm per ent d_sem cd_a using Data_raw\ENOE\COE2T1`y'.dta
keep if r_def==00



*get remitence question
gen got_remit=0
replace got_remit=1 if p10a1==1

*get plans to cross border Q
gen unemp_border_cross=.
replace unemp_border_cross=0 if p2_2==2
replace unemp_border_cross=0 if p2_3==3
replace unemp_border_cross=1 if p2_1==1

gen newjob_border_cross=0
replace newjob_border_cross=1 if p8_1==1
replace newjob_border_cross=. if p8_4==4


keep con v_sel h_mud n_ren n_ent n_hog n_pro_viv upm per ent d_sem cd_a eda unemp_border_cross newjob_border_cross got_remit
gen quarter =1
gen year = 20`y'
merge 1:1 cd_a ent con v_sel n_hog h_mud n_ren using Data_built\ENOE\charact1`y'.dta
*merge failures mostlt kids 
*tab eda if _m==2
drop if _merge==2
drop _merge
append using Data_built\ENOE\rep_remit.dta
drop if per==.
save Data_built\ENOE\rep_remit.dta, replace
}
*


* 2006 2007 2008 (2nd qurter)
foreach y in 206 207 208 {
use Data_raw\ENOE\COE1T`y'.dta, clear 
merge 1:1 n_ren n_ent n_hog n_pro_viv upm per ent d_sem cd_a using Data_raw\ENOE\COE2T`y'.dta
keep if r_def==00



*get remitence question
gen got_remit=0
replace got_remit=1 if p10a1==1

*get plans to cross border Q
gen unemp_border_cross=.
replace unemp_border_cross=0 if p2_2==2
replace unemp_border_cross=0 if p2_3==3
replace unemp_border_cross=1 if p2_1==1

gen newjob_border_cross=0
replace newjob_border_cross=1 if p8_1==1
replace newjob_border_cross=. if p8_4==4


keep con v_sel h_mud n_ren n_ent n_hog n_pro_viv upm per ent d_sem cd_a eda  unemp_border_cross newjob_border_cross got_remit
gen quarter =1
local z=`y'-200
gen year = 200`z'
merge 1:1 cd_a ent con v_sel n_hog h_mud n_ren using Data_built\ENOE\charact`y'.dta
*merge failures mostlt kids 
*tab eda if _m==2
drop if _merge==2
drop _merge
append using Data_built\ENOE\rep_remit.dta
drop if per==.
save Data_built\ENOE\rep_remit.dta, replace
}
*


* 2009 (1st quarter)
foreach y in 109{

use Data_raw\ENOE\COE1T`y'.dta, clear 
merge 1:1 n_ren n_ent n_hog n_pro_viv upm per ent d_sem cd_a using Data_raw\ENOE\COE2T`y'.dta
keep if r_def==00


*get remitence question
gen got_remit=0
replace got_remit=1 if p10a1==1

*get plans to cross border Q
gen unemp_border_cross=.
replace unemp_border_cross=0 if p2_2==2
replace unemp_border_cross=0 if p2_3==3
replace unemp_border_cross=1 if p2_1==1

gen newjob_border_cross=0
replace newjob_border_cross=1 if p8_1==1
replace newjob_border_cross=. if p8_4==4

keep con v_sel h_mud n_ren n_ent n_hog n_pro_viv upm per ent d_sem cd_a eda  unemp_border_cross newjob_border_cross got_remit
gen quarter =1
local z=`y'-100
gen year = 200`z'
merge 1:1 cd_a ent con v_sel n_hog h_mud n_ren using Data_built\ENOE\charact`y'.dta
*merge failures mostlt kids 
*tab eda if _m==2
drop if _merge==2
drop _merge
append using Data_built\ENOE\rep_remit.dta
drop if per==.
save Data_built\ENOE\rep_remit.dta, replace
}
*

******************************************************************************




gen geo2_mx2015 = ent*1000 + mun

keep if year <=2014
keep if year >=2005



merge m:1 geo2_mx2015 using Data_built\Claves\Claves_1960_2015.dta
drop if _m==2 // not all municipalities coevered in any round? 
drop _m geo1_mx2015 geo1_mx2010 geo2_mx2010 geo1_mx2005 geo2_mx2005

save Data_built\ENOE\ENOE_remit_shock.dta, replace

clear
use  Data_built\Claves\Claves_1960_2015.dta
keep geo1_mx2000 geo2_mx2000
duplicates drop

merge 1:m  geo2_mx2000 using Data_built\EMIF\Shock_EMIF_SecComm_Sanc_2.dta
drop _m
tempfile seccom
save `seccom'



*remittences
clear
use Data_built\ENOE\ENOE_remit_shock.dta



bysort cd_a ent con v_sel n_hog h_mud: egen hh_remit=total(got_remit)
replace hh_remit=1 if hh_remit>0
keep hh_remit cd_a ent con v_sel n_hog h_mud d_anio d_mes  geo2_mx2000  year
duplicates drop
isid cd_a ent con v_sel n_hog h_mud d_anio d_mes 



rename d_mes month

gen edate = mdy(month, 1, year)


merge m:1 geo2_mx2000 year month using `seccom'


save Data_built\ENOE\ENOE_remittances_shock.dta, replace


********************-windows construction
clear
use Data_built\ENOE\ENOE_remit_shock.dta

bysort cd_a ent con v_sel n_hog h_mud: egen hh_remit=total(got_remit)
replace hh_remit=1 if hh_remit>0
keep hh_remit cd_a ent con v_sel n_hog h_mud d_anio d_mes  geo2_mx2000  year fac  geo1_mx2000
duplicates drop
isid cd_a ent con v_sel n_hog h_mud d_anio d_mes 



merge m:1 geo2_mx2000 using Data_built\EMIF\EMIF_migr_shock_avg0811_0510.dta
drop if _m!=3 // not all municipalities covered in each round...   
drop _m

gen month=d_mes 


keep if year <=2014
keep if year >=2005

gen modate = ym(year, month)

rename month int_month
rename year int_year

drop if modate>=586 & modate<=604
replace avg_treat0811_0510=0 if modate<=585

save Data_built\ENOE\ENOE_remit_shock_windows.dta, replace


stop
