/*

clear all 
set more off


* This dofile merges the EMIF norte data to establish origin-destination networks 
* between mexico and the US
* So far, I am only using the "procedentes del sur" files, and intended destinations
* could extend this by looking at past destinations (also procsur), or at return migrants 

* Esther Gehrke, May 23, 2019

// import the file
cd "C:\Users\gehrk001\Dropbox\MigrationShocks\"
*global graphs "C:\Users\gehrk001\Dropbox\MigrationShocks\Output\Graphs\"

*Claire
cd "C:\Users\Claire\Dropbox\MigrationShocks\"
*/
************************************************************************************
*PREP:

*Input files:
*files of type:
*Data_raw\EMIF\PDS_Descriptores_`x'.csv
*Data_raw\EMIF\ENORTE_procsur`x'.csv
*Data_raw\EMIF\SUR_`x'.csv
*Data_raw\EMIF\PDS_Valores_`x'.csv

*Data_raw\EMIF\claves_eua_2003.dta (not sure if these are raw or built)
*Data_raw\EMIF\claves_eua_2000.dta

*Data_raw\MexCensus\census2000_col.dta

*Data_built\Claves\Claves_1960_2010.dta(built in mun_keys.do)
*Data_built\SecureComm\sec_comm_activation_wide.dta(built in secure_communities.do)

*label files:
*git_migshks_code\EMIFlabels\my_labels_`x'.do
*git_migshks_code\EMIFlabels\my_values_2003.do

*Output files: 
*Data_built\EMIF\Shock_EMIF_SecComm_Sanc_2.dta

************************************************************************************


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
file open `fh' using $dofiles\EMIFlabels\my_labels_`x'.do , write replace
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
file open `fh' using $dofiles\EMIFlabels\my_labels_`x'.do , write replace
forvalues i = 1/`N' {
    file write `fh' "label variable `= variable[`i']' "
    file write `fh' `""`= eti[`i']'""' _newline
}
file close `fh'
// look at new dofile
type $dofiles\EMIFlabels\my_labels_`x'.do
}

// now get value labels
import delimited $Data_raw\EMIF\PDS_Valores_1999.csv , clear
keep in 1/`= _N-1'
tempname fh
local N = c(N)
file open `fh' using $dofiles\EMIFlabels\my_values_2003.do , write append
file write `fh' _newline
forvalues i = 1/`N' {
     file write `fh' "label define `=var[`i']' `=valor[`i']' "
     file write `fh' `""`=descr[`i']'" , modify"' _newline 
}
file close `fh'

// look at new dofile
type $dofiles\EMIFlabels\my_values_2003.do


forvalues x=1999/2012 {
import delimited $Data_raw\EMIF\ENORTE_procsur`x'.csv, clear
do $dofiles\EMIFlabels\my_labels_`x'.do
tempfile procsur_`x'
save `procsur_`x''
}

forvalues x=2013/2016 {
import delimited $Data_raw\EMIF\SUR_`x'.csv, clear
do $dofiles\EMIFlabels\my_labels_`x'.do
tempfile procsur_`x'
save `procsur_`x''
}

******************* 
* Value labels

forvalues x=1999/2012 {
import delimited $Data_raw\EMIF\PDS_Valores_`x'.csv , clear
capture rename variable variable
capture rename variales variable
replace variable = strlower(variable)
keep if variable=="mun_nac" | variable=="p13_3_1c" | variable=="p13_3_1e" 
capture rename variable variable
capture rename variales variable
//rename val val`x'
rename descripción descripción`x'
tempfile pds_val_`x'
save `pds_val_`x''
}

/*
use EMIF\pds_val_1999.dta, clear
merge 1:1 var val using EMIF\pds_val_2000
drop _merge
forvalues x=2001/2003 {
merge 1:1 var val using EMIF\pds_val_`x'
drop _merge
}
** codes are uniform 1999 - 2003 (except municipalities in 2003
use EMIF\pds_val_2004.dta, clear
merge 1:1 var val using EMIF\pds_val_2005
drop _merge
forvalues x=2001/2003 {
merge 1:1 var val using EMIF\pds_val_`x'
drop _merge
}
*/
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

rename CLAVE CLAVE_LOC


