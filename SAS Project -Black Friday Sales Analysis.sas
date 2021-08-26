


*                                      SAS FIANL BUSINESS PROJECT
                                       BLACK FRIDAY SALES-ANALYSIS
                                      SUBMITTED BY: RESHMA RETNAMMA
                                       SUBMITTED TO: Mr.ARKAR MIN

-------------------------------------------------------------------------------------------------------------------------------------;



Libname pro "D:\dsc\sas\advanced SAS\pjct";
proc import file="D:\dsc\sas\advanced SAS\pjct\train.csv"
    out=pro.train1
    dbms=csv;
run;

proc import file="D:\dsc\sas\advanced SAS\pjct\tests.csv"
    out=pro.test1
    dbms=csv;
run;
proc contents data=pro.train1;
run;
proc contents data=pro.test1;
run;
Data pro.train1;
 set pro.train1;
 source = 'train' ;
run;
proc contents data=pro.train1;
run;
proc print data=pro.train1 (obs=5) ; *noobs;
run;
Data pro.test1;
 set pro.test1;
 source = 'test' ;
run;
proc print data=pro.test1 (obs=5) ; *noobs;
run;
*MERGING THE DATASETS TEST AND TRAIN FOR CLEANING PURPOSE;
data pro.merged1;
set pro.train1 pro.test1;
run;
*printing the bottom 10 rows;

%let obswant = 10;
data want;
   do _i_=nobs-(&obswant-1) to nobs;
      set merged point=_i_ nobs=nobs;
      output;
      end;
   stop;  /* Needed to stop data step */
run;
proc print data=want; *noobs;
run;

* CATEGORICAL DATA : FREQUENCY COUNT : ABSOULTE FREQ, 
                     RELATIVE FREQ AND CUMULATIVE FREQ OR RATE/RATIO/PROPORTION;
*------------------------------------------------------------------------------;
PROC FREQ DATA = pro.merged1;
TABLE
	Gender
	Age
	Occupation
	City_Category
	Stay_In_Current_City_Years
	Marital_Status
	Product_Category_1 
	Product_Category_2 
	Product_Category_3 
; 
RUN;

* Handling Missing value- GET PERCENTAGE OF MISSING VALUES;
*---------------------------------------------------------------;
TITLE "Null Values in all variables";
/* CREATE A FORMAT TO GROUP MISSING AND NONMISSING */
PROC FORMAT;
 VALUE $MISSFMT ' '='MISSING' OTHER='NOT MISSING';
 VALUE  MISSFMT  . ='MISSING' OTHER='NOT MISSING';
RUN;

PROC FREQ DATA= pro.merged1; 
FORMAT _CHAR_ $MISSFMT.; /* APPLY FORMAT FOR THE DURATION OF THIS PROC */
TABLES _CHAR_ / MISSING MISSPRINT NOCUM ;
FORMAT _NUMERIC_ MISSFMT.;
TABLES _NUMERIC_ / MISSING MISSPRINT NOCUM;
RUN;


* WE HAVE ABOUT 70% MISSING VALUE IN PRODUCT_CATEGORY_3 
THEREFORE WE ARE DROPPING AS IT DOENOT MAKE SENSE TO FILL IT;

*FILLING MISSING VALUES AND DROP PRODUCT_CATEGORY_3
*--------------------------------------------------;
DATA pro.merged1;
SET pro.merged1;
DROP PRODUCT_CATEGORY_3;
RETAIN  _PRODUCT_CATEGORY_2;
IF NOT MISSING(PRODUCT_CATEGORY_2) THEN _PRODUCT_CATEGORY_2 = PRODUCT_CATEGORY_2;
ELSE PRODUCT_CATEGORY_2 = PRODUCT_CATEGORY_1;
DROP _PRODUCT_CATEGORY_2;
RUN;
PROC PRINT DATA= Spro.merged1 (OBS= 10);
RUN;

PROC MEANS DATA = pro.merged1 N NMISS;
VAR PRODUCT_CATEGORY_2;
RUN;

*IMPORTING THE EXTERNAL MACRO FILES TO PERFORM THE ANALYSIS;
PROC OPTIONS OPTION = MACRO;
RUN;
%include "C:\Users\Reshma\Desktop\mac.sas";


*UNIVARIATE ANALYSIS OF INDIVIDUAL FEATURES;
*__________________________________________________________________________________________________________________________________________________;
*...AGE...;
%UNI_ANALYSIS_CAT(pro.merged1,Age)
*...city_Category...;
%UNI_ANALYSIS_CAT(pro.merged1,city_Category)
PROC SGPLOT DATA = pro.merged1 ;
 VBAR city_Category/FILLATTRS=(COLOR=aqua);
RUN;
QUIT;
*...Gender...;
%UNI_ANALYSIS_CAT(pro.merged1,Gender)
*...Marital_Status...;
%UNI_ANALYSIS_CAT(pro.merged1,Marital_Status)
PROC SGPLOT DATA = pro.merged1 ;
 VBAR Marital_Status/FILLATTRS=(COLOR=OLIVE);
RUN;
QUIT;
*...Occupation...;
%UNI_ANALYSIS_CAT(pro.merged1,Occupation)
PROC SGPLOT DATA = pro.merged1 ;
 VBAR Occupation/FILLATTRS=(COLOR=olive);
