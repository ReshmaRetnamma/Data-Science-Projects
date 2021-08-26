/*SQL PROJECT on Banking Transactions by RESHMA RETNAMMA */

-- PHASE I 

--Q1. Create a database for a banking application called 'Bank'. 

create database dbCanadianBank;
GO
use dbCanadianBank
GO

--Q2. Create all the tables mentioned in the database diagram. 
--Q3. Create all the constraints based on the database diagram. 


/* CREATE TABLE & ADD CONSTRAINTS*/
-- Creating tables THAT HAS only primary keys first 

/************************ TABLE 1-UserLogins*********************************/


CREATE TABLE UserLogins
(
	UserLoginID SMALLINT NOT NULL IDENTITY(1,1) PRIMARY KEY,
	UserLogin VARCHAR(50) NOT NULL,
	UserPassword VARCHAR(20) NOT NULL);
GO

/************************ TABLE 2-UserSecurityQuestions*********************************/

CREATE TABLE UserSecurityQuestions
(
	UserSecurityQuestionID TINYINT NOT NULL IDENTITY(1,1) PRIMARY KEY,
	UserSecurityQuestion VARCHAR(50) NOT NULL);
GO

/************************ TABLE 3-AccountType*********************************/


CREATE TABLE AccountType
(
	AccountTypeID TINYINT NOT NULL IDENTITY(1,1) PRIMARY KEY,
	AccountTypeDescription VARCHAR(30) NOT NULL);
GO


/************************ TABLE 4-SavingsInterestRates*********************************/

CREATE TABLE SavingsInterestRates
(
	InterestSavingRatesID TINYINT NOT NULL IDENTITY(1,1) PRIMARY KEY,
	InterestRatesValue NUMERIC(9,9) NOT NULL, 
	InterestRatesDescription VARCHAR(20) NOT NULL);
GO

/************************ TABLE 5-AccountStatusType*********************************/

CREATE TABLE AccountStatusType
(
	AccountStatusTypeID TINYINT NOT NULL IDENTITY(1,1) PRIMARY KEY,
	AccountStatusTypeDescription VARCHAR(30) NOT NULL);
GO

/************************ TABLE 6-FailedTransactionErrorType*********************************/

CREATE TABLE FailedTransactionErrorType
(
	FailedTransactionErrorTypeID TINYINT NOT NULL IDENTITY(1,1) PRIMARY KEY,
	FailedTransactionErrorTypeDescription VARCHAR(50) NOT NULL);

GO

/************************ TABLE 7-LoginErrorLog*********************************/

CREATE TABLE LoginErrorLog
(
	ErrorLogID INT NOT NULL IDENTITY(1,1) PRIMARY KEY,
	ErrorTime DATETIME NOT NULL,
	FailedTransactionXML XML)

GO

/************************ TABLE 8-Employee*********************************/

CREATE TABLE Employee
(
	EmployeeID INT NOT NULL IDENTITY(1,1) PRIMARY KEY,
	EmployeeFirstName VARCHAR(25) NOT NULL,
	EmployeeMiddleInitial CHAR(1),
	EmployeeLastName VARCHAR(25),
	EmployeeisManager BIT);
GO

/************************ TABLE 9-TransactionType*********************************/

CREATE TABLE TransactionType
(
	TransactionTypeID TINYINT NOT NULL IDENTITY(1,1) PRIMARY KEY,
	TransactionTypeName CHAR(10) NOT NULL,
	TransactionTypeDescription VARCHAR(50),
	TransactionFeeAmount SMALLMONEY);
GO



-- CREATING TABLES WITH FOREIGN KEY AND COMBINATION OF BOTH PRIMARY AND FOREIGN KEYS


/************************ TABLE 10-FailedTransactionLog*********************************/

CREATE TABLE FailedTransactionLog
(
	FailedTransactionID INT NOT NULL IDENTITY(1,1)PRIMARY KEY,
	FailedTransactionErrorTypeID TINYINT NOT NULL REFERENCES 
	FailedTransactionErrorType(FailedTransactionErrorTypeID),
	FailedTransactionErrorTime DATETIME,
	FailedTransactionErrorXML XML);

	/************************ TABLE 11-UserSecurityAnswer*********************************/

