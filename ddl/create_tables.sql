ALTER SESSION SET "_ORACLE_SCRIPT"=true; 

CREATE USER DW_TPCDI_SF6 IDENTIFIED BY tpcdisf6;

ALTER SESSION SET current_schema = DW_TPCDI_SF6;


-- AUDIT 
CREATE TABLE "AUDIT" (
	DATASET VARCHAR2(2000) NULL,
	BATCHID NUMBER(38,0) NULL,
	"Date" VARCHAR2(2000) NULL,
	"ATTRIBUTE" VARCHAR2(2000) NULL,
	VALUE NUMBER(38,0) NULL,
	DVALUE NUMBER NULL
);


-- DIMBROKER
CREATE TABLE DIMBROKER (
	SK_BROKERID NUMBER(38,0) NOT NULL,
	BROKERID NUMBER(38,0) NULL,
	MANAGERID NUMBER(38,0) NULL,
	FIRSTNAME VARCHAR2(50) NULL,
	LASTNAME VARCHAR2(50) NULL,
	MIDDLEINITIAL VARCHAR2(1) NULL,
	BRANCH VARCHAR2(50) NULL,
	OFFICE VARCHAR2(50) NULL,
	PHONE VARCHAR2(14) NULL,
	ISCURRENT CHAR(1) NULL,
	BATCHID NUMBER(38,0) NULL,
	EFFECTIVEDATE DATE NULL,
	ENDDATE DATE NULL,
	CONSTRAINT DIMBROKER_PK PRIMARY KEY (SK_BROKERID)
);


-- DIMCUSTOMER 
CREATE TABLE DIMCUSTOMER (
	SK_CUSTOMERID NUMBER(38,0) NOT NULL,
	CUSTOMERID NUMBER(38,0) NULL,
	TAXID VARCHAR2(2000) NULL,
	STATUS VARCHAR2(2000) NULL,
	LASTNAME VARCHAR2(2000) NULL,
	FIRSTNAME VARCHAR2(2000) NULL,
	MIDDLEINITIAL VARCHAR2(2000) NULL,
	GENDER VARCHAR2(2000) NULL,
	TIER NUMBER NULL,
	DOB DATE NULL,
	ADDRESSLINE1 VARCHAR2(2000) NULL,
	ADDRESSLINE2 VARCHAR2(2000) NULL,
	POSTALCODE VARCHAR2(2000) NULL,
	CITY VARCHAR2(2000) NULL,
	STATEPROV VARCHAR2(2000) NULL,
	COUNTRY VARCHAR2(2000) NULL,
	PHONE1 VARCHAR2(2000) NULL,
	PHONE2 VARCHAR2(2000) NULL,
	PHONE3 VARCHAR2(2000) NULL,
	EMAIL1 VARCHAR2(2000) NULL,
	EMAIL2 VARCHAR2(2000) NULL,
	NATIONALTAXRATEDESC VARCHAR2(50) NULL,
	NATIONALTAXRATE NUMBER(6,5) NULL,
	LOCALTAXRATEDESC VARCHAR2(50) NULL,
	LOCALTAXRATE NUMBER(6,5) NULL,
	AGENCYID VARCHAR2(2000) NULL,
	CREDITRATING NUMBER NULL,
	NETWORTH NUMBER(38,0) NULL,
	MARKETINGNAMEPLATE VARCHAR2(2000) NULL,
	ISCURRENT CHAR(1) NULL,
	BATCHID NUMBER(38,0) NULL,
	ENDDATE DATE NULL,
	EFFECTIVEDATE DATE NULL,
	CONSTRAINT DIMCUSTOMER_PK PRIMARY KEY (SK_CUSTOMERID)
);


-- DIMACCOUNT
CREATE TABLE DIMACCOUNT (
	SK_ACCOUNTID NUMBER(38,0) NOT NULL,
	ACCOUNTID NUMBER(38,0) NULL,
	SK_BROKERID NUMBER(38,0) NULL,
	SK_CUSTOMERID NUMBER(38,0) NULL,
	STATUS VARCHAR2(10) NULL,
	ACCOUNTDESC VARCHAR2(50) NULL,
	TAXSTATUS NUMBER(38,0) NULL,
	ISCURRENT CHAR(1) NULL,
	BATCHID NUMBER(38,0) NULL,
	EFFECTIVEDATE DATE NULL,
	ENDDATE DATE NULL,
	CONSTRAINT DIMACCOUNT_PK PRIMARY KEY (SK_ACCOUNTID),
	CONSTRAINT SK_BROKERID1 FOREIGN KEY (SK_BROKERID) REFERENCES DIMBROKER(SK_BROKERID),
	CONSTRAINT SK_CUSTOMERID1 FOREIGN KEY (SK_CUSTOMERID) REFERENCES DIMCUSTOMER(SK_CUSTOMERID)
);


