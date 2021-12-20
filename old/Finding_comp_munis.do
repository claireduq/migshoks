
clear all
set more off


*Claire
cd "C:\Users\Claire\Dropbox\MigrationShocks\"


use Data_built\ENOE\ENOE_migr_shock_windows.dta

keep geo1_mx2000 geo2_mx2000 migr_share avg_treat0811_0510
duplicates drop

drop if avg_treat0811_0510==0
sort geo1_mx2000  migr_share 
