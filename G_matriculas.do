
clear all
*****************************************************************************************
import excel "$Data_raw\Matriculas\Matriculasmuniconda 2005-2006-2007.xlsx", sheet("2005") firstrow
tempfile Matriculas_2005
save `Matriculas_2005', replace

clear
import excel "$Data_raw\Matriculas\Matriculasmuniconda 2005-2006-2007.xlsx", sheet("2006") firstrow
tempfile Matriculas_2006
save `Matriculas_2006', replace

clear
import excel "$Data_raw\Matriculas\Matriculasmuniconda 2005-2006-2007.xlsx", sheet("2007") firstrow
tempfile Matriculas_2007
save `Matriculas_2007', replace

clear
import excel "$Data_raw\Matriculas\matriculasmuniconda08.xlsx", sheet("Hoja1") firstrow
rename NodeMatrículas Nopersonas
tempfile Matriculas_2008
save `Matriculas_2008', replace

use  `Matriculas_2005', clear
append using  `Matriculas_2006'
append using  `Matriculas_2007'
append using  `Matriculas_2008'
collapse (sum) Nopersonas, by(MunicipiodenacimientoenMexic EstadodenacimientoenMexico CondadoderesidenciaenUSA EstadoderesidenciaenUSA)
rename EstadodenacimientoenMexico EstNac
rename MunicipiodenacimientoenMexic MunNac
rename CondadoderesidenciaenUSA county
rename EstadoderesidenciaenUSA state
replace EstNac = ustrupper( ustrregexra( ustrnormalize(EstNac, "nfd" ) , "\p{Mark}", "" ) )
replace MunNac = ustrupper( ustrregexra( ustrnormalize(MunNac, "nfd" ) , "\p{Mark}", "" ) )
replace MunNac=ustrregexra(MunNac,"GRAL. ","GENERAL", 1)
//replace MunNac=ustrregexra(MunNac,"DR.","DOCTOR", 1)
drop if MunNac=="[MEX00] NO IDENTIFICADO"
replace MunNac="SAN MATEO YUCUTINDOO" if MunNac=="ZAPOTITLAN DEL RIO" 
save "$Data_built\Matriculas_all.dta", replace
// 2302 mun in 32 estados, 3,624,339 individuals observed 


use "$Data_built\Claves_1960_2017.dta", clear
gen EstNac = ustrupper( ustrregexra( ustrnormalize( NOM_ENT, "nfd" ) , "\p{Mark}", "" ) )
gen MunNac = ustrupper( ustrregexra( ustrnormalize( NOM_MUN, "nfd" ) , "\p{Mark}", "" ) )
replace EstNac="VERACRUZ" if EstNac=="VERACRUZ DE IGNACIO DE LA LLAVE"
replace EstNac="MICHOACAN" if EstNac=="MICHOACAN DE OCAMPO"
replace EstNac="ESTADO DE MEXICO" if EstNac=="MEXICO"
replace EstNac="COAHUILA" if EstNac=="COAHUILA DE ZARAGOZA"
replace EstNac="DISTRITO FEDERAL" if EstNac=="CIUDAD DE MEXICO"
//replace MunNac=ustrregexra(MunNac,"GR.","GENERAL", 1)
replace MunNac="SAN PEDRO MIXTEPEC - DISTR. 22 -" if geolev2==484020317
replace MunNac="SAN PEDRO MIXTEPEC - DISTR. 26 -" if geolev2==484020318
replace MunNac="SAN JUAN MIXTEPEC - DISTR. 08 -" if geolev2==484020207
replace MunNac="SAN JUAN MIXTEPEC - DISTR. 26 -" if geolev2==484020208
keep geo1_mx2000 geo2_mx2000 EstNac MunNac geolev2
replace MunNac="ACAMBAY" if MunNac=="ACAMBAY DE RUIZ CASTANEDA"
replace MunNac="CUATROCIENEGAS" if MunNac=="CUATRO CIENEGAS"
replace MunNac="TEMOSACHI" if MunNac=="TEMOSACHIC"
replace MunNac="BATOPILAS" if MunNac=="BATOPILAS DE MANUEL GOMEZ MORIN"
replace MunNac="GENERALSIMON BOIVAR" if MunNac=="GENERAL SIMON BOLIVAR"
replace MunNac="ALLENDE" if MunNac=="SAN MIGUEL DE ALLENDE" 
replace MunNac="DOLORES HIDALGO" if MunNac=="DOLORES HIDALGO CUNA DE LA INDEPENDENCIA NACIONAL"
replace MunNac="SILAO" if MunNac=="SILAO DE LA VICTORIA"
replace MunNac="JOSE AZUETA" if MunNac=="ZIHUATANEJO DE AZUETA" 

