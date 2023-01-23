*Tenhle program slouží k provedení základní exploraèní analýzy dat o víceèetný pøíèinách smrti. Je složen z makra, pøed jehož 
 spuštením je tøeba definovat šablony výstupních souborù. Makro je uložené v knihovnì "Makra", pro spuštení tedy není potøeba jej
 znova nahrávat, pokud jeho obsah nebyl zmìnìn. Na konci programu jsou pøíkazy na export vytvoøených souborù.

Obsahem makra je:
1. Výstup: prùmìrné poèty zapisovaných pøíèin smrti podle vìku
2. Výstup: pozice UCD na hlášení o smrti (nejvyšší øádek/jiný)
3. Výstup: pøípady, kdy UCD je v èásti 1
4. a 5. Výstup: Vìková struktura podle poètu zapsaných pøíèin smrti a podíly osob podle poètu pøíèin smrti
6. Výstup: nejèastìji zapisované kódy podle èástí HOÚ (první bez UCD/ UCD/ druhá)
7. Výstup: PPK u jednotlivých UCD podle èástí hlášení (celkem  a druhá èást)
------------------------------------------------------------------------------------------------------------------------------------
____________________________________________________________________________________________________________________________________
-> vytvoøení grafických výstupù pro porovnání v èase -> DODÌLAT
-> ménì podrobných tabulek pro porovnání v èase -> DODÌLAT;



libname Nova "G:\Mùj disk\DP\zbytek\B\memory\sas výstupy";
libname Database "G:\Mùj disk\DP\zbytek\B\memory\sas data";
libname Makra "G:\Mùj disk\DP\zbytek\B\memory\sas makra";
options mstored sasmstore=Makra;
*______________________________________________________________________________________________________________________________________________
 VÝBÌR CÍLOVÉ POPULACE PODLE ZADANÝCH PARAMETRÙ + ZÁKLADNÍ OPERACE NA DATÁCH (PØESUNY, RECODY);

*Definuj dataframe pro PRVNÍ SPUŠTÌNÍ;
data PPK; * výstup 1;
length age_group $5. age_num 8 sex $1. 
PPK_celkem PPK_p1 PPK_p2 8 rok 4;
run;
data Pozice_ucd; * výstup 2;
length rok 4 sex $1. age_num 8 age_group $5. ucod_na_nejvyssim 8 Pozice_ucod 8;
run;
data Ucod_p1; * výstup 3;
length rok 4 sex $1. age_num 8 age_group $5. ucod_part_1 8 Ucod_p1 8;
run;
data VS_ppk; * výstup 4 a 5;
length rok 4 sex $1. age_num 8 age_group $5. celkem_pricin 8 Pocet_zemrelych 8;
run;
data Nejkody; *výstup 6;
length rok 4 sex $1. kod $3. Part_1 8 Freq_p1 8 Part_2 8 Freq_p2 8 UCD 8 Freq_ucd 8 Rank_p1 8 Rank_p2 8 Rank_ucd 8;
run;

data UCD_ppk; *výstup 7;
length rok 4 kapitola $1. ucod $3. sex $1. ucod_PPK 8 ucod_PPKp2 8 ucod_PPK_rank 8 ucod_PPKp2_rank 8; run;

%process(Mort_1969);
%process(Mort_1970);
%process(Mort_1971);
%process(Mort_1972);
%process(Mort_1973);
%process(Mort_1974);
%process(Mort_1975);
%process(Mort_1976);
%process(Mort_1977);
%process(Mort_1978);
%process(Mort_1979);
%process(Mort_1980);
%process(Mort_1981);
%process(Mort_1982);
%process(Mort_1983);
%process(Mort_1984);
%process(Mort_1985);
%process(Mort_1986);
%process(Mort_1987);
%process(Mort_1988);
%process(Mort_1989);
%process(Mort_1990);
%process(Mort_1991);
%process(Mort_1992);
%process(Mort_1993);
%process(Mort_1994);
%process(Mort_1995);
%process(Mort_1996);
%process(Mort_1997);
%process(Mort_1998);
%process(Mort_1999);
%process(Mort_2000);
%process(Mort_2001);
%process(Mort_2002);
%process(Mort_2003);
%process(Mort_2004);
%process(Mort_2005);
%process(Mort_2006);
%process(Mort_2007);
%process(Mort_2008);
%process(Mort_2009);
%process(Mort_2010);
%process(Mort_2011);
%process(Mort_2012);
%process(Mort_2013);
%process(Mort_2014);
%process(Mort_2015);
%process(Mort_2016);
%process(Mort_2017);
%process(Mort_2018);
%process(Mort_2019);


%process(Mort_2020); %process(Mort_1970); %process(Mort_1975); %process(Mort_1980); %process(Mort_1985); %process(Mort_1990);
%process(Mort_1995); %process(Mort_2000); %process(Mort_2010); %process(Mort_2005); %process(Mort_2015);

%macro process(rok) /store source des="Macro for basic explanatory analysis of MCD";
%LET od=0; %LET do=101; *Zadej vìkové rozmezí od–do (min=0, max=100)

*Pøesun datasetu mezi libraries (nemùžeš rovnou z webu? -> vyøeš to);
data &rok;
set Database.&rok; run;

*Pøepis vìku (rùznými zpùsoby pro dvì období 1980-2002 a 2003-2019) -> na NBER jsou data už od 1960 -> zajímá tì to?;
data &rok;
set &rok;
if datayear<100 or year<=2002 then do; *pro 1980-2002;
	if age<100 then age_want=age;
	if age>=100 and age<200 then age_want=100;
	if age>=200 then age_want=0;
	if age=999 then age_want=.; end;
if datayear>=100 or year>2002 then do; *pro 2003-2019;
	x= put(age, 4.);
	age_want = input(substr(x,2,3),4.);
	if age>1135 then age_want=0;
	if age=>1100 and age<=1135 then age_want=100;
	if age=999 then age_want=.;
	drop x; end;
