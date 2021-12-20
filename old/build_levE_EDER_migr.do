

cd "C:\Users\gehrk001\Dropbox\MigrationShocks\" 

use Data_raw\EDER\2017\antecedentes.dta, clear
keep folioviv foliohog id_pobla factor_per
merge 1:m folioviv foliohog id_pobla  using Data_raw\EDER\2017\historiavida.dta 
drop _m

* destring variable, gen geolev2
gen curr_residence = substr(geo_eder, 4, .)
destring curr_residence, replace
gen country = substr(geo_eder, 1, 3)
gen country_tem = substr(geo_eder_t, 1, 3)
gen mun = substr(geo_eder, -3, .)

*specify initial place of residence from geo_eder
sort folioviv foliohog id_pobla anio_retro
bysort folioviv foliohog id_pobla: gen n=_n

gen geo_residence = curr_residence if n==1 & country=="700" & mun !="999"
bysort folioviv foliohog id_pobla:  carryforward geo_residence , replace
forvalues x=2/56 {
replace geo_residence = curr_residence if n==`x' & country=="700" & mun !="999" & geo_residence==.
sort folioviv foliohog id_pobla anio_retro
bysort folioviv foliohog id_pobla:  carryforward geo_residence , replace
}
bysort folioviv foliohog id_pobla: egen initial_residence = min(geo_residence)
drop if initial_residence ==. // always in US or never know municipality (982 obs)

* specify migration variable (migrant in yeat t if geo starts with 221)
gen migr_us = 1 if country=="221"
recode migr_us .=0

* add short term migration to US
replace migr_us=1 if country_tem =="221"

sort folioviv foliohog id_pobla anio_retro 
bysort folioviv foliohog id_pobla: gen migration = 1 if migr_us==1 & migr_us[_n-1]!=1
sort folioviv foliohog id_pobla anio_retro 
bysort folioviv foliohog id_pobla: gen return = 1 if migr_us==1 & migr_us[_n+1]==0
recode migration .=0
recode return .=0

* keep years 2005-2014 (only adults in 2000)
destring anio_ret edad_retro, replace
keep if anio_retr>=2005
drop if anio_retr>2014
keep if edad_retro>=15

rename initial_residence geo2_mx2017
merge m:1 geo2_mx2017 using "Data_built\Claves\Claves_1960_2017.dta"
drop if _m==2
drop _m
* collapse (sum) migr_us migration return [fw=factor_per], by(anio_retr geo1_mx2000 geo2_mx2000)
// weights are calculated to be representative at the national level, can't calculate the number of migrants like this....
rename anio_retr year
gen month =1 
merge m:1 geo2_mx2000 year month using "Data_built\EMIF\Shock_EMIF_SecComm_Sanc_2.dta"
// foreach var in migration migr_us return {
// recode `var' .=0 if _m==2
// }
drop if month!=1
drop if _m==2
drop _m
merge m:1 geo2_mx2000 using "Data_built\MexCensus\census2010_col2.dta"
drop if _m==2
drop _m
save Data_built\EDER\EDER_migr_shock.dta, replace



*gen migrants_pton = (migration*100000)/persons
log using Output\EDER_Migration_IndivByYear.txt, text replace

global fem  i.year##i.geo1_mx2000 i.geo2_mx2000 i.edad_retro

//reghdfe migration f12_sc2 f9_sc2 f6_sc2 f3_sc2 sc_shock2 l3_sc2 l6_sc2 l9_sc2 l12_sc2 l15_sc2 c.migr_share#i.year if migr_share>0 [aw=factor_per],  a($fem) cluster(geo2_mx2000)

reghdfe migration f24_sc2 migr_share  sc_shock2  l12_sc2  l24_sc2 l36_sc2 if migr_share>0 [aw=factor_per],  a($fem) cluster(geo2_mx2000)
reghdfe migration f24_sc2 migr_share  sc_shock2  l12_sc2  l24_sc2 l36_sc2 c.migr_share#i.year if migr_share>0 [aw=factor_per],  a($fem) cluster(geo2_mx2000)

reghdfe return f24_sc2 migr_share  sc_shock2  l12_sc2  l24_sc2 l36_sc2 if migr_share>0 [aw=factor_per],  a($fem) cluster(geo2_mx2000)
reghdfe return f24_sc2 migr_share  sc_shock2  l12_sc2  l24_sc2 l36_sc2 c.migr_share#i.year if migr_share>0 [aw=factor_per],  a($fem) cluster(geo2_mx2000)

reghdfe migr_us f24_sc2 migr_share sc_shock2  l12_sc2  l24_sc2 l36_sc2  if migr_share>0 [aw=factor_per],  a($fem) cluster(geo2_mx2000)
reghdfe migr_us f24_sc2 f12_sc2 sc_shock2  l12_sc2  l24_sc2 l36_sc2 c.migr_share#i.year if migr_share>0 [aw=factor_per],  a($fem) cluster(geo2_mx2000)

log close