/* Check if works...
duplicates drop county state, force
merge 1:m county state using "C:\Users\esthe\ownCloud\gehrke8\Data\Mexico\SecureComm\sec_comm_activation.dta"
*/
tempfile codes_emif_1999
save `codes_emif_1999'

*****************************************
* Clean and append data

forvalues x=1999/2002 { 
use `procsur_`x'', clear
keep  folio  mun_nac p6_* pai_nac p13_3_1c p13_3_1e //p20_1c p20_1e
// drop those that are not from mexico
drop if p6_est==99
drop if p6_mun==999 | p6_mun==998
keep if p13_3_1c>0
// 65% of respondents dont seem to be intending to cross the border... 
gen year=`x'
rename (p13_3_1c p13_3_1e) (CLAVE_LOC CLAVE_EDO)
merge m:1 CLAVE_LOC using `codes_emif_1999'
ta CLAVE_LOC if _merge==1
drop if _merge==2
gen obs=1 if _merge ==3 // only those that can be matched at city (rather than state) level, drops roughly 1/3 of obs
drop _merge
display `x'
drop descripción1999
*replace weight = c(N) * weight
*bysort p6_est p6_mun: gen obspmun = _N
tempfile emif_`x'
save `emif_`x''
}

** 2003 forward has mixed code system
use `procsur_2003', clear
keep  folio  mun_nac p6_* pai_nac p13_3_1c p13_3_1e //p20_1c p20_1e
// drop those that are not from mexico
drop if p6_est==99
drop if p6_mun==999 | p6_mun==998
keep if p13_3_1c>0
// 65% of respondents dont seem to be intending to cross the border... 
gen year=2003
*bysort p6_est p6_mun: gen migpmun = _N
rename (p13_3_1c p13_3_1e) (CLAVE_LOC CLAVE_EDO)
keep if CLAVE_LOC<=55
merge m:1 CLAVE_LOC using `codes_emif_1999'
ta CLAVE_LOC if _merge==1
drop if _merge==2
gen obs=1 if _merge ==3 // only those that can be matched at city (rather than state) level, drops roughly 1/3 of obs
drop _merge
drop descripción1999
tempfile emif_2003
save `emif_2003'

use `procsur_2003', clear
keep  folio  mun_nac p6_* pai_nac p13_3_1c p13_3_1e //p20_1c p20_1e
// drop those that are not from mexico
drop if p6_est==99
drop if p6_mun==999 | p6_mun==998
keep if p13_3_1c>0
// 65% of respondents dont seem to be intending to cross the border... 
gen year=2003
*bysort p6_est p6_mun: gen migpmun = _N
rename (p13_3_1c p13_3_1e) (CLAVE_LOC CLAVE_EDO)
keep if CLAVE_LOC>99
drop if CLAVE_LOC==99999 
merge m:1 CLAVE_LOC using "$Data_raw\EMIF\claves_eua_2003.dta"
ta CLAVE_LOC if _merge==1
drop if _merge==2
gen obs=1 if _merge ==3 // only these that can be matched at city (rather than state) level, drops roughly 1/3 of obs
drop _merge
append using `emif_2003' 
drop PMSA MSA LOCALIDADCIUDAD CLAVE_CNTY ESTADO METROPOLIS
*bysort p6_est p6_mun: gen obspmun = _N
tempfile emif_2003
save `emif_2003', replace

** make codes comparable in years 2004 - 2008 
forvalues x=2004/2008 {
use `procsur_`x'', clear
keep  folio  mun_nac p6_* pai_nac p13_3_1c p13_3_1e //p20_1c p20_1e
// drop those that are not from mexico
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
merge m:1 CLAVE_LOC CLAVE_EDO using "$Data_raw\EMIF\claves_eua_2000.dta"
list if _merge==1
drop if _merge==2
gen obs=1 if _merge==3
drop _merge
tempfile emif_`x'
save `emif_`x'', replace

use `procsur_`x'', clear
keep  folio  mun_nac p6_* pai_nac p13_3_1c p13_3_1e //p20_1c p20_1e
// drop those that are not from mexico
drop if p6_est==99
drop if p6_mun==999 | p6_mun==998
keep if p13_3_1c>0
// 65% of respondents dont seem to be intending to cross the border... 
gen year=`x'
rename (p13_3_1c p13_3_1e) (CLAVE_LOC CLAVE_EDO)
keep if CLAVE_LOC<=55
merge m:1 CLAVE_LOC using `codes_emif_1999'
ta CLAVE_LOC if _merge==1
drop if _merge==2
gen obs=1 if _merge==3
drop _merge
append using `emif_`x''
drop descripción1999 PMSA MSA LOCALIDADCIUDAD CLAVE_CNTY ESTADO METROPOLIS
save `emif_`x'', replace
}

***********************************************************************************
*** append all 

