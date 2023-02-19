/* Daily WRITEOFF reports */
SELECT
	CONCAT(patrons.firstname, ' ', patrons.surname) AS 'Patron Name',
	patrons.cardnumber AS 'Card Number',
	accountlines.amount AS 'Amount',
	accountlines.timestamp AS 'Transaction Timestamp',
	accountlines.description AS 'Description',
	accountlines.note AS 'Notes',
	CONCAT(managers.firstname, ' ', managers.surname) AS 'Manager Name'
FROM accountlines
LEFT JOIN borrowers patrons ON (accountlines.borrowernumber = patrons.borrowernumber)
LEFT JOIN borrowers managers ON (accountlines.manager_id = managers.borrowernumber)
WHERE
	accountlines.date = CURDATE()
	AND accountlines.credit_type_code = 'WRITEOFF'

/* Fines paid on Young Adult and Juvenile materials */
SELECT
	CONCAT(items.location, ' ', YEAR(CURRENT_DATE()), ' - ', MONTH(CURRENT_DATE())) AS 'Category',
	ROUND(SUM(debit.amount),2) AS 'Total Paid ($)'
FROM accountlines credit
LEFT JOIN account_offsets ON (credit.accountlines_id = account_offsets.credit_id)
LEFT JOIN accountlines debit ON (debit.accountlines_id = account_offsets.debit_id)
LEFT JOIN items ON (items.itemnumber = debit.itemnumber)
WHERE
	items.location IN ('JFORLANG', 'JSERIES', 'JUVENILE', 'YOUNGADLT')
	AND credit.credit_type_code = "PAYMENT"
	AND credit.date BETWEEN DATE_SUB(DATE_ADD(LAST_DAY(CURRENT_DATE()), INTERVAL 1 DAY), INTERVAL 1 MONTH) AND LAST_DAY(CURRENT_DATE())
GROUP BY
	CASE
		WHEN items.location = 'YOUNGADLT' THEN 'YAMaterial'
		ELSE 'JMaterial'
	END

/* List accounts with CREDIT */
SELECT
    CONCAT('<a href=\"/cgi-bin/koha/members/boraccount.pl?borrowernumber=',borrowernumber,'\">', borrowernumber, '</a>') AS borrowernumber,
    surname,
    firstname,
    cardnumber,
    sum(if(debit_type_code is not null,amountoutstanding,0)) as total_debits,
    sum(if(credit_type_code is not null,amountoutstanding,0)) as total_credits
FROM borrowers
LEFT JOIN accountlines USING (borrowernumber)
GROUP BY borrowernumber

/* WRITEOFF fines within a date range */
SELECT
	CONCAT('<a href=\"/cgi-bin/koha/circ/circulation.pl?borrowernumber=', patrons.borrowernumber, '\" target=/"_blank\">', patrons.cardnumber, '</a>' ) AS 'Card Number',
	CONCAT(patrons.firstname, ' ', patrons.surname) AS 'Patron Name',
	patrons.borrowernotes AS 'Circulation Note',
	patrons.opacnote AS 'OPAC Note',
	patrons.categorycode AS 'Patron Category',
	accountlines.amount AS 'Amount',
	accountlines.timestamp AS 'Transaction Timestamp',
	accountlines.description AS 'Description',
	accountlines.note AS 'Payment Notes',
	CONCAT(managers.firstname, ' ', managers.surname) AS 'Manager Name'
FROM accountlines
LEFT JOIN borrowers patrons ON (accountlines.borrowernumber = patrons.borrowernumber)
LEFT JOIN borrowers managers ON (accountlines.manager_id = managers.borrowernumber)
WHERE
	(accountlines.date BETWEEN <<Fine Waived BETWEEN |date>> AND <<and |date>>)
	AND accountlines.accounttype = 'W'
	AND patrons.categorycode = <<Patron Category |categorycode>>

