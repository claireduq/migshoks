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


clear
import delimited "Data_raw\SIMBAD\SIMBAD_Enrollment.csv", encoding(UTF-8)

rename (índicederetenciónenprimariaa índicedeaprovechamientoenprimari índicederetenciónensecundariaa índicedeaprovechamientoensecunda índicederetenciónenbachilleratoa índicedeaprovechamientoenbachill alumnosexistenciaseneducaciónbás alumnosaprobadoseneducaciónbásic alumnosegresadoseneducaciónbásic personaldocenteeneducaciónbásica escuelaseneducaciónbásicaymedias) (retention_prim_1993 pass_prim_1993 retention_sec_1993 pass_sec_1993 retention_hs_1993 pass_hs_1993 no_attend_1993 no_pass_1993 no_grad_1993 teachers_1993 schools_1993)

rename (v14 v15 v16 v17 v18 v19 v20 v21 v22 v23 v24) (retention_prim_1994 pass_prim_1994 retention_sec_1994 pass_sec_1994 retention_hs_1994 pass_hs_1994 no_attend_1994 no_pass_1994 no_grad_1994 teachers_1994 schools_1994)

rename (v25 v26 v27 v28 v29 v30 v31 v32 v33 v34 v35) (retention_prim_1995 pass_prim_1995 retention_sec_1995 pass_sec_1995 retention_hs_1995 pass_hs_1995 no_attend_1995 no_pass_1995 no_grad_1995 teachers_1995 schools_1995)

rename (v36 v37 v38 v39 v40 v41 v42 v43 v44 v45 v46) (retention_prim_1996 pass_prim_1996 retention_sec_1996 pass_sec_1996 retention_hs_1996 pass_hs_1996 no_attend_1996 no_pass_1996 no_grad_1996 teachers_1996 schools_1996)

rename (v47 v48 v49 v50 v51 v52 v53 v54 v55 v56 v57) (retention_prim_1997 pass_prim_1997 retention_sec_1997 pass_sec_1997 retention_hs_1997 pass_hs_1997 no_attend_1997 no_pass_1997 no_grad_1997 teachers_1997 schools_1997)

rename (v58 - v68) (retention_prim_1998 pass_prim_1998 retention_sec_1998 pass_sec_1998 retention_hs_1998 pass_hs_1998 no_attend_1998 no_pass_1998 no_grad_1998 teachers_1998 schools_1998)

rename (v69 - v79) (retention_prim_1999 pass_prim_1999 retention_sec_1999 pass_sec_1999 retention_hs_1999 pass_hs_1999 no_attend_1999 no_pass_1999 no_grad_1999 teachers_1999 schools_1999)

rename (v80 - v90) (retention_prim_2000 pass_prim_2000 retention_sec_2000 pass_sec_2000 retention_hs_2000 pass_hs_2000 no_attend_2000 no_pass_2000 no_grad_2000 teachers_2000 schools_2000)

rename (v91 - v101) (retention_prim_2001 pass_prim_2001 retention_sec_2001 pass_sec_2001 retention_hs_2001 pass_hs_2001 no_attend_2001 no_pass_2001 no_grad_2001 teachers_2001 schools_2001) 

rename (v102 - v112) (retention_prim_2002 pass_prim_2002 retention_sec_2002 pass_sec_2002 retention_hs_2002 pass_hs_2002 no_attend_2002 no_pass_2002 no_grad_2002 teachers_2002 schools_2002)

rename (v113 - v123) (retention_prim_2003 pass_prim_2003 retention_sec_2003 pass_sec_2003 retention_hs_2003 pass_hs_2003 no_attend_2003 no_pass_2003 no_grad_2003 teachers_2003 schools_2003) 
rename (v124 - v134) (retention_prim_2004 pass_prim_2004 retention_sec_2004 pass_sec_2004 retention_hs_2004 pass_hs_2004 no_attend_2004 no_pass_2004 no_grad_2004 teachers_2004 schools_2004)
 
rename (v135 - v145) (retention_prim_2005 pass_prim_2005 retention_sec_2005 pass_sec_2005 retention_hs_2005 pass_hs_2005 no_attend_2005 no_pass_2005 no_grad_2005 teachers_2005 schools_2005)

rename (v146 - v156) (retention_prim_2006 pass_prim_2006 retention_sec_2006 pass_sec_2006 retention_hs_2006 pass_hs_2006 no_attend_2006 no_pass_2006 no_grad_2006 teachers_2006 schools_2006)

