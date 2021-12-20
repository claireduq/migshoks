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
 sleep 100
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

	sleep 100
save Data_built\ENOE\charact`x'`y'.dta, replace

}
}
*



*getting deportation question from the extended questionair.
*it is also asked in the basic questionairs.  (presumably would generate a lot of repeates? )

*so far only using extended. 
clear
gen per=.
save Data_built\ENOE\rep_dep.dta, replace

* 2013, 2014, 2015, 16, 17, 18
foreach y in 13 14 15 16 17 18 {
use Data_raw\ENOE\COE1T1`y'.dta, clear 
merge 1:1 n_ren n_ent n_hog n_pro_viv upm per ent d_sem cd_a using Data_raw\ENOE\COE2T1`y'.dta
keep if r_def==00

gen rep_dep=0
replace rep_dep=1 if p9a==6

*time of deportation
gen dep_yr=.
replace dep_yr=p9f_anio if rep_dep==1
replace dep_yr=. if dep_yr==9999

gen dep_mo=.
replace dep_mo=p9f_mes if rep_dep==1
replace dep_mo=. if dep_mo==99

gen year_only=1 if dep_yr!=. & dep_mo==.

egen dep_time=concat(dep_yr dep_mo ), punct(" ")

*could use final 9f question to check consistency if needed.



keep con v_sel h_mud n_ren n_ent n_hog n_pro_viv upm per ent d_sem cd_a eda rep_dep dep_yr dep_mo year_only dep_time 
gen quarter =1
gen year = 20`y'
merge 1:1 cd_a ent con v_sel n_hog h_mud n_ren using Data_built\ENOE\charact1`y'.dta
*merge failures mostlt kids 
*tab eda if _m==2
drop if _merge==2
drop _merge
append using Data_built\ENOE\rep_dep.dta
drop if per==.
sleep 100
save Data_built\ENOE\rep_dep.dta, replace
}
*



* 2010, 2012, 2012
foreach y in 10 11 12 {
use Data_raw\ENOE\COE1T1`y'.dta, clear 
merge 1:1 n_ren n_ent n_hog n_pro_viv upm per ent d_sem cd_a using Data_raw\ENOE\COE2T1`y'.dta
keep if r_def==00

gen rep_dep=0
replace rep_dep=1 if p9a==6

*time of deportation
gen dep_yr=.
replace dep_yr=p9f_anio if rep_dep==1
replace dep_yr=. if dep_yr==9999

gen dep_mo=.
replace dep_mo=p9f_mes if rep_dep==1
replace dep_mo=. if dep_mo==99

gen year_only=1 if dep_yr!=. & dep_mo==.

egen dep_time=concat(dep_yr dep_mo ), punct(" ")

*could use final 9f question to check consistency if needed.




keep con v_sel h_mud n_ren n_ent n_hog n_pro_viv upm per ent d_sem cd_a eda rep_dep dep_yr dep_mo year_only dep_time 
gen quarter =1
gen year = 20`y'
merge 1:1 cd_a ent con v_sel n_hog h_mud n_ren using Data_built\ENOE\charact1`y'.dta
*merge failures mostlt kids 
*tab eda if _m==2
drop if _merge==2
drop _merge
append using Data_built\ENOE\rep_dep.dta
drop if per==.
sleep 100
save Data_built\ENOE\rep_dep.dta, replace
}
*


* 2006 2007 2008 (2nd qurter)
foreach y in 206 207 208 {
use Data_raw\ENOE\COE1T`y'.dta, clear 
merge 1:1 n_ren n_ent n_hog n_pro_viv upm per ent d_sem cd_a using Data_raw\ENOE\COE2T`y'.dta
keep if r_def==00

gen rep_dep=0
replace rep_dep=1 if p9a==6

*time of deportation
gen dep_yr=.
replace dep_yr=p9f_anio if rep_dep==1
replace dep_yr=. if dep_yr==9999

gen dep_mo=.
replace dep_mo=p9f_mes if rep_dep==1
replace dep_mo=. if dep_mo==99

gen year_only=1 if dep_yr!=. & dep_mo==.

egen dep_time=concat(dep_yr dep_mo ), punct(" ")

*could use final 9f question to check consistency if needed.



keep con v_sel h_mud n_ren n_ent n_hog n_pro_viv upm per ent d_sem cd_a eda rep_dep dep_yr dep_mo year_only dep_time 
gen quarter =1
local z=`y'-200
gen year = 200`z'
merge 1:1 cd_a ent con v_sel n_hog h_mud n_ren using Data_built\ENOE\charact`y'.dta
*merge failures mostlt kids 
*tab eda if _m==2
drop if _merge==2
drop _merge
append using Data_built\ENOE\rep_dep.dta
drop if per==.
sleep 100
save Data_built\ENOE\rep_dep.dta, replace
}
*


* 2009 (1st quarter)
foreach y in 109{

use Data_raw\ENOE\COE1T`y'.dta, clear 
merge 1:1 n_ren n_ent n_hog n_pro_viv upm per ent d_sem cd_a using Data_raw\ENOE\COE2T`y'.dta
keep if r_def==00

gen rep_dep=0
replace rep_dep=1 if p9a==6

*time of deportation
gen dep_yr=.
replace dep_yr=p9f_anio if rep_dep==1
replace dep_yr=. if dep_yr==9999

gen dep_mo=.
replace dep_mo=p9f_mes if rep_dep==1
replace dep_mo=. if dep_mo==99

gen year_only=1 if dep_yr!=. & dep_mo==.

egen dep_time=concat(dep_yr dep_mo ), punct(" ")

*could use final 9f question to check consistency if needed.



keep con v_sel h_mud n_ren n_ent n_hog n_pro_viv upm per ent d_sem cd_a eda rep_dep dep_yr dep_mo year_only dep_time 
gen quarter =1
local z=`y'-100
gen year = 200`z'
merge 1:1 cd_a ent con v_sel n_hog h_mud n_ren using Data_built\ENOE\charact`y'.dta
*merge failures mostlt kids 
*tab eda if _m==2
drop if _merge==2
drop _merge
append using Data_built\ENOE\rep_dep.dta
drop if per==.
sleep 100
save Data_built\ENOE\rep_dep.dta, replace
}
*