RUN;
QUIT;
*...Product_Category_1...;
%UNI_ANALYSIS_CAT(pro.merged1,Product_Category_1)
PROC SGPLOT DATA = pro.merged1 ;
 VBAR Product_Category_1/FILLATTRS=(COLOR=OLIVE);
RUN;
QUIT;
%UNI_ANALYSIS_CAT(pro.merged1,Product_Category_2)
PROC SGPLOT DATA = pro.merged1 ;
 VBAR Product_Category_2/FILLATTRS=(COLOR=OLIVE);
RUN;
QUIT;
*...Stay_In_Current_City_Years...;
%UNI_ANALYSIS_CAT(pro.merged1,Stay_In_Current_City_Years)
*...Purchase...;
%UNI_ANALYSIS_NUM(pro.merged1,Purchase);
PROC SGPLOT DATA = pro.merged1;
HISTOGRAM Purchase; 
DENSITY Purchase;
RUN;


*BIVARIATE ANALYSIS;
*____________________________________________________________________________________________________________________________________;
*BIVARIATE ANALYSIS OF PURCHASE AND AGE
WHICH AGE CATEGORY SPENDS MORE ON A BLACKFRIDAY SALE
-----------------------------------------------------------------------------;
%BI_ANALYSIS_NUMs_CAT (DSN =pro.merged1 ,CLASS=Age , VAR=Purchase);

ods graphics on;

title " BIVARIATE ANALYSIS OF PURCHASE BY AGE";
PROC univariate DATA = pro.merged1;
class Age; 
var Purchase; 
HISTOGRAM Purchase;
inset skewness kurtosis;
probplot Purchase;
inset skewness kurtosis;
RUN;
ODS GRAPHICS OFF;

title " BOXPLOT FOR PURCHASE BY AGE";
PROC SGPLOT DATA = pro.merged1;
VBOX Purchase/CATEGORY=Age; 
RUN;
ods graphics on;

proc sql;
create table pro.purchase_ages as 
   select Age,sum(Purchase)as Purchase_sum from pro.merged1 group by age order by calculated Purchase_sum DESC;
quit;

title " PURCHASE BY AGE";
proc print data=pro.purchase_ages noobs;
run;
title;
proc sgplot data=pro.merged1;
title "BARCHART FOR PURCHASE BY AGE";
vbar AGE / response=PURCHASE;
FORMAT PURCHASE dollar10.2;
run;


PROC SGPLOT DATA = s.train1 ;
 VBAR Age/response=PURCHASE/GROUP =  Gender ;
 RUN;
QUIT;

*TEST OF INDEPENDANCE;
*HO: There is no statistically significant relation between AGE and PURCHASE
 H1: There is a statistically significant relation between AGE and PURCHASE;
title " ANOVA FOR PURCHASE BY AGE";
PROC ANOVA data=pro.merged1;
CLASS AGE;
MODEL PURCHASE = AGE;
run;
TITLE;
*BIVARIATE ANALYSIS OF PURCHASE AND GENDER
WHICH GENDER CATEGORY SPENDS MORE ON A BLACKFRIDAY SALE
-----------------------------------------------------------------------------;
%BI_ANALYSIS_NUMs_CAT (DSN =pro.merged1 ,CLASS=GENDER , VAR=Purchase);

ods graphics on;

title " BIVARIATE ANALYSIS OF PURCHASE BY GENDER";
PROC univariate DATA = pro.merged1;
class GENDER; 
var Purchase; 
HISTOGRAM Purchase;
inset skewness kurtosis;
probplot Purchase;
inset skewness kurtosis;
RUN;
ODS GRAPHICS OFF;

title " BOXPLOT FOR PURCHASE BY GENDER";
PROC SGPLOT DATA = pro.merged1;
VBOX Purchase/CATEGORY=GENDER; 
RUN;
ods graphics on;
proc sql;
create table pro.purchase_GENDERs as 
   select GENDER,sum(Purchase)as Purchase_sum from pro.merged1 group by GENDER order by calculated Purchase_sum DESC;
quit;
proc print data=pro.purchase_GENDERs noobs;
run;
proc sgplot data=pro.merged1;
title "BARCHART FOR PURCHASE BY GENDER";
vbar GENDER / response=PURCHASE;
FORMAT PURCHASE dollar10.2;
run;
title "T-Test for PURCHASE BY GENDER";
proc ttest data=pro.merged1;
class GENDER;
var PURCHASE;
run;

*BIVARIATE ANALYSIS OF PURCHASE AND OCCUPATION
WHICH OCCUPATION CATEGORY SPENDS MORE ON A BLACKFRIDAY SALE
-----------------------------------------------------------------------------;
%BI_ANALYSIS_NUMs_CAT (DSN =pro.merged1 ,CLASS=OCCUPATION , VAR=Purchase);

ods graphics on;

title " BIVARIATE ANALYSIS OF PURCHASE BY OCCUPATION";
PROC univariate DATA = pro.merged1;
class OCCUPATION; 
var Purchase; 
HISTOGRAM Purchase;
inset skewness kurtosis;
probplot Purchase;
inset skewness kurtosis;
RUN;
ODS GRAPHICS OFF;

title " BOXPLOT FOR PURCHASE BY OCCUPATION";
PROC SGPLOT DATA = pro.merged1;
VBOX Purchase/CATEGORY=OCCUPATION; 
RUN;
ods graphics on;
proc sql;
create table pro.purchase_OCCUPATIONs as 
   select OCCUPATION,sum(Purchase)as Purchase_sum from pro.merged1 group by OCCUPATION order by calculated Purchase_sum DESC;
