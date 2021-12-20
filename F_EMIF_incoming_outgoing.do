
************************************************************************************
* City codes for round 1999 - 2003

import delimited $Data_raw\EMIF\PDS_Valores_1999.csv , clear
replace variable = strlower(variable)
keep if variable=="mun_nac" | variable=="p13_3_1c" | variable=="p13_3_1e" 
rename variable variable
//rename val val`x'
rename descripción descr1999
tempfile pds_val_1999
save `pds_val_1999', replace

use `pds_val_1999', clear
keep if variable=="p13_3_1c"
keep if valor>0
drop if valor>=58
rename valor CLAVE
drop variable
gen state = "CA" if CLAVE<11
replace state = "TX" if CLAVE >=11 & CLAVE<22
replace state = "AZ" if CLAVE >=22 & CLAVE<28
replace state = "NM" if CLAVE >=28 & CLAVE<32
replace state = "NV" if CLAVE >=32 & CLAVE<35
replace state = "CO" if CLAVE >=35 & CLAVE<38
replace state = "IL" if CLAVE >=38 & CLAVE<40
replace state = "KS" if CLAVE >=40 & CLAVE<42
replace state = "WI" if CLAVE >=42 & CLAVE<44
replace state = "WA" if CLAVE >=44 & CLAVE<46
replace state = "NY" if CLAVE >=46 & CLAVE<48
replace state = "FL" if CLAVE >=48 & CLAVE<50
replace state = "MD" if CLAVE ==50
replace state = "UT" if CLAVE ==51
replace state = "OK" if CLAVE ==52
replace state = "CA" if CLAVE ==53
replace state = "OR" if CLAVE ==54
replace state = "ID" if CLAVE ==55
replace state = "MT" if CLAVE ==56
replace state = "NJ" if CLAVE ==57

gen county="Washington" if CLAVE==50
replace county="Los Angeles" if CLAVE==1
replace county="San Diego" if CLAVE==2
replace county="San Francisco" if CLAVE==3
replace county="Imperial" if CLAVE==4
replace county="Imperial" if CLAVE==5
replace county="Orange" if CLAVE==6
replace county="Kern" if CLAVE==7
replace county="Fresno" if CLAVE==8
replace county="Sacramento" if CLAVE==9
replace county="Dallas" if CLAVE==11
replace county="Houston" if CLAVE==12
replace county="Bexar" if CLAVE==13
replace county="Hidalgo" if CLAVE==14
replace county="Webb" if CLAVE==15
replace county="Nueces" if CLAVE==16
replace county="El Paso" if CLAVE==17
replace county="Travis" if CLAVE==18
replace county="Lubbock" if CLAVE==19
replace county="Pima" if CLAVE==22
replace county="Santa Cruz" if CLAVE==23
replace county="Maricopa" if CLAVE==24
replace county="Pima" if CLAVE==25
replace county="Pinal" if CLAVE==26
replace county="Bernalillo" if CLAVE==28
replace county="Dona Ana" if CLAVE==29
replace county="Santa Fe" if CLAVE==30
replace county="Clark" if CLAVE==32
replace county="Washoe" if CLAVE==33
replace county="Denver" if CLAVE==35
replace county="El Paso" if CLAVE==36
replace county="Cook" if CLAVE==38
replace county="Wyandotte" if CLAVE==40
replace county="Milwaukee" if CLAVE==42
replace county="King" if CLAVE==44
replace county="New York City" if CLAVE==46
replace county="Miami-Dade" if CLAVE==48
keep if county!=""

rename  CLAVE CLAVE_LOC


/* Check if works...
duplicates drop county state, force
merge 1:m county state using "C:\Users\esthe\ownCloud\gehrke8\Data\Mexico\SecureComm\sec_comm_activation.dta"
*/

tempfile codes_emif_1999
save `codes_emif_1999', replace 
****************************************************************************************
* Return migrants (border)

forvalues x=1999/2008 {
import delimited $Data_raw\EMIF\PFN_Descriptores_`x'.csv ,  clear
// keep relevant observations
keep variable descripcion
replace variable = strlower(variable)
tempname fh
local N = c(N)
// create a new do-file
file open `fh' using $dofiles\EMIFlabels\my_labels_`x'.do , write replace
forvalues i = 1/`N' {
    file write `fh' "label variable `= variable[`i']' "
    file write `fh' `""`= descripcion[`i']'""' _newline
}
file close `fh'

type $dofiles\EMIFlabels\my_labels_`x'.do
}

forvalues x=1999/2008 {
import delimited "$Data_raw\EMIF\PFN `x'.csv", clear
do $dofiles\EMIFlabels\my_labels_`x'.do
tempfile pfn_`x'
save `pfn_`x'', replace
}

forvalues x=1999/2003 { 
use `pfn_`x'', clear
keep  folio mun_nac pai_nac p11* p13_4_3*
// drop those that are not from mexico
drop if pai_nac>32
*drop if mun_nac==999 | mun_nac==998
keep if p13_4_3c>0
// drop respondents who dont seem to have lived in US... 
gen year=`x'
rename (p13_4_3c p13_4_3e) (CLAVE_LOC CLAVE_EDO)
merge m:1 CLAVE_LOC using "$Data_raw\EMIF\codes_emif_1999.dta"
ta CLAVE_LOC if _merge==1
drop if _merge==2
gen obs=1 if _merge ==3 // only those that can be matched at city (rather than state) level, drops roughly 1/3 of obs
drop _merge
drop descr1999
replace p11e = pai_nac if p11p>=2 // replace place of residence with place of birth if lives in US
replace p11m = mun_nac if p11p>=2
gen geo2_mx2010 = p11e *1000 + p11m
drop p11*
*replace weight = c(N) * weight
*bysort p6_est p6_mun: gen obspmun = _N
tempfile emif_pfn_`x'
save `emif_pfn_`x'', replace
}