run;

*V starších souborech tvoøíš novou písmenkovou promìnnou sex místo numerické;
data &rok;
length sex_recode $1.;
set &rok;
if datayear<100 or year<=2002 then do;
	if sex=1 then sex_recode="M";
	if sex=2 then sex_recode="F";
if datayear>=100 or year>2002 then do;
	sex_recode=sex; end;
drop sex; end;
run;
data &rok; length sex $1.; set &rok; sex=sex_recode; drop sex_recode; run;

*Nová promìnná se ètyømístným rokem;
data &rok;
length rok 4.;
set &rok;
rok=substr("&rok", 6, 4);
run;

*Selekce zadaného vìku;
data &rok;
set &rok;
where age_want>=&od and age_want<&do; run;
*Pøepisuješ kody na tøechmístný;
data &rok; 
length enicon_1-enicon_20 ucod $3.;
set &rok; run;

data &rok;
length age_group $5.;
set &rok;
if age_want=0 then do; age_group="0"; age_num=0; end;
if age_want>0 and age_want<5 then do; age_group="1-4"; age_num=1; end;
if age_want>=5 and age_want<10 then do; age_group="5-9" ;age_num=5; end;
if age_want>=10 and age_want<15 then do; age_group="10-14" ; age_num=10;end;
if age_want>=15 and age_want<20 then do; age_group="15-19" ; age_num=15;end;
if age_want>=20 and age_want<25 then do; age_group="20-24" ; age_num=20;end;
if age_want>=25 and age_want<30 then do; age_group="25-29" ; age_num=25;end;
if age_want>=30 and age_want<35 then do; age_group="30-34" ; age_num=30;end;
if age_want>=35 and age_want<40 then do; age_group="35-39" ; age_num=35;end;
if age_want>=40 and age_want<45 then do; age_group="40-44" ; age_num=40;end;
if age_want>=45 and age_want<50 then do; age_group="45-49" ; age_num=45;end;
if age_want>=50 and age_want<55 then do; age_group="50-54" ; age_num=50;end;
if age_want>=55 and age_want<60 then do; age_group="55-59" ; age_num=55;end;
if age_want>=60 and age_want<65 then do; age_group="60-64" ; age_num=60;end;
if age_want>=65 and age_want<70 then do; age_group="65-69" ; age_num=65;end;
if age_want>=70 and age_want<75 then do; age_group="70-74" ; age_num=70;end;
if age_want>=75 and age_want<80 then do; age_group="75-79" ; age_num=75;end;
if age_want>=80 and age_want<85 then do; age_group="80-84" ; age_num=80;end;
if age_want>=85 and age_want<90 then do; age_group="85-89" ; age_num=85;end;
if age_want>=90 and age_want<95 then do; age_group="90-94" ; age_num=90;end;
if age_want>=95 and age_want<100 then do; age_group="95-99" ; age_num=95;end;
if age_want>=100 then do; age_group="100+" ; age_num=100; end;
if age_want=. then do; age_group="NA"; age_num=.; end;
run;
*______________________________________________________________________________________________________
* 1. Výstup 1 (viz lejstro)
_______________________________________________________________________________________________________;

* Najdi záznamy, kde ucod není v Part1;
data Mort;
set &rok;
array as enicon_1-enicon_20;
if ucod in as then do;
	ucod_part_1=1; end;
	else ucod_part_1=0;
run;
* Když v Part1 není, tak ji tam zapiš na "novou" pozici, když tam je, nedìlej nic.;
data Mort;
length enicon_21 $3. econdp_21 3;
set Mort;
if ucod_part_1=0 then do;
	enicon_21=ucod;
	econdp_21=21; end;
else do;
	enicon_21="";
	econdp_21=.; end;
run;
* Nalezni pøíèinu na nejvyšším øádku nepoèítaje pøíèiny z Part2 (když všechny v Part2, potom missing);
%if %substr(&rok, 6, 4)>1978 %then %do;
data Mort_try;
set Mort;
array as econdp_1-econdp_20;
array bs xecondp_1-xecondp_20;
do i=1 to dim(as);
if max( of as[i])<=5 then bs[i]=as[i];
else bs[i]=.; end;
run;
data Mort;
set Mort_try;
array as xecondp_1-xecondp_20;
nejvyssi_radek=max( of as[*]);
drop xecondp_1--xecondp_20;
run;
%end;
%if %substr(&rok, 6, 4)<=1978 %then %do;
data Mort_try;
set Mort;
array as econdp_1-econdp_20;
array bs xecondp_1-xecondp_20;
do i=1 to dim(as);
if max( of as[i])<=4 then bs[i]=as[i];
else bs[i]=.; end;
run;
data Mort;
set Mort_try;
array as xecondp_1-xecondp_20;
nejvyssi_radek=max( of as[*]);
drop xecondp_1--xecondp_20;
run;
%end;

* Zapiš do nové promìnné tu pøíèinu co byla na nejvyšším øádku a vytvoø binární promìnnou 1/0 podle toho, jestli se
  pøíèina na nejvyšším øádku shoduje s ucod;
data Mort;
set Mort;
array as enicon_1-enicon_20;
array bs econdp_1-econdp_20;
do i=1 to dim (bs);
if bs[i]=nejvyssi_radek then do;
pricina_na_nejvyssim=(as[i]); end; end;
if pricina_na_nejvyssim=ucod then do; ucod_na_nejvyssim=1; end;
if pricina_na_nejvyssim~=ucod then do; ucod_na_nejvyssim=0; end ; run;		
* Spoèítej celkový poèet pøíèin smrti (vèetnì ucd, i když v Part1 nebyla);
data Mort;
 set Mort;
 	totmiss=cmiss(of enicon_1-enicon_21);
 	celkem_pricin=21- cmiss(of enicon_1-enicon_21);
run;