quit;
title " PURCHASE BY OCCUPATION";
proc print data=pro.purchase_OCCUPATIONs noobs;
run;
proc sgplot data=pro.merged1;
title "BARCHART FOR PURCHASE BY OCCUPATION";
vbar OCCUPATION / response=PURCHASE GROUPORDER=ASCENDING;
FORMAT PURCHASE dollar10.2;
run;
title " ANOVA FOR PURCHASE BY OCCUPATION";
PROC ANOVA data=pro.merged1;
CLASS OCCUPATION;
MODEL PURCHASE =OCCUPATION;
run;
*BIVARIATE ANALYSIS OF PURCHASE AND CITY_CATEGORY
WHICH CITY_CATEGORY CATEGORY SPENDS MORE ON A BLACKFRIDAY SALE
-----------------------------------------------------------------------------;
%BI_ANALYSIS_NUMs_CAT (DSN =pro.merged1 ,CLASS=CITY_CATEGORY , VAR=Purchase);

ods graphics on;

title " BIVARIATE ANALYSIS OF PURCHASE BY CITY_CATEGORY";
PROC univariate DATA = pro.merged1;
class CITY_CATEGORY; 
var Purchase; 
HISTOGRAM Purchase;
inset skewness kurtosis;
probplot Purchase;
inset skewness kurtosis;
RUN;
ODS GRAPHICS OFF;

title " BOXPLOT FOR PURCHASE BY CITY_CATEGORY";
PROC SGPLOT DATA = pro.merged1;
VBOX Purchase/CATEGORY=CITY_CATEGORY; 
RUN;
ods graphics on;
proc sql;
create table pro.purchase_CITY_CATEGORYs as 
   select CITY_CATEGORY,sum(Purchase)as Purchase_sum from pro.merged1 group by CITY_CATEGORY order by calculated Purchase_sum DESC;
quit;
proc print data=pro.purchase_CITY_CATEGORYs noobs;
run;
proc sgplot data=pro.merged1;
title "BARCHART FOR PURCHASE BY CITY_CATEGORY";
vbar CITY_CATEGORY / response=PURCHASE;
FORMAT PURCHASE dollar10.2;
run;

title "ANOVA FOR PURCHASE BY CITY_CATEGORY";
PROC ANOVA data=pro.merged1;
CLASS CITY_CATEGORY;
MODEL PURCHASE =CITY_CATEGORY;
run;

*BIVARIATE ANALYSIS OF PURCHASE AND MARITAL_STATUS
WHICH MARITAL_STATUS CATEGORY SPENDS MORE ON A BLACKFRIDAY SALE
-----------------------------------------------------------------------------;
%BI_ANALYSIS_NUMs_CAT (DSN =pro.merged1 ,CLASS=MARITAL_STATUS , VAR=Purchase);

ods graphics on;

title " BIVARIATE ANALYSIS OF PURCHASE BY MARITAL_STATUS";
PROC univariate DATA = pro.merged1;
class MARITAL_STATUS; 
var Purchase; 
HISTOGRAM Purchase;
inset skewness kurtosis;
probplot Purchase;
inset skewness kurtosis;
RUN;
ODS GRAPHICS OFF;

title " BOXPLOT FOR PURCHASE BY MARITAL_STATUS";
PROC SGPLOT DATA = pro.merged1;
VBOX Purchase/CATEGORY=MARITAL_STATUS; 
RUN;
ods graphics on;
proc sql;
create table pro.purchase_MARITAL_STATUSs as 
   select MARITAL_STATUS,sum(Purchase)as Purchase_sum from pro.merged1 group by MARITAL_STATUS order by calculated Purchase_sum DESC;
quit;
title " PURCHASE BY MARITAL_STATUS";
proc print data=pro.purchase_MARITAL_STATUSs noobs;
run;
proc sgplot data=pro.merged1;
title "BARCHART FOR PURCHASE BY MARITAL_STATUS";
vbar MARITAL_STATUS / response=PURCHASE;
FORMAT PURCHASE dollar10.2;
run;
title "T-test FOR PURCHASE BY MARITAL_STATUS";
proc ttest data=pro.merged1;
class MARITAL_STATUS;
var PURCHASE;
run;
*BIVARIATE ANALYSIS OF PURCHASE AND STAY_IN_CURRENT_CITY_YEARS
WHICH STAY_IN_CURRENT_CITY_YEARS CATEGORY SPENDS MORE ON A BLACKFRIDAY SALE
-----------------------------------------------------------------------------;
%BI_ANALYSIS_NUMs_CAT (DSN =pro.merged1 ,CLASS=STAY_IN_CURRENT_CITY_YEARS,VAR=Purchase);

ods graphics on;

title " BIVARIATE ANALYSIS OF PURCHASE BY STAY_IN_CURRENT_CITY_YEARS";
PROC univariate DATA = pro.merged1;
class STAY_IN_CURRENT_CITY_YEARS; 
var Purchase; 
HISTOGRAM Purchase;
inset skewness kurtosis;
probplot Purchase;
inset skewness kurtosis;
RUN;
ODS GRAPHICS OFF;