replace MunNac="SAN MARTIN DE HIDALGO" if MunNac=="SAN MARTIN HIDALGO" 
replace MunNac="TLAQUEPAQUE" if MunNac=="SAN PEDRO TLAQUEPAQUE" 
replace MunNac="JONACATEPEC" if MunNac=="JONACATEPEC DE LEANDRO VALLE" 
replace MunNac="TLALTIZAPAN" if MunNac=="TLALTIZAPAN DE ZAPATA" 
replace MunNac="ZACATEPEC DE HIDALGO" if MunNac=="ZACATEPEC" 
replace MunNac="CARMEN" if MunNac=="EL CARMEN" 
replace MunNac="DR.  COSS" if MunNac=="DOCTOR COSS" 
replace MunNac="DR. ARROYO" if MunNac=="DOCTOR ARROYO" 
replace MunNac="DR. GONZALEZ" if MunNac=="DOCTOR GONZALEZ" 
replace MunNac="GENERALBRAVO" if MunNac=="GENERAL BRAVO" 

replace MunNac="JUCHITAN DE ZARAGOZA" if MunNac=="HEROICA CIUDAD DE JUCHITAN DE ZARAGOZA" 
replace MunNac="SAN PEDRO TOTOLAPA" if MunNac=="SAN PEDRO TOTOLAPAM" 
replace MunNac="TEZOATLAN DE SEGURA Y LUNA" if MunNac=="HEROICA VILLA TEZOATLAN DE SEGURA Y LUNA, CUNA DE LA INDEPENDENCIA DE OAXACA" 
replace MunNac="VILLA DE TUTUTEPEC DE MELCHOR OCAMPO" if MunNac=="VILLA DE TUTUTEPEC" 

replace MunNac="GENERAL FELIPE _NGELES" if MunNac=="GENERAL FELIPE ANGELES" 

replace MunNac="ALTZAYANCA" if MunNac=="ATLTZAYANCA" 
replace MunNac="YAUHQUEMECAN" if MunNac=="YAUHQUEMEHCAN" 
replace MunNac="ZITLALTEPEC DE TRINIDAD SANCHEZ SANTOS" if MunNac=="ZILTLALTEPEC DE TRINIDAD SANCHEZ SANTOS" 

replace MunNac="CAZONES" if MunNac=="CAZONES DE HERRERA" 
replace MunNac="HUILOAPAN" if MunNac=="HUILOAPAN DE CUAUHTEMOC" 
replace MunNac="MEDELLIN" if MunNac=="MEDELLIN DE BRAVO" 
replace MunNac="TEMAPACHE" if MunNac=="ALAMO TEMAPACHE" 
replace MunNac="TUXPAM" if MunNac=="TUXPAN" & EstNac=="VERACRUZ"

merge 1:m  EstNac MunNac using "$Data_built\Matriculas_all.dta"
drop if _merge==1 // all matricula data were merged, but 22 municipios do not appear in matriculas data
drop _merge

collapse  (sum) Nopersonas, by(state county geo2_mx2000 geolev2) // 2438 our of 2443 municipalities are in matriculas data

replace state="AL" if state=="Alabama"
replace state="AK" if state=="Alaska"
replace state="AZ" if state=="Arizona"
replace state="AR" if state=="Arkansas"
replace state="CA" if state=="California"
replace state="CO" if state=="Colorado"
replace state="CT" if state=="Connecticut"
replace state="DE" if state=="Delaware"
replace state="FL" if state=="Florida"
replace state="GA" if state=="Georgia"
replace state="HI" if state=="Hawaii"
replace state="ID" if state=="Idaho"
replace state="IL" if state=="Illinois"
replace state="IN" if state=="Indiana"
replace state="IA" if state=="Iowa"
replace state="KS" if state=="Kansas"
replace state="KY" if state=="Kentucky"
replace state="LA" if state=="Louisiana"
replace state="ME" if state=="Maine"
replace state="MD" if state=="Maryland"
replace state="MA" if state=="Massachusetts"
replace state="MI" if state=="Michigan"
replace state="MN" if state=="Minnesota"
replace state="MS" if state=="Mississippi"
replace state="MO" if state=="Missouri"
replace state="MT" if state=="Montana"
replace state="NE" if state=="Nebraska"
replace state="NV" if state=="Nevada"
replace state="NH" if state=="New Hampshire"
replace state="NJ" if state=="New Jersey"
replace state="NM" if state=="New Mexico"
replace state="NY" if state=="New York"
replace state="NC" if state=="North Carolina"
replace state="ND" if state=="North Dakota"
replace state="OH" if state=="Ohio"
replace state="OK" if state=="Oklahoma"
replace state="OR" if state=="Oregon"
replace state="PA" if state=="Pennsylvania"
replace state="RI" if state=="Rhode Island"
replace state="SC" if state=="South Carolina"
replace state="SD" if state=="South Dakota"
replace state="TN" if state=="Tennessee"
replace state="TX" if state=="Texas"
replace state="UT" if state=="Utah"
replace state="VT" if state=="Vermont"
replace state="VA" if state=="Virginia"
replace state="WA" if state=="Washington"
replace state="WV" if state=="West Virginia"
replace state="WI" if state=="Wisconsin"
replace state="WY" if state=="Wyoming"
replace state="DC" if state=="District of Columbia"

