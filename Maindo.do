*MASTER DO FILE FOR MIGRATION SHOCK PROJECT

*PROJECT DESCRIPTION

*Input files:

*output files


**************************************
clear all
set more off

*Install all packages that this project requires:
/*	   ssc install ietoolkit, replace
       ssc install estout   , replace
	   ssc install reghdfe  , replace
       ssc install ivreg2   , replace 
	   ssc install shp2dta  , replace
	   ssc install carryforward , replace
	   
	    */
		
		
		
*Standardize settings accross users
       ieboilstart, version(12.1)      //Set the version number to oldest version used in the team
       `r(version)'                    //This line actually sets the version from the command above
	   
*GLOBAL ROOT FOLDERS
   
   if "`c(username)'"=="gehrk001" {
	global projectfolder "C:\Users\gehrk001\Dropbox\MigrationShocks2\"
}
if "`c(username)'"=="esthe" {
	global projectfolder "C:\Users\esthe\Dropbox\MigrationShocks2\"
}
if "`c(username)'"=="Claire" {
	global projectfolder "C:\Users\Claire\Dropbox\MigrationShocks2\"
}
if "`c(username)'"=="johnh" {
	global projectfolder "C:\Users\johnh\Dropbox\MigrationShocks2\"
}

   * Project folder globals
   * ---------------------
   global Data_raw       "$projectfolder\Data_raw"
   global Data_built     "$projectfolder\Data_built"
   global output         "$projectfolder\Output"
   global dofiles        "$projectfolder\git_migshks_code"
   
*RUNNING DO FILES  


*//Change the locals below to specify which files to run or not 
   
*BUILD FILES   
   local A_census_migrants     			  0 // 1 min
   local B_mun_keys     			      0 // 1 min
   local C_sanctuary_cities     	      0 // 1 min
   local D_USkeys			    	      0 // 1 min
   local E_secure_communities			  0 // 1 min
*   local EMIF							  0 // 1 min//still using? CUtting becaus I dont think it is making anything we are using. 
   local F_EMIF_incoming_outgoing		  0 // 5 min//still using?
*   local EMIF_migration				  0 // 1 min//still using? calling unbuilt file census2010_col2.dta?
   local G_matriculas  				 	  0 // 20 min
*   local ENOE_fmt						  0 // 1 min //IS THIS STEP STILL NEEDED? LOOKS LIKE THE RAW DATA FILES ARE ALREADY LOWERCASE/HAVE BEEN OVERWRITTEN. fOR REPLICABILITY SHOULD WE REDOWNLOAD RAW FILES AND PUT THIS STEP IN ENOE_all DO FILE?
   local H_ENOE_all						  0 // min
   local I_ENOE_muni_agg  				  0 // min
   local J_indiv_yoy					  0 // min
   local K_muni_yoy						  0 // min