CREATE TABLE UserSecurityAnswers
(
	UserLoginID SMALLINT NOT NULL IDENTITY(1,1) PRIMARY KEY REFERENCES UserLogins(UserLoginID),
	UserSecurityAnswers VARCHAR(25) NOT NULL,
	UserSecurityQuestionID TINYINT NOT NULL REFERENCES
	UserSecurityQuestions(UserSecurityQuestionID));
GO

/************************ TABLE 12-Account*********************************/


CREATE TABLE Account
(
	AccountID INT NOT NULL IDENTITY(1,1) PRIMARY KEY,
	CurrentBalance INT NOT NULL,
	AccountTypeID TINYINT NOT NULL REFERENCES AccountType (AccountTypeID),
	AccountStatusTypeID TINYINT NOT NULL REFERENCES AccountStatusType(AccountStatusTypeID),
	InterestSavingRatesID TINYINT NOT NULL REFERENCES 
	SavingsInterestRates(InterestSavingRatesID));
	ALTER TABLE Account Alter COLUMN CurrentBalance Money;

	/************************ TABLE 13-Login_Account*********************************/
CREATE TABLE LoginAccount
(
	UserLoginID SMALLINT NOT NULL REFERENCES UserLogins(UserLoginID),
	AccountID INT NOT NULL REFERENCES Account(AccountID)
);

GO



/************************ TABLE 14-Customer*********************************/
CREATE TABLE Customer
(
	CustomerID INT NOT NULL IDENTITY(1,1) PRIMARY KEY,
	AccountID INT NOT NULL REFERENCES Account(AccountID),
	CustomerAddress1 VARCHAR(30) NOT NULL,
	CustomerAddress2  VARCHAR(30),
	CustomerFirstName  VARCHAR(30) NOT NULL,
	CustomerMiddleInitial CHAR(1),
	CustomerLastName  VARCHAR(30) NOT NULL,
	City  VARCHAR(20) NOT NULL,
	State CHAR(2) NOT NULL,
	ZipCode CHAR(10) NOT NULL,
	EmailAddress CHAR(40) NOT NULL,
	HomePhone VARCHAR(10) NOT NULL,
	CellPhone VARCHAR(10) NOT NULL,
	WorkPhone VARCHAR(10) NOT NULL,
	SSN VARCHAR(9),
	UserLoginID SMALLINT NOT NULL REFERENCES UserLogins(UserLoginID));
GO

/************************ TABLE 15-Customer-Account*********************************/

CREATE TABLE CustomerAccount
(
	AccountID INT NOT NULL REFERENCES Account(AccountID) ,
	CustomerID INT NOT NULL REFERENCES Customer(CustomerID));
GO

/************************ TABLE 16-TransactionLog*********************************/

CREATE TABLE TransactionLog
(
	TransactionID INT NOT NULL IDENTITY(1,1) PRIMARY KEY,
	TransactionDate DATETIME NOT NULL,
	TransactionTypeID TINYINT NOT NULL REFERENCES TransactionType(TransactionTypeID),
	TransactionAmount Money NOT NULL,
	NewBalance Money NOT NULL,
	AccountID INT NOT NULL REFERENCES Account(AccountID),
	CustomerID INT NOT NULL REFERENCES Customer(CustomerID),
	EmployeeID INT NOT NULL REFERENCES Employee(EmployeeID),
	UserLoginID SMALLINT NOT NULL REFERENCES UserLogins(UserLoginID));

GO

/************************ TABLE 17-OverDraftLog*********************************/
CREATE TABLE OverDraftLog
(
	AccountID INT NOT NULL PRIMARY KEY REFERENCES Account(AccountID),
	OverDraftDate DATETIME NOT NULL,
	OverDraftAmount Money NOT NULL,
	OverDraftTransactionXML XML NOT NULL);
GO

select * from OverDraftLog

/**********************INSERTING VALUES*************************************/

INSERT INTO UserLogins VALUES
('User1','Password1'),
('User2','Password2'),
('User3','Password3'),
('User4','Password4'),
('User5','Password5')
select*from UserLogins


INSERT INTO UserSecurityQuestions VALUES
('Whis is your favorite city'),
('What is the name of your first school?'),
('Your Mothers maiden name?'),
('What is the name of your first pet?'),
('Which is the website you use the most?')

select * from UserSecurityQuestions

Insert into AccountType values('Savings'),('Checking');
go