replace county="MATANUSKA-SUSITNA" if county=="MATANUSKA SUSITNA"
replace county="SITKA CITY AND" if county=="SITKA"
replace county="VALDEZ-CORDOVA" if county=="VALDEZ CORDOVA"
replace county="YUKON-KOYUKUK" if county=="YUKON KOYUKUK"
replace county="DEKALB" if county=="DE KALB" & state!="IN" 
replace county="DESOTO" if county=="DE SOTO" & state!="IN" & state!="LA"
replace county="HAWAII" if county=="HONOLULU"
replace county="DUPAGE" if county=="DU PAGE"

replace county="SAINT JOSEPH" if county=="ST JOSEPH"
replace county="SAINT JOHN THE BAPTIST" if county=="ST JOHN THE BAPTIST"  & state=="LA"
replace county="PRINCE GEORGE'S" if county=="PRINCE GEORGES"  & state=="MD"
replace county="QUEEN ANNE'S" if county=="QUEEN ANNES"  & state=="MD"
replace county="SAINT MARY'S" if county=="SAINT MARYS"  & state=="MD"
replace county="DEBACA" if county=="DE BACA" & state=="NM"
replace county="NEW YORK CITY" if county=="NEW YORK" & state=="NY"
replace county="NEW YORK CITY" if county=="QUEENS"  & state=="NY" 
replace county="NEW YORK CITY" if county=="BRONX" & state=="NY"
replace county="NEW YORK CITY" if  county=="RICHMOND" & state=="NY"
replace county="NEW YORK CITY" if  county=="KINGS" & state=="NY"
replace county="LEFLORE" if county=="LE FLORE" & state=="OK"
drop if county=="SHANNON" & state=="SD" // Oglala Lakota County, not in SecComm data
replace county="DEWITT" if county=="DE WITT" & state=="TX"

replace county="BRISTOL CITY" if county=="BRISTOL" & state=="VA"
replace county="YORK" if county=="POQUOSON CITY" & state=="VA"
replace county="RADFORD CITY" if county=="RADFORD" & state=="VA"
replace county="SALEM CITY" if county=="SALEM" & state=="VA"
replace county="MC KEAN" if county=="MCKEAN" & state=="PA"

collapse (sum) Nopersonas , by(state county geo2_mx2000 geolev2)

merge m:1 county state using  "$Data_built\sec_comm_activation_wide_mat.dta" 
keep if _merge==3 // 336 counties not connected with mex (in Matriculas data)
drop _merge //ym year month

merge m:1 geo2_mx2000 using "$Data_built\census2000_col.dta"
*drop if _m==2
drop _merge year mx2000a_mign persons mx2000a_migstat

bysort geo2_mx2000: egen migrants_5 =total(Nopersonas)
gen link= Nopersonas/ migrants_5 // number of migrants from mun j observed in Matriculas that intended to migrate to particular county n / out of all obs from mun j
drop Nopersonas activationdate activ
reshape long sc sanc, i(state county geolev2 geo2_mx2000 link migrants_5 migr_share) j(date)
tostring date, replace
gen y=substr(date, -4,.)
egen m=ends(date) , punct(20) head
destring y, replace
destring m, replace
recode sanc .=0 if sc!=.
gen sc5 = sc * (1-sanc)

gen sc_noweight_5 = sc5 * link
gen ym = ym(y, m)
format ym %tm
collapse (mean) migrants_5 migr_share  (sum) sc_noweight*, by(geo2_mx2000 geolev2 y m ym)
gen sc_shock_5 = sc_noweight_5 * migr_share
replace sc_shock_5=0 if migr_share==0 
rename y year
rename m month
label var sc_noweight_5 "Secure communities shock (unweighted, Matriculas)"
label var sc_shock_5 "Secure communities shock (Matriculas)"
label var migrants_5 "Number of migrants (w/ known US destination) from municipio observed in Matriculas"
su 
replace sc_noweight_5 =. if migrants_5==0
su sc_shock_5 if sc_noweight_5==.
xtset geo2_mx2000 ym