title " BOXPLOT FOR PURCHASE BY STAY_IN_CURRENT_CITY_YEARS";
PROC SGPLOT DATA = pro.merged1;
VBOX Purchase/CATEGORY=STAY_IN_CURRENT_CITY_YEARS; 
RUN;
ods graphics on;
proc sql;
create table pro.purchase_CITY_YEARS as 
   select STAY_IN_CURRENT_CITY_YEARS,sum(Purchase)as Purchase_sum from pro.merged1 group by STAY_IN_CURRENT_CITY_YEARS order by calculated Purchase_sum DESC;
quit;
title "PURCHASE BY STAY_IN_CURRENT_CITY_YEARS";
proc print data=pro.purchase_CITY_YEARS noobs;
run;
proc sgplot data=pro.merged1;
title "BARCHART FOR PURCHASE BY STAY_IN_CURRENT_CITY_YEARS";
vbar STAY_IN_CURRENT_CITY_YEARS / response=PURCHASE;
FORMAT PURCHASE dollar10.2;
run;

title "ANOVA FOR PURCHASE BY STAY_IN_CURRENT_CITY_YEARS";
PROC ANOVA data=pro.merged1;
CLASS STAY_IN_CURRENT_CITY_YEARS;
MODEL PURCHASE = STAY_IN_CURRENT_CITY_YEARS;
run;

*BIVARIATE ANALYSIS OF PURCHASE AND PRODUCT_CATEGORY_1
WHICH PRODUCT_CATEGORY_1 CATEGORY SPENDS MORE ON A BLACKFRIDAY SALE
-----------------------------------------------------------------------------;
%BI_ANALYSIS_NUMs_CAT (DSN =pro.merged1 ,CLASS=PRODUCT_CATEGORY_1 , VAR=Purchase);

ods graphics on;

title " BIVARIATE ANALYSIS OF PURCHASE BY PRODUCT_CATEGORY_1";
PROC univariate DATA = pro.merged1;
class PRODUCT_CATEGORY_1; 
var Purchase; 
HISTOGRAM Purchase;
inset skewness kurtosis;
probplot Purchase;
inset skewness kurtosis;
RUN;
ODS GRAPHICS OFF;

title " BOXPLOT FOR PURCHASE BY PRODUCT_CATEGORY_1";
PROC SGPLOT DATA = pro.merged1;
VBOX Purchase/CATEGORY=PRODUCT_CATEGORY_1; 
RUN;
ods graphics on;
proc sql;
create table pro.purchase_PRODUCT_CATEGORY_1s as 
   select PRODUCT_CATEGORY_1,sum(Purchase)as Purchase_sum from pro.merged1 group by PRODUCT_CATEGORY_1 order by calculated Purchase_sum DESC;
quit;
title "PURCHASE BY PRODUCT_CATEGORY_1";

proc print data=pro.purchase_PRODUCT_CATEGORY_1s noobs;
run;
proc sgplot data=pro.merged1;
title "BARCHART FOR PURCHASE BY PRODUCT_CATEGORY_1";
vbar PRODUCT_CATEGORY_1 / response=PURCHASE;
FORMAT PURCHASE dollar10.2;
run;
title "ANOVA FOR PURCHASE BY PRODUCT_CATEGORY_1";
PROC ANOVA data=pro.merged1;
CLASS PRODUCT_CATEGORY_1;
MODEL PURCHASE = PRODUCT_CATEGORY_1;
run;
*BIVARIATE ANALYSIS OF PURCHASE AND PRODUCT_CATEGORY_2
WHICH PRODUCT_CATEGORY_2 CATEGORY SPENDS MORE ON A BLACKFRIDAY SALE
-----------------------------------------------------------------------------;
%BI_ANALYSIS_NUMs_CAT (DSN =pro.merged1 ,CLASS=PRODUCT_CATEGORY_2 , VAR=Purchase);

ods graphics on;

title " BIVARIATE ANALYSIS OF PURCHASE BY PRODUCT_CATEGORY_2";
PROC univariate DATA = pro.merged1;
class PRODUCT_CATEGORY_2; 
var Purchase; 
HISTOGRAM Purchase;
inset skewness kurtosis;
probplot Purchase;
inset skewness kurtosis;
RUN;
ODS GRAPHICS OFF;

title " BOXPLOT FOR PURCHASE BY PRODUCT_CATEGORY_2";
PROC SGPLOT DATA = pro.merged1;
VBOX Purchase/CATEGORY=PRODUCT_CATEGORY_2; 
RUN;
ods graphics on;
proc sql;
create table pro.purchase_PRODUCT_CATEGORY_2s as 
   select PRODUCT_CATEGORY_2,sum(Purchase)as Purchase_sum from pro.merged1 group by PRODUCT_CATEGORY_2 order by calculated Purchase_sum DESC;
quit;
title " PURCHASE BY PRODUCT_CATEGORY_2";
proc print data=pro.purchase_PRODUCT_CATEGORY_2s noobs;
run;
proc sgplot data=pro.merged1;
title "BARCHART FOR PURCHASE BY PRODUCT_CATEGORY_2";
vbar PRODUCT_CATEGORY_2 / response=PURCHASE;
FORMAT PURCHASE dollar10.2;
run;
PROC ANOVA data=pro.merged1;
CLASS PRODUCT_CATEGORY_2;
MODEL PURCHASE = PRODUCT_CATEGORY_2;
run;

*concatenate  two product categories
 -----------------------------------;
