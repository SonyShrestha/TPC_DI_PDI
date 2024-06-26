ALTER SESSION SET current_schema = DW_TPCDI_SF5;

select * from (
--  
--  Checks against the "AUDIT" table.  If there is a problem with the "AUDIT" table, then other tests are suspect...
--  
select '"AUDIT" table batches' as Test, NULL as Batch, case when 
	(select count(distinct BatchID) from "AUDIT") = 3 and
	(select max(BatchID) from "AUDIT") = 3
then 'OK' else 'Not 3 batches' end as Result, 'There must be "AUDIT" data for 3 batches' as Description
 FROM dual
union
select '"AUDIT" table sources' as Test, NULL as Batch, case when 
	(select count(distinct DataSet) 
	 from "AUDIT" 
	 where DataSet in (   
		'Batch',
		'DimAccount',
		'DimBroker',
		'DimCompany',
		'DimCustomer',
		'DimSecurity',
		'DimTrade',
--		'FactCashBalances', currently we are not generating any "AUDIT" data for this table
		'FactHoldings',     
		'FactMarketHistory',
		'FactWatches',
		'Financial',
		'Generator',
		'Prospect'
	) ) = 13
then 'OK' else 'Mismatch' end as Result, 'There must be "AUDIT" data for all data sets' as Description
 FROM dual
--  
-- Checks against the DImessages table.
--  
union
select 'DImessages validation reports', BatchID, Result, 'Every batch must have a full set of validation reports' from (
	select distinct BatchID, (
		case when 
			(select count(*) from DImessages where BatchID = a.BatchID and MessageType = 'Validation') = 24
		then 'OK' else 'Validation checks not fully reported' end
	) as Result
	from DImessages a
) o
union
select 'DImessages batches', NULL, case when 
	(select count(distinct BatchID) from DImessages) = 4 and
	(select max(BatchID) from DImessages) = 3
then 'OK' else 'Not 3 batches plus batch 0' end, 'Must have 3 distinct batches reported in DImessages'
 FROM dual
union
select 'DImessages Phase complete records', NULL, case when 
	(select count(distinct BatchID) from DImessages where MessageType = 'PCR') = 4 and
	(select max(BatchID) from DImessages where MessageType = 'PCR') = 3
then 'OK' else 'Not 4 Phase Complete Records' end, 'Must have 4 Phase Complete records'
 FROM dual
union
select 'DImessages sources', NULL, case when 
	(select count(*) from (
		select distinct MessageSource from DImessages where MessageType = 'Validation' and MessageSource in 
			('DimAccount','DimBroker','DimCustomer','DimDate','DimSecurity','DimTime','DimTrade','FactCashBalances','FactHoldings',
			 'FactMarketHistory','FactWatches','Financial','Industry','Prospect','StatusType','TaxRate','TradeType')
	) a ) = 17
then 'OK' else 'Mismatch' end, 'Messages must be present for all tables/transforms'
 FROM dual
union
select 'DImessages initial condition', NULL, case when 
	(select count(*) from DImessages where BatchID = 0 and MessageType = 'Validation' and MessageData <> '0') = 0
then 'OK' else 'Non-empty table in before Batch1' end, 'All DW tables must be empty before Batch1'
 FROM dual
--  
-- Checks against the DimBroker table.
--  
union
select 'DimBroker row count', NULL, case when 
	(select count(*) from DimBroker) = 
	(select Value from "AUDIT" where DataSet = 'DimBroker' and Attribute = 'HR_BROKERS') 
then 'OK' else 'Mismatch' end, 'Actual row count matches "AUDIT" table'
 FROM dual
union
select 'DimBroker distinct keys', NULL, case when 
	(select count(distinct SK_BrokerID) from DimBroker) = 
	(select Value from "AUDIT" where DataSet = 'DimBroker' and Attribute = 'HR_BROKERS') 
then 'OK' else 'Not unique' end, 'All SKs are distinct'
 FROM dual
union
select 'DimBroker BatchID', 1, case when 
	(select count(*) from DimBroker where BatchID <> 1) = 0 
then 'OK' else 'Not batch 1' end, 'All rows report BatchID = 1'
 FROM dual
union
select 'DimBroker IsCurrent', NULL, case when 
	(select count(*) from DimBroker where IsCurrent <> 1) = 0 
then 'OK' else 'Not current' end, 'All rows have IsCurrent = 1'
 FROM dual
union
select 'DimBroker EffectiveDate', NULL, case when 
	(select count(*) from DimBroker where EffectiveDate <> TO_DATE('1950-01-01','YYYY-MM-DD')) = 0 
then 'OK' else 'Wrong date' end, 'All rows have Batch1 BatchDate as EffectiveDate'
 FROM dual
union
select 'DimBroker EndDate', NULL, case when 
	(select count(*) from DimBroker where EndDate <> TO_DATE('9999-12-31','YYYY-MM-DD')) = 0 
then 'OK' else 'Wrong date' end, 'All rows have end of time as EndDate'
 FROM dual
--  
-- Checks against the DimAccount table.
--  
union
select 'DimAccount row count', 1, case when						
	(select count(*) from DimAccount where BatchID = 1) >
	(select Value from "AUDIT" where DataSet = 'DimCustomer' and Attribute = 'C_NEW' and BatchID = 1) + 
	(select Value from "AUDIT" where DataSet = 'DimAccount' and Attribute = 'CA_ADDACCT' and BatchID = 1) +
	(select Value from "AUDIT" where DataSet = 'DimAccount' and Attribute = 'CA_CLOSEACCT' and BatchID = 1) +
	(select Value from "AUDIT" where DataSet = 'DimAccount' and Attribute = 'CA_UPDACCT' and BatchID = 1) +
	(select Value from "AUDIT" where DataSet = 'DimCustomer' and Attribute = 'C_UPDCUST' and BatchID = 1) +
	(select Value from "AUDIT" where DataSet = 'DimCustomer' and Attribute = 'C_INACT' and BatchID = 1) -
	(select Value from "AUDIT" where DataSet = 'DimCustomer' and Attribute = 'C_ID_HIST' and BatchID = 1) -
	(select Value from "AUDIT" where DataSet = 'DimAccount' and Attribute = 'CA_ID_HIST' and BatchID = 1)
then 'OK' else 'Too few rows' end, 'Actual row count matches or exceeds "AUDIT" table minimum'
 FROM dual
union
select 'DimAccount row count', BatchID, Result, 'Actual row count matches or exceeds "AUDIT" table minimum' from (
	select distinct BatchID, (
		case when 
			(select count(*) from DimAccount where BatchID = a.BatchID) >=
			(select Value from "AUDIT" where DataSet = 'DimAccount' and "ATTRIBUTE" = 'CA_ADDACCT' and BatchID = a.BatchID) +
			(select Value from "AUDIT" where DataSet = 'DimAccount' and "ATTRIBUTE" = 'CA_CLOSEACCT' and BatchID = a.BatchID) +
			(select Value from "AUDIT" where DataSet = 'DimAccount' and "ATTRIBUTE" = 'CA_UPDACCT' and BatchID = a.BatchID) -
			(select Value from "AUDIT" where DataSet = 'DimAccount' and "ATTRIBUTE" = 'CA_ID_HIST' and BatchID = a.BatchID)
		then 'OK' else 'Too few rows' end
	) as Result
	from "AUDIT" a
	where BatchID in (2, 3)
) o
union
select 'DimAccount distinct keys', NULL, case when 
	(select count(distinct SK_AccountID) from DimAccount) = 
	(select count(*) from DimAccount) 
then 'OK' else 'Not unique' end, 'All SKs are distinct'
 FROM dual
-- Three tests together check for validity of the EffectiveDate and EndDate handling:
--   'DimAccount EndDate' checks that effective and end dates line up
--   'DimAccount Overlap' checks that there are not records that overlap in time
--   'DimAccount End of Time' checks that every company has a final record that goes to 9999-12-31
union
select 'DimAccount EndDate', NULL, case when
	(select count(*) from DimAccount) =
	(select count(*) from DimAccount a join DimAccount b on a.AccountID = b.AccountID and a.EndDate = b.EffectiveDate) +
	(select count(*) from DimAccount where EndDate = TO_DATE('9999-12-31','YYYY-MM-DD'))
then 'OK' else 'Dates not aligned' end, 'EndDate of one record matches EffectiveDate of another, or the end of time'
 FROM dual
union
select 'DimAccount Overlap', NULL, case when (
	select count(*)
	from DimAccount a 
	join DimAccount b on a.AccountID = b.AccountID and a.SK_AccountID <> b.SK_AccountID and a.EffectiveDate >= b.EffectiveDate and a.EffectiveDate < b.EndDate
) = 0
then 'OK' else 'Dates overlap' end, 'Date ranges do not overlap for a given Account'
 FROM dual
union
select 'DimAccount End of Time', NULL, case when
	(select count(distinct AccountID) from DimAccount) =
	(select count(*) from DimAccount where EndDate = TO_DATE('9999-12-31','YYYY-MM-DD'))
then 'OK' else 'End of tome not reached' end, 'Every Account has one record with a date range reaching the end of time'
 FROM dual
union
select 'DimAccount consolidation', NULL, case when 
	(select count(*) from DimAccount where EffectiveDate = EndDate) = 0	
then 'OK' else 'Not consolidated' end, 'No records become effective and end on the same day'
 FROM dual
union
select 'DimAccount batches', NULL, case when 
	(select count(distinct BatchID) from DimAccount) = 3  and
	(select max(BatchID) from DimAccount) = 3 
then 'OK' else 'Mismatch' end, 'BatchID values must match "AUDIT" table'
 FROM dual
UNION
-- CORRECT
select 'DimAccount EffectiveDate', BatchID, Result, 'All records from a batch have an EffectiveDate in the batch time window' from (
	select distinct BatchID, (
		case when (
			select count(*) from DimAccount
			where BatchID = a.BatchID and (
				TRUNC(CAST(EFFECTIVEDATE AS DATE)) < (SELECT to_date("Date",'YYYY-MM-DD') from "AUDIT" where DataSet = 'Batch' and "ATTRIBUTE" = 'FirstDay' and BatchID = a.BatchID) or
				TRUNC(CAST(EFFECTIVEDATE AS DATE)) > (select to_date("Date",'YYYY-MM-DD') from "AUDIT" where DataSet = 'Batch' and "ATTRIBUTE" = 'LastDay' and BatchID = a.BatchID) )
		) = 0 
		then 'OK' else 'Data out of range - see ticket #71' end
	) as Result
	from "AUDIT" a where BatchID in (1, 2, 3)
) o
union
select 'DimAccount IsCurrent', NULL, case when
	(select count(*) from DimAccount) =
	(select count(*) from DimAccount where trunc(EndDate) = trunc(TO_DATE('9999-12-31','YYYY-MM-DD')) and IsCurrent = '1') +
	(select count(*) from DimAccount where trunc(EndDate) < trunc(TO_DATE('9999-12-31','YYYY-MM-DD')) and IsCurrent = '0')
then 'OK' else 'Not current' end, 'IsCurrent is 1 if EndDate is the end of time, else Iscurrent is 0'
 FROM dual
union
select 'DimAccount Status', NULL, case when
	(select count(*) from DimAccount where Status not in ('Active', 'Inactive')) = 0
then 'OK' else 'Bad value' end, 'All Status values are valid'
 FROM dual
union
select 'DimAccount TaxStatus', NULL, case when
	(select count(*) from DimAccount where BatchID = 1 and TaxStatus not in (0, 1, 2)) = 0
then 'OK' else 'Bad value' end, 'All TaxStatus values are valid'
 FROM dual
union
select 'DimAccount SK_CustomerID', NULL, case when
	(select count(*) from DimAccount) = 
	(select count(*) from DimAccount a
	 join DimCustomer c on a.SK_CustomerID = c.SK_CustomerID and c.EffectiveDate <= a.EffectiveDate and a.EndDate <= c.EndDate)
then 'OK' else 'Bad join' end, 'All SK_CustomerIDs match a DimCustomer record with a valid date range'
 FROM dual
union
select 'DimAccount SK_BrokerID', NULL, case when
	(select count(*) from DimAccount) = 
	(select count(*) from DimAccount a	 join DimBroker c on a.SK_BrokerID = c.SK_BrokerID and c.EffectiveDate <= a.EffectiveDate and a.EndDate <= c.EndDate)
then 'OK' else 'Bad join - spec problem with DimBroker EffectiveDate values' end, 'All SK_BrokerIDs match a broker record with a valid date range'
 FROM dual
union
select 'DimAccount inactive customers', NULL, case when (
       select count(*) from 
       (select count(*) from (select * from DimCustomer where Status='Inactive') c left join DimAccount a on a.SK_CustomerID = c.SK_CustomerID 
          where a.Status = 'Inactive' group by c.SK_CustomerID having count(*) < 1) z
) = 0
then 'OK' else 'Bad value' end, 'If a customer is inactive, the corresponding accounts must also have been inactive'
 FROM dual
--  
-- Checks against the DimCustomer table.
--  
union
select 'DimCustomer row count', BatchID, Result, 'Actual row count matches or exceeds "AUDIT" table minimum' from (
	select distinct BatchID, case when
		(select count(*) from DimCustomer where BatchID = a.BatchID) >=
		(select Value from "AUDIT" where DataSet = 'DimCustomer' and Attribute = 'C_NEW' and BatchID = a.BatchID) + 
		(select Value from "AUDIT" where DataSet = 'DimCustomer' and Attribute = 'C_INACT' and BatchID = a.BatchID) +
		(select Value from "AUDIT" where DataSet = 'DimCustomer' and Attribute = 'C_UPDCUST' and BatchID = a.BatchID) -
		(select Value from "AUDIT" where DataSet = 'DimCustomer' and Attribute = 'C_ID_HIST' and BatchID = a.BatchID)
	then 'OK' else 'Too few rows' end as Result
	from "AUDIT" a where BatchID in (1, 2, 3)
) o
union
select 'DimCustomer distinct keys', NULL, case when 
	(select count(distinct SK_CustomerID) from DimCustomer) = 
	(select count(*) from DimCustomer) 
then 'OK' else 'Not unique' end, 'All SKs are distinct'
 FROM dual
-- Three tests together check for validity of the EffectiveDate and EndDate handling:
--   'DimCustomer EndDate' checks that effective and end dates line up
--   'DimCustomer Overlap' checks that there are not records that overlap in time
--   'DimCustomer End of Time' checks that every company has a final record that goes to 9999-12-31
union
select 'DimCustomer EndDate', NULL, case when
	(select count(*) from DimCustomer) =
	(select count(*) from DimCustomer a join DimCustomer b on a.CustomerID = b.CustomerID and a.EndDate = b.EffectiveDate) +
	(select count(*) from DimCustomer where EndDate = TO_DATE('9999-12-31','YYYY-MM-DD'))
then 'OK' else 'Dates not aligned' end, 'EndDate of one record matches EffectiveDate of another, or the end of time'
 FROM dual
union
select 'DimCustomer Overlap', NULL, case when (
	select count(*)
	from DimCustomer a 
	join DimCustomer b on a.CustomerID = b.CustomerID and a.SK_CustomerID <> b.SK_CustomerID and a.EffectiveDate >= b.EffectiveDate and a.EffectiveDate < b.EndDate
) = 0
then 'OK' else 'Dates overlap' end, 'Date ranges do not overlap for a given Customer'
 FROM dual
union
select 'DimCustomer End of Time', NULL, case when
	(select count(distinct CustomerID) from DimCustomer) =
	(select count(*) from DimCustomer where to_char(ENDDATE) = to_char(TO_DATE('9999-12-31 ','YYYY-MM-DD')))
then 'OK' else 'End of time not reached' end, 'Every Customer has one record with a date range reaching the end of time'
 FROM dual
union
select 'DimCustomer consolidation', NULL, case when 
	(select count(*) from DimCustomer where EffectiveDate = EndDate) = 0	
then 'OK' else 'Not consolidated' end, 'No records become effective and end on the same day'
 FROM dual
union
select 'DimCustomer batches', NULL, case when 
	(select count(distinct BatchID) from DimCustomer) = 3 and
	(select max(BatchID) from DimCustomer) = 3
then 'OK' else 'Mismatch' end, 'BatchID values must match "AUDIT" table'
 FROM dual
union
select 'DimCustomer IsCurrent', NULL, case when 
	(select count(*) from DimCustomer) =
	(select count(*) from DimCustomer where  TRUNC(ENDDATE) = TRUNC(to_date('9999-12-31','YYYY-MM-DD')) and IsCurrent = '1') +
	(select count(*) from DimCustomer where  TRUNC(ENDDATE) < TRUNC(to_date('9999-12-31','YYYY-MM-DD'))  and IsCurrent = '0')
then 'OK' else 'Not current' end, 'IsCurrent is 1 if EndDate is the end of time, else Iscurrent is 0'
 FROM dual
union
select 'DimCustomer EffectiveDate', BatchID, Result, 'All records from a batch have an EffectiveDate in the batch time window' from (
	select distinct BatchID, (
		case when (
			select count(*) from DimCustomer
			where BatchID = a.BatchID and (
				to_date(EffectiveDate) < (select to_date("Date",'YYYY-MM-DD') from "AUDIT" where DataSet = 'Batch' and "ATTRIBUTE" = 'FirstDay' and BatchID = a.BatchID) or
				to_date(EffectiveDate) > (select to_date("Date",'YYYY-MM-DD') from "AUDIT" where DataSet = 'Batch' and "ATTRIBUTE" = 'LastDay' and BatchID = a.BatchID) )
		) = 0 
		then 'OK' else 'Data out of range' end
	) as Result
	from "AUDIT" a where BatchID in (1, 2, 3)
) o
union
select 'DimCustomer Status', NULL, case when
	(select count(*) from DimCustomer where Status not in ('Active', 'Inactive')) = 0
then 'OK' else 'Bad value' end, 'All Status values are valid'
 FROM dual
union
select 'DimCustomer inactive customers', BatchID, Result, 'Inactive customer count matches "AUDIT" table' from (
	select distinct BatchID, case when
		(select messageData from DImessages where MessageType = 'Validation' and BatchID = a.BatchID and 'DimCustomer' = MessageSource and 'Inactive customers' = MessageText) = 
		(select sum(Value) from "AUDIT" where DataSet = 'DimCustomer' and BatchID <= a.BatchID and Attribute = 'C_INACT')		
	then 'OK' else 'Mismatch' end as Result
	from "AUDIT" a where BatchID in (1, 2, 3)
) o
union
select 'DimCustomer Gender', NULL, case when
	(select count(*) from DimCustomer where Gender not in ('M', 'F', 'U')) = 0
then 'OK' else 'Bad value' end, 'All Gender values are valid'
 FROM dual
union
select 'DimCustomer age range alerts', BatchID, Result, 'Count of age range alerts matches "AUDIT" table' from (
	select distinct BatchID, case when
		(select count(*) from DImessages where MessageType = 'Alert' and BatchID = a.BatchID and MessageText = 'DOB out of range') = 
		(select Value from "AUDIT" where DataSet = 'DimCustomer' and BatchID = a.BatchID and Attribute = 'C_DOB_TO') +
		(select Value from "AUDIT" where DataSet = 'DimCustomer' and BatchID = a.BatchID and Attribute = 'C_DOB_TY')
	then 'OK' else 'Mismatch' end as Result
	from "AUDIT" a where BatchID in (1, 2, 3)
) o
union
select 'DimCustomer customer tier alerts', BatchID, Result, 'Count of customer tier alerts matches "AUDIT" table' from (
	select distinct BatchID, case when
		(select count(*) from DImessages where MessageType = 'Alert' and BatchID = a.BatchID and MessageText = 'Invalid customer tier') = 
		(select Value from "AUDIT" where DataSet = 'DimCustomer' and BatchID = a.BatchID and Attribute = 'C_TIER_INV')
	then 'OK' else 'Mismatch' end as Result
	from "AUDIT" a where BatchID in (1, 2, 3)
) o
union                     
select 'DimCustomer TaxID', NULL, case when (
	select count(*) from DimCustomer where TaxID not like '___-__-____'
	) = 0
then 'OK' else 'Mismatch' end, 'TaxID values are properly formatted'
 FROM dual
union                       
select 'DimCustomer Phone1', NULL, case when (
	select count(*) from DimCustomer 
	where Phone1 not like '+1 (___) ___-____%'
	  and Phone1 not like '(___) ___-____%'
	  and Phone1 not like '___-____%'
	  and Phone1 <> ''
	  and Phone1 is not null
	) = 0
then 'OK' else 'Mismatch' end, 'Phone1 values are properly formatted'
 FROM dual
union                       
select 'DimCustomer Phone2', NULL, case when (
	select count(*) from DimCustomer 
	where Phone2 not like '+1 (___) ___-____%'
	  and Phone2 not like '(___) ___-____%'
	  and Phone2 not like '___-____%'
	  and Phone2 <> ''
	  and Phone2 is not null
	) = 0
then 'OK' else 'Mismatch' end, 'Phone2 values are properly formatted'
 FROM dual
union                       
select 'DimCustomer Phone3', NULL, case when (
	select count(*) from DimCustomer 
	where Phone3 not like '+1 (___) ___-____%'
	  and Phone3 not like '(___) ___-____%'
	  and Phone3 not like '___-____%'
	  and Phone3 <> ''
	  and Phone3 is not null
	) = 0
then 'OK' else 'Mismatch' end, 'Phone3 values are properly formatted'
 FROM dual
union                     
select 'DimCustomer Email1', NULL, case when (
	select count(*) from DimCustomer 
	where Email1 not like '_%.%@%.%'
	  and Email1 is not null
	) = 0
then 'OK' else 'Mismatch' end, 'Email1 values are properly formatted'
 FROM dual
union                    
select 'DimCustomer Email2', NULL, case when (
	select count(*) from DimCustomer 
	where Email2 not like '_%.%@%.%'
	  and Email2 <> ''
	  and Email2 is not null
	) = 0
then 'OK' else 'Mismatch' end, 'Email2 values are properly formatted'
 FROM dual
union                    
select 'DimCustomer LocalTaxRate', NULL, case when 
	(select count(*) from DimCustomer) = 
	(select count(*) from DimCustomer c join TaxRate t on c.LocalTaxRateDesc = t.TX_NAME and c.LocalTaxRate = t.TX_RATE) and
	(select count(distinct LocalTaxRateDesc) from DimCustomer) > 300
then 'OK' else 'Mismatch' end, 'LocalTaxRateDesc and LocalTaxRate values are from TaxRate table'
 FROM dual
union                 
select 'DimCustomer NationalTaxRate', NULL, case when 
	(select count(*) from DimCustomer) = 
	(select count(*) from DimCustomer c join TaxRate t on c.NationalTaxRateDesc = t.TX_NAME and c.NationalTaxRate = t.TX_RATE) and
	(select count(distinct NationalTaxRateDesc) from DimCustomer) >= 9   -- Including the inequality for now, because the generated data is not sticking to national tax rates
then 'OK' else 'Mismatch' end, 'NationalTaxRateDesc and NationalTaxRate values are from TaxRate table'
 FROM dual
union                                
select 'DimCustomer demographic fields', NULL, case when
	(
		select count(*) from DimCustomer c 
		join Prospect p on upper(c.FirstName || c.LastName || c.AddressLine1 || COALESCE(c.AddressLine2,'') || c.PostalCode)
						 = upper(p.FirstName || p.LastName || p.AddressLine1 || COALESCE(p.AddressLine2,'') || p.PostalCode)
	                    and COALESCE(c.CreditRating,0) = COALESCE(p.CreditRating,0) and COALESCE(c.NetWorth,0) = COALESCE(p.NetWorth,0) and COALESCE(c.MarketingNameplate, ' ') = COALESCE(p.MarketingNameplate,' ')
					    and c.IsCurrent = '1'
	) = (
		select count(*) from DimCustomer where AgencyID is not null and IsCurrent = '1'
	)
then 'OK' else 'Mismatch' end, 'For current customer records that match Prospect records, the demographic fields also match'
 FROM dual
--  
-- Checks against the DimSecurity table.
--  
union
select 'DimSecurity row count', BatchID, Result, 'Actual row count matches or exceeds "AUDIT" table minimum' from (
	select distinct BatchID, case when
		cast((select MessageData from DImessages where MessageType = 'Validation' and BatchID = a.BatchID and MessageSource = 'DimSecurity' and MessageText = 'Row count') as NUMBER) >= 
		(select sum(Value) from "AUDIT" where DataSet = 'DimSecurity' and Attribute = 'FW_SEC' and BatchID <= a.BatchID)
	then 'OK' else 'Too few rows' end as Result
	from "AUDIT" a where BatchID in (1)
) o
union
select 'DimSecurity distinct keys', NULL, case when 
	(select count(distinct SK_SecurityID) from DimSecurity) = 
	(select count(*) from DimSecurity) 
then 'OK' else 'Not unique' end, 'All SKs are distinct'
 FROM dual
-- Three tests together check for validity of the EffectiveDate and EndDate handling:
--   'DimSecurity EndDate' checks that effective and end dates line up
--   'DimSecurity Overlap' checks that there are not records that overlap in time
--   'DimSecurity End of Time' checks that every company has a final record that goes to 9999-12-31
union
select 'DimSecurity EndDate', NULL, case when
	(select count(*) from DimSecurity) =
	(select count(*) from DimSecurity a join DimSecurity b on a.Symbol = b.Symbol and a.EndDate = b.EffectiveDate) +
	(select count(*) from DimSecurity where EndDate = TO_DATE('9999-12-31','YYYY-MM-DD'))
then 'OK' else 'Dates not aligned' end, 'EndDate of one record matches EffectiveDate of another, or the end of time'
 FROM dual
union
select 'DimSecurity Overlap', NULL, case when (
	select count(*)
	from DimSecurity a 
	join DimSecurity b on a.Symbol = b.Symbol and a.SK_SecurityID <> b.SK_SecurityID and a.EffectiveDate >= b.EffectiveDate and a.EffectiveDate < b.EndDate
) = 0
then 'OK' else 'Dates overlap' end, 'Date ranges do not overlap for a given company'
 FROM dual
union
select 'DimSecurity End of Time', NULL, case when
	(select count(distinct Symbol) from DimSecurity) =
	(select count(*) from DimSecurity where EndDate = TO_DATE('9999-12-31','YYYY-MM-DD'))
then 'OK' else 'End of tome not reached' end, 'Every company has one record with a date range reaching the end of time'
 FROM dual
union
select 'DimSecurity consolidation', NULL, case when 
	(select count(*) from DimSecurity where EffectiveDate = EndDate) = 0	
then 'OK' else 'Not consolidated' end, 'No records become effective and end on the same day'
 FROM dual
union
select 'DimSecurity batches', NULL, case when 
	(select count(distinct BatchID) from DimSecurity) = 1 and
	(select max(BatchID) from DimSecurity) = 1 
then 'OK' else 'Mismatch' end, 'BatchID values must match "AUDIT" table'
 FROM dual
union
select 'DimSecurity IsCurrent', NULL, case when 
	(select count(*) from DimSecurity) =
	(select count(*) from DimSecurity where EndDate = TO_DATE('9999-12-31','YYYY-MM-DD') and IsCurrent = 1) +
	(select count(*) from DimSecurity where EndDate < TO_DATE('9999-12-31','YYYY-MM-DD') and IsCurrent = 0)
then 'OK' else 'Not current' end, 'IsCurrent is 1 if EndDate is the end of time, else Iscurrent is 0'
 FROM dual
union
select 'DimSecurity EffectiveDate', BatchID, Result, 'All records from a batch have an EffectiveDate in the batch time window' from (
	select distinct BatchID, (
		case when (
			select count(*) from DimSecurity
			where BatchID = a.BatchID and (
				trunc(EffectiveDate) < (select to_date("Date",'YYYY-MM-DD') from "AUDIT" where DataSet = 'Batch' and "ATTRIBUTE" = 'FirstDay' and BatchID = a.BatchID) or
				trunc(EffectiveDate) > (select to_date("Date",'YYYY-MM-DD') from "AUDIT" where DataSet = 'Batch' and "ATTRIBUTE" = 'LastDay' and BatchID = a.BatchID) )
		) = 0 
		then 'OK' else 'Data out of range' end
	) as Result
	from "AUDIT" a where BatchID in (1, 2, 3)
) o
union
select 'DimSecurity Status', NULL, case when
	(select count(*) from DimSecurity where Status not in ('Active', 'Inactive')) = 0
then 'OK' else 'Bad value' end, 'All Status values are valid'
 FROM dual
union
select 'DimSecurity SK_CompanyID', NULL, case when
	(select count(*) from DimSecurity) = 
	(select count(*) from DimSecurity a
	 join DimCompany c on a.SK_CompanyID = c.SK_CompanyID and c.EffectiveDate <= a.EffectiveDate and a.EndDate <= c.EndDate)
then 'OK' else 'Bad join' end, 'All SK_CompanyIDs match a DimCompany record with a valid date range'
 FROM dual
union
select 'DimSecurity ExchangeID', NULL, case when
	(select count(*) from DimSecurity where ExchangeID not in ('NYSE', 'NASDAQ', 'AMEX', 'PCX')) = 0
then 'OK' else 'Bad value - see ticket #65' end, 'All ExchangeID values are valid'
 FROM dual
union
select 'DimSecurity Issue', NULL, case when
	(select count(*) from DimSecurity where Issue not in ('COMMON', 'PREF_A', 'PREF_B', 'PREF_C', 'PREF_D')) = 0
then 'OK' else 'Bad value - see ticket #65' end, 'All Issue values are valid'
 FROM dual
--  
-- Checks against the DimCompany table.
--  
union
select 'DimCompany row count', BatchID, Result, 'Actual row count matches or exceeds "AUDIT" table minimum' from (
	select distinct BatchID, case when
		cast((select MessageData from DImessages where MessageType='Validation' and BatchID = a.BatchID and MessageSource = 'DimCompany' and MessageText = 'Row count') as NUMBER) <= 
		(select sum(Value) from "AUDIT" where DataSet = 'DimCompany' and Attribute = 'FW_CMP' and BatchID <= a.BatchID)
	then 'OK' else 'Too few rows' end as Result
	from "AUDIT" a where BatchID in (1, 2, 3)
) o
union
select 'DimCompany distinct keys', NULL, case when 
	(select count(distinct SK_CompanyID) from DimCompany) = 
	(select count(*) from DimCompany) 
then 'OK' else 'Not unique' end, 'All SKs are distinct'
 FROM dual
-- Three tests together check for validity of the EffectiveDate and EndDate handling:
--   'DimCompany EndDate' checks that effective and end dates line up
--   'DimCompany Overlap' checks that there are not records that overlap in time
--   'DimCompany End of Time' checks that every company has a final record that goes to 9999-12-31
union
select 'DimCompany EndDate', NULL, case when
	(select count(*) from DimCompany) =
	(select count(*) from DimCompany a join DimCompany b on a.CompanyID = b.CompanyID and a.EndDate = b.EffectiveDate) +
	(select count(*) from DimCompany where EndDate = TO_DATE('9999-12-31','YYYY-MM-DD'))
then 'OK' else 'Dates not aligned' end, 'EndDate of one record matches EffectiveDate of another, or the end of time'
 FROM dual
union
select 'DimCompany Overlap', NULL, case when (
	select count(*)
	from DimCompany a 
	join DimCompany b on a.CompanyID = b.CompanyID and a.SK_CompanyID <> b.SK_CompanyID and a.EffectiveDate >= b.EffectiveDate and a.EffectiveDate < b.EndDate
) = 0
then 'OK' else 'Dates overlap' end, 'Date ranges do not overlap for a given company'
 FROM dual
union
select 'DimCompany End of Time', NULL, case when
	(select count(distinct CompanyID) from DimCompany) =
	(select count(*) from DimCompany where EndDate = TO_DATE('9999-12-31','YYYY-MM-DD'))
then 'OK' else 'End of tome not reached' end, 'Every company has one record with a date range reaching the end of time'
 FROM dual
union
select 'DimCompany consolidation', NULL, case when 
	(select count(*) from DimCompany where EffectiveDate = EndDate) = 0	
then 'OK' else 'Not consolidated' end, 'No records become effective and end on the same day'
FROM dual
union
select 'DimCompany batches', NULL, case when 
	(select count(distinct BatchID) from DimCompany) = 1 and
	(select max(BatchID) from DimCompany) = 1 
then 'OK' else 'Mismatch' end, 'BatchID values must match "AUDIT" table'
FROM dual
union
select 'DimCompany EffectiveDate', BatchID, Result, 'All records from a batch have an EffectiveDate in the batch time window' from (
	select distinct BatchID, (
		case when (
			select count(*) from DimCompany
			where BatchID = a.BatchID and (
				TRUNC(CAST(EFFECTIVEDATE AS DATE)) < (select to_date("Date",'YYYY-MM-DD') from "AUDIT" where DataSet = 'Batch' and "ATTRIBUTE" = 'FirstDay' and BatchID = a.BatchID) or
				TRUNC(CAST(EFFECTIVEDATE AS DATE)) > (select to_date("Date",'YYYY-MM-DD') from "AUDIT" where DataSet = 'Batch' and "ATTRIBUTE" = 'LastDay' and BatchID = a.BatchID) )
		) = 0 
		then 'OK' else 'Data out of range - see ticket #71' end
	) as Result
	from "AUDIT" a where BatchID in (1, 2, 3)
) o
union
select 'DimCompany Status', NULL, case when
	(select count(*) from DimCompany where Status not in ('Active', 'Inactive')) = 0
then 'OK' else 'Bad value' end, 'All Status values are valid'
FROM dual
union
select 'DimCompany distinct names', NULL, case when	(
	select count(*)
	from DimCompany a
	join DimCompany b on a.Name = b.Name and a.CompanyID <> b.CompanyID
) = 0 
then 'OK' else 'Mismatch' end, 'Every company has a unique name'
FROM dual
union				-- Curious, there are duplicate industry names in Industry table.  Should there be?  That's why the distinct stuff...
select 'DimCompany Industry', NULL, case when
	(select count(*) from DimCompany) = 
	(select count(*) from DimCompany where Industry in (select distinct IN_NAME from Industry))
then 'OK' else 'Bad value' end, 'Industry values are from the Industry table'
FROM dual
union
select 'DimCompany SPrating', NULL, case when (
	select count(*) from DimCompany 
	where SPrating not in (	'AAA','AA','A','BBB','BB','B','CCC','CC','C','D','AA+','A+','BBB+','BB+','B+','CCC+','AA-','A-','BBB-','BB-','B-','CCC-' )
	  and SPrating is not null
) = 0
then 'OK' else 'Bad value' end, 'All SPrating values are valid'
FROM dual
union			-- Right now we have blank (but not null) country names.  Should there be?
select 'DimCompany Country', NULL, case when (
	select count(*) from DimCompany 
	where Country not in ( 'Canada', 'United States of America', '' )
	  and Country is not null
) = 0
then 'OK' else 'Bad value' end, 'All Country values are valid'
FROM dual
-- 
-- Checks against the Prospect table.
--  
union
select 'Prospect SK_UpdateDateID', NULL, case when 
	(select count(*) from Prospect where SK_RecordDateID < SK_UpdateDateID) = 0	
then 'OK' else 'Mismatch' end, 'SK_RecordDateID must be newer or same as SK_UpdateDateID'
 FROM dual
union
select 'Prospect SK_RecordDateID', BatchID, Result, 'All records from batch have SK_RecordDateID in or after the batch time window' from (
	select distinct BatchID, (
		case when (
			select count(*) from Prospect p
			where p.BatchID = a.BatchID and (
				(select DateValue from DimDate where SK_DateID = p.SK_RecordDateID) < 
				(select to_date("Date",'YYYY-MM-DD') from "AUDIT" where DataSet = 'Batch' and "ATTRIBUTE" = 'FirstDay' and BatchID = a.BatchID)
			)
		) = 0
		then 'OK' else 'Mismatch' end
	) as Result
	from "AUDIT" a where BatchID in (1, 2, 3)
) o
union
select 'Prospect batches', NULL, case when 
	(select count(distinct BatchID) from Prospect) = 3 and
	(select max(BatchID) from Prospect) = 3 
then 'OK' else 'Mismatch' end, 'BatchID values must match "AUDIT" table'
 FROM dual
 union
select 'Prospect Country', NULL, case when (
	select count(*) from Prospect 
	where Country not in ( 'Canada', 'United States of America' ) -- For the tiny sample data it would be ( 'CANADA', 'USA' )
	  and Country is not null
) = 0
then 'OK' else 'Bad value' end, 'All Country values are valid'
 FROM dual
union																
select 'Prospect MarketingNameplate', NULL, case when (
	select sum(case when (COALESCE(NetWorth,0) > 1000000 or COALESCE(Income,0) > 200000) and MarketingNameplate not like '%HighValue%' then 1 else 0 end) +
	       sum(case when (COALESCE(NumberChildren,0) > 3 or COALESCE(NumberCreditCards,0) > 5) and MarketingNameplate not like '%Expenses%' then 1 else 0 end) +
	       sum(case when (COALESCE(Age,0) > 45) and MarketingNameplate not like '%Boomer%' then 1 else 0 end) +
	       sum(case when (COALESCE(Income,50000) < 50000 or COALESCE(CreditRating,600) < 600 or COALESCE(NetWorth,100000) < 100000) and MarketingNameplate not like '%MoneyAlert%' then 1 else 0 end) +
	       sum(case when (COALESCE(NumberCars,0) > 3 or COALESCE(NUMBERCREDITCARDS,0) > 7) and MarketingNameplate not like '%Spender%' then 1 else 0 end) +
	       sum(case when (COALESCE(Age,25) < 25 and COALESCE(NetWorth,0) > 1000000) and MarketingNameplate not like '%Inherited%' then 1 else 0 end) +
		   sum(case when COALESCE(MarketingNameplate, '') not in (   -- Technically, a few of these combinations cannot really happen
				'','HighValue','Expenses','HighValue+Expenses','Boomer','HighValue+Boomer','Expenses+Boomer','HighValue+Expenses+Boomer','MoneyAlert','HighValue+MoneyAlert',
				'Expenses+MoneyAlert','HighValue+Expenses+MoneyAlert','Boomer+MoneyAlert','HighValue+Boomer+MoneyAlert','Expenses+Boomer+MoneyAlert','HighValue+Expenses+Boomer+MoneyAlert',
				'Spender','HighValue+Spender','Expenses+Spender','HighValue+Expenses+Spender','Boomer+Spender','HighValue+Boomer+Spender','Expenses+Boomer+Spender',
				'HighValue+Expenses+Boomer+Spender','MoneyAlert+Spender','HighValue+MoneyAlert+Spender','Expenses+MoneyAlert+Spender','HighValue+Expenses+MoneyAlert+Spender',
				'Boomer+MoneyAlert+Spender','HighValue+Boomer+MoneyAlert+Spender','Expenses+Boomer+MoneyAlert+Spender','HighValue+Expenses+Boomer+MoneyAlert+Spender','Inherited',
				'HighValue+Inherited','Expenses+Inherited','HighValue+Expenses+Inherited','Boomer+Inherited','HighValue+Boomer+Inherited','Expenses+Boomer+Inherited',
				'HighValue+Expenses+Boomer+Inherited','MoneyAlert+Inherited','HighValue+MoneyAlert+Inherited','Expenses+MoneyAlert+Inherited','HighValue+Expenses+MoneyAlert+Inherited',
				'Boomer+MoneyAlert+Inherited','HighValue+Boomer+MoneyAlert+Inherited','Expenses+Boomer+MoneyAlert+Inherited','HighValue+Expenses+Boomer+MoneyAlert+Inherited',
				'Spender+Inherited','HighValue+Spender+Inherited','Expenses+Spender+Inherited','HighValue+Expenses+Spender+Inherited','Boomer+Spender+Inherited',
				'HighValue+Boomer+Spender+Inherited','Expenses+Boomer+Spender+Inherited','HighValue+Expenses+Boomer+Spender+Inherited','MoneyAlert+Spender+Inherited',
				'HighValue+MoneyAlert+Spender+Inherited','Expenses+MoneyAlert+Spender+Inherited','HighValue+Expenses+MoneyAlert+Spender+Inherited','Boomer+MoneyAlert+Spender+Inherited',
				'HighValue+Boomer+MoneyAlert+Spender+Inherited','Expenses+Boomer+MoneyAlert+Spender+Inherited','HighValue+Expenses+Boomer+MoneyAlert+Spender+Inherited'
				) then 1 else 0  end)
	from Prospect
) = 0
then 'OK' else 'Bad value' end, 'All MarketingNameplate values match the data'
 FROM dual
--
-- Checks against the FactWatches table.
--
union
select 'FactWatches row count', BatchID, Result, 'Actual row count matches "AUDIT" table' from (
	select distinct BatchID, (
		case when 
			cast((select MessageData from DImessages where MessageSource = 'FactWatches' and MessageType = 'Validation' and MessageText = 'Row count' and BatchID = a.BatchID) as int) -
			coalesce(cast((select MessageData from DImessages where MessageSource = 'FactWatches' and MessageType = 'Validation' and MessageText = 'Row count' and BatchID = a.BatchID-1) as int),0) =
			(select Value from "AUDIT" where DataSet = 'FactWatches' and Attribute = 'WH_ACTIVE' and BatchID = a.BatchID)
		then 'OK' else 'Mismatch' end
	) as Result
	from "AUDIT" a where BatchID in (1, 2, 3)
) o
union
select 'FactWatches batches', NULL, case when 
	(select count(distinct BatchID) from FactWatches) = 3  and
	(select max(BatchID) from FactWatches) = 3
then 'OK' else 'Mismatch' end, 'BatchID values must match "AUDIT" table'
 FROM dual
union
select 'FactWatches active watches', BatchID, Result, 'Actual total matches "AUDIT" table' from (
	select distinct BatchID, case when
		(select cast(MessageData as number) from DImessages where MessageSource = 'FactWatches' and MessageType = 'Validation' and MessageText = 'Row count' and BatchID = a.BatchID) +
		(select cast(MessageData as number) from DImessages where MessageSource = 'FactWatches' and MessageType = 'Validation' and MessageText = 'Inactive watches' and BatchID = a.BatchID) =
		(select sum(Value) from "AUDIT" where DataSet = 'FactWatches' and Attribute = 'WH_RECORDS' and BatchID <= a.BatchID)
	then 'OK' else 'Mismatch' end as Result
	from "AUDIT" a where BatchID in (1, 2, 3)
) o
union
select 'FactWatches SK_CustomerID', NULL, case when
	(select count(*) from FactWatches) = 
	(select count(*) from FactWatches a
	 join DimCustomer c on a.SK_CustomerID = c.SK_CustomerID
	  and c.EffectiveDate <= (select DateValue from DimDate where SK_DateID = a.SK_DateID_DatePlaced)
	  and (select DateValue from DimDate where SK_DateID = a.SK_DateID_DatePlaced) <= c.EndDate )
then 'OK' else 'Bad join' end, 'All SK_CustomerIDs match a DimCustomer record with a valid date range'
 FROM dual
union
select 'FactWatches SK_SecurityID', NULL, case when
	(select count(*) from FactWatches) = 
	(select count(*) from FactWatches a
	 join DimSecurity c on a.SK_SecurityID = c.SK_SecurityID
	  and trunc(c.EffectiveDate) <= (select DateValue from DimDate where SK_DateID = a.SK_DateID_DatePlaced)
	  and (select DateValue from DimDate where SK_DateID = a.SK_DateID_DatePlaced) <= trunc(c.EndDate) )
then 'OK' else 'Bad join' end, 'All SK_SecurityIDs match a DimSecurity record with a valid date range'
 FROM dual
union	
SELECT 'FactWatches date check', BatchID, Result, 'All SK_DateID_ values are in the correct batch time window'
FROM (
    SELECT DISTINCT
        BatchID,
        CASE
            WHEN (
                SELECT COUNT(*)
                FROM FactWatches w
                WHERE w.BatchID = a.BatchID
                    AND (
                        (w.SK_DateID_DateRemoved IS NULL AND (
                            TRUNC((SELECT DateValue FROM DimDate WHERE SK_DateID = w.SK_DateID_DatePlaced)) >
                            (SELECT TO_DATE("Date", 'YYYY-MM-DD') FROM "AUDIT" WHERE DataSet = 'Batch' AND "ATTRIBUTE" = 'LastDay' AND BatchID = a.BatchID)
                            OR
                            TRUNC((SELECT DateValue FROM DimDate WHERE SK_DateID = w.SK_DateID_DatePlaced)) <
                            (SELECT TO_DATE("Date", 'YYYY-MM-DD') FROM "AUDIT" WHERE DataSet = 'Batch' AND "ATTRIBUTE" = 'FirstDay' AND BatchID = a.BatchID)
                        ))
                        OR
                        (w.SK_DateID_DateRemoved IS NOT NULL AND (
                            TRUNC((SELECT DateValue FROM DimDate WHERE SK_DateID = w.SK_DateID_DateRemoved)) >
                            (SELECT TO_DATE("Date", 'YYYY-MM-DD') FROM "AUDIT" WHERE DataSet = 'Batch' AND "ATTRIBUTE" = 'LastDay' AND BatchID = a.BatchID)
                            OR
                            TRUNC((SELECT DateValue FROM DimDate WHERE SK_DateID = w.SK_DateID_DateRemoved)) <
                            (SELECT TO_DATE("Date", 'YYYY-MM-DD') FROM "AUDIT" WHERE DataSet = 'Batch' AND "ATTRIBUTE" = 'FirstDay' AND BatchID = a.BatchID)
                            OR
                            SK_DateID_DatePlaced > SK_DateID_DateRemoved
                        ))
                    )
            ) = 0 THEN 'OK'
            ELSE 'Mismatch'
        END AS Result
    FROM "AUDIT" a
    WHERE BatchID IN (1, 2, 3)
) o
union 
--  
-- Checks against the DimTrade table.
--  
select 'DimTrade row count', BatchID, Result, 'Actual total matches "AUDIT" table' from (
	select distinct BatchID, case when
		(select MessageData from DImessages where MessageSource = 'DimTrade' and MessageType = 'Validation' and MessageText = 'Row count' and BatchID = a.BatchID)  =
		(select sum(Value) from "AUDIT" where DataSet = 'DimTrade' and Attribute = 'T_NEW' and BatchID <= a.BatchID)
	then 'OK' else 'Mismatch' end as Result
	from "AUDIT" a where BatchID in (1, 2, 3)
) o
union 
select 'DimTrade canceled trades', NULL, case when 
		(select count(*) from DimTrade where Status = 'Canceled')  =
		(select sum(Value) from "AUDIT" where DataSet = 'DimTrade' and Attribute = 'T_CanceledTrades')
then 'OK' else 'Mismatch' end, 'Actual row counts matches "AUDIT" table'
 FROM dual
union 
select 'DimTrade commission alerts', NULL, case when 
		(select count(*) from DImessages where MessageType = 'Alert' and messageText = 'Invalid trade commission')  =
		(select sum(Value) from "AUDIT" where DataSet = 'DimTrade' and Attribute = 'T_InvalidCommision')
then 'OK' else 'Mismatch' end, 'Actual row counts matches "AUDIT" table'
 FROM dual
union 
select 'DimTrade charge alerts', NULL, case when 
		(select count(*) from DImessages where MessageType = 'Alert' and messageText = 'Invalid trade fee')  =
		(select sum(Value) from "AUDIT" where DataSet = 'DimTrade' and Attribute = 'T_InvalidCharge')
then 'OK' else 'Mismatch' end, 'Actual row counts matches "AUDIT" table'
 FROM dual
union
select 'DimTrade batches', NULL, case when 
	(select count(distinct BatchID) from DimTrade) = 3 and
	(select max(BatchID) from DimTrade) = 3 
then 'OK' else 'Mismatch' end, 'BatchID values must match "AUDIT" table'
 FROM dual
union
select 'DimTrade distinct keys', NULL, case when 
	(select count(distinct TradeID) from DimTrade) = 
	(select count(*) from DimTrade) 
then 'OK' else 'Not unique' end, 'All keys are distinct'
 FROM dual
union
select 'DimTrade SK_BrokerID', NULL, case when
	(select count(*) from DimTrade) = 
	(select count(*) from DimTrade a
	 join DimBroker c on a.SK_BrokerID = c.SK_BrokerID and trunc(c.EffectiveDate) <= (select trunc(DateValue) from DimDate where SK_DateID = a.SK_CreateDateID) and (select trunc(DateValue) from DimDate where SK_DateID = a.SK_CreateDateID) <= trunc(c.EndDate))
then 'OK' else 'Bad join' end, 'All SK_BrokerIDs match a DimBroker record with a valid date range'
 FROM dual
union
select 'DimTrade SK_CompanyID', NULL, case when
	(select count(*) from DimTrade) = 
	(select count(*) from DimTrade a
	 join DimCompany c on a.SK_CompanyID = c.SK_CompanyID and trunc(c.EffectiveDate) <= (select trunc(DateValue) from DimDate where SK_DateID = a.SK_CreateDateID) and (select trunc(DateValue) from DimDate where SK_DateID = a.SK_CreateDateID) <= trunc(c.EndDate))
then 'OK' else 'Bad join' end, 'All SK_CompanyIDs match a DimCompany record with a valid date range'
 FROM dual
union
select 'DimTrade SK_SecurityID', NULL, case when
	(select count(*) from DimTrade) = 
	(select count(*) from DimTrade a
	 join DimSecurity c on a.SK_SecurityID = c.SK_SecurityID and trunc(c.EffectiveDate) <= (select trunc(DateValue) from DimDate where SK_DateID = a.SK_CreateDateID) and (select trunc(DateValue) from DimDate where SK_DateID = a.SK_CreateDateID) <= trunc(c.EndDate))
then 'OK' else 'Bad join' end, 'All SK_SecurityIDs match a DimSecurity record with a valid date range'
 FROM dual
union
select 'DimTrade SK_CustomerID', NULL, case when
	(select count(*) from DimTrade) = 
	(select count(*) from DimTrade a
	 join DimCustomer c on a.SK_CustomerID = c.SK_CustomerID and trunc(c.EffectiveDate) <= (select trunc(DateValue) from DimDate where SK_DateID = a.SK_CreateDateID) and (select trunc(DateValue) from DimDate where SK_DateID = a.SK_CreateDateID) <= trunc(c.EndDate))
then 'OK' else 'Bad join' end, 'All SK_CustomerIDs match a DimCustomer record with a valid date range'
 FROM dual
union
select 'DimTrade SK_AccountID', NULL, case when
	(select count(*) from DimTrade) = 
	(select count(*) from DimTrade a
	 join DimAccount c on a.SK_AccountID = c.SK_AccountID and TRUNC(c.EffectiveDate) <= (select TRUNC(DateValue) from DimDate where SK_DateID = a.SK_CreateDateID) and (select TRUNC(DateValue) from DimDate where SK_DateID = a.SK_CreateDateID) <= TRUNC(c.EndDate))
then 'OK' else 'Bad join' end, 'All SK_AccountIDs match a DimAccount record with a valid date range'
 FROM dual
UNION
select 'DimTrade date check', BatchID, Result, 'All SK_DateID values are in the correct batch time window' from (
	select distinct BatchID, (
		case when (
			select count(*) from DimTrade w
			where w.BatchID = a.BatchID and (
				(w.SK_CloseDateID is NULL) and (
					(select DateValue from DimDate where SK_DateID = w.SK_CreateDateID) > 
					(select to_date("Date",'YYYY-MM-DD') from "AUDIT" where DataSet = 'Batch' and Attribute = 'LastDay' and BatchID = a.BatchID)
					or
					(select DateValue from DimDate where SK_DateID = w.SK_CreateDateID) < 
					(case when w.Type like 'Limit%'  /* Limit trades can have create dates earlier than the current Batch date, but not earlier than Batch1's first date */
                                              then (select to_date("Date",'YYYY-MM-DD') from "AUDIT" where DataSet = 'Batch' and Attribute = 'FirstDay' and BatchID = 1) 
                                              else (select to_date("Date",'YYYY-MM-DD') from "AUDIT" where DataSet = 'Batch' and Attribute = 'FirstDay' and BatchID = a.BatchID) end)
				) or 
				(w.SK_CloseDateID is not NULL) and (
					(select DateValue from DimDate where SK_DateID = w.SK_CloseDateID) > 
					(select to_date("Date",'YYYY-MM-DD') from "AUDIT" where DataSet = 'Batch' and Attribute = 'LastDay' and BatchID = a.BatchID)
					or
					(select DateValue from DimDate where SK_DateID = w.SK_CloseDateID) < 
					(select to_date("Date",'YYYY-MM-DD') from "AUDIT" where DataSet = 'Batch' and Attribute = 'FirstDay' and BatchID = a.BatchID)
					or
					SK_CloseDateID < SK_CreateDateID
				)
			)
		) = 0
		then 'OK' else 'Mismatch' end
	) as Result
	from "AUDIT" a where BatchID in (1, 2, 3)
) o
union
select 'DimTrade Status', NULL, case when (
	select count(*) from DimTrade 
	where Status not in ( 'Canceled', 'Pending', 'Submitted', 'Active', 'Completed' )
) = 0
then 'OK' else 'Bad value' end, 'All Trade Status values are valid'
 FROM dual
union
select 'DimTrade Type', NULL, case when (
	select count(*) from DimTrade 
	where Type not in ( 'Market Buy', 'Market Sell', 'Stop Loss', 'Limit Sell', 'Limit Buy' )
) = 0
then 'OK' else 'Bad value' end, 'All Trade Type values are valid'
 FROM dual
--  
-- Checks against the Financial table.
--  
union 
select 'Financial row count', NULL, case when 
		(select MessageData from DImessages where MessageSource = 'Financial' and MessageType = 'Validation' and MessageText = 'Row count' and BatchID = 1)  =
		(select sum(Value) from "AUDIT" where DataSet = 'Financial' and Attribute = 'FW_FIN')
then 'OK' else 'Mismatch' end, 'Actual row count matches "AUDIT" table'
 FROM dual
union
select 'Financial SK_CompanyID', NULL, case when
	(select count(*) from Financial) = 
	(select count(*) from Financial a join DimCompany c on a.SK_CompanyID = c.SK_CompanyID )
then 'OK' else 'Bad join' end, 'All SK_CompanyIDs match a DimCompany record'
 FROM dual
UNION
-- CORRECT
select 'Financial FI_YEAR', NULL, case when (
	(select count(*) from Financial where FI_YEAR < EXTRACT(YEAR FROM (select to_date("Date",'YYYY-MM-DD') from "AUDIT" where DataSet = 'Batch' and BatchID = 1 and "ATTRIBUTE" = 'FirstDay'))) + 
	(select count(*) from Financial where FI_YEAR > EXTRACT(YEAR FROM (select to_date("Date",'YYYY-MM-DD') from "AUDIT" where DataSet = 'Batch' and BatchID = 1 and "ATTRIBUTE" = 'LastDay')))
) = 0
then 'OK' else 'Bad Year' end, 'All Years are within Batch1 range'
 FROM dual
UNION
select 'Financial FI_QTR', NULL, case when (
	select count(*) from Financial where FI_QTR not in ( 1, 2, 3, 4 )
) = 0
then 'OK' else 'Bad Qtr' end, 'All quarters are in ( 1, 2, 3, 4 )'
 FROM dual
union
select 'Financial FI_QTR_START_DATE', NULL, case when (
	select count(*) from Financial
	where FI_YEAR <> EXTRACT(YEAR FROM FI_QTR_START_DATE)
	   or EXTRACT(MONTH FROM FI_QTR_START_DATE) <> (FI_QTR-1)*3+1
	   or EXTRACT(DAY FROM FI_QTR_START_DATE) <> 1
) = 0
then 'OK' else 'Bad date' end, 'All quarters start on correct date'
 FROM dual
union											
select 'Financial EPS', NULL, case when (
	select count(*) from Financial
	where Round(FI_NET_EARN/FI_OUT_BASIC,2)- FI_BASIC_EPS not between -0.4 and 0.4
	   or  Round(FI_NET_EARN/FI_OUT_DILUT,2) - FI_DILUT_EPS not between -0.4 and 0.4
	   or  Round(FI_NET_EARN/FI_REVENUE,2) - FI_MARGIN not between -0.4 and 0.4
) = 0
then 'OK' else 'Bad EPS' end, 'Earnings calculations are valid'
 FROM dual
--  
-- Checks against the FactMarketHistory table.
--  
union
select 'FactMarketHistory row count', BatchID, Result, 'Actual row count matches "AUDIT" table' from (
	select distinct BatchID, (
		case when 
			cast((select MessageData from DImessages where MessageSource = 'FactMarketHistory' and MessageType = 'Validation' and MessageText = 'Row count' and BatchID = a.BatchID) as int) -
			COALESCE(cast((select MessageData from DImessages where MessageSource = 'FactMarketHistory' and MessageType = 'Validation' and MessageText = 'Row count' and BatchID = a.BatchID-1) as int),0) =
			(select Value from "AUDIT" where DataSet = 'FactMarketHistory' and Attribute = 'DM_RECORDS' and BatchID = a.BatchID)
		then 'OK' else 'Mismatch' end
	) as Result
	from "AUDIT" a where BatchID in (1, 2, 3)
) o
union
select 'FactMarketHistory batches', NULL, case when 
	(select count(distinct BatchID) from FactMarketHistory) = 3 and
	(select max(BatchID) from FactMarketHistory) = 3 
then 'OK' else 'Mismatch' end, 'BatchID values must match "AUDIT" table'
FROM dual
union
select 'FactMarketHistory SK_CompanyID', NULL, case when
	(select count(*) from FactMarketHistory) = 
	(
        select 
            count(*) 
        from FactMarketHistory a 
        join DimCompany c 
        on a.SK_CompanyID = c.SK_CompanyID 
        and TRUNC(c.EffectiveDate) <= (
            select TRUNC(DateValue) from DimDate where SK_DateID = a.SK_DateID
        ) 
        and (
            select TRUNC(DateValue) from DimDate where SK_DateID = a.SK_DateID) <= TRUNC(c.EndDate)
        )
then 'OK' else 'Bad join' end, 'All SK_CompanyIDs match a DimCompany record with a valid date range'
FROM dual
union
select 'FactMarketHistory SK_SecurityID', NULL, case when
	(select count(*) from FactMarketHistory) = 
	(
        select 
            count(*) 
        from FactMarketHistory a 
        join DimSecurity c 
        on a.SK_SecurityID = c.SK_SecurityID 
        and TRUNC(c.EffectiveDate) <= (
            select TRUNC(DateValue) from DimDate where SK_DateID = a.SK_DateID
        ) 
        and (
            select TRUNC(DateValue) from DimDate where SK_DateID = a.SK_DateID
        ) <= TRUNC(c.EndDate)
    )
then 'OK' else 'Bad join' end, 'All SK_SecurityIDs match a DimSecurity record with a valid date range'
FROM dual
union	
select 'FactMarketHistory SK_DateID', BatchID, Result, 'All dates are within batch date range' from (
	select distinct BatchID, (
		case when (
			(select count(*) from FactMarketHistory m where m.BatchID = a.BatchID and (select DateValue from DimDate where SK_DateID = m.SK_DateID) < (select to_date("Date",'YYYY-MM-DD')-1 day from "AUDIT" where DataSet = 'Batch' and BatchID = a.BatchID and Attribute = 'FirstDay')) + 
			(select count(*) from FactMarketHistory m where m.BatchID = a.BatchID and (select DateValue from DimDate where SK_DateID = m.SK_DateID) >= (select to_date("Date",'YYYY-MM-DD') from "AUDIT" where DataSet = 'Batch' and BatchID = a.BatchID and Attribute = 'LastDay'))
		) = 0
		then 'OK' else 'Bad Date' end
	) as Result
	from "AUDIT" a where BatchID in (1, 2, 3)
) o
union
select 'FactMarketHistory relative dates', NULL, case when (
	select count(*) from FactMarketHistory
	where FiftyTwoWeekLow > DayLow
	   or DayLow > ClosePrice
	   or ClosePrice > DayHigh
	   or DayHigh > FiftyTwoWeekHigh
) = 0
then 'OK' else 'Bad Date' end, '52-week-low <= day_low <= close_price <= day_high <= 52-week-high'
FROM dual
--  
-- Checks against the FactHoldings table.
--  
union
select 'FactHoldings row count', BatchID, Result, 'Actual row count matches "AUDIT" table' from (
	select distinct BatchID, (
		case when 
			cast((select MessageData from DImessages where MessageSource = 'FactHoldings' and MessageType = 'Validation' and MessageText = 'Row count' and BatchID = a.BatchID) as int) -
			COALESCE(cast((select MessageData from DImessages where MessageSource = 'FactHoldings' and MessageType = 'Validation' and MessageText = 'Row count' and BatchID = a.BatchID-1) as int),0) =
			(select Value from "AUDIT" where DataSet = 'FactHoldings' and Attribute = 'HH_RECORDS' and BatchID = a.BatchID)
		then 'OK' else 'Mismatch' end
	) as Result
	from "AUDIT" a where BatchID in (1, 2, 3)
) o
union
select 'FactHoldings batches', NULL, case when 
	(select count(distinct BatchID) from FactHoldings) = 3 and
	(select max(BatchID) from FactHoldings) = 3 
then 'OK' else 'Mismatch' end, 'BatchID values must match "AUDIT" table'
FROM dual
union
/* It is possible that the dimension record has changed between orgination of the trade and the completion of the trade. *
 * So, we can check that the Effective Date of the dimension record is older than the the completion date, but the end date could be earlier or later than the completion date
 */
select 'FactHoldings SK_CustomerID', NULL, case when
	(select count(*) from FactHoldings) = 
	(
		select 
			count(*) from FactHoldings a join DimCustomer c 
		on a.SK_CustomerID = c.SK_CustomerID 
		and NVL(c.EffectiveDate,TO_DATE('9999-12-31','YYYY-MM-DD')) <= (
			select NVL(MIN(DateValue),TO_DATE('9999-12-31','YYYY-MM-DD')) from DimDate where SK_DateID = a.SK_DateID
		) 
    )
then 'OK' else 'Bad join' end, 'All SK_CustomerIDs match a DimCustomer record with a valid date range'
FROM dual
union
select 'FactHoldings SK_AccountID', NULL, case when
	(select count(*) from FactHoldings) = 
	(
		select 
			count(*) 
		from FactHoldings a 
		join DimAccount c 
		on a.SK_AccountID = c.SK_AccountID 
		and NVL(c.EffectiveDate,TO_DATE('9999-12-31','YYYY-MM-DD')) <= (
			select NVL(MIN(DateValue),TO_DATE('9999-12-31','YYYY-MM-DD')) from DimDate where SK_DateID = a.SK_DateID
		) 
    )
then 'OK' else 'Bad join' end, 'All SK_AccountIDs match a DimAccount record with a valid date range'
FROM dual
union
select 'FactHoldings SK_CompanyID', NULL, case when
	(select count(*) from FactHoldings) = 
	(
		select 
			count(*) 
		from FactHoldings a 
		join DimCompany c 
		on a.SK_CompanyID = c.SK_CompanyID 
		and NVL(c.EffectiveDate,TO_DATE('9999-12-31','YYYY-MM-DD')) <= (
			select NVL(MIN(DateValue),TO_DATE('9999-12-31','YYYY-MM-DD')) from DimDate where SK_DateID = a.SK_DateID
		) 
	)
then 'OK' else 'Bad join' end, 'All SK_CompanyIDs match a DimCompany record with a valid date range'
FROM dual
union
select 'FactHoldings SK_SecurityID', NULL, case when
	(select count(*) from FactHoldings) = 
	(
		select 
			count(*) 
		from FactHoldings a 
		join DimSecurity c 
		on a.SK_SecurityID = c.SK_SecurityID and 
		NVL(c.EffectiveDate,TO_DATE('9999-12-31','YYYY-MM-DD')) <= (
			select NVL(MIN(DateValue),TO_DATE('9999-12-31','YYYY-MM-DD')) from DimDate where SK_DateID = a.SK_DateID
		) 
    )
then 'OK' else 'Bad join' end, 'All SK_SecurityIDs match a DimSecurity record with a valid date range'
FROM dual
UNION
select 'FactHoldings CurrentTradeID', NULL, case when
	(select count(*) from FactHoldings) = 
	(
		select 
			count(*) 
		from FactHoldings a 
		join DimTrade t 
		on a.CurrentTradeID = t.TradeID 
		and NVL(a.SK_DateID,9999999) = NVL(t.SK_CloseDateID,9999999) 
		and NVL(a.SK_TimeID,9999999) = NVL(t.SK_CloseTimeID,9999999)
	) 
then 'OK' else 'Failed' end, 'CurrentTradeID matches a DimTrade record with and Close Date and Time are values are used as the holdings date and time'
FROM dual
UNION
-- check
select 'FactHoldings SK_DateID', BatchID, Result, 'All dates are within batch date range' from (
	select distinct BatchID, (
		case when (
			(select count(*) from FactHoldings m where BatchID = a.BatchID and (select DateValue from DimDate where SK_DateID = m.SK_DateID) < (select to_date("Date",'YYYY-MM-DD') from "AUDIT" where DataSet = 'Batch' and BatchID = a.BatchID and Attribute = 'FirstDay')) + 
			(select count(*) from FactHoldings m where BatchID = a.BatchID and (select DateValue from DimDate where SK_DateID = m.SK_DateID) > (select to_date("Date",'YYYY-MM-DD') from "AUDIT" where DataSet = 'Batch' and BatchID = a.BatchID and Attribute = 'LastDay'))
		) = 0
		then 'OK' else 'Bad Date' end
	) as Result
	from "AUDIT" a where BatchID in (1, 2, 3)
) o
--  
-- Checks against the FactCashBalances table.
--  
union
select 'FactCashBalances batches', NULL, case when 
	(select count(distinct BatchID) from FactCashBalances) = 3 and
	(select max(BatchID) from FactCashBalances) = 3 
then 'OK' else 'Mismatch' end, 'BatchID values must match "AUDIT" table'
FROM dual
union
select 'FactCashBalances SK_CustomerID', NULL, case when
	(select count(*) from FactCashBalances) = 
	(select count(*) from FactCashBalances a join DimCustomer c on a.SK_CustomerID = c.SK_CustomerID and trunc(c.EffectiveDate) <= (select trunc(DateValue) from DimDate where SK_DateID = a.SK_DateID) and  (select trunc(DateValue) from DimDate where SK_DateID = a.SK_DateID) <= trunc(c.EndDate))
then 'OK' else 'Bad join' end, 'All SK_CustomerIDs match a DimCustomer record with a valid date range'
FROM dual
union
select 'FactCashBalances SK_AccountID', NULL, case when
	(select count(*) from FactCashBalances) = 
	(select count(*) from FactCashBalances a join DimAccount c on a.SK_AccountID = c.SK_AccountID and trunc(c.EffectiveDate) <= (select trunc(DateValue) from DimDate where SK_DateID = a.SK_DateID) and (select trunc(DateValue) from DimDate where SK_DateID = a.SK_DateID) <= trunc(c.EndDate))
then 'OK' else 'Bad join' end, 'All SK_AccountIDs match a DimAccount record with a valid date range'
FROM dual
union
select 'FactCashBalances SK_DateID', BatchID, Result, 'All dates are within batch date range' from (
	select distinct BatchID, (
		case when (
			(select count(*) from FactCashBalances m where BatchID = a.BatchID and (select DateValue from DimDate where SK_DateID = m.SK_DateID) < (select to_date("Date",'YYYY-MM-DD') from "AUDIT" where DataSet = 'Batch' and BatchID = a.BatchID and Attribute = 'FirstDay')) + 
			(select count(*) from FactCashBalances m where BatchID = a.BatchID and (select DateValue from DimDate where SK_DateID = m.SK_DateID) > (select to_date("Date",'YYYY-MM-DD') from "AUDIT" where DataSet = 'Batch' and BatchID = a.BatchID and Attribute = 'LastDay'))
		) = 0
		then 'OK' else 'Bad Date' end
	) as Result
	from "AUDIT" a where BatchID in (1, 2, 3)
) o
/*
 *  Checks against the Batch Validation Query row counts
 */
union
select 'Batch row count: ' || MessageSource, BatchID,
	case when RowsLastBatch > RowsThisBatch then 'Row count decreased' else 'OK' end,
	'Row counts do not decrease between successive batches'
from (
	select distinct(a.BatchID), m.MessageSource, cast(m1.MessageData as number) as RowsThisBatch, cast(m2.MessageData as number) as RowsLastBatch
	from "AUDIT" a 
	full join DImessages m on m.BatchID = 0 and m.MessageText = 'Row count' and m.MessageType = 'Validation'
	join DImessages m1 on m1.BatchID = a.BatchID   and m1.MessageSource = m.MessageSource and m1.MessageText = 'Row count' and m1.MessageType = 'Validation'
	join DImessages m2 on m2.BatchID = a.BatchID-1 and m2.MessageSource = m.MessageSource and m2.MessageText = 'Row count' and m2.MessageType = 'Validation'
	where a.BatchID in (1, 2, 3)
) o
union
select 'Batch joined row count: ' || MessageSource, BatchID,
	case when RowsJoined = RowsUnjoined then 'OK' else 'No match' end,
	'Row counts match when joined to dimensions'
from (
	select distinct(a.BatchID), m.MessageSource, cast(m1.MessageData as number) as RowsUnjoined, cast(m2.MessageData as number) as RowsJoined
	from "AUDIT" a 
	full join DImessages m on m.BatchID = 0 and m.MessageText = 'Row count' and m.MessageType = 'Validation'
	join DImessages m1 on m1.BatchID = a.BatchID and m1.MessageSource = m.MessageSource and m1.MessageText = 'Row count' and m1.MessageType = 'Validation'
	join DImessages m2 on m2.BatchID = a.BatchID and m2.MessageSource = m.MessageSource and m2.MessageText = 'Row count joined' and m2.MessageType = 'Validation'
	where a.BatchID in (1, 2, 3)
) o
/*
 *  Checks against the Data Visibility Query row counts
 */
union
select 'Data visibility row counts: ' || MessageSource , NULL as BatchID,
	case when regressions = 0 then 'OK' else 'Row count decreased' end,
	'Row counts must be non-decreasing over time'
from (
	select m1.MessageSource, sum( case when cast(m1.MessageData as number) > cast(m2.MessageData as number) then 1 else 0 end ) as regressions
	from DImessages m1 
	join DImessages m2 on 
		m2.MessageType IN ('Visibility_1', 'Visibility_2') and 
		m2.MessageText = 'Row count' and
		m2.MessageSource = m1.MessageSource and
		m2.MessageDateAndTime > m1.MessageDateAndTime
	where m1.MessageType IN ('Visibility_1', 'Visibility_2') and m1.MessageText = 'Row count'
	group by m1.MessageSource
) o
union
select 'Data visibility joined row counts: ' || MessageSource , NULL as BatchID,
	case when regressions = 0 then 'OK' else 'No match' end,
	'Row counts match when joined to dimensions'
from (
	select m1.MessageSource, sum( case when cast(m1.MessageData as number) > cast(m2.MessageData as number) then 1 else 0 end ) as regressions
	from DImessages m1 
	join DImessages m2 on 
		m2.MessageType = 'Visibility_1' and 
		m2.MessageText = 'Row count joined' and
		m2.MessageSource = m1.MessageSource and
		m2.MessageDateAndTime = m1.MessageDateAndTime
	where m1.MessageType = 'Visibility_1' and m1.MessageText = 'Row count'
	group by m1.MessageSource
) o
/* close the outer query */
) q  
order by Test, Batch
;		

