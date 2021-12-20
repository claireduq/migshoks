

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

destring first_int_yq, replace
drop if first_int_yq<51
drop if first_int_yq>134

gen geo2_mx2015 = ent*1000 + mun


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

*need to get weights from hh_survey?


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
by hh_id: egen hh_home1vaway_ent_`i'=max(hh_home1vaway_ent_`i'a)
by hh_id: egen hh_fac_`i'=max(fac_`i'a)
drop hh_home1vaway_ent_`i'a fac_`i'a
}

keep hh_id  hh_home1vaway_ent_* hh_fac_*
duplicates drop

egen hh_obs_rounds=rowtotal(hh_home1vaway_ent_1 hh_home1vaway_ent_2 hh_home1vaway_ent_3 hh_home1vaway_ent_4 hh_home1vaway_ent_5)

*tab hh_home1vaway_ent_5, miss
*Share of missing households by round
*1:7.45%  2:7.43%  3:7.76%  4:8.16%  5:8.07%

merge 1:m hh_id using Data_built\ENOE\wide_build.dta 
drop _m



gen home0vaway_ent_1a=.
replace home0vaway_ent_1a=0 if n_ent==1



forval i=2/5{
gen home0vaway_ent_`i'a=.
replace home0vaway_ent_`i'a=0 if n_ent==`i' & c_res==1
*arrive
replace home0vaway_ent_`i'a=1 if n_ent==`i' & c_res==3
*depart
replace home0vaway_ent_`i'a=-1 if n_ent==`i' & c_res==2 
*birth
replace home0vaway_ent_`i'a=8 if n_ent==`i' & c_res==3 & cs_nr_mot==8
*death
replace home0vaway_ent_`i'a=7 if n_ent==`i' &  c_res==2 & cs_ad_mot==8
}
*

sort indiv_id
forval i=1/5{
by indiv_id: egen home0vaway_ent_`i'b=max(home0vaway_ent_`i'a)
drop home0vaway_ent_`i'a
}

*2 if missing due to departed in earlier period
replace home0vaway_ent_3b=2 if home0vaway_ent_3b==. & home0vaway_ent_2b==-1
replace home0vaway_ent_4b=2 if home0vaway_ent_4b==. & inlist(home0vaway_ent_3b, -1,2)
replace home0vaway_ent_5b=2 if home0vaway_ent_5b==. & inlist(home0vaway_ent_4b, -1,2)

*3 if missing and will return in later period 
replace home0vaway_ent_4b=3 if home0vaway_ent_4b==. & home0vaway_ent_5b==1
replace home0vaway_ent_3b=3 if home0vaway_ent_3b==. & inlist(home0vaway_ent_4b,1,3)
replace home0vaway_ent_2b=3 if home0vaway_ent_2b==. & inlist(home0vaway_ent_3b,1,3)
replace home0vaway_ent_1b=3 if home0vaway_ent_1b==. & inlist(home0vaway_ent_2b,1,3)


*6 if missing due to later birth
replace home0vaway_ent_4b=6 if home0vaway_ent_4b==. & home0vaway_ent_5b==8
replace home0vaway_ent_3b=6 if home0vaway_ent_3b==. & inlist(home0vaway_ent_4b,8,6)
replace home0vaway_ent_2b=6 if home0vaway_ent_2b==. & inlist(home0vaway_ent_3b,8,6)
replace home0vaway_ent_1b=6 if home0vaway_ent_1b==. & inlist(home0vaway_ent_2b,8,6)

*4 if missing due to earlier death
replace home0vaway_ent_3b=4 if home0vaway_ent_3b==. & home0vaway_ent_2b==7
replace home0vaway_ent_4b=4 if home0vaway_ent_4b==. & inlist(home0vaway_ent_3b, 7,4)
replace home0vaway_ent_5b=4 if home0vaway_ent_5b==. & inlist(home0vaway_ent_4b, 7,4)


*still have missing observations when entire household is missing from a wave. 
*9 if missing due to entire household inexplicably missing 
replace home0vaway_ent_1b=9 if hh_home1vaway_ent_1==. & home0vaway_ent_1b==.
replace home0vaway_ent_2b=9 if hh_home1vaway_ent_2==. & home0vaway_ent_2b==.
replace home0vaway_ent_3b=9 if hh_home1vaway_ent_3==. & home0vaway_ent_3b==.
replace home0vaway_ent_4b=9 if hh_home1vaway_ent_4==. & home0vaway_ent_4b==.
replace home0vaway_ent_5b=9 if hh_home1vaway_ent_5==. & home0vaway_ent_5b==.


*tab home0vaway_ent_1, missing

*between 3.27 and 4.15 pct of observations missing in each wave due to hh not being interviewed.
*still a small share of missing observations that should be there- ie no information on why not observed. 
*show up without being listed as new residents or disappear without question on departure




forval i=1/5{
gen indiv_notalive1_`i'=0
replace indiv_notalive1_`i'=1 if inlist(home0vaway_ent_`i'b,7, 6, 4)	
}