insert into SavingsInterestRates values(0.5, 'Very Low'),(0.6, 'Low'),(0.7, 'Medium High'),
										(0.8, 'High'),(0.9, 'Very High');
GO
select * from SavingsInterestRates
go


INSERT INTO AccountStatusType VALUES
('Active'),
('Inactive'),
('Freezed'),
('Closed'),
('Dormant')

select * from AccountStatusType;

INSERT INTO FailedTransactionErrorType VALUES 
('WRONG USERLOGIN'),
('WRONG PASSWORD'),
('EXCEEDS THE TRANSACTION LIMIT'),
('DOES NOT HAVE ENOUGH ACCOUNT BALANCE'),
('ATM MACHINE OUT OF SERVICE')

SELECT * FROM FailedTransactionErrorType

INSERT INTO LoginErrorLog VALUES(TRY_CAST('2015/6/4 07:30:56' AS DATETIME), 'BAD CONNECTION'),
	(TRY_CAST('2020/6/9 13:24:37' AS DATETIME), 'INVALID USER'),
	(TRY_CAST('2020/3/5 02:14:00' AS DATETIME), 'WRONG PASSWORD'),
	(TRY_CAST('2020/8/5 05:56:59' AS DATETIME), 'SERVER DOWN'),
	(TRY_CAST('2020/5/12 08:34:15' AS DATETIME), 'MULTIPLE ATTEMPTS');
	GO
	SELECT * FROM LoginErrorLog
	GO

INSERT INTO Employee VALUES('Ram','M','Mohan',0),
('Sara','K','Benny',1),
('Priya','M','Mohan',0),
('Linda','V','Manoj',1),
('Sunitha','K','Pillai',0)
select *from Employee

GO

insert into TransactionType values
('Balance','Check the current Balance', 0),
('Transfer','Send money to other Account', 4),
('Receive','credited from other Account', 3),
('NewCard','Card Replacement', 10),
('Statement','Checked monthly transaction', 0);

select * from TransactionType

go


Insert into FailedTransactionLog values
(1,TRY_CAST('2015/6/4 07:30:56' AS DATETIME), 'First Attempt'),
(2,TRY_CAST('2018/6/9 12:34:57' AS DATETIME), 'Second Attempt'),
(3,TRY_CAST('2016/4/5 02:14:00' AS DATETIME), 'Third Attempt'),
(4,TRY_CAST('2014/7/5 05:56:59' AS DATETIME), 'Fourth Attempt'),
(5,TRY_CAST('2009/10/12 08:34:15' AS DATETIME), 'Fifth Attempt');

select *from FailedTransactionLog

select * from UserSecurityQuestions

INSERT INTO UserSecurityAnswers VALUES('Mumbai',1),
('Facebook',2),
('Tiger',3),
('Menon',4),
('Good Shepered',5)

select * from UserSecurityAnswers

go 
select *from Account
select * from AccountType
select * from AccountStatusType
select *from SavingsInterestRates

Insert into Account values(20000,1,1,5),(50000,2,5,4),
(700,2,1,3),(9278,1,2,2),
(728,2,1,1)
select *from Account

go
insert into LoginAccount values(1,11),(2,12),(3,13)
,(4,14),(5,15)


select * from Customer
select *from LoginAccount


INSERT INTO Customer VALUES
(11,'7578C','ABCD','SITA','L','PILLAI','MISSISSUGA','ON','L4T3P6','SITA@GMAIL.COM',2068326,254554,5656,'A15020',1)
,(12,'3649A','EFG','GITA','P','MENON','MALTON','ON','L4T3P9','GITA@GMAIL.COM',241557,785235,452232,'A2520',2)
,(13,'2800B','HIJ','PRITA','S','VARGHESE','SCABROUGH','BC','L7T3P1','PRITA@GMAIL.COM',523909,6665675,5456,'A7650',3)
,(14,'726G','KLM','MITA','T','JOY','HAMILTON','ON','L3T3P6','MITA@GMAIL.COM',456256,74555,44444,'A3450',4)
,(15,'676P','NOP','PRETTY','G','CHRISTY','MALTON','ON','L6T3P8','PRETTY@GMAIL.COM',2454545,75136,852364,'A2760',5)
select * from Customer


select *from CustomerAccount
INSERT INTO CustomerAccount VALUES(11,1),(12,2),(13,3),(14,4),(15,5)
select *from Employee

