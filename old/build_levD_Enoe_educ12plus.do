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
keep if r_def==00 // keep only those obs with completed survey
gen migr =1 if c_res==2 & cs_ad_des==3 
bysort cd_a ent con v_sel n_hog h_mud: egen migr_3m = count(migr) 
drop migr
gen ret=1 if c_res==3 & cs_nr_ori==3
bysort cd_a ent con v_sel n_hog h_mud: egen return_3m = count(ret) 
replace migr_3m =. if n_ent==1
replace return_3m = . if n_ent==1 // can construct only for hh that were interviewed at least once before
drop ret
ren cs_p17 enroll 
recode enroll 9=. 2=0
** construct birth order variable
gen hijo=1 if par_c >=300 & par_c<400
sort cd_a ent con v_sel n_hog h_mud nac_anio
bysort  cd_a ent con v_sel n_hog h_mud hijo: gen birthorder=_n
replace birthorder=. if hijo==.
drop if c_res==2	
bysort cd_a ent con v_sel n_hog h_mud: gen hhsize=_N
bysort cd_a ent con v_sel n_hog h_mud hijo: gen cohabsib=_N
replace cohabsib=. if hijo==.
recode anios_esc 99=.


keep loc mun est est_d ageb t_loc cd_a ent con upm d_sem n_pro_viv v_sel n_hog ///
	h_mud n_ent per n_ren return migr sex eda enroll anios_esc hrsocup ingocup ///
	ing_x_hrs c_res hhsize cohabsib birthorder par_c n_ent
	
keep if eda>=12 & eda <25

merge m:1 cd_a ent con v_sel n_hog h_mud using Data_raw\ENOE\HOGT`x'`y'.dta
drop if _merge==2

keep loc mun est est_d ageb t_loc cd_a ent con upm d_sem n_pro_viv v_sel n_hog ///
	h_mud n_ent per n_ren return migr sex eda enroll anios_esc hrsocup ingocup ///
	ing_x_hrs c_res hhsize cohabsib birthorder par_c d_dia d_mes d_anio n_ent
	
rename per per1
rename c_res c_res1
*rename r_def r_def1
rename n_ent n_ent1
gen match =. 
gen migrant = . 

*link member by id in next file using  
if "`x'" == "4" {
	if "`y'" >= "05" & "`y'"<"09" {
	local z = `y'+1
	merge 1:1 cd_a ent con v_sel n_hog h_mud n_ren using Data_raw\ENOE\SDEMT10`z'.dta  
	}
	if "`y'" >= "09" {
	local z = `y'+1
	merge 1:1 cd_a ent con v_sel n_hog h_mud n_ren using Data_raw\ENOE\SDEMT1`z'.dta  
	}
}
if "`x'" == "1" | "`x'" == "2" | "`x'" == "3" {
local w = `x'+1
merge 1:1 cd_a ent con v_sel n_hog h_mud n_ren  using Data_raw\ENOE\SDEMT`w'`y'.dta  
}
cap drop if _merge==2
replace match=1 if _m==3
replace match=0 if r_def!=00
replace migrant=1 if match==1 & c_res==2 & cs_ad_des==3
recode match .=0
recode migrant .=0 if match==1
replace match=. if n_ent1==5
replace migrant=. if n_ent1==5
replace match=. if n_ent==1
replace migrant=. if n_ent==1
	
keep loc mun est est_d ageb t_loc cd_a ent con upm d_sem n_pro_viv v_sel n_hog ///
	h_mud n_ent per n_ren return migr_3m sex eda enroll anios_esc hrsocup ingocup ///
	ing_x_hrs c_res hhsize cohabsib birthorder par_c d_dia d_mes d_anio c_res1 ///
	per1 migrant match n_ent
	
save Data_built\ENOE\socioT`x'`y'.dta, replace
}
}	

***********************************************************************************
* Cuestionario de ocupacion y empleo
* lfp, employment, wages, time use

// can construct week of survey with per and d_sem variables... 
// but can also use d_dia d_mes d_anio from HogT file (date of interview)