forvalues x=2004/2008 { 
use `pfn_`x'', clear
keep folio ponfin3 trim mun_nac pai_nac p11* p13_4_3*
duplicates drop folio ponfin3 trim , force
// drop those that are not from mexico
drop if pai_nac>32
keep if p13_4_3o>0 
drop if p13_4_3o==p13_4_3e
// drop respondents who dont seem to have lived in US... 
gen year=`x'
rename (p13_4_3o p13_4_3e) (CLAVE_LOC CLAVE_EDO)
merge m:1 CLAVE_LOC CLAVE_EDO using "$Data_raw\EMIF\claves_eua_2020.dta"
ta CLAVE_LOC if _merge==1
drop if _merge==2
gen obs=1 if _merge ==3 // only those that can be matched at city (rather than state) level, drops roughly 1/3 of obs
drop _merge
replace p11e = pai_nac if p11p>=2 // replace place of residence with place of birth if lives in US
replace p11m = mun_nac if p11p>=2
gen geo2_mx2010 = p11e *1000 + p11m
drop p11*
*replace weight = c(N) * weight
*bysort p6_est p6_mun: gen obspmun = _N
tempfile emif_pfn_`x'
save `emif_pfn_`x'', replace
}

forvalues x=2004/2008 { 
use `pfn_`x'', clear
keep  folio ponfin3 trim  mun_nac pai_nac p11* p13_4_3*
duplicates drop folio ponfin3 trim, force
// drop those that are not from mexico
drop if pai_nac>32
*drop if mun_nac==999 | mun_nac==998
keep if p13_4_3o>=0
*drop if p13_4_3o==p13_4_3e
replace p11e = pai_nac if p11p>=2 // replace place of residence with place of birth if lives in US
replace p11m = mun_nac if p11p>=2
gen geo2_mx2010 = p11e *1000 + p11m
// drop respondents who dont seem to have lived in US... 
gen year=`x'
rename (p13_4_3c p13_4_3e) (CLAVE_CNTY CLAVE_EDO)
*keep if CLAVE_CNTY>99
drop if CLAVE_CNTY==99999 
merge m:1 CLAVE_CNTY CLAVE_EDO using "$Data_built\claves_eua_2020_mun.dta"
drop if _merge==2
gen obs=1 if _merge ==3 // only those that can be matched at city (rather than state) level, drops roughly 1/3 of obs
drop _merge
merge 1:1 folio ponfin3 trim using `emif_pfn_`x'', update 
drop Name p11*
tempfile emif_pfn_`x'
save `emif_pfn_`x'', replace
} 

clear
forvalues x=1999/2008 {
append using `emif_pfn_`x''
}
gen geo_birth =  pai_nac *1000 + mun_nac
replace geo2_mx2010=geo_birth if geo2_mx2010==99999
drop folio mun_nac pai_nac CLAVE_LOC CLAVE_EDO trim p13_4_3o ponfin3 p13_4_3c _merge
keep if county!=""
compare geo_birth geo2_mx2010
save $Data_built\emif_pfn.dta, replace

// 3078/3920 (78%) have same destination as place of birth

forvalues x = 1999/2008 {
cap erase Data_raw\EMIF\my_labels_`x'.do
cap erase Data_raw\EMIF\emif_pfn_`x'.dta
cap erase Data_raw\EMIF\pfn_`x'.dta 
}
************************************************************************************
* Return migrants (terrestrial crossings)

forvalues x=1999/2008 {
import delimited $Data_raw\EMIF\PEUA-T_Descriptores_`x'.csv ,  clear
// keep relevant observations
keep variable descripcion
replace variable = strlower(variable)
tempname fh
local N = c(N)
// create a new do-file
file open `fh' using $dofiles\EMIFlabels\my_labels_`x'.do , write replace
forvalues i = 1/`N' {
    file write `fh' "label variable `= variable[`i']' "
    file write `fh' `""`= descripcion[`i']'""' _newline
}
file close `fh'

type $dofiles\EMIFlabels\my_labels_`x'.do
}

forvalues x=1999/2008 {
import delimited "$Data_raw\EMIF\PEUA-T `x'.csv", clear
do $dofiles\EMIFlabels\my_labels_`x'.do
tempfile peuat_`x'
save `peuat_`x'', replace
}

forvalues x=1999/2003 { 
use `peuat_`x'', clear
 capture rename p12_1ciu p12_1c
  capture rename p12_1est p12_1e

keep  folio mun_nac pai_nac p12_1c p12_1e p14m p14e p14p 

// drop those that are not from mexico
drop if pai_nac>32
*drop if mun_nac==999 | mun_nac==998
keep if p12_1c>0
// drop respondents who dont seem to have lived in US... 
gen year=`x'
rename (p12_1c p12_1e) (CLAVE_LOC CLAVE_EDO)
merge m:1 CLAVE_LOC using "$Data_raw\EMIF\codes_emif_1999.dta"
ta CLAVE_LOC if _merge==1
drop if _merge==2
gen obs=1 if _merge ==3 // only those that can be matched at city (rather than state) level, drops roughly 1/3 of obs
drop _merge
drop descr1999
replace p14e = pai_nac if p14p>=2 // replace place of residence with place of birth if lives in US
replace p14m = mun_nac if p14p>=2
gen geo2_mx2010 = p14e *1000 + p14m
drop p14*
*replace weight = c(N) * weight
*bysort p6_est p6_mun: gen obspmun = _N
tempfile emif_peuat_`x'
save `emif_peuat_`x'', replace
}

forvalues x=2004/2008 { 
use `peuat_`x'', clear
keep  folio ponfin3 trim mun_nac pai_nac p12_1* p14m p14e p14p
duplicates drop folio ponfin3 trim, force
// drop those that are not from mexico
drop if pai_nac>32
*drop if mun_nac==999 | mun_nac==998
keep if p12_1ciu>0 
drop if p12_1ciu==p12_1est
// drop respondents who dont seem to have lived in US... 
gen year=`x'
rename (p12_1ciu p12_1est) (CLAVE_LOC CLAVE_EDO)
merge m:1 CLAVE_LOC CLAVE_EDO using "$Data_raw\EMIF\claves_eua_2020.dta"
ta CLAVE_LOC if _merge==1
drop if _merge==2
gen obs=1 if _merge ==3 // only those that can be matched at city (rather than state) level, drops roughly 1/3 of obs
drop _merge
replace p14e = pai_nac if p14p>=2 // replace place of residence with place of birth if lives in US
replace p14m = mun_nac if p14p>=2
gen geo2_mx2010 = p14e *1000 + p14m
drop p14* p12*
*replace weight = c(N) * weight
*bysort p6_est p6_mun: gen obspmun = _N
tempfile emif_peuat_`x'
save `emif_peuat_`x'', replace
}

