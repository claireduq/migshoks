
* 2000 Extract
use $Data_raw\MexCensus\ipumsi_00005.dta, clear 
keep if year == 2000
keep country - subsamp geolev2 geo2_mx2000 mx2000* 
duplicates drop
su
drop mx2000a_pern
save "$Data_built\census2000.dta", replace

* 2010 Extract
use "$Data_raw\MexCensus\ipumsi_00005.dta", clear 
keep if year == 2010
keep country - subsamp geolev2 geo2_mx2010 mx2010*
duplicates drop
drop mx2010a_pern
save "$Data_built\census2010.dta", replace

* Migration data to be merged with other datasets
use $Data_built\census2000, clear
recode mx2000a_migstat 9=. 2=0 // any hh member is migrant
isid  geolev2 mx2000a_dwnum mx2000a_hhnumo

collapse (sum) mx2000a_mign persons (mean) mx2000a_migstat [fw = hhwt], by(geolev2 geo2_mx2000 year)

*CLAIRE: correcting to add migrants to denominator? 
gen migr_share = mx2000a_mign/ (persons+mx2000a_mign) // number of migrants per observed hh members  
su
save $Data_built\census2000_col.dta, replace

* 2000 map
shp2dta using $Data_raw\Map_IPUMS\geo2_mx1960_2015, data($Data_built\mex_data2) coor($Data_built\mex_coordinates2) genid(id) replace

cap erase "$Data_built\census2000.dta"
cap erase "$Data_built\census2010.dta"
cap erase "$Data_built\mex_coordinates2.dta"
cap erase "$Data_built\mex_data2.dta"