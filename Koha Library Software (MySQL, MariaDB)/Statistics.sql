/*
The majority of reports in this file were devised for the Market Segmentation Research which was
part of the Strategic Planning.
*/

/*
Count patrons' number of visits within a given time period.

Definition of visits: when a patron has any "issue" or "renew" actions logged within a day.
Multiple "issue" or "renew" activities/actions within the same day still count as ONE visit.
*/

SELECT
    borrowers.cardnumber,
    CONCAT(borrowers.firstname, ' ', borrowers.surname) AS 'Name',
    COUNT(DISTINCT SUBSTRING(statistics.datetime,1,13)) AS 'NumberOfVisits',
    statistics.branch
FROM statistics
LEFT JOIN borrowers ON (statistics.borrowernumber = borrowers.borrowernumber)
WHERE
    statistics.datetime BETWEEN '2019-01-01' AND '2019-01-31'
    AND statistics.type IN ('issue','renew')
    AND statistics.branch = <<Which branch? |branches>>
    AND borrowers.cardnumber != ''
    AND LENGTH(borrowers.cardnumber) = 14
GROUP BY borrowers.cardnumber
ORDER BY NumberOfVisits DESC

/* Count "active patrons" by zipcode. */
SELECT
    borrowers.zipcode,
    COUNT(DISTINCT statistics.borrowernumber) AS 'Patrons'
FROM statistics
LEFT JOIN borrowers ON (statistics.borrowernumber = borrowers.borrowernumber)
WHERE
    statistics.type IN ('issue', 'renew')
    AND statistics.datetime BETWEEN '2019-01-01' AND '2019-01-31'
    AND LENGTH(borrowers.zipcode) = 5
    AND borrowers.zipcode IN ()
GROUP BY borrowers.zipcode
ORDER BY Patrons DESC

/* Count the number of patrons living within given zipcode areas. */
SELECT
    borrowers.zipcode,
    COUNT(DISTINCT statistics.borrowernumber) AS 'Patrons'
FROM statistics
LEFT JOIN borrowers ON (statistics.borrowernumber = borrowers.borrowernumber)
WHERE
    statistics.type IN ('issue', 'renew')
    AND statistics.datetime BETWEEN '2019-01-01' AND '2019-01-31'
    AND LENGTH(borrowers.zipcode) = 5
    AND borrowers.zipcode IN ()
GROUP BY borrowers.zipcode
ORDER BY Patrons DESC

/* Number of patrons in given age group, living within given zipcode areas */
SELECT
    borrowers.zipcode,
    COUNT(*) AS 'Patrons'
FROM borrowers
WHERE
    FLOOR(DATEDIFF(CURDATE(), DATE(borrowers.dateofbirth))/365) BETWEEN '' AND ''
    AND borrowers.zipcode IN ()
    AND LENGTH(borrowers.zipcode) = 5
GROUP BY borrowers.zipcode
ORDER BY Patrons DESC

/* List patrons that have activities within given time period. (Entire library system) */
SELECT
	borrowers.borrowernumber,
	borrowers.cardnumber,
	SUBSTRING(borrowers.zipcode, 1, 5),
	statistics.branch,
	statistics.datetime,
	statistics.type,
	CONCAT(borrowers.cardnumber, '|', SUBSTRING(statistics.datetime, 1, 10))
FROM statistics
LEFT JOIN borrowers ON (borrowers.borrowernumber = statistics.borrowernumber)
WHERE
	statistics.branch = <<Branch |branches>>
	AND statistics.type IN ('issue', 'renew')
	AND statistics.datetime BETWEEN '2017-06-01' AND '2017-06-30'
ORDER BY cardnumber, type ASC

/* Count patrons who have activities within given time period. (With Branch selection) */
SELECT
	SUBSTRING(borrowers.zipcode, 1, 5) AS "ZipCode",
	COUNT(DISTINCT CONCAT(borrowers.cardnumber, '|', SUBSTRING(statistics.datetime, 1, 10))) AS "PatronSrved"	
FROM statistics
LEFT JOIN borrowers ON (borrowers.borrowernumber = statistics.borrowernumber)
WHERE
	statistics.branch = <<Branch |branches>>
	AND statistics.type IN ('issue', 'renew')
	AND statistics.datetime BETWEEN '2016-06-01' AND '2017-06-30'
GROUP BY SUBSTRING(borrowers.zipcode, 1, 5)
ORDER BY PatronSrved DESC

/* Count patrons who have activities within given time period. (Entire library) */
SELECT
	SUBSTRING(borrowers.zipcode, 1, 5) AS "ZipCode",
	COUNT(DISTINCT CONCAT(borrowers.cardnumber, '|', SUBSTRING(statistics.datetime, 1, 10))) AS "PatronSrved"	
