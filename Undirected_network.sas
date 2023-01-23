*Koukej se;
proc print data=Nova.Bimodal_cdai_m75;
var underlying contributory du dc duc;
where contributory in ("dc-H40" "dc-F25"); run;

data vidim; set Mort_partII;
where ucod="F54" and sex="F"; run;

libname Nova "G:\Mùj disk\DP\zbytek\B\memory\sas výstupy";
libname Database "G:\Mùj disk\DP\zbytek\B\memory\sas data";
*______________________________________________________________________________________________________________________________________________
 VÝBÌR CÍLOVÉ POPULACE PODLE ZADANÝCH PARAMETRÙ + ZÁKLADNÍ OPERACE NA DATÁCH (PØESUNY, RECODY);

%LET rok=Mort_2018; *Zadej název souboru z jakého roku chceš dìlat analýzu ve tvaru Mort_XXXX;
%LET sex=F; *Zadej pohlaví M/F;
%LET od=0;%LET do=101; *Zadej vìkové rozmezí od–do (min=0, max=100)-> nehejbej s tim, CDAI poèítáš za celou populaci;
%LET stan_dolni_mez=0; %LET stan_horni_mez=100; *Zadej si vìkové rozmezí, pro úpravu standardní populace. Platí hodnoty: 0,1,5..(n+5)...100
Když dáš tøeba 1, máš tam vìky 1-4, když 5, tak 5-9.Obì meze se zapoèítavají do vìkového intervalu
(tøeba když zadáš 0-10, budeš tam mít lidi 0-14)

*Pøesun datasetu mezi libraries ;
proc copy in=database out=work memtype=data;
select &rok;
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
*Výbìr zadaného pohlaví;
data &rok;
set &rok;
where sex="&sex"; run;
*Pøepis vìku;
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
*Selekce zadaného vìku;
data &rok;
set &rok;
where age_want>=&od and age_want<&do; run;

*Odmazáváš kódy z první èásti hlášení, budeš tam mít jenom UCOD a pøíèiny v Part II;
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
*Pøepisuješ kody na tøechmístný;
data Mort_partII; 
length enicon_1-enicon_20 ucod $3.;
set Mort_partII; run;

*Recoduješ vìk v jednotkách do 5 letých skupin -> nejde to napsat krátš?
 Tvoje nová promìnná age_numeric obsahuje hodnoty, které jsou ve sloupci age_numeric v souboru se standardem, který budeš záhy importovat;
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
MANIPULACE S DATAMA - UTVÁØENÍ DVOJIC MEZI UCOD A kody v Part II;

*Celkový poèet kódù uvedených v Part II; 
data Mort_partII;
 set Mort_partII;
 	totmiss=cmiss(of enicon_1-enicon_20);
 	totnonmiss=20- cmiss(of enicon_1-enicon_20);
run;
*Pøiøazuješ ID k pozorování;
data Mort_partII;
set Mort_partII;
ID=_n_;
run;

*Pøipisuješ ucod øádek výskytu, abys pak mohla podle nìho vyhledávat ucod  mezi všema pøíèinama;
data Mort_partII;
length enicon_21 $3. econdp_21 5;
set Mort_partII;
enicon_21=ucod;
econdp_21=99; run;

*Duplikuješ info o øádcích, abys mohla uskuteènit Sag_2;
data Sag_1;
set Mort_partII;
array as econdp_1-econdp_21;
array bs econdp2_1-econdp2_21;
do i=1 to dim(as);
bs[i]=as[i]; end;
run;

*Utvoøuješ dvojice;
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

*Odstraòuješ redundantní páry - ve finále ti tam zbyde u každého èlovìka jenom pøíèina z Part II v sloupci A spárovaná s jeho UCOD,
která je uvedená v sloupci B, nesleduješ páry mezi pøíèinama v Part II mezi sebou!! Chceš totiž asociace vyjadøovat s UCOD a tam tì zajímaj
jenom dvojice underlying (tvùj sloupec B)+contributory (tvùj sloupec A)
-> po tomhlectom kroce ti vypadnou lidi co nemaj žádný caontributory causes -> vadí ti to?;
data Sag_3;
set Sag_2;
if C=6 and D=99; run;