forvalues x=2004/2008 { 
use `peuat_`x'', clear
keep  folio ponfin3 trim mun_nac pai_nac p12_1* p14m p14e p14p
duplicates drop folio ponfin3 trim, force
// drop those that are not from mexico
drop if pai_nac>32
*drop if mun_nac==999 | mun_nac==998
keep if p12_1ciu>=0
replace p14e = pai_nac if p14p>=2 // replace place of residence with place of birth if lives in US
replace p14m = mun_nac if p14p>=2
gen geo2_mx2010 = p14e *1000 + p14m
gen year=`x'
// drop respondents who dont seem to have lived in US... 
rename (p12_1con p12_1est) (CLAVE_CNTY CLAVE_EDO)
*keep if CLAVE_CNTY>99
drop if CLAVE_CNTY==99999 
merge m:1 CLAVE_CNTY CLAVE_EDO using "$Data_built\claves_eua_2020_mun.dta"
drop if _merge==2
gen obs=1 if _merge ==3 // only those that can be matched at city (rather than state) level, drops roughly 1/3 of obs
drop _merge
merge 1:1 folio ponfin3 trim using `emif_peuat_`x'', update
drop Name p14* p12*
tempfile emif_peuat_`x'
save `emif_peuat_`x'', replace
} 

clear
forvalues x=1999/2008 {
append using `emif_peuat_`x''
}
gen geo_birth =  pai_nac *1000 + mun_nac
replace geo2_mx2010=geo_birth if geo2_mx2010==99999
drop folio mun_nac pai_nac CLAVE_LOC CLAVE_EDO trim  ponfin3  _merge
keep if county!=""
compare geo_birth geo2_mx2010
save $Data_built\emif_peuat.dta, replace

// 25782/ 36806 (70%) have same destination as place of birth

forvalues x = 1999/2008 {
cap erase Data_raw\EMIF\my_labels_`x'.do
cap erase Data_raw\EMIF\emif_peuat_`x'.dta
cap erase Data_raw\EMIF\peuat_`x'.dta
}
***********************************************************************************
* Deported
forvalues x=1999/2008 {
import delimited $Data_raw\EMIF\DEV_Descriptores_`x'.csv ,  clear
// keep relevant observations
keep variable descripcion
replace variable = strlower(variable)
tempname fh
local N = c(N)
// create a new do-file
file open `fh' using $dofiles\EMIFlabels\my_labels_`x'.do , write replace
forvalues i = 1/`N' {
    file write `fh' "cap label variable `= variable[`i']' "
    file write `fh' `""`= descripcion[`i']'""' _newline
}
file close `fh'

type $dofiles\EMIFlabels\my_labels_`x'.do
}

forvalues x=1999/2008 {
import delimited "$Data_raw\EMIF\DEV `x'.csv", clear
do $dofiles\EMIFlabels\my_labels_`x'.do
tempfile dev_`x'
save `dev_`x'', replace
}

forvalues x=1999/2003 { 
use `dev_`x'', clear
keep  folio  p8_mun p8_est p26_ciu p26_est p9*
// drop those that are not from mexico
drop if p8_est>32
*drop if p8_mun==999 | p8_mun==998
keep if p26_ciu>0
// drop respondents who dont seem to have lived in US... 
gen year=`x'
rename (p26_ciu p26_est) (CLAVE_LOC CLAVE_EDO)
merge m:1 CLAVE_LOC using "$Data_raw\EMIF\codes_emif_1999.dta"
ta CLAVE_LOC if _merge==1
drop if _merge==2
gen obs=1 if _merge ==3 // only those that can be matched at city (rather than state) level, drops roughly 1/3 of obs
drop _merge
drop descr1999
replace p9_est = p8_est if p9_pai>=2 // replace place of residence with place of birth if lives in US
replace p9_mun = p8_mun if p9_pai>=2
gen geo2_mx2010 = p9_est *1000 + p9_mun
drop p9* p8*
*replace weight = c(N) * weight
*bysort p6_est p6_mun: gen obspmun = _N
tempfile emif_dev_`x'
save `emif_dev_`x'', replace
}

forvalues x=2004/2008 { 
use `dev_`x'', clear
keep folio ponfin3 trim p8_mun p8_est p26_ciu p26_est p26_con p9*
duplicates drop folio ponfin3 trim, force
// drop those that are not from mexico
drop if p8_est>32 | p8_est==-1
*drop if p8_mun==999 | p8_mun==998
keep if p26_ciu>0  
drop if p26_ciu==p26_est
// drop respondents who dont seem to have lived in US... 
gen year=`x'
rename (p26_ciu p26_est) (CLAVE_LOC CLAVE_EDO)
merge m:1 CLAVE_LOC CLAVE_EDO using "$Data_raw\EMIF\claves_eua_2020.dta"
ta CLAVE_LOC if _merge==1
drop if _merge==2
gen obs=1 if _merge ==3 // only those that can be matched at city (rather than state) level, drops roughly 1/3 of obs
drop _merge
replace p9_est = p8_est if p9_pai>=2 // replace place of residence with place of birth if lives in US
replace p9_mun = p8_mun if p9_pai>=2
gen geo2_mx2010 = p9_est *1000 + p9_mun
drop p9* p8*
*replace weight = c(N) * weight
*bysort p6_est p6_mun: gen obspmun = _N
tempfile emif_dev_`x'
save `emif_dev_`x'', replace
}

forvalues x=2004/2008 { 
use `dev_`x'', clear
keep folio ponfin3 trim p8_mun p8_est p26_ciu p26_est p26_con p9*
duplicates drop folio ponfin3 trim, force
 // drop those that are not from mexico
drop if p8_est>32 | p8_est==-1
drop if p8_mun==999 | p8_mun==998
keep if p26_ciu>=0
replace p9_est = p8_est if p9_pai>=2 // replace place of residence with place of birth if lives in US
replace p9_mun = p8_mun if p9_pai>=2
gen geo2_mx2010 = p9_est *1000 + p9_mun
gen year=`x'
// drop respondents who dont seem to have lived in US... 
rename (p26_con p26_est) (CLAVE_CNTY CLAVE_EDO)
*keep if CLAVE_CNTY>99
drop if CLAVE_CNTY==99999 
merge m:1 CLAVE_CNTY CLAVE_EDO using "$Data_built\claves_eua_2020_mun.dta"
drop if _merge==2
gen obs=1 if _merge ==3 // only those that can be matched at city (rather than state) level, drops roughly 1/3 of obs
drop _merge
merge 1:1 folio ponfin3 trim using `emif_dev_`x'', update 
drop Name 
tempfile emif_dev_`x'
save `emif_dev_`x'', replace
} 

