*Koukej se;
proc print data=Nova.Bimodal_cdai_m75;
var underlying contributory du dc duc;
where contributory in ("dc-H40" "dc-F25"); run;

data vidim; set Mort_partII;
where ucod="F54" and sex="F"; run;

libname Nova "G:\M�j disk\DP\zbytek\B\memory\sas v�stupy";
libname Database "G:\M�j disk\DP\zbytek\B\memory\sas data";
*______________________________________________________________________________________________________________________________________________
 V�B�R C�LOV� POPULACE PODLE ZADAN�CH PARAMETR� + Z�KLADN� OPERACE NA DAT�CH (P�ESUNY, RECODY);

%LET rok=Mort_2018; *Zadej n�zev souboru z jak�ho roku chce� d�lat anal�zu ve tvaru Mort_XXXX;
%LET sex=F; *Zadej pohlav� M/F;
%LET od=0;%LET do=101; *Zadej v�kov� rozmez� od�do (min=0, max=100)-> nehejbej s tim, CDAI po��t� za celou populaci;
%LET stan_dolni_mez=0; %LET stan_horni_mez=100; *Zadej si v�kov� rozmez�, pro �pravu standardn� populace. Plat� hodnoty: 0,1,5..(n+5)...100
Kdy� d� t�eba 1, m� tam v�ky 1-4, kdy� 5, tak 5-9.Ob� meze se zapo��tavaj� do v�kov�ho intervalu
(t�eba kdy� zad� 0-10, bude� tam m�t lidi 0-14)

*P�esun datasetu mezi libraries ;
proc copy in=database out=work memtype=data;
select &rok;
run;
*V star��ch souborech tvo�� novou p�smenkovou prom�nnou sex m�sto numerick�;
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
*V�b�r zadan�ho pohlav�;
data &rok;
set &rok;
where sex="&sex"; run;
*P�epis v�ku;
data &rok;
set &rok;
if datayear<100 or year<=2002 then do; *pro 1980-2002;
	if age<100 then age_want=age;
	if age>=100 and age<200 then age_want=100;
	if age>=200 then age_want=0;
	if age=999 then age_want="."; end;
if datayear>=100 or year>2002 then do; *pro 2003-2019;
	x= put(age, 4.);
	age_want = input(substr(x,2,3),4.);
	if age>1135 then age_want=0;
	if age=>1100 and age<=1135 then age_want=100;
	if age=999 then age_want=".";
	drop x; end;
run;
*Selekce zadan�ho v�ku;
data &rok;
set &rok;
where age_want>=&od and age_want<&do; run;

*Odmaz�v� k�dy z prvn� ��sti hl�en�, bude� tam m�t jenom UCOD a p���iny v Part II;
data Mort_partII;
set &rok;
array as econdp_1-econdp_20;
array bs enicon_1-enicon_20;
do i=1 to dim(as);
if as[i]<6 then do;
	as[i]=.;
	bs[i]="";
end; end;
run;
*P�episuje� kody na t�echm�stn�;
data Mort_partII; 
length enicon_1-enicon_20 ucod $3.;
set Mort_partII; run;

*Recoduje� v�k v jednotk�ch do 5 let�ch skupin -> nejde to napsat kr�t�?
 Tvoje nov� prom�nn� age_numeric obsahuje hodnoty, kter� jsou ve sloupci age_numeric v souboru se standardem, kter� bude� z�hy importovat;
data Mort_partII;
set Mort_partII;
if age_want=0 then age_numeric=0;
if age_want>0 and age_want<5 then age_numeric=1;
if age_want>=5 and age_want<10 then age_numeric=5;
if age_want>=10 and age_want<15 then age_numeric=10;
if age_want>=15 and age_want<20 then age_numeric=15;
if age_want>=20 and age_want<25 then age_numeric=20;
if age_want>=25 and age_want<30 then age_numeric=25;
if age_want>=30 and age_want<35 then age_numeric=30;
if age_want>=35 and age_want<40 then age_numeric=35;
if age_want>=40 and age_want<45 then age_numeric=40;
if age_want>=45 and age_want<50 then age_numeric=45;
if age_want>=50 and age_want<55 then age_numeric=50;
if age_want>=55 and age_want<60 then age_numeric=55;
if age_want>=60 and age_want<65 then age_numeric=60;
if age_want>=65 and age_want<70 then age_numeric=65;
if age_want>=70 and age_want<75 then age_numeric=70;
if age_want>=75 and age_want<80 then age_numeric=75;
if age_want>=80 and age_want<85 then age_numeric=80;
if age_want>=85 and age_want<90 then age_numeric=85;
if age_want>=90 and age_want<95 then age_numeric=90;
if age_want>=95 and age_want<100 then age_numeric=95;
if age_want>=100 then age_numeric=100; run;

*_______________________________________________________________________________________________
MANIPULACE S DATAMA - UTV��EN� DVOJIC MEZI UCOD A kody v Part II;

*Celkov� po�et k�d� uveden�ch v Part II; 
data Mort_partII;
 set Mort_partII;
 	totmiss=cmiss(of enicon_1-enicon_20);
 	totnonmiss=20- cmiss(of enicon_1-enicon_20);
run;
*P�i�azuje� ID k pozorov�n�;
data Mort_partII;
set Mort_partII;
ID=_n_;
run;

