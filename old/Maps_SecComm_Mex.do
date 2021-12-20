

*ssc install spmap
*ssc install shp2dta


clear all 
set more off


* This dofile merges the EMIF norte data to establish origin-destination networks 
* between mexico and the US
* So far, I am only using the "procedentes del sur" files, and intended destinations
* could extend this by looking at past destinations (also procsur), or at return migrants 

* Esther Gehrke, May 23, 2019
if "`c(username)'"=="gehrk001" {
	cap cd "C:\Users\gehrk001\Dropbox\MigrationShocks\"
}
*
if "`c(username)'"=="Claire" {
	cap cd "C:\Users\Claire\Dropbox\MigrationShocks\"
}
*

*Claire Desktop
if "`c(username)'"=="johnh" {
	cap cd "C:\Users\johnh\Dropbox\MigrationShocks\"
}




global graphs "Output\Graphs\"



*shp2dta using geo2_mx1960_2015, data(mex_data2) coor(mex_coordinates2) genid(id)

** December 2008
use Data_built\Map_IPUMS\mex_data2.dta, clear
destring GEOLEVEL2, replace
rename GEOLEVEL2 geolev2
// merge districts with own data 

merge 1:m geolev2 using "Data_built\EMIF\Shock_EMIF_SecComm_Sanc_2.dta"

keep if year==2008 & month==12
collapse (mean) sc_shock_2, by(geolev2 id)

spmap sc_shock_2 using Data_built\Map_IPUMS\mex_coordinates2.dta, id(id) fcolor(Blues) ndsize(none) ndocolor(none) ///
	ndfcolor(white) mos(none) osize(none none none none none none none) ///
	ocolor(none none none none none none none) ///
	clmethod(custom)  clb(0 0.02 0.04 0.08 0.12 0.20) ///
	subtitle("December 2008", position(6)) 

graph save Graph "$graphs\SC_mex_Dec2008.gph", replace

** December 2009
use Data_built\Map_IPUMS\mex_data2.dta, clear
destring GEOLEVEL2, replace
rename GEOLEVEL2 geolev2
// merge districts with own data 

merge 1:m geolev2 using "Data_built\EMIF\Shock_EMIF_SecComm_Sanc_2.dta"

keep if year==2009 & month==12
collapse (mean) sc_shock_2, by(geolev2 id)

spmap sc_shock_2 using Data_built\Map_IPUMS\mex_coordinates2.dta, id(id) fcolor(Blues) ndsize(none) ndocolor(none) ///
	ndfcolor(white) mos(none) osize(none none none none none none none) ///
	ocolor(none none none none none none none) ///
	clmethod(custom)  clb(0 0.02 0.04 0.08 0.12 0.20) ///
	subtitle("December 2009", position(6)) 
graph save Graph "$graphs\SC_mex_Dec2009.gph", replace

** December 2010
use Data_built\Map_IPUMS\mex_data2.dta, clear
destring GEOLEVEL2, replace
rename GEOLEVEL2 geolev2
// merge districts with own data 

merge 1:m geolev2 using "Data_built\EMIF\Shock_EMIF_SecComm_Sanc_2.dta"

keep if year==2010 & month==12
collapse (mean) sc_shock_2, by(geolev2 id)

spmap sc_shock_2 using Data_built\Map_IPUMS\mex_coordinates2.dta, id(id) fcolor(Blues) ndsize(none) ndocolor(none) ///
	ndfcolor(white) mos(none) osize(none none none none none none none) ///
	ocolor(none none none none none none none) ///
	clmethod(custom)  clb(0 0.02 0.04 0.08 0.12 0.20) ///
	subtitle("December 2010", position(6)) 
graph save Graph "$graphs\SC_mex_Dec2010.gph", replace

** December 2011
use Data_built\Map_IPUMS\mex_data2.dta, clear
destring GEOLEVEL2, replace
rename GEOLEVEL2 geolev2
// merge districts with own data 

