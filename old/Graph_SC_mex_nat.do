
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

/*
use "Data_built\EMIF\Shock_EMIF_SecComm_Sanc_2.dta", clear
merge m:1 geo2_mx2000 using Data_built\MexCensus\census2010_col2.dta
drop _m
******************************************************************************************************************

//graph tw kdensity scweight || kdensity scweight2
//graph tw kdensity sc_shock if obs!=. & migr_share>.0136407 || kdensity sc_shock2 if obs!=. & migr_share>.0136407

*decode ym, generate(time)  
*graph box sc_shock2 if inrange(year, 2007, 2014) [aw=persons], over(ym, label(angle(45) format(%tm))) nooutsides

/* selection
2443 municipalities
1796 mun in EMIF data,within these observe an average of 2.5 migrants (min 1, max 40)
2258/ 2443 municipalities have migr_share>0, out of which 1710 are in EMIF
1221/ 2443 municipalities have migr_share>p50 (0.0136407), out of which 977 are in EMIF
1832/ 2443 municipalities have migr_share>p25 (0.0033062), out of which 1,425 are in EMIF
2198/ 2443 municipalities have migr_share>p10 (0.000456), out of which 1,666 are in EMIF

highest average number of obs per mun in EMIF is when is use all muns with migr_share>0

graph tw kdensity sc_shock if obs!=. & migr_share>0 & year>=2008 ///
	|| kdensity sc_shock2 if obs!=. & migr_share>0 & year>=2008
	
graph tw kdensity scweight2 if obs!=. & migr_share>0 & year>=2008 ///
	|| kdensity scweight if obs!=. & migr_share>0 & year>=2008
*/		
collapse (mean) scweight scweight2 sc_shock sc_shock2 [aw=persons], by(ym year month)

 graph tw line sc_shock ym || line sc_shock2 ym 

 graph save Graph "$graphs\SC_mex_nat.gph", replace
 */
 
 ****************************
* NEW TREATMENT WINDOWS GRAPH


use "Data_built\EMIF\Shock_EMIF_SecComm_Sanc_2.dta", clear
merge m:1 geo2_mx2000 using Data_built\MexCensus\census2010_col2.dta
drop _m


collapse (mean) scweight_*  sc_shock_* [aw=persons], by(ym year month)
gen momonth=ym(year, month)

graph tw line sc_shock ym, xline(610.5, lwidth(51) lc(gs14)) xtitle("")   ///
ytitle(Mean National Pop. Share Impacted by Sec. Comm. ) ///
graphregion(margin(2 2 2 2) color(white)) xlabel( ,angle(vertical)) ///
tlabel(2005m1 "Jan'05" 2006m1 "Jan'06" 2007m1 "Jan'07" 2008m1 "Jan'08" 2009m1 "Jan'09" 2010m1 "Jan'10"  2011m1  "Jan'11" 2012m1 "Jan'12" 2013m1 "Jan'13" 2014m1 "Jan'14" 2015m1 "Jan'15") 
graph export "$graphs\SC_mex_nat_presentation.pdf", replace

 
  ****************************
* COMPARISON GRAPH


use "Data_built\EMIF\Shock_EMIF_SecComm_Sanc_2.dta", clear
merge m:1 geo2_mx2000 using Data_built\MexCensus\census2010_col2.dta
drop _m

tostring geolev2, replace
gen state=substr(geolev2,4,3)

keep if state=="032"


collapse (mean) scweight_2  sc_shock_2 [aw=persons], by(ym year month)

local zacatecas mean
save `zacatecas mean', replace

use "Data_built\EMIF\Shock_EMIF_SecComm_Sanc_2.dta", clear



keep if inlist(geo2_mx2000, 32009, 32014, 32032)




keep sc_shock_2 ym geo2_mx2000

reshape wide sc_shock_2, i(ym) j(geo2_mx2000)
merge 1:1 ym using `zacatecas mean'


