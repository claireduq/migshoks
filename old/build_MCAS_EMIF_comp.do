clear all
set more off


********************************************************************************
** This dofile creates the mexican dataset on time use of adolescents
* Esther Gehrke
* March, 20 2019


********************************************************************************
*Esther
if "`c(username)'"=="gehrk001" {
	cap cd "C:\Users\gehrk001\Dropbox\MigrationShocks\"
}
if "`c(username)'"=="esthe" {
	cap cd "C:\Users\esthe\Dropbox\MigrationShocks\"
}
*Claire laptop
if "`c(username)'"=="Claire" {
	cap cd "C:\Users\Claire\Dropbox\MigrationShocks\"
}

*Claire Desktop
if "`c(username)'"=="johnh" {
	cap cd "C:\Users\johnh\Dropbox\MigrationShocks\"
}

********************************************************************************
*PREP:
*Input Files: 
*files of type: 
*Data_raw\ENOE\SDEMT`x'`y'.dta
*Data_raw\ENOE\HOGT`x'`y'.dta 
*Data_built\Claves\Claves_1960_2015.dta
*Data_built\EMIF\Shock_EMIF_SecComm_Sanc_2.dta


*Output Files:
*files of type: Data_built\ENOE\educT`x'`y'.dta
*Data_built\ENOE\educENOE.dta
*Data_built\ENOE\ENOE_educ_shock.dta


*********************************************************************************
*********************************************************************************
use Data/MCAS_states/matriculas2006_2013.dta

sort cve_ent cve_mun 
by cve_ent cve_mun : egen tester1=total(matricula)

sort cve_ent year
by cve_ent year: egen tester2=total(matricula)

sort state year 
by state year: egen tester3=total(matricula)

keep if year<=2008

*count muni to state in this windw
sort cve_ent cve_mun state
by cve_ent cve_mun state: egen tot_muni2state_mcas=total(matricula)

*all migrants from a muni
sort cve_ent cve_mun
by cve_ent cve_mun: egen tot_muni_mcas=total(matricula)

*gen muni_state_shareofmuni_mcas= muni2state/muni

keep state cve_ent nom_ent cve_mun nom_mun tot_muni2state_mcas tot_muni_mcas 
duplicates drop

statastates, name(state)
gen geo2_mx2000 = cve_ent*1000 + cve_mun
tostring geo2_mx2000, format(%05.0f) replace

*merge m:1 geo2_mx2000 using Data_built\Claves\Claves_1960_2015.dta
egen muni_st=concat(geo2_mx2000 state_abbrev), punct("_")

keep muni_st geo2_mx2000 state_abbrev tot_muni_mcas tot_muni2state_mcas nom_mun nom_ent 

save Data_built/MCAS/MCAS_muni2states.dta, replace

*************************
clear

use  "Data_built\EMIF\EMIF_all_1999_2008.dta", clear
replace county="New York City" if county=="Kings" & state=="NY"
replace county="Hawaii" if county=="Honolulu"
replace county="District of Columbia" if county=="DC"
replace state="MA" if county=="Norfolk"
replace state="DC" if county=="District of Columbia"
replace state="AR" if county=="Ouachita"
replace county="Anchorage Borough" if county=="Anchorage"
replace county="New York City" if county=="Bronx" & state=="NY"
replace state="OK" if county=="Caddo"
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

*matriculas has place of birth so using that here.
drop if geo_birth==.
drop if state==""
drop if county==""
drop if geo_birth>95000
gen geo_birth2=geo_birth
tostring geo_birth2, format(%05.0f) replace
gen miss=substr(geo_birth2,3,3)
destring miss, replace
drop if miss>990
drop miss 

sort state county geo_birth
by state county geo_birth: egen tot_muni2county_emif=total(obs)

sort state geo_birth
by state geo_birth: egen tot_muni2state_emif=total(obs)

sort geo_birth
by geo_birth: egen tot_muni_emif=total(obs)


keep state county geo_birth geo_birth2 tot_muni2county_emif tot_muni2state_emif tot_muni_emif
duplicates drop
/*
gen muni_co_shareofmuni_emif=birth_muni2county/birth_muni2US
gen muni_st_shareofmuni_emif=birth_muni2state/birth_muni2US
gen muni_co_shareofstate_emif=birth_muni2county/birth_muni2state
*/
*county level data

egen muni_st=concat(geo_birth2 state), punct("_")


save Data_built/EMIF/EMIF_muni2counties.dta, replace
/*
keep state  geo_birth county birth_muni2state birth_muni2US  muni_st_shareofmuni muni_co_shareofstate_emif muni_co_shareofmuni_emif
duplicates drop

gen  muni_st_one=0
sort state geo_birth
by state geo_birth: replace muni_st_one=1 if _n==1



/*sort geo_birth
by geo_birth: egen check=total( muni_st_shareofmuni)*/

egen muni_st=concat(geo_birth state), punct("_")
egen muni_co=concat(muni_st county), punct("_")
isid muni_co
*/
merge m:1 muni_st using Data_built/MCAS/MCAS_muni2states.dta 

