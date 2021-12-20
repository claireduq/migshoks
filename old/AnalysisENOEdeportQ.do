
*Esther
*cd "C:\Users\gehrk001\Dropbox\MigrationShocks\"

cd "C:\Users\Claire\Dropbox\MigrationShocks\"

********************************************************************************
use Data_built\ENOE\ENOE_retplans_shock.dta, clear
global fem i.year##i.month i.year##i.geo1_mx2000 i.month i.geo2_mx2000

reghdfe migrated f12_sc2 f9_sc2  f6_sc2  f3_sc2  sc_shock2  l3_sc2 l6_sc2  l9_sc2 l12_sc2   l15_sc2 l18_sc2  l21_sc2 l24_sc2  c.migr_share#i.year if migr_share>0 , a($fem) cluster(geo2_mx2000)

reghdfe returned f12_sc2 f9_sc2  f6_sc2  f3_sc2  sc_shock2  l3_sc2 l6_sc2  l9_sc2 l12_sc2   l15_sc2 l18_sc2  l21_sc2 l24_sc2  c.migr_share#i.year if migr_share>0 , a($fem) cluster(geo2_mx2000)


reghdfe unemp_border_cross f12_sc2 f9_sc2  f6_sc2  f3_sc2  sc_shock2  l3_sc2 l6_sc2  l9_sc2 l12_sc2   l15_sc2 l18_sc2  l21_sc2 l24_sc2  c.migr_share#i.year if migr_share>0 , a($fem) cluster(geo2_mx2000)
reghdfe newjob_border_cross f12_sc2 f9_sc2  f6_sc2  f3_sc2  sc_shock2  l3_sc2 l6_sc2  l9_sc2 l12_sc2   l15_sc2 l18_sc2  l21_sc2 l24_sc2  c.migr_share#i.year if migr_share>0 , a($fem) cluster(geo2_mx2000)



use Data_built\ENOE\ENOE_remittances_shock.dta, clear
global fem i.year##i.month i.year##i.geo1_mx2000 i.month i.geo2_mx2000

reghdfe hh_remit f12_sc2 f9_sc2  f6_sc2  f3_sc2  sc_shock2  l3_sc2 l6_sc2  l9_sc2 l12_sc2   l15_sc2 l18_sc2  l21_sc2 l24_sc2  c.migr_share#i.year if migr_share>0 , a($fem) cluster(geo2_mx2000)


*log using Output\Log\hh_migration, replace text

use Data_built\ENOE\ENOE_deportation_shock_ym.dta, clear

global fem i.year##i.month i.edate##i.geo1_mx2000 i.month i.geo2_mx2000

*year month

*Effects by why the sign switch: 
*ALSO: not sure how to use weights 
reghdfe sum_rep_dep f12_sc2 f9_sc2  f6_sc2  f3_sc2  sc_shock2  l3_sc2 l6_sc2  l9_sc2 l12_sc2   l15_sc2 l18_sc2  l21_sc2 l24_sc2  c.migr_share#i.year if migr_share>0 , a($fem) cluster(geo2_mx2000)
reghdfe sum_rep_dep f12_sc2 f9_sc2  f6_sc2  f3_sc2  sc_shock2  l3_sc2 l6_sc2  l9_sc2 l12_sc2   l15_sc2 l18_sc2  l21_sc2 l24_sc2  c.migr_share#c.edate if migr_share>0 , a($fem) cluster(geo2_mx2000)


use Data_built\ENOE\ENOE_deportation_shock_y.dta, clear

global fe i.year i.year##i.geo1_mx2000  i.geo2_mx2000


reghdfe sum_rep_dep f12_sc2 sc_shock2 l12_sc2  c.migr_share#i.year if migr_share>0 , a($fe) cluster(geo2_mx2000)

reghdfe sum_rep_dep f24_sc2 f12_sc2 sc_shock2 l12_sc2 l24_sc2  c.migr_share#i.year if migr_share>0 , a($fe) cluster(geo2_mx2000)


reghdfe sum_rep_dep f12_sc2 sc_shock2 l12_sc2  c.migr_share#c.edate if migr_share>0 , a($fe) cluster(geo2_mx2000)

reghdfe sum_rep_dep f24_sc2 f12_sc2 sc_shock2 l12_sc2 l24_sc2  c.migr_share#c.edate if migr_share>0 , a($fe) cluster(geo2_mx2000)
