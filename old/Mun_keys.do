clear all
set more off
*Esther
*cd "C:\Users\gehrk001\Dropbox\MigrationShocks\Data"

*Claire
cd "C:\Users\Claire\Dropbox\MigrationShocks\Data"

*PREP:
*ssc install use13

*Input files:
*Claves\Claves.xlsx
*MexCensus\ipumsi_00005.dta

*Output files: 


************************************************************************************
** Municipality keys

* Ne
import excel "Claves\Claves.xlsx", sheet("Claves") firstrow
keep CVE_ENT NOM_ENT CVE_MUN NOM_MUN
duplicates drop
su 
//  2463 Municipalities in December 2017!
gen str12 geo2_mx2017 = string(CVE_ENT, "%02.0f") + string(CVE_MUN, "%03.0f")
destring geo2_mx2017, replace
ren CVE_ENT geo1_mx2017 
drop CVE_MUN
save "Claves\Claves2017.dta", replace

* IPUMS
use MexCensus\ipumsi_00005.dta, clear
keep geo* year
duplicates drop
save Claves\Claves_IPUMS_l.dta, replace

use "Claves\Claves_IPUMS_l.dta", clear
keep if year==2000
keep geolev2 geo1_mx2000 geo2_mx2000
save Claves\cl00.dta, replace

use Claves\Claves_IPUMS_l.dta, clear
keep if year==2005
keep geolev2 geo1_mx2005 geo2_mx2005
save Claves\cl05.dta, replace

use Claves\Claves_IPUMS_l.dta, clear
keep if year==2010
keep geolev2 geo1_mx2010 geo2_mx2010
save Claves\cl10.dta, replace

use Claves\Claves_IPUMS.dta, clear
keep if year==2015
keep geolev2 geo1_mx2015 geo2_mx2015
save Claves\cl15.dta, replace

