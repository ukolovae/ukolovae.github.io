*_____________________________________________________________________
*Filtering techniques
*---------------------------------------------------------------------
*V tomhlenctom programu budeš mít utvoøení dvojic chorob z promìnných record_XX a výpoèet fij a OER resp. RR.

*Define library where output files with edges and nodes lists for import to Gephi will be stored;
libname Nova "G:\Mùj disk\DP\zbytek\B\memory\sas výstupy";
*Define library where file from CDC is stored;
libname Database "G:\Mùj disk\DP\zbytek\B\memory\sas data"; 

%LET rok=Mort_2019; *Name of file downloaded from CDC or NBER in format Mort_XXXX;
%LET sex=F; *Sex option: M/F;
%LET od=0;%LET do=101; *Age option from-to (min=0, max=100);



%see(Mort_2018, F, 0, 20)
%see(Mort_2018, F, 20, 35)
%see(Mort_2018, F, 35, 50)
%see(Mort_2018, F, 50, 65)
%see(Mort_2018, F, 65, 80)
%see(Mort_2018, F, 80, 101)



%macro see(rok, sex, od, do);
*______________________________________________________________________________________________________________________________________________
 SELECTION OF POPULATION by year of death, age and sex parameters and some recodes;

*proc copy in=database out=work memtype=data;
*select &rok;
*run;
data &rok;
length sex_recode $1.;
set Database.&rok;
if datayear<100 or year<=2002 then do;
	if sex=1 then sex_recode="M";
	if sex=2 then sex_recode="F";
if datayear>=100 or year>2002 then do;
	sex_recode=sex; end;
drop sex; end;
run;
data &rok; length sex $1.; set &rok; sex=sex_recode; if sex_recode="&sex"; drop sex_recode; run;
data &rok;
set &rok;
if datayear<100 or year<=2002 then do; *for 1980-2002;
	if age<100 then age_want=age;
	if age>=100 and age<200 then age_want=100;
	if age>=200 then age_want=0;
	if age=999 then age_want="."; end;
if datayear>=100 or year>2002 then do; *for 2003-2019;
	x= put(age, 4.);
	age_want = input(substr(x,2,3),4.);
	if age>1135 then age_want=0;
	if age=>1100 and age<=1135 then age_want=100;
	if age=999 then age_want=".";
	drop x; end;
run;
data &rok;
set &rok;
where age_want>=&od and age_want<&do; run;

data Mort; 
length record_1-record_20 ucod $3.;
set &rok; run;

*___________________________________________________________________________________________________________________________________________
 FORMATION OF DISEASE PAIRS;
*Add ID to each obs;
data Step_1;
set Mort;
ID=_n_;
keep ID record_: ranum;
run;

*All possible disease pairs;
data Step_2;
set Step_1;
array as record_1-record_20;
array bs record_1-record_20;
do i=1 to dim(as);
do j= 1 to dim(bs);
if as[i]~=("") and bs[j]~=("")  then do;
         A=(as[i]);
         B=(bs[j]);
output;
end; end; end;
keep a b id ranum; run;

*Erase self-loops;
data Step_2;
set Step_2;
if A=B then delete; run;

*Count same disease pairs (Nij in contingency tables) -> these pairs define raw network;
proc freq data=Step_2 noprint;
label Nij="Nij";
tables A*B/out=Nij (rename=(count=Nij)) norow nocum nocol nopercent;
run;
*Count occurences of same causes and consequences (Ni and Nj in contingency tables);
proc freq data=Step_2 noprint;
tables A/ norow nocol nopercent out=Ni (rename=(count=Ni));
run;
proc freq data=Step_2 noprint;
tables B/ norow nocol nopercent out=Nj (rename=(count=Nj));
run;
*Create dataset Step_3, where Nij, Ni and Nj are merged together;
proc sort data=Nij; by A; run;
proc sort data=Ni; by A; run;
data Nij_Ni;
merge Nij Ni;
by A; drop percent; run;
proc sort data=Nij_Ni; by B; run;
proc sort data=Nj; by B; run;
data Nij_Ni_Nj;
label Ni="Ni" Nj="Nj";
merge Nij_Ni Nj;
by B; drop percent; run;
proc sort data=Nij_Ni_Nj; by descending Nij; run;
*___________________________________________________________________________________________________________________________
 DETERMINING STRENGTH OF ASSOCIATIONS BETWEEN CAUSES AND CONSEQUENCES (and prevalences of desease pairs);