clear
forvalues x=1999/2008 {
append using `emif_dev_`x''
}
gen geo_birth =  p8_est *1000 + p8_mun
replace geo2_mx2010=geo_birth if geo2_mx2010==99999
drop folio CLAVE_LOC CLAVE_EDO trim  ponfin3  _merge p8* p9* p26*
keep if county!=""
compare geo_birth geo2_mx2010

save $Data_built\emif_dev.dta, replace

// 4235/4640 (91%) have same place of birth as destination 

forvalues x=1999/2008 {
cap erase Data_raw\EMIF\my_labels_`x'.do
cap erase Data_raw\EMIF\emif_dev_`x'.dta
cap erase Data_raw\EMIF\dev_`x'.dta
}
***********************************************************************************
* Outgoing migrants

forvalues x=1999/2012 {
import delimited $Data_raw\EMIF\PDS_Descriptores_`x'.csv ,  clear
// keep relevant observations
keep variable descripcion
replace variable = strlower(variable)
tempname fh
local N = c(N)
// create a new do-file
file open `fh' using $dofiles\EMIFlabels\my_labels_`x'.do , write replace
forvalues i = 1/`N' {
    file write `fh' "label variable `= variable[`i']' "
    file write `fh' `""`= descripcion[`i']'""' _newline
}
file close `fh'

type $dofiles\EMIFlabels\my_labels_`x'.do
}

forvalues x=2013/2016 {
import delimited $Data_raw\EMIF\PDS_Descriptores_`x'.csv ,  clear
// keep relevant observations
keep variable descripción
replace variable = strlower(variable)
tempname fh
local N = c(N)
// create a new do-file
file open `fh' using $dofiles\EMIFlabels\my_labels_`x'.do, write replace
forvalues i = 1/`N' {
    file write `fh' "label variable `= variable[`i']' "
    file write `fh' `""`= desc[`i']'""' _newline
}
file close `fh'
// look at new dofile
type $dofiles\EMIFlabels\my_labels_`x'.do
}

forvalues x=2017/2017 {
import delimited $Data_raw\EMIF\PDS_Descriptores_`x'.csv ,  clear
// keep relevant observations
keep variable etiqueta
tempname fh
local N = c(N)
// create a new do-file
file open `fh' using $dofiles\EMIFlabels\my_labels_`x'.do, write replace
forvalues i = 1/`N' {
    file write `fh' "label variable `= variable[`i']' "
    file write `fh' `""`= eti[`i']'""' _newline
}
file close `fh'
// look at new dofile
type $dofiles\EMIFlabels\my_labels_`x'.do
}

forvalues x=1999/2012 {
import delimited $Data_raw\EMIF\ENORTE_procsur`x'.csv, clear
do $dofiles\EMIFlabels\my_labels_`x'.do
tempfile procsur_`x'
save `procsur_`x'', replace
}

forvalues x=2013/2016 {
import delimited $Data_raw\EMIF\SUR_`x'.csv, clear
do $dofiles\EMIFlabels\my_labels_`x'.do
tempfile procsur_`x'
save `procsur_`x'', replace
}

*****************************************
* Clean and append data

forvalues x=1999/2002 { 
use `procsur_`x'', clear
keep  folio  mun_nac p6_* pai_nac p13_3_1c p13_3_1e //p20_1c p20_1e
drop if pai_nac>32 // drop those that are not from mexico
replace p6_est= pai_nac if p6_pai>=2
replace p6_mun= mun_nac if p6_pai>=2
drop if p6_est==99
drop if p6_mun==999 | p6_mun==998
keep if p13_3_1c>0
// 65% of respondents dont seem to be intending to cross the border... 
gen year=`x'
rename (p13_3_1c p13_3_1e) (CLAVE_LOC CLAVE_EDO)
merge m:1 CLAVE_LOC using "$Data_raw\EMIF\codes_emif_1999.dta"
ta CLAVE_LOC if _merge==1
drop if _merge==2
gen obs=1 if _merge ==3 // only those that can be matched at city (rather than state) level, drops roughly 1/3 of obs
drop _merge
drop descr1999
*replace weight = c(N) * weight
*bysort p6_est p6_mun: gen obspmun = _N
tempfile emif_procsur_`x'
save `emif_procsur_`x'', replace
}

** 2003 forward has mixed code system
use `procsur_2003', clear
keep  folio  mun_nac p6_* pai_nac p13_3_1c p13_3_1e //p20_1c p20_1e
drop if pai_nac>32 // drop those that are not from mexico
replace p6_est= pai_nac if p6_pai>=2
replace p6_mun= mun_nac if p6_pai>=2
drop if p6_est==99
drop if p6_mun==999 | p6_mun==998
keep if p13_3_1c>0
// 65% of respondents dont seem to be intending to cross the border... 
gen year=2003
*bysort p6_est p6_mun: gen migpmun = _N
rename (p13_3_1c p13_3_1e) (CLAVE_LOC CLAVE_EDO)
drop if CLAVE_LOC==99 //CLAVE_EDO
keep if CLAVE_LOC<=55
merge m:1 CLAVE_LOC using "$Data_raw\EMIF\codes_emif_1999.dta"
ta CLAVE_LOC if _merge==1
drop if _merge==2
gen obs=1 if _merge ==3 // only those that can be matched at city (rather than state) level, drops roughly 1/3 of obs
drop _merge
drop descr1999
tempfile emif_procsur_2003
save `emif_procsur_2003', replace

