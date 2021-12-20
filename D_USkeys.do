

import excel "$Data_raw\EMIF\bas21_codes.xlsx", sheet("Sheet1") first clear
drop BASID 
gen CLAVE_LOC=substr(GEOIDforTIGERweb, 3, .)
rename (CountyFIPS StateFIPS CountyName StateAbbreviation) (CLAVE_CNTY CLAVE_EDO county state)
drop ANSICode MTDBExpandedLsad GEOIDforTIGERweb
destring CLAVE_LOC CLAVE_EDO CLAVE_CNTY, replace
// a number of cities (with same name and city code) are in two different counties. For nw just arbitrarily drop duplicates  
duplicates tag CLAVE_EDO CLAVE_LOC, gen(dup)
sort CLAVE_EDO CLAVE_LOC CLAVE_CNTY
bysort CLAVE_EDO CLAVE_LOC: gen count=_n
drop if count>1
drop count dup
save "$Data_built\claves_eua_2020.dta", replace

keep CLAVE_EDO state CLAVE_CNTY county
duplicates drop
save "$Data_built\claves_eua_2020_mun.dta", replace

cap erase "$Data_built\claves_eua_2020.dta"