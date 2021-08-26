
##############################################################################################
#Changing directory
##############################################################################################

getwd()
setwd("C:\\Users\\Reshma\\Downloads\\dsc\\R\\class")
getwd()
ls()
rm(list=ls())#clean the working enviornmnet
ls()
library(MASS) 
library(tidyverse)
library(dplyr)


library(ggplot2)
library(gridExtra)
library(GGally)

##############################################################################################
# loading csv data to dataframe 
##############################################################################################
df<-read.csv("BankChurners.csv")
df

##############################################################################################
#Getting familiar with data
##############################################################################################
dim(df)
colnames(df)
str(df)
summary(df)

# Checking the head of the dataset
head(df)
head(df,10)

# Checking the tail of the dataset
tail(df)

# number of missing values:
colSums(is.na(df))
#Percentage of missing values:
round(colMeans(is.na(df))*100,2)#2:digit=2

#data cleansing is 1)Handling duplicate data 2)Handling Missing Values 3)Handling outliers
#make a copy
df_org<-df
##########################################################################################
#Duplicate Data
#########################################################################################
duplicated(df)# returns for you TRUE for observation that is duplicated otherwise returns FALSE
#Note: an observation considered duplicated if values of all features are exactly the same as another observation

#How many duplicated data are there?
sum(duplicated((df)))#--> there are no duplicated data

#checking columns 
names(df)
#or
colnames(df)
str(df)

# Getting the summary of Data
summary(df)


#dropping features are only for identification and we don't have any knowlege to extract meaningfull features from them

dim(df)
str(df)
dfsource<-df#backup
head(df)
tail(df)
duplicated(df)#checking for duplicated data
sum(duplicated(df))
sum(is.na(df))
df[df=='']<-NA#Assigning NA to missing Values
colnames(df)
names(df)
cat <- df %>% select(Attrition_Flag,Gender,Education_Level,Marital_Status,Income_Category,Card_Category)
 #dropping features are only for identification and the ones we don't have any knowlege to extract meaningfull features from them
df[,c("CLIENTNUM","Naive_Bayes_Classifier_Attrition_Flag_Card_Category_Contacts_Count_12_mon_Dependent_count_Education_Level_Months_Inactive_12_mon_1","Naive_Bayes_Classifier_Attrition_Flag_Card_Category_Contacts_Count_12_mon_Dependent_count_Education_Level_Months_Inactive_12_mon_2")]<-NULL

library(tidyverse)
#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

#Q1
##what is the distribution of target(Attrition_Flag)?
##how many missing values we have for Attrition_Flag

sum(is.na(df$Attrition_Flag))
#We have Zero missing values for target.
#since target is categorical variable, in univaraite Analysis 
                       #for summarization:find frequency 
                       #for visualization: pie chart or barchart 
#Summarization

tbl<-aggregate(df$Attrition_Flag,list(df$Attrition_Flag),length)
tbl

#Visualization

# Pie Chart with Percentages
count<-table(df$Attrition_Flag)
count
lbls <- c("Attrited Customer", "Existing Customer ")
pct <- round(count/sum(count)*100)
lbls <- paste(lbls, pct) # add percents to labels
lbls <- paste(lbls,"%",sep="") # ad % to labels
pie(count,labels = lbls, col=rainbow(length(lbls)),
    main="Status of Customer")
#as you can see we have 84% Existing Customer and 14% Attired Customers, so we are dealing with unbalanced data
#simple Bar Plot
barplot(table(df$Attrition_Flag),main="Status of Customer",
        ylab="Number",col = 'red',horiz = FALSE)

#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
#Q2

#what is the distribution of Card_Category?
#how many missing values we have for Card_Category
sum(is.na(df$Card_Category))

#we don't have missing value for Card_Category

#since Card_Category is categorical variable, in univaraite Analysis 
          #for summarization:find frequency 
          #for visualization: pie chart or barchart 
#Summarization

tbl<-aggregate(df$Card_Category,list(df$Card_Category),length)
tbl


# Pie Chart with Percentages
count<-table(df$Card_Category)
count
lbls <- c("Blue", "Gold","Platinum","Silver")
pct <- round(count/sum(count)*100,2)
lbls <- paste(lbls, pct) # add percents to labels
lbls <- paste(lbls,"%",sep="") # ad % to labels
pie(count,labels = lbls, col=rainbow(length(lbls)),
    main="Pie Chart of Card Categories")
#as you can see we have 93.18% of the Card belongs to Blue 1.15% to Gold ,2.20 to Platinum and 5.48% to Silver.