*just 3 missing muni-st combos that appear in the EMIF and not in MCAS.--dropping
drop if _m==1

gen match="."
replace match="in both" if _m==3
replace match="in MCAS only" if _m==2
drop _m 

*generate values needed:
*droping MCAS 0's 
drop if tot_muni_mcas==0 

*from the mcas
replace county="missing" if county=="" & match=="in MCAS only"
replace county="DC" if state_abbrev=="DC"

egen muni_co=concat(muni_st county), punct("_")
isid muni_co

gen share_muni2state_mcas=tot_muni2state_mcas/tot_muni_mcas
gen share_munistate2county_emif=tot_muni2county_emif/tot_muni2state_emif
gen adj_share_muni2county=share_muni2state_mcas* share_munistate2county_emif

gen share_munist2miss_co=share_muni2state_mcas if county=="missing"

gen adj_share_muni2county_wmiss=adj_share_muni2county
replace  adj_share_muni2county_wmiss=share_munist2miss_co if county=="missing"

*for DC observations since (only 1 county in DC)
replace  adj_share_muni2county_wmiss=share_muni2state if county=="DC"


gen muni=substr(muni_st,1,5)

sort muni
by muni: egen check1=total(adj_share_muni2county_wmiss)
hist check1
tab check1
*looks good. 

*save Data_built/EMIF/muni2counties_all_var.dta, replace

rename  adj_share_muni2county_wmiss  muni2county_adj

gen share_muni2county_emif=tot_muni2county_emif/tot_muni_emif

keep muni muni_st muni_co muni2county_adj tot_muni_mcas tot_muni_emif tot_muni2state_mcas tot_muni2state_emif tot_muni2county_emif share_muni2county_emif county state

order muni muni_st muni_co muni2county_adj share_muni2county_emif tot_muni_mcas tot_muni2state_mcas  tot_muni_emif tot_muni2state_emif tot_muni2county_emif

sort muni muni_st
save Data_built/EMIF/muni2counties_adj.dta, replace

************************************************************************************
use Data_built/EMIF/muni2counties_adj.dta, clear
drop if county=="missing"

merge m:1 county state using  "Data_built\SecureComm\sec_comm_activation_wide.dta" 
keep if _mer==3 // many counties not connected with mex (in EMIF)
drop _m //ym year month
destring muni, gen(geo2_mx2010)

merge m:1 geo2_mx2010 using "Data_built\Claves\Claves_1960_2010.dta"
ta geo2_mx2010 if _m==1 // 7095 (doesnt exist in any list of claves)
keep if _merge==3
drop _m
merge m:1 geo2_mx2000 using "Data_raw\MexCensus\census2000_col.dta"
drop if _m==2
drop _m year mx2000a_mign persons mx2000a_migstat

reshape long sc sanc, i(state county geolev2 geo2_mx2000) j(date)
tostring date, replace
gen y=substr(date, -4,.)
egen m=ends(date) , punct(20) head
destring y, replace
destring m, replace
recode sanc .=0 if sc!=.
gen sc2 = sc * (1-sanc)

gen scweight_5 = sc2 * muni2county_adj
gen ym = ym(y, m)
format ym %tm
collapse (mean) migr_share (sum) scweight*, by(geo2_mx2000 geolev y m ym)
gen sc_shock_5 = scweight_5 * migr_share
replace sc_shock_5=0 if migr_share==0 
rename y year
rename m month
//label var scweight "Secure communities in destination counties"
label var scweight_5 "Secure communities (place of residence, MCAS & EMIF birthplace)"
//label var sc_shock "Secure communities in destination counties (weighted by share of migrants in mun.)"
label var sc_shock_5 "Secure communities shock (weighted by share of migrants in mun.)"
label var migr_share "Average number of migrants per capita, as of census 2000"
su

xtset geo2_mx2000 ym
foreach i in 3 6 9 12 15 18 21 24 27 30 33 36 {
gen l`i'_sc_5 = l`i'.sc_shock_5
gen f`i'_sc_5 = f`i'.sc_shock_5
recode l`i'_sc_5 .=0 if sc_shock_5!=.
}
*
isid geo2_mx2000 ym
save "Data_built\EMIF\Shock_EMIF_SecComm_Sanc_5.dta", replace



/*comparing shares

*muni-county shares comparisons: constructed to emif _only

reg  muni2county_adj share_muni2county_emif
scatter muni2county_adj share_muni2county_emif

hist muni2county_adj

keep muni muni_st tot_muni_emif tot_muni2state_emif tot_muni2state_mcas tot_muni_mcas
duplicates drop

*muni-state shares comparisons: emif mcas
gen share_muni2state_mcas=tot_muni2state_mcas/tot_muni_mcas
gen share_muni2state_emif=tot_muni2state_emif/tot_muni_emif

sort muni
by muni: egen check2=total(share_muni2state_emif)
by muni: egen check3=total(share_muni2state_mcas)

reg  share_muni2state_mcas share_muni2state_emif
scatter share_muni2state_mcas share_muni2state_emif

STOP
