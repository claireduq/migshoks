

*Esther
*cd "C:\Users\gehrk001\Dropbox\MigrationShocks\Data\"
*global graphs "C:\Users\gehrk001\Dropbox\MigrationShocks\Output\Graphs\"

*Claire
cd "C:\Users\Claire\Dropbox\MigrationShocks\"
global graphs "C:\Users\Claire\Dropbox\MigrationShocks\Output\Graphs\"
************************************************************************************
*PREP:

ssc install spmap
*ssc install shp2dta


************************************************************************************



use Data_built\MexCensus\census2000, clear
recode mx2000a_migstat 9=. 2=0 // any hh member is migrant
collapse (sum) mx2000a_mign persons (mean) mx2000a_migstat [aw = hhwt], by(geolev2 year)
gen migr_share = mx2000a_mign/  (persons+mx2000a_mign) // number of migrants per observed hh members  
su
tostring(geolev2), gen(GEOLEVEL2)
merge 1:1 GEOLEVEL2 using Data_built\Map_IPUMS\mex_data2.dta
drop _merge
spmap migr_share using Data_built\Map_IPUMS\mex_coordinates2.dta, id(id)  ///
	osize(vthin vthin vthin vthin vthin) ndsize(vthin) fcolor(Blues) /// 	clmethod(custom) clbreaks(0 .1 .2 .4 .99) 				///
	title(International migrants 2000) 
graph save Graph "$graphs\Census_migrants2000.gph", replace

	
* 2010 map
use "Data_built\MexCensus\census2010.dta", clear
recode mx2010a_intmigs 9=. 2=0
collapse (sum) mx2010a_migrants persons (mean) mx2010a_intmigs [aw = hhwt], by(geolev2 year)
gen migr_share = mx2010a_migrants/ (persons+mx2010a_migrants)
su
save Data_built\MexCensus\census2010_col.dta, replace
tostring(geolev2), gen(GEOLEVEL2)
merge 1:1 GEOLEVEL2 using Data_built\Map_IPUMS\mex_data2.dta
drop _merge
spmap mx2010a_intmigs using Data_built\Map_IPUMS\mex_coordinates2.dta, id(id)  ///
	osize(vthin vthin vthin vthin) ndsize(vthin) fcolor(Blues) /// clmethod(custom) clbreaks(0 .1 .2 .4 .99) 				///
	title(International migrants 2010) //saving(migrants2010)

** correlation
use Data_built\MexCensus\census2000, clear
recode mx2000a_migstat 9=. 2=0 // any hh member is migrant
collapse (sum) mx2000a_mign persons (mean) mx2000a_migstat [aw = hhwt], by(geolev2 year)
merge 1:1 geolev2 using Data_built\MexCensus\census2010_col.dta
drop _merge
corr mx2010a_intmigs mx2000a_migstat 
scatter mx2010a_intmigs mx2000a_migstat 
egen migr_stock= rowmean(mx2010a_intmigs mx2000a_migstat)

tostring(geolev2), gen(GEOLEVEL2)
merge 1:1 GEOLEVEL2 using Data_built\Map_IPUMS\mex_data2.dta
drop _merge
spmap migr_stock using Data_built\Map_IPUMS\mex_coordinates2.dta, id(id)  ///
	osize(vthin vthin vthin vthin vthin) ndsize(vthin) fcolor(Blues) clnumber(5) /// clmethod(custom) clbreaks(0 .1 .2 .4 .99) 				///
	title(International migrants stock) //saving(migrants_stock)

/*
decode geo2_mx2010, gen(mun_name)
gen str clave = string(geo2_mx2010) 

gen CVE_MUN= substr(clave,-3, 3)
gen CVE_ENT = substr(clave, 1, strlen(clave) - 3)
destring CVE_ENT, replace
destring CVE_MUN, replace
merge 1:1 CVE_ENT CVE_MUN using  "C:\Users\esthe\ownCloud\gehrke8\Data\Mexico\Claves.dta"
keep if _merge==3
// 7 municipalities were created between 2010 and 2017