*P�ipisuje� ucod ��dek v�skytu, abys pak mohla podle n�ho vyhled�vat ucod  mezi v�ema p���inama;
data Mort_partII;
length enicon_21 $3. econdp_21 5;
set Mort_partII;
enicon_21=ucod;
econdp_21=99; run;

*Duplikuje� info o ��dc�ch, abys mohla uskute�nit Sag_2;
data Sag_1;
set Mort_partII;
array as econdp_1-econdp_21;
array bs econdp2_1-econdp2_21;
do i=1 to dim(as);
bs[i]=as[i]; end;
run;

*Utvo�uje� dvojice;
data Sag_2;
set Sag_1;
   array as enicon_1-enicon_21;
   array bs enicon_1-enicon_21;
   array cs econdp_1-econdp_21;
   array ds econdp2_1-econdp2_21;
      do i= 1 to dim(as);
      do j= 1 to dim(bs);
         if as[i]~=("") and bs[j]~=("")  then do;
            A=(as[i]);
            B=(bs[j]);
			C=(cs[i]);
			D=(ds[j]);
            output;
      end;
      end;
      end;
keep a b c d ID age_numeric;
run;

*Odstra�uje� redundantn� p�ry - ve fin�le ti tam zbyde u ka�d�ho �lov�ka jenom p���ina z Part II v sloupci A sp�rovan� s jeho UCOD,
kter� je uveden� v sloupci B, nesleduje� p�ry mezi p���inama v Part II mezi sebou!! Chce� toti� asociace vyjad�ovat s UCOD a tam t� zaj�maj
jenom dvojice underlying (tv�j sloupec B)+contributory (tv�j sloupec A)
-> po tomhlectom kroce ti vypadnou lidi co nemaj ��dn� caontributory causes -> vad� ti to?;
data Sag_3;
set Sag_2;
if C=6 and D=99; run;

*Po��t� v�skyty dvojic v r�mci jedn� v�kov� kategorie;
proc sort data=Sag_3; by age_numeric; run;
proc freq data=Sag_3 noprint;
by age_numeric;
tables A*B/ norow nocol nopercent out=Sag_4;
run;
*Upravuje� dataset s po�etama dvojic;
data Sag_4;
set Sag_4;
duc=count; *duc jako deaths at age x (age_numeric) with underlying cause u and contributing cause c;
drop count percent; run;
proc sort data=Sag_4; by descending duc; run;

*Po��t� du - po�ty lid� s stejnou underlying cause. D�l� to z cel�ho p�vodn�ho datasetu, tak�e tam m� i ty lidi, co t�eba nem�ly
��dnou contributory cause;
data Du;
set Mort_partII;
keep ucod age_numeric;
proc sort data=Du; by age_numeric; run;
proc freq data=Du noprint;
by age_numeric;
tables Ucod/ norow nocol nopercent out=Du;
run;
data Du;
length B $3.;
set Du;
du=count;*du jako number of deaths observed at age x (age_numeric) with cause u as underlying cause;
B=ucod;
drop ucod count percent; run;

*Po��t� dc - po�ty lid� podle contributory cause. Zase to d�l� z p�vodn�ho datasetu;
data Dc;
set Mort_partII;
array as enicon_1-enicon_20;
 do i= 1 to dim(as);
 if as[i]~=("") then do;
 A=(as[i]);
 output;
keep A ID age_numeric;
end; end; run;
proc sort data=Dc; by age_numeric; run;
proc freq data=Dc noprint;
by age_numeric;
tables A/ norow nocol nopercent out=Dc;
run;
data Dc;
set Dc;
dc=count; *total number of deaths at age x (age_numeric) observed with cause c as contributing cause (regardless of the underlying cause);
drop count percent; run;

*D�v�m dohromady Dc, Du a Sag_4 (tam m� ty po�ty dvojic Duc);
proc sort data=Sag_4; by age_numeric A; run;
proc sort data=Dc; by age_numeric A; run;
data Duc_Dc;
merge Sag_4 Dc;
by age_numeric A; run;
proc sort data=Duc_Dc; by age_numeric B; run;
proc sort data=Du; by age_numeric B; run;
data Duc_Dc_Du;
merge Duc_Dc Du;
by age_numeric B; run;
data Duc_Dc_Du;
set Duc_Dc_Du;
if A="" or B="" then delete; run;

*Po��t� re�lnou v�kovou strukturu zem�el�ch, abys pak mohla p�idat prom�nnou d (celkov� po�et zem�el�ch ve v�ku x);
proc sort data=Mort_partII; by age_numeric; run;
proc means data=Mort_partII n noprint;
by age_numeric;
var age_numeric;
where age_numeric>=&stan_dolni_mez and age_numeric<=&stan_horni_mez; *useless statement;
output out=Real_pop n=Population;
run;
*V prom�nn� Population m� dx;
data Undirected;
merge Duc_Dc_Du Real_pop;
by age_numeric;
d=Population;
drop _TYPE_ _FREQ_ Population; run;

*_____________________________________________________________________________________________________________
 V�PO�ET M�R ASOCIACE (CDAI);