proc sql;
create table Num_obs as
select count(*) as N from &rok;
quit;
data Raw;
set Nij_Ni_Nj;
if _n_=1 then set Num_obs(keep=N);
run;
data Raw;
length sig_fij sig_OR $5. A B $3.;
set Raw; 
*Fields of contingency tables;
	Ninonj=Ni-Nij;
	Nnonij=Nj-Nij;
	Nineboj=Ni+Nj-Nij;
	Nnoninonj=N-Nij;
	Nnoni=N-Ni;
	Nnonj= N-Nj;
*Fij as from Hidalgo et al. (2008);
	fij=(Nij*Nnoninonj-Ninonj*Nnonij)/((Ni*Nnoni*Nj*Nnonj)**(1/2));
	if fij<0 then fij=0;
	if Ni=>Nj then m=Ni;
	if Ni<Nj then m=Nj;
	t_fij=(fij*(m-2)**(1/2))/((1-fij**2)**(1/2));
	if (t_fij>-2.58) and (t_fij<2.58) then sig_fij="nesig";
		else sig_fij="sig";
*OR as from Kim et al. (2016);
	OR=(Nij/Nnonij)/(Ninonj/Nnoninonj);
	lower_CI_OR=exp(log(OR)-2.58*((1/Nij+1/Ninonj+1/Nnonij+1/Nnoninonj)**(1/2)));
	upper_CI_OR=exp(log(OR)+2.58*((1/Nij+1/Ninonj+1/Nnonij+1/Nnoninonj)**(1/2)));
	if lower_CI_OR>5 and upper_CI_OR>5 then sig_oR="sig"; else sig_OR="nesig";
*Count prevalences;
	prev_Ni=Ni/N;
	prev_Nj=Nj/N;
	prev_Nij=Nij/N;
* pij;
	pij=Nij/Ni;
ID=_n_;
run;

data Raw&od._&do.;
set Raw;
run;
%mend see;

data Raw0_20; length skup $6.; set Raw0_20; skup_num=1; skup="0_20"; drop ID; run;
data Raw20_35; length skup $6.; set Raw20_35; skup_num=2; skup="20_35"; drop ID; run;
data Raw35_50; length skup $6.; set Raw35_50; skup_num=3; skup="35_50"; drop ID; run;
data Raw50_65; length skup $6.; set Raw50_65; skup_num=4; skup="50_65"; drop ID; run;
data Raw65_80; length skup $6.; set Raw65_80; skup_num=5; skup="65_80"; drop ID; run;
data Raw80_101; length skup $6.; set Raw80_101; skup_num=6; skup="80_101"; drop ID; run;

data Raw;
set Raw0_20 Raw20_35 Raw35_50 Raw50_65 Raw65_80 Raw80_101; run;

data Try1;
set Raw;
keep skup A B pij;
run;
proc sort data=Try1; by A B; run;
proc transpose data=Try1 out=Try2 prefix=pij;
id skup;
by A B;
var pij; run;
data Try2;
   set Try2;
   array change _numeric_;
        do over change;
            if change=. then change=0;
        end;
 run ;
 data Try3;
 set Try2;
 delta2_1=pij20_35-pij0_20;
 delta3_2=pij35_50-pij20_35;
 delta4_3=pij50_65-pij35_50;
 delta5_4=pij65_80-pij50_65;
 delta6_5=pij80_10-pij65_80; run;
*Add prevalence;
 data Try4;
set Raw;
keep skup A B prev_Ni;
run;
proc sort data=Try4; by A B; run;
proc transpose data=Try4 out=Try5 prefix=prev;
id skup;
by A B;
var prev_Ni; run;

data Try6;
merge Try3 Try5;
by A B; run;