use `procsur_2003', clear
keep  folio  mun_nac p6_* pai_nac p13_3_1c p13_3_1e //p20_1c p20_1e
drop if pai_nac>32 // drop those that are not from mexico
replace p6_est= pai_nac if p6_pai>=2
replace p6_mun= mun_nac if p6_pai>=2
drop if p6_est==99
drop if p6_mun==999 | p6_mun==998
keep if p13_3_1c>0
// 65% of respondents dont seem to be intending to cross the border... 
gen year=2003
*bysort p6_est p6_mun: gen migpmun = _N
rename (p13_3_1c p13_3_1e) (CLAVE_LOC CLAVE_EDO)
keep if CLAVE_LOC>99
drop if CLAVE_LOC==99999 
merge m:1 CLAVE_LOC CLAVE_EDO using "$Data_raw\EMIF\claves_eua_2020.dta"
ta CLAVE_LOC if _merge==1
drop if _merge==2
gen obs=1 if _merge ==3 // only these that can be matched at city (rather than state) level, drops roughly 1/3 of obs
drop _merge
append using `emif_procsur_2003' 
*bysort p6_est p6_mun: gen obspmun = _N
save `emif_procsur_2003', replace


** make codes comparable in years 2004 - 2008 
forvalues x=2004/2006 {
use `procsur_`x'', clear
keep folio unidad trim mun_nac p6_* pai_nac p13_3_1c p13_3_1o p13_3_1e //p20_1c p20_1e
duplicates drop folio unidad trim, force
drop if pai_nac>32 // drop those that are not from mexico
replace p6_est= pai_nac if p6_pai>=2
replace p6_mun= mun_nac if p6_pai>=2
drop if p6_est==99
drop if p6_mun==999 | p6_mun==998
keep if p13_3_1c>0
// 65% of respondents dont seem to be intending to cross the border... 
gen year=`x'
rename (p13_3_1c p13_3_1e) (CLAVE_LOC CLAVE_EDO)
keep if CLAVE_LOC>55
drop if CLAVE_LOC==99999
drop if CLAVE_LOC==99998
drop if CLAVE_LOC==99997
merge m:1 CLAVE_LOC CLAVE_EDO using "$Data_raw\EMIF\claves_eua_2020.dta"
list if _merge==1
drop if _merge==2
gen obs=1 if _merge==3
drop _merge
tempfile emif_procsur_`x'
save `emif_procsur_`x'', replace
}

forvalues x=2004/2006 {
use `procsur_`x'', clear
keep  folio unidad trim mun_nac p6_* pai_nac p13_3_1c p13_3_1e p13_3_1o //p20_1c p20_1e
duplicates drop folio unidad trim, force
drop if pai_nac>32 // drop those that are not from mexico
replace p6_est= pai_nac if p6_pai>=2
replace p6_mun= mun_nac if p6_pai>=2
drop if p6_est==99
drop if p6_mun==999 | p6_mun==998
keep if p13_3_1c>0
// 65% of respondents dont seem to be intending to cross the border... 
gen year=`x'
rename (p13_3_1o p13_3_1e) (CLAVE_CNTY CLAVE_EDO)
*keep if CLAVE_CNTY>99
drop if CLAVE_CNTY==99999 | CLAVE_CNTY==999
merge m:1 CLAVE_CNTY CLAVE_EDO using "$Data_built\claves_eua_2020_mun.dta"
ta CLAVE_CNTY if _merge==1
drop if _merge==2
gen obs=1 if _merge ==3 // only those that can be matched at city (rather than state) level, drops roughly 1/3 of obs
drop _merge
merge 1:1 folio unidad trim using `emif_procsur_`x'', update
tempfile emif_procsur_`x'
save `emif_procsur_`x'', replace
}


** make codes comparable in years 2004 - 2008 
forvalues x=2007/2008 {
use `procsur_`x'', clear
keep folio trim mun_nac p6_* pai_nac p13_3_1c p13_3_1o p13_3_1e //p20_1c p20_1e
duplicates drop folio trim, force
drop if pai_nac>32 // drop those that are not from mexico
replace p6_est= pai_nac if p6_pai>=2
replace p6_mun= mun_nac if p6_pai>=2
drop if p6_est==99
drop if p6_mun==999 | p6_mun==998
keep if p13_3_1c>0
// 65% of respondents dont seem to be intending to cross the border... 
gen year=`x'
rename (p13_3_1c p13_3_1e) (CLAVE_LOC CLAVE_EDO)
keep if CLAVE_LOC>55
drop if CLAVE_LOC==99999
drop if CLAVE_LOC==99998
drop if CLAVE_LOC==99997
merge m:1 CLAVE_LOC CLAVE_EDO using "$Data_raw\EMIF\claves_eua_2020.dta"
list if _merge==1
drop if _merge==2
gen obs=1 if _merge==3
drop _merge
tempfile emif_procsur_`x'
save `emif_procsur_`x'', replace
}

/*
forvalues x=2007/2008 {
use `procsur_`x'', clear
keep  folio trim mun_nac p6_* pai_nac p13_3_1c p13_3_1e p13_3_1o //p20_1c p20_1e
duplicates drop folio trim, force
drop if pai_nac>32 // drop those that are not from mexico
replace p6_est= pai_nac if p6_pai>=2
replace p6_mun= mun_nac if p6_pai>=2
drop if p6_est==99
drop if p6_mun==999 | p6_mun==998
keep if p13_3_1c>0
// 65% of respondents dont seem to be intending to cross the border... 
gen year=`x'
rename (p13_3_1o p13_3_1e) (CLAVE_CNTY CLAVE_EDO)
*keep if CLAVE_CNTY>99
drop if CLAVE_CNTY==99999 
merge m:1 CLAVE_CNTY CLAVE_EDO using "$Data_raw\EMIF\claves_eua_2020_mun.dta"
drop if _merge==2
gen obs=1 if _merge ==3 // only those that can be matched at city (rather than state) level, drops roughly 1/3 of obs
drop _merge
merge 1:1 folio trim using `emif_procsur_`x'', update 
tempfile emif_procsur_`x'
save `emif_procsur_`x'', replace
}
*/

use `emif_procsur_1999', clear
forvalues x = 2000/2008 {
append using `emif_procsur_`x''
}
gen geo2_mx2010 = p6_est *1000 + p6_mun
recode geo2_mx2010 9001 = 9003 // All mun of mexico city, 9001 was divided up into 10 in 80s
gen geo_birth =  pai_nac *1000 + mun_nac
drop mun_nac pai_nac p6_pai p6_est p6_mun p6_loc CLAVE_LOC CLAVE_EDO unidad trim p13_3_1c p13_3_1o _merge folio
keep if county!=""
tempfile emif_procsur
save `emif_procsur', replace
compare geo_birth geo2_mx2010
//   33569/36656 (92%) have same place of birth as place of residence

forvalues x=1999/2017 {
cap erase Data_raw\EMIF\my_labels_`x'.do
cap erase Data_raw\EMIF\emif_procsur_`x'.dta
cap erase Data_raw\EMIF\procsur_`x'.dta 
}

***********************************************************************************
*** append all 

