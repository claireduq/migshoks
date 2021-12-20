

clear all
set more off


********************************************************************************
** This dofile creates the mexican dataset on time use of adolescents
* Esther Gehrke
* March, 20 2019


********************************************************************************
if "`c(username)'"=="gehrk001" {
	cap cd "C:\Users\gehrk001\Dropbox\MigrationShocks\"
}
if "`c(username)'"=="esthe" {
	cap cd "C:\Users\esthe\Dropbox\MigrationShocks\"
}
if "`c(username)'"=="Claire" {
	cap cd "C:\Users\Claire\Dropbox\MigrationShocks\"
}
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



*******
*to integrate a queston from the sociodemographic survey: Just add once in section below

*to integrate a queston from the extended ampliado questionaire or the basic add twice for 
*the older versions 1,2,3 and newer versions 4,5 in two different sections. 


*********************************************************************************
*********************************************************************************
* Sociodemographico
* birth order, number of siblings (older and younger), gender, migration history


* 1a, 2a, 3a, 4a 
foreach x in 1 2 3 4 {
foreach y in 05 06 07 08 09 10 11 12 13 14 15 16 17 18 {



use Data_raw\ENOE\SDEMT`x'`y'.dta, clear
keep if r_def==00 // keep only those obs with completed survey

*GENERATE HOUSEHOLD IDENTIFIER:
*calculate 1 quarter hh is interviewed
gen first_int_yq="."
replace first_int_yq="`y'"+"`x'" if n_ent==1


gen a=`y'-1
gen b=`y'-1
tostring b, replace
replace b="0"+b if a<10


if `x'==1{
replace first_int_yq=b+"4" if n_ent==2
replace first_int_yq=b+"3" if n_ent==3
replace first_int_yq=b+"2" if n_ent==4
replace first_int_yq=b+"1" if n_ent==5
}
*
if `x'==2{
replace first_int_yq="`y'"+"1" if n_ent==2
replace first_int_yq=b+"4" if n_ent==3
replace first_int_yq=b+"3" if n_ent==4
replace first_int_yq=b+"2" if n_ent==5
}
*
if `x'==3{
replace first_int_yq="`y'"+"2" if n_ent==2
replace first_int_yq="`y'"+"1" if n_ent==3
replace first_int_yq=b+"4" if n_ent==4
replace first_int_yq=b+"3" if n_ent==5
}
*
if `x'==4{
replace first_int_yq="`y'"+"3" if n_ent==2
replace first_int_yq="`y'"+"2" if n_ent==3
replace first_int_yq="`y'"+"1" if n_ent==4
replace first_int_yq=b+"4" if n_ent==5
}
*
drop a b

 *note h_mod indicates the hh has moved and should not be included for panel tracking
gen hh_id=first_int_yq+"_"+ string(cd_a)+ "_" + string(ent)+"_"+string(con)+"_"+string(v_sel)+"_"+string(n_hog)
gen hh_id_visit=hh_id+"_visit"+string(n_ent)

gen indiv_id= hh_id+"_"+string(n_ren)
gen indiv_id_visit=indiv_id+"_visit"+string(n_ent)

*one observation per individual
isid indiv_id


*SCHOOLING VARIABLES
ren cs_p17 enroll 
recode enroll 9=. 2=0


keep loc mun est est_d ageb t_loc cd_a ent con upm d_sem n_pro_viv v_sel n_hog ///
	h_mud n_ent hh_id hh_id_visit indiv_id indiv_id_visit per n_ren  sex eda enroll anios_esc hrsocup ingocup ///
	ing_x_hrs c_res n_ent first_int_yq  anios_esc cs_ad_des cs_nr_ori fac  cs_ad_mot cs_nr_mot


save Data_built\ENOE\socioT`x'`y'_wide_mini.dta, replace

}
}
*

clear
gen per=.
save Data_built\ENOE\wide_build.dta, replace

foreach x in 1 2 3 4 {
foreach y in 05 06 07 08 09 10 11 12 13 14 15 16 17 18 {
append using Data_built\ENOE\socioT`x'`y'_wide_mini.dta
}
}
*


