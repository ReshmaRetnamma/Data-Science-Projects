

Libname project "D:\dsc\sas\advanced SAS\pjct";

DATA project.WN;
 INFILE 'D:\dsc\sas\advanced SAS\pjct\New_Wireless_Fixed.txt' truncover;
 INPUT Acctno $ 1-13 Actdt @26 Deactdt  DeactReason $ 41-48 GoodCredit 53-54  RatePlan 62-63 DealerType $ 65-66 Age 74-75 Province 
$ 80-81 Sales DOLLAR11.2 ;
 informat Actdt Deactdt MMDDYY10.;
 format Actdt Deactdt MMDDYY10.;
 FORMAT Sales DOLLAR11.2;

RUN;
data project.tenure_new_all(OBS=100);
  set project.WN;
  if Deactdt eq null then
   Tenure=intck('day',Actdt,TODAY());
  else
   Tenure=intck('day',Actdt,Deactdt);
run;
data project.statusq2(OBS=100);
  length status $ 15;
  set project.WN;
  if Deactdt eq null then
   status='Active';
  else
   status='DeActivated';
run;
data status1(OBS=100);
  set project.WN(keep = Acctno Actdt Deactdt);
  if Deactdt eq null then
   status='Active';
  else
   status='DeAct';
run;
data statusq2(OBS=100);
  set project.WN;
  if Deactdt eq null then
   status='Active';
  else
   status='DeAct';
run;
data project.status3(OBS=100);
 length agegruop $ 15;
set project.status2;
   if       Age  le 20	then  agegruop='less than 20';
   else if  Age  le 41	then  agegruop='between 21-40';
   else if  Age  le 61	then  agegruop='between 41-60';
   else if  Age  gt 61	then  agegruop='more than 60';
		
   if      Sales le 100   then  salesgroup='less than 100';
   else if Sales le 500   then  salesgroup='between 100-500';	 
   else if Sales le 800   then  salesgroup='between 500-800';	 
   else if Sales gt 800   then  salesgroup='more than 800';	
run;
proc print data=project.status3(obs=5);
run;
*Q1 (a). Explore and describe the dataset briefly or(PROPERITIES OF A DATA SET(Browsing decriptor portion));
         *To obtain a list of all of the columns in a table and their attributes, you can use the DESCRIBE 
          TABLE statement.;
proc contents data = project.WN;
   title  'The Contents of the New_Wireless_Fixed Data Set';
run;
PROC SQL;
 DESCRIBE TABLE project.WN;
QUIT;

/*1.1a Is accno unique? */

PROC SQL;
title "number of unique account numbers";
 SELECT COUNT(DISTINCT Acctno) AS Number_of_unique_Acctno,COUNT(Acctno) AS Number_of_all_Acctno
 FROM project.WN
 ;
 QUIT;
 PROC SORT DATA = project.WN OUT= NWF NODUPKEY;
 BY Acctno;
RUN;
PROC PRINT DATA = NWF;
 VAR Acctno;
RUN;

/*1.1.b What is the number of accounts activated and deactivated? */

PROC SQL ;
title " List of Activated and Deactivated Accounts.";
SELECT count (ACtdt) as Number_of_Activated,count (Deactdt) as Number_of_Deactivated,count (ACtdt)-count (Deactdt) as Currently_Active
FROM project.WN
;
QUIT;
PROC SQL OUTOBS=1;
TITLE " What is latest account activation date ";
SELECT *
FROM project.WN where Actdt is not null

ORDER BY Actdt DESC
;
QUIT;
PROC SQL OUTOBS=1;
TITLE " What is latest account deactivation date ";
SELECT *
FROM project.WN where Deactdt is not null

ORDER BY Deactdt DESC 
;
QUIT;
PROC SQL OUTOBS=1;
TITLE " What is eraliest account activation date ";
SELECT *
FROM project.WN where Actdt is not null

ORDER BY Actdt 
;
QUIT;
PROC SQL OUTOBS=1;
TITLE " What is eraliest account deactivation date ";
SELECT *
FROM project.WN where Deactdt is not null
ORDER BY Deactdt 
;
QUIT;



  /*1.21.2  What is the age and province distributions of active and deactivated customers?*/
  
