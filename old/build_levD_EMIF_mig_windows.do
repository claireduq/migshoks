

if "`c(username)'"=="gehrk001" {
	cap cd "C:\Users\gehrk001\Dropbox\MigrationShocks\"
}

if "`c(username)'"=="Claire" {
	cap cd "C:\Users\Claire\Dropbox\MigrationShocks\"
}


**************************************************
use Data_built\EMIF\Shock_EMIF_SecComm_Sanc_1.dta, replace

keep year geo2_mx2000 month sc_shock migr_share migwdest
gen modate = ym(year, month) 

sort geo2_mx2000 modate
*November 2008 is start of rollout
*get average of sc_shock for a municipality between nov2008 and may2010

keep if modate >=586 
keep if modate<=604

sort geo2_mx2000
by geo2_mx2000: egen avg_treat0811_0510=mean(sc_shock)

keep avg_treat0811_0510 geo2_mx2000 migr_share migwdest
duplicates drop

rename avg_treat0811_0510 avg_treat_1

save Data_built\EMIF\avg_treat0811_0510_1.dta, replace

forvalues i=2/4{

use Data_built\EMIF\Shock_EMIF_SecComm_Sanc_`i'.dta, replace

keep year geo2_mx2000 month sc_shock migr_share migwdest
gen modate = ym(year, month) 

sort geo2_mx2000 modate
*November 2008 is start of rollout
*get average of sc_shock for a municipality between nov2008 and may2010

keep if modate >=586 
keep if modate<=604

sort geo2_mx2000
by geo2_mx2000: egen avg_treat0811_0510=mean(sc_shock)

keep avg_treat0811_0510 geo2_mx2000 
duplicates drop

rename avg_treat0811_0510 avg_treat_`i'


save Data_built\EMIF\avg_treat0811_0510_`i'.dta, replace
}
*

use Data_built\EMIF\Shock_EMIF_SecComm_Sanc_5.dta, replace

keep year geo2_mx2000 month sc_shock migr_share 
gen modate = ym(year, month) 

sort geo2_mx2000 modate
*November 2008 is start of rollout
*get average of sc_shock for a municipality between nov2008 and may2010

keep if modate >=586 
keep if modate<=604

sort geo2_mx2000
by geo2_mx2000: egen avg_treat0811_0510=mean(sc_shock)

keep avg_treat0811_0510 geo2_mx2000 migr_share 
duplicates drop

rename avg_treat0811_0510 avg_treat_5

save Data_built\EMIF\avg_treat0811_0510_5.dta, replace

merge 1:1 geo2_mx2000 using Data_built\EMIF\avg_treat0811_0510_1.dta
drop _m
merge 1:1 geo2_mx2000 using Data_built\EMIF\avg_treat0811_0510_2.dta
drop _m
merge 1:1 geo2_mx2000 using Data_built\EMIF\avg_treat0811_0510_3.dta
drop _m
merge 1:1 geo2_mx2000 using Data_built\EMIF\avg_treat0811_0510_4.dta
drop _m

save Data_built\EMIF\EMIF_migr_shock_avg0811_0510.dta, replace