-- DIMCOMPANY
CREATE TABLE DIMCOMPANY (
	COMPANYID NUMBER(38,0) NULL,
	NAME VARCHAR2(256) NULL,
	SPRATING VARCHAR2(256) NULL,
	CEO VARCHAR2(256) NULL,
	DESCRIPTION VARCHAR2(256) NULL,
	FOUNDINGDATE DATE NULL,
	ADDRESSLINE1 VARCHAR2(256) NULL,
	ADDRESSLINE2 VARCHAR2(256) NULL,
	POSTALCODE VARCHAR2(12) NULL,
	CITY VARCHAR2(256) NULL,
	STATEPROV VARCHAR2(256) NULL,
	COUNTRY VARCHAR2(256) NULL,
	STATUS VARCHAR2(256) NULL,
	INDUSTRY VARCHAR2(256) NULL,
	ISLOWGRADE VARCHAR2(10) NULL,
	ISCURRENT CHAR(1) NULL,
	EFFECTIVEDATE DATE NULL,
	ENDDATE DATE NULL,
	BATCHID NUMBER(38,0) NULL,
	SK_COMPANYID NUMBER(38,0) NOT NULL,
	CONSTRAINT DIMCOMPANY_PK PRIMARY KEY (SK_COMPANYID)
);


-- DIMDATE
CREATE TABLE DIMDATE (
	SK_DATEID NUMBER(38,0) NOT NULL,
	DATEVALUE DATE NULL,
	DATEDESC VARCHAR2(2000) NULL,
	CALENDARYEARID NUMBER(38,0) NULL,
	CALENDARYEARDESC VARCHAR2(2000) NULL,
	CALENDARQTRID NUMBER(38,0) NULL,
	CALENDARQTRDESC VARCHAR2(2000) NULL,
	CALENDARMONTHID NUMBER(38,0) NULL,
	CALENDARMONTHDESC VARCHAR2(2000) NULL,
	CALENDARWEEKID NUMBER(38,0) NULL,
	CALENDARWEEKDESC VARCHAR2(2000) NULL,
	DAYOFWEEKNUM NUMBER(38,0) NULL,
	DAYOFWEEKDESC VARCHAR2(2000) NULL,
	FISCALYEARID NUMBER(38,0) NULL,
	FISCALYEARDESC VARCHAR2(2000) NULL,
	FISCALQTRID NUMBER(38,0) NULL,
	FISCALQTRDESC VARCHAR2(2000) NULL,
	HOLIDAYFLAG CHAR(1) NULL,
	CONSTRAINT DIMDATE_PK PRIMARY KEY (SK_DATEID)
);


-- DIMESSAGES
CREATE TABLE DIMESSAGES (
	MESSAGEDATEANDTIME TIMESTAMP NULL,
	BATCHID NUMBER(5,0) NOT NULL,
	MESSAGESOURCE VARCHAR2(30) NULL,
	MESSAGETEXT VARCHAR2(50) NOT NULL,
	MESSAGETYPE VARCHAR2(12) NOT NULL,
	MESSAGEDATA VARCHAR2(100) NULL,
	CONSTRAINT SYS_C0015506 CHECK ("BATCHID" IS NOT NULL),
	CONSTRAINT SYS_C0015507 CHECK ("MESSAGETEXT" IS NOT NULL),
	CONSTRAINT SYS_C0015508 CHECK ("MESSAGETYPE" IS NOT NULL)
);


-- DIMSECURITY
CREATE TABLE DIMSECURITY (
	SK_SECURITYID NUMBER(38,0) NOT NULL,
	SYMBOL VARCHAR2(15) NULL,
	ISSUE VARCHAR2(6) NULL,
	STATUS VARCHAR2(10) NULL,
	NAME VARCHAR2(70) NULL,
	EXCHANGEID VARCHAR2(6) NULL,
	SK_COMPANYID NUMBER(38,0) NULL,
	SHARESOUTSTANDING NUMBER(38,0) NULL,
	FIRSTTRADE DATE NULL,
	FIRSTTRADEONEXCHANGE DATE NULL,
	DIVIDEND NUMBER(12,2) NULL,
	ISCURRENT CHAR(1) NULL,
	BATCHID NUMBER(38,0) NULL,
	EFFECTIVEDATE DATE NULL,
	ENDDATE DATE NULL,
	CONSTRAINT DIMSECURITY_PK PRIMARY KEY (SK_SECURITYID)
);