barplot(table(df$Card_Category),main="Card Categories",
        ylab="Number",col = 'red',horiz = FALSE)

# what is Distribution of Attrited Customer by Card Category

cat %>%
  select(Attrition_Flag,Card_Category) %>%
  ggplot(aes(x=Attrition_Flag,fill=Card_Category)) +
  geom_bar(position="dodge") +
  geom_text(aes(y = (..count..)/sum(..count..), 
                label = paste0(round(prop.table(..count..) * 100,2), '%')), 
            stat = 'count', 
            position = position_dodge(.9), 
            size = 5,
            vjust=-2)+
  labs(title="Distribution of Attrited Customer by Card Category",
       subtitle = "Percentages relative to the total",
       x="Attrition_Flag",y="Count")

#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

#Q3

#what is the distribution of attrition flag by Gender,Income and education level
tbl <-table(df$Attrition_Flag,df$Income_Category,df$Gender)
tbl

cat %>%
  select(Attrition_Flag,Income_Category,Education_Level,Gender)  %>%
  mutate(Gender = ifelse(Gender == "F","Female","Male")) %>%
  ggplot(aes(x=Attrition_Flag,fill=Education_Level)) +
  geom_bar(position="dodge") +
  facet_grid(Income_Category~Gender) + 
  labs(title="Distribution of Attrited Customer by Gender,Income Category and Education level",
       x="Attrition_Flag",y="Count")
#Most of the Attrited costumers are Female, below the 40k income range and Graduate students.
#The same can be said by Male costumers, but they are more spread among income ranges.

library(gridExtra)
#Q4,#q9.What is the distribution of total transaction count and total transaction amount on credit card by Attrition flag
p1 <-ggplot(df,aes(x=Total_Trans_Ct,fill=Attrition_Flag)) +
  geom_bar(alpha=0.4,position="dodge") +
  labs(title="Distribution of Total Transaction Count by Customer type",
       x="Total Transaction Count",y="Count")
p1
p2 <-ggplot(df,aes(x=Total_Trans_Amt,fill=Attrition_Flag)) +
  geom_density(alpha=0.4) +
  labs(title="Distribution of Total Transaction Amount by Customer type",
       x="Total Transaction Amount",y="Density")

grid.arrange(p1, p2, nrow = 2)

#Attrited customers peform fewer transactions at lower amounts.
#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

#Q4

#.What is the distribution of total revolving balance on credit card by Attrition flag

cat %>% 
  select(Total_Revolving_Bal,Attrition_Flag) %>%
  ggplot(aes(x=Total_Revolving_Bal,fill=Attrition_Flag)) +
  geom_density(alpha=0.4)+
  labs(title="Distribution of Total Revolving Balance on the Credit Card by Customer type",
       x="Total Revolving Balance on the Credit Card",y="Density")
p<-ggplot(df, aes(x=Total_Revolving_Bal, fill=Attrition_Flag, color=Attrition_Flag)) +
  geom_density(position="identity", alpha=0.5)
p
# Attired Customers are more numerous on lower total balance than existing customers.
p<-ggplot(df, aes(x=Total_Revolving_Bal, fill=Attrition_Flag, color=Attrition_Flag)) +
  geom_histogram(position="identity", alpha=0.5)
p

#existing customers have more revolving balance than the attried customers






#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>





#Q5

#what is the ditribution of Attrition flag based on Gender

#what is the relation between Gender and target(Attrition_Flag)?
sum(is.na(df$Gender))
# we do not have any missing values for Gender
table(df$Gender)#-->it can be seen that Bank have more number of female customers than males ones.(f=5358,M=4769)
addmargins(xtabs(~ Gender+Attrition_Flag,data=df))
prop.table(xtabs(~ Gender+Attrition_Flag,data=df)) 

cat <- df %>% select(Attrition_Flag,Gender,Education_Level,Marital_Status,Income_Category,Card_Category,Customer_Age,Credit_Limit,Dependent_count,Total_Revolving_Bal)
cat
cat %>%
  select(Attrition_Flag,Gender) %>%
  mutate(Gender = ifelse(Gender == "F","Female","Male")) %>%
  ggplot(aes(x=Attrition_Flag,fill=Gender)) +
  geom_bar(position="dodge") +
  geom_text(aes(y = (..count..)/sum(..count..), 
                label = paste0(round(prop.table(..count..) * 100,2), '%')), 
            stat = 'count', 
            position = position_dodge(.9), 
            size = 5,
            vjust=-1)+
  labs(title="Distribution of Attrited Customer by Gender",
       subtitle = "Percentages relative to the total",
       x="Attrition_Flag",y="Count")