*Poèítáš výskyty dvojic v rámci jedné vìkové kategorie;
proc sort data=Sag_3; by age_numeric; run;
proc freq data=Sag_3 noprint;
by age_numeric;
tables A*B/ norow nocol nopercent out=Sag_4;
run;
*Upravuješ dataset s poèetama dvojic;
data Sag_4;
set Sag_4;
duc=count; *duc jako deaths at age x (age_numeric) with underlying cause u and contributing cause c;
drop count percent; run;
proc sort data=Sag_4; by descending duc; run;

*Poèítáš du - poèty lidí s stejnou underlying cause. Dìláš to z celého pùvodního datasetu, takže tam máš i ty lidi, co tøeba nemìly
žádnou contributory cause;
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

*Poèítáš dc - poèty lidí podle contributory cause. Zase to dìláš z pùvodního datasetu;
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

*Dávám dohromady Dc, Du a Sag_4 (tam máš ty poèty dvojic Duc);
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

*Poèítáš reálnou vìkovou strukturu zemøelých, abys pak mohla pøidat promìnnou d (celkový poèet zemøelých ve vìku x);
proc sort data=Mort_partII; by age_numeric; run;
proc means data=Mort_partII n noprint;
by age_numeric;
var age_numeric;
where age_numeric>=&stan_dolni_mez and age_numeric<=&stan_horni_mez; *useless statement;
output out=Real_pop n=Population;
run;
*V promìnné Population máš dx;
data Undirected;
merge Duc_Dc_Du Real_pop;
by age_numeric;
d=Population;
drop _TYPE_ _FREQ_ Population; run;

*_____________________________________________________________________________________________________________
 VÝPOÈET MÌR ASOCIACE (CDAI);
*Import souboru se standardem (bereš Popstand2013 od MP -> europskej?)
-> v tomto souboru musíš mít prom age_numeric, která je zakodovaná podle syntaxe pro vytváøení promìnné age_numeric povýš zde;
PROC IMPORT OUT= WORK.Standard_pop 
            DATAFILE= "G:\Mùj disk\DP\zbytek\Popstand2013.xlsx" 
            DBMS=EXCEL REPLACE;
     RANGE="Foglio2$"; 
     GETNAMES=YES;
     MIXED=NO;
     SCANTEXT=YES;
     USEDATE=YES;
     SCANTIME=YES;
RUN;
*Pøindáváš sloupec s standardní populací do souboru, kde budeš následnì poèítat CDAI;
data Undirected;
merge Undirected Standard_pop;
by age_numeric;
run;

*Poèítáš hoøejšek a dolejšek zlomku pro CDAI;
data Undirected;
set Undirected;
sum_popstan=100000;
horejsek=(duc/du)*Popstan/sum_popstan;
dolejsek=(dc/d)*Popstan/sum_popstan; *pøekontroluj, jestli máš v dc skuteènì contributory a v du skuteènì ucod;
horejsek_pro_IS=((Popstan/sum_popstan)**2)*(duc/(du**2));
dolejsek_pro_IS=((duc/du)*(Popstan/sum_popstan));
run;

*Posèítáváš hoøejšky a dolejšky CDAI a fragmenty, z kterých budeš skládat intervaly spolehlivostì v rámci jedné dvojice A B;
proc summary nway data=Undirected noprint; *Nway proè;
var horejsek dolejsek horejsek_pro_IS dolejsek_pro_IS;
class A B;
output out=Undirected_CDAI sum=;
run;
*Dopoèítáváš kompletní CDAIu,c a intervaly spolehlivosti v jednotkách na 100 000 asi;
data Undirected_CDAI;
length sig_CDAI $5.;
set Undirected_CDAI;
CDAI=(horejsek/dolejsek); *máš to jakože na 100 000 obyvatel?;
SE_log_CDAI=(horejsek_pro_IS/(dolejsek_pro_IS**2))**(1/2);
IS_dolni_mez=exp(log(CDAI-1.96*SE_log_CDAI));
IS_horni_mez=exp(log(CDAI+1.96*SE_log_CDAI));
ln_CDAI=log(CDAI);
if IS_dolni_mez>1 and IS_horni_mez>1 then sig_CDAI="sig"; *signifikantní vazby jsou jenom ty, které jsou nad 100 celým SI;
else sig_CDAI="nesig";
drop _type_ _freq_;
run;
*Pokud CDAI je signifikantnì vìtší než 100, tak je ta asociace více se objevující,
než by tomu bylo za pøedpokladu platnosti nezávislostì tìch dvou pøíèin;