-- DIMTIME
CREATE TABLE DIMTIME (
	SK_TIMEID NUMBER(38,0) NOT NULL,
	TIMEVALUE TIMESTAMP NULL,
	HOURID NUMBER NULL,
	HOURDESC VARCHAR2(2000) NULL,
	MINUTEID NUMBER NULL,
	MINUTEDESC VARCHAR2(2000) NULL,
	SECONDID NUMBER NULL,
	SECONDDESC VARCHAR2(2000) NULL,
	MARKETHOURSFLAG CHAR(1) NULL,
	OFFICEHOURSFLAG CHAR(1) NULL,
	CONSTRAINT DIMTIME_PK PRIMARY KEY (SK_TIMEID)
);


-- DIMTRADE
CREATE TABLE DIMTRADE (
	TRADEID NUMBER(38,0) NULL,
	SK_BROKERID NUMBER(38,0) NULL,
	SK_CREATEDATEID NUMBER(38,0) NULL,
	SK_CREATETIMEID NUMBER(38,0) NULL,
	SK_CLOSEDATEID NUMBER(38,0) NULL,
	SK_CLOSETIMEID NUMBER(38,0) NULL,
	STATUS VARCHAR2(10) NULL,
	"TYPE" VARCHAR2(12) NULL,
	CASHFLAG CHAR(1) NULL,
	SK_SECURITYID NUMBER(38,0) NULL,
	SK_COMPANYID NUMBER(38,0) NULL,
	QUANTITY NUMBER(38,0) NULL,
	BIDPRICE NUMBER(8,2) NULL,
	SK_CUSTOMERID NUMBER(38,0) NULL,
	SK_ACCOUNTID NUMBER(38,0) NULL,
	EXECUTEDBY VARCHAR2(64) NULL,
	TRADEPRICE NUMBER(8,2) NULL,
	FEE NUMBER(10,2) NULL,
	COMMISSION NUMBER(10,2) NULL,
	TAX NUMBER(10,2) NULL,
	BATCHID NUMBER(38,0) NULL,
	CONSTRAINT SK_ACCOUNTID FOREIGN KEY (SK_ACCOUNTID) REFERENCES DIMACCOUNT(SK_ACCOUNTID),
	CONSTRAINT SK_BROKERID FOREIGN KEY (SK_BROKERID) REFERENCES DIMBROKER(SK_BROKERID),
	CONSTRAINT SK_CLOSEDATEID FOREIGN KEY (SK_CLOSEDATEID) REFERENCES DIMDATE(SK_DATEID),
	CONSTRAINT SK_CLOSETIMEID FOREIGN KEY (SK_CLOSETIMEID) REFERENCES DIMTIME(SK_TIMEID),
	CONSTRAINT SK_COMPANYID FOREIGN KEY (SK_COMPANYID) REFERENCES DIMCOMPANY(SK_COMPANYID),
	CONSTRAINT SK_CREATEDATEID FOREIGN KEY (SK_CREATEDATEID) REFERENCES DIMDATE(SK_DATEID),
	CONSTRAINT SK_CREATETIMEID FOREIGN KEY (SK_CREATETIMEID) REFERENCES DIMTIME(SK_TIMEID),
	CONSTRAINT SK_CUSTOMERID FOREIGN KEY (SK_CUSTOMERID) REFERENCES DIMCUSTOMER(SK_CUSTOMERID),
	CONSTRAINT SK_SECURITYID FOREIGN KEY (SK_SECURITYID) REFERENCES DIMSECURITY(SK_SECURITYID)
);


-- FACTCASHBALANCES
CREATE TABLE FACTCASHBALANCES (
	SK_CUSTOMERID NUMBER(38,0) NULL,
	SK_ACCOUNTID NUMBER(38,0) NULL,
	SK_DATEID NUMBER(38,0) NULL,
	CASH NUMBER(15,2) NULL,
	BATCHID NUMBER(38,0) NULL,
	CONSTRAINT SK_ACCOUNT3 FOREIGN KEY (SK_ACCOUNTID) REFERENCES DIMACCOUNT(SK_ACCOUNTID),
	CONSTRAINT SK_CUSTOMER3 FOREIGN KEY (SK_CUSTOMERID) REFERENCES DIMCUSTOMER(SK_CUSTOMERID),
	CONSTRAINT SK_DATE3 FOREIGN KEY (SK_DATEID) REFERENCES DIMDATE(SK_DATEID)
);