select *from TransactionLog
select *from TransactionType

select *from Account

insert into TransactionLog values('2020/5/12 06:30:56', 9,0, 20000, 11, 1, 1, 1),
('2020/3/10 2:04:07', 9,0, 50000, 12, 2, 2, 2),
('2020/4/5 02:14:00', 10,50, 650, 13, 3, 3, 3),
('2020/8/7 02:06:09',11 ,10000, 19278,14, 4, 4, 4),
('2020/10/6 08:04:15',10,500, 228, 15, 5, 5, 5);


Select * from OverDraftLog

insert into OverDraftLog values
(11,'2020/9/2 05:10:26', 10, 'Paid'),
(12,'2020/3/9 02:34:57', 5, 'Pending'),
(13,'2020/7/5 02:04:05', 10, 'Paid'),
(14,'2020/8/5 05:26:09', 55, 'Pending'),
(15,'2020/9/12 08:34:15', 0, 'Paid');

/**************************************************************************************************/

-----------------------------------------PHASE 2----------------------------------------------
--Q1. Create a view to get all customers with checking account from ON province. 

DROP VIEW CheckingCustomersON1_view;

CREATE VIEW CheckingCustomersON1_view AS
select customerID,CustomerFirstName+''+CustomerMiddleInitial+' '+CustomerLastName 
AS CustomerName,State,AccountTypeDescription
from customer join Account
on customer.AccountID = Account.AccountID join AccountType 
on Account.AccountTypeID=AccountType.AccountTypeID
where AccountType.AccountTypeDescription='Checking'and customer.State='ON'
go

select *from CheckingCustomersON1_view

go

--Q2. Create a view to get all customers with total account balance (including interest rate) greater than 5000. 

Drop view Customerabove5000_view

CREATE VIEW Customerabove5000_view AS
SELECT CustomerFirstName,CurrentBalance, 
SUM(Account.CurrentBalance+((Account.CurrentBalance*SavingsInterestRates.InterestRatesValue)/100)/12) 
AS Total_Ac_Balance 
FROM Account
JOIN Customer
ON Customer.AccountID = Account.AccountId
JOIN SavingsInterestRates 
ON Account.InterestSavingRatesID = SavingsInterestRates.InterestSavingRatesID 
GROUP BY Customer.CustomerFirstName,CurrentBalance
HAVING SUM(Account.CurrentBalance + ((Account.CurrentBalance*SavingsInterestRates.InterestRatesValue)/100)/12) > 5000;
GO
select Customer.CustomerFirstName,Account.CurrentBalance FROM Account
JOIN Customer
ON Customer.AccountID = Account.AccountId
select *from Customerabove5000_view

go


--Q3. Create a view to get counts of checking and savings accounts by customer. 



drop VIEW CountOfAccounts2



CREATE VIEW CountOfAccounts2 AS
SELECT Customer.CustomerID,Customer.CustomerFirstName, COUNT (AccountType.AccountTypeID) AS AccountTypeNumber, AccountType.AccountTypeDescription
FROM Customer  JOIN Account  ON Customer.AccountID = Account.AccountID
                JOIN AccountType  ON Account.AccountTypeID = AccountType.AccountTypeID
WHERE AccountType.AccountTypeDescription IN ('Savings', 'Checking')
GROUP BY Customer.CustomerID,Customer.CustomerFirstName,AccountType.AccountTypeDescription;

SELECT *FROM CountOfAccounts2
go

--Q4. Create a view to get any particular user's login and password using AccountId.
drop view Userlogin_view
go

select * from UserLogins
go

CREATE VIEW Userlogin_view AS
select Account.AccountID,UserLogins.UserLoginID,UserLogins.UserLogin,UserPassword
from LoginAccount 
join Account on Account.AccountID = LoginAccount.AccountID 
join UserLogins on LoginAccount.UserLoginID=UserLogins.UserLoginID

go
select *from Userlogin_view
go

/*********************OR**************************************/
Drop VIEW Userlogin3_view
go

CREATE VIEW Userlogin3_view AS
select LoginAccount.AccountID,UserLogins.UserLoginID,UserLogins.UserLogin,UserPassword
from LoginAccount 
join UserLogins on LoginAccount.UserLoginID=UserLogins.UserLoginID

go
select *from Userlogin3_view
go