#we can see that  among the 
          # Attired customers(16%)-->9.18% belongs to Female and 6.88% belongs to Male
          # Existing customers(84%)-->43.72% belongs to Female and 40.21% belongs to Male


#Problem:
#Test the hypothesis whether the Attrition_Flag is independent of the "Gender"   at .05 significance level.
# Null hypothesis  Attrition_Flag is independent of  Customer_Age

#Solution

tbl <-table(df$Attrition_Flag,df$Gender)
tbl              # the contingency table
chisq.test(tbl)
#Answer:
#As the p-value p-value = 0.0001964 is less than the .05 significance level, we reject the null hypothesis that
#the Attrition_Flag is independent of the Gender so there is association between it at 5% significant level

###############################
#6)what is the relation between Marital_Status and target(Attrition_Flag)?

sum(is.na(df$Marital_Status))# we dont have any missing values
table(df$Marital_Status)
addmargins(xtabs(~ Marital_Status+Attrition_Flag,data=df))
prop.table(xtabs(~ Marital_Status+Attrition_Flag,data=df))
select(Attrition_Flag,Marital_Status) %>%
  cat %>%
  ggplot(aes(x=Attrition_Flag,fill=Marital_Status)) +
  geom_bar(position="dodge") +
  geom_text(aes(y = (..count..)/sum(..count..), 
                label = paste0(round(prop.table(..count..) * 100,2), '%')), 
            stat = 'count', 
            position = position_dodge(.9), 
            size = 5,
            vjust=-2)+
  labs(title="Distribution of Attrited Customer by Marital Status",
       subtitle = "Percentages relative to the total",
       x="Attrition_Flag",y="Count")
#Problem:
#Test the hypothesis whether the Attrition_Flag is independent of the Marital_Status at .05 significance level.
# Null hypothesis Attrition_Flag is independent of  Marital_Status

#Solution
#We apply the chisq.test function to the contingency table tbl, and found the p-value to be 0.1089
tbl <- table(df$Attrition_Flag,df$Marital_Status)
tbl
tbl# the contingency table
chisq.test(tbl)
#Answer:
#As the p-value 0.1089 is grrater than the .05 significance level, we accept the null hypothesis that
#the Attrition_Flag is independent of the Marital_Status
#so the Attrition_Flag and Maital status are not statistically significantly associated 
#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>


#Q7#what is the ditribution of Attrition flag based on Education Level and what is the relation between two.

sum(is.na(df$Education_Level))# we dont have any missing values
table(df$Education_Level)
addmargins(xtabs(~ Education_Level+Attrition_Flag,data=df))
prop.table(xtabs(~ Education_Level+Attrition_Flag,data=df))

cat %>%
  select(Attrition_Flag,Education_Level) %>%
  ggplot(aes(x=Attrition_Flag,fill=Education_Level)) +
  geom_bar(position="dodge") +
  geom_text(aes(y = (..count..)/sum(..count..), 
                label = paste0(round(prop.table(..count..) * 100,2), '%'),
  ), 
  stat = 'count', 
  position = position_dodge(.9), 
  size = 5,
  vjust=-2)+
  labs(title="Distribution of Attrited Customer by Education Level",
       subtitle = "Percentages relative to the total",
       x="Attrition_Flag",y="Count")

#OR

ggplot(df,aes(x=Attrition_Flag,fill=Education_Level)) +
  geom_bar(position="dodge") +
  geom_text(aes(y = (..count..)/sum(..count..), 
                label = paste0(round(prop.table(..count..) * 100,2), '%'),
  ), 
  stat = 'count', 
  position = position_dodge(.9), 
  size = 5,
  vjust=-2)+
  labs(title="Distribution of Attrited Customer by Education Level",
       subtitle = "Percentages relative to the total",
       x="Attrition_Flag",y="Count")

#Problem:
#Test the hypothesis whether the Attrition_Flag is independent of the Education_Level at .05 significance level.
# Null hypothesis Attrition_Flag is independent of  Education_Level

#Solution
#We apply the chisq.test function to the contingency table tbl, and found the p-value to be 0.05149
tbl <- table(df$Attrition_Flag,df$Education_Level)
tbl
tbl# the contingency table
chisq.test(tbl)
#Answer:
#As the p-value 0.05149 is grrater than the .05 significance level, we accept the null hypothesis that
#the Attrition_Flag is independent of the Education_Level
#so the Attrition_Flag and Education_Level are not statistically significantly associated 
#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