use `emif_procsur', clear
append using $Data_built\emif_pfn.dta
append using $Data_built\emif_peuat.dta
append using $Data_built\emif_dev.dta
drop Name
save "$Data_built\EMIF_all_1999_2008.dta", replace

***************************************************************************************
* Version 1 
use `emif_procsur', clear
drop Name
recode geo2_mx2010 9001 = 9003 // All mun of mexico city, 9001 was divided up into 10 in 80s

merge m:1 geo2_mx2010 using "$Data_built\Claves_1960_2010.dta"
ta geo2_mx2010 if _merge==1 // 7095 (doesnt exist in any list of claves)
keep if _merge==3
drop _merge
replace county="New York City" if county=="Kings" & state=="NY"
replace county="Hawaii" if county=="Honolulu"
replace state="AR" if county=="Ouachita"
replace county="Anchorage Borough" if county=="Anchorage"
replace county="New York City" if county=="Bronx" & state=="NY"
replace state="OK" if county=="Caddo"
replace state="MA" if county=="Norfolk"
replace county="Calcasieu Parish" if county=="Calcasieu"
replace county="Dona Ana" if county=="Do├▒a Ana"
replace state="AR" if county=="Lafayette" & state=="LA"
replace county="East Baton Rouge Parish" if county=="East Baton Rouge"
replace county="Newport News city" if county=="Newport News"
replace county="Orleans Parish" if county=="Orleans" & state=="LA"
replace county="Petersburg city" if county=="Petersburg" & state=="VA"
replace county="Virginia Beach city" if county=="Virginia Beach"
replace county="Saint Joseph" if county=="St. Joseph"
replace county="Saint Louis" if county=="St. Louis"
replace county="Terrebonne Parish" if county=="Terrebonne" 

// if we do everything in 2000 borders
bysort geo2_mx2000: gen migrants = _N
bysort geo2_mx2000: egen migwdest= count(obs)
keep if obs==1 /// count only those that could be matched at the city (rather than state) level 

collapse (mean) migwdest migrants (sum) obs, by(state county geo2_mx2000 geolev2)
gen link= obs/ migwdest // number of migrants observed in EMIF that intended to migrate to this particular county
gen precision = migwdest/migrants

merge m:1 county state using  "$Data_built\sec_comm_activation_wide.dta" 
keep if _merge==3 // many counties not connected with mex (in EMIF)
drop _merge //ym year month

merge m:1 geo2_mx2000 using "$Data_built\census2000_col.dta"
*drop if _m==2
drop _merge year mx2000a_mign persons mx2000a_migstat

reshape long sc sanc, i(state county geolev2 geo2_mx2000) j(date)
tostring date, replace
gen y=substr(date, -4,.)
egen m=ends(date) , punct(20) head
destring y, replace
destring m, replace
recode sanc .=0 if sc!=.
gen sc2 = sc * (1-sanc)

gen sc_noweight_1 = sc2 * link
gen ym = ym(y, m)
format ym %tm
drop obs // number of links county-mun
collapse (mean) precision migr_share migwdest migrants (sum) sc_noweight*, by(geo2_mx2000 geolev2 y m ym)
replace sc_noweight_1=. if precision ==.
gen sc_shock_1 = sc_noweight_1 * migr_share
replace sc_shock_1=0 if migr_share==0 
rename y year
rename m month
rename (precision migwdest)(precision_1 migwdest_1)
//label var sc_noweight "Secure communities in destination counties"
label var sc_noweight_1 "Secure communities shock (unweighted, last place of residence, EMIF sur)"
//label var sc_shock "Secure communities in destination counties (weighted by share of migrants in mun.)"
label var sc_shock_1 "Secure communities shock (weighted by share of migrants in mun.)"
label var migr_share "Average number of migrants per capita, as of census 2000"
label var precision_1 "Share of migrants from municipality with known destination (EMIF)"
label var migwdest_1 "Number of migrants (w/ known US destination) from municipio observed in EMIF"
su 

xtset geo2_mx2000 ym
foreach i in 3 6 9 12 15 18 21 24 27 30 33 36 39 42 45 48 {
gen l`i'_sc_1 = l`i'.sc_shock_1
gen l`i'_scnw_1 = l`i'.sc_noweight_1
gen f`i'_sc_1 = f`i'.sc_shock_1
gen f`i'_scnw_1 = f`i'.sc_noweight_1
recode l`i'_sc_1 .=0 if sc_shock_1!=.
recode l`i'_scnw_1 .=0 if sc_noweight_1!=.
}
*
isid geo2_mx2000 ym
save "$Data_built\Shock_EMIF_SecComm_Sanc_1.dta", replace