proc freq data=project.statusq2;
tables status*Age*Province;
run;
proc freq data=project.status3;
tables status*agegruop*Province;
run;


 /*1.3 Segment the customers based on age, province and sales amount:*/
proc format;
  value agefmt
        low-<20='<20'
		21- <41='21-40'
		41- <61='41-60'
		61-high='60 and above'
		;
  
  Value Salesfmt
	    low-<100="100"
		100- <500="100-500"
		500- <800="500-800"
		800-high="800 PLUS"
		;
	run;
proc print data=project.WN(OBS=100);
format Age agefmt. Sales Salesfmt.;
run;
DATA project.CUX_02(OBS=100);
 SET project.WN;
format Age agefmt. Sales Salesfmt.;
RUN;
proc print data=project.CUX_02(OBS=100);
run;
data project.tenure_qq(OBS=100);
  set project.WN(keep = Age Sales Province);
  format Age agefmt. Sales Salesfmt.;
RUN;
proc print data=project.tenure_qq(OBS=100);
run;

proc freq data=project.tenure_qq(OBS=100);
    run;
/*1) Calculate the tenure in days for each account and give its simple statistics.*/


data project.tenure_new1(OBS=100);

title"Calculate the tenure in days for each account and give its simple statistics.";
  set project.WN(keep = Acctno Actdt Deactdt);
  if Deactdt eq null then
     Tenure=intck('day',Actdt,TODAY());
  else
   Tenure=intck('day',Actdt,Deactdt);
run;

proc print data=project.tenure_new1(OBS=100);
run;


proc means data=project.tenure_new1(OBS=100);
var Tenure;
run;
/*2) Calculate the number of accounts deactivated for each month.*/
data month_deact(OBS=100);
  set project.WN(keep = Acctno Actdt Deactdt);
    justmonth= put(Deactdt, monname3.);
	year = year(Deactdt);
 run;
proc print data=month_deact(OBS=100);
run;
proc sql;
select count(Deactdt) as Number_Account_Deactivated,justmonth,year from month_deact group by justmonth,year having calculated Number_Account_Deactivated>0 order by calculated Number_Account_Deactivated;
quit;
data project.tenure_new_all(OBS=100);
  set project.WN;
  if Deactdt eq null then
   Tenure=intck('day',Actdt,TODAY());
  else
   Tenure=intck('day',Actdt,Deactdt);
run;
data status1(OBS=100);
  set project.WN(keep = Acctno Actdt Deactdt);
  if Deactdt eq null then
   status='Active';
  else
   status='DeAct';
run;
data statusq2(OBS=100);
  set project.WN;
  if Deactdt eq null then
   status='Active';
  else
   status='DeAct';
run;
proc print data=status1(OBS=100);
run;
data status2(OBS=100);
  set tenure_new1;
  if Deactdt eq null then
   status='Active';
  else
   status='DeAct';
   if Tenure le 30 then Tenuregruop='less than 30';
   else if 30 <= Tenure < 61 	then  Tenuregruop='between 31-60 days';
   ELSE IF 61 <= Tenure <= 365  THEN Tenuregruop = "one year";
   else if Tenure  gt 365	then  Tenuregruop = "above one year";
run;
proc print data=status2(OBS=100);
run;
 proc freq data = status2;
 table Tenuregruop/missing list;
 run;
 proc freq data = status2;
 table status /missing list;
 run;
data project.status2(OBS=100);
  length status $ 15;
  length Tenuregruop $ 25; 
  set project.tenure_new_all;
  if Deactdt eq null then
   status='Active';
  else
   status='DeActivated';
   if Tenure le 30 then Tenuregruop='less than 30';
   else if 30 <= Tenure < 61 	then  Tenuregruop='between 31-60 days';
   ELSE IF 61 <= Tenure <= 365  THEN Tenuregruop = "one year";
   else if Tenure  gt 365	then  Tenuregruop = "above one year";
run;
data project.status2(OBS=100);
  length status $ 15;
  length Tenuregruop $ 25; 
  set project.tenure_new_all;
  if Deactdt eq null then
   status='Active';
  else
   status='DeActivated';
   if Tenure le 30 then Tenuregruop='less than 30';
   else if 30 <= Tenure < 61 	then  Tenuregruop='between 31-60 days';
   ELSE IF 61 <= Tenure <= 365  THEN Tenuregruop = "one year";
   else if Tenure  gt 365	then  Tenuregruop = "above one year";