DATA pro.merged1;
SET pro.merged1;
NEW_PRODUCT = CATX('-',PRODUCT_CATEGORY_1, PRODUCT_CATEGORY_2);
RUN;

*PRODUCT DISTRIBUTION
 --------------------;
/*CREATE A TABLE AGGREGATED BY DISTINCT PRODUCT COUNTS*/
PROC SQL;
CREATE TABLE PRODUCT_DIST AS
SELECT NEW_PRODUCT,
	USER_ID,
	COUNT(DISTINCT USER_ID)AS NUMBER_OF_CUSTOMER,  
	SUM(DISTINCT USER_ID) AS TOTAL_CUSTOMER,
	SUM(PURCHASE) AS TOTAL_PURCHASE,
	AVG(PURCHASE) AS AVG_PURCHASE,
	AGE,
	GENDER,
	OCCUPATION,
	Marital_Status,
	STAY_IN_CURRENT_CITY_YEARS,
	CITY_CATEGORY
FROM pro.merged1
GROUP BY NEW_PRODUCT, CITY_CATEGORY,Marital_Status
;
QUIT;


proc print data=PRODUCT_DIST(obs=5);
run;




proc sgplot data=pro.merged1;
title "BARCHART FOR PURCHASE BY PRODUCT_CATEGORY_2";
vbar NEW_PRODUCT / response=PURCHASE;
FORMAT PURCHASE dollar10.2;
run;
proc sql;
create table pro.purchase_NEW_CATEGORY_2s as 
   select NEW_PRODUCT,sum(Purchase)as Purchase_sum from pro.merged1 group by NEW_PRODUCT order by calculated Purchase_sum DESC;
quit;
title " PURCHASE BY PRODUCT_CATEGORY_2";
proc print data=pro.purchase_NEW_CATEGORY_2s noobs;
run;

*BUSINESS QUESTIONS
----------------------------------------------------;
*1. WHICH IS THE MOST PROFITABLE DISTRIBUTION MIX;

PROC TABULATE DATA=pro.merged1;
CLASS AGE OCCUPATION GENDER MARITAL_STATUS CITY_CATEGORY;
TABLE CITY_CATEGORY*(GENDER ALL),AGE="AGE GROUPS"*(PCTN='%')ALL*(N PCTN) MARITAL_STATUS="MS GROUPS"*(PCTN='%')ALL*(N PCTN) occupation="OCCUPATION"*(PCTN='%')ALL*(N PCTN);
RUN;
*2.Which occupation category spends the most on a black Friday sale?;

PROC TABULATE DATA=pro.merged1;
CLASS AGE OCCUPATION GENDER MARITAL_STATUS CITY_CATEGORY;
TABLE CITY_CATEGORY*(GENDER ALL),OCCUPATION="OCCUPATION GROUPS"*(PCTN='%')ALL*(N PCTN);
RUN;
proc sql;
create table pro.purchase_OC as 
   select Occupation,sum(Purchase)as Purchase_sum from pro.merged1 group by Occupation order by calculated Purchase_sum DESC;
quit;

proc print data=pro.purchase_OC;
run;
proc sgplot data=pro.merged1;
title "BARCHART FOR PURCHASE BY OCCUPATION";
vbar OCCUPATION / response=PURCHASE;
run;

5.Which type of products are common among 

            Occupation categories;
*PRODUCT CATEGORY1;
TITLE 'TOP PRODUCT Purchases IN OCCUPATION CATEGORIES';
PROC SGPLOT DATA=PRODUCT_DIST(WHERE= (NEW_PRODUCT = '1-15' OR NEW_PRODUCT = '1-2' 
							           OR NEW_PRODUCT = '5-5' OR NEW_PRODUCT = '5-8'
							           OR NEW_PRODUCT = '8-8'OR NEW_PRODUCT = '6-8'));
  VBAR occupation / RESPONSE= TOTAL_PURCHASE GROUP= NEW_PRODUCT GROUPDISPLAY= CLUSTER 
  STAT= MEAN DATASKIN= GLOSS;
  XAXIS DISPLAY= (NOLABEL NOTICKS);
  FORMAT TOTAL_PURCHASE dollar10.2;
  YAXIS GRID;
RUN;
TITLE 'TOP PRODUCT Purchases BY NUMBER OF CUSTOMERS IN OCCUPATION CATEGORIES';
PROC SGPLOT DATA=PRODUCT_DIST(WHERE= (NEW_PRODUCT = '1-15' OR NEW_PRODUCT = '1-2' 
							           OR NEW_PRODUCT = '5-5' OR NEW_PRODUCT = '5-8'
							           OR NEW_PRODUCT = '8-8'OR NEW_PRODUCT = '6-8'));
  VBAR occupation / RESPONSE= NUMBER_OF_CUSTOMER GROUP= NEW_PRODUCT GROUPDISPLAY= CLUSTER 
  STAT= MEAN DATASKIN= GLOSS;
  XAXIS DISPLAY= (NOLABEL NOTICKS);
  YAXIS GRID;
RUN;



*3.Which city category spends the most on a black Friday sale?;

proc sql;
create table pro.purchase_CIT as 
   select sum(Purchase)as Purchase_sum,City_Category from pro.merged1 group by City_Category order by calculated Purchase_sum DESC;
quit;

proc print data=pro.purchase_CIT noobs;
run;
proc sgplot data=pro.merged1;
title "BARCHART FOR PURCHASE BY OCCUPATION";
vbar City_Category / response=PURCHASE;
run;