*ANALYSIS FILES   
   local L_muni_yoy_graphs	 			  0 //min
   local M_muni_yoy_reg		  		      0 // 10 min
   local N_muni_graphs					  0 
   local O_hh_indiv_yoy_graphs			  1
   *still working on

   local analysis_hh_indiv_graphs

 *MISCELLANEOUS  
   *NEED TO MAKE NEW MAPS USING MATRICULAS
   
   
   

   
   
  *build files

   if (`A_census_migrants' == 1) { //Change the local above to run or not to run this file
       do "$dofiles\A_Census_migrants.do" 
   } 
   /*ABOUT FILE build_levA_Census_migrants:
INPUTS:
Raw-data inputs:
*Data_raw\MexCensus\ipumsi_00005.dta
*Data_raw\Map_IPUMS\geo2_mx1960_2015(...)

Built-data inputs:NA

OUTPUTS:
Built-data outputs:
*Data_built\census2000_col.dta

Figures:NA
Tables:NA
*/

   if (`B_mun_keys' == 1) { //Change the local above to run or not to run this file
       do "$dofiles\B_mun_keys.do"
   }
    
	/*ABOUT FILE build_levA_mun_keys:
INPUTS:
Raw-data inputs:
*Data_raw\Claves\Claves.xlsx
*Data_raw\MexCensus\ipumsi_00005.dta
Built-data inputs:NA

OUTPUTS:
Built-data outputs:
$Data_built\Claves_1960_2017.dta
$Data_built\Claves_1960_2010.dta
$Data_built\Claves_1960_2015.dta
Figures: NA
Tables: NA
*/

   if (`C_sanctuary_cities' == 1) { //Change the local above to run or not to run this file
       do "$dofiles\C_sanctuary_cities.do"
   }
 
 /*ABOUT FILE build_levA_sanctuary_cities:
INPUTS:
Raw-data inputs:
$Data_raw\SancCities\page8-page-1-table-1.csv
$Data_raw\SancCities\page`x'-page-1-table-1.csv
Built-data inputs:NA

OUTPUTS:
Built-data outputs:
$Data_built\sancturay_cities_wide.dta
Figures:NA
Tables:NA
*/
    if (`D_USkeys' == 1) { //Change the local above to run or not to run this file
       do "$dofiles\D_USkeys.do"
   }
   
   /*ABOUT FILE build_levA_USkeys:
INPUTS:
Raw-data inputs:
$Data_raw\EMIF\bas21_codes.xlsx
Built-data inputs:NA

OUTPUTS:
Built-data outputs:
$Data_built\claves_eua_2020_mun.dta
Figures:NA
Tables:NA
*/
     if (`E_secure_communities' == 1) { //Change the local above to run or not to run this file
       do "$dofiles\E_secure_communities.do"
   }
   
   
/*ABOUT FILE build_levB_secure_communities:
INPUTS:
Raw-data inputs:
$Data_raw\SecureComm\page8-page-1-table-1.csv
$Data_raw\SecureComm\page`x'-page-1-table-1.csv
Built-data inputs:
$Data_built\sancturay_cities_wide.dta
OUTPUTS:
Built-data outputs:
$Data_built\sec_comm_activation_usav.dta
$Data_built\sec_comm_activation_wide.dta
$Data_built\sec_comm_activation_wide_mat.dta
Figures:NA
Tables:NA
*/

 /*
      if (`EMIF' == 1) { //Change the local above to run or not to run this file
       do "$dofiles\build_levC_EMIF.do"
   }
   

/*ABOUT FILE build_levC_EMIF:
INPUTS:
Raw-data inputs:
*Data_raw\EMIF\PDS_Descriptores_`x'.csv
*Data_raw\EMIF\ENORTE_procsur`x'.csv
*Data_raw\EMIF\SUR_`x'.csv
*Data_raw\EMIF\PDS_Valores_`x'.csv
$dofiles\EMIFlabels\my_labels_`x'.do (label files)
$Data_raw\EMIF\claves_eua_2003.dta (WERE THESE RAW OR BUILT?)
$Data_raw\EMIF\claves_eua_2000.dta (WERE THESE RAW OR BUILT?)

Built-data inputs:
$Data_built\Claves_1960_2010.dta
$Data_built\sec_comm_activation_wide.dta
$Data_built\census2000_col.dta"

OUTPUTS:
Built-data outputs:
$Data_built\EMIF_1999_2008.dta
$Data_built\Shock_EMIF_SecComm_Sanc_2.dta
Figures:NA
Tables:NA
*/
*/
 
       if (`F_EMIF_incoming_outgoing' == 1) { //Change the local above to run or not to run 
       do "$dofiles\F_EMIF_incoming_outgoing.do"
   }
   
   
/*ABOUT FILE build_levC_EMIF_incoming_outgoing:
INPUTS:
Raw-data inputs:
*Data_raw\EMIF\PDS_Descriptores_`x'.csv
$Data_raw\EMIF\PEUA-T__`x'.csv
$Data_raw\EMIF\PEUA-T_Descriptores_`x'.csv
$Data_raw\EMIF\DEV_Descriptores_`x'.csv
*Data_raw\EMIF\ENORTE_procsur`x'.csv
*Data_raw\EMIF\SUR_`x'.csv
$Data_raw\EMIF\DEV `x'.csv"
*Data_raw\EMIF\PDS_Valores_`x'.csv
"$Data_raw\EMIF\PFN `x'.csv"
"$Data_raw\EMIF\PFN_Descriptores_`x'.csv"

$Data_raw\EMIF\PEUA-T `x'.csv"
$dofiles\EMIFlabels\my_labels_`x'.do (label files)
$Data_raw\EMIF\codes_emif_1999.dta"(WERE THESE RAW OR BUILT?)
$Data_raw\EMIF\claves_eua_2020.dta"(WERE THESE RAW OR BUILT?)
Built-data inputs:
"$Data_built\claves_eua_2020_mun.dta"
"$Data_built\Claves_1960_2010.dta"
"$Data_built\sec_comm_activation_wide.dta" 
"$Data_built\census2000_col.dta"

OUTPUTS:
Built-data outputs:
"$Data_built\EMIF_all_1999_2008.dta"
"$Data_built\Shock_EMIF_SecComm_Sanc_1.dta"
"$Data_built\Shock_EMIF_SecComm_Sanc_2.dta"
"$Data_built\Shock_EMIF_SecComm_Sanc_3.dta"
"$Data_built\Shock_EMIF_SecComm_Sanc_4.dta"
Figures:NA
Tables:NA
*/

/* 
        if (`EMIF_migration' == 1) { //Change the local above to run or not to run 
       do "$dofiles\build_levC_EMIF_migration.do"
   }
   
   
/*ABOUT FILE build_levC_EMIF_migration:
INPUTS:
Raw-data inputs:
$Data_raw\EMIF\PDS_Descriptores_`x'.csv
$Data_raw\EMIF\ENORTE_procsur`x'.csv
$Data_raw\EMIF\SUR_`x'.csv
$dofiles\EMIFlabels\my_labels_`x'.do (label files)
$Data_raw\census2010_col2.dta" (NOT SURE WHERE THIS FILE IS COMMING FROM: IS IT BUILT?)
Built-data inputs:
"$Data_built\Claves_1960_2017.dta"
"$Data_built\Shock_EMIF_SecComm_Sanc_2.dta"


OUTPUTS:
Built-data outputs:
 $Data_built\EMIF_migr_shock.dta,
Figures: na
Tables: NA
*/
*/
 
         if (`G_matriculas' == 1) { //Change the local above to run or not to run 
       do "$dofiles\G_matriculas.do"
   }
 

/*ABOUT FILE build_levC_matriculas:
INPUTS:
Raw-data inputs:
$Data_raw\Matriculas\Matriculasmuniconda 2005-2006-2007.xlsx
$Data_raw\Matriculas\matriculasmuniconda08.xlsx
Built-data inputs:
$Data_built\Claves_1960_2017.dta
$Data_built\sec_comm_activation_wide_mat.dta
$Data_built\census2000_col.dta
OUTPUTS:
Built-data outputs:
$Data_built\Matriculas_all.dta
$Data_built\Shock_Mat_SecComm_Sanc_5.dta
$Data_built\Shock_Mat_SecComm_Sanc_all.dta
$Data_built\Shock_SecComm_Sanc_all_yq_med.dta
$Data_built\Shock_SecComm_Sanc_all_yq_mean.dta
Figures:NA
Tables:NA
*/

/*
   
         if (`ENOE_fmt' == 1) { //Change the local above to run or not to run 
       do "$dofiles\build_levA_ENOEvariables_fmt.do"
   }
  
/*ABOUT FILE build_levA__ENOEvariables_fmt: This file simply converts the original ENOE variables to lowercase
INPUTS:
Raw-data inputs:
$Data_raw\ENOE\SDEMT`x'`y'.dta
Built-data inputs:NA
OUTPUTS:
Built-data outputs:
$Data_raw\ENOE\SDEMT`x'`y'.dta
Figures:NA
Tables:NA
*/
 */  
   
         if (`H_ENOE_all' == 1) { //Change the local above to run or not to run 
       do "$dofiles\H_ENOE_all.do"
   }
  
/*ABOUT FILE build_levD_ENOE_allvariables_simplified3:
INPUTS:
Raw-data inputs:
$Data_raw\ENOE\SDEMT`x'`y'.dta
$Data_raw\ENOE\HOGT`x'`y'.dta
$Data_raw\ENOE\COE...`y'.dta
Built-data inputs:
$Data_built\Claves_1960_2015.dta

OUTPUTS:
Built-data outputs:
$Data_built\time_use_all_merge.dta		\\DROPABLE?
$Data_built\time_use_all_merge2.dta
 $Data_built\indiv_attrit_wide.dta
 $Data_built\hh_attrit_wide.dta
 $Data_built\wide_build.dta
Figures:
Tables:
*/



           if (`I_ENOE_muni_agg' == 1) { //Change the local above to run or not to run 
       do "$dofiles\I_municipal_agg.do"
   }
  
   /*ABOUT FILE ABOVE:
INPUTS:
Raw-data inputs:

Built-data inputs:
 $Data_built\time_use_all_merge2
 $Data_built\ENOE_muniaggtotpop.dta
 $Data_built\munpopweights.dta
  $Data_built\Shock_SecComm_Sanc_all_yq_med.dta
OUTPUTS:
Built-data outputs:
$Data_built\ENOE_muniagg_prog.dta
Figures:
Tables:
*/


           if (`J_indiv_yoy' == 1) { //Change the local above to run or not to run 
       do "$dofiles\J_indiv_yoy.do"
   }

      /*ABOUT FILE ABOVE:
INPUTS:
Raw-data inputs:

Built-data inputs:
$Data_built\wide_build.dta
$Data_built\indiv_attrit_wide.dta
$Data_built\hh_attrit_wide.dta
$Data_built\Shock_Mat_SecComm_Sanc_5.dta
OUTPUTS:
Built-data outputs:
$Data_built\ind_attrit_FD.dta
Figures:
Tables:
*/
   
           if (`K_muni_yoy' == 1) { //Change the local above to run or not to run 
       do "$dofiles\K_muni_yoy.do"
   }
   
      /*ABOUT FILE ABOVE:
INPUTS:
Raw-data inputs:
Built-data inputs:
 $Data_built\ind_attrit_FD.dta
OUTPUTS:
Built-data outputs:
   Data_built\ENOE_myoyagg.dta
Figures:
Tables:
*/


****************************************************
*ANALYSIS
     if (`L_muni_yoy_graphs' == 1) { //Change the local above to run or not to run 
       do "$dofiles\L_muni_yoy_graphs.do"
   } //USES $Data_built\ENOE_myoyagg.dta
   
   
      if (`M_muni_yoy_reg' == 1) { //Change the local above to run or not to run 
       do "$dofiles\M_muni_yoy_reg.do"
   }  //USES $Data_built\ENOE_myoyagg.dta
   
       if (`N_muni_graphs' == 1) { //Change the local above to run or not to run 
       do "$dofiles\N_muni_graphs.do"
   }  //USES $Data_built\ENOE_muniagg_prog.dta
   
       if (`O_hh_indiv_yoy_graphs' == 1) { //Change the local above to run or not to run 
       do "$dofiles\O_hh_indiv_yoy_graphs.do"
   }  //USES $Data_built\ENOE_muniagg_prog.dta
   