run;
proc freq data = project.status2;
title"number of accounts of percent of all for tenure segment.";
 table Tenuregruop/missing list;
 run;
 proc freq data = project.status2;
 title"number of accounts of percent of all for status segment.";
 table status /missing list;
 run;
proc freq data = project.status2;
title"number of accounts of percent of all for tenure segment and status segment";
 table status*Tenuregruop /missing list;
 run;
 proc print data=project.status2(obs=10);
 run;
PROC OPTIONS OPTION = MACRO;
RUN;
%include "C:\Users\Reshma\Desktop\mac.sas";
/*1.4.4) Test the general association between the tenure segments and “Good Credit”
“RatePlan ” and “DealerType.”
*/

/*H0:There is no association between tenure segments Good Credit
H1:There is an association between tenure segments Good Credit*/

%CHSQUARE(DSN =project.status2 , VAR1= Tenuregruop , VAR2 = GoodCredit);

/*H0:There is no association between tenure segments RatePlan
H1:There is an association between tenure segments RatePlan*/

%CHSQUARE(DSN =project.status2 , VAR1= Tenuregruop , VAR2 = RatePlan);

/*H0:There is no association between tenure segments DealerType
H1:There is an association between tenure segments DealerType*/

%CHSQUARE(DSN =project.status2 , VAR1= Tenuregruop , VAR2 = DealerType);
/*5) Is there any association between the account status and the tenure segments?
Could you find out a better tenure segmentation strategy that is more associated
with the account status?*/

/*H0:There is no association between tenure segments and Status
H1:There is an association between tenure segments and Status*/

%CHSQUARE(DSN = project.status2 , VAR1= Tenuregruop , VAR2 = status);
PROC SGPLOT DATA=project.status2;
VBAR status/GROUP=Tenuregruop;
TITLE"association between tenure segments and Status";
RUN;
data project.status4(OBS=100);
  length status $ 15;
  length Tenuregruop $ 25; 
  set project.tenure_new_all;
  if Deactdt eq null then
   status='Active';
  else
   status='DeActivated';
   if 0<Tenure < 182.2 then Tenuregruop='less than 6 months';
   ELSE IF 182.2 <= Tenure <= 365  THEN Tenuregruop = "one year";
   else if Tenure  gt 365	then  Tenuregruop = "above one year";
run;
%CHSQUARE(DSN = project.status4 , VAR1= Tenuregruop , VAR2 = status);
/*6) Does Sales amount differ among different account status, GoodCredit, and
customer age segments?
*/
%UNI_ANALYSIS_NUM(project.status2,Sales);

%BI_ANALYSIS_NUMs_CAT (DSN =project.status2 ,CLASS=status , VAR=Sales);
/*H0:Sales amount does not differ among Account Status
H1: Sales amount  differs among Account Status*/
proc ttest data=project.status2;
class status;
var Sales;
run;
%BI_ANALYSIS_NUMs_CAT (DSN =project.status2 ,CLASS=GoodCredit , VAR=Sales);
/*H0:Sales amount does not differ among Good Credit
H1: Sales amount  differs among Account Good Credit*/
proc ttest data=project.status2;
class GoodCredit;
var Sales;
run;
%BI_ANALYSIS_NUMs_CAT (DSN =project.status3 ,CLASS=agegruop , VAR=Sales);
/*H0:Sales amount does not differ among Age segments
H1: Sales amount  differs among Age Segments*/
proc glm data=project.status3;
class agegruop;
model Sales = agegruop;
means Sales / hovtest=levene(type=abs) welch;
run;
PROC ANOVA data=project.status3;
CLASS agegruop;
MODEL Sales = agegruop;
run;



/*................................................................................*/
 /*univariate analysis for categorical columns*/

%UNI_ANALYSIS_CAT(project.wn,Province)
%UNI_ANALYSIS_CAT(project.wn,DeactReason)
%UNI_ANALYSIS_CAT(project.status3,agegruop)
PROC SGPLOT DATA = project.status3;
title"Bar Chart for Age group Distribution";
VBAR agegruop;
RUN;
%UNI_ANALYSIS_CAT(project.status3,Tenuregruop)