gen obs=1
sort indiv_id
by indiv_id: egen times_obs=total(obs)
tab times_obs


*figuring out quarter of all scheduled houshold interviews
destring first_int_yq, replace
drop if first_int_yq<51
drop if first_int_yq>134

gen first_int_yq_2=first_int_yq
gen str3  first_int_yq_3 = string(first_int_yq_2,"%03.0f")
tostring first_int_yq, replace
gen x=substr(first_int_yq_3,3,1) 
gen y=substr(first_int_yq_3,1,2) 

destring x y, replace
replace y=y+2000

gen xmo=.
replace xmo=2 if x==1
replace xmo=5 if x==2
replace xmo=8 if x==3
replace xmo=11 if x==4
tostring xmo y, replace
gen date1=xmo+"-1-"+y
gen edate = date(date1,"MDY")
gen qy_ent1 = qofd(edate)

forval i=2/5{
local a=`i'-1
gen qy_ent`i'=qy_ent`a'+1
}

forval i=1/5{
gen y_ent`i'=yofd(dofq(qy_ent`i'))    
gen q_ent`i'=quarter(dofq(qy_ent`i'))    
}

gen geo2_mx2015 = ent*1000 + mun


merge m:1 geo2_mx2015 using Data_built\Claves\Claves_1960_2015.dta
drop if _m==2 // not all municipalities coevered in any round? 
drop _m geo1_mx2015 geo1_mx2010 geo2_mx2010 geo1_mx2005 geo2_mx2005

save Data_built\ENOE\wide_build.dta, replace




*select individual constants want to keep
sort indiv_id
by indiv_id: egen bsline_age=min(eda)
by indiv_id: egen msex=mean(sex)
replace msex=round(msex) 
keep indiv_id msex bsline_age geo2_mx2015 
duplicates drop
* a few (200+) duplicate ids 
duplicates tag indiv_id, gen(duple)
drop if duple==1
drop duple
save Data_built\ENOE\wide_build_mini.dta, replace



clear 
use  Data_built\Matriculas\Shock_Mat_SecComm_Sanc_5.dta
keep if inlist(month, 2, 5, 8,11)
gen quarter=.
replace quarter=1 if month==2
replace quarter=2 if month==5
replace quarter=3 if month==8
replace quarter=4 if month==11
gen q_ent=quarter
gen y_ent=year
gen int_yq= (year-2000)*10+quarter
isid    geo2_mx2000 int_yq
save  Data_built\Matriculas\Shock_Mat_SecComm_Sanc_5merge.dta, replace 





********************************************************
*get household attrition panel
*household attrition
use  Data_built\ENOE\wide_build.dta, 

forval i=1/5{
gen hh_home1vaway_ent_`i'a=.
replace hh_home1vaway_ent_`i'a=1 if n_ent==`i'
gen fac_`i'a=.
replace fac_`i'a=fac if n_ent==`i'
}
*
sort hh_id
forval i=1/5{
gen hh_shouldbe_int`i'=1	
by hh_id: egen hh_home1vaway_ent_`i'=max(hh_home1vaway_ent_`i'a)
by hh_id: egen hh_fac_`i'=max(fac_`i'a)
drop hh_home1vaway_ent_`i'a fac_`i'a
}

keep hh_id qy_ent* y_ent* q_ent* geo1_mx2000 geo2_mx2000 hh_home1vaway_ent_* hh_fac_* hh_shouldbe_int*
duplicates drop

egen hh_obs_rounds=rowtotal(hh_home1vaway_ent_1 hh_home1vaway_ent_2 hh_home1vaway_ent_3 hh_home1vaway_ent_4 hh_home1vaway_ent_5)

*tab hh_home1vaway_ent_5, miss
*Share of missing households by round
*1:7.45%  2:7.43%  3:7.76%  4:8.16%  5:8.07%