*Rozdíl mezi eanum (Number of EAC oficiální) a celkem_pricin;
data Mort;
set Mort;
rozdil_EAC=eanum-celkem_pricin; run;
proc means data=Mort min max mean; var rozdil_EAC; run; 
proc freq data=Mort; table rozdil_EAC*ucod_part_1; run; * V tìch datách jsou chyby?;
* Dopoèítej celkový poèet pøíèin smrti v každé z èástí hlášení zvláš;
%if %substr(&rok, 6, 4)>1978 %then %do;
data Mort_try;
set Mort;
array as econdp_1-econdp_20;
array bs p1enicon_1-p1enicon_20;
array cs p2enicon_1-p2enicon_20;
do i=1 to dim(as);
	if as[i]<6 then bs[i]=as[i];
	if as[i]>=6 then cs[i]=as[i];
end; run;
data Mort;
set Mort_try;	 	
	totmiss_p1=cmiss(of p1enicon_1-p1enicon_20); 
 	celkem_pricin_p1=20- cmiss(of p1enicon_1-p1enicon_20);
	totmiss_p2=cmiss(of p2enicon_1-p2enicon_20); 
 	celkem_pricin_p2=20- cmiss(of p2enicon_1-p2enicon_20);
drop p1enicon: p2enicon:;
run;
%end;
%if %substr(&rok, 6, 4)<=1978 %then %do;
data Mort_try;
set Mort;
array as econdp_1-econdp_20;
array bs p1enicon_1-p1enicon_20;
array cs p2enicon_1-p2enicon_20;
do i=1 to dim(as);
	if as[i]<5 then bs[i]=as[i];
	if as[i]>=5 then cs[i]=as[i];
end; run;
data Mort;
set Mort_try;	 	
	totmiss_p1=cmiss(of p1enicon_1-p1enicon_20); 
 	celkem_pricin_p1=20- cmiss(of p1enicon_1-p1enicon_20);
	totmiss_p2=cmiss(of p2enicon_1-p2enicon_20); 
 	celkem_pricin_p2=20- cmiss(of p2enicon_1-p2enicon_20);
drop p1enicon: p2enicon:;
run;
%end;

* Kontrola - > celkem pøíèin a souèet podle èásti se liší pouze v pøípadech, kdy ucod není v part1;
data Mort; set Mort;
rozdil_celkem_pricin=celkem_pricin-(celkem_pricin_p1+celkem_pricin_p2); run;
proc freq data=Mort; table rozdil_celkem_pricin*ucod_part_1; run;

* Prùmìrné poèty kódù podle èástí hlášení a podle vìku;
proc sort data=Mort; by sex age_num age_group; run;
proc sql;
create table Mort_ppk as
select *, avg(celkem_pricin) as PPK_celkem, avg(celkem_pricin_p1) as PPK_p1, avg(celkem_pricin_p2) as PPK_p2
from Mort
group by sex, age_num, age_group
order by sex, age_num, age_group;
quit;

data PPK; * Do souboru PPK mùže pøidávat data za jednotlivé roky;
set Mort_ppk PPK;
keep  age_num age_group sex PPK_celkem PPK_p1 PPK_p2 rok; run;
proc sort data=PPK nodup; by rok sex age_num ; run;

*______________________________________________________________________________________________________
* 2. Výstup 2 (viz lejstro)
_______________________________________________________________________________________________________;
proc sql;
create table Mort_pozice_ucd as
select rok, sex, age_num, age_group, ucod_na_nejvyssim, count(ucod_na_nejvyssim) as Pozice_ucod
from Mort
group by rok, sex, ucod_na_nejvyssim, age_num, age_group;
quit;
proc freq data=Mort_pozice_ucd; table sex*ucod_na_nejvyssim; weight Pozice_ucod; run;

data Pozice_ucd; * Do souboru Pozice_ucd mùžeš pøidávat data za jednotlivé roky;
set Mort_pozice_ucd Pozice_ucd;
run;

*______________________________________________________________________________________________________
* 3. Výstup 3 (viz lejstro)
_______________________________________________________________________________________________________;
proc sql;
create table Mort_ucd_p1 as
select rok, sex, age_num, age_group, ucod_part_1, count(ucod_part_1) as Ucod_p1
from Mort
group by rok, sex, ucod_part_1, age_num, age_group;
quit;
proc freq data=Mort_ucd_p1; table sex*ucod_part_1; weight Ucod_p1; run;

data Ucod_p1; * Do souboru Ucd_p1 mùžeš pøidávat data za jednotlivé roky;
set Mort_ucd_p1 Ucod_p1;
run;

*______________________________________________________________________________________________________
* 4. Výstup 4+5 (viz lejstro)
_______________________________________________________________________________________________________;
proc sql;
create table Mort_VS_ppk as
select rok, sex, age_num, age_group, celkem_pricin, count(celkem_pricin) as Pocet_zemrelych
from Mort
group by rok, sex, celkem_pricin, age_num, age_group;
quit;
proc freq data=Mort_VS_ppk; by sex; table celkem_pricin; weight Pocet_zemrelych; run;

data VS_ppk; * Do souboru VS_ppk mùžeš pøidávat data za jednotlivé roky;
set Mort_VS_ppk VS_ppk;
run;
*____________________________________________________________________________________________________________________
* 5. Výstup 6 (viz lejstro);
*____________________________________________________________________________________________________________________
* Jaké jsou nejèastìjší pøíèiny v Part I nepoèítaje UCD?;
%if %substr(&rok, 6, 4)>1978 %then %do;
data Nejkody_p1_1;
set Mort;
id=_n_;
array as enicon_1-enicon_21;
array bs econdp_1-econdp_21;
do i=1 to dim(as);
if as[i]=ucod then as[i]=""; else as[i]=as[i];
if bs[i]=6 then as[i]=""; else as[i]=as[i]; end;
run;
proc sort data=Nejkody_p1_1; by ID sex age_num rok; run;
proc transpose data=Nejkody_p1_1 out=Nejkody_p1_2 name=Part_1;
by ID sex age_num rok; var enicon_:;
run;
*Frekvenèní tabulky na poèet kódù v P1 (lze podle rùzných atributù -> pohlaví a vìk);
*proc freq data=Nejkody_p1_2 noprint; *by sex age_num rok; *table col1/norow nocol nopercent out=Nejkody_p1_3; *run;
proc freq data=Nejkody_p1_2 noprint; by sex rok; table col1/norow nocol nopercent out=Nejkody_p1_4; run;