*household attrition
forval i=1/5{
gen hh_attrit1no0_ent_`i'=0	
replace hh_attrit1no0_ent_`i'=1 if home0vaway_ent_`i'b==9	
}


*individual unexplained attrition indicator 
forval i=1/5{
gen indiv_attrit1no0_ent_`i'=0
replace indiv_attrit1no0_ent_`i'=1 if home0vaway_ent_`i'b==. 
}
*

forval i=1/5{
gen indiv_observable1no0_ent_`i'=1
replace indiv_observable1no0_ent_`i'=0 if indiv_notalive1_`i'==1
replace indiv_observable1no0_ent_`i'=0 if hh_attrit1no0_ent_`i'==1
replace indiv_observable1no0_ent_`i'=0 if indiv_attrit1no0_ent_`i'==1
}


forval i=1/5{
gen home0vaway_ent_`i'=2
replace home0vaway_ent_`i'=. if indiv_observable1no0_ent_`i'==0

replace home0vaway_ent_`i'=0 if home0vaway_ent_`i'b==8
replace home0vaway_ent_`i'=0 if home0vaway_ent_`i'b==0
replace home0vaway_ent_`i'=0 if home0vaway_ent_`i'b==1
replace home0vaway_ent_`i'=1 if home0vaway_ent_`i'b==-1
replace home0vaway_ent_`i'=1 if home0vaway_ent_`i'b==2
replace home0vaway_ent_`i'=1 if home0vaway_ent_`i'b==3
}
*



*similar set up but for international migrants
*for people who are at home or away: determine if in mexico or abroad

gen mex0vabroad_ent_1a=.
replace mex0vabroad_ent_1a=0 if n_ent==1  


*NOTE:cs_ad_des cs_nr_ori are missing assume domestic
forval i=2/5{
gen mex0vabroad_ent_`i'a=.
replace mex0vabroad_ent_`i'a=0 if n_ent==`i' & c_res==1
*domestic migr
replace mex0vabroad_ent_`i'a=2 if n_ent==`i' & c_res==2 & inlist(cs_ad_des,1,2,9,.)
*migr abroad
replace mex0vabroad_ent_`i'a=3 if n_ent==`i' & cs_ad_des==3
*domestic return
replace mex0vabroad_ent_`i'a=4 if n_ent==`i' & c_res==3 & inlist(cs_nr_ori,1,2,9,.)
*return from abroad
replace mex0vabroad_ent_`i'a=5 if n_ent==`i' & c_res==3 & cs_nr_ori==3
}


