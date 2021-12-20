#######################################################
# Creating one dataset of ENCO data
#
# esther gehrke, 10 December 2018
#######################################################
rm(list=ls())
library(foreign)
library(readstata13)
library(maxLik)
library(haven)
library(gtools)

setwd("C:/Users/esthe/ownCloud/gehrke8/Data/Mexico/ENOE/")


####
#unzip("enco_2001_2014_dbf.zip")
for (i in dir(pattern=".zip"))
  unzip(i)

options(stringsAsFactors=FALSE)

#ENCO CB
#2009
rm(list=ls())
df <- lapply(Sys.glob("encocb*09.dbf"), read.dbf, as.is = TRUE)
cb09 <- data.frame(do.call("rbind", df), stringsAsFactors = FALSE)
write_dta(cb09, "STATA/encocb2009.dta")
#2010
rm(list=ls())
df <- lapply(Sys.glob("encocb_*10.*"), read.dbf, as.is = TRUE)
cb10 <- do.call("rbind", df)
write_dta(cb10, "STATA/encocb2010.dta")
#2011
rm(list=ls())
df <- lapply(Sys.glob("encocb_*11.*"), read.dbf, as.is = TRUE)
cb11 <- do.call("rbind", df)
write_dta(cb11, "STATA/encocb2011.dta")
#2012
rm(list=ls())
df <- lapply(Sys.glob("encocb_*12.*"), read.dbf, as.is = TRUE)
cb12 <- do.call("rbind", df)
write_dta(cb12, "STATA/encocb2012.dta")
#2013
rm(list=ls())
df <- lapply(Sys.glob("encocb*13.*"), read.dbf, as.is = TRUE)
cb09 <- do.call("rbind", df)
write_dta(cb09, "STATA/encocb2013.dta")
#2014
rm(list=ls())
df <- lapply(Sys.glob("encocb*14.*"), read.dbf, as.is = TRUE)
cb09 <- do.call("rbind", df)
write_dta(cb09, "STATA/encocb2014.dta")
#2015
rm(list=ls())
df <- lapply(Sys.glob("encocb*15.*"), read.dbf, as.is = TRUE)
cb09 <- do.call("rbind", df)
write_dta(cb09, "STATA/encocb2015.dta")
#2016
rm(list=ls())
df <- lapply(Sys.glob("encocb*16.*"), read.dbf, as.is = TRUE)
cb09 <- do.call("rbind", df)
write_dta(cb09, "STATA/encocb2016.dta")
#2017
rm(list=ls())
df <- lapply(Sys.glob("encocb*17.*"), read.dbf, as.is = TRUE)
cb09 <- do.call("rbind", df)
write_dta(cb09, "STATA/encocb2017.dta")
#2018
rm(list=ls())
df <- lapply(Sys.glob("encocb*18.*"), read.dbf, as.is = TRUE)
cb09 <- do.call("rbind", df)
write_dta(cb09, "STATA/encocb2018.dta")