* Jaké jsou nejèastìjší pøíèiny v Part II nepoèítaje UCD?;
data Nejkody_p2_1;
set Mort;
id=_n_;
array as enicon_1-enicon_21;
array bs econdp_1-econdp_21;
do i=1 to dim(as);
if bs[i]<6 then as[i]=""; else as[i]=as[i]; end;
run;
proc sort data=Nejkody_p2_1; by ID sex age_num rok; run;
proc transpose data=Nejkody_p2_1 out=Nejkody_p2_2 name=Part_II;
by ID sex age_num rok; var enicon_:;
run;
*Frekvenèní tabulky na poèet kódù v P2 (lze podle rùzných atributù -> pohlaví a vìk);
*proc freq data=Nejkody_p2_2 noprint; *by sex age_num rok; *table col1/norow nocol nopercent out=Nejkody_p2_3; *run;
proc freq data=Nejkody_p2_2 noprint; by sex rok; table col1/norow nocol nopercent out=Nejkody_p2_4; run;

* Jaké jsou nejèastìjší pøíèiny v UCOD?;
*proc freq data=Mort noprint; *by sex age_num rok; *table ucod/norow nocol nopercent out=Nejkody_ucd_3; *run;
proc freq data=Mort noprint; by sex rok; table ucod /norow nocol nopercent out=Nejkody_ucd_4; run;
%end;
%if %substr(&rok, 6, 4)<=1978 %then %do;
data Nejkody_p1_1;
set Mort;
id=_n_;
array as enicon_1-enicon_21;
array bs econdp_1-econdp_21;
do i=1 to dim(as);
if as[i]=ucod then as[i]=""; else as[i]=as[i];
if bs[i]=5 then as[i]=""; else as[i]=as[i]; end;
run;
proc sort data=Nejkody_p1_1; by ID sex age_num rok; run;
proc transpose data=Nejkody_p1_1 out=Nejkody_p1_2 name=Part_1;
by ID sex age_num rok; var enicon_:;
run;
*Frekvenèní tabulky na poèet kódù v P1 (lze podle rùzných atributù -> pohlaví a vìk);
*proc freq data=Nejkody_p1_2 noprint; *by sex age_num rok; *table col1/norow nocol nopercent out=Nejkody_p1_3; *run;
proc freq data=Nejkody_p1_2 noprint; by sex rok; table col1/norow nocol nopercent out=Nejkody_p1_4; run;

* Jaké jsou nejèastìjší pøíèiny v Part II nepoèítaje UCD?;
data Nejkody_p2_1;
set Mort;
id=_n_;
array as enicon_1-enicon_21;
array bs econdp_1-econdp_21;
do i=1 to dim(as);
if bs[i]<5 then as[i]=""; else as[i]=as[i]; end;
run;
proc sort data=Nejkody_p2_1; by ID sex age_num rok; run;
proc transpose data=Nejkody_p2_1 out=Nejkody_p2_2 name=Part_II;
by ID sex age_num rok; var enicon_:;
run;
*Frekvenèní tabulky na poèet kódù v P2 (lze podle rùzných atributù -> pohlaví a vìk);
*proc freq data=Nejkody_p2_2 noprint; *by sex age_num rok; *table col1/norow nocol nopercent out=Nejkody_p2_3; *run;
proc freq data=Nejkody_p2_2 noprint; by sex rok; table col1/norow nocol nopercent out=Nejkody_p2_4; run;

* Jaké jsou nejèastìjší pøíèiny v UCOD?;
*proc freq data=Mort noprint; *by sex age_num rok; *table ucod/norow nocol nopercent out=Nejkody_ucd_3; *run;
proc freq data=Mort noprint; by sex rok; table ucod /norow nocol nopercent out=Nejkody_ucd_4; run;
%end;
*Kompilace všech souborù s nejèastìjšíma kódama (jenom atribut pohlaví);
proc sort data=Nejkody_p1_4; by sex col1 rok; run;
proc sort data=Nejkody_p2_4; by sex col1 rok; run;
proc sort data=Nejkody_ucd_4; by sex ucod rok; run;
data Nejkody1;
merge Nejkody_p1_4 (rename=(col1=kod count=Part_1 percent=Freq_p1))
	  Nejkody_p2_4 (rename=(col1=kod count=Part_2 percent=Freq_p2))
	  Nejkody_ucd_4 (rename=(ucod=kod count=UCD percent=Freq_ucd));
by sex kod rok; run;
data Nejkody1; set Nejkody1; if kod~=""; run;
proc sort data=Nejkody1; by sex kod; run;
proc rank data=Nejkody1 descending out=Nejkody2;
by sex;
var Part_1 Part_2 UCD;
ranks Rank_p1 Rank_p2 Rank_ucd; run;

data Nejkody; * Do souboru Nejkody mùžeš pøidávat data za jednotlivé roky;
set Nejkody2 Nejkody; run;