keep  hh_id geo1_mx2000 geo2_mx2000  qy_ent* y_ent* q_ent* hh_home1vaway_ent_*  hh_fac_* hh_shouldbe_int*
*one miscoded observation: drop
duplicates tag hh_id, gen(duple)
drop if duple==1
duplicates drop
save Data_built\ENOE\hh_attrit_wide.dta, replace







*FD build
use  Data_built\ENOE\hh_attrit_wide.dta
keep if y_ent1 <=2014
forval i=1/5{
replace hh_home1vaway_ent_`i'=0 if hh_home1vaway_ent_`i'==.	
}

rename (y_ent5 q_ent5)( y_ent q_ent)
merge m:1  y_ent q_ent  geo2_mx2000 using Data_built\Matriculas\Shock_Mat_SecComm_Sanc_5merge.dta

save Data_built\ENOE\hh_attrit_FD.dta, replace

/*
*yoy hh attrits: -1 for joining hh, 0 no change, 1 for disappearing
gen yoy_hhattrits=(-1)*(hh_home1vaway_ent_5-hh_home1vaway_ent_1)

gen yoy_hhdeparts=(-1)*(hh_home1vaway_ent_5-hh_home1vaway_ent_1) 
replace yoy_hhdeparts=. if hh_home1vaway_ent_1==0

gen yoy_hharrives=(hh_home1vaway_ent_5-hh_home1vaway_ent_1) 
replace yoy_hharrives=. if hh_home1vaway_ent_5==0


keep hh_id  qy_ent1 y_ent1 q_ent1 qy_ent5 y_ent5 q_ent5 geo1_mx2000 geo2_mx2000 yoy_hhattrits  hh_fac_1 hh_fac_5 yoy_hhdeparts yoy_hharrives
duplicates drop
isid hh_id


rename (y_ent1 q_ent1)( y_ent q_ent)
merge m:1  y_ent q_ent  geo2_mx2000 using Data_built\Matriculas\Shock_Mat_SecComm_Sanc_5merge.dta
rename ( y_ent q_ent sc_shock_5 sc_noweight_5) (y_ent1 q_ent1 sc_shock_5_ent1 sc_noweight_5_ent1)
keep hh_id  qy_ent1 y_ent1 q_ent1 qy_ent5 y_ent5 q_ent5 geo1_mx2000 geo2_mx2000 yoy_hhattrits  hh_fac_1 hh_fac_5 migr_share yoy_hhdeparts yoy_hharrives sc_shock_5_ent1 sc_noweight_5_ent1

rename (y_ent5 q_ent5)( y_ent q_ent)
merge m:1  y_ent q_ent  geo2_mx2000 using Data_built\Matriculas\Shock_Mat_SecComm_Sanc_5merge.dta
rename ( y_ent q_ent ) (y_ent5 q_ent5 )


gen yoy_sc_shock_5_ent1to5=sc_shock_5_ent5-sc_shock_5_ent1
gen yoy_sc_noweight_5_ent1to5=sc_noweight_5_ent5-sc_noweight_5_ent1

save Data_built\ENOE\hh_attrit_FD.dta, replace
*/



****Muni build
use  Data_built\ENOE\hh_attrit_wide.dta
reshape long qy_ent y_ent q_ent hh_home1vaway_ent_ hh_fac_  hh_shouldbe_int, i(hh_id) j(n_ent)

*issue no weights on missing households so cant be weighted.
collapse (sum) hh_home1vaway_ent_ hh_shouldbe_int, by(geo1_mx2000 geo2_mx2000 y_ent q_ent) 

merge m:1  y_ent q_ent  geo2_mx2000 using Data_built\Matriculas\Shock_Mat_SecComm_Sanc_5merge.dta
drop _m 

gen attrit_hhs= hh_shouldbe_int- hh_home1vaway_ent_
gen att_share=attrit_hhs/hh_shouldbe_int


merge m:1 geo2_mx2000 using Data_raw\MexCensus\census2000_col.dta
*get population from 2000 census
drop _m
 
save Data_built\ENOE\muni_hh_attrit.dta, replace



****Muni level attrition
use Data_built\ENOE\muni_hh_attrit.dta

global fe i.int_yq i.year##i.geo1_mx2000 i.geo2_mx2000
global controls c.migr_share#i.int_yq 