/* Total Write-off Amount by Patron Category in a Date Range */
SELECT
	patrons.categorycode AS 'Patron Category',
	SUM(ABS(accountlines.amount)) AS 'Total Write-Off Amount'
FROM accountlines
LEFT JOIN borrowers patrons ON (accountlines.borrowernumber = patrons.borrowernumber)
WHERE
	(accountlines.date BETWEEN <<Fine Waived BETWEEN |date>> AND <<and |date>>)
	AND accountlines.accounttype = 'W'
GROUP BY patrons.categorycode

/* Accounts whose access has been blocked by excessive fines. */
SELECT
	borrowers.borrowernumber as 'borrowernumber',
	borrowers.cardnumber as 'cardnumber',
	SUM(accountlines.amountoutstanding) AS 'TotalOwedByPatron'
FROM borrowers
LEFT JOIN accountlines USING (borrowernumber)
WHERE
	borrowers.dateexpiry > CURDATE()
	AND (borrowers.categorycode = 'JUV' OR borrowers.categorycode = 'YA' OR borrowers.categorycode = 'YAVOL')
GROUP BY borrowernumber
HAVING TotalOwedByPatron > '10'
ORDER BY TotalOwedByPatron ASC

SELECT
	borrowers.borrowernumber as 'borrowernumber',
	SUM(accountlines.amountoutstanding) AS 'TotalOwedByPatron'
FROM borrowers
LEFT JOIN accountlines USING (borrowernumber)
LEFT JOIN
	(SELECT
		issues.borrowernumber,
		borrowers.cardnumber,
		COUNT(issues.itemnumber) AS 'checkouts'
	FROM issues
	LEFT JOIN borrowers USING (borrowernumber)
	LEFT JOIN items USING (itemnumber)
	GROUP BY borrowernumber) PatronWithCheckouts
USING (borrowernumber)
GROUP BY borrowernumber
HAVING TotalOwedByPatron > '10'
ORDER BY TotalOwedByPatron ASC

SELECT
	borrowers.borrowernumber as 'borrowernumber',
	SUM(accountlines.amountoutstanding) AS 'TotalOwedByPatron'
FROM borrowers
LEFT JOIN accountlines USING (borrowernumber)
WHERE
	borrowers.dateexpiry > <<Expiration date after |date>>
	
GROUP BY borrowernumber
HAVING TotalOwedByPatron > '10'
ORDER BY TotalOwedByPatron ASC

/* Reports for library fine amnesty */
SELECT
	statistics.borrowernumber,
	borrowers.cardnumber,
	statistics.branch,
	statistics.type,
	statistics.itemnumber,
	items.barcode,
	statistics.datetime
FROM statistics
LEFT JOIN items ON statistics.itemnumber = items.itemnumber
LEFT JOIN borrowers ON statistics.borrowernumber = borrowers.borrowernumber
WHERE
	statistics.type = 'writeoff'
	AND statistics.datetime BETWEEN <<Date between |date>> AND <<and |date>>	
	AND items.itemlost = <<Lost type |LOST>>
	AND items.onloan = NULL
	
SELECT
	accountlines.borrowernumber,
	accountlines.accounttype,
	accountlines.itemnumber,
	items.barcode,
	accountlines.date
FROM accountlines
LEFT JOIN items ON (accountlines.itemnumber=items.itemnumber)
WHERE
	accountlines.date BETWEEN <<Date between |date>> AND <<and |date>>
	AND accountlines.accounttype = 'W'
	
SELECT
	statistics.borrowernumber,
	statistics.branch,
	statistics.type,
	statistics.value,
	items.barcode,
	statistics.datetime
FROM statistics
LEFT JOIN items ON (statistics.itemnumber = items.itemnumber)
WHERE
	statistics.type = 'writeoff'
	AND statistics.datetime BETWEEN <<Date between |date>> AND <<and |date>>