use `emif_1999', clear
forvalues x = 2000/2008 {
append using `emif_`x''
}
save "$Data_built\EMIF_1999_2008.dta", replace

// need to map municipalities in mexico
gen geo2_mx2010 = p6_est *1000 + p6_mun
recode geo2_mx2010 9001 = 9003 // All mun of mexico city, 9001 was divided up into 10 in 80s

merge m:1 geo2_mx2010 using "$Data_built\Claves_1960_2010.dta"
ta geo2_mx2010 if _merge==1 // 7095 (doesnt exist in any list of claves)
keep if _merge==3
drop _merge
replace county="New York City" if county=="Kings" & state=="NY"
replace county="Hawaii" if county=="Honolulu"

// if we do everything in 2000 borders
bysort geo2_mx2000: gen migrants = _N
bysort geo2_mx2000: egen migwdest= count(obs)
keep if obs==1 /// count only those that could be matched at the city (rather than state) level 

collapse (mean) migwdest migrants (sum) obs, by(state county geo2_mx2000 geolev2)
gen link= obs/ migrants // number of migrants observed in EMIF that intended to migrate to this particular county
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

gen scweight = sc * link
gen scweight2 = sc2 *link
gen ym = ym(y, m)
format ym %tm

collapse (mean) precision migr_share obs  migwdest migrants (sum) scweight*, by(geo2_mx2000 geolev2 y m ym)
replace scweight=. if precision ==.
replace scweight2=. if precision ==.

/*recode precision .=0 
merge m:1 m y using "SecureComm\sec_comm_activation_usav.dta" 
drop _m

replace scweight = scweight + (1- precision) * us_av_SC
replace scweight = us_av_SC if scweight==.
replace scweight2 = scweight2 + (1- precision) * us_av_SCsanc
replace scweight2 = us_av_SCsanc if scweight2==.
*/
gen sc_shock = scweight * migr_share
gen sc_shock2 = scweight2 * migr_share
replace sc_shock=0 if migr_share==0 
replace sc_shock2=0 if migr_share==0 


rename y year
rename m month
label var scweight "Secure communities in destination counties"
label var scweight2 "Secure communities in destination counties minus sanctury cities"
label var sc_shock "Secure communities in destination counties (weighted by share of migrants in mun.)"
label var sc_shock2 "Secure communities in destination counties - sanc. cities (weighted by share of migrants in mun.)"

*label var us_av_SC "Secure communities, US average"
*label var us_av_SCsanc "Secure communities - sanctury cities, US average"
*label var us_av_sanc "Sanctury cities, US average"

label var migr_share "Average number of migrants per capita, as of census 2000"
label var precision "Share of migrants from municipality with known destination (EMIF)"
su 

xtset geo2_mx2000 ym


/*forvalues x=1/24 {
gen l`x'_sc = l`x'.sc_shock
gen l`x'_sc2 = l`x'.sc_shock2
recode l`x'_sc2 .=0 if sc_shock!=.
recode l`x'_sc .=0 if sc_shock!=.
}

forvalues x=1/24 {
gen f`x'_sc = f`x'.sc_shock
gen f`x'_sc2 = f`x'.sc_shock2
sort geo2_mx2000 ym
by geo2_mx2000: carryforward f`x'_sc2, replace
by geo2_mx2000: carryforward f`x'_sc, replace
}
*/


foreach i in 3 6 9 12 15 18 21 24 27 30 33 36 {
gen l`i'_sc = l`i'.sc_shock
gen l`i'_sc2 = l`i'.sc_shock2
gen f`i'_sc = f`i'.sc_shock
gen f`i'_sc2 = f`i'.sc_shock2
recode l`i'_sc2 .=0 if sc_shock!=.
recode l`i'_sc .=0 if sc_shock!=.

}
*
isid geo2_mx2000 ym
*stop


*
/*
CODE FROM ESTHER
gen l1_sc = l12.sc_shock
gen l1_sc2 = l12.sc_shock2
gen f1_sc = f12.sc_shock
gen f1_sc2 = f12.sc_shock2
gen l2_sc = l24.sc_shock
gen l2_sc2 = l24.sc_shock2
gen f2_sc = f24.sc_shock
gen f2_sc2 = f24.sc_shock2
recode l1_sc2 .=0 if sc_shock!=.
recode l1_sc .=0 if sc_shock!=.
recode l2_sc2 .=0 if sc_shock!=.
recode l2_sc .=0 if sc_shock!=.

gen l3_sc = l36.sc_shock
gen l3_sc2 = l36.sc_shock2
gen f3_sc = f36.sc_shock
gen f3_sc2 = f36.sc_shock2
recode l3_sc2 .=0 if sc_shock!=.
recode l3_sc .=0 if sc_shock!=.

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

/*
this did not work!
forvalues x=2/4 {
local y = `x' * 12
gen l`x'_sc = l`y'.sc_shock
gen l`x'_sc2 = l`y'.sc_shock2
recode l`x'_sc .=0
recode l`x'_sc2 .=0
gen f`x'_sc = f`x'.sc_shock
gen f`x'_sc2 = f`x'.sc_shock2
replace f`x'_sc = migr_share if f`x'_sc==.
// cant't do equivalent for sc2, because more places became sanctury after... 
}
*/

save "$Data_built\Shock_EMIF_SecComm_Sanc_2.dta", replace

cap erase "$Data_built\EMIF_1999_2008.dta"
******************************************************************************************************************


*********