FROM statistics
LEFT JOIN borrowers ON (borrowers.borrowernumber = statistics.borrowernumber)
WHERE
	statistics.type IN ('issue', 'renew')
	AND statistics.datetime BETWEEN '2016-06-01' AND '2017-06-30'
GROUP BY SUBSTRING(borrowers.zipcode, 1, 5)
ORDER BY PatronSrved DESC

/* Patrons who have at least ONE activity in a Fiscal Year */
SELECT
	COUNT(DISTINCT statistics.borrowernumber)
FROM statistics
WHERE
	statistics.datetime BETWEEN '2016-07-01' AND '2017-06-30'
	AND statistics.type IN ('issue', 'renew');

/* Number of patrons who have established accounts before a given date. */
SELECT
	COUNT(DISTINCT borrowers.borrowernumber)
FROM borrowers
WHERE
	borrowers.dateenrolled <= '2018-06-27'
	AND borrowers.branchcode = 'CHICO'

/* Number of patrons who have established accounts between given dates. */
SELECT
	COUNT(DISTINCT borrowers.borrowernumber)
FROM borrowers
WHERE
	borrowers.dateenrolled >= '2016-06-01'
	AND borrowers.dateenrolled <= '2017-06-30'

/* All-in-One report for monthly statistics or state report. */
SELECT
	CONCAT('NEW CARD HOLDERS') AS 'BRANCH',
	CONCAT('COUNT') AS 'STATS'
FROM borrowers
UNION
SELECT
	borrowers.branchcode,
	COUNT(borrowernumber)
FROM borrowers 
WHERE
	dateenrolled BETWEEN (@StartDate:=<<Statistics Date Between |date>>) AND (@EndDate:=<<And |date>>)
	AND branchcode='BIGGS'
UNION
SELECT
	borrowers.branchcode,
	COUNT(borrowernumber)
FROM borrowers 
WHERE
	dateenrolled BETWEEN @StartDate AND @EndDate
	AND branchcode='CHICO'
UNION
SELECT
	borrowers.branchcode,
	COUNT(borrowernumber)
FROM borrowers 
WHERE
	dateenrolled BETWEEN @StartDate AND @EndDate
	AND branchcode='DURHAM'
UNION
SELECT
	borrowers.branchcode,
	COUNT(borrowernumber)
FROM borrowers 
WHERE
	dateenrolled BETWEEN @StartDate AND @EndDate
	AND branchcode='GRIDLEY'
UNION
SELECT
	borrowers.branchcode,
	COUNT(borrowernumber)
FROM borrowers 
WHERE
	dateenrolled BETWEEN @StartDate AND @EndDate
	AND branchcode='OROVILLE'
UNION
SELECT
	borrowers.branchcode,
	COUNT(borrowernumber)
FROM borrowers 
WHERE
	dateenrolled BETWEEN @StartDate AND @EndDate
	AND branchcode='PARADISE'
UNION
SELECT
	CONCAT('TOTAL CARD HOLDERS') AS '',
	CONCAT('COUNT') AS ''
FROM borrowers
UNION
SELECT
	borrowers.branchcode,
	count(*)
FROM borrowers
GROUP by branchcode
UNION
SELECT
	CONCAT('MONTHLY CIRCULATION') AS '',
	CONCAT('CHECKOUTS & RENEWALS') AS ''
FROM borrowers
UNION
SELECT
	statistics.branch,
	count(*)
FROM statistics
WHERE
	statistics.datetime BETWEEN @StartDate AND @EndDate
	AND statistics.type IN ('issue', 'renew')
GROUP by branch
UNION
SELECT
	CONCAT('MONTHLY CIRCULATION') AS '',
	CONCAT('CHECKOUTS ONLY') AS ''
FROM borrowers
UNION
SELECT
	branch,
	count(*)
FROM statistics
WHERE
	statistics.datetime BETWEEN @StartDate AND @EndDate
	AND statistics.type IN ('issue')
GROUP by branch
UNION
SELECT
	CONCAT('CHILDREN BORROWERS') AS '',
	CONCAT('COUNT') AS ''
FROM borrowers
UNION
SELECT
	branchcode,
	count(*)
FROM borrowers
WHERE
	borrowers.dateofbirth BETWEEN (DATE_SUB(@EndDate, INTERVAL 14 YEAR)) AND @EndDate
GROUP by branchcode
UNION
SELECT
	CONCAT('HOLDS PLACED') AS '',
	CONCAT('COUNT') AS ''
FROM borrowers
UNION
SELECT
	branchcode,
	count(*)
FROM (
	SELECT
		branchcode,
		reservedate
	FROM reserves
	UNION ALL
	SELECT
		branchcode,
		reservedate
	FROM old_reserves
	) AS HoldsPlaced
WHERE
	reservedate BETWEEN @StartDate AND @EndDate
GROUP BY branchcode