merge 1:m geolev2 using "Data_built\EMIF\Shock_EMIF_SecComm_Sanc_2.dta"

keep if year==2011 & month==12
collapse (mean) sc_shock_2, by(geolev2 id)

spmap sc_shock_2 using Data_built\Map_IPUMS\mex_coordinates2.dta, id(id) fcolor(Blues) ndsize(none)  ndocolor(none) ///
	ndfcolor(white) mos(none) osize(none none none none none none none) ///
	ocolor(none none none none none none none) ///
	clmethod(custom)  clb(0 0.02 0.04 0.08 0.12 0.20) ///
	subtitle("December 2011", position(6)) 
graph save Graph "$graphs\SC_mex_Dec2011.gph", replace

** December 2012
use Data_built\Map_IPUMS\mex_data2.dta, clear
destring GEOLEVEL2, replace
rename GEOLEVEL2 geolev2
// merge districts with own data 

merge 1:m geolev2 using "Data_built\EMIF\Shock_EMIF_SecComm_Sanc_2.dta"

keep if year==2012 & month==12
collapse (mean) sc_shock_2, by(geolev2 id)
spmap sc_shock_2 using Data_built\Map_IPUMS\mex_coordinates2.dta, id(id) fcolor(Blues) ndsize(none)  ndocolor(none) ///
	ndfcolor(white) mos(none) osize(none none none none none none none) ///
	ocolor(none none none none none none none) ///
	clmethod(custom)  clb(0 0.02 0.04 0.08 0.12 0.20) ///
	subtitle("December 2012", position(6)) 
graph save Graph "$graphs\SC_mex_Dec2012.gph", replace

** December 2013
use Data_built\Map_IPUMS\mex_data2.dta, clear
destring GEOLEVEL2, replace
rename GEOLEVEL2 geolev2
// merge districts with own data 

merge 1:m geolev2 using "Data_built\EMIF\Shock_EMIF_SecComm_Sanc_2.dta"

keep if year==2013 & month==12
collapse (mean) sc_shock_2, by(geolev2 id)

spmap sc_shock_2 using Data_built\Map_IPUMS\mex_coordinates2.dta, id(id) fcolor(Blues) ndsize(none)  ndocolor(none) ///
	ndfcolor(white) mos(none) osize(none none none none none none none) ///
	ocolor(none none none none none none none) ///
	clmethod(custom)  clb(0 0.02 0.04 0.08 0.12 0.20) ///
	subtitle("December 2013", position(6)) 
graph save Graph "$graphs\SC_mex_Dec2013.gph", replace

** December 2014
use Data_built\Map_IPUMS\mex_data2.dta, clear
destring GEOLEVEL2, replace
rename GEOLEVEL2 geolev2
// merge districts with own data 

merge 1:m geolev2 using "Data_built\EMIF\Shock_EMIF_SecComm_Sanc_2.dta"

keep if year==2014 & month==12
collapse (mean) sc_shock_2, by(geolev2 id)

spmap sc_shock_2 using Data_built\Map_IPUMS\mex_coordinates2.dta, id(id) fcolor(Blues) ndsize(none)  ndocolor(none) ///
	ndfcolor(white) mos(none) osize(none none none none none none none) ///
	ocolor(none none none none none none none) ///
	clmethod(custom)  clb(0 0.02 0.04 0.08 0.12 0.20) ///
	subtitle("December 2014", position(6)) 
graph save Graph "$graphs\SC_mex_Dec2014.gph", replace

graph combine "$graphs\SC_mex_Dec2008.gph" "$graphs\SC_mex_Dec2009.gph" ///
	"$graphs\SC_mex_Dec2010.gph" "$graphs\SC_mex_Dec2011.gph" "$graphs\SC_mex_Dec2012.gph" ///
	"$graphs\SC_mex_Dec2013.gph", c(2) graphregion(fcolor(white) lcolor(white)) imargin(zero) iscale(*.8) xsize(8.3) ysize(11.7)