/* Lost items WRITEOFF */
SELECT DISTINCT accountlines.accounttype
FROM accountlines

SELECT DISTINCT statistics.type
FROM statistics

SELECT DISTINCT accountlines.description
FROM accountlines

SELECT DISTINCT AllResults.barcode
FROM
(SELECT
	borrowers.cardnumber,
	items.barcode
FROM accountlines
LEFT JOIN items ON (accountlines.itemnumber=items.itemnumber)
LEFT JOIN borrowers ON (accountlines.borrowernumber=borrowers.borrowernumber)
WHERE
	accountlines.date BETWEEN <<Date between |date>> AND <<and |date>>
	AND accountlines.accounttype = 'W'
	AND items.itemlost = '2') AllResults

SELECT
	borrowers.cardnumber,
	items.barcode,
	items.onloan
FROM accountlines
LEFT JOIN items ON (accountlines.itemnumber=items.itemnumber)
LEFT JOIN borrowers ON (accountlines.borrowernumber=borrowers.borrowernumber)
WHERE
	accountlines.date BETWEEN <<Date between |date>> AND <<and |date>>
	AND accountlines.accounttype = 'W'
	AND items.itemlost = '2'
	AND items.onloan IS NULL

SELECT DISTINCT AllResults.barcode
FROM
(SELECT
	borrowers.cardnumber,
	items.barcode,
	items.onloan
FROM accountlines
LEFT JOIN items ON (accountlines.itemnumber=items.itemnumber)
LEFT JOIN borrowers ON (accountlines.borrowernumber=borrowers.borrowernumber)
WHERE
	accountlines.date BETWEEN <<Date between |date>> AND <<and |date>>
	AND accountlines.accounttype = 'W'
	AND items.itemlost = '2'
	AND items.onloan IS NULL) AllResults

/* Daily total payments by "paycode" (source of payment) */
SELECT
	CONCAT(borrowers.firstname, ' ', borrowers.surname) AS "Name",
	borrowers.cardnumber AS "Cardnumber",
	ROUND(ABS(accountlines.amount),2) AS "Payment Amount",
	accountlines.timestamp AS "Transaction Time",
	borrowers.branchcode AS "Home Branch"
FROM accountlines
LEFT JOIN borrowers ON (borrowers.borrowernumber=accountlines.borrowernumber)
WHERE
	accountlines.date = CURRENT_DATE()
	AND accountlines.accounttype = "Pay02"
UNION
SELECT
	CONCAT('Grand Total'),
	CONCAT(''),
	SUM(ROUND(ABS(accountlines.amount),2)) AS "Grand Total",
	CONCAT(''),
	CONCAT('')
FROM accountlines
LEFT JOIN borrowers ON (borrowers.borrowernumber=accountlines.borrowernumber)
WHERE
	accountlines.date = CURRENT_DATE()
	AND accountlines.accounttype = "Pay02"

/* Payment via Comprise SmartPay Terminals */
SELECT
	CONCAT(borrowers.firstname, ' ', borrowers.surname) AS "Name",
	CONCAT('<a href=\"/cgi-bin/koha/members/boraccount.pl?borrowernumber=', borrowers.borrowernumber, '\">', borrowers.cardnumber, '</a>' ) AS "Cardnumber",
	ROUND(ABS(accountlines.amount),2) AS "Payment Amount",
	accountlines.timestamp AS "Transaction Time",
	borrowers.branchcode AS "Home Branch"
FROM accountlines
LEFT JOIN borrowers ON (borrowers.borrowernumber=accountlines.borrowernumber)
WHERE
	DATE(accountlines.date) = <<Payment Date |date>>
	AND accountlines.credit_type_code = "PAYMENT"
    AND accountlines.payment_type = "SIP02"
UNION
SELECT
	CONCAT('Grand Total'),
	CONCAT(''),
	SUM(ROUND(ABS(accountlines.amount),2)) AS "Grand Total",
	CONCAT(''),
	CONCAT('')
