clear all
set more off

*cd C:\Users\esthe\ownCloud\gehrke8\Data\Mexico\
*cd "C:\Users\gehrk001\OneDrive - WageningenUR\Data\Mexico"

*Claire
cd "C:\Users\Claire\Dropbox\MigrationShocks"
******************************************
*PREP: 

*input_files:
*files of type: 
*Data_raw\SecureComm\page8-page-1-table-1.csv
*Data_built\SancCities\sancturay_cities_wide.dta(built in Sanctuary_cities.do)

*output_files:
*Data_built\SecureComm\sec_comm_activation.dta
*Data_built\SecureComm\sec_comm_activation_usav.dta
*Data_built\SecureComm\sec_comm_activation_wide.dta
*Data_built\SecureComm\sec_comm_sanc_long.dta


*******************************************
clear
import delimited Data_raw\SecureComm\page8-page-1-table-1.csv, bindquote(strict) varnames(1) encoding(UTF-8)
keep state county activationdate
save Data_built\SecureComm\sec_comm_activation.dta, replace

clear
forvalues x=9/56 {
import delimited Data_raw\SecureComm\page`x'-page-1-table-1.csv, bindquote(strict) varnames(1) encoding(UTF-8)
keep state county activationdate
append using Data_built\SecureComm\sec_comm_activation.dta
save Data_built\SecureComm\sec_comm_activation.dta, replace
sleep 200
clear
}

use Data_built\SecureComm\sec_comm_activation.dta, clear

gen activ = date(activationdate, "MDY")
format activ %td

forvalues m=1/12 {
forvalues y=2005/2014 {
gen sc`m'`y' = 1 if activ<=mdy(`m',1,`y')
recode sc`m'`y' .=0 
}
}

merge 1:1 county state using Data_built\SancCities\sancturay_cities_wide.dta
drop _m 

// manually correct state-level changes
forvalues m=1/12 {
replace sanc`m'2014=1 if state=="CA" | state=="CT"
}
forvalues m=10/12 {
replace sanc`m'2014=1 if state=="NM"
}
forvalues m=9/12 {
replace sanc`m'2014=1 if state=="CO"  
}
forvalues m=7/12 {
replace sanc`m'2014=1 if state=="RI"  
}

save Data_built\SecureComm\sec_comm_activation_wide.dta, replace

reshape long sc sanc, i(state county) j(date)
tostring date, replace
gen y=substr(date, -4,.)
egen m=ends(date) , punct(20) head

destring y, replace
destring m, replace
recode sanc .=0

gen sc2 = sc*(1-sanc)

save Data_built\SecureComm\sec_comm_sanc_long.dta, replace

collapse (mean) sc* sanc , by(y m)

rename sc us_av_SC
rename sc2 us_av_SCsanc
rename sanc us_av_sanc
// gen ym=ym(y, m)
// line us_av ym

save Data_built\SecureComm\sec_comm_activation_usav.dta, replace