foreach i in 3 6 9 12 15 18 21 24 27 30 33 36 39 42 45 48 {
gen l`i'_sc_5 = l`i'.sc_shock_5
gen f`i'_sc_5 = f`i'.sc_shock_5
recode l`i'_sc_5 .=0 if sc_shock_5!=.
gen l`i'_scnw_5 = l`i'.sc_noweight_5
gen f`i'_scnw_5 = f`i'.sc_noweight_5
recode l`i'_scnw_5 .=0 if sc_noweight_5!=.
}
*
isid geo2_mx2000 ym


foreach i in 3 6 9 12 15 18 21 24 {
recode f`i'_sc_5 .=0 if sc_shock_5!=.
recode f`i'_scnw_5 .=0 if sc_noweight_5!=.
}

save "$Data_built\Shock_Mat_SecComm_Sanc_5.dta", replace

merge 1:1 geo2_mx2000 year month using $Data_built\Shock_EMIF_SecComm_Sanc_1.dta
drop _merge

merge 1:1 geo2_mx2000 year month using $Data_built\Shock_EMIF_SecComm_Sanc_2.dta
drop _merge

merge 1:1 geo2_mx2000 year month using $Data_built\Shock_EMIF_SecComm_Sanc_3.dta
drop _merge

merge 1:1 geo2_mx2000 year month using $Data_built\Shock_EMIF_SecComm_Sanc_4.dta
drop _merge



foreach i in 3 6 9 12 15 18 21 24 {
recode f`i'_sc_1 .=0 if sc_shock_1!=.
recode f`i'_sc_2 .=0 if sc_shock_2!=.
recode f`i'_sc_3 .=0 if sc_shock_3!=.
recode f`i'_sc_4 .=0 if sc_shock_4!=.
recode f`i'_sc_5 .=0 if sc_shock_5!=.
recode f`i'_scnw_1 .=0 if sc_noweight_1!=.
recode f`i'_scnw_2 .=0 if sc_noweight_2!=.
recode f`i'_scnw_3 .=0 if sc_noweight_3!=.
recode f`i'_scnw_4 .=0 if sc_noweight_4!=.
recode f`i'_scnw_5 .=0 if sc_noweight_5!=.
}

save "$Data_built\Shock_Mat_SecComm_Sanc_all.dta", replace

/*foreach i in 3 6 9 12 15 18 21 24 27 30 33 36 39 42 45 48 {
replace l`i'_scnw_5 =. if migrants_5==0
replace f`i'_scnw_5 =. if migrants_5==0
}
*/
*** 
use "$Data_built\Shock_Mat_SecComm_Sanc_all.dta", clear
keep if inlist(month, 2, 5, 8,11)

gen quarter=.
replace quarter=1 if month==2
replace quarter=2 if month==5
replace quarter=3 if month==8
replace quarter=4 if month==11

gen int_yq= (year-2000)*10+quarter
isid geo2_mx2000 int_yq
save "$Data_built\Shock_SecComm_Sanc_all_yq_med.dta", replace

*Not using the mean file so not running. Uncomment to run
/*
use "$Data_built\Shock_Mat_SecComm_Sanc_all.dta", clear
gen quarter=.
replace quarter=1 if month>=1 & month<=3
replace quarter=2 if month>=4 & month<=6
replace quarter=3 if month>=7 & month<=9
replace quarter=4 if month>=10 & month <=12
collapse (mean) *sc* migrants* migr_share* migwdest*, by(geo2_mx2000 quarter year)
label var sc_noweight_5 "Secure communities shock (unweighted, Matriculas)"
label var sc_shock_5 "Secure communities shock (Matriculas)"
label var migrants_5 "Number of migrants (w/ known US destination) from municipio observed in Matriculas"
label var sc_noweight_2 "Secure communities (unweighted, place of residence, EMIF sur & devueltos)"
label var sc_shock_2 "Secure communities shock (weighted by share of migrants in mun.)"
label var migr_share "Average number of migrants per capita, as of census 2000"
label var migwdest_2 "Number of migrants (w/ known US destination) from municipio observed in EMIF"
label var sc_noweight_3 "Secure communities shock (unweighted, place of residence or destination)"
label var sc_shock_3 "Secure communities shock (weighted by share of migrants in mun.)"
label var migwdest_3 "Number of migrants (w/ known US destination) from municipio observed in EMIF"
label var sc_noweight_4 "Secure communities shock (unweighted, birth place)"
label var sc_shock_4 "Secure communities shock (weighted by share of migrants in mun.)"
label var migwdest_4 "Number of migrants (w/ known US destination) from municipio observed in EMIF"
gen int_yq= (year-2000)*10+quarter
isid geo2_mx2000 int_yq 
save "$Data_built\Shock_SecComm_Sanc_all_yq_mean.dta", replace
*/
cap erase $Data_built\Shock_EMIF_SecComm_Sanc_3.dta
cap erase $Data_built\Shock_EMIF_SecComm_Sanc_1.dta
cap erase $Data_built\Shock_EMIF_SecComm_Sanc_4.dta
cap erase "$Data_built\Shock_Mat_SecComm_Sanc_all.dta"