*Import souboru se standardem (bere� Popstand2013 od MP -> europskej?)
-> v tomto souboru mus� m�t prom age_numeric, kter� je zakodovan� podle syntaxe pro vytv��en� prom�nn� age_numeric pov�� zde;
PROC IMPORT OUT= WORK.Standard_pop 
            DATAFILE= "G:\M�j disk\DP\zbytek\Popstand2013.xlsx" 
            DBMS=EXCEL REPLACE;
     RANGE="Foglio2$"; 
     GETNAMES=YES;
     MIXED=NO;
     SCANTEXT=YES;
     USEDATE=YES;
     SCANTIME=YES;
RUN;
*P�ind�v� sloupec s standardn� populac� do souboru, kde bude� n�sledn� po��tat CDAI;
data Undirected;
merge Undirected Standard_pop;
by age_numeric;
run;

*Po��t� ho�ej�ek a dolej�ek zlomku pro CDAI;
data Undirected;
set Undirected;
sum_popstan=100000;
horejsek=(duc/du)*Popstan/sum_popstan;
dolejsek=(dc/d)*Popstan/sum_popstan; *p�ekontroluj, jestli m� v dc skute�n� contributory a v du skute�n� ucod;
horejsek_pro_IS=((Popstan/sum_popstan)**2)*(duc/(du**2));
dolejsek_pro_IS=((duc/du)*(Popstan/sum_popstan));
run;

*Pos��t�v� ho�ej�ky a dolej�ky CDAI a fragmenty, z kter�ch bude� skl�dat intervaly spolehlivost� v r�mci jedn� dvojice A B;
proc summary nway data=Undirected noprint; *Nway pro�;
var horejsek dolejsek horejsek_pro_IS dolejsek_pro_IS;
class A B;
output out=Undirected_CDAI sum=;
run;
*Dopo��t�v� kompletn� CDAIu,c a intervaly spolehlivosti v jednotk�ch na 100 000 asi;
data Undirected_CDAI;
length sig_CDAI $5.;
set Undirected_CDAI;
CDAI=(horejsek/dolejsek); *m� to jako�e na 100 000 obyvatel?;
SE_log_CDAI=(horejsek_pro_IS/(dolejsek_pro_IS**2))**(1/2);
IS_dolni_mez=exp(log(CDAI-1.96*SE_log_CDAI));
IS_horni_mez=exp(log(CDAI+1.96*SE_log_CDAI));
ln_CDAI=log(CDAI);
if IS_dolni_mez>1 and IS_horni_mez>1 then sig_CDAI="sig"; *signifikantn� vazby jsou jenom ty, kter� jsou nad 100 cel�m SI;
else sig_CDAI="nesig";
drop _type_ _freq_;
run;
*Pokud CDAI je signifikantn� v�t�� ne� 100, tak je ta asociace v�ce se objevuj�c�,
ne� by tomu bylo za p�edpokladu platnosti nez�vislost� t�ch dvou p���in;

*Po��t� v�skyty t�ch kod� -> nem��e� to d�lat z Duc_dc_du;
data Prev_duc;
set Duc_Dc; drop age_numeric dc;
data Prev_dc;
set Dc; drop age_numeric ; run;
data Prev_du;
set Du; drop age_numeric ;
proc freq data=Prev_duc noprint; 
weight duc; table A*B/nocol norow nopercent out=Prev_duc; run;
proc freq data=Prev_dc noprint; 
weight dc; table A/nocol norow nopercent out=Prev_dc;run;
proc freq data=Prev_du noprint; 
weight du; table B/nocol norow nopercent out=Prev_du; run;
*D�v� dohromady v�echny ty v�skyty duc, dc, du s t�m datasetem, kde m� spo�ten� CDAI
-> nem��e� �sporn�jic? -> vy�e� to;
proc sort data=Undirected_CDAI; by A B; run;
proc sort data=Prev_duc; by A B; run;
proc sort data=Prev_dc; by A ; run;
proc sort data=Prev_du; by B ; run;
data Undirected_CDAI;
merge Undirected_CDAI Prev_duc (rename=(count=duc)); by A B ;
merge Undirected_CDAI Prev_dc (rename=(count=dc)); by A; run;
proc sort data=Undirected_CDAI; by B; run;
data Undirected_CDAI;
merge Undirected_CDAI Prev_du (rename=(count=du)); by B; run;
data Undirected_CDAI;
set Undirected_CDAI; if a="" or b="" then delete;
ln_duc=log(duc); run;
proc sort data=Undirected_CDAI; by A B; run;
*Nechce� si odmazat t� vazby, co jsou sice signifikantn�, ale pat�� t�eba do doln�ho decilu (�e maj prost� v�skyt t�eba m�� �astej ne� 5)?;

*Do trval� knihovny pos�l� soubor s jenom signifikantn�ma vazbama a d�l� d�l�� kosmetick� �pravy k tomu;
data Undirected_CDAI;
length contributory $6. underlying $6.;
set Undirected_CDAI;
if sig_CDAI="sig";
label duc="duc";
label dc="dc";
label du="du"; 
contributory=cats("dc-", A);
underlying=cats("du-", B);
drop percent; run;

