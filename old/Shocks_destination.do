
cd "C:\Users\esthe\ownCloud\gehrke8\Data\Mexico\"

use Deportations_securecommunities.dta, clear

gen year=year(DepartedDate)
gen month = month(DepartedDate)
gen year_month=ym(year, month)
format year_month %tm

* drop those that are returned at the border




graph bar (count) year, over(year_month)
// on average deportations are lower since trump, trend increasing, but no marked jump after jan 2017...


** use this data to look at regional concentration of deportations??? 