#Q8.Is there any difference between Mean of Months on book(Period of relationship with bank) among groups  


#the means of Months_on_book and Attrition_Flag are equal to each other. The assumption for the test is that both groups are sampled from normal distributions with equal variances
#The null hypothesis is that the two means are equal, and the alternative is that they are not. 
summary(df$Months_on_book) 

#categorical Vs Continous
t.test(Months_on_book~Attrition_Flag,data=df) 
boxplot(Months_on_book ~ Attrition_Flag,data=df, main="Months_on_book",
        xlab="Attrition_Flag", ylab="Months_on_book",col="blue")

#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

#Q9.Is there any relation between Total_Trans_Amt: Last 12 months of Total Transaction Amount
#Total_Trans_Ct: Last 12 months of Total Transaction Count


cor(df$Total_Trans_Ct,df$Total_Trans_Amt)# Pearson correlation coefficient=0.807192

#A correlation coefficient greater than zero indicates a positive relationship:Asthe count of transaction increased total transaction amount as well increaded

plot(df$Total_Trans_Ct, df$Total_Trans_Amt, type = "p", #"p" for points
     main = "Total_Trans_Amt vs. Total_Trans_Ct",#an overall title for the plot
     sub = "scatter plot",#a sub title for the plot:
     xlab = "Total_Trans_Ctt", ylab = "Total_Trans_Amt",
     col=10, #col=color
     pch=16, cex=1.5)

install.packages("GGally")
library(GGally)
mydata <- df[,c(17,18)]
ggpairs(mydata)

summary(df$Credit_Limit)
colnames(df)





#Q10:what is the Distribution of Attrited Customer by income category
#what is the relation between income category and target(Attrition_Flag)?
sum(is.na(df$Income_Category))
# we do not have any missing values for Gender
table(df$Income_Category)#-->it can be seen that Bank have more number of customers at than $40K  Income_Category(3561).
addmargins(xtabs(~ Income_Category+Attrition_Flag,data=df))
prop.table(xtabs(~ Income_Category+Attrition_Flag,data=df)) 



cat %>% select(Attrition_Flag,Income_Category) %>%
  ggplot(aes(x=Attrition_Flag,fill=Income_Category)) +
  geom_bar(position="dodge") +
  geom_text(aes(y = (..count..)/sum(..count..), 
                label = paste0(round(prop.table(..count..) * 100,2), '%')), 
            stat = 'count', 
            position = position_dodge(.9), 
            size = 5,
            vjust=-1)+
  labs(title="Distribution of Attrited Customer by Income Category",
       subtitle = "Percentages relative to the total",
       x="Attrition_Flag",y="Count")
#we can see that  among the 
# Attired customers(16%)-->1.24% belongs to $120k+,2.68% to $40-$60 K,1.87% to $60-$80 K,2.39% to $80K-$120K,6.04% to less than 40K and 1.85%belongs to unknown.
# Existing customers(84%)-->5.93% belongs to $120k+,15% to $40-$60 K,11.98% to $60-$80 K,12.77% to $80K-$120K,29.12% to less than 40K and 9.13%belongs to unknown.
#in both the categories majority of the customers belong to less than $40 k income group

#Problem:
#Test the hypothesis whether the Attrition_Flag is independent of the income group   at .05 significance level.
# Null hypothesis  Attrition_Flag is independent of  income group

#Solution

tbl <-table(df$Attrition_Flag,df$Income_Category)
tbl              # the contingency table
chisq.test(tbl)
#Answer:
#As the p-value p-value = 0.025 is less than the .05 significance level, we reject the null hypothesis that
#the Attrition_Flag is independent of the Income group so there is association between it at 5% significant level


#Q12.Is there any relation between Credit_Limit and Total_Revolving_Bal?


cor(df$Credit_Limit,df$Total_Revolving_Bal)# Pearson correlation coefficient=0.04249261

#A correlation coefficient greater than zero indicates a positive relationship:As the credit limit increased total total revolving balance as well increaded

plot(df$Credit_Limit,df$Total_Revolving_Bal, type = "p", #"p" for points
     main = "Credit_Limit vs. Total_Revolving_Bal",#an overall title for the plot
     sub = "scatter plot",#a sub title for the plot:
     xlab = "Credit_Limit", ylab = "Total_Revolving_Bal",
     col=10, #col=color
     pch=16, cex=1.5)

mydata <- df[,c(13,14)]
ggpairs(mydata)








  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  