* ______________________________________________________________________________________________________
* 6. Výstup 7
* ______________________________________________________________________________________________________;
*UCD dle PPK celkem a dle UCD dle PPK jenom z pøispívajících pøíèin smrti;
proc sql;
create table UCOD_dle_PPK1 as
select *, count(ucod) as pocet_ucod from Mort group by sex, ucod;
create table UCOD_dle_PPK2 as
select *, sum(pocet_ucod*celkem_pricin)/sum(pocet_ucod) as ucod_PPK from UCOD_dle_PPK1 group by sex, ucod;
create table UCOD_dle_PPK3 as
select *, sum(pocet_ucod*celkem_pricin_p2)/sum(pocet_ucod) as ucod_PPKp2 from UCOD_dle_PPK2 group by sex, ucod;
quit;
data PPK_ucd_v7;
length kapitola $1.;
set UCOD_dle_PPK3;
kapitola=substr(ucod, 1, 1);
keep rok sex ucod_PPK ucod_PPKp2 ucod kapitola; run;
proc sort data=PPK_ucd_v7 nodupkey; by sex ucod; run;
proc rank data=PPK_ucd_v7 descending out=PPK_rank;
by sex;
var ucod_PPK ucod_PPKp2;
ranks ucod_PPK_rank ucod_PPKp2_rank; run;

data UCD_ppk;
set PPK_rank UCD_ppk; run;

%mend process;


*Exporty;
PROC EXPORT DATA= Nova.Pozice_ucd
            OUTFILE= "G:\Mùj disk\DP\Pozice_ucd_1969-2018.xlsx" 
            DBMS=EXCEL REPLACE;
     SHEET="Pozice_ucd_1969-2018"; 
RUN;

PROC EXPORT DATA= Nova.Ppk 
            OUTFILE= "G:\Mùj disk\DP\PPK_1969-2018.xlsx" 
            DBMS=EXCEL REPLACE;
     SHEET="PPK_1969-2018"; 
RUN;

PROC EXPORT DATA= Nova.Ucod_p1
            OUTFILE= "G:\Mùj disk\DP\Ucod_p1_1969-2018.xlsx" 
            DBMS=EXCEL REPLACE;
     SHEET="Ucod_p1_1969-2018"; 
RUN;

PROC EXPORT DATA= Nova.VS_ppk
            OUTFILE= "G:\Mùj disk\DP\VS_ppk_1969-2018.xlsx" 
            DBMS=EXCEL REPLACE;
     SHEET="VS_ppk_1969-2018"; 
RUN;

PROC EXPORT DATA= Nejkody
            OUTFILE= "G:\Mùj disk\DP\Nejkody.xlsx" 
            DBMS=EXCEL REPLACE;
     SHEET="Nejkody"; 
RUN;

PROC EXPORT DATA= PPK
            OUTFILE= "G:\Mùj disk\DP\PPK.xlsx" 
            DBMS=EXCEL REPLACE;
     SHEET="PPK"; 
RUN;

*______________________________________________________________________________________________________________________
 GRAFICKÉ VÝSTUPY;

proc sql;
create table Pozice_UCD_v as
select rok, sex, ucod_na_nejvyssim, sum(Pozice_ucod) as Pocet
from Pozice_ucd
group rok, sex, ucod_na_nejvyssim; quit;
proc sort data=Pozice_UCD_v nodupkey; by rok sex ucod_na_nejvyssim; run;

proc format;
value $sex F="Ženy"
		   M="Muži";
value  ucod_na_nejvyssim 0="UCD není na nejvyšším"
						 1="UCD je na nejvyšším";
run;
ods excel file="G:\Mùj disk\DP\zbytek\B\memory\sas výstupy\MCD_expl_an.xlsx" options(sheet_name="VS_podle_pricin_smrti" sheet_interval="none");
proc tabulate data=Pozice_ucd_v;
title "Je UCD na nejvyšším øádku?";
format sex $sex. ucod_na_nejvyssim ucod_na_nejvyssim.;
where rok ne . and sex="F";
freq Pocet;
class rok sex ucod_na_nejvyssim pocet;
table rok="Rok"*ucod_na_nejvyssim="Pozice UCD", Pocet; 
run;
ods excel close;


