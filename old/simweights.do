*how should we think about the attrition corrected survey weights
*surveyy weights
clear all
set obs  10000
gen muni = mod(_n-1,10) + 1
sort muni
gen indiv=mod(_n-1,1000)+1
gen id=muni*100000+indiv

*treatment indicator
gen treat_muni=0
replace treat_muni=1 if inlist(muni,1,2,3,4,5)

*two types of individuals: Type 1 goes to school Type 0 works
gen type=1
replace type =0 if indiv>500

*suppose no effect on enrollment by treatment status
gen enroll=type


*only type 0 workers attrit (migrate)
* probability of attrition higher in untreated municipalities
gen attrit_treat= 0
gen attrit_untreat= rbinomial(1, 0.2)
gen attrit=attrit_treat
replace attrit=attrit_untreat if treat_muni==0
replace attrit=0 if type==1
drop attrit_treat attrit_untreat

*enrollment indicator that gives a value for attrited workers
gen act_enroll= enroll

*observed enrollment
replace enroll=. if attrit==1

*indicator for being observed
gen observed=(-1)*(attrit-1)
sort muni
by muni: egen muni_tot_obs=total(observed)
gen muni_attrit=1000-muni_tot_obs

*generating weights
*without attrition, each observation represents 100
gen weight=100

* generating corrected weights:
gen cor_weight= 100*(1000/muni_tot_obs)


*Note: true effect is that there is no effect on enrollment, just on attrition of the non-school types
reg act_enroll treat_muni [aw=weight]
reg enroll treat_muni
reg enroll treat_muni [aw=cor_weight]

reg enroll treat_muni muni_attrit
reg enroll treat_muni muni_attrit[aw=cor_weight]

reg attrit treat_muni
reg attrit treat_muni [aw=cor_weight]

*calculate muni level aggregated variables using weights
gen pop_build=cor_weight*observed
gen pop_enrolled_build=cor_weight*observed*enroll

by muni: egen pop=total(pop_build)
by muni: egen pop_enrolled=total(pop_enrolled_build)

by muni: egen pop_noweight=total(observed)
by muni: egen pop_enrolled_noweight=total(enroll)

keep muni treat_muni pop pop_enrolled pop_noweight pop_enrolled_noweight
duplicates drop 

*Note: true effect is that there is no effect on enrollment, just on attrition of the non-school types
*using the attrition corrected weights created bias?
reg  pop_enrolled treat_muni
reg  pop_enrolled_noweight treat_muni

*Note: true effect is that "present" population is lower in untreated municipality
*using the attrition corrected weights created bias?
reg  pop treat_muni
reg pop_noweight  treat_muni
STOP









**************************
*how should we think aboutm weighting sc_shock by migration share. 
clear all


set obs  10000

gen muni = mod(_n-1,10) + 1
sort muni
gen indiv=mod(_n-1,1000)+1

gen id=muni*100000+indiv

gen prob=.
replace prob=0.4 if muni==1
replace prob=0.2 if muni==2
replace prob=0.01 if muni==3
replace prob=0.3 if muni==4
replace prob=0.05 if muni==5
replace prob=0.25 if muni==6
replace prob=0.34 if muni==7
replace prob=0.15 if muni==8
replace prob=0.18 if muni==9
replace prob=0.31 if muni==10


gen migpost1=runiform() < prob


gen sc_treat=0.3

*sc_treat reduces the probability of migrating by (1-x)%
gen prob2=sc_treat*prob
gen migpost2=runiform() < prob2


reshape long migpost, i(id) j(time)

gen post=0
replace post=1 if time==2

reghdfe migpost post, a(muni)
*interpret directly as the decrease in the probability of migrating (and can then divide by constant to recover (1-x)% )


*with weights

gen weightedtreat=post*prob

*recovers (1-x)% directly
reghdfe migpost weightedtreat, a(muni)


*done at the aggregated municipality level:

sort muni time

by muni time: egen migrants=total(migpost)
gen obs=1
by muni time: egen population=total(obs)

keep muni post migrants population weightedtreat

reghdfe migrants post, a(muni)

gen ln_mig=log(migrants)
gen ln_pop=log(population)

reghdfe ln_mig post , a(muni)


reghdfe migrants weightedtreat, a(muni)


***

reghdfe migpost i.post##c.prob, a(mun)
margins, dydx(post) atmeans


gen mig_weighted = migpost/prob
reghdfe mig_weighted post, a(muni)