**************************************************************************************
* Version 2 
use `emif_procsur', clear
append using $Data_built\emif_dev.dta
drop Name
recode geo2_mx2010 9001 = 9003 // All mun of mexico city, 9001 was divided up into 10 in 80s

merge m:1 geo2_mx2010 using "$Data_built\Claves_1960_2010.dta"
ta geo2_mx2010 if _merge==1 // 7095 (doesnt exist in any list of claves)
keep if _merge==3
drop _merge
replace county="New York City" if county=="Kings" & state=="NY"
replace county="Hawaii" if county=="Honolulu"
replace state="AR" if county=="Ouachita"
replace county="Anchorage Borough" if county=="Anchorage"
replace county="New York City" if county=="Bronx" & state=="NY"
replace state="OK" if county=="Caddo"
replace state="MA" if county=="Norfolk"
replace county="Calcasieu Parish" if county=="Calcasieu"
replace county="Dona Ana" if county=="Do├▒a Ana"
replace state="AR" if county=="Lafayette" & state=="LA"
replace county="East Baton Rouge Parish" if county=="East Baton Rouge"
replace county="Newport News city" if county=="Newport News"
replace county="Orleans Parish" if county=="Orleans" & state=="LA"
replace county="Petersburg city" if county=="Petersburg" & state=="VA"
replace county="Virginia Beach city" if county=="Virginia Beach"
replace county="Saint Joseph" if county=="St. Joseph"
replace county="Saint Louis" if county=="St. Louis"
replace county="Terrebonne Parish" if county=="Terrebonne" 

// if we do everything in 2000 borders
bysort geo2_mx2000: gen migrants = _N
bysort geo2_mx2000: egen migwdest= count(obs)
keep if obs==1 /// count only those that could be matched at the city (rather than state) level 

collapse (mean) migwdest migrants (sum) obs, by(state county geo2_mx2000 geolev2)
gen link= obs/ migwdest // number of migrants observed in EMIF that intended to migrate to this particular county
gen precision = migwdest/migrants

merge m:1 county state using  "$Data_built\sec_comm_activation_wide.dta" 
keep if _merge==3 // many counties not connected with mex (in EMIF)
drop _merge //ym year month

merge m:1 geo2_mx2000 using "$Data_built\census2000_col.dta"
*drop if _m==2
drop _merge year mx2000a_mign persons mx2000a_migstat

reshape long sc sanc, i(state county geolev2 geo2_mx2000) j(date)
tostring date, replace
gen y=substr(date, -4,.)
egen m=ends(date) , punct(20) head
destring y, replace
destring m, replace
recode sanc .=0 if sc!=.
gen sc2 = sc * (1-sanc)

gen sc_noweight_2 = sc2 * link
gen ym = ym(y, m)
format ym %tm
drop obs // number of links county-mun
collapse (mean) precision migr_share migwdest migrants (sum) sc_noweight*, by(geo2_mx2000 geolev2 y m ym)
replace sc_noweight_2=. if precision ==.
gen sc_shock_2 = sc_noweight_2 * migr_share
replace sc_shock_2=0 if migr_share==0 
rename y year
rename m month
rename (precision migwdest)(precision_2 migwdest_2)
label var sc_noweight_2 "Secure communities (unweighted, place of residence, EMIF sur & devueltos)"
label var sc_shock_2 "Secure communities shock (weighted by share of migrants in mun.)"
label var migr_share "Average number of migrants per capita, as of census 2000"
label var precision_2 "Share of migrants from municipality with known destination (EMIF)"
label var migwdest_2 "Number of migrants (w/ known US destination) from municipio observed in EMIF"
su 

xtset geo2_mx2000 ym
foreach i in 3 6 9 12 15 18 21 24 27 30 33 36 39 42 45 48 {
gen l`i'_sc_2 = l`i'.sc_shock_2
gen l`i'_scnw_2 = l`i'.sc_noweight_2
gen f`i'_sc_2 = f`i'.sc_shock_2
gen f`i'_scnw_2 = f`i'.sc_noweight_2
recode l`i'_sc_2 .=0 if sc_shock_2!=.
recode l`i'_scnw_2 .=0 if sc_noweight_2!=.
}
*
isid geo2_mx2000 ym
save "$Data_built\Shock_EMIF_SecComm_Sanc_2.dta", replace

**************************************************************************************
* Version 3 
use "$Data_built\EMIF_all_1999_2008.dta", clear
recode geo2_mx2010 9001 = 9003 // All mun of mexico city, 9001 was divided up into 10 in 80s
merge m:1 geo2_mx2010 using "$Data_built\Claves_1960_2010.dta"
ta geo2_mx2010 if _merge==1 // 7095 (doesnt exist in any list of claves)
keep if _merge==3
drop _merge
replace county="New York City" if county=="Kings" & state=="NY"
replace county="Hawaii" if county=="Honolulu"
replace state="AR" if county=="Ouachita"
replace county="Anchorage Borough" if county=="Anchorage"
replace county="New York City" if county=="Bronx" & state=="NY"
replace state="OK" if county=="Caddo"
replace state="MA" if county=="Norfolk"
replace county="Calcasieu Parish" if county=="Calcasieu"
replace county="Dona Ana" if county=="Do├▒a Ana"
replace state="AR" if county=="Lafayette" & state=="LA"
replace county="East Baton Rouge Parish" if county=="East Baton Rouge"
replace county="Newport News city" if county=="Newport News"
replace county="Orleans Parish" if county=="Orleans" & state=="LA"
replace county="Petersburg city" if county=="Petersburg" & state=="VA"
replace county="Virginia Beach city" if county=="Virginia Beach"
replace county="Saint Joseph" if county=="St. Joseph"
replace county="Saint Louis" if county=="St. Louis"
replace county="Terrebonne Parish" if county=="Terrebonne" 

// if we do everything in 2000 borders
bysort geo2_mx2000: gen migrants = _N
bysort geo2_mx2000: egen migwdest= count(obs)
keep if obs==1 /// count only those that could be matched at the city (rather than state) level 

collapse (mean) migwdest migrants (sum) obs, by(state county geo2_mx2000 geolev2)
gen link= obs/ migwdest // number of migrants observed in EMIF that intended to migrate to this particular county
gen precision = migwdest/migrants

merge m:1 county state using  "$Data_built\sec_comm_activation_wide.dta" 
keep if _merge==3 // many counties not connected with mex (in EMIF)
drop _merge //ym year month

merge m:1 geo2_mx2000 using "$Data_built\census2000_col.dta"
*drop if _m==2
drop _merge year mx2000a_mign persons mx2000a_migstat

reshape long sc sanc, i(state county geolev2 geo2_mx2000) j(date)
tostring date, replace
gen y=substr(date, -4,.)
egen m=ends(date) , punct(20) head
destring y, replace
destring m, replace
recode sanc .=0 if sc!=.
gen sc2 = sc * (1-sanc)

gen sc_noweight_3 = sc2 * link
gen ym = ym(y, m)
format ym %tm
drop obs // number of links county-mun
collapse (mean) precision migr_share migwdest migrants (sum) sc_noweight*, by(geo2_mx2000 geolev2 y m ym)
replace sc_noweight_3=. if precision ==.
gen sc_shock_3 = sc_noweight_3 * migr_share
replace sc_shock_3=0 if migr_share==0 
rename y year
rename m month
rename (precision migwdest)(precision_3 migwdest_3)
label var sc_noweight_3 "Secure communities shock (unweighted, place of residence or destination)"
label var sc_shock_3 "Secure communities shock (weighted by share of migrants in mun.)"
label var migr_share "Average number of migrants per capita, as of census 2000"
label var precision_3 "Share of migrants from municipality with known destination (EMIF)"
label var migwdest_3 "Number of migrants (w/ known US destination) from municipio observed in EMIF"
su 