proc tabulate data=Pozice_ucd;
var rok ucod_na_nejvyssim; 
table rok, count(ucod_na_nejvyssim; run;



data Nova.Vs_ppk_1970_2020; set Vs_ppk; run;
data Nova.UCD_p1_1970_2020; set Ucod_p1; run;
data Nova.UCD_ppk_1970_2020; set Ucd_ppk; run;
data Nova.Pozice_ucd_1970_2020; set Pozice_ucd; run;
data Nova.Nejkody_1970_2020; set Nejkody; run;


proc freq data=Nova.Ucd_ppk_1970_2020; table rok*sex; run;
proc freq data=Nova.Vs_ppk_1970_2020; table rok*sex; run;
proc freq data=Nova.Ucod_p1_1970_2020; table rok*sex; run;
proc freq data=Nova.PPK_1970_2020; table rok*sex; run;
proc freq data=Nova.Pozice_ucd_1970_2020; table rok*sex; run;
proc freq data=Nova.Nejkody_1970_2020; table rok*sex; run;

data Nova.Nejkody_1970_2020;
set Makra.Nejkody Nejkody; run;

data Nova.Pozice_ucd_1970_2020;
set Makra.Pozice_ucd Pozice_ucd; run;

data Nova.PPK_1970_2020;
set Makra.PPK PPK; run;

data Nova.Ucd_ppk_1970_2020;
set Makra.Ucd_ppk Ucd_ppk; run;

data Nova.Ucod_p1_1970_2020;
set Makra.Ucod_p1 Ucod_p1; run;

data Nova.Vs_ppk_1970_2020;
set Makra.Vs_ppk Vs_ppk; run;

data Nova.Z_ICD9_doICD10;
set TMP1.icd9toicd10cmgem; run;

*Perform VLOOKUP in sas na pøekódování promìnných z ICD9 na ekvivalenty z ICD10.;
%pokus(Mort_1982, 20);

%macro pokus(rok, number);
data &rok;
set Database.&rok;
id=_n_; run;

%do i=1 %to &number;
data See;
set &rok;
enic_1a0=substr(entity&i, 3, 5);
enic_1b0=substr(entity&i, 3, 4);
enic_1c0 = enic_1a0||"0";
enic_1a=compress(enic_1a0);
enic_1b=compress(enic_1b0);
enic_1c=compress(enic_1c0);
enic_1d0=enic_1b||"1";
enic_1d=compress(enic_1d0);
enic_1e0="0"||enic_1b;
enic_1e=compress(enic_1e0);
enic_1fE="E"||enic_1b;
enic_1f=compress(enic_1fE);
enic_1gV="V"||enic_1b;
enic_1g=compress(enic_1gV);
run;

proc sql;
    create table result1 as
    select a.*,
           b.icd10cm
    from See a
    left join Nova.Z_icd9_doicd10 b on a.enicon_&i = b.icd9cm;
quit;
proc sql;
    create table result2 as
    select a.*,
           b.icd10cm
    from See a
    left join Nova.Z_icd9_doicd10 b on a.enic_1a = b.icd9cm;
quit;
proc sql;
    create table result3 as
    select a.*,
           b.icd10cm
    from See a
    left join Nova.Z_icd9_doicd10 b on a.enic_1b = b.icd9cm;
quit;
proc sql;
    create table result4 as
    select a.*,
           b.icd10cm
    from See a
    left join Nova.Z_icd9_doicd10 b on a.enic_1c = b.icd9cm;
quit;

proc sql;
    create table result5 as
    select a.*,
           b.icd10cm
    from See a
    left join Nova.Z_icd9_doicd10 b on a.enic_1d = b.icd9cm;
quit;
proc sql;
    create table result6 as
    select a.*,
           b.icd10cm
    from See a
    left join Nova.Z_icd9_doicd10 b on a.enic_1e = b.icd9cm;
quit;
proc sql;
    create table result7 as
    select a.*,
           b.icd10cm
    from See a
    left join Nova.Z_icd9_doicd10 b on a.enic_1f = b.icd9cm;
quit;
proc sql;
    create table result8 as
    select a.*,
           b.icd10cm
    from See a
    left join Nova.Z_icd9_doicd10 b on a.enic_1g = b.icd9cm;
quit;

proc sort data=Result1; by id; run;
proc sort data=Result2; by id; run;
proc sort data=Result3; by id; run;
proc sort data=Result4; by id; run;
proc sort data=Result5; by id; run;
proc sort data=Result6; by id; run;
proc sort data=Result7; by id; run;
proc sort data=Result8; by id; run;

data Vyledek;
merge Result1
	  Result2 (keep=icd10cm id rename=(icd10cm=icd10cm1))
	  Result3 (keep=icd10cm id rename=(icd10cm=icd10cm2))
	  Result4 (keep=icd10cm id rename=(icd10cm=icd10cm3))
	  Result5 (keep=icd10cm id rename=(icd10cm=icd10cm4))
	  Result6 (keep=icd10cm id rename=(icd10cm=icd10cm5))
	  Result7 (keep=icd10cm id rename=(icd10cm=icd10cm6))
	  Result8 (keep=icd10cm id rename=(icd10cm=icd10cm7));
by id; run;

data Vysledek;
set Vyledek;
if icd10cm~="" then do; renicon_1=icd10cm; end;
	else if icd10cm="" and icd10cm1~="" then do; renicon_1=icd10cm1; end;
		else if icd10cm1="" and icd10cm2~="" then do; renicon_1=icd10cm2; end;
			else if icd10cm2="" and icd10cm3~="" then do; renicon_1=icd10cm3; end;
				else if icd10cm3="" and icd10cm4~="" then do; renicon_1=icd10cm4; end;
					else if icd10cm4="" and icd10cm5~="" then do; renicon_1=icd10cm5; end;
						else if icd10cm5="" and icd10cm6~="" then do; renicon_1=icd10cm6; end;
							else if icd10cm6="" and icd10cm7~="" then do; renicon_1=icd10cm7; end;
								else if icd10cm="" then do; renicon_1=""; end;
									else do; renicon_1="XXX"; end;
run;

data Vysledek&i;
set Vysledek;
renicon&i=renicon_1;
drop enic_1a0 enic_1b0 enic_1c0 enic_1d0 enic_1e0
	 enic_1a enic_1b enic_1c enic_1d enic_1e
	 enic_1fE enic_1f
	 enic_1gV enic_1g
	 icd10cm: renicon_1;
run;
proc sort data=Vysledek&i; by id ; run;
data &rok;
merge &rok
	  Vysledek&i (keep=renicon&i id); 
by id ;run;
proc sort data=&rok out=Vysledek_final nodupkey; by id; run;
%end;
%mend pokus;

*V tomto stavu ti to ukládá do rùzných sešitù a v každém máš promìnnou renicon pro jiný enicon. 
ID je stejný -> staèí v konci makra, po stamementu %end mergenout podle id?
+ je potøeba odlišit nenapárované a nevyplnìné, zejména u vyšších reniconù.;

data Missingy;
set Vyledek; 
if icd10cm="" and icd10cm1="" and icd10cm2="" and icd10cm3="" and icd10cm4="" and icd10cm5="" and icd10cm6="" and icd10cm7="";
run;

data See;
set Nova.Z_icd9_doicd10;
icd9cm10=icd9cm||"0";
icd9cm10=icd9cm||"00";
icd9cm20=icd9cm||"1";
icd9cm30="E"||icd9cm;
icd9cm40="V"||icd9cm;
if icd9cm=:"0" then do; icd9cm50=substr(icd9cm, 2); end;
if icd9cm=:"00" then do; icd9cm60=substr(icd9cm, 3); end;
icd9cm1=compress(icd9cm10);
icd9cm2=compress(icd9cm20);
icd9cm3=compress(icd9cm30);
icd9cm4=compress(icd9cm40);
icd9cm5=compress(icd9cm50);
icd9cm6=compress(icd9cm60);
run;
proc sql;
    create table result1 as
    select a.*,
           b.icd10cm as kod
    from See a
    left join Database.Mort_1982 b on a.enicon_1 = b.icd9cm and a.enicon_1 = b.icd9cm1;
quit;







data See;
set Database.Mort_1982;
enic_1a0=substr(entity1, 3, 5);
enic_1b0=substr(entity1, 3, 4);
enic_1c0 = enic_1a0||"0";
enic_1a=compress(enic_1a0);
enic_1b=compress(enic_1b0);
enic_1c=compress(enic_1c0);
enic_1d0=enic_1b||"1";
enic_1d=compress(enic_1d0);
enic_1e0="0"||enic_1b;
enic_1e=compress(enic_1e0);
enic_1fE="E"||enic_1b;
enic_1f=compress(enic_1fE);
enic_1gV="V"||enic_1b;
enic_1g=compress(enic_1gV);
run;

proc sql;
    create table result1 as
    select a.*,
           b.icd10cm
    from See a
    left join Nova.Z_icd9_doicd10 b on a.enicon_1 = b.icd9cm and a.enic_1a = b.icd9cm;
quit;
proc sql;
    create table result2 as
    select a.*,
           b.icd10cm
    from See a
    left join Nova.Z_icd9_doicd10 b on a.enic_1a = b.icd9cm;
quit;
proc sql;
    create table result3 as
    select a.*,
           b.icd10cm
    from See a
    left join Nova.Z_icd9_doicd10 b on a.enic_1b = b.icd9cm;
quit;
proc sql;
    create table result4 as
    select a.*,
           b.icd10cm
    from See a
    left join Nova.Z_icd9_doicd10 b on a.enic_1c = b.icd9cm;
quit;

proc sql;
    create table result5 as
    select a.*,
           b.icd10cm
    from See a
    left join Nova.Z_icd9_doicd10 b on a.enic_1d = b.icd9cm;
quit;
proc sql;
    create table result6 as
    select a.*,
           b.icd10cm
    from See a
    left join Nova.Z_icd9_doicd10 b on a.enic_1e = b.icd9cm;
quit;
proc sql;
    create table result7 as
    select a.*,
           b.icd10cm
    from See a
    left join Nova.Z_icd9_doicd10 b on a.enic_1f = b.icd9cm;
quit;
proc sql;
    create table result8 as
    select a.*,
           b.icd10cm
    from See a
    left join Nova.Z_icd9_doicd10 b on a.enic_1g = b.icd9cm;
quit;

proc sort data=Result1; by id; run;
proc sort data=Result2; by id; run;
proc sort data=Result3; by id; run;
proc sort data=Result4; by id; run;
proc sort data=Result5; by id; run;
proc sort data=Result6; by id; run;
proc sort data=Result7; by id; run;
proc sort data=Result8; by id; run;

data Vyledek;
merge Result1
	  Result2 (keep=icd10cm id rename=(icd10cm=icd10cm1))
	  Result3 (keep=icd10cm id rename=(icd10cm=icd10cm2))
	  Result4 (keep=icd10cm id rename=(icd10cm=icd10cm3))
	  Result5 (keep=icd10cm id rename=(icd10cm=icd10cm4))
	  Result6 (keep=icd10cm id rename=(icd10cm=icd10cm5))
	  Result7 (keep=icd10cm id rename=(icd10cm=icd10cm6))
	  Result8 (keep=icd10cm id rename=(icd10cm=icd10cm7));
by id; run;

data Vysledek;
set Vyledek;
if icd10cm~="" then do; renicon_1=icd10cm; end;
	else if icd10cm="" and icd10cm1~="" then do; renicon_1=icd10cm1; end;
		else if icd10cm1="" and icd10cm2~="" then do; renicon_1=icd10cm2; end;
			else if icd10cm2="" and icd10cm3~="" then do; renicon_1=icd10cm3; end;
				else if icd10cm3="" and icd10cm4~="" then do; renicon_1=icd10cm4; end;
					else if icd10cm4="" and icd10cm5~="" then do; renicon_1=icd10cm5; end;
						else if icd10cm5="" and icd10cm6~="" then do; renicon_1=icd10cm6; end;
							else if icd10cm6="" and icd10cm7~="" then do; renicon_1=icd10cm7; end;
								else if icd10cm="" then do; renicon_1=""; end;
									else do; renicon_1="XXX"; end;
run;

data Vysledek&i;
set Vysledek;
renicon&i=renicon_1;
drop enic_1a0 enic_1b0 enic_1c0 enic_1d0 enic_1e0
	 enic_1a enic_1b enic_1c enic_1d enic_1e
	 enic_1fE enic_1f
	 enic_1gV enic_1g
	 icd10cm: renicon_1;
run;
proc sort data=Vysledek&i; by id ; run;
data &rok;
merge &rok
	  Vysledek&i (keep=renicon&i id); 
by id ;run;
proc sort data=&rok out=Vysledek_final nodupkey; by id; run;





*________________________________________________________________________________________________;
data Mort_1999; set Mort_1999;
if eanum>5 then eanum=5; run;

proc freq data=Mort_1999 noprint;
table sex*eanum*ucod/ out=See_1999;
run;
data See_1999; set See_1999;
if eanum>5 then eanum=5; run;

proc sort data=See_1999; by sex eanum; run;
proc rank data=See_1999 out=See_1999r descending; by sex eanum;
var count;
ranks ucod_rank; run;
proc sort data=See_1999r; by descending sex eanum count; run;

proc freq data=See_1999r noprint;
weight count;
where ucod_rank<=5;
table ucod_rank*ucod*eanum*sex/ out=See_1999r_top; run;

*top pøíèiny pro muže zemøící s 5 v 1999: 414 410 162 496 436;
data MOrt_1999r; set MOrt_1999;
if sex="M" then do;
if eanum=5 then do;
		if ucod ="I25" or ucod="I21" or ucod="J44" or ucod="C34" or ucod="E14" then rucod=ucod; else rucod="999"; end;
if eanum=4 then do;
		if ucod="I25" or ucod="I21" or ucod="J44" or ucod="C34" or ucod="E14" then rucod=ucod; else rucod="999"; end;
if eanum=3 then do;
		if ucod="I25" or ucod="I21" or ucod="C34" or ucod="J44" or ucod="I64" then rucod=ucod; else rucod="999"; end;
if eanum=2 then do;
		if ucod="I25" or ucod="I21" or ucod="C34" or ucod="J44" or ucod="I64" then rucod=ucod; else rucod="999"; end;
if eanum=1 then do;
		if ucod="C34" or ucod="I25" or ucod="I21" or ucod="C61" or ucod="C18" then rucod=ucod; else rucod="999"; end; end;
if sex="F" then do;
if eanum=5 then do;
		if ucod ="I25" or ucod="I21" or ucod="J44" or ucod="I64" or ucod="E14" then rucod=ucod; else rucod="999"; end;
if eanum=4 then do;
		if ucod="I25" or ucod="I21" or ucod="J44" or ucod="I64" or ucod="E14" then rucod=ucod; else rucod="999"; end;
if eanum=3 then do;
		if ucod="I25" or ucod="I21" or ucod="I64" or ucod="J44" or ucod="C34" then rucod=ucod; else rucod="999"; end;
if eanum=2 then do;
		if ucod="I25" or ucod="I21" or ucod="C34" or ucod="I64" or ucod="J44" then rucod=ucod; else rucod="999"; end;
if eanum=1 then do;
		if ucod="C34" or ucod="I25" or ucod="C50" or ucod="I21" or ucod="I64" then rucod=ucod; else rucod="999"; end; end;
run;

proc freq data=Mort_1999r;
where eanum=5;
table rucod; run;

proc freq data=Mort_1999r noprint;
table sex*age_group*age_num*rucod*eanum/ out=Mort_1999r_c; run;

*__________________________________________________________________________________________________________;
data Mort_2019; set Mort_2019;
if eanum>5 then eanum=5; run;

proc freq data=Mort_2019 noprint;
table sex*eanum*ucod/ out=See_2019;
run;
data See_2019; set See_2019;
if eanum>5 then eanum=5; run;

proc sort data=See_2019; by sex eanum; run;
proc rank data=See_2019 out=See_2019r descending; by sex eanum;
var count;
ranks ucod_rank; run;
proc sort data=See_2019r; by descending sex eanum count; run;

proc freq data=See_2019r noprint;
weight count;
where ucod_rank<=5;
table ucod_rank*ucod*eanum*sex/ out=See_2019r_top; run;

*top pøíèiny pro muže zemøící s 5 v 1987: 414 410 162 496 436;
data MOrt_2019r; set MOrt_2019;
if sex="M" then do;
if eanum=5 then do;
		if ucod ="I25" or ucod="I21" or ucod="J44" or ucod="C34" or ucod="E14" then rucod=ucod; else rucod="999"; end;
if eanum=4 then do;
		if ucod="I25" or ucod="I21" or ucod="J44" or ucod="C34" or ucod="E14" then rucod=ucod; else rucod="999"; end;
if eanum=3 then do;
		if ucod="I25" or ucod="I21" or ucod="C34" or ucod="J44" or ucod="I64" then rucod=ucod; else rucod="999"; end;
if eanum=2 then do;
		if ucod="I25" or ucod="I21" or ucod="C34" or ucod="J44" or ucod="I64" then rucod=ucod; else rucod="999"; end;
if eanum=1 then do;
		if ucod="C34" or ucod="I25" or ucod="I21" or ucod="C61" or ucod="C18" then rucod=ucod; else rucod="999"; end; end;
if sex="F" then do;
if eanum=5 then do;
		if ucod ="I25" or ucod="I21" or ucod="J44" or ucod="I64" or ucod="E14" then rucod=ucod; else rucod="999"; end;
if eanum=4 then do;
		if ucod="I25" or ucod="I21" or ucod="J44" or ucod="I64" or ucod="E14" then rucod=ucod; else rucod="999"; end;
if eanum=3 then do;
		if ucod="I25" or ucod="I21" or ucod="I64" or ucod="J44" or ucod="C34" then rucod=ucod; else rucod="999"; end;
if eanum=2 then do;
		if ucod="I25" or ucod="I21" or ucod="C34" or ucod="I64" or ucod="J44" then rucod=ucod; else rucod="999"; end;
if eanum=1 then do;
		if ucod="C34" or ucod="I25" or ucod="C50" or ucod="I21" or ucod="I64" then rucod=ucod; else rucod="999"; end; end;
run;

proc freq data=Mort_2019r;
where eanum=5;
table rucod; run;

proc freq data=Mort_2019r noprint;
table sex*age_group*age_num*rucod*eanum/ out=Mort_2019r_c; run;

PROC EXPORT DATA= WORK.Mort_2019r_c 
            OUTFILE= "C:\Users\Bety Ukolova\Desktop\pokus\Mort_Dxi_1.
xlsx" 
            DBMS=EXCEL REPLACE;
     SHEET="2019"; 
RUN;
PROC EXPORT DATA= WORK.Mort_1999r_c 
            OUTFILE= "C:\Users\Bety Ukolova\Desktop\pokus\Mort_Dxi_1.
xlsx" 
            DBMS=EXCEL REPLACE;
     SHEET="1999"; 
RUN;

PROC EXPORT DATA= WORK.Vs_ppk 
            OUTFILE= "C:\Users\Bety Ukolova\Desktop\pokus\Mort_Dxi_1.
xlsx" 
            DBMS=EXCEL REPLACE;
     SHEET="VS_ppk"; 
RUN;