*Which type of products are common among 

            City_Category categories;



TITLE 'TOP PRODUCT Purchases IN CITY CATEGORIES';
PROC SGPLOT DATA=PRODUCT_DIST(WHERE= (NEW_PRODUCT = '1-15' OR NEW_PRODUCT = '1-2' 
							           OR NEW_PRODUCT = '5-5' OR NEW_PRODUCT = '5-8'
							           OR NEW_PRODUCT = '8-8'OR NEW_PRODUCT = '6-8'));
  VBAR CITY_CATEGORY / RESPONSE= TOTAL_PURCHASE GROUP= NEW_PRODUCT GROUPDISPLAY= CLUSTER 
  STAT= MEAN DATASKIN= GLOSS;
  XAXIS DISPLAY= (NOLABEL NOTICKS);
  FORMAT TOTAL_PURCHASE dollar10.2;
  YAXIS GRID;
RUN;
proc sql;
create table pro.purchase_C1 as 
   select sum(Purchase)as Purchase_sum,Product_Category_1,CITY_CATEGORY from pro.merged1 group by CITY_CATEGORY,Product_Category_1 order by calculated Purchase_sum DESC;
quit;
proc print data=pro.purchase_C1 noobs;
run;


*4.Who is spends the most on a black Friday sale?
Men Vs. Women;

proc sql;
create table pro.purchase_G as 
   select sum(Purchase)as Purchase_sum,GENDER from pro.merged1 group by GENDER order by calculated Purchase_sum DESC;
quit;

proc print data=pro.purchase_G noobs;
run;
proc sgplot data=pro.merged1;
title "BARCHART FOR PURCHASE BY GENDER";
vbar GENDER / response=PURCHASE;
FORMAT PURCHASE dollar10.2;
run;

*Which type of products are common among 

            GENDER categories;

*PRODUCT CATEGORY;

TITLE 'TOP PRODUCT Purchases IN GENDER CATEGORIES';
PROC SGPLOT DATA=PRODUCT_DIST(WHERE= (NEW_PRODUCT = '1-15' OR NEW_PRODUCT = '1-2' 
							           OR NEW_PRODUCT = '5-5' OR NEW_PRODUCT = '5-8'
							           OR NEW_PRODUCT = '8-8'OR NEW_PRODUCT = '6-8'));
  VBAR GENDER / RESPONSE= TOTAL_PURCHASE GROUP= NEW_PRODUCT GROUPDISPLAY= CLUSTER 
  DATASKIN= GLOSS;
  XAXIS DISPLAY= (NOLABEL NOTICKS);
  FORMAT TOTAL_PURCHASE dollar10.2;
  YAXIS GRID;
RUN;


*Which type of products are common among 

            AGE categories;

TITLE 'TOP PRODUCT Purchases IN  AGE CATEGORIES';
PROC SGPLOT DATA=PRODUCT_DIST(WHERE= (NEW_PRODUCT = '1-15' OR NEW_PRODUCT = '1-2' 
							           OR NEW_PRODUCT = '5-5' OR NEW_PRODUCT = '5-8'
							           OR NEW_PRODUCT = '8-8'OR NEW_PRODUCT = '6-8'));
  VBAR  AGE / RESPONSE= TOTAL_PURCHASE GROUP= NEW_PRODUCT GROUPDISPLAY= CLUSTER 
  DATASKIN= GLOSS;
  XAXIS DISPLAY= (NOLABEL NOTICKS);
  FORMAT TOTAL_PURCHASE dollar10.2;
  YAXIS GRID;
RUN;
* Who is spends the most on a black Friday sale?

                 Married Vs. Unmarried;


proc sql;
create table pro.purchase_M as 
   select sum(Purchase)as Purchase_sum,Marital_Status from pro.merged1 group by Marital_Status order by calculated Purchase_sum DESC;
quit;

proc print data=pro.purchase_G noobs;
run;
proc sgplot data=pro.merged1;
title "BARCHART FOR PURCHASE BY MARITAL STATUS";
vbar Marital_Status / response=PURCHASE;
FORMAT PURCHASE dollar10.2;
run;


*Which type of products are common among 

            MARRIED VS UNMARRIED;

TITLE 'TOP PRODUCT Purchases IN  MARITAL STATUS CATEGORIES';
PROC SGPLOT DATA=PRODUCT_DIST(WHERE= (NEW_PRODUCT = '1-15' OR NEW_PRODUCT = '1-2' 
							           OR NEW_PRODUCT = '5-5' OR NEW_PRODUCT = '5-8'
							           OR NEW_PRODUCT = '8-8'OR NEW_PRODUCT = '6-8'));
  VBAR  Marital_Status / RESPONSE= TOTAL_PURCHASE GROUP= NEW_PRODUCT GROUPDISPLAY= CLUSTER 
  DATASKIN= GLOSS;
  XAXIS DISPLAY= (NOLABEL NOTICKS);
  FORMAT TOTAL_PURCHASE dollar10.2;
  YAXIS GRID;
RUN;
*MARRIED VS UNMARRIED;