-- FACTHOLDINGS
CREATE TABLE FACTHOLDINGS (
	TRADEID NUMBER(38,0) NULL,
	CURRENTTRADEID NUMBER(38,0) NULL,
	SK_CUSTOMERID NUMBER(38,0) NULL,
	SK_ACCOUNTID NUMBER(38,0) NULL,
	SK_SECURITYID NUMBER(38,0) NULL,
	SK_COMPANYID NUMBER(38,0) NULL,
	SK_DATEID NUMBER(38,0) NULL,
	SK_TIMEID NUMBER(38,0) NULL,
	CURRENTPRICE NUMBER(38,2) NULL,
	CURRENTHOLDING NUMBER(38,2) NULL,
	BATCHID NUMBER(38,0) NULL,
	CONSTRAINT SK_ACCOUNTID4 FOREIGN KEY (SK_ACCOUNTID) REFERENCES DIMACCOUNT(SK_ACCOUNTID),
	CONSTRAINT SK_COMPANYID4 FOREIGN KEY (SK_COMPANYID) REFERENCES DIMCOMPANY(SK_COMPANYID),
	CONSTRAINT SK_CUSTOMERID4 FOREIGN KEY (SK_CUSTOMERID) REFERENCES DIMCUSTOMER(SK_CUSTOMERID),
	CONSTRAINT SK_DATEID4 FOREIGN KEY (SK_DATEID) REFERENCES DIMDATE(SK_DATEID),
	CONSTRAINT SK_SECURITYID4 FOREIGN KEY (SK_SECURITYID) REFERENCES DIMSECURITY(SK_SECURITYID),
	CONSTRAINT SK_TIMEID4 FOREIGN KEY (SK_TIMEID) REFERENCES DIMTIME(SK_TIMEID)
);


-- FACTMARKETHISTORY
CREATE TABLE FACTMARKETHISTORY (
	SK_SECURITYID NUMBER(38,0) NULL,
	SK_COMPANYID NUMBER(38,0) NULL,
	SK_DATEID NUMBER(38,0) NULL,
	PERATIO NUMBER(10,2) NULL,
	YIELD NUMBER(5,2) NULL,
	FIFTYTWOWEEKHIGH NUMBER(8,2) NULL,
	SK_FIFTYTWOWEEK NUMBER(38,0) NULL,
	FIFTYTWOWEEKLOW NUMBER(8,2) NULL,
	SK_FIFTYTWOWEEKL NUMBER(38,0) NULL,
	CLOSEPRICE NUMBER(8,2) NULL,
	DAYHIGH NUMBER(8,2) NULL,
	DAYLOW NUMBER(8,2) NULL,
	VOLUME NUMBER(38,0) NULL,
	BATCHID NUMBER(38,0) NULL,
	CONSTRAINT SK_COMPANYID5 FOREIGN KEY (SK_COMPANYID) REFERENCES DIMCOMPANY(SK_COMPANYID),
	CONSTRAINT SK_DATEID5 FOREIGN KEY (SK_DATEID) REFERENCES DIMDATE(SK_DATEID),
	CONSTRAINT SK_SECURITYID5 FOREIGN KEY (SK_SECURITYID) REFERENCES DIMSECURITY(SK_SECURITYID)
);


-- FACTWATCHES
CREATE TABLE FACTWATCHES (
	SK_CUSTOMERID NUMBER(38,0) NULL,
	SK_SECURITYID NUMBER(38,0) NULL,
	SK_DATEID_DATEPLACED NUMBER(38,0) NULL,
	SK_DATEID_DATEREMOVED NUMBER(38,0) NULL,
	BATCHID NUMBER(38,0) NULL,
	CONSTRAINT SK_CUSTOMERID6 FOREIGN KEY (SK_CUSTOMERID) REFERENCES DIMCUSTOMER(SK_CUSTOMERID),
	CONSTRAINT SK_DATEID6 FOREIGN KEY (SK_DATEID_DATEPLACED) REFERENCES DIMDATE(SK_DATEID),
	CONSTRAINT SK_DATEID7 FOREIGN KEY (SK_DATEID_DATEREMOVED) REFERENCES DIMDATE(SK_DATEID),
	CONSTRAINT SK_SECURITYID6 FOREIGN KEY (SK_SECURITYID) REFERENCES DIMSECURITY(SK_SECURITYID)
);