graph export $graphs\SC_Sanc_dest_municipatilies2.pdf, as(pdf) replace


graph combine "$graphs\SC_mex_Dec2008.gph" "$graphs\SC_mex_Dec2009.gph" ///
	"$graphs\SC_mex_Dec2010.gph" "$graphs\SC_mex_Dec2011.gph" "$graphs\SC_mex_Dec2012.gph" ///
	"$graphs\SC_mex_Dec2013.gph", c(3) graphregion(fcolor(white) lcolor(white)) imargin(zero) iscale(*.8) xsize(8.3) ysize(4.7)
graph export $graphs\SC_Sanc_dest_municipatilies2_wide.pdf, as(pdf) replace
graph export $graphs\SC_Sanc_dest_municipatilies2_wide.png, as(png) replace

stop

*window roll out
** June 2010
use Data_built\Map_IPUMS\mex_data2.dta, clear
destring GEOLEVEL2, replace
rename GEOLEVEL2 geolev2
// merge districts with own data 

merge 1:m geolev2 using "Data_built\EMIF\Shock_EMIF_SecComm_Sanc_2.dta"

keep if year==2010 & month==6
collapse (mean) sc_shock2, by(geolev2 id)

spmap sc_shock2 using Data_built\Map_IPUMS\mex_coordinates2.dta, id(id) fcolor(Blues) ndsize(none) ndocolor(none) ///
	ndfcolor(white) mos(none) osize(none none none none none none none) ///
	ocolor(none none none none none none none) ///
	clmethod(custom)  clb(0 0.02 0.04 0.08 0.12 0.20) ///
	subtitle("June 2010", position(6)) 
graph save Graph "$graphs\SC_mex_Jun2010.gph", replace



graph combine "$graphs\SC_mex_Dec2008.gph" "$graphs\SC_mex_Dec2009.gph" ///
	"$graphs\SC_mex_Jun2010.gph", c(3) graphregion(fcolor(white) lcolor(white)) imargin(zero) iscale(*2) xsize(8.3) ysize(2.7)
graph export $graphs\SC_Sanc_dest_municipalities_mini.pdf, as(pdf) replace


*map of average treatment in window

use Data_built\Map_IPUMS\mex_data2.dta, clear
destring GEOLEVEL2, replace
rename GEOLEVEL2 geolev2
tostring geolev2, replace
gen geo2_mx2000=substr(geolev2,5,5)
destring geo2_mx2000, replace
// merge districts with own data 

merge 1:m geo2_mx2000 using Data_built\EMIF\EMIF_migr_shock_avg0811_0510.dta
*a few missing merges. Maybe not 2000 muni codes. should check. 
spmap avg_treat0811_0510 using Data_built\Map_IPUMS\mex_coordinates2.dta, id(id) fcolor(Blues) ndsize(none) ndocolor(none) ///
	ndfcolor(white) mos(none) osize(none none none none none none none) ///
	ocolor(none none none none none none none) ///
	clmethod(custom)  clb(0 0.02 0.04 0.08 0.12 0.20) ///
	subtitle("Mean exposure in window", position(6)) 
graph export "$graphs\map_mean_treat_window.pdf", replace

gen mean_share_mig= avg_treat0811_0510/migr_share
scatter  avg_treat0811_0510 migr_share

keep if migr_share>0
spmap mean_share_mig using Data_built\Map_IPUMS\mex_coordinates2.dta, id(id) fcolor(Blues) ndsize(none) ndocolor(none) ///
	ndfcolor(white) mos(none) osize(none none none none none none none) ///
	ocolor(none none none none none none none) ///
	clmethod(custom)  clb(0 0.25 0.5 0.75 1) ///
	subtitle("Mean exposure / Migrant Share", position(6)) 
graph export "$graphs\map_mean_treat_window_by_mig_share.pdf", replace