eststo clear
foreach x in 5 { 	
foreach y in hh_home1vaway_ent_ hh_shouldbe_int attrit_hhs att_share{
*remit question only in ampliado questionair so will only be asked to hh once. 
eststo: reghdfe `y' f18_sc_`x' f12_sc_`x' f6_sc_`x' sc_shock_`x' l6_sc_`x' l12_sc_`x' l18_sc_`x' l24_sc_`x' l30_sc_`x' l36_sc_`x' l42_sc_`x' $controls  [pw=persons], a($fe) cluster(geo2_mx2000)

local obs=e(N)
local N=e(N_clust)
sum year if e(sample)
local year_start = r(min)
local year_end = r(max)
local month_start = 1
local month_end = 12

nlcom ///
	(-(_b[sc_shock_]+_b[f6_sc_]+_b[f12_sc_]+_b[f18_sc_])) ///
	(-(_b[sc_shock_]+_b[f6_sc_]+_b[f12_sc_])) ///
	(-(_b[sc_shock_]+_b[f6_sc_])) ///
	(-_b[sc_shock_]) ///
	(0) ///
	(_b[l6_sc_]) ///
	(_b[l6_sc_]+_b[l12_sc_]) ///
	(_b[l6_sc_]+_b[l12_sc_]+_b[l18_sc_]) ///
	(_b[l6_sc_]+_b[l12_sc_]+_b[l18_sc_]+_b[l24_sc_]) /// 
	(_b[l6_sc_]+_b[l12_sc_]+_b[l18_sc_]+_b[l24_sc_]+_b[l30_sc_]) ///
	(_b[l6_sc_]+_b[l12_sc_]+_b[l18_sc_]+_b[l24_sc_]+_b[l30_sc_]+_b[l36_sc_]) ///
	(_b[l6_sc_]+_b[l12_sc_]+_b[l18_sc_]+_b[l24_sc_]+_b[l30_sc_]+_b[l36_sc_]+_b[l42_sc_]) ///
	, post level(90)

estimates store beta_incr

* plot beta coefficients
coefplot (beta_incr, ciopts(recast(rcap)) recast(connected) level(90)), ///
  	vertical ///
  	keep (_nl_*) ///
  	coeflabel(_nl_1 = -24 _nl_2 = -18 _nl_3 = -12 _nl_4 = -6 _nl_5 = 0 _nl_6 = 6 _nl_7 = 12 _nl_8 = 18 _nl_9 = 24 _nl_10 = 30 _nl_11 = 36 _nl_12 = 42) ///
  	xline(5, lpattern(dash) lwidth(thin) lcolor(black)) xlabel(,labsize(medlarge)) ///
 	yline(0, lcolor(black) lwidth(thin)) ylabel(,labsize(medlarge)) ///
 	graphregion(color(white)) ///
  	xtitle (" " "Months relative to Secure communities shock", size(medlarge)) ytitle ("Treatment effect (90% c.i.)" " ", size(medlarge)) ///
	legend(off) ///
	note(" " "Observations: `obs', Municipalities: `N', Period: `month_start'/`year_start' - `month_end'/`year_end'.", size(small))
	
graph export "Output/Graphs/GES_SC`x'_`y'_mun_norm0.pdf", replace
}
}



