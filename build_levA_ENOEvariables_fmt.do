*********************************************************************************
*********************************************************************************
* Sociodemographico
* birth order, number of siblings (older and younger), gender, migration history
foreach x in 1 2 3 4 {
foreach y in 05 06 07 08 09 10 11 12 13 14 15  {
use $Data_raw\ENOE\SDEMT`x'`y'.dta, clear
 rename *, lower
 save $Data_raw\ENOE\SDEMT`x'`y'.dta, replace
}
}
*