FROM accountlines
LEFT JOIN borrowers ON (borrowers.borrowernumber=accountlines.borrowernumber)
WHERE
	DATE(accountlines.date) = <<Payment Date |date>>
	AND accountlines.credit_type_code = "PAYMENT"
    AND accountlines.payment_type = "SIP02"

/* Payment made via Comprise SmartPay Terminals via SIP02 connection (Automated daily report) */
SELECT
	CONCAT(borrowers.firstname, ' ', borrowers.surname) AS "Name",
	borrowers.cardnumber AS "Cardnumber",
	ROUND(ABS(accountlines.amount),2) AS "Payment Amount",
	accountlines.timestamp AS "Transaction Time",
	borrowers.branchcode AS "Home Branch"
FROM accountlines
LEFT JOIN borrowers ON (borrowers.borrowernumber=accountlines.borrowernumber)
WHERE
	DATE(accountlines.date) = DATE_ADD(CURRENT_DATE(), INTERVAL -1 DAY)
	AND accountlines.credit_type_code = "PAYMENT"
    AND accountlines.payment_type = "SIP02"
UNION
SELECT
	CONCAT('Grand Total'),
	CONCAT(''),
	SUM(ROUND(ABS(accountlines.amount),2)) AS "Grand Total",
	CONCAT(''),
	CONCAT('')
FROM accountlines
LEFT JOIN borrowers ON (borrowers.borrowernumber=accountlines.borrowernumber)
WHERE
	DATE(accountlines.date) = DATE_ADD(CURRENT_DATE(), INTERVAL -1 DAY)
	AND accountlines.credit_type_code = "PAYMENT"
    AND accountlines.payment_type = "SIP02"

/* All payment transactions */
SELECT
	DISTINCT CONCAT('<a href=\"/cgi-bin/koha/members/boraccount.pl?borrowernumber=', borrowers.borrowernumber, '\">', borrowers.cardnumber, '</a>' ) AS 'Patron Acct',
	CONCAT(borrowers.surname, ', ', borrowers.firstname) AS 'Patron Name',
	borrowers.address AS 'Patron Address',
	borrowers.phone as 'Phone #',
	accountlines.date,
	accountlines.timestamp,
	accountlines.description,
	accountlines.note,
	accountlines.amount,
	items.paidfor
FROM accountlines
LEFT JOIN items ON (items.itemnumber = accountlines.itemnumber)
LEFT JOIN borrowers ON (accountlines.borrowernumber = borrowers.borrowernumber)
WHERE
	accountlines.date = <<Payment Date |date>>
	AND accountlines.credit_type_code = "PAYMENT"
ORDER BY CONCAT(borrowers.surname, ', ', borrowers.firstname) ASC

/* Fine WRITEOFF within a given date range for auditing. */
/* Within given date range */
SELECT
	CONCAT('<a href=\"/cgi-bin/koha/circ/circulation.pl?borrowernumber=', patrons.borrowernumber, '\" target=/"_blank\">', patrons.cardnumber, '</a>' ) AS 'Card Number',
	CONCAT(patrons.firstname, ' ', patrons.surname) AS 'Patron Name',
	patrons.borrowernotes AS 'Circulation Note',
	patrons.opacnote AS 'OPAC Note',
	patrons.categorycode AS 'Patron Category',
	accountlines.amount AS 'Amount',
	accountlines.timestamp AS 'Transaction Timestamp',
	accountlines.description AS 'Description',
	accountlines.note AS 'Payment Notes',
	CONCAT(managers.firstname, ' ', managers.surname) AS 'Manager Name'
FROM accountlines
LEFT JOIN borrowers patrons ON (accountlines.borrowernumber = patrons.borrowernumber)
LEFT JOIN borrowers managers ON (accountlines.manager_id = managers.borrowernumber)
WHERE
	(accountlines.date BETWEEN <<Fine Waived Between |date>> AND <<and |date>>)
	AND accountlines.credit_type_code = 'WRITEOFF'
	AND patrons.categorycode = <<Patron Category |categorycode>>

