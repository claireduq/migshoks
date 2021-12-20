
*cd "C:\Users\gehrk001\Dropbox\MigrationShocks\"


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
file open `fh' using  $dofiles\EMIFlabels\my_labels_`x'.do , write replace
forvalues i = 1/`N' {
    file write `fh' "label variable `= variable[`i']' "
    file write `fh' `""`= desc[`i']'""' _newline
}
file close `fh'
// look at new dofile
type  $dofiles\EMIFlabels\my_labels_`x'.do
}


forvalues x=2005/2012 {
import delimited $Data_raw\EMIF\ENORTE_procsur`x'.csv, clear
do  $dofiles\EMIFlabels\my_labels_`x'.do
tempfile procsur_`x'
save `procsur_`x''
}

forvalues x=2013/2016 {
import delimited $Data_raw\EMIF\SUR_`x'.csv, clear
do  $dofiles\EMIFlabels\my_labels_`x'.do
tempfile procsur_`x'
save `procsur_`x''
}


********************************************************************************
forvalues x=2005/2006 {
use `procsur_`x'', clear
keep  folio  mun_nac pai_nac p6_* p13 p13_3_1c p13_3_1e unidad //p20_1c p20_1e
// drop those that are not from mexico
drop if p13==-1 | p13==2 // don't want to cross border
rename p6_est estado
rename p6_mun mun
rename pai_nac est_nac
gen year=`x'
rename (p13_3_1c p13_3_1e) (CLAVE_LOC CLAVE_EDO)
tempfile emif_`x'
save `emif_`x'', replace
} 


forvalues x=2007/2009 {
use `procsur_`x'', clear
keep  folio  mun_nac pai_nac p6_* p13 p13_3_1c p13_3_1e f_mes f_ano //p20_1c p20_1e
// drop those that are not from mexico
drop if p13==-1 | p13==2 // don't want to cross border
rename p6_est estado
rename p6_mun mun
rename pai_nac est_nac
gen year=`x'
rename (p13_3_1c p13_3_1e) (CLAVE_LOC CLAVE_EDO)
tempfile emif_`x'
save `emif_`x'', replace
} 


** make codes comparable in years 2010 - 2011 
forvalues x=2010/2010 {
use `procsur_`x'', clear
keep  folio p9_* p10_* p16 p19_1c p19_1o p19_1e fecha //p20_1c p20_1e
drop if p16==-1 | p16==-3 | p16==2
// drop those that are not from mexico
rename p10_est estado
rename p10_mun mun
rename p9_mun mun_nac
rename p9_est est_nac
gen year=`x'
rename (p19_1c p19_1e) (CLAVE_LOC CLAVE_EDO)
tempfile emif_`x'
save `emif_`x'', replace
}

forvalues x=2011/2011 {
use `procsur_`x'', clear
keep  folio p9_* p10_* p16 p19_1c p19_1o p19_1e unidad trim //p20_1c p20_1e
drop if p16==-1 | p16==-3 | p16==2
// drop those that are not from mexico
rename p10_est estado
rename p10_mun mun
rename p9_mun mun_nac
rename p9_est est_nac
gen year=`x'
rename (p19_1c p19_1e) (CLAVE_LOC CLAVE_EDO)
tempfile emif_`x'
save `emif_`x'', replace
}



** make codes comparable in years 2012 - 2016 
forvalues x=2012/2014 {
use `procsur_`x'', clear
keep  folio  p9_* p10_* p17 p21_1c p21_1o p21_1e unidad trim //p20_1c p20_1e
// drop those that are not from mexico
drop if p17==-1 | p17==2  | p17==-3 
rename p9_est est_nac
rename p9_mun mun_nac
rename p10_est estado
rename p10_mun mun 
gen year=`x'
rename (p21_1c p21_1e) (CLAVE_LOC CLAVE_EDO)
tostring CLAVE_LOC p21_1o, replace
replace CLAVE_LOC =  regexr(CLAVE_LOC,p21_1o,"")
destring CLAVE_LOC, replace
tempfile emif_`x'
save `emif_`x'', replace
}

use `emif_2005', clear
forvalues x = 2006/2014 {
append using `emif_`x''
}

cap drop *_loc *_1o 
drop *_pai p9_1
tempfile EMIF_2005_2014
save `EMIF_2005_2014', replace

use `EMIF_2005_2014', clear
replace estado = est_nac if estado==-2 | estado ==98 | estado==99
drop if estado==97 |  estado ==98 | estado==99

replace mun=mun_nac if mun==-2 | mun==99997 | mun==99998 | mun==99999
drop if mun==999 | mun==998 | mun==997 // can't locate
drop if mun==99997 | mun==99998 | mun==99999

gen geo2_mx2017 = mun
replace geo2_mx2017=estado *1000 + mun if mun<1001
//recode geo2_mx2010 9001 = 9003 // All mun of mexico city, 9001 was divided up into 10 in 80s

merge m:1 geo2_mx2017 using "$Data_built\Claves_1960_2017.dta"
ta geo2_mx2010 if _merge==1 // 7095 (doesnt exist in any list of claves)
keep if _merge==3
drop _merge
gen migrant=1

tostring fecha,  replace
gen fe_mo= substr(fecha,-4,2)
destring fe_mo, replace
tostring unidad, replace
gen month = substr(unidad, -2, 2)
destring month, replace
replace month = f_mes if month==.
replace month = fe_mo if month==.

drop f_mes f_ano unidad  trim

collapse (count) migrant, by(geo2_mx2000 month year)
tempfile EMIF_migrants_2005_2014
save `EMIF_migrants_2005_2014', replace

merge m:1 geo2_mx2000 year month using "$Data_built\Shock_EMIF_SecComm_Sanc_2.dta"
drop _merge

merge m:1 geo2_mx2000 using "$Data_raw\census2010_col2.dta"
drop _merge 
recode migrant .=0
gen edate = mdy(1, 1, year)
gen ret_share = migrant/mx2010a_migrants
keep if year>=2005
*keep if year<=2010

save $Data_built\EMIF_migr_shock.dta, replace

*********************************************************************************

/*
use Data_built\EMIF\EMIF_migr_shock.dta, clear

gen migrants_pton = (migrant*100000)/persons

global fem i.year##i.month i.edate##i.geo1_mx2000 i.geo2_mx2000

reghdfe migrants_pton f12_sc2 f9_sc2 f6_sc2 f3_sc2 sc_shock2 l3_sc2 l6_sc2 l9_sc2 l12_sc2 l15_sc2 c.migr_share#i.year if migr_share>0 [aw=persons],  a($fem) cluster(geo2_mx2000)

reghdfe migrants_pton f6_sc2  sc_shock2 l6_sc2 l12_sc2 l18_sc2 l24_sc2 c.migr_share#i.year if migr_share>0 [aw=persons],  a($fem) cluster(geo2_mx2000)
reghdfe migrants_pton f12_sc2 migr_share sc_shock2 l6_sc2 l12_sc2 l18_sc2 l24_sc2  if migr_share>0 [aw=persons],  a($fem) cluster(geolev2)


gen logmigrant = log(migrant+1)
reghdfe logmigrant f12_sc2 f9_sc2  f6_sc2  f3_sc2  sc_shock2  l3_sc2 l6_sc2  l9_sc2 l12_sc2 l15_sc2 c.migr_share#i.year if migr_share>0 , a($fem) cluster(geo2_mx2000)
*/