use Claves\cl00.dta, clear
*gen firstobs = 2000
bysort geolev2: gen n = _N // number of mun splits since 1960
gen geo2_mx2005=geo2_mx2000
merge 1:m geo2_mx2005 using Claves\cl05
*recode firstobs .=2005
sort geolev2 geo2_mx2000
levelsof geolev2 if _merge==2, local(newmun1)
foreach l of local newmun1 {
list geolev2 n if geolev2==`l'
} // check manually that each new municipality goes back to only one original municipality (n should never be>1) 
replace geo2_mx2000= 32047 if geo2_mx2005== 32058
drop _merge n
bysort geolev2: carryforward geo1_mx2000 geo2_mx2000, replace
bysort geolev2: gen n = _N // number of mun splits since 1960
gen geo2_mx2010=geo2_mx2005
merge 1:m geo2_mx2010 using Claves\cl10
sort geolev2 geo2_mx2005
levelsof geolev2 if _merge==2, local(newmun2)
foreach l of local newmun2 {
list geolev2 n if geolev2==`l'
} 
replace geo2_mx2005 = 23008 if geo2_mx2010== 23009 // have to do this manually!
replace geo2_mx2000 = 23008 if geo2_mx2010== 23009 // have to do this manually!
bysort geolev2: carryforward geo2_mx2000 geo1_mx2000 geo1_mx2005 geo2_mx2005, replace
drop _merge n
bysort geolev2: gen n = _N // number of mun splits since 1960
gen geo2_mx2015=geo2_mx2010
merge 1:m geo2_mx2015 using Claves\cl15
sort geolev2 geo2_mx2005
levelsof geolev2 if _merge==2, local(newmun3)
foreach l of local newmun3 {
list geolev2 n if geolev2==`l'
} 
replace geo2_mx2010 = 23004 if geo2_mx2015== 23010 // have to do this manually!
replace geo2_mx2005 = 23004 if geo2_mx2015== 23010 // have to do this manually!
replace geo2_mx2000 = 23004 if geo2_mx2015== 23010 // have to do this manually!
bysort geolev2: carryforward geo2_mx2000 geo1_mx2000 geo1_mx2005 geo2_mx2005 geo1_mx2010, replace
drop n _merge
su
save Claves\Claves_1960_2015.dta, replace

** Add 2017 (here need to do everything manually!)
use Claves\Claves_1960_2015.dta, clear
gen geo2_mx2017=geo2_mx2015
merge 1:m geo2_mx2017 using Claves\Claves2017
sort geolev2 geo2_mx2015
levelsof geo2_mx2017 if _merge==2, local(newmun4)
list geo2_mx2017 NOM_MUN if _merge==2

* Capitan Luis Angel Vidal
replace geo2_mx2015 = 7080 if geo2_mx2017== 7120 // have to do this manually!
replace geo2_mx2010 = 7080 if geo2_mx2017== 7120 // have to do this manually!
replace geo2_mx2005 = 7080 if geo2_mx2017== 7120 // have to do this manually!
replace geo2_mx2000 = 7080 if geo2_mx2017== 7120 // have to do this manually!
replace geolev2 = 484007080 if geo2_mx2017== 7120 // have to do this manually!

* Rincon chamula San Pedro
replace geo2_mx2015 = 7072 if geo2_mx2017== 7121 // have to do this manually!
replace geo2_mx2010 = 7072 if geo2_mx2017== 7121 // have to do this manually!
replace geo2_mx2005 = 7072 if geo2_mx2017== 7121 // have to do this manually!
replace geo2_mx2000 = 7072 if geo2_mx2017== 7121 // have to do this manually!
replace geolev2 = 484007072 if geo2_mx2017== 7121 // have to do this manually!

* El parral
replace geo2_mx2015 = 7107 if geo2_mx2017== 7122 // have to do this manually!
replace geo2_mx2010 = 7107 if geo2_mx2017== 7122 // have to do this manually!
replace geo2_mx2005 = 7107 if geo2_mx2017== 7122 // have to do this manually!
replace geo2_mx2000 = 7107 if geo2_mx2017== 7122 // have to do this manually!
replace geolev2 = 484007106 if geo2_mx2017== 7122 // have to do this manually!

* Emiliano Zapata
replace geo2_mx2015 = 7071 if geo2_mx2017== 7123 // have to do this manually!
replace geo2_mx2010 = 7071 if geo2_mx2017== 7123 // have to do this manually!
replace geo2_mx2005 = 7071 if geo2_mx2017== 7123 // have to do this manually!
replace geo2_mx2000 = 7071 if geo2_mx2017== 7123 // have to do this manually!
replace geolev2 = 484007071 if geo2_mx2017== 7123 // have to do this manually!

* Mezcalapa
replace geo2_mx2015 = 7092 if geo2_mx2017== 7124 // have to do this manually!
replace geo2_mx2010 = 7092 if geo2_mx2017== 7124 // have to do this manually!
replace geo2_mx2005 = 7092 if geo2_mx2017== 7124 // have to do this manually!
replace geo2_mx2000 = 7092 if geo2_mx2017== 7124 // have to do this manually!
replace geolev2 = 484007092 if geo2_mx2017== 7124 // have to do this manually!

* Puerto Morelos
replace geo2_mx2015 = 23005 if geo2_mx2017== 23011 // have to do this manually!
replace geo2_mx2010 = 23005 if geo2_mx2017== 23011 // have to do this manually!
replace geo2_mx2005 = 23005 if geo2_mx2017== 23011 // have to do this manually!
replace geo2_mx2000 = 23005 if geo2_mx2017== 23011 // have to do this manually!
replace geolev2 = 484023001 if geo2_mx2017== 23011 // have to do this manually!
sort geolev2 geo2_mx2017
bysort geolev2: carryforward geo1_mx2000 geo1_mx2005 geo1_mx2010 geo1_mx2015, replace
drop _merge
su

save Claves\Claves_1960_2017.dta, replace


use Claves\Claves_1960_2015.dta, clear
drop geo2_mx2015 geo1_mx2015 //geo2_mx2017 geo1_mx2017
duplicates drop
save Claves\Claves_1960_2010.dta, replace