* ampliado, cuarta y quinta version
clear
gen per=.
save Data_built\ENOE\time_use_4a.dta, replace

* 2013, 2014, 2015, 16, 17, 18
foreach y in 13 14 15 16 17 18 {

use Data_raw\ENOE\COE1T1`y'.dta, clear 
merge 1:1 n_ren n_ent n_hog n_pro_viv upm per ent d_sem cd_a using Data_raw\ENOE\COE2T1`y'.dta
keep if r_def==00
keep if eda<25

egen lfp = anymatch(p1 p1a1 p1b), v(1)
replace lfp = 1 if p1a2==2

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

keep con v_sel h_mud n_ren n_ent n_hog n_pro_viv upm per ent d_sem cd_a eda lfp ls_hrs inc_week wage logwage chores* study* ur fac
gen quarter =1
gen year = 20`y'
merge 1:1 cd_a ent con v_sel n_hog h_mud n_ren using Data_built\ENOE\socioT1`y'.dta
drop if _merge==2
drop _merge
append using Data_built\ENOE\time_use_4a.dta
drop if per==.
save Data_built\ENOE\time_use_4a.dta, replace
}


******************************************************************************
clear
gen per=.
save Data_built\ENOE\time_use_5a.dta, replace

* basico, cuarta y quinta version