eststo clear
foreach x in 5 { 	
foreach y in hh_home1vaway_ent_ hh_shouldbe_int attrit_hhs att_share{
eststo: reghdfe `y' f18_scnw_`x' f12_scnw_`x' f6_scnw_`x' sc_noweight_`x' l6_scnw_`x' l12_scnw_`x' l18_scnw_`x' l24_scnw_`x' l30_scnw_`x' l36_scnw_`x'  $controls [aw=persons], a($fe) cluster(geo2_mx2000)

local obs=e(N)
local N=e(N_clust)
sum year if e(sample)
local year_start = r(min)
local year_end = r(max)
local month_start = 1
local month_end = 12

nlcom ///
	(-(_b[f12_scnw_]+_b[f18_scnw_]+_b[f6_scnw_])) ///
	(-(_b[f12_scnw_]+_b[f6_scnw_])) ///
	(-_b[f6_scnw_]) ///
	(0) ///
	(_b[sc_noweight_]) ///
	(_b[sc_noweight_]+_b[l6_scnw_]) ///
	(_b[sc_noweight_]+_b[l12_scnw_]+_b[l6_scnw_]) ///
	(_b[sc_noweight_]+_b[l12_scnw_]+_b[l6_scnw_]+_b[l18_scnw_]) /// 
	(_b[sc_noweight_]+_b[l12_scnw_]+_b[l6_scnw_]+_b[l18_scnw_]+_b[l24_scnw_]) ///
	(_b[sc_noweight_]+_b[l12_scnw_]+_b[l6_scnw_]+_b[l18_scnw_]+_b[l24_scnw_]+_b[l30_scnw_]) ///
	(_b[sc_noweight_]+_b[l12_scnw_]+_b[l6_scnw_]+_b[l18_scnw_]+_b[l24_scnw_]+_b[l30_scnw_]+_b[l36_scnw_]) ///
	, post level(90)

estimates store beta_incr_

* plot beta coefficients
coefplot (beta_incr_, ciopts(recast(rcap)) recast(connected) level(90)), ///
  	vertical ///
  	keep (_nl_*) ///
  	coeflabel(_nl_1 = -36 _nl_2 = -24 _nl_3 = -12 _nl_4 = 0 _nl_5 = 12 _nl_6 = 24 _nl_7 = 36 _nl_8 = 48) ///
  	xline(4, lpattern(dash) lwidth(thin) lcolor(black)) xlabel(,labsize(medlarge)) ///
 	yline(0, lcolor(black) lwidth(thin)) ylabel(,labsize(medlarge)) ///
 	graphregion(color(white)) ///
  	xtitle (" " "Months relative to Secure communities shock", size(medlarge)) ytitle ("Treatment effect (90% c.i.)" " ", size(medlarge)) ///
	legend(off) ///
	note(" " "Observations: `obs', Municipalities: `N', Period: `month_start'/`year_start' - `month_end'/`year_end'.", size(small))
	
graph export "Output/Graphs/GES_SC`x'_nw_`y'_mun_norm0_noweights.pdf", replace
}
}
*


**************First differences approach
use Data_built\ENOE\hh_attrit_FD.dta
*households less likely to disappear, more likely to join. FD approach
keep if y_ent1 <=2014


global fe i.int_yq i.year##i.geo1_mx2000 i.geo2_mx2000
global controls c.migr_share#i.int_yq 


