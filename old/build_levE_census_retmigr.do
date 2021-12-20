
*Esther
cd "C:\Users\gehrk001\Dropbox\MigrationShocks\"
global graphs "C:\Users\gehrk001\Dropbox\MigrationShocks\Output\Graphs\"

*Claire
*cd "C:\Users\Claire\Dropbox\MigrationShocks\"
*global graphs "C:\Users\Claire\Dropbox\MigrationShocks\Output\Graphs\"
************************************************************************************
*PREP:

*ssc install shp2dta

*Input files:
*Data_built\MexCensus\census2010.dta
*Data_built\Claves\Claves_1960_2010.dta

*Output files: 
*Data_built\MexCensus\MexCensus_returnmigr_shock.dta

************************************************************************************

* Migration data to be merged with other datasets
use Data_built\MexCensus\census2010, clear
merge m:1 geo2_mx2010 using Data_built\Claves\Claves_1960_2010.dta
recode mx2010a_intmigs 9=. 2=0
collapse (sum) mx2010a_migrants persons (mean) mx2010a_intmigs [fw = hhwt], by(geo2_mx2000 geo1_mx2000 year)
save Data_built\MexCensus\census2010_col2.dta, replace


use Data_built\MexCensus\census2010, clear
keep geolev2 geo2_mx2010 mx2010a_intmigs mx2010a_hhwt mx2010a_migrants serial persons hhwt
merge 1:m serial using Data_raw\MexCensus\mx2010a_migration.dta
keep if _m==3 // keeps hh with international migrants
drop _m

gen ret_yr=.
replace ret_yr=yearret  
replace ret_yr=. if ret_yr==9999

gen ret_mo=.
replace ret_mo=monthret  
replace ret_mo=. if ret_mo==99

*gen year_only=1 if dep_yr!=. & dep_mo==.

egen dep_time=concat(ret_yr ret_mo ), punct(" ")

merge m:1 geo2_mx2010 using Data_built\Claves\Claves_1960_2010.dta
drop if _m==2 // not all municipalities coevered in any round? 
drop _m  geo1_mx2010 geo2_mx2010 geo1_mx2005 geo2_mx2005
gen no_return=1 if ret_yr!=.
bysort geo2_mx2000: egen no_migrants=total(wtmig)

collapse (sum) no_return (mean) no_migrants [fw = wtmig], by(geo2_mx2000 geo1_mx2000 ret_mo ret_yr)

rename ret_mo month
rename ret_yr year

merge 1:1  geo2_mx2000 year month using Data_built\EMIF\Shock_EMIF_SecComm_Sanc_2.dta
drop if _m==1 // migrants that haven't returned
drop _m

merge m:1 geo2_mx2000 using Data_built\MexCensus\census2010_col2.dta
drop _m 
recode no_return .=0
gen edate = mdy(1, 1, year)
gen ret_share = no_return/mx2010a_migrants

keep if year<=2010

save Data_built\MexCensus\MexCensus_returnmigr_shock.dta, replace