*Poèítáš výskyty tìch kodù -> nemùžeš to dìlat z Duc_dc_du;
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
*Dáváš dohromady všechny ty výskyty duc, dc, du s tím datasetem, kde máš spoètený CDAI
-> nemùžeš úspornìjic? -> vyøeš to;
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
*Nechceš si odmazat tì vazby, co jsou sice signifikantní, ale patøí tøeba do dolního decilu (že maj prostì výskyt tøeba míò èastej než 5)?;

*Do trvalé knihovny posíláš soubor s jenom signifikantníma vazbama a dìláš dílèí kosmetický úpravy k tomu;
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

*Poèítáš prevalence duc, dc, du (relativizuješ souètem);
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
if _n_=1 then set DC_sum(keep=sum_dc); *vychází ti to podezøele;
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
*Posíláš 25% vazeb s vyšším Nij do trvalé knihovny;
data Undirected_CDAI_see;
set See2;
if duc>p90;
drop p90;
run;

data Undirected_CDAI_try; *useless kód, že jo;
set Undirected_CDAI_see;
if CDAI>1; run;

data Nova.Bimodal_CDAI_z75;
set Undirected_CDAI_try; run;

*Na konci tohohle syntaxu máš matici contributory na conrtibutory, ale musíš si pøekontrolovat, jsetli se ti pøiøadìly 
 správnì názvy tìch sloupcù a øádkù
-> v souboru Mat_dataset_with_names_final máš na diagonále kolik celkem duc z souboru Undrirected_CDAI_try má ty prvky jako
   dc (takže si to zkontroluj)
-> a mimo diagonálu máš na kolik celkem se pojí du spolu s tìma prvkama mimo diagonálu
-> kontroly prosím -> vyøeš to!!!!;