*can add first period weight but concerned am adding confounds. aw=hh_fac_1
eststo clear
foreach x in 5 { 	
foreach y in hh_home1vaway_ent_5{
*remit question only in ampliado questionair so will only be asked to hh once. 
eststo: reghdfe `y' f18_sc_`x' f12_sc_`x' f6_sc_`x' sc_shock_`x' l6_sc_`x' l12_sc_`x' l18_sc_`x' l24_sc_`x' l30_sc_`x' l36_sc_`x' l42_sc_`x' $controls   if hh_home1vaway_ent_1==1, a($fe) cluster(geo2_mx2000)

local obs=e(N)
local N=e(N_clust)
sum year if e(sample)
local year_start = r(min)
local year_end = r(max)
local month_start = 1
local month_end = 12

nlcom ///
	(-(_b[sc_shock_]+_b[f6_sc_]+_b[f12_sc_]+_b[f18_sc_])) ///
	(-(_b[sc_shock_]+_b[f6_sc_]+_b[f12_sc_])) ///
	(-(_b[sc_shock_]+_b[f6_sc_])) ///
	(-_b[sc_shock_]) ///
	(0) ///
	(_b[l6_sc_]) ///
	(_b[l6_sc_]+_b[l12_sc_]) ///
	(_b[l6_sc_]+_b[l12_sc_]+_b[l18_sc_]) ///
	(_b[l6_sc_]+_b[l12_sc_]+_b[l18_sc_]+_b[l24_sc_]) /// 
	(_b[l6_sc_]+_b[l12_sc_]+_b[l18_sc_]+_b[l24_sc_]+_b[l30_sc_]) ///
	(_b[l6_sc_]+_b[l12_sc_]+_b[l18_sc_]+_b[l24_sc_]+_b[l30_sc_]+_b[l36_sc_]) ///
	(_b[l6_sc_]+_b[l12_sc_]+_b[l18_sc_]+_b[l24_sc_]+_b[l30_sc_]+_b[l36_sc_]+_b[l42_sc_]) ///
	, post level(90)

estimates store beta_incr

* plot beta coefficients
coefplot (beta_incr, ciopts(recast(rcap)) recast(connected) level(90)), ///
  	vertical ///
  	keep (_nl_*) ///
  	coeflabel(_nl_1 = -24 _nl_2 = -18 _nl_3 = -12 _nl_4 = -6 _nl_5 = 0 _nl_6 = 6 _nl_7 = 12 _nl_8 = 18 _nl_9 = 24 _nl_10 = 30 _nl_11 = 36 _nl_12 = 42) ///
  	xline(5, lpattern(dash) lwidth(thin) lcolor(black)) xlabel(,labsize(medlarge)) ///
 	yline(0, lcolor(black) lwidth(thin)) ylabel(,labsize(medlarge)) ///
 	graphregion(color(white)) ///
  	xtitle (" " "Months relative to Secure communities shock", size(medlarge)) ytitle ("Treatment effect (90% c.i.)" " ", size(medlarge)) ///
	legend(off) ///
	note(" " "Observations: `obs', Municipalities: `N', Period: `month_start'/`year_start' - `month_end'/`year_end'.", size(small))
	
graph export "Output/Graphs/GES_SC`x'_`y'_mun_norm0.pdf", replace
}
}

eststo clear
foreach x in 5 { 	
foreach y in hh_home1vaway_ent_5{
eststo: reghdfe `y' f18_scnw_`x' f12_scnw_`x' f6_scnw_`x' sc_noweight_`x' l6_scnw_`x' l12_scnw_`x' l18_scnw_`x' l24_scnw_`x' l30_scnw_`x' l36_scnw_`x'  $controls   if hh_home1vaway_ent_1==1, a($fe) cluster(geo2_mx2000)

local obs=e(N)
local N=e(N_clust)
sum year if e(sample)
local year_start = r(min)
local year_end = r(max)
local month_start = 1
local month_end = 12

nlcom ///
	(-(_b[f12_scnw_]+_b[f18_scnw_]+_b[f6_scnw_])) ///
	(-(_b[f12_scnw_]+_b[f6_scnw_])) ///
	(-_b[f6_scnw_]) ///
	(0) ///
	(_b[sc_noweight_]) ///
	(_b[sc_noweight_]+_b[l6_scnw_]) ///
	(_b[sc_noweight_]+_b[l12_scnw_]+_b[l6_scnw_]) ///
	(_b[sc_noweight_]+_b[l12_scnw_]+_b[l6_scnw_]+_b[l18_scnw_]) /// 
	(_b[sc_noweight_]+_b[l12_scnw_]+_b[l6_scnw_]+_b[l18_scnw_]+_b[l24_scnw_]) ///
	(_b[sc_noweight_]+_b[l12_scnw_]+_b[l6_scnw_]+_b[l18_scnw_]+_b[l24_scnw_]+_b[l30_scnw_]) ///
	(_b[sc_noweight_]+_b[l12_scnw_]+_b[l6_scnw_]+_b[l18_scnw_]+_b[l24_scnw_]+_b[l30_scnw_]+_b[l36_scnw_]) ///
	, post level(90)

estimates store beta_incr_

* plot beta coefficients
coefplot (beta_incr_, ciopts(recast(rcap)) recast(connected) level(90)), ///
  	vertical ///
  	keep (_nl_*) ///
  	coeflabel(_nl_1 = -36 _nl_2 = -24 _nl_3 = -12 _nl_4 = 0 _nl_5 = 12 _nl_6 = 24 _nl_7 = 36 _nl_8 = 48) ///
  	xline(4, lpattern(dash) lwidth(thin) lcolor(black)) xlabel(,labsize(medlarge)) ///
 	yline(0, lcolor(black) lwidth(thin)) ylabel(,labsize(medlarge)) ///
 	graphregion(color(white)) ///
  	xtitle (" " "Months relative to Secure communities shock", size(medlarge)) ytitle ("Treatment effect (90% c.i.)" " ", size(medlarge)) ///
	legend(off) ///
	note(" " "Observations: `obs', Municipalities: `N', Period: `month_start'/`year_start' - `month_end'/`year_end'.", size(small))
	
graph export "Output/Graphs/GES_SC`x'_nw_`y'_mun_norm0_noweights.pdf", replace
}
}
*





























