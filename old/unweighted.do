
if "`c(username)'"=="gehrk001" {
	cap cd "C:\Users\gehrk001\Dropbox\MigrationShocks\"
}

if "`c(username)'"=="Claire" {
	cap cd "C:\Users\Claire\Dropbox\MigrationShocks\"
}

if "`c(username)'"=="johnh" {
	cap cd "C:\Users\johnh\Dropbox\MigrationShocks\"
}

*************************************************************************************

use Data_built\ENOE\ENOE_timeuse_shock_all.dta, clear
keep if int_year>=2005
keep if int_year<=2012
keep if eda<21



gen sc_shock_5_a = sc_shock_5 / migr_share
gen f24_sc_5_a = f24_sc_5/ migr_share 
gen f12_sc_5_a = f12_sc_5/ migr_share 
gen l12_sc_5_a = l12_sc_5 / migr_share
gen l24_sc_5_a = l24_sc_5 / migr_share 
gen l36_sc_5_a =  l36_sc_5 / migr_share

global fe i.sex i.eda i.time_yq i.int_year##i.geo1_mx2000 i.int_month i.geo2_mx2000

eststo clear 	
foreach y in study enroll lfp {
eststo: reghdfe `y' f12_sc_5_a sc_shock_5_a l12_sc_5_a l24_sc_5_a l36_sc_5_a c.migr_share#i.int_year [aw=fac], a($fe) cluster(geo2_mx2000)

}

reghdfe migrant f12_sc_5_a sc_shock_5_a l12_sc_5_a l24_sc_5_a l36_sc_5_a c.migr_share#i.int_year [aw=fac] if eda>16 , a($fe) cluster(geo2_mx2000)




****REMITTANCES:
clear
use Data_built\ENOE\ENOE_timeuse_shock_all.dta, clear
keep if int_year>=2005
keep if int_year<=2012
drop if hh_report_remit==.

keep hh_id hh_report_remit sc_shock_5  migr_share f24_sc_5 f12_sc_5  l12_sc_5  l24_sc_5 l36_sc_5 time_yq int_year geo1_mx2000 int_month geo2_mx2000 fac quarter
duplicates drop

egen hh_id_q=concat(hh_id quarter)
duplicates tag  hh_id_q, gen(duple)

keep if duple==1
gen sc_shock_5_a = sc_shock_5 / migr_share
gen f24_sc_5_a = f24_sc_5/ migr_share 
gen f12_sc_5_a = f12_sc_5/ migr_share 
gen l12_sc_5_a = l12_sc_5 / migr_share
gen l24_sc_5_a = l24_sc_5 / migr_share 
gen l36_sc_5_a =  l36_sc_5 / migr_share

* in first differences
sort hh_id_q
by hh_id_q: egen earliest=min(time_yq)
gen time=2
replace time=1 if earliest==time_yq
 
keep hh_report_remit sc_shock_5_a sc_shock_5  geo1_mx2000 geo2_mx2000 int_year fac migr_share hh_id_q time

reshape wide hh_report_remit sc_shock_5_a sc_shock_5 geo1_mx2000  geo2_mx2000 int_year fac migr_share, i(hh_id_q)  j(time)

gen remit_fd= hh_report_remit2-hh_report_remit1
gen sc_shock_5_a_fd= sc_shock_5_a2-sc_shock_5_a1
gen sc_shock_5_fd= sc_shock_52-sc_shock_51


global fe  i.int_year1##i.geo1_mx20001 
reghdfe remit_fd sc_shock_5_a_fd c.migr_share1#i.int_year1 [aw=fac1] if int_year1, a($fe) cluster(geo2_mx20001)


* get 5% significance if look at high movement time period. ...whatever you want to make of this.  
reghdfe remit_fd sc_shock_5_a_fd c.migr_share1#i.int_year1 [aw=fac1] if int_year1<2010 & int_year1>2006, a($fe) cluster(geo2_mx20001)
tab  remit_fd if int_year1<2010 & int_year1>2006

reghdfe remit_fd sc_shock_5_fd c.migr_share1#i.int_year1 [aw=fac1] if int_year1>2006, a($fe) cluster(geo2_mx20001)
reghdfe remit_fd sc_shock_5_fd c.migr_share1#i.int_year1 [aw=fac1] if int_year1<2010 & int_year1>2006, a($fe) cluster(geo2_mx20001)


****REMITTANCES:
clear
use Data_built\ENOE\ENOE_timeuse_shock_all.dta, clear
keep if int_year>=2005
keep if int_year<=2012
drop if hh_report_remit==.

keep hh_id hh_report_remit sc_shock_5  migr_share f24_sc_5 f12_sc_5  l12_sc_5  l24_sc_5 l36_sc_5 time_yq int_year geo1_mx2000 int_month geo2_mx2000 fac quarter
duplicates drop


*issue, remitance question asked multiple times early on and twice in later panels. 
*FOR THE MOMENT: limiting to first observation per household
sort hh_id
by hh_id: egen earliest=min(time_yq)
keep if time_yq==earliest
 
gen sc_shock_5_a = sc_shock_5 / migr_share
gen f24_sc_5_a = f24_sc_5/ migr_share 
gen f12_sc_5_a = f12_sc_5/ migr_share 
gen l12_sc_5_a = l12_sc_5 / migr_share
gen l24_sc_5_a = l24_sc_5 / migr_share 
gen l36_sc_5_a =  l36_sc_5 / migr_share

global fe i.time_yq i.int_year##i.geo1_mx2000 i.geo2_mx2000

reghdfe hh_report_remit f24_sc_5_a f12_sc_5_a sc_shock_5_a l12_sc_5_a l24_sc_5_a l36_sc_5_a c.migr_share#i.int_year [aw=fac] if int_year<2011 & int_year>2006, a($fe) cluster(geo2_mx2000)



/*
*someone in hh reports remitnces
sort hh_id_visit n_ent
by  hh_id_visit: egen hh_report_remit=total(got_remit_3m)
replace hh_report_remit=1 if hh_report_remit>=1
replace hh_report_remit=. if inlist(svy_type, "basic_old","basic_new")
*/



global fe i.time_yq i.int_year##i.geo1_mx2000 i.int_month i.geo2_mx2000


reghdfe hh_report_remit f12_sc_5_a sc_shock_5_a l12_sc_5_a l24_sc_5_a l36_sc_5_a c.migr_share#i.int_year [aw=fac] , a($fe) cluster(geo2_mx2000)


