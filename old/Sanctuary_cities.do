clear all
set more off

*cd C:\Users\esthe\ownCloud\gehrke8\Data\Mexico\

*Claire
cd "C:\Users\Claire\Dropbox\MigrationShocks"
******************************************
*PREP: 

*input_files:
*files of type: 
*Data_raw\SancCities\page8-page-1-table-1.csv



*output_files:
*Data_built\SancCities\sancturay_cities.dta
*Data_built\SancCities\sancturay_cities_wide.dta

*******************************************







** First have to remove tabs/ enter manually from csv files... 
clear
import delimited Data_raw\SancCities\page8-page-1-table-1.csv, delimiter(comma, collapse) bindquote(strict) varnames(1) stripquote(yes) encoding(UTF-8)
keep juris date
save Data_built\SancCities\sanctuary_cities.dta, replace

clear
forvalues x=9/23 {
import delimited Data_raw\SancCities\page`x'-page-1-table-1.csv, delimiter(comma, collapse) bindquote(strict) varnames(1) stripquote(yes) encoding(UTF-8)
append using Data_built\SancCities\sanctuary_cities.dta
save Data_built\SancCities\sanctuary_cities.dta, replace
sleep 200
clear
}

use Data_built\SancCities\sanctuary_cities.dta, clear
gen juris =  jurisdictiondateenactedpolicycri
replace juris = jurisdictionaor if juris==""
gen date = v2
replace date = dateenacted if date==""
gen expl = criteriaforhonoringdetainer
replace expl = v4 if expl==""
keep juris date expl
replace juris=stritrim(juris)

gen year = substr(date, -2,.)
destring year, ignore("ed") replace
replace year=2000+year
gen month = substr(date, 1, 3)
gen m = 1 if month=="Jan"
replace m=2 if month=="Feb"
replace m=3 if month=="Mar"
replace m=4 if month=="Apr"
replace m=5 if month=="May"
replace m=6 if month=="Jun"
replace m=7 if month=="Jul"
replace m=8 if month=="Aug"
replace m=9 if month=="Sep"
replace m=10 if month=="Oct"
replace m=11 if month=="Nov"
replace m=12 if month=="Dec"
replace m=1 if month=="Und"
drop month
rename m month
recode year .=2008
replace month =1 if year==2097
recode year 2097 = 2008
gen ym=ym(year, month)
format ym %tm

split juris, p("County" "," "(" ")")
replace juris2= juris3 if juris2==""
replace juris2= ustrrtrim(juris2)
replace juris2= strtrim(juris2)
replace juris1= ustrtrim(juris1)
*keep if year<2014

rename juris1 county
gen state = "CA" if juris2=="California"
replace state = "MD" if juris2=="DC" | juris2=="Maryland"
replace state = "FL" if juris2=="Florida" 
replace state = "NM" if juris2=="New Mexico"
replace state = "NV" if juris2=="Nevada"
replace state = "CO" if juris2=="Colorado" | juris2=="Aurora Colorado"
replace state = "CT" if juris2=="Connecticut"
replace state = "IL" if juris2=="Illinois"
replace state = "KS" if juris2=="Kansas"
replace state="LA" if juris2=="Louisiana"
replace state="MN" if juris2=="Minnesota"
replace state="MA" if juris2=="Massachusetts"
replace state="NE" if juris2=="Nebraska"
replace state = "RI" if juris2=="Rhode Island"
replace state = "TX" if juris2=="Texas"
replace state = "VT" if juris2=="Vermont"
replace state = "VA" if juris2=="Virginia"
replace state = "OR" if juris2=="Oregon" 
replace state = "NY" if juris2=="New York"
replace state = "NJ" if juris2=="New Jersey"
replace state="GA" if juris2=="Georgia"
replace state="IA" if juris2=="Iowa" | juris2=="Johnson"
replace state="PA" if juris2=="Pennsylvania"
replace state="WA" if juris2=="Washington"
replace state="WI" if juris2=="Wisconsin"

* entire states, will have to account for them differently
drop if county=="Colorado" // as of Sept 2014 all of Colorado is sanctuary
drop if county=="California" // as of Jan 2014 all of California is sanctuary
drop if county=="Connecticut" // as of Jan 2014 all of Connecticut is sanctuary
drop if county=="New Mexico" // as of Oct 2014 all of New Mexico is sanctuary
drop if county=="Rhode Island Department of Corrections"  // as of Jul 2014 all of RI is sanctuary

*drop 2nd entry for counties that expanded their sanctury laws
duplicates drop
drop if county=="Philadelphia" & year==2016

* manually correct misspelled counties and assing counties to cities
replace county="Hampshire" if county=="Amherst"
replace county="Arapahoe" if county=="Aurora Detention Center"
// also Adams county in Colorado 
replace county="Baltimore city" if county=="Baltimore City"
replace county="Suffolk" if county=="Boston"
replace county="Middlesex" if county=="Cambridge"
replace county="Cook" if county=="Chicago"
replace county="Del Norte" if county=="Del-Norte"
replace county="New Haven" if county=="East Haven"
replace county="Iowa" if county=="Iowa City"
replace county="Tompkins" if county=="Ithaca"
replace county="Washington" if county=="Montpelier"
replace county="Orleans Parish" if county=="New Orleans"
replace county="Essex" if county=="Newark"
replace county="Hampshire" if county=="Northampton"
replace county="Prince George's" if county=="Prince George’s"
replace county="Middlesex" if county=="Somerville"
replace county="Lane" if county=="Springfield Police Department"
replace county="Saint Lawrence" if county=="St. Lawrence"

*drop 2nd entry for counties that expanded their sanctury laws
sort county state date
drop if county=="Cook" & year==2012 
drop if county=="Hampshire" & year==2014 
drop if county=="Iowa" & year==2017 
drop if county=="Middlesex" & month==7 
drop if county=="Middlesex" & month==6 
 
* merge 1:1 county state using SecureComm\sec_comm_activation_wide.dta
 
forvalues m=1/12 {
forvalues y=2005/2014 {
gen sanc`m'`y' = 1 if ym<=ym(`y',`m')
recode sanc`m'`y' .=0 
}
}

keep county state sanc*
save Data_built\SancCities\sancturay_cities_wide.dta, replace