#ENCO CS
#2009
rm(list=ls())
df <- lapply(Sys.glob("encocs*09.dbf"), read.dbf, as.is = TRUE)
cb09 <- do.call("rbind", df)
write_dta(cb09, "STATA/encocs2009.dta")
#2010
rm(list=ls())
df <- lapply(Sys.glob("encocs_*10.*"), read.dbf, as.is = TRUE)
cb10 <- do.call("rbind", df)
write_dta(cb10, "STATA/encocs2010.dta")
#2011
rm(list=ls())
df <- lapply(Sys.glob("encocs_*11.*"), read.dbf, as.is = TRUE)
cb11 <- do.call("rbind", df)
write_dta(cb11, "STATA/encocs2011.dta")
#2012
rm(list=ls())
df <- lapply(Sys.glob("encocs_*12.*"), read.dbf, as.is = TRUE)
cb12 <- do.call("smartbind", df)
write_dta(cb12, "STATA/encocs2012.dta")
#2013
rm(list=ls())
df <- lapply(Sys.glob("encocs*13.*"), read.dbf, as.is = TRUE)
cb09 <- do.call("rbind", df)
write_dta(cb09, "STATA/encocs2013.dta")
#2014
rm(list=ls())
df <- lapply(Sys.glob("encocs*14.*"), read.dbf, as.is = TRUE)
cb09 <- do.call("rbind", df)
write_dta(cb09, "STATA/encocs2014.dta")
#2015
rm(list=ls())
df <- lapply(Sys.glob("encocs*15.*"), read.dbf, as.is = TRUE)
cb09 <- do.call("rbind", df)
write_dta(cb09, "STATA/encocs2015.dta")
#2016
rm(list=ls())
df <- lapply(Sys.glob("encocs*16.*"), read.dbf, as.is = TRUE)
cb09 <- do.call("rbind", df)
write_dta(cb09, "STATA/encocs2016.dta")
#2017
rm(list=ls())
df <- lapply(Sys.glob("encocs*17.*"), read.dbf, as.is = TRUE)
cb09 <- do.call("rbind", df)
write_dta(cb09, "STATA/encocs2017.dta")
#2018
rm(list=ls())
df <- lapply(Sys.glob("encocs*18.*"), read.dbf, as.is = TRUE)
cb09 <- do.call("rbind", df)
write_dta(cb09, "STATA/encocs2018.dta")

#ENCO VIV
#2009
rm(list=ls())
oct <- read.dbf("encoviv_1009.dbf", as.is = TRUE)
nov <- read.dbf("encoviv_1109.dbf", as.is = TRUE)
dec <- read.dbf("encoviv_1209.dbf", as.is = TRUE)
df <- lapply(Sys.glob("encoviv_0*09.dbf"), read.dbf, as.is = TRUE)
nov <- subset(nov, select = -c(DIASEM,HORA) )
dec <- subset(dec, select = -c(DIASEM,HORA) )
cb09 <- do.call("rbind", df)
md = rbind(cb09,oct,nov,dec,  stringsAsFactors = FALSE)
write_dta(md, "STATA/encoviv2009.dta")
#2010
rm(list=ls())
df <- lapply(Sys.glob("encoviv_*10.*"), read.dbf, as.is = TRUE)
cb10 <- do.call("rbind", df)
write_dta(cb10, "STATA/encoviv2010.dta")
#2011
rm(list=ls())
df <- lapply(Sys.glob("encoviv_*11.*"), read.dbf, as.is = TRUE)
cb11 <- do.call("rbind", df)
write_dta(cb11, "STATA/encoviv2011.dta")
#2012
rm(list=ls())
df <- lapply(Sys.glob("encoviv_*12.*"), read.dbf, as.is = TRUE)
cb12 <- do.call("rbind", df)
write_dta(cb12, "STATA/encoviv2012.dta")
#2013
rm(list=ls())
df <- lapply(Sys.glob("encoviv*13.*"), read.dbf, as.is = TRUE)
cb09 <- do.call("smartbind", df)
write_dta(cb09, "STATA/encoviv2013.dta")
#2014
rm(list=ls())
df <- lapply(Sys.glob("encoviv*14.*"), read.dbf, as.is = TRUE)
cb09 <- do.call("smartbind", df)
write_dta(cb09, "STATA/encoviv2014.dta")
#2015
rm(list=ls())
df <- lapply(Sys.glob("encoviv*15.*"), read.dbf, as.is = TRUE)
cb09 <- do.call("smartbind", df)
write_dta(cb09, "STATA/encoviv2015.dta")
#2016
rm(list=ls())
df <- lapply(Sys.glob("encoviv*16.*"), read.dbf, as.is = TRUE)
cb09 <- do.call("rbind", df)
write_dta(cb09, "STATA/encoviv2016.dta")
#2017
rm(list=ls())
df <- lapply(Sys.glob("encoviv*17.*"), read.dbf, as.is = TRUE)
cb09 <- do.call("rbind", df)
write_dta(cb09, "STATA/encoviv2017.dta")
#2018
rm(list=ls())
df <- lapply(Sys.glob("encoviv*18.*"), read.dbf, as.is = TRUE)
cb09 <- do.call("rbind", df)
write_dta(cb09, "STATA/encoviv2018.dta")