TITLE 'TOP PRODUCT Purchases IN  Stay_In_Current_City_Years CATEGORIES';
PROC SGPLOT DATA=PRODUCT_DIST(WHERE= (NEW_PRODUCT = '1-15' OR NEW_PRODUCT = '1-2' 
							           OR NEW_PRODUCT = '5-5' OR NEW_PRODUCT = '5-8'
							           OR NEW_PRODUCT = '8-8'OR NEW_PRODUCT = '6-8'));
  VBAR  Stay_In_Current_City_Years / RESPONSE= TOTAL_PURCHASE GROUP= NEW_PRODUCT GROUPDISPLAY= CLUSTER 
  DATASKIN= GLOSS;
  XAXIS DISPLAY= (NOLABEL NOTICKS);
  FORMAT TOTAL_PURCHASE dollar10.2;
  YAXIS GRID;
RUN;


*AVERAGE SALES MATRIX;

PROC SQL;
CREATE TABLE PURCHASEMAT AS SELECT COUNT(DISTINCT USER_ID) AS NO_CUST,
SUM(PURCHASE) AS TOTAL_PURCHASE,AVG(PURCHASE) AS AVG_PURCHASE,CITY_CATEGORY,Marital_Status,GENDER FROM pro.merged1 GROUP BY CITY_CATEGORY,Marital_Status,GENDER;
QUIT;

PROC SGPLOT DATA=PURCHASEMAT;
TITLE "AVERAGE PURCHASE BY CITY CATEGORY";
VBOX AVG_PURCHASE/GROUP= City_Category GROUPDISPLAY= CLUSTER;
RUN;
QUIT;

PROC SGPLOT DATA=PURCHASEMAT;
TITLE "AVERAGE PURCHASE BY GENDER";
VBOX AVG_PURCHASE/GROUP= GENDER GROUPDISPLAY= CLUSTER;
RUN;
QUIT;

PROC SGPLOT DATA=PURCHASEMAT;
TITLE "AVERAGE PURCHASE BY Marital_Status";
VBOX AVG_PURCHASE/GROUP= Marital_Status GROUPDISPLAY= CLUSTER;
RUN;
QUIT;
*CUSTOMER ANALYSIS";
PROC SGPLOT DATA = pro.merged1 ;
TITLE " CITY-AGE MIX";
 VBAR CITY_CATEGORY/GROUP =Age   ;
RUN;
QUIT;
PROC SGPLOT DATA = pro.merged1 ;
TITLE " CITY-GENDER MIX";
 VBAR CITY_CATEGORY/GROUP =GENDER   ;
RUN;
QUIT;
PROC SGPLOT DATA = pro.merged1 ;
TITLE " CITY-Marital_Status MIX";
 VBAR CITY_CATEGORY/GROUP =Marital_Status   ;
RUN;
QUIT;


PROC SGPLOT DATA = pro.merged1 ;
TITLE " AGE-GENDER MIX";
 VBAR Age/GROUP =  Gender ;
RUN;
QUIT;



*MODELLING;

/*Spliting TRAIN AND TEST*/

DATA PRO.Black_Friday_Train1 PRO.Black_Friday_Test1; 
SET  pro.merged1;
IF  SOURCE='train' THEN OUTPUT PRO.Black_Friday_Train1;
ELSE IF SOURCE='test' THEN OUTPUT PRO.Black_Friday_Test1;
RUN;
TITLE "CHECKING THE DISTRIBUTION OF PURCHASE";

PROC SGPLOT DATA = pro.merged5;
HISTOGRAM Purchase; 
DENSITY Purchase;
RUN;

PROC STANDARD DATA=pro.merged5 MEAN=0 STD=1 OUT=pro.merged6;
  VAR PURCHASE ;
RUN;
TITLE "CHECKING THE DISTRIBUTION OF PURCHASE";

PROC SGPLOT DATA = pro.merged6;
HISTOGRAM Purchase; 
DENSITY Purchase;
RUN;

DATA  pro.merged9;
SET PRO.Black_Friday_Train1;
DROP Marital_Status source USER_ID PRODUCT_ID;
RUN;

PROC CONTENTS DATA=PRO.Black_Friday_Train1;
RUN;


PROC GLMSELECT data=pro.merged9;
class AGE GENDER City_Category Stay_In_Current_City_Years Occupation new_product / param=ref order=data;
model PURCHASE = AGE GENDER City_Category Stay_In_Current_City_Years Occupation new_product/ selection=stepwise select=SL
showpvalues stats=all STB;
QUIT;























































*ENCODING THE DATA SET 
 -----------------------;
DATA  pro.mergedN;
SET pro.merged1;
IF AGE="0-17"  THEN  AGE_ENC=1;
IF AGE="18-25" THEN  AGE_ENC=2;
IF AGE="26-35" THEN  AGE_ENC=3;
IF AGE="36-45" THEN  AGE_ENC=4;
IF AGE="46-50" THEN  AGE_ENC=5;
IF AGE="51-55" THEN  AGE_ENC=6;
IF AGE="55+"   THEN  AGE_ENC=7;
RUN;


DATA  pro.mergedN;
SET pro.mergedN;
IF GENDER="F"  THEN  GENDER_ENC=1;
IF GENDER="M"  THEN  GENDER_ENC=2;
RUN;

DATA  pro.mergedN;
SET pro.mergedN;
IF Marital_Status="0"  THEN  Marital_Status_ENC=1;
IF Marital_Status="1"  THEN  Marital_Status_ENC=2;
RUN;