data Try6;
   set Try6;
   array change _numeric_;
        do over change;
            if change=. then change=0;
        end;
 run ;

*Vyraz v sume;
data Try7;
set Try6;
vyraz1=delta2_1*prev0_20;
vyraz2=delta3_2*prev20_35;
vyraz3=delta4_3*prev35_50;
vyraz4=delta5_4*prev50_65;
vyraz5=delta6_5*prev65_80;
run;
*Performing sum over j (B) in the diffusion model in Chmiel et al;
proc sql;
create table Try8 as 
    select *, sum(vyraz1) as sum1, sum(vyraz2) as sum2, sum(vyraz3) as sum3, sum(vyraz4) as sum4, sum(vyraz5) as sum5
    from Try7
    group by A;
quit;

*Prev Ni do stejne podoby jako predtim prev Nj;
data Try9;
set Raw;
keep skup A B prev_Nj;
run;
proc sort data=Try9; by A B; run;
proc transpose data=Try9 out=Try10 prefix=prevN;
id skup;
by A B;
var prev_Nj; run;

proc sort data=Try10; by A B; run;
proc sort data=Try8; by A B; run;
*Merge prev_Ni k ostatnim (tomu výrazu v sumì zejména);
data Try11;
merge Try8 Try10;
by A B; run;

data Try11;
   set Try11;
   array change _numeric_;
        do over change;
            if change=. then change=0;
        end;
 run ;

*Výpoèet pi_hat (odhadu prevalence);
data Try11;
set Try11;
pihat2= prevN0_20+(1-prevN0_20)*sum1;
pihat3= prevN20_35+(1-prevN20_35)*sum2;
pihat4= prevN35_50+(1-prevN35_50)*sum3;
pihat5= prevN50_65+(1-prevN50_65)*sum4;
pihat6= prevN65_80+(1-prevN65_80)*sum5;
run;

proc corr data=Try11 out=Try12 spearman outs=CC;
var pihat2 prev20_35  pihat3 prev35_50  pihat4 prev50_65 pihat5 prev65_80 pihat6 prev80_10;run;




*Check - descriptives of measures of association;
proc means data=Raw min max mean;
var fij OR pij; run;
data Raw;
set Raw;
log_fij=log(fij);
log_pij=log(pij);
log_OR=log(OR);
run;
proc univariate data=Raw;
var log_fij log_pij log_OR;
histogram log_fij;
histogram log_pij;
histogram log_OR;
run;

proc freq data=Raw;
table sig_fij*sig_OR; run;




*__________________________________________________________________________________________________
 PREPAIRING DATA FOR IMPORT TO GEPHI;
data OR_fij_raw;
length A B $3.;
set Raw;
run;
data result_fij;
set Raw;
if sig_fij="sig"; run;
data result_OR;
set Raw;
if sig_OR="sig"; run;

%let soubor=OR_fij_raw; * select the file you want to use, Options: OR_fij_raw, result_fij, result_OR

*NODES SHEET;
proc sql ;
create table Nodup_A as
	select DISTINCT (A), prev_Ni
	from &soubor order by A;
create table Nodup_B as
  	select DISTINCT (B), prev_Nj
 	from &soubor order by B;
quit;
data Opora;
merge Nodup_A(rename=(A=Kod))
	  Nodup_B (rename=(B=Kod));
by kod; run;
proc sort data=Opora nodupkey; by kod; run;
data Opora;
length ID 5;
set Opora;
if prev_Ni=. then prev_Ni=0;
if prev_Nj=. then prev_Nj=0;
ID=_n_;
kapitola=substr(kod, 1, 1);
prev=prev_Ni+prev_Nj;
run; 

*EDGE SHEET;
proc sort data = &soubor; by A;run;
proc sort data = Opora ;by kod; run;
data Vlookup_A;
length source 5;
merge &soubor (rename=(A=kod) in=x keep=A B fij OR)
	  Opora (in=y keep=kod id);
by kod;
if x & y;
source=id;
drop id;
run;
data Vlookup_A;
length A $3.;
set Vlookup_A;
A=kod; drop kod; run;
proc sort data = Vlookup_A; by B;run;
data Vlookup_B;
length target 5;
merge Vlookup_A (rename=(B=kod) in=x keep=B A fij OR source)
	  Opora (in=y keep=kod id);
