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


clear
gen per=.
save Data_built\ENOE\basics.dta, replace


* 1a, 2a, 3a, 4a 
foreach x in 1 2 3 4 {
foreach y in 05 06 07 08 09 10 11 12 13 14 15 16 17 18 {

use Data_raw\ENOE\SDEMT`x'`y'.dta, clear

keep if r_def==00 
*has migrated
gen migrated =1 if c_res==2 & cs_ad_des==3 
replace migrated=0 if migrated==.

gen returned=1 if c_res==3 & cs_nr_ori==3
replace returned=0 if returned==. & n_ent!=1

gen ret=1 if c_res==3 & cs_nr_ori==3 


bysort cd_a ent con v_sel n_hog h_mud: gen hhsize=_N
recode anios_esc 99=.

keep loc mun est est_d ageb t_loc cd_a ent con upm d_sem n_pro_viv v_sel n_hog ///
	h_mud n_ent per n_ren  sex eda anios_esc  returned migrated ///
	 c_res hhsize par_c n_ent fac
	
	
	
merge m:1 cd_a ent con v_sel n_hog h_mud using Data_raw\ENOE\HOGT`x'`y'.dta
drop if _merge==2


keep loc mun est est_d ageb t_loc cd_a ent con upm d_sem n_pro_viv v_sel n_hog ///
	h_mud n_ent per n_ren sex eda  anios_esc returned migrated  ///
	c_res hhsize par_c d_dia d_mes d_anio n_ent fac
	
gen file_quarter =`x'
gen file_year = 20`y'

append using Data_built\ENOE\basics.dta
save Data_built\ENOE\basics.dta, replace

}
}
*


egen hh_id=concat(cd_a ent con v_sel n_hog h_mud), punct(_)
tostring per, gen(per_st)

gen quart=substr(per_st,1,1)
gen yr=substr(per_st,2,2)

egen yr_quart=concat(yr quart)
destring yr_quart, replace


sort hh_id yr_quart 
gen first_con=yr_quart if n_ent==1
replace first_con=yr_quart-1 if n_ent==2 & inlist(quart,"2","3","4")
replace first_con=yr_quart-2 if n_ent==3 & inlist(quart,"3","4")
replace first_con=yr_quart-3 if n_ent==4 & inlist(quart,"4")
replace first_con=yr_quart-10 if n_ent==5
replace first_con=yr_quart-9 if n_ent==4 & inlist(quart,"1","2","3")
replace first_con=yr_quart-8 if n_ent==3 & inlist(quart,"1","2")
replace first_con=yr_quart-7 if n_ent==2 & inlist(quart,"1")

egen hh_id2=concat(hh_id first_con)
replace hh_id=hh_id2
drop hh_id2

sort hh_id n_ent
egen indiv_id=concat(hh_id n_ren), punct(_)
bys indiv_id: gen obscount=_N

by indiv_id: egen evermig=max(migrated)

by indiv_id: egen everret=max(returned)

gen wavemig=n_ent if migrated==1
by indiv_id: egen migwave=max(wavemig)

gen waveret=n_ent if returned==1
by indiv_id: egen retwave=max(waveret)
drop wavemig waveret

by indiv_id: egen lastwave=max(n_ent)

gen indiv_is_obs=1 if sex!=.
replace indiv_is_obs=0 if indiv_is_obs==.


gen leftandback=1 if migwave<n_ent & indiv_is_obs==1
*only a few instances where this happens so not going to worry about this. 

gen shorthome=1 if migwave>retwave 
gen shorthomereturn=1 if returned==1 & shorthome==1 
gen shorthomedepart=1 if migrated==1 & shorthome==1 
replace shorthome=0 if shorthome==.
replace shorthomereturn=0 if shorthomereturn==.
replace shorthomedepart=0 if shorthomedepart==.


gen shortaway=1 if migwave<retwave 
gen shortawaydepart=1 if migrated==1 & shortaway==1 
gen shortawayreturn=1 if returned==1 & shortaway==1 
replace shortaway=0 if shortaway==.
replace shortawayreturn=0 if shortawayreturn==.
replace shortawaydepart=0 if shortawaydepart==.

save Data_built\ENOE\basics.dta, replace

*isid cd_a ent con v_sel n_hog h_mud n_ren file_quarter file_year

*______________________________________________________________
*getting migration question


