
PROC IMPORT OUT= WORK.Med 
            DATAFILE= "G:\Mùj disk\DP\zbytek\Medailiste_OH.xlsx" 
            DBMS=EXCEL REPLACE;
     RANGE="Sheet1$"; 
     GETNAMES=YES;
     MIXED=NO;
     SCANTEXT=YES;
     USEDATE=YES;
     SCANTIME=YES;
RUN;


PROC IMPORT OUT= WORK.Ucast 
            DATAFILE= "G:\Mùj disk\DP\zbytek\Ucastnici_OH.xlsx" 
            DBMS=EXCEL REPLACE;
     RANGE="Sheet1$"; 
     GETNAMES=YES;
     MIXED=NO;
     SCANTEXT=YES;
     USEDATE=YES;
     SCANTIME=YES;
RUN;
data ucast;
set ucast;
t=smrt1-1980;
run;

data med;
set med;
if t>0 or t=.; run;
data ucast;
set ucast;
if t>0 or t=.; run;

data med; set med; if t=. then cens=1; else cens=0; run;
data ucast; set ucast; if t=. then cens=1; else cens=0; run;