/* By patron category. */
SELECT
	patrons.categorycode AS 'Patron Category',
	SUM(ABS(accountlines.amount)) AS 'Total Write-Off Amount'
FROM accountlines
LEFT JOIN borrowers patrons ON (accountlines.borrowernumber = patrons.borrowernumber)
WHERE
	(accountlines.date BETWEEN <<Fine Waived Between |date>> AND <<and |date>>)
	AND accountlines.credit_type_code = 'WRITEOFF'
GROUP BY patrons.categorycode

/* Accounts with CREDIT */
SELECT
    CONCAT('<a href=\"/cgi-bin/koha/members/boraccount.pl?borrowernumber=',borrowernumber,'\">', borrowernumber, '</a>') AS borrowernumber,
    surname,
    firstname,
    cardnumber,
    sum(if(debit_type_code is not null,amountoutstanding,0)) as total_debits,
    sum(if(credit_type_code is not null,amountoutstanding,0)) as total_credits
FROM borrowers
LEFT JOIN accountlines USING (borrowernumber)
GROUP BY borrowernumber
HAVING total_credits < 0

/* Payment via PayGov.us */
SELECT
	CONCAT(borrowers.firstname, ' ', borrowers.surname) AS "Name",
	CONCAT('<a href=\"/cgi-bin/koha/members/boraccount.pl?borrowernumber=', borrowers.borrowernumber, '\">', borrowers.cardnumber, '</a>' ) AS "Cardnumber",
	ROUND(ABS(accountlines.amount),2) AS "Payment Amount",
	accountlines.timestamp AS "Transaction Time",
	borrowers.branchcode AS "Home Branch"
FROM accountlines
LEFT JOIN borrowers ON (borrowers.borrowernumber=accountlines.borrowernumber)
WHERE
	DATE(accountlines.date) = <<Payment Date |date>>
	AND accountlines.note LIKE '%PayGov%'
UNION
SELECT
	CONCAT('Grand Total'),
	CONCAT(''),
	SUM(ROUND(ABS(accountlines.amount),2)) AS "Grand Total",
	CONCAT(''),
	CONCAT('')
FROM accountlines
LEFT JOIN borrowers ON (borrowers.borrowernumber=accountlines.borrowernumber)
WHERE
	DATE(accountlines.date) = <<Payment Date |date>>
	AND accountlines.note LIKE '%PayGov%'

/* Monthly fines charged on Juvenile and Young Adult materials (automated monthly report) */
SELECT
    CONCAT(items.location, ' ', YEAR(DATE_SUB(CURRENT_DATE, INTERVAL 1 MONTH )), ' - ', MONTH(DATE_SUB(CURRENT_DATE, INTERVAL 1 MONTH ))) AS 'Category',
    ROUND(SUM(debit.amount),2) AS 'Total Paid ($)'
FROM accountlines credit
LEFT JOIN account_offsets ON (credit.accountlines_id = account_offsets.credit_id)
LEFT JOIN accountlines debit ON (debit.accountlines_id = account_offsets.debit_id)
LEFT JOIN items ON (items.itemnumber = debit.itemnumber)
WHERE
    items.location IN ('JFORLANG', 'JSERIES', 'JUVENILE', 'YOUNGADLT')
    AND credit.credit_type_code = "PAYMENT"
    AND month( DATE_SUB(CURRENT_DATE, INTERVAL 1 MONTH ) ) = month(credit.date)
    AND year( DATE_SUB(CURRENT_DATE, INTERVAL 1 MONTH ) ) = year(credit.date)
GROUP BY
    CASE
        WHEN items.location = 'YOUNGADLT' THEN 'YAMaterial'
        ELSE 'JMaterial'
    END