-- FINANCIAL
CREATE TABLE FINANCIAL (
	SK_COMPANYID NUMBER(38,0) NULL,
	FI_YEAR NUMBER(38,0) NULL,
	FI_QTR NUMBER(38,0) NULL,
	FI_QTR_START_DATE DATE NULL,
	FI_REVENUE NUMBER(17,2) NULL,
	FI_NET_EARN NUMBER(17,2) NULL,
	FI_BASIC_EPS NUMBER(17,2) NULL,
	FI_DILUT_EPS NUMBER(17,2) NULL,
	FI_MARGIN NUMBER(17,2) NULL,
	FI_INVENTORY NUMBER(17,2) NULL,
	FI_ASSETS NUMBER(17,2) NULL,
	FI_LIABILITY NUMBER(17,2) NULL,
	FI_OUT_BASIC NUMBER(17,2) NULL,
	FI_OUT_DILUT NUMBER(17,2) NULL
);


-- INDUSTRY
CREATE TABLE INDUSTRY (
	IN_ID VARCHAR2(2) NULL,
	IN_NAME VARCHAR2(50) NULL,
	IN_SC_ID VARCHAR2(4) NULL
);


-- PROSPECT
CREATE TABLE PROSPECT (
	AGENCYID VARCHAR2(2000) NULL,
	LASTNAME VARCHAR2(2000) NULL,
	FIRSTNAME VARCHAR2(2000) NULL,
	GENDER VARCHAR2(2000) NULL,
	POSTALCODE VARCHAR2(2000) NULL,
	CITY VARCHAR2(2000) NULL,
	ADDRESSLINE1 VARCHAR2(2000) NULL,
	ADDRESSLINE2 VARCHAR2(2000) NULL,
	COUNTRY VARCHAR2(2000) NULL,
	PHONE VARCHAR2(2000) NULL,
	INCOME NUMBER(38,0) NULL,
	STATE VARCHAR2(2000) NULL,
	MIDDLEINITIAL VARCHAR2(2000) NULL,
	MARITALSTATUS VARCHAR2(2000) NULL,
	AGE NUMBER NULL,
	OWNORRENTFLAG VARCHAR2(2000) NULL,
	EMPLOYER VARCHAR2(2000) NULL,
	CREDITRATING NUMBER NULL,
	NETWORTH NUMBER(38,0) NULL,
	BATCHID NUMBER(38,0) NULL,
	MARKETINGNAMEPLATE VARCHAR2(2000) NULL,
	SK_RECORDDATEID NUMBER(38,0) NULL,
	SK_UPDATEDATEID NUMBER(38,0) NULL,
	ISCUSTOMER CHAR(1) NULL,
	NUMBERCHILDREN NUMBER(38,0) NULL,
	NUMBERCREDITCARDS NUMBER(38,0) NULL,
	NUMBERCARS NUMBER(38,0) NULL,
	CONSTRAINT SK_DATEID8 FOREIGN KEY (SK_RECORDDATEID) REFERENCES DIMDATE(SK_DATEID),
	CONSTRAINT SK_DATEID9 FOREIGN KEY (SK_UPDATEDATEID) REFERENCES DIMDATE(SK_DATEID)
);


-- STATUSTYPE
CREATE TABLE STATUSTYPE (
	ST_ID VARCHAR2(4) NOT NULL,
	ST_NAME VARCHAR2(10) NULL,
	CONSTRAINT STATUSTYPE_PK PRIMARY KEY (ST_ID)
);


-- TAXRATE
CREATE TABLE TAXRATE (
	TX_ID VARCHAR2(5) NOT NULL,
	TX_NAME VARCHAR2(50) NULL,
	TX_RATE NUMBER(6,5) NULL,
	CONSTRAINT TAXRATE_PK PRIMARY KEY (TX_ID)
);


-- TRADETYPE
CREATE TABLE TRADETYPE (
	TT_ID VARCHAR2(3) NOT NULL,
	TT_NAME VARCHAR2(12) NULL,
	TT_IS_SELL VARCHAR2(1) NULL,
	TT_IS_MRKT VARCHAR2(1) NULL,
	CONSTRAINT TRADETYPE_PK PRIMARY KEY (TT_ID)
);