*______________________________________________________________________________________________________________________
 ZEÈTVERCOVATÌNÍ MATICE DC NA DU 
 -> dìláš to, abys pak mohla udìlat tì bimodální sítì (dc na sebe se vážou/ du na sebe se vážou;

data Krok_1;
set Undirected_cdai_try;
keep contributory underlying duc; run;

proc transpose data=Krok_1 out=Krok_2 name=duc; id underlying; by contributory; run;

proc stdize data=Krok_2 out=Krok_3 reponly missing=0;
var du_:;
run;
* V souboru Krok_4 máš jakože matici s popisama øádkù a sloupcù;
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
data Krok_3_1_dc; *list s originálníma pøíèinama (pouze ty, co je objevovaly v signifikantním souboru);
set Krok_3;
name=substr(contributory, 4,3);
keep name contributory;
run;
*v prom name máš vìci na pøípadné párování;

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
*Pøidáváš øádky;
data Krok_3_3;
set Krok_3_2_du_navic (drop=underlying) Krok_3 (drop=contributory);
run;
*Transponuješ pøíèiny nejsoucí v dùsledcích a pøidáváš je jako sloupce;
proc transpose data=Krok_3_2_dc_navic out=Krok_3_4 prefix=du_;
id name;run;
data Krok_3_5;
set Krok_3_4 Krok_3_3;
run;
*useless úpravy;
data Krok_3_5;
length name $3.;
set Krok_3_5;
drop _name_ ; run;
proc sort data=Krok_3_5; by name; run;
*Øadim sloupce podle alfabetu;
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
contributory=cats("dc_", name); * v téhle souboøe máš ètvercovou matici dc x du, seøazené podle abc -> TOHLE JE DÙLEŽITÝ PROSÍM TÌ!!!;
run;

*pøepusuješ poèty lidí, co maj duc na 1 a 0;
data Krok_4;
set  Krok_3_9;
array as _numeric_;
do i=1 to dim(as);
if as[i]>0 then do; as[i]=1; end;
if as[i]=0 then do; as[i]=0; end;
end; 
drop i; run;


*______________________________________________________________________________________________________
 MATICOVÉ POÈTY (viz papirek, prostì pøendáváš to na dc x dc) -> TADY!!! VŠIMNI SI, ŽE JE TO DC NA DC;

*Dáváš Krok_4 do objektu formy matice;
proc iml;
use Krok_4; 
read all var _NUM_ into A; *v iml objektu A máš soubor Krok_4 ale ve formì matice (sloupce jsou underlying, øádky contributory);
At = A`; *transponuješ A;
*print A; *tohle radšeji nespouštìj -> pøíliš velký;
*print At; *tohle radšeji nespouštìj -> pøíliš velký;
AAt = A * At;
*print AAt;
create Mat_dataset from AAt;
append from AAt;
close Mat_dataset; * máš soubor, ke kterému budeš pak pøindávat názvy sloupcù a øádkù;

*Máš dva soubory, v nichž máš názvy sloupcù a øádkù, co chceš pøidat k matici;
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
*Jak pøindat názvy promìnných místo col1 atd?;
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

proc freq data=List_dc_d noprint; * jenom for sure se kouknout jestli ti tøeba míry polohy nevycházej náhodou jináè,
									když béøeš jenom originální poèety -> asi pøekvapivì ok;
table dc1*N_du_sum/ nocol norow nopercent out=List_dc_e; run;
proc sort data=List_dc_e nodup out=List_dc_f; by dc1; run;
data List_dc_f; set List_dc_f; drop count percent; run;

proc means data=List_dc_f p50 p75 p90; var N_du_sum; run; 

data Dc_sousedi;
set List_dc_D;
A=dc1; B=dc2;
if dc1 ne dc2 and N_spolecnych_du=>half_N_du_sum and N_du_sum=>4; run; *UPDEJTUJ!!!!
* chceš spoleènou vìtšinu? tohle: N_spolecnych_du>half_N_du_sum;

*Níže kódem si ponecháváš jenom ty vazby, kde jsou ty podmínky splnìny z obouch stran
 (tzn. víc jak polovina spoleèných sousedù od obou uzlù);
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
*v soubøe Dc_paralel_3_1 máš ty vazby, který jsou reciproký;
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
 MATICOVÉ POÈTY (viz papirek, prostì pøendáváš to na du x du) -> TADY!!! VŠIMNI SI, ŽE JE TO DU NA DU;

proc transpose data=Krok_3_9 out=Krok_3_9_1 name=underlying; id contributory;  run;
data Krok_3_9_1;
length name $6.;
set Krok_3_9_1;
name=substr(underlying, 4, 3);
run;

*pøepusuješ poèty lidí, co maj duc na 1 a 0;
data Krok_4;
set  Krok_3_9_1;
array as _numeric_;
do i=1 to dim(as);
if as[i]>0 then do; as[i]=1; end;
if as[i]=0 then do; as[i]=0; end;
end; 
drop i; run;

*Dáváš Krok_4 do objektu formy matice;
proc iml;
use Krok_4; 
read all var _NUM_ into A; *v iml objektu A máš soubor Krok_4 ale ve formì matice (sloupce jsou underlying, øádky contributory);
At = A`; *transponuješ A;
*print A; *tohle radšeji nespouštìj -> pøíliš velký;
*print At; *tohle radšeji nespouštìj -> pøíliš velký;
AAt = A * At;
*print AAt;
create Mat_dataset from AAt;
append from AAt;
close Mat_dataset; * máš soubor, ke kterému budeš pak pøindávat názvy sloupcù a øádkù;

*Máš dva soubory, v nichž máš názvy sloupcù a øádkù, co chceš pøidat k matici;
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
*Jak pøindat názvy promìnných místo col1 atd?;
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
* chceš spoleènou vìtšinu? tohle: N_spolecnych_du>half_N_du_sum;

*Níže kódem si ponecháváš jenom ty vazby, kde jsou ty podmínky splnìny z obouch stran
 (tzn. víc jak polovina spoleèných sousedù od obou uzlù);
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
*v soubøe Du_paralel_3_1 máš ty vazby, který jsou reciproký;
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
 VYTVÁØENÍ SOUBORÙ NA IMPORT DO GEPHI (NA INDIVINDI SÍ JENOM S DC, ÈI INDIVINDI SÍ JENOM S DU);
*viz zvláštní program;
















*____________________________________________________________________________________________________________________
 POHØEBIŠTÌ;

*Vytváøení dat na sí s dc i du dohromady;
* Bereš soubor, kde už máš omezení na duc (>p90, tj. 1=duc splòuje tuto podmínku, 0=nesplòuje);
data Pokus_1;
set Krok_4;
sum_du = sum(of du_A04--du_Y87); *kolik celkem má ta dc v øádku du sousedù;
run;
data Pokus_2;
set Pokus_1;
contributory=substr(contributory, 4);
run;
data Pokus_3; * promìnné bez prefixu du_ jsou dc a dg této èástì matice je rovna sloupci sum_du;
merge Pokus_2 Mat_dataset_with_names_final;
by contributory; run;
data Pokus_4;
set Pokus_3;
trictvrt_sum_du=(sum_du/4)*3;
half_sum_du=sum_du/2; *v tìchto promìnných máš kritéria pro dimenzi 2 (výše shody v sousedstvu);
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
            OUTFILE= "G:\Mùj disk\DP\zbytek\B\memory\sas výstupy\Bimodal
_try_adjacency.csv" 
            DBMS=CSV REPLACE;
     PUTNAMES=YES;
RUN;






*Vymysli import;

*_________________________________________________________________________________________________________________________
 POHØEBIŠTÌ;

*pokus o udìlání du na du;

data Krok_1;
set Undirected_cdai_try;
keep contributory underlying duc; run;

proc sort data=Krok_1; by underlying contributory; run;
proc transpose data=Krok_1 out=Krok_2 name=duc; id contributory; by underlying; run;

proc stdize data=Krok_2 out=Krok_3 reponly missing=0;
var dc_:;
run;
* V souboru Krok_4 máš jakože matici s popisama øádkù a sloupcù;
data Krok_3;
set Krok_3;
drop duc _LABEL_; run;
*pøepusuješ poèty lidí, co maj duc na 1 a 0;
data Krok_4;
set  Krok_3;
array as _numeric_;
do i=1 to dim(as);
if as[i]>0 then do; as[i]=1; end;
if as[i]=0 then do; as[i]=0; end;
end; 
drop i; run;

* Dáváš Krok_4 do objektu formy matice;
proc iml;
use Krok_4; 
read all var _NUM_ into A; *v iml objektu A máš soubor Krok_4 ale ve formì matice (sloupce jsou underlying, øádky contributory);
At = A`; *transponuješ A;
*print A; *tohle radšeji nespouštìj -> pøíliš velký;
*print At; *tohle radšeji nespouštìj -> pøíliš velký;
AAt = A * At;
print AAt;
create Mat_dataset from AAt;
append from AAt;
close Mat_dataset; * máš soubor, ke kterému budeš pak pøindávat názvy sloupcù a øádkù;

*Máš dva soubory, v nichž máš názvy sloupcù a øádkù, co chceš pøidat k matici;
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
*Jak pøindat názvy promìnných místo col1 atd?;
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

*Do trvalé knihovny posíláš soubor s jenom signifikantníma vazbama a dìláš dílèí kosmetický úpravy k tomu;
data Nova.Vystupni_soubor_prev_duc_select;
set Undirected_CDAI;
if sig_CDAI="sig" and duc>10; 
where B in ("I25" "G30" "J44" "F03" "C34" "I21" "I50" "C50" "I64" "J18" "E14" "A41" "I11" "C18" "C25" "I48" "N18"
			"C56" "C80" "I10" "G20" "E11" "I69" "I67"); * asi to budeš dìlat tak, že budeš brát jenom ty uderlying causes, co jsou ty nejèastìjší v tom daném roce;
label duc="duc";
label dc="dc";
label du="du"; run;

*Což takhle tøeba brát jenom ty, co mají signifikantní vazby a zároveò prevalence té dvojice pøevyšuje 1 na 100 000 zemøelých lidí?
-> tohle nefunguje
-> musíš v tý finální síti pak rozlišit dc a du
-> nechceš tøeba vymyslet digraph, nebo smìrovanou dìlat i tady?;

proc means data=Undirected_CDAI p75 p50 p90; var duc; run;

data Undirected_CDAI_duc;
set Undirected_CDAI;
if duc>2; run;