--Q5. Create a view to get all customers overdraft amount. 

Drop VIEW Useroverdraft_view


go

CREATE VIEW Useroverdraft_view AS
select Customer.AccountID,Customer.CustomerFirstName+' '+Customer.CustomerMiddleInitial+
' '+Customer.CustomerLastName AS CustomerName,OverDraftLog.OverDraftAmount
from Customer join OverDraftLog on Customer.AccountID = OverDraftLog.AccountID 
where OverDraftLog.OverDraftAmount>0

select *from Useroverdraft_view
go

--Q6. Create a stored procedure to add "User_" as a prefix to everyone's login (username). 

DROP PROCEDURE sp_UpdateLogin;
GO

CREATE PROCEDURE sp_UpdateLogin
AS
--begin
	if exists(select * from UserLogins where LEFT(UserLogin,5)='USER_')
	print'Updation denied,UserLogin already has User_ in it'
	else
	UPDATE UserLogins
	SET UserLogin = Concat('User_', UserLogin);
--end
GO
EXEC sp_UpdateLogin;
select *from UserLogins
GO

--Q7. Create a stored procedure that accepts AccountId as a parameter and returns customer's full name. 


drop procedure spfullname
go

create procedure spfullname @i int, @Fullname nvarchar(100) output
as
begin
if exists(select * from Customer where AccountId=@i)
	begin
	select @Fullname=[CustomerFirstName]+' '+[CustomerMiddleInitial]+' '+[CustomerLastName]
	from Customer where AccountId=@i
	end
else
	begin
	print 'There is no Customer with this id'
	end
end
	go
Declare @FullName nvarchar(100)
exec spfullname 11,@FullName out/*valid accountid*/
Print ' Full name is '+replace (@FullName,'   ',' ')
Declare @FullName nvarchar(100)
exec spfullname 66,@FullName out /*Invalid accountid*/
Print ' Full name is '+replace (@FullName,'   ',' ')


--Q8. Create a stored procedure that returns error logs inserted in the last 24 hours. 

DROP PROCEDURE spErrorsloglessthan24;
GO

INSERT INTO LoginErrorLog VALUES(TRY_CAST('2020/12/23 07:30:56' AS DATETIME), 'network error')
INSERT INTO LoginErrorLog VALUES(TRY_CAST('2020/02/12 07:30:56' AS DATETIME), 'network error')
go

CREATE PROCEDURE spErrorsloglessthan24
AS
SELECT * FROM LoginErrorLog
WHERE ErrorTime >= DATEADD(HOUR, -24,GETDATE());
GO

EXEC spErrorsloglessthan24;
GO

/***************************************OR********************************************************/
DROP PROCEDURE spErrorsloglessthannew24
go

CREATE PROCEDURE spErrorsloglessthannew24
AS
begin
SELECT * FROM LoginErrorLog
WHERE ErrorTime between DATEADD(HOUR, -24,GETDATE()) and getdate();
end
GO

EXEC spErrorsloglessthannew24;
GO

--Q9. Create a stored procedure that takes a deposit as a parameter and updates CurrentBalance 
      -- value for that particular account.*/  

DROP PROCEDURE spCurrentBalanceAfterDeposit;
GO

CREATE PROCEDURE spCurrentBalanceAfterDeposit @AccountID INT, @Deposit Money
AS
select AccountID,CurrentBalance from Account where AccountID=@AccountID
UPDATE Account
SET CurrentBalance = CurrentBalance + @Deposit
where AccountID = @AccountID;
select AccountID,CurrentBalance from Account where AccountID=@AccountID
GO

EXEC spCurrentBalanceAfterDeposit 13, 300;
GO

select *from Account

--Q10. Create a stored procedure that takes a withdrawal amount as a parameter and updates CurrentBalance value for that particular account. 

DROP PROCEDURE spBalanceafterWithdrawal;
GO

CREATE PROCEDURE spBalanceafterWithdrawal @AccountID INT, @Withdrawal Money
AS
select AccountID,CurrentBalance from Account where AccountID=@AccountID
UPDATE Account
SET CurrentBalance = CurrentBalance - @Withdrawal
WHERE AccountID = @AccountID;
select AccountID,CurrentBalance from Account where AccountID=@AccountID
GO

EXEC spBalanceafterWithdrawal 13, 300;
GO
select *from Account