*Po��t� prevalence duc, dc, du (relativizuje� sou�tem);
proc sql;
create table DUC_sum as
select sum(duc) as sum_duc from Duc_DC_Du;
create table DC_sum as
select sum(dc) as sum_dc from Dc;
create table DU_sum as
select sum(du) as sum_du from Du;
quit;
data Undirected_CDAI;
set Undirected_CDAI;
if _n_=1 then set DUC_sum(keep=sum_duc);
if _n_=1 then set DC_sum(keep=sum_dc); *vych�z� ti to podez�ele;
if _n_=1 then set DU_sum(keep=sum_du);
prev_duc=duc/sum_duc*1000;
prev_dc=dc/sum_dc*1000;
prev_du=du/sum_du*1000;
run;

ods exclude all;
proc means data=Undirected_CDAI p90 STACKODSOUTPUT maxdec=2; 
var duc;
ods output Summary=duc_stats; run;
ods exclude none;
data See2;
set Undirected_CDAI;
if _n_=1 then set duc_stats(keep=p90);
run;
*Pos�l� 25% vazeb s vy���m Nij do trval� knihovny;
data Undirected_CDAI_see;
set See2;
if duc>p90;
drop p90;
run;

data Undirected_CDAI_try; *useless k�d, �e jo;
set Undirected_CDAI_see;
if CDAI>1; run;

data Nova.Bimodal_CDAI_z75;
set Undirected_CDAI_try; run;

*Na konci tohohle syntaxu m� matici contributory na conrtibutory, ale mus� si p�ekontrolovat, jsetli se ti p�i�ad�ly 
 spr�vn� n�zvy t�ch sloupc� a ��dk�
-> v souboru Mat_dataset_with_names_final m� na diagon�le kolik celkem duc z souboru Undrirected_CDAI_try m� ty prvky jako
   dc (tak�e si to zkontroluj)
-> a mimo diagon�lu m� na kolik celkem se poj� du spolu s t�ma prvkama mimo diagon�lu
-> kontroly pros�m -> vy�e� to!!!!;