xtset geo2_mx2000 ym
foreach i in 3 6 9 12 15 18 21 24 27 30 33 36 39 42 45 48 {
gen l`i'_sc_3 = l`i'.sc_shock_3
gen f`i'_sc_3 = f`i'.sc_shock_3
recode l`i'_sc_3 .=0 if sc_shock_3!=.
gen l`i'_scnw_3 = l`i'.sc_noweight_3
gen f`i'_scnw_3 = f`i'.sc_noweight_3
recode l`i'_scnw_3 .=0 if sc_noweight_3!=.
}
*
isid geo2_mx2000 ym
save "$Data_built\Shock_EMIF_SecComm_Sanc_3.dta", replace

****************************************************************************************
*Version 4
// need to map municipalities in mexico
use "$Data_built\EMIF_all_1999_2008.dta", clear
*replace geo_birth = geo2_mx2010 if geo_birth> 32057
*egen mun_miss = anymatch(geo_birth), v(30999 28999 25999 24999 22998 21999 20999 18999 17999 16999 15998 15999 14999 14998 13999 12999 12998 11999 10999 9999 8999 7999 6999 5999 4999 3999 2999 1999) 
*replace geo_birth = geo2_mx2010 if mun_miss==1
drop geo2_mx2010
rename geo_birth geo2_mx2010
recode geo2_mx2010 9001 = 9003 // All mun of mexico city, 9001 was divided up into 10 in 80s

merge m:1 geo2_mx2010 using "$Data_built\Claves_1960_2010.dta"
ta geo2_mx2010 if _merge==1 // 7095 (doesnt exist in any list of claves)
keep if _merge==3
drop _merge
replace county="New York City" if county=="Kings" & state=="NY"
replace county="Hawaii" if county=="Honolulu"
replace state="AR" if county=="Ouachita"
replace county="Anchorage Borough" if county=="Anchorage"
replace county="New York City" if county=="Bronx" & state=="NY"
replace state="OK" if county=="Caddo"
replace state="MA" if county=="Norfolk"
replace county="Calcasieu Parish" if county=="Calcasieu"
replace county="Dona Ana" if county=="Do├▒a Ana"
replace state="AR" if county=="Lafayette" & state=="LA"
replace county="East Baton Rouge Parish" if county=="East Baton Rouge"
replace county="Newport News city" if county=="Newport News"
replace county="Orleans Parish" if county=="Orleans" & state=="LA"
replace county="Petersburg city" if county=="Petersburg" & state=="VA"
replace county="Virginia Beach city" if county=="Virginia Beach"
replace county="Saint Joseph" if county=="St. Joseph"
replace county="Saint Louis" if county=="St. Louis"
replace county="Terrebonne Parish" if county=="Terrebonne" 


// if we do everything in 2000 borders
bysort geo2_mx2000: gen migrants = _N
bysort geo2_mx2000: egen migwdest= count(obs)
keep if obs==1 /// count only those that could be matched at the city (rather than state) level 

collapse (mean) migwdest migrants (sum) obs, by(state county geo2_mx2000 geolev2)
gen link= obs/ migwdest // number of migrants observed in EMIF that intended to migrate to this particular county
gen precision = migwdest/migrants

merge m:1 county state using  "$Data_built\sec_comm_activation_wide.dta" 
keep if _merge==3 // many counties not connected with mex (in EMIF)
drop _merge //ym year month

merge m:1 geo2_mx2000 using "$Data_built\census2000_col.dta"
*drop if _m==2
drop _merge year mx2000a_mign persons mx2000a_migstat

reshape long sc sanc, i(state county geolev2 geo2_mx2000) j(date)
tostring date, replace
gen y=substr(date, -4,.)
egen m=ends(date) , punct(20) head
destring y, replace
destring m, replace
recode sanc .=0 if sc!=.
gen sc2 = sc * (1-sanc)

gen sc_noweight_4 = sc2 * link
//gen sc_noweight2 = sc2 *link
gen ym = ym(y, m)
format ym %tm
drop obs // number of links county-mun
collapse (mean) precision migr_share migwdest migrants (sum) sc_noweight*, by(geo2_mx2000 geolev2 y m ym)
//replace sc_noweight=. if precision ==.
replace sc_noweight_4=. if precision ==.

/*recode precision .=0 
merge m:1 m y using "SecureComm\sec_comm_activation_usav.dta" 
drop _m

replace sc_noweight = sc_noweight + (1- precision) * us_av_SC
replace sc_noweight = us_av_SC if sc_noweight==.
replace sc_noweight2 = sc_noweight2 + (1- precision) * us_av_SCsanc
replace sc_noweight2 = us_av_SCsanc if sc_noweight2==.
*/
gen sc_shock_4 = sc_noweight_4 * migr_share
replace sc_shock_4=0 if migr_share==0 
rename y year
rename m month
rename (precision migwdest)(precision_4 migwdest_4)
label var sc_noweight_4 "Secure communities shock (unweighted, birth place)"
label var sc_shock_4 "Secure communities shock (weighted by share of migrants in mun.)"
label var migr_share "Average number of migrants per capita, as of census 2000"
label var precision_4 "Share of migrants from municipality with known destination (EMIF)"
label var migwdest_4 "Number of migrants (w/ known US destination) from municipio observed in EMIF"
su 

xtset geo2_mx2000 ym

foreach i in 3 6 9 12 15 18 21 24 27 30 33 36 39 42 45 48 {
gen l`i'_sc_4 = l`i'.sc_shock_4
gen f`i'_sc_4 = f`i'.sc_shock_4
recode l`i'_sc_4 .=0 if sc_shock_4!=.
gen l`i'_scnw_4 = l`i'.sc_noweight_4
gen f`i'_scnw_4 = f`i'.sc_noweight_4
recode l`i'_scnw_4 .=0 if sc_noweight_4!=.
}
*
isid geo2_mx2000 ym


*
/*
CODE FROM ESTHER
forvalues x=1/3 {
sort geo2_mx2000 ym
by geo2_mx2000: carryforward f`x'_sc2, replace
by geo2_mx2000: carryforward f`x'_sc, replace
}

foreach var in sc2 sc {
replace f1_`var'=0 if year==2014
replace f2_`var'=0 if year==2013 | year==2014
replace f3_`var'=0 if year==2012 | year==2013 | year==2014
}

*/

save "$Data_built\Shock_EMIF_SecComm_Sanc_4.dta", replace
// v4: links based on birthplace
// v3: links based on last place of residence/ and or destination 
// v2: links based on last place of residence (procedentes del sur and devueltos)
// v1: links based on last place of residence (procedentes del sur only)

******************************************************************************************************************


cap erase $Data_built\EMIF_all_1999_2008.dta

cap erase $Data_built\emif_pfn.dta
cap erase $Data_built\emif_peuat.dta
cap erase $Data_built\emif_dev.dta

*********