graph tw line sc_shock_232009 ym || line sc_shock_232014 ym|| line sc_shock_232032 ym||line sc_shock_2 ym ||            pcarrowi .06 575 .06 593 (9) "Gen. F. Murguia", mlabcolor(red) mcolor(red) lcolor(red)  ||pcarrowi .05 575 .05 613 (9) "Chalchihuites", mlabcolor(blue) mcolor(blue) lcolor(blue) ||pcarrowi .03 575 .03 603 (9) "Weighted Mean Zacatecas", mlabcolor(orange) mcolor(orange) lcolor(orange) ||pcarrowi .008 575 .008 602 (9) "Morelos", mlabcolor(green) mcolor(green) lcolor(green) ,    xline(610.5, lwidth(51) lc(gs14)) xtitle("") title(Four Municipalities in Zacatecas) legend(pos(9) ring(0) col(1))  ytitle(Muni. Pop. Share Impacted by Sec. Comm. ) graphregion(margin(2 2 2 2) color(white)) xlabel( ,angle(vertical))   tlabel(2005m1 "Jan'05" 2006m1 "Jan'06" 2007m1 "Jan'07" 2008m1 "Jan'08" 2009m1 "Jan'09" 2010m1 "Jan'10"  2011m1  "Jan'11" 2012m1 "Jan'12" 2013m1 "Jan'13" 2014m1 "Jan'14" 2015m1 "Jan'15")  legend(off)
 graph export "$graphs\SC_mex_ex_zaca.pdf", replace

 stop
/*
 graph tw line sc_shock32009 ym || line sc_shock32014 ym ||pcarrowi .05 615 .05 605 (3) " Gen. F. Murguia treatment= .051", mlabcolor(red) mcolor(red) lcolor(red)  ||pcarrowi .01 615 .01 605 (3) "Chalchihuites treatment= .009", mlabcolor(blue) mcolor(blue) lcolor(blue) ,     xline(595, lwidth(19) lc(gs12)) xtitle("") title(Two Municipalities in Zacatecas) legend(pos(9) ring(0) col(1))  ytitle(Muni. Pop. Share Impacted by Sec. Comm. ) graphregion(margin(2 2 2 2)) xlabel( ,angle(vertical))   tlabel(2005m1 "Jan'05" 2006m1 "Jan'06" 2007m1 "Jan'07" 2008m1 "Jan'08" 2008m11 "Nov'08" 2010m6 "Jun'10"  2011m1  "Jan'11" 2012m1 "Jan'12" 2013m1 "Jan'13" 2014m1 "Jan'14" 2015m1 "Jan'15")  legend(off)

 
 */


/* 
use "Data_built\EMIF\Shock_EMIF_SecComm_Sanc_5.dta", clear

keep if inlist(geo2_mx2000, 14038, 14045)

keep sc_shock ym geo2_mx2000

reshape wide sc_shock, i(ym) j(geo2_mx2000)
 graph tw line sc_shock14045 ym || line sc_shock14038 ym ||pcarrowi .04 615 .04 605 (3) "Guachinango treatment= .04", mlabcolor(red) mcolor(red) lcolor(red)  ||pcarrowi .03 615 .03 605 (3) "Ixtlahuacan del rio treatment= .03", mlabcolor(blue) mcolor(blue) lcolor(blue) ,     xline(595, lwidth(19) lc(gs12)) xtitle("") title(Two Municipalities in Jalisco) legend(pos(9) ring(0) col(1))  ytitle(Muni. Pop. Share Impacted by Sec. Comm. ) graphregion(margin(2 2 2 2)) xlabel( ,angle(vertical))   tlabel(2005m1 "Jan'05" 2006m1 "Jan'06" 2007m1 "Jan'07" 2008m1 "Jan'08" 2008m11 "Nov'08" 2010m6 "Jun'10"  2011m1  "Jan'11" 2012m1 "Jan'12" 2013m1 "Jan'13" 2014m1 "Jan'14" 2015m1 "Jan'15")  legend(off)
 graph export "$graphs\SC_mex_ex_jal.pdf", replace
*/
 stop
 
 *TO FIND COMPRABLE MUNIS:

/*
use Data_built\ENOE\ENOE_migr_shock_windows.dta

keep geo1_mx2000 geo2_mx2000 migr_share avg_treat0811_0510
duplicates drop

drop if avg_treat0811_0510==0
sort geo1_mx2000  migr_share 
*/
 
 
 
 