*______________________________________________________________________________________________________________________
 ZE�TVERCOVAT�N� MATICE DC NA DU 
 -> d�l� to, abys pak mohla ud�lat t� bimod�ln� s�t� (dc na sebe se v�ou/ du na sebe se v�ou;

data Krok_1;
set Undirected_cdai_try;
keep contributory underlying duc; run;

proc transpose data=Krok_1 out=Krok_2 name=duc; id underlying; by contributory; run;

proc stdize data=Krok_2 out=Krok_3 reponly missing=0;
var du_:;
run;
* V souboru Krok_4 m� jako�e matici s popisama ��dk� a sloupc�;
data Krok_3;
set Krok_3;
drop duc _LABEL_; run;

proc contents data=Krok_3 out=Krok_3_1_du (keep=name);
run;
data  Krok_3_1_du; 
set Krok_3_1_du;
if name="contributory" then delete;
underlying=name;
name=substr(name, 4, 3);run;
data Krok_3_1_du;
length name $6.;
set Krok_3_1_du;
run;
data Krok_3_1_dc; *list s origin�ln�ma p���inama (pouze ty, co je objevovaly v signifikantn�m souboru);
set Krok_3;
name=substr(contributory, 4,3);
keep name contributory;
run;
*v prom name m� v�ci na p��padn� p�rov�n�;

proc sql;
create table Krok_3_2_dc_navic as
select * from Krok_3_1_dc
where name not in (select name from Krok_3_1_du);
create table Krok_3_2_du_navic as
select * from Krok_3_1_du
where name not in (select name from Krok_3_1_dc);
quit;
data Krok_3;
length name $6.;
set Krok_3;
name=substr(contributory, 4,3);
run;
*P�id�v� ��dky;
data Krok_3_3;
set Krok_3_2_du_navic (drop=underlying) Krok_3 (drop=contributory);
run;
*Transponuje� p���iny nejsouc� v d�sledc�ch a p�id�v� je jako sloupce;
proc transpose data=Krok_3_2_dc_navic out=Krok_3_4 prefix=du_;
id name;run;
data Krok_3_5;
set Krok_3_4 Krok_3_3;
run;
*useless �pravy;
data Krok_3_5;
length name $3.;
set Krok_3_5;
drop _name_ ; run;
proc sort data=Krok_3_5; by name; run;
*�adim sloupce podle alfabetu;
proc contents data=Krok_3_5 out=Krok_3_6 (keep=name);
run;
data _null_;
  set Krok_3_6 end=last;
  i+1;
  call symput('var'||trim(left(put(i,8.))),trim(name));
  if last then call symput('total',trim(left(put(i,8.))));
run;
%macro test;
  data Krok_3_7;
    retain %do j=1 %to &total;
             &&var&j
	   %end;;
    set Krok_3_5;
  run;
%mend test;
%test;
proc stdize data=Krok_3_7 out=Krok_3_8 reponly missing=0;
var du_:;
run;
data Krok_3_9;
length name $3. contributory  $6.;
set Krok_3_8;
contributory=cats("dc_", name); * v t�hle soubo�e m� �tvercovou matici dc x du, se�azen� podle abc -> TOHLE JE D�LE�IT� PROS�M T�!!!;
run;

*p�epusuje� po�ty lid�, co maj duc na 1 a 0;
data Krok_4;
set  Krok_3_9;
array as _numeric_;
do i=1 to dim(as);
if as[i]>0 then do; as[i]=1; end;
if as[i]=0 then do; as[i]=0; end;
end; 
drop i; run;


*______________________________________________________________________________________________________
 MATICOV� PO�TY (viz papirek, prost� p�end�v� to na dc x dc) -> TADY!!! V�IMNI SI, �E JE TO DC NA DC;

*D�v� Krok_4 do objektu formy matice;
proc iml;
use Krok_4; 
read all var _NUM_ into A; *v iml objektu A m� soubor Krok_4 ale ve form� matice (sloupce jsou underlying, ��dky contributory);
At = A`; *transponuje� A;
*print A; *tohle rad�eji nespou�t�j -> p��li� velk�;
*print At; *tohle rad�eji nespou�t�j -> p��li� velk�;
AAt = A * At;
*print AAt;
create Mat_dataset from AAt;
append from AAt;
close Mat_dataset; * m� soubor, ke kter�mu bude� pak p�ind�vat n�zvy sloupc� a ��dk�;

*M� dva soubory, v nich� m� n�zvy sloupc� a ��dk�, co chce� p�idat k matici;
proc contents data=Krok_3_9 out=Col_names (keep=name);
run;
data Col_names;
set Col_names; 
if name ne "contributory" and name ne "name"; run;
data Col_names;
length name $3.;
set Col_names;
name=substr(name, 4, 3);
ID=_n_; run;
data Row_names;
set Krok_3_9;
ID=_n_;
keep ID name; run;
*Jak p�indat n�zvy prom�nn�ch m�sto col1 atd?;
proc contents data=Mat_dataset out=Col_names_old (keep=name);
run;
data Col_names_old;
set Col_names_old;
ID=_n_; run;
data Col_names_both;
merge Row_names (rename=(name=new_name))
      Col_names_old(rename=(name=old_name));
by ID; run;

data Col_names_both_try;
length new_name_short $3.;
set Col_names_both;
new_name_short=new_name;
if old_name ne "ID";
run;

PROC SQL;
	SELECT CATX("=", old_name, new_name_short)
		INTO :LIST_RENAME SEPARATED BY " "
		FROM WORK.Col_names_both_try;
QUIT;
 
%PUT &=LIST_RENAME.;
PROC DATASETS LIB=WORK;
	MODIFY Mat_dataset;
	RENAME &LIST_RENAME.;
RUN;

data Mat_dataset;
set Mat_dataset;
ID=_n_; run;
data Mat_dataset_with_names;
merge Mat_dataset
      Col_names_both_try;
by ID; run;

data Mat_dataset_with_names_final;
length contributory $3.;
set Mat_dataset_with_names;
contributory=new_name_short;
drop ID new_name old_name new_name_short; run;

proc transpose data=Mat_dataset_with_names_final out=List_dc;
by contributory; run;

data List_dc;
set List_dc (rename=(contributory=dc1 _name_=dc2 col1=N_spolecnych_du));
label dc2="dc2";
run;

data List_dc_A;
set List_dc;
if dc1=dc2 then do;
N_du_celkem=N_spolecnych_du; end;
else do; N_du_celkem=""; end; run;
data List_dc_A;
set List_dc_A;
if dc1=dc2 then do; poradi=1; end;
else do; poradi=2; end; run;
proc sort data=List_dc_A out=List_dc_B; by dc1 poradi dc2; run;

data List_dc_C;
set List_dc_B;
by dc1;
if first.dc1 then N_du_sum=N_du_celkem;
else N_du_sum=coalesce(N_du_celkem, N_du_sum);
retain N_du_sum;
run;

data List_dc_D;
set List_dc_C;
half_N_du_sum=N_du_sum/2;
tri_ctvrte_N_du_sum=(N_du_sum/4)*3;
drop N_du_celkem poradi; run;

proc freq data=List_dc_d noprint; * jenom for sure se kouknout jestli ti t�eba m�ry polohy nevych�zej n�hodou jin��,
									kdy� b��e� jenom origin�ln� po�ety -> asi p�ekvapiv� ok;
table dc1*N_du_sum/ nocol norow nopercent out=List_dc_e; run;
proc sort data=List_dc_e nodup out=List_dc_f; by dc1; run;
data List_dc_f; set List_dc_f; drop count percent; run;

proc means data=List_dc_f p50 p75 p90; var N_du_sum; run; 

data Dc_sousedi;
set List_dc_D;
A=dc1; B=dc2;
if dc1 ne dc2 and N_spolecnych_du=>half_N_du_sum and N_du_sum=>4; run; *UPDEJTUJ!!!!
* chce� spole�nou v�t�inu? tohle: N_spolecnych_du>half_N_du_sum;

*N�e k�dem si ponech�v� jenom ty vazby, kde jsou ty podm�nky spln�ny z obouch stran
 (tzn. v�c jak polovina spole�n�ch soused� od obou uzl�);
data Dc_paralel_1;
length dc1_dc2 $7. dc2_dc1 $7. dc2 $3. B $3.;
set Dc_sousedi;
dc1_dc2=catx("_", dc1, dc2);
dc2_dc1=catx("_", dc2, dc1);
run;
proc sql;
create table Dc_paralel_2_1 as select dc1_dc2 from Dc_paralel_1;
create table Dc_paralel_2_2 as select dc2_dc1 from Dc_paralel_1;
quit;

data Dc_paralel_2;
set Dc_paralel_2_1 (rename=(dc1_dc2=mix))
	Dc_paralel_2_2 (rename=(dc2_dc1=mix)); 
 run;
proc sort data=Dc_paralel_2 nodcpkey dcpout=Dc_paralel_3_1 out=Dc_paralel_3_2; by mix; run;
*v soub�e Dc_paralel_3_1 m� ty vazby, kter� jsou reciprok�;
data Dc_paralel_3;
length dc1 $3. dc2 $3.;
set Dc_paralel_3_1;
dc1=substr(mix, 1,3);
dc2=substr(mix, 5,3);
reciproky=1;
run;
proc sort data=Dc_paralel_1; by dc1 dc2; run;
proc sort data=Dc_paralel_3; by dc1 dc2; run;
data Dc_paralel_4;
merge Dc_paralel_3
	  Dc_paralel_1;
by dc1 dc2;
if reciproky=1; run;


*______________________________________________________________________________________________________
 MATICOV� PO�TY (viz papirek, prost� p�end�v� to na du x du) -> TADY!!! V�IMNI SI, �E JE TO DU NA DU;

proc transpose data=Krok_3_9 out=Krok_3_9_1 name=underlying; id contributory;  run;
data Krok_3_9_1;
length name $6.;
set Krok_3_9_1;
name=substr(underlying, 4, 3);
run;

*p�epusuje� po�ty lid�, co maj duc na 1 a 0;
data Krok_4;
set  Krok_3_9_1;
array as _numeric_;
do i=1 to dim(as);
if as[i]>0 then do; as[i]=1; end;
if as[i]=0 then do; as[i]=0; end;
end; 
drop i; run;

*D�v� Krok_4 do objektu formy matice;
proc iml;
use Krok_4; 
read all var _NUM_ into A; *v iml objektu A m� soubor Krok_4 ale ve form� matice (sloupce jsou underlying, ��dky contributory);
At = A`; *transponuje� A;
*print A; *tohle rad�eji nespou�t�j -> p��li� velk�;
*print At; *tohle rad�eji nespou�t�j -> p��li� velk�;
AAt = A * At;
*print AAt;
create Mat_dataset from AAt;
append from AAt;
close Mat_dataset; * m� soubor, ke kter�mu bude� pak p�ind�vat n�zvy sloupc� a ��dk�;

*M� dva soubory, v nich� m� n�zvy sloupc� a ��dk�, co chce� p�idat k matici;
proc contents data=Krok_3_9_1 out=Col_names (keep=name);
run;
data Col_names;
set Col_names; 
if name ne "underlying" and name ne "name"; run;
data Col_names;
length  name $3.;
set Col_names;
name=substr(name, 4, 3);
ID=_n_; run;
data Row_names;
set Krok_3_9_1;
ID=_n_;
keep ID name; run;
*Jak p�indat n�zvy prom�nn�ch m�sto col1 atd?;
proc contents data=Mat_dataset out=Col_names_old (keep=name);
run;
data Col_names_old;
set Col_names_old;
ID=_n_; run;
data Col_names_both;
merge Row_names (rename=(name=new_name))
      Col_names_old(rename=(name=old_name));
by ID; run;

data Col_names_both_try;
length new_name_short $3.;
set Col_names_both;
new_name_short=new_name;
if old_name ne "ID";
run;

PROC SQL;
	SELECT CATX("=", old_name, new_name_short)
		INTO :LIST_RENAME SEPARATED BY " "
		FROM WORK.Col_names_both_try;
QUIT;
 
%PUT &=LIST_RENAME.;
PROC DATASETS LIB=WORK;
	MODIFY Mat_dataset;
	RENAME &LIST_RENAME.;
RUN;

data Mat_dataset;
set Mat_dataset;
ID=_n_; run;
data Mat_dataset_with_names;
merge Mat_dataset
      Col_names_both_try;
by ID; run;

data Mat_dataset_with_names_final;
length underlying $3.;
set Mat_dataset_with_names;
underlying=new_name_short;
drop ID new_name old_name new_name_short; run;

proc transpose data=Mat_dataset_with_names_final out=List_du;
by underlying; run;

data List_du;
set List_du (rename=(underlying=du1 _name_=du2 col1=N_spolecnych_dc));
label du2="du2";
run;

data List_du_A;
set List_du;
if du1=du2 then do;
N_dc_celkem=N_spolecnych_dc; end;
else do; N_dc_celkem=""; end; run;
data List_du_A;
set List_du_A;
if du1=du2 then do; poradi=1; end;
else do; poradi=2; end; run;
proc sort data=List_du_A out=List_du_B; by du1 poradi du2; run;

data List_du_C;
set List_du_B;
by du1;
if first.du1 then N_dc_sum=N_dc_celkem;
else N_dc_sum=coalesce(N_dc_celkem, N_dc_sum);
retain N_dc_sum;
run;

data List_du_D;
set List_du_C;
half_N_dc_sum=N_dc_sum/2;
tri_ctvrte_N_dc_sum=(N_dc_sum/4)*3;
drop N_dc_celkem poradi; run;

proc means data=List_du_d p50 p75 p90; var N_dc_sum; run; 

data Du_sousedi;
set List_du_D;
A=du1; B=du2;
if du1 ne du2 and N_spolecnych_dc>=half_N_dc_sum and N_dc_sum>=5; run;
* chce� spole�nou v�t�inu? tohle: N_spolecnych_du>half_N_du_sum;

*N�e k�dem si ponech�v� jenom ty vazby, kde jsou ty podm�nky spln�ny z obouch stran
 (tzn. v�c jak polovina spole�n�ch soused� od obou uzl�);
data Du_paralel_1;
length du1_du2 $7. du2_du1 $7. du2 $3. B $3.;
set Du_sousedi;
du1_du2=catx("_", du1, du2);
du2_du1=catx("_", du2, du1);
run;
proc sql;
create table Du_paralel_2_1 as select du1_du2 from Du_paralel_1;
create table Du_paralel_2_2 as select du2_du1 from Du_paralel_1;
quit;

data Du_paralel_2;
set Du_paralel_2_1 (rename=(du1_du2=mix))
	Du_paralel_2_2 (rename=(du2_du1=mix)); 
 run;
proc sort data=Du_paralel_2 nodupkey dupout=Du_paralel_3_1 out=Du_paralel_3_2; by mix; run;
*v soub�e Du_paralel_3_1 m� ty vazby, kter� jsou reciprok�;
data Du_paralel_3;
length du1 $3. du2 $3.;
set Du_paralel_3_1;
du1=substr(mix, 1,3);
du2=substr(mix, 5,3);
reciproky=1;
run;
proc sort data=Du_paralel_1; by du1 du2; run;
proc sort data=Du_paralel_3; by du1 du2; run;
data Du_paralel_4;
merge Du_paralel_3
	  Du_paralel_1;
by du1 du2;
if reciproky=1; run;



*kontrola;
*proc print data=Du_paralel_4;
*where du1 in ("A04" "A41") and du2 in ("A04" "A41"); *run;
*______________________________________________________________________________________________________
 VYTV��EN� SOUBOR� NA IMPORT DO GEPHI (NA INDIVINDI S͍ JENOM S DC, �I INDIVINDI S͍ JENOM S DU);
*viz zvl�tn� program;
















*____________________________________________________________________________________________________________________
 POH�EBI�T�;

*Vytv��en� dat na s� s dc i du dohromady;
* Bere� soubor, kde u� m� omezen� na duc (>p90, tj. 1=duc spl�uje tuto podm�nku, 0=nespl�uje);
data Pokus_1;
set Krok_4;
sum_du = sum(of du_A04--du_Y87); *kolik celkem m� ta dc v ��dku du soused�;
run;
data Pokus_2;
set Pokus_1;
contributory=substr(contributory, 4);
run;
data Pokus_3; * prom�nn� bez prefixu du_ jsou dc a dg t�to ��st� matice je rovna sloupci sum_du;
merge Pokus_2 Mat_dataset_with_names_final;
by contributory; run;
data Pokus_4;
set Pokus_3;
trictvrt_sum_du=(sum_du/4)*3;
half_sum_du=sum_du/2; *v t�chto prom�nn�ch m� krit�ria pro dimenzi 2 (v��e shody v sousedstvu);
run;

data Pokus_5;
set Pokus_4;
array as A04--Y87;
array bs du_:;
do i=1 to dim (as);
if bs[i]=1 and sum_du>4 and as[i]>trictvrt_sum_du then
					as[i]=1;
else as[i]=0;
end; 
run;

data Pokus_6;
length dc $8. kapitola_dc $3.;
set Pokus_5;
dc=cats("dc_", contributory);
kapitola_dc=substr(contributory, 1, 1);
*keep dc contributory kapitola_dc du_:;
drop du_: i trictvrt_sum_du half_sum_du sum_du ; run;

proc transpose data=Pokus_6 out=Pokus_7;
by dc; run;
data Pokus_8;
length du $6.;
set Pokus_7;
je_v_siti=col1;
B=_name_;
A=substr(dc, 4);
du=cats("du_", B);
if je_v_siti=1 and A ne B;
keep A B je_v_siti du dc; run;


PROC EXPORT DATA= WORK.Pokus_6
            OUTFILE= "G:\M�j disk\DP\zbytek\B\memory\sas v�stupy\Bimodal
_try_adjacency.csv" 
            DBMS=CSV REPLACE;
     PUTNAMES=YES;
RUN;






*Vymysli import;

*_________________________________________________________________________________________________________________________
 POH�EBI�T�;

*pokus o ud�l�n� du na du;

data Krok_1;
set Undirected_cdai_try;
keep contributory underlying duc; run;

proc sort data=Krok_1; by underlying contributory; run;
proc transpose data=Krok_1 out=Krok_2 name=duc; id contributory; by underlying; run;

proc stdize data=Krok_2 out=Krok_3 reponly missing=0;
var dc_:;
run;
* V souboru Krok_4 m� jako�e matici s popisama ��dk� a sloupc�;
data Krok_3;
set Krok_3;
drop duc _LABEL_; run;
*p�epusuje� po�ty lid�, co maj duc na 1 a 0;
data Krok_4;
set  Krok_3;
array as _numeric_;
do i=1 to dim(as);
if as[i]>0 then do; as[i]=1; end;
if as[i]=0 then do; as[i]=0; end;
end; 
drop i; run;

* D�v� Krok_4 do objektu formy matice;
proc iml;
use Krok_4; 
read all var _NUM_ into A; *v iml objektu A m� soubor Krok_4 ale ve form� matice (sloupce jsou underlying, ��dky contributory);
At = A`; *transponuje� A;
*print A; *tohle rad�eji nespou�t�j -> p��li� velk�;
*print At; *tohle rad�eji nespou�t�j -> p��li� velk�;
AAt = A * At;
print AAt;
create Mat_dataset from AAt;
append from AAt;
close Mat_dataset; * m� soubor, ke kter�mu bude� pak p�ind�vat n�zvy sloupc� a ��dk�;

*M� dva soubory, v nich� m� n�zvy sloupc� a ��dk�, co chce� p�idat k matici;
proc contents data=Krok_3 out=Col_names (keep=name);
run;
data Col_names;
set Col_names; 
ID=_n_;
if name ne "underlying"; run;
data Row_names;
set Krok_3;
name=underlying;
ID=_n_;
keep ID name; run;
*Jak p�indat n�zvy prom�nn�ch m�sto col1 atd?;
proc contents data=Mat_dataset out=Col_names_old (keep=name);
run;
data Col_names_old;
set Col_names_old;
ID=_n_; run;
data Col_names_both;
merge Row_names (rename=(name=new_name))
      Col_names_old(rename=(name=old_name));
by ID; run;

data Col_names_both_try;
length new_name_short $3.;
set Col_names_both;
new_name_short=substr(new_name, 4, 3);
run;

PROC SQL;
	SELECT CATX("=", old_name, new_name_short)
		INTO :LIST_RENAME SEPARATED BY " "
		FROM WORK.Col_names_both_try;
QUIT;
 
%PUT &=LIST_RENAME.;
PROC DATASETS LIB=WORK;
	MODIFY Mat_dataset;
	RENAME &LIST_RENAME.;
RUN;

data Mat_dataset;
set Mat_dataset;
ID=_n_; run;
data Mat_dataset_with_names;
merge Mat_dataset
      Col_names_both_try;
by ID; run;

data Mat_dataset_with_names_final;
length underlying $3.;
set Mat_dataset_with_names;
underlying=new_name_short;
drop ID new_name old_name new_name_short; run;


proc transpose data=Mat_dataset_with_names_final out=List_dc;
by underlying; run;

data List_dc;
set List_dc (rename=(underlying=du1 _name_=du2 col1=N_spolecnych_dc));
label du2="du2";
run;

data List_dc_A;
set List_dc;
if du1=du2 then do;
N_dc_celkem=N_spolecnych_dc; end;
else do; N_dc_celkem=""; end; run;
data List_dc_A;
set List_dc_A;
if du1=du2 then do; poradi=1; end;
else do; poradi=2; end; run;
proc sort data=List_dc_A out=List_dc_B; by du1 poradi du2; run;

data List_dc_C;
set List_dc_B;
by du1;
if first.du1 then N_dc_sum=N_dc_celkem;
else N_dc_sum=coalesce(N_dc_celkem, N_dc_sum);
retain N_dc_sum;
run;

data List_dc_D;
set List_dc_C;
half_N_dc_sum=N_dc_sum/2;
tri_ctvrte_N_dc_sum=(N_dc_sum/4)*3;
drop N_dc_celkem poradi; run;

proc means data=List_dc_D p50 p75 p90; var N_dc_sum; run;

data See;
set List_dc_D;
A=du1; B=du2;
if du1 ne du2 and N_spolecnych_dc>tri_ctvrte_N_dc_sum and N_dc_sum>5; run;

data Je_v_siti;
length je_v_siti $3.;
set List_dc_D;
A=du1; B=du2;
if du1 ne du2 and N_spolecnych_dc>tri_ctvrte_N_dc_sum and N_dc_sum>5 then je_v_siti="ano"; 
else je_v_siti="ne"; run;

proc freq data=Je_v_siti;
table je_v_siti; run;

proc means data=Je_v_siti n min max mean p25 p50 p75 maxdec=2;
class je_v_siti;
var N_spolecnych_dc N_dc_sum;
run;

*Do trval� knihovny pos�l� soubor s jenom signifikantn�ma vazbama a d�l� d�l�� kosmetick� �pravy k tomu;
data Nova.Vystupni_soubor_prev_duc_select;
set Undirected_CDAI;
if sig_CDAI="sig" and duc>10; 
where B in ("I25" "G30" "J44" "F03" "C34" "I21" "I50" "C50" "I64" "J18" "E14" "A41" "I11" "C18" "C25" "I48" "N18"
			"C56" "C80" "I10" "G20" "E11" "I69" "I67"); * asi to bude� d�lat tak, �e bude� br�t jenom ty uderlying causes, co jsou ty nej�ast�j�� v tom dan�m roce;
label duc="duc";
label dc="dc";
label du="du"; run;

*Co� takhle t�eba br�t jenom ty, co maj� signifikantn� vazby a z�rove� prevalence t� dvojice p�evy�uje 1 na 100 000 zem�el�ch lid�?
-> tohle nefunguje
-> mus� v t� fin�ln� s�ti pak rozli�it dc a du
-> nechce� t�eba vymyslet digraph, nebo sm�rovanou d�lat i tady?;

proc means data=Undirected_CDAI p75 p50 p90; var duc; run;

data Undirected_CDAI_duc;
set Undirected_CDAI;
if duc>2; run;
