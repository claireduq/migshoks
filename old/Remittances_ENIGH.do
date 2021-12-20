
cd C:\Users\esthe\ownCloud\gehrke8\Data\Mexico\ENIGH\

use "\ncv_ingresos_2014_concil_2010.dta"

egen ID=group(folioviv foliohog)

egen rem= rowtotal(ing_1 ing_2 ing_3 ing_4 ing_5 ing_6) if clave=="P040" | clave=="P041"
gen anyrem=1 if clave=="P040" | clave=="P041"
recode anyrem .=0

collapse (max) anyrem (sum) rem, by(ID)
su

clear 

use "C:\Users\esthe\ownCloud\gehrke8\Data\Mexico\ENIGH\ncv_ingresos_2014_concil_2010.dta", clear

egen ID=group( folioviv foliohog)

egen rem= rowtotal(ing_1 ing_2 ing_3 ing_4 ing_5 ing_6) if  clave=="P041"
gen anyrem=1 if clave=="P041"
recode anyrem .=0

collapse (max) anyrem (sum) rem, by(ID)
su

******************************************************************************
clear 
use ncv_ingresos_2014_concil_2010.dta

merge m:1 folioviv using NCV_vivi_2014_concil_2010.dta
keep if _merge==3
drop _merge

egen ID=group( folioviv foliohog)

su ubica_geo
gen state= substr(ubica_geo,1,2)
gen mun= substr(ubica_geo,3,3)
*browse ubica state mun

egen rem= rowtotal(ing_1 ing_2 ing_3 ing_4 ing_5 ing_6) if  clave=="P041"
gen anyrem=1 if clave=="P041"
recode anyrem .=0

collapse (max) anyrem (sum) rem, by(ID state mun)
ta state anyrem