sort indiv_id
forval i=1/5{
by indiv_id: egen mex0vabroad_ent_`i'b=max(mex0vabroad_ent_`i'a)
drop mex0vabroad_ent_`i'a
}

*note: there is an assumption here that where we are told the person goes is where they will remain for the rest of interviews

*6 if missing due to departed domestic in earlier period
replace mex0vabroad_ent_3b=6 if mex0vabroad_ent_3b==. & mex0vabroad_ent_2b==2
replace mex0vabroad_ent_4b=6 if mex0vabroad_ent_4b==. & inlist(mex0vabroad_ent_3b, 2,6)
replace mex0vabroad_ent_5b=6 if mex0vabroad_ent_5b==. & inlist(mex0vabroad_ent_4b, 2,6)

*7 if missing and will return from domestic in later period 
replace mex0vabroad_ent_4b=7 if mex0vabroad_ent_4b==. & mex0vabroad_ent_5b==4
replace mex0vabroad_ent_3b=7 if mex0vabroad_ent_3b==. & inlist(mex0vabroad_ent_4b,4,7)
replace mex0vabroad_ent_2b=7 if mex0vabroad_ent_2b==. & inlist(mex0vabroad_ent_3b,4,7)
replace mex0vabroad_ent_1b=7 if mex0vabroad_ent_1b==. & inlist(mex0vabroad_ent_2b,4,7)

*8 if missing due to departed abroad in earlier period
replace mex0vabroad_ent_3b=8 if mex0vabroad_ent_3b==. & mex0vabroad_ent_2b==3
replace mex0vabroad_ent_4b=8 if mex0vabroad_ent_4b==. & inlist(mex0vabroad_ent_3b, 3,8)
replace mex0vabroad_ent_5b=8 if mex0vabroad_ent_5b==. & inlist(mex0vabroad_ent_4b, 3,8)

*9 if missing and will return from abroad in later period 
replace mex0vabroad_ent_4b=9 if mex0vabroad_ent_4b==. & mex0vabroad_ent_5b==5
replace mex0vabroad_ent_3b=9 if mex0vabroad_ent_3b==. & inlist(mex0vabroad_ent_4b,5,9)
replace mex0vabroad_ent_2b=9 if mex0vabroad_ent_2b==. & inlist(mex0vabroad_ent_3b,5,9)
replace mex0vabroad_ent_1b=9 if mex0vabroad_ent_1b==. & inlist(mex0vabroad_ent_2b,5,9)




forval i=1/5{
gen mex0vabroad_ent_`i'=2
replace mex0vabroad_ent_`i'=. if home0vaway_ent_`i'==.
replace mex0vabroad_ent_`i'=0 if home0vaway_ent_`i'==0
replace mex0vabroad_ent_`i'=0 if home0vaway_ent_`i'==1 & inlist(mex0vabroad_ent_`i'b,6,7,2,4,5)
replace mex0vabroad_ent_`i'=1 if home0vaway_ent_`i'==1 & inlist(mex0vabroad_ent_`i'b,8,9,3 )

}

drop mex0vabroad_ent_1b mex0vabroad_ent_2b mex0vabroad_ent_3b mex0vabroad_ent_4b mex0vabroad_ent_5b home0vaway_ent_5b home0vaway_ent_4b home0vaway_ent_3b home0vaway_ent_2b home0vaway_ent_1b






keep indiv_id  first_int_yq home0vaway_ent_*  mex0vabroad_ent_* indiv_attrit1no0_ent_* hh_fac_* indiv_notalive1_* hh_attrit1no0_ent_*
duplicates drop
isid indiv_id

reshape long mex0vabroad_ent_  home0vaway_ent_ indiv_attrit1no0_ent_ hh_fac_  indiv_notalive1_ hh_attrit1no0_ent_, i(indiv_id) j(n_ent)

gen first_int_yq_2=first_int_yq
gen str3  first_int_yq_3 = string(first_int_yq_2,"%03.0f")
tostring first_int_yq, replace
gen x=substr(first_int_yq_3,3,1) 
gen y=substr(first_int_yq_3,1,2) 

destring x y, replace

gen newy=y
gen newx=. 

replace newx=1 if n_ent==1 & x==1
replace newx=2 if n_ent==2 & x==1
replace newx=3 if n_ent==3 & x==1
replace newx=4 if n_ent==4 & x==1
replace newx=1 if n_ent==5 & x==1
replace newy=y+1 if n_ent==5 & x==1

replace newx=2 if n_ent==1 & x==2
replace newx=3 if n_ent==2 & x==2
replace newx=4 if n_ent==3 & x==2
replace newx=1 if n_ent==4 & x==2
replace newx=2 if n_ent==5 & x==2
replace newy=y+1 if inlist(n_ent,4, 5) & x==2


replace newx=3 if n_ent==1 & x==3
replace newx=4 if n_ent==2 & x==3
replace newx=1 if n_ent==3 & x==3
replace newx=2 if n_ent==4 & x==3
replace newx=3 if n_ent==5 & x==3
replace newy=y+1 if inlist(n_ent,3,4, 5) & x==3


replace newx=4 if n_ent==1 & x==4
replace newx=1 if n_ent==2 & x==4
replace newx=2 if n_ent==3 & x==4
replace newx=3 if n_ent==4 & x==4
replace newx=4 if n_ent==5 & x==4
replace newy=y+1 if inlist(n_ent,2, 3,4, 5) & x==4