rename (v157 - v167) (retention_prim_2007 pass_prim_2007 retention_sec_2007 pass_sec_2007 retention_hs_2007 pass_hs_2007 no_attend_2007 no_pass_2007 no_grad_2007 teachers_2007 schools_2007)

rename (v168 - v178) (retention_prim_2008 pass_prim_2008 retention_sec_2008 pass_sec_2008 retention_hs_2008 pass_hs_2008 no_attend_2008 no_pass_2008 no_grad_2008 teachers_2008 schools_2008)

rename (v179 - v189) (retention_prim_2009 pass_prim_2009 retention_sec_2009 pass_sec_2009 retention_hs_2009 pass_hs_2009 no_attend_2009 no_pass_2009 no_grad_2009 teachers_2009 schools_2009)

rename (v190 - v200) (retention_prim_2010 pass_prim_2010 retention_sec_2010 pass_sec_2010 retention_hs_2010 pass_hs_2010 no_attend_2010 no_pass_2010 no_grad_2010 teachers_2010 schools_2010)

rename (v201 - v211) (retention_prim_2011 pass_prim_2011 retention_sec_2011 pass_sec_2011 retention_hs_2011 pass_hs_2011 no_attend_2011 no_pass_2011 no_grad_2011 teachers_2011 schools_2011)

rename (v212 - v222) (retention_prim_2012 pass_prim_2012 retention_sec_2012 pass_sec_2012 retention_hs_2012 pass_hs_2012 no_attend_2012 no_pass_2012 no_grad_2012 teachers_2012 schools_2012)

rename (v223 - v233) (retention_prim_2013 pass_prim_2013 retention_sec_2013 pass_sec_2013 retention_hs_2013 pass_hs_2013 no_attend_2013 no_pass_2013 no_grad_2013 teachers_2013 schools_2013)

rename (v234 - v244) (retention_prim_2014 pass_prim_2014 retention_sec_2014 pass_sec_2014 retention_hs_2014 pass_hs_2014 no_attend_2014 no_pass_2014 no_grad_2014 teachers_2014 schools_2014)

rename (v245 - v255) (retention_prim_2015 pass_prim_2015 retention_sec_2015 pass_sec_2015 retention_hs_2015 pass_hs_2015 no_attend_2015 no_pass_2015 no_grad_2015 teachers_2015 schools_2015)

destring retention_prim_1993 - schools_2015, ignore("ND") replace

drop if clave==33 | clave>33990

* keep only municipalities
drop if clave<=32
drop if nombre=="No especificada" | nombre=="No especificado" | nombre=="No identificado" ///
	| nombre=="Resto de los municipios" | nombre=="Otros estados" | nombre=="Otros municipios"

keep no_attend_* no_pass_* no_grad_* clave nombre
reshape long no_attend_ no_pass_ no_grad_ , i(clave nombre) j(year)
keep if year>=2000

rename clave geo2_mx2017
merge m:1 geo2_mx2017 using Data_built\Claves\Claves_1960_2017.dta
drop if _m==2 // not all municipalities coevered in any round? 
* 30 municipalities cannot be merged, these do not exist in any list of municipalities I have access to
// but also have no data 
 
drop if _m==1 & no_attend_==0 & no_pass_==0 & no_grad_==0
ta _m 
drop _m geo1_mx2015 geo1_mx2010 geo2_mx2010 geo1_mx2005 geo2_mx2005 
collapse (sum) no_attend_ no_pass_ no_grad_ , by(year geo1_mx2000 geo2_mx2000)
gen log_attendance = log(no_attend_)
gen log_completion = log(no_pass)
gen log_graduation = log(no_grad)
*drop no_attend_ no_pass_ no_grad_ 
label var log_attendance "Attendance in pre-schools, primary, secondary (log, SIMBAD)"
label var log_completion "Completion in pre-schools, primary, secondary (log, SIMBAD)"
label var log_graduation "Graduation from pre-schools, primary, secondary (log, SIMBAD)"
su
ta year if no_attend==0 // 570 missings (zeroes that were miss before collapse) in 2000, 2001, 2014 perhaps should consider dropping these years? interpolate 2014?  
save "Data_built\SIMBAD\SIMBAD_Enrollment.dta", replace