by kod;
if x & y;
target=id;
drop id;
run;
data Edge_list;
length source 5 target 5 A $3. B $3.;
set Vlookup_B;
B=kod;
drop kod; run;
proc sort data=Edge_list; by source target; run;
*Exports of node list and edgelist;
PROC EXPORT DATA= WORK.OPORA 
            OUTFILE= "G:\Mùj disk\DP\zbytek\B\memory\sas výstupy\Nodes_&soubor..csv" 
            DBMS=CSV REPLACE;
     PUTNAMES=YES;
RUN;
PROC EXPORT DATA= WORK.Edge_list
            OUTFILE= "G:\Mùj disk\DP\zbytek\B\memory\sas výstupy\Edges_&soubor..csv" 
            DBMS=CSV REPLACE;
     PUTNAMES=YES;
RUN;


*__________________________________________________________________________________________________
 PREPAIRING DATA FOR IMPORT TO GEPHI FOR OTHER TECHNIQUES THEN FIJ AND OER;
*Import datafile cretaed in R;
*Which file you want to use and where is it stored?;
										%let path="G:\My Drive\DP\zbytek\B\memory\R vìci\all_raw_export.csv";
PROC IMPORT OUT= WORK.all_raw 
            DATAFILE= &path
            DBMS=CSV REPLACE;
     GETNAMES=YES;
     DATAROW=2; 
RUN;
data Raw;
length A B $3.;
set all_raw;
run;
%let soubor=Raw; * select the file you want to use, Options: Raw, result_fij, result_OR

*NODES SHEET;
proc sql ;
create table Nodup_A as
	select DISTINCT (A), prev_Ni
	from &soubor order by A;
create table Nodup_B as
  	select DISTINCT (B), prev_Nj
 	from &soubor order by B;
quit;
data Opora;
merge Nodup_A(rename=(A=Kod))
	  Nodup_B (rename=(B=Kod));
by kod; run;
proc sort data=Opora nodupkey; by kod; run;
data Opora;
length ID 5;
set Opora;
if prev_Ni=. then prev_Ni=0;
if prev_Nj=. then prev_Nj=0;
ID=_n_;
kapitola=substr(kod, 1, 1);
prev=prev_Ni+prev_Nj;
run; 

*EDGE SHEET;
proc sort data = &soubor; by A;run;
proc sort data = Opora ;by kod; run;
data Vlookup_A;
length source 5;
merge &soubor (rename=(A=kod) in=x keep=A B fij OR prev_Nij vetsi_005 alpha_ipfp_out Salience vetsi_tety alpha_df_out)
	  Opora (in=y keep=kod id);
by kod;
if x & y;
source=id;
drop id;
run;
data Vlookup_A;
length A $3.;
set Vlookup_A;
A=kod; drop kod; run;
proc sort data = Vlookup_A; by B;run;
data Vlookup_B;
length target 5;
merge Vlookup_A (rename=(B=kod) in=x keep=B A fij OR source prev_Nij vetsi_005 alpha_ipfp_out Salience vetsi_tety alpha_df_out)
	  Opora (in=y keep=kod id);
by kod;
if x & y;
target=id;
drop id;
run;
data Edge_list;
length source 5 target 5 A $3. B $3.;
set Vlookup_B;
B=kod;
drop kod; run;
proc sort data=Edge_list; by source target; run;
*Exports of node list and edgelist;
PROC EXPORT DATA= WORK.OPORA 
            OUTFILE= "G:\My Drive\DP\zbytek\B\memory\sas výstupy\Nodes_&soubor..csv" 
            DBMS=CSV REPLACE;
     PUTNAMES=YES;
RUN;
PROC EXPORT DATA= WORK.Edge_list
            OUTFILE= "G:\My Drive\DP\zbytek\B\memory\sas výstupy\Edges_&soubor..csv" 
            DBMS=CSV REPLACE;
     PUTNAMES=YES;
RUN;