foreach x in 2 3 4 {
foreach y in 13 14 15 16 17 18 {
use Data_raw\ENOE\COE1T`x'`y'.dta, clear 
merge 1:1 n_ren n_ent n_hog n_pro_viv upm per ent d_sem cd_a using Data_raw\ENOE\COE2T`x'`y'.dta
keep if r_def==00
keep if eda<25

egen lfp = anymatch(p1 p1a1 p1b), v(1)
replace lfp = 1 if p1a2==2

foreach var in p5b_mlu p5b_mma p5b_mmi p5b_mju p5b_mvi p5b_msa p5b_mdo {
replace `var'=`var'/60
}
foreach var in p5b_hlu p5b_hma p5b_hmi p5b_hju p5b_hvi p5b_hsa p5b_hdo {
recode `var' 99=. 98=.
}
egen ls_hrs = rowtotal(p5b_mlu p5b_mma p5b_mmi p5b_mju p5b_mvi p5b_msa p5b_mdo p5b_hlu p5b_hma p5b_hmi p5b_hju p5b_hvi p5b_hsa p5b_hdo), m 
gen inc_week = p6b2 if p6b1==3
replace inc_week = p6b2*7 if p6b1==4
replace inc_week = p6b2/2 if p6b1==2
replace inc_week = p6b2/4 if p6b1==1
gen wage_hr = inc_week/ls_hrs
gen logwage_hr = log(wage_hr)

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

keep con v_sel h_mud n_ren n_ent n_hog n_pro_viv upm per d_sem ent cd_a eda lfp ls_hrs inc_week wage logwage chores* study* ur fac
gen quarter =`x'
gen year = 20`y'
merge 1:1 cd_a ent con v_sel n_hog h_mud n_ren using Data_built\ENOE\socioT`x'`y'.dta
drop if _merge==2
drop _merge
append using Data_built\ENOE\time_use_5a.dta
save Data_built\ENOE\time_use_5a.dta, replace
}
}

* ampliado, 1a, 2a, 3a version
// time use only collects 6 instead of 8 categories, will have to control for this in the estimation!
clear
gen per=.
save Data_built\ENOE\time_use_1a.dta, replace

* 2005 - 2012
foreach y in 105 205 305 405 106 206 207 208 109 110 111 112 {
use Data_raw\ENOE\COE1T`y'.dta, clear 
merge 1:1 n_ren n_ent n_hog n_pro_viv v_sel con upm per ent d_sem cd_a using Data_raw\ENOE\COE2T`y'.dta
keep if r_def==00
keep if eda<25

egen lfp = anymatch(p1 p1a1 p1b), v(1)
replace lfp = 1 if p1a2==2

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

keep con v_sel h_mud n_ren n_ent n_hog n_pro_viv upm per  v_sel con  ent d_sem cd_a eda lfp ls_hrs inc_week wage logwage chores* study* ur fac
gen quarter =substr("`y'", 1, 1)
gen year = "20" + substr("`y'",2,.)
destring quarter, replace
destring year, replace
merge 1:1 cd_a ent con v_sel n_hog h_mud n_ren using Data_built\ENOE\socioT`y'.dta
drop if _merge==2
drop _merge
append using Data_built\ENOE\time_use_1a.dta
drop if per==.
save Data_built\ENOE\time_use_1a.dta, replace
sleep 200
}

***************************************
clear
gen per=.
save Data_built\ENOE\time_use_2a.dta, replace

* basico, 1a, 2a 3a version

foreach y in 306 406 107 307 407 108 308 408 209 309 409 210 310 410 211 311 411 212 312 412 {
use Data_raw\ENOE\COE1T`y'.dta, clear 
merge 1:1 n_ren n_ent n_hog n_pro_viv upm per ent d_sem cd_a using Data_raw\ENOE\COE2T`y'.dta
keep if r_def==00
keep if eda<25

egen lfp = anymatch(p1 p1a1 p1b), v(1)
replace lfp = 1 if p1a2==2

foreach var in p5b_mlu p5b_mma p5b_mmi p5b_mju p5b_mvi p5b_msa p5b_mdo {
replace `var'=`var'/60
}
foreach var in p5b_hlu p5b_hma p5b_hmi p5b_hju p5b_hvi p5b_hsa p5b_hdo {
recode `var' 99=. 98=.
}
egen ls_hrs = rowtotal(p5b_mlu p5b_mma p5b_mmi p5b_mju p5b_mvi p5b_msa p5b_mdo p5b_hlu p5b_hma p5b_hmi p5b_hju p5b_hvi p5b_hsa p5b_hdo), m 
gen inc_week = p6b2 if p6b1==3
replace inc_week = p6b2*7 if p6b1==4
replace inc_week = p6b2/2 if p6b1==2
replace inc_week = p6b2/4 if p6b1==1
gen wage_hr = inc_week/ls_hrs
gen logwage_hr = log(wage_hr)

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

keep con v_sel h_mud n_ren n_ent n_hog n_pro_viv upm per d_sem ent cd_a eda lfp ls_hrs inc_week wage logwage chores* study* ur fac
gen quarter =substr("`y'", 1, 1)
gen year = "20" + substr("`y'",2,.)
destring quarter, replace
destring year, replace
merge 1:1 cd_a ent con v_sel n_hog h_mud n_ren using Data_built\ENOE\socioT`y'.dta
drop if _merge==2
drop _merge
append using Data_built\ENOE\time_use_2a.dta
save Data_built\ENOE\time_use_2a.dta, replace
}

*********************************************************************************
* Final changes
use Data_built\ENOE\time_use_1a.dta, clear
append using Data_built\ENOE\time_use_2a.dta
append using Data_built\ENOE\time_use_4a.dta
append using Data_built\ENOE\time_use_5a.dta
label drop per
*label drop _all
gen time_yq=yq(year,quarter)
format time_yq %tq

ta n_ent migr_3m 
replace migr_3m =. if n_ent==1
replace return_3m = . if n_ent==1
replace match=. if n_ent==5
replace migrant=. if n_ent==5


gen cohab =1 if birthorder!=.
recode cohab .=0
label var cohab "Lives with parents"
label var migr_3m "number of hh members who migrated in last 3 months (not available for hh in 1. round)" 
label var return_3m "number of hh members who returned in last 3 months (not available for hh in 1. round)" 
label var migrant "Person migrates whithin three months (not available for hh in 5. round)" 

save Data_built\ENOE\time_use_all.dta, replace

*********************************************************************************

use Data_built\ENOE\time_use_all, clear
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
drop if _m==2 // not all municipalities coevered in any round? 
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

save Data_built\ENOE\ENOE_timeuse_shock.dta, replace



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