******************************************************************************



tab2 dep_yr d_anio

gen geo2_mx2015 = ent*1000 + mun

rename dep_mo month 
ta month 

rename year int_yr
rename dep_yr year
keep if year <=2014
keep if year >=2005

tab2 int_yr year


merge m:1 geo2_mx2015 using Data_built\Claves\Claves_1960_2015.dta
drop if _m==2 // not all municipalities coevered in any round? 
drop _m geo1_mx2015 geo1_mx2010 geo2_mx2010 geo1_mx2005 geo2_mx2005

save Data_built\ENOE\ENOE_deportation_shock.dta, replace

clear
use  Data_built\Claves\Claves_1960_2015.dta
keep geo1_mx2000 geo2_mx2000
duplicates drop

merge 1:m  geo2_mx2000 using Data_built\EMIF\Shock_EMIF_SecComm_Sanc_2.dta
drop _m
tempfile seccom
save `seccom'




*deportations
clear
use Data_built\ENOE\ENOE_deportation_shock.dta

keep if month !=.

sort year month geo2_mx2000
by year month geo2_mx2000: gen sum_rep_dep=_N

keep sum_rep_dep year  month   geo2_mx2000  
duplicates drop


merge m:1 geo2_mx2000 year month using `seccom'
*aggegating to get number of reported deportation in a muni for each year month


*putting 0 if no reports 
replace sum_rep_dep=0 if sum_rep_dep==.
gen edate = mdy(1, 1, year)

save Data_built\ENOE\ENOE_deportation_shock_ym.dta, replace


clear
use Data_built\ENOE\ENOE_deportation_shock.dta

sort year geo2_mx2000
by year  geo2_mx2000: gen sum_rep_dep_yr=_N

keep sum_rep_dep_yr year  geo2_mx2000  
duplicates drop

tempfile sum_rep_dep_yr
save `sum_rep_dep_yr'

*get secure community shocks on Jan 1st of year to merge by year
use `seccom'
keep if month==1

merge 1:m geo2_mx2000 year using `sum_rep_dep_yr'


keep sum_rep_dep_yr year  geo1_mx2000 geo2_mx2000 sc_shock2 f24_sc2 f12_sc2 l12_sc2 l24_sc2 l36_sc2 f36_sc2 migr_share
duplicates drop
*putting 0 if no reports 
replace sum_rep_dep_yr=0 if sum_rep_dep_yr==.
gen edate = mdy(1, 1, year)

save Data_built\ENOE\ENOE_deportation_shock_y.dta, replace

**********************_windows months

clear
use Data_built\EMIF\EMIF_migr_shock_avg0811_0510.dta

forval i=2005/2014{
gen year_`i'=.
}
*

reshape long year_  , i(geo2_mx2000) j(year)  
drop year_


forval i=1/12{
gen mo_`i'=.
}
*
reshape long mo_  , i(geo2_mx2000 year) j(month)  
drop mo_

merge 1:m geo2_mx2000 year month using Data_built\ENOE\ENOE_deportation_shock.dta
drop if month==.

gen ones=1
replace ones=0 if _m!=3

gen weighted_rep_dep=ones*fac
replace weighted_rep_dep=0 if weighted_rep_dep==.

sort geo2_mx2000 year month 
by geo2_mx2000 year month: egen sum_rep_dep=total(ones)
by geo2_mx2000 year month: egen weighted_sum_rep_dep=total( weighted_rep_dep)


keep sum_rep_dep  weighted_sum_rep_dep year month  geo2_mx2000  migr_share avg_treat0811_0510 geo1_mx2000
duplicates drop


keep if year <=2014
keep if year >=2005


gen modate = ym(year, month)



drop if modate>=586 & modate<=604
replace avg_treat0811_0510=0 if modate<=585


*putting 0 if no reports 
replace sum_rep_dep=0 if sum_rep_dep==.

save Data_built\ENOE\ENOE_deportation_shock_months_windows.dta, replace



**********************_windows Years


clear
use Data_built\ENOE\ENOE_deportation_shock.dta


sort year geo2_mx2000
by year  geo2_mx2000: gen sum_rep_dep_yr=_N

keep sum_rep_dep_yr year  geo2_mx2000  geo1_mx2000 
duplicates drop

merge m:1 geo2_mx2000 using Data_built\EMIF\EMIF_migr_shock_avg0811_0510.dta
drop if _m!=3 // not all municipalities covered in each round...   
drop _m


keep if year <=2014
keep if year >=2005
drop if year==2009

replace avg_treat0811_0510=0 if year<=2009

save Data_built\ENOE\ENOE_deport_shock_windows.dta, replace

stop