**************First differences approach
use Data_built\ENOE\hh_attrit_FD.dta
*households less likely to disappear, more likely to join. FD approach
keep if y_ent1 <=2014


global fe1 i.qy_ent1  i.y_ent1##i.geo1_mx2000 i.geo2_mx2000


*with weights this conditions on hh being observed in first ent (departures=1 stay=0)
reghdfe yoy_hhdeparts yoy_sc_shock_5_ent1to5 c.migr_share#i.y_ent1 [aw=hh_fac_1], a($fe1) cluster(geo2_mx2000)
reghdfe yoy_hhdeparts   yoy_sc_noweight_5_ent1to5 c.migr_share#i.y_ent5 [aw=hh_fac_1], a($fe5=1) cluster(geo2_mx2000)


*here hh can arrive (1) no change 0 
reghdfe yoy_hharrives  yoy_sc_shock_5_ent1to5 c.migr_share#i.y_ent5  [aw=hh_fac_5] , a($fe5) cluster(geo2_mx2000)
reghdfe yoy_hharrives yoy_sc_noweight_5_ent1to5 c.migr_share#i.y_ent5  [aw=hh_fac_5] , a($fe5) cluster(geo2_mx2000)


*here hh can arrive (-1) no change 0 depart 1
reghdfe yoy_hhattrits yoy_sc_shock_5 c.migr_share#i.y_ent , a($fe) cluster(geo2_mx2000)
reghdfe yoy_hhattrits yoy_sc_noweight_5 c.migr_share#i.y_ent , a($fe) cluster(geo2_mx2000)





**************First differences approach
use Data_built\ENOE\hh_attrit_FD.dta
*households less likely to disappear, more likely to join. FD approach

*QUESTION: time variables here are for ent_1. If using ent_5 weights is that ok? 

global fe1 i.qy_ent1  i.y_ent1##i.geo1_mx2000 i.geo2_mx2000

*with weights this conditions on hh being observed in first ent (departures=1 stay=0)
reghdfe yoy_hhdeparts yoy_sc_shock_5post c.migr_share#i.y_ent1 [aw=hh_fac_1], a($fe1) cluster(geo2_mx2000)
reghdfe yoy_hhdeparts  yoy_sc_noweight_5post c.migr_share#i.y_ent1 [aw=hh_fac_1], a($fe1) cluster(geo2_mx2000)

global fe5 i.int_yq  i.y_ent##i.geo1_mx2000 i.geo2_mx2000

*here hh can arrive (1) no change 0 
reghdfe yoy_hharrives yoy_sc_shock_5 c.migr_share#i.y_ent  [aw=hh_fac_5] , a($fe) cluster(geo2_mx2000)
reghdfe yoy_hharrives yoy_sc_noweight_5 c.migr_share#i.y_ent  [aw=hh_fac_5] , a($fe) cluster(geo2_mx2000)


*here hh can arrive (-1) no change 0 depart 1
reghdfe yoy_hhattrits yoy_sc_shock_5 c.migr_share#i.y_ent , a($fe) cluster(geo2_mx2000)
reghdfe yoy_hhattrits yoy_sc_noweight_5 c.migr_share#i.y_ent , a($fe) cluster(geo2_mx2000)



