**************************************************************************************
** ENCO Data

* (have to read in with R first and save as stata... )

/*
Questionnaires
Basico: Version 3 October 2005 - September 2010, Version 4 since October 2010
		only change in Question P12 (Expectation of inflation)
 
Socio:  Version 4 (April 2008 to December 2014), Version 5 since January 2015

*/

cd "C:\Users\esthe\ownCloud\gehrke8\Data\Mexico\"

** Combine datasets 
clear

use ENCO\STATA\encoviv2009.dta, clear 
drop P1-P4
merge 1:1 PER FOL ENT CON V_SEL using ENCO\STATA\encocb2009.dta
keep if _merge==3 
drop _merge
forvalues x=1/15 {
destring P`x', replace 
}
gen year=2009
save ENCO\STATA\enco_all.dta, replace

foreach y in 2010 2011 2012 2013 2014 2015 2016 2017 2018 {
use ENCO\STATA\encoviv`y'.dta, clear
drop P1-P4
merge 1:1 PER FOL ENT CON V_SEL using ENCO\STATA\encocb`y'.dta
keep if _merge==3 
drop _merge
forvalues x=1/15 {
destring P`x', replace 
}
gen year=`y'
append using ENCO\STATA\enco_final.dta
save ENCO\STATA\enco_all.dta, replace
 }
 
** Clean
 
use ENCO\STATA\enco_all.dta, clear
gen month = substr(PER,1,2)
destring month, replace
gen time_ym=ym(year,month)
format time_ym %tm

drop P12
foreach x in 1 2 3 4 5 6 11 13 {
recode P`x' 6=.
}
foreach x in 7 8 10 14 15 {
recode P`x' 4=.
}
foreach x in 9 10 {
recode P`x' 3=.
}

save ENCO\STATA\enco_final.dta, replace

use ENCO\STATA\enco_final.dta, clear
collapse (mean) P1 - P15 , by(time)
tsset time


* How do you expect the economic situation of your household to change in the next 12 months (1 (better) - 5 (worse)) 
twoway line P4 time if time>tm(2010m1)  , xline(`=tm(2016m12)', lcolor(black) lwidth(medthick))

* How do you expect the economic situation of this country to change in the next 12 months (1 (better) - 5 (worse)) 
twoway line P6 time if time>tm(2010m1), xline(`=tm(2016m12)', lcolor(black) lwidth(medthick))

* How do your rate your possibility to generate savings in the next 12 months? 
twoway line P11 time if time>tm(2010m1) , xline(`=tm(2016m12)', lcolor(black) lwidth(medthick))

** Are there any changes in coding in 2018???? 