gen int_yq=newy*10+newx


drop x y newx newy

*tostring first_int_yq, replace

tempfile long_build
save `long_build'


merge m:1 indiv_id using  Data_built\ENOE\wide_build_mini.dta
drop _m

merge m:1 geo2_mx2015 using Data_built\Claves\Claves_1960_2015.dta
drop if _m==2 // not all municipalities coevered in any round? 
drop _m geo1_mx2015 geo1_mx2010 geo2_mx2010 geo1_mx2005 geo2_mx2005

save Data_built\ENOE\long_build.dta, replace




/* need to create a migration shock variable at the quarter level.
 Checked: most interviews are conducted in assigned quarter with a few straglers. 
 I think it makes sense to just use the shock variable for the midmonth of the quarter. 
*/
clear 
use  Data_built\Matriculas\Shock_Mat_SecComm_Sanc_5.dta

keep if inlist(month, 2, 5, 8,11)

gen quarter=.
replace quarter=1 if month==2
replace quarter=2 if month==5
replace quarter=3 if month==8
replace quarter=4 if month==11

gen int_yq= (year-2000)*10+quarter

isid    geo2_mx2000 int_yq

merge 1:m  geo2_mx2000 int_yq using Data_built\ENOE\long_build.dta
drop _m

save Data_built\ENOE\long_build.dta, replace

**********************
*build Municipal aggregates


clear
use  Data_built\ENOE\long_build.dta
keep if year<=2014
gen person=1
replace person =0 if indiv_notalive1_==1
replace person =0 if hh_attrit1no0_ent_==1
replace person =0 if indiv_attrit1no0_ent_==1

collapse (sum) person home0vaway_ent_ indiv_attrit1no0_ent_ mex0vabroad_ent_  [pw=hh_fac_], by(geo2_mx2000 quarter year)
rename (person home0vaway_ent_ indiv_attrit1no0_ent_ mex0vabroad_ent_  )(mex_n_mig_pop absent_pop unexp_abs_ind abroad_pop)
save Data_built\ENOE\ENOE_bal_muni_migall.dta, replace




*********************************************************************************
******************************************************
***************************
***************************




***************************
*analysis

clear 
use Data_built\ENOE\long_build.dta

gen sc_shock_5_a = sc_shock_5 / migr_share
gen f24_sc_5_a = f24_sc_5/ migr_share 
gen f12_sc_5_a = f12_sc_5/ migr_share 
gen l12_sc_5_a = l12_sc_5 / migr_share
gen l24_sc_5_a = l24_sc_5 / migr_share 
gen l36_sc_5_a =  l36_sc_5 / migr_share

*log using C:\Users\johnh\Dropbox\MigrationShocks\Output\Log\migration_no_weights.log, replace

keep if year>=2005
keep if year<=2012
keep if migr_share>0


global fe  i.year##i.geo1_mx2000 i.int_yq i.geo2_mx2000

reghdfe mex0vabroad_ent_ f24_sc_5_a f12_sc_5_a sc_shock_5_a l12_sc_5_a l24_sc_5_a l36_sc_5_a  c.migr_share#i.year [aw=hh_fac_] , a($fe) cluster(geo2_mx2000)


gen age_groups=.
forval i=1/14{
	
local t= `i'-1
local a= 10*`t'
local b= (10*`t')+1
local c= (10*`t')+2
local d= (10*`t')+3
local e= (10*`t')+4
local f= (10*`t')+5
local g= (10*`t')+6
local h= (10*`t')+7
local ii= (10*`t')+8
local j= (10*`t')+9



replace age_groups=`i' if inlist(bsline_age, `a', `b', `c', `d', `e', `f', `g', `h',`ii',`j' )	
	
}
/*
gen age_groups=.
replace age_groups=1 if inlist(bsline_age, 0,1,2)
replace age_groups=2 if inlist(bsline_age, 3,4,5)
replace age_groups=3 if inlist(bsline_age, 6,7,8)
replace age_groups=4 if inlist(bsline_age, 9,10,11)
replace age_groups=5 if inlist(bsline_age, 12,13,14)
replace age_groups=6 if inlist(bsline_age, 15,16,17)
replace age_groups=7 if inlist(bsline_age, 18,19,20)
replace age_groups=8 if inlist(bsline_age, 21,22,23)
replace age_groups=9 if inlist(bsline_age, 24,25,26)
replace age_groups=10 if inlist(bsline_age, 27,28,29)
replace age_groups=11 if inlist(bsline_age, 30,31,32)
replace age_groups=12 if inlist(bsline_age, 33,34,35)
replace age_groups=13 if inlist(bsline_age, 36,37,38)
replace age_groups=14 if inlist(bsline_age, 39,40,41)
*/




forval i=1/7{
reghdfe mex0vabroad_ent_ sc_shock_5_a  c.migr_share#i.year [aw=hh_fac_] if age_groups==`i' & msex==2, a($fe) cluster(geo2_mx2000)
estimate store age`i'
}

coefplot  age1 ||  age2 ||  age3 ||  age4 ||  age5 ||  age6 ||  age7 ||  age8 ||  ///
				, vertical  yline(0) keep(sc_shock_5_a) bycoefs byopts(xrescale) 

				
				


log close


reghdfe mex0vabroad_ent_ f24_sc_5_a f12_sc_5_a sc_shock_5_a l12_sc_5_a l24_sc_5_a l36_sc_5_a  c.migr_share#i.year i.msex i.bsline_age [aw=hh_fac_] , a($fe) cluster(geo2_mx2000)


reghdfe mex0vabroad_ent_ f24_sc_5_a f12_sc_5_a sc_shock_5_a l12_sc_5_a l24_sc_5_a l36_sc_5_a   [aw=hh_fac_] , a($fe) cluster(geo2_mx2000)


reghdfe mex0vabroad_ent_ f24_sc_5_a f12_sc_5_a sc_shock_5_a l12_sc_5_a l24_sc_5_a l36_sc_5_a  c.migr_share#i.year [aw=hh_fac_] if msex==1, a($fe) cluster(geo2_mx2000)


reghdfe mex0vabroad_ent_ f24_sc_5_a f12_sc_5_a sc_shock_5_a l12_sc_5_a l24_sc_5_a l36_sc_5_a  c.migr_share#i.year [aw=hh_fac_] if msex==2, a($fe) cluster(geo2_mx2000)

reghdfe mex0vabroad_ent_ f24_sc_5 f12_sc_5 sc_shock_5 l12_sc_5 l24_sc_5 l36_sc_5  c.migr_share#i.year [aw=hh_fac_] if msex==1 , a($fe) cluster(geo2_mx2000)

reghdfe indiv_attrit1no0_ent_ f24_sc_5_a f12_sc_5_a sc_shock_5_a l12_sc_5_a l24_sc_5_a l36_sc_5_a  c.migr_share#i.year [aw=hh_fac_] , a($fe) cluster(geo2_mx2000)

*need to pull in weights? how for missings? Are they constant within individual?
reghdfe home0vaway_ent_ f24_sc_5_a f12_sc_5_a sc_shock_5_a l12_sc_5_a l24_sc_5_a l36_sc_5_a  c.migr_share#i.year [aw=hh_fac_] , a($fe) cluster(geo2_mx2000)

log close





/*






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




use Data_built\ENOE\ENOE_timeuse_shock_all.dta, clear

*want to transfer to wide format key variables: enrollment, attendance, migration, domestic migration, lfp

*observations where we havent loaded all the needed files: 
*should have 5 interviews for hh with first_int_yq between: 051 and 134

destring first_int_yq, replace
drop if first_int_yq<51
drop if first_int_yq>134
*tab times_obs

********************
*start with migration

gen home0vaway_ent_1a=.
replace home0vaway_ent_1a=0 if n_ent==1

forval i=2/5{
gen home0vaway_ent_`i'a=.
replace home0vaway_ent_`i'a=0 if n_ent==`i' & c_res==1
replace home0vaway_ent_`i'a=0 if n_ent==`i' & c_res==3

replace home0vaway_ent_`i'a=1 if n_ent==`i' & migrated==1 
replace home0vaway_ent_`i'a=1 if n_ent==`i' & dom_migrated==1
}



sort indiv_id
forval i=1/5{
by indiv_id: egen home0vaway_ent_`i'=max(home0vaway_ent_`i'a)
drop home0vaway_ent_`i'a
}



*/