DATA  pro.mergedN;
SET pro.mergedN;
IF City_Category="A"  THEN  City_Category_ENC=1;
IF City_Category="B"  THEN  City_Category_ENC=2;
IF City_Category="C"  THEN  City_Category_ENC=3;
RUN;


DATA  pro.mergedN;
SET pro.mergedN;
IF Occupation="0"   THEN  Occupation_ENC=1;
IF Occupation="1"   THEN  Occupation_ENC=2;
IF Occupation="2"   THEN  Occupation_ENC=3;
IF Occupation="3"   THEN  Occupation_ENC=4;
IF Occupation="4"   THEN  Occupation_ENC=5;
IF Occupation="5"   THEN  Occupation_ENC=6;
IF Occupation="6"   THEN  Occupation_ENC=7;
IF Occupation="7"   THEN  Occupation_ENC=8;
IF Occupation="8"   THEN  Occupation_ENC=9;
IF Occupation="9"   THEN  Occupation_ENC=10;
IF Occupation="10"  THEN  Occupation_ENC=11;
IF Occupation="11"  THEN  Occupation_ENC=12;
IF Occupation="12"  THEN  Occupation_ENC=13;
IF Occupation="13"  THEN  Occupation_ENC=14;
IF Occupation="14"  THEN  Occupation_ENC=15;
IF Occupation="15"  THEN  Occupation_ENC=16;
IF Occupation="16"  THEN  Occupation_ENC=17;
IF Occupation="17"  THEN  Occupation_ENC=18;
IF Occupation="18"  THEN  Occupation_ENC=19;
IF Occupation="19"  THEN  Occupation_ENC=20;
IF Occupation="20"  THEN  Occupation_ENC=21;
RUN;

DATA  pro.mergedN;
SET pro.mergedN;
IF Stay_In_Current_City_Years="0"  THEN  City_Years_ENC=1;
IF Stay_In_Current_City_Years="1" THEN  City_Years_ENC=2;
IF Stay_In_Current_City_Years="2" THEN  City_Years_ENC=3;
IF Stay_In_Current_City_Years="3" THEN  City_Years_ENC=4;
IF Stay_In_Current_City_Years="4+" THEN  City_Years_ENC=5;
RUN;

DATA  pro.mergedN;
SET pro.mergedN;
DROP AGE GENDER City_Category Stay_In_Current_City_Years Occupation Marital_Status ;
RUN;

PROC PRINT DATA= pro.mergedN(OBS=10);
RUN;

/*Spliting TRAIN AND TEST*/

DATA PRO.Black_Friday_Train PRO.Black_Friday_Test; 
SET  pro.mergedN;
IF  SOURCE='train' THEN OUTPUT PRO.Black_Friday_Train;
ELSE IF SOURCE='test' THEN OUTPUT PRO.Black_Friday_Test;
RUN;







/*CHECKING CORRELATION X VARIABLE WITH Y*/

TITLE "Computing Pearson Correlation Coefficients";
PROC CORR DATA = PRO.Black_Friday_Train NOSIMPLE RANK PLOTS= MATRIX(NVAR=ALL);
 VAR AGE_ENC GENDER_ENC City_Category_ENC Occupation_ENC Marital_Status_ENC;
 WITH Purchase;
RUN;

TITLE "PRODUCING A CORRELATION MATRIX";
PROC CORR DATA = PRO.Black_Friday_Train NOSIMPLE PLOTS = MATRIX(HISTOGRAM);
  VAR AGE_ENC GENDER_ENC City_Category_ENC Occupation_ENC Marital_Status_ENC Product_Category_1 Product_Category_2 Purchase;
RUN;

/*REGRESSION MODEL*/


TITLE "DEMONSTRATING THE RSQUARE SELECTION METHOD";
PROC REG DATA = PRO.Black_Friday_Train;
 MODEL Purchase = AGE_ENC GENDER_ENC City_Category_ENC Occupation_ENC Marital_Status_ENC/SELECTION = RSQUARE CP ADJRSQ ;
RUN;
QUIT;


TITLE "STEPWISE SELECTION METHODS";
PROC REG DATA = PRO.Black_Friday_Train ;
MODEL Purchase = AGE_ENC GENDER_ENC City_Category_ENC Occupation_ENC Marital_Status_ENC Product_Category_1 Product_Category_2 /SELECTION = STEPWISE;
RUN;
QUIT;


TITLE "FORCING SELECTED VARAIBLES INTO A MODEL";
PROC REG DATA = PRO.Black_Friday_Train PLOTS(MAXPOINTS=1000000) ;
 MODEL Purchase = AGE_ENC GENDER_ENC City_Category_ENC Occupation_ENC Marital_Status_ENC Product_Category_1 Product_Category_2/SELECTION = STEPWISE INclude=1;
 
RUN;
QUIT;



PROC GLMSELECT DATA = PRO.Black_Friday_Train1;
MODEL Purchase = AGE GENDER City_Category Occupation Marital_Status Stay_In_Current_City_Years Product_Category_1 Product_Category_1/SELECTION = STEPWISE;
RUN;

 

PROC GLMSELECT DATA = PRO.Black_Friday_Train1 OUTDESIGN=PRO.Black_Friday_Train2;
CLASS AGE GENDER City_Category Stay_In_Current_City_Years ;
MODEL Purchase=Occupation Product_Category_1 Product_Category_1 / SELECTION=STEPWISE(SELECT=SL SLE=0.05);
RUN;