clear
gen per=.
save Data_built\ENOE\rep_retplans1.dta, replace

foreach x in 1 2 3 4 {
foreach y in 06 07 08 09 10 11 12 13 14 15 16 17 18 {
*local x=1
*local y="06"

use Data_raw\ENOE\COE1T`x'`y'.dta, clear 


*get plans to cross border Q
gen unemp_border_cross=.
replace unemp_border_cross=0 if p2_2==2
replace unemp_border_cross=0 if p2_3==3
replace unemp_border_cross=1 if p2_1==1


keep con r_def v_sel h_mud n_ren n_ent n_hog n_pro_viv upm per ent d_sem cd_a eda unemp_border_cross 
gen file_quarter =`x'
gen file_year = 20`y'

append using Data_built\ENOE\rep_retplans1.dta
save Data_built\ENOE\rep_retplans1.dta, replace
}
}
*
*isid cd_a ent con v_sel n_hog h_mud n_ren file_quarter file_year


clear
gen per=.
save Data_built\ENOE\rep_retplans2.dta, replace

foreach x in 1 2 3 4 {
foreach y in 06 07 08 09 10 11 12 13 14 15 16 17 18 {

use Data_raw\ENOE\COE2T`x'`y'.dta, clear 


*get plans to cross border Q
gen newjob_border_cross=0
replace newjob_border_cross=1 if p8_1==1
replace newjob_border_cross=. if p8_4==4


keep con v_sel h_mud n_ren n_ent n_hog n_pro_viv upm per ent d_sem cd_a eda newjob_border_cross 
gen file_quarter =`x'
gen file_year = 20`y'

append using Data_built\ENOE\rep_retplans2.dta
save Data_built\ENOE\rep_retplans2.dta, replace
}
}
*
*isid cd_a ent con v_sel n_hog h_mud n_ren file_quarter file_year



merge 1:1 cd_a ent con v_sel n_hog h_mud n_ren file_quarter file_year using Data_built\ENOE\rep_retplans1.dta
drop _m
merge 1:1 cd_a ent con v_sel n_hog h_mud n_ren file_quarter file_year using Data_built\ENOE\basics.dta
*merge failures due to incomplete interviews. Droping them.
drop if r_def==.
drop _m
save Data_built\ENOE\rep_retplans.dta, replace


*******

gen geo2_mx2015 = ent*1000 + mun

keep if file_year <=2014
keep if file_year >=2005



merge m:1 geo2_mx2015 using Data_built\Claves\Claves_1960_2015.dta
drop if _m==2 // not all municipalities coevered in any round? 
drop _m geo1_mx2015 geo1_mx2010 geo2_mx2010 geo1_mx2005 geo2_mx2005

save Data_built\ENOE\ENOE_retplans_shock.dta, replace

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
use Data_built\ENOE\ENOE_retplans_shock.dta

keep shortawaydepart shortawayreturn shorthomedepart shorthomereturn hh_id indiv_id migrated returned newjob_border_cross unemp_border_cross cd_a ent con v_sel n_hog h_mud n_ren file_quarter file_year d_anio d_mes  geo2_mx2000

rename d_mes month
gen year=d_anio+2000

gen edate = mdy(month, 1, year)


merge m:1 geo2_mx2000 year month using `seccom'
keep if _m==3
drop _m 

save Data_built\ENOE\ENOE_retplans_shock.dta, replace


*******Generate return plans _windows file. 
clear
use Data_built\ENOE\rep_retplans.dta
gen geo2_mx2015 = ent*1000 + mun

keep if file_year <=2014
keep if file_year >=2005

merge m:1 geo2_mx2015 using Data_built\Claves\Claves_1960_2015.dta
drop if _m==2 // not all municipalities coevered in any round? 
drop _m geo1_mx2015 geo1_mx2010 geo2_mx2010 geo1_mx2005 geo2_mx2005


merge m:1 geo2_mx2000 using Data_built\EMIF\EMIF_migr_shock_avg0811_0510.dta
drop if _m!=3 // not all municipalities covered in each round...   
drop _m

gen month=d_mes 
gen year=d_anio+2000

gen modate = ym(year, month)

rename month int_month
rename year int_year

drop if modate>=586 & modate<=604
replace avg_treat0811_0510=0 if modate<=585

save Data_built\ENOE\rep_retplans_windows.dta



stop
