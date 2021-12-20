clear
import excel "C:\Users\esthe\ownCloud\gehrke8\Data\Mexico\BancoMex\BancoMex Monthly remittances by type of transfer 1995 - 2018.xlsx", sheet("Hoja1") firstrow

tsset Fecha
line RemesasFamiliaresTotal Fecha if Fecha> td(01jan2010)


