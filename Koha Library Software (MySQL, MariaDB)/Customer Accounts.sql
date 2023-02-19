/*
List patron accounts with specified attributes.
(e.g. patrons who have signed up for newsletter.)
*/

SELECT
    cardnumber, 
    firstname, 
    surname, 
    email, 
    branchcode 
FROM borrowers 
INNER JOIN borrower_attributes USING (borrowernumber)
WHERE
    code = 'NEWSLETTER'
    AND attribute = '1'
    AND branchcode = <<Select a Branch |branches>>
    AND email != ''
GROUP BY email

/* Newly established borrower accounts between a given date range. */

-- Version 1
SELECT
	borrowers.branchcode AS "Branch",
	COUNT(borrowernumber) AS "New Patrons"
FROM borrowers 
WHERE
	dateenrolled BETWEEN (@StartDate:=<<New Borrowers between date |date>>) AND (@EndDate:=<<and |date>>)
	AND branchcode='BIGGS'
UNION
SELECT
	borrowers.branchcode AS "Branch",
	COUNT(borrowernumber) AS "New Patrons"
FROM borrowers 
WHERE
	dateenrolled BETWEEN @StartDate AND @EndDate
	AND branchcode='CHICO'
UNION
SELECT
	borrowers.branchcode AS "Branch",
	COUNT(borrowernumber) AS "New Patrons"
FROM borrowers 
WHERE
	dateenrolled BETWEEN @StartDate AND @EndDate
	AND branchcode='DURHAM'
UNION
SELECT
	borrowers.branchcode AS "Branch",
	COUNT(borrowernumber) AS "New Patrons"
FROM borrowers 
WHERE
	dateenrolled BETWEEN @StartDate AND @EndDate
	AND branchcode='GRIDLEY'
UNION
SELECT
	borrowers.branchcode AS "Branch",
	COUNT(borrowernumber) AS "New Patrons"
FROM borrowers 
WHERE
	dateenrolled BETWEEN @StartDate AND @EndDate
	AND branchcode='OROVILLE'
UNION
SELECT
	borrowers.branchcode AS "Branch",
	COUNT(borrowernumber) AS "New Patrons"
FROM borrowers 
WHERE
	dateenrolled BETWEEN @StartDate AND @EndDate
	AND branchcode='PARADISE'

-- Version 2
SELECT
	borrowers.branchcode AS "Branch",
	COUNT(borrowernumber) AS "New Patrons"
FROM borrowers 
WHERE
	dateenrolled BETWEEN <<New Borrowers between date |date>> AND <<and |date>>
	AND branchcode IN ('BIGGS', 'CHICO', 'DURHAM', 'GRIDLEY', 'OROVILLE', 'PARADISE')
GROUP BY branchcode
ORDER BY branchcode ASC

/* Addresses from patrons with some cleasing and normalization. */
SELECT
	CONCAT(borrowers.address, ", ", borrowers.city, ", ", borrowers.state, " ", SUBSTRING(borrowers.zipcode,1,5)) AS 'FullAddr',
	borrowers.address,
	borrowers.city,
	borrowers.state,
	SUBSTRING(borrowers.zipcode,1,5),
	COUNT(*)
FROM borrowers
WHERE
	borrowers.address != ""
	AND borrowers.city != ""
	AND borrowers.zipcode !=""
	AND borrowers.state != ""
GROUP BY CONCAT(borrowers.address, " ", borrowers.city, " ", SUBSTRING(borrowers.zipcode,1,5))
ORDER BY FullAddr ASC

/* Patron age groups by zipcode */
SELECT
	borrowers.cardnumber,
	FLOOR(DATEDIFF(CURDATE(), DATE(borrowers.dateofbirth))/365) as 'age'
FROM borrowers
WHERE
	FLOOR(DATEDIFF(CURDATE(), DATE(borrowers.dateofbirth))/365) BETWEEN <<Age between (numbers only) >> AND <<and >>
	AND borrowers.zipcode = <<Zipcode>>

/* All possible zipcodes used by patrons in a branch. */
SELECT
	DISTINCT SUBSTRING(borrowers.zipcode, 1, 5) AS "Zipcode"
FROM borrowers
WHERE
	borrowers.branchcode = <<Home Branch |branches>>
	AND borrowers.zipcode != ""
ORDER BY Zipcode ASC

/* Patron count. */

-- Total number of borrowers.
SELECT COUNT(borrowers.borrowernumber)
FROM borrowers

-- Count total patrons by home branch.
SELECT COUNT(DISTINCT borrowernumber)
FROM borrowers
WHERE branchcode = <<Home Branch |branches>>

-- Count patrons by zipcode in an age group.
SELECT
	SUBSTRING(borrowers.zipcode,1,5) AS 'ZipCode',
	COUNT(*) AS 'No.OfPatrons'
FROM borrowers
WHERE
	FLOOR(DATEDIFF(CURDATE(), DATE(borrowers.dateofbirth))/365) BETWEEN <<Age between>> AND <<and>>
	AND SUBSTRING(borrowers.zipcode,1,5) IN (SELECT DISTINCT SUBSTRING(borrowers.zipcode,1,5) FROM borrowers)
GROUP BY SUBSTRING(ZipCode,1,5)
ORDER BY SUBSTRING(ZipCode,1,5) ASC

-- Count patrons by zipcode by branch.
SELECT
	SUBSTRING(borrowers.zipcode, 1, 5) AS "ZIP",
	COUNT(DISTINCT borrowers.borrowernumber) AS "NumOfPatrons"
FROM borrowers
WHERE
	borrowers.branchcode = <<Home Branch |branches>>
	AND borrowers.zipcode != ""
GROUP BY SUBSTRING(borrowers.zipcode, 1, 5)
ORDER BY NumOfPatrons DESC

-- Count patrons by zipcode (all branches).
SELECT
	SUBSTRING(borrowers.zipcode, 1, 5) AS "ZIP",
	COUNT(DISTINCT borrowers.borrowernumber) AS "NumOfPatrons"
FROM borrowers
WHERE
	borrowers.zipcode != ""
GROUP BY SUBSTRING(borrowers.zipcode, 1, 5)
ORDER BY NumOfPatrons DESC

-- Count patrons by age group in a branch.
SELECT
	COUNT(DISTINCT borrowers.cardnumber) AS "Total"
FROM borrowers
WHERE
	FLOOR(DATEDIFF(CURDATE(), DATE(borrowers.dateofbirth))/365) BETWEEN <<Age between (numbers only) >> AND <<and >>
	AND borrowers.branchcode = <<Home Branch |branches>>

-- Count patrons by each age group in a branch.
SELECT
	CONCAT('0-19') AS 'Age Group',
	COUNT(DISTINCT borrowers.cardnumber) AS "Total"
FROM borrowers
WHERE
	FLOOR(DATEDIFF(CURDATE(), DATE(borrowers.dateofbirth))/365) BETWEEN '0' AND '19'
	AND borrowers.branchcode = @HomeBranch := <<Home Branch |branches>> COLLATE utf8mb4_unicode_ci
UNION
SELECT
	CONCAT('20-29') AS 'Age Group',
	COUNT(DISTINCT borrowers.cardnumber) AS "Total"
FROM borrowers
WHERE
	FLOOR(DATEDIFF(CURDATE(), DATE(borrowers.dateofbirth))/365) BETWEEN '20' AND '29'
	AND borrowers.branchcode = @HomeBranch
UNION
SELECT
	CONCAT('30-44') AS 'Age Group',
	COUNT(DISTINCT borrowers.cardnumber) AS "Total"
FROM borrowers
WHERE
	FLOOR(DATEDIFF(CURDATE(), DATE(borrowers.dateofbirth))/365) BETWEEN '30' AND '44'
	AND borrowers.branchcode = @HomeBranch
UNION
SELECT
	CONCAT('45-64') AS 'Age Group',
	COUNT(DISTINCT borrowers.cardnumber) AS "Total"
FROM borrowers
WHERE
	FLOOR(DATEDIFF(CURDATE(), DATE(borrowers.dateofbirth))/365) BETWEEN '45' AND '64'
	AND borrowers.branchcode = @HomeBranch
UNION
SELECT
	CONCAT('65+') AS 'Age Group',
	COUNT(DISTINCT borrowers.cardnumber) AS "Total"
FROM borrowers
WHERE
	FLOOR(DATEDIFF(CURDATE(), DATE(borrowers.dateofbirth))/365) BETWEEN '65' AND '9999'
	AND borrowers.branchcode = @HomeBranch

-- Count patrons by each age group in the entire library.
SELECT
	CONCAT('0-19') AS 'Age Group',
	COUNT(DISTINCT borrowers.cardnumber) AS "Total"
FROM borrowers
WHERE
	FLOOR(DATEDIFF(CURDATE(), DATE(borrowers.dateofbirth))/365) BETWEEN '0' AND '19'
UNION
SELECT
	CONCAT('20-29') AS 'Age Group',
	COUNT(DISTINCT borrowers.cardnumber) AS "Total"
FROM borrowers
WHERE
	FLOOR(DATEDIFF(CURDATE(), DATE(borrowers.dateofbirth))/365) BETWEEN '20' AND '29'
UNION
SELECT
	CONCAT('30-44') AS 'Age Group',
	COUNT(DISTINCT borrowers.cardnumber) AS "Total"
FROM borrowers
WHERE
	FLOOR(DATEDIFF(CURDATE(), DATE(borrowers.dateofbirth))/365) BETWEEN '30' AND '44'
UNION
SELECT
	CONCAT('45-64') AS 'Age Group',
	COUNT(DISTINCT borrowers.cardnumber) AS "Total"
FROM borrowers
WHERE
	FLOOR(DATEDIFF(CURDATE(), DATE(borrowers.dateofbirth))/365) BETWEEN '45' AND '64'
UNION
SELECT
	CONCAT('65+') AS 'Age Group',
	COUNT(DISTINCT borrowers.cardnumber) AS "Total"
FROM borrowers
WHERE
	FLOOR(DATEDIFF(CURDATE(), DATE(borrowers.dateofbirth))/365) BETWEEN '65' AND '9999'

-- Active patrons - by checkout/renewal activities.
SELECT
    borrowers.branchcode,
    COUNT(DISTINCT borrowers.borrowernumber)
FROM borrowers
LEFT JOIN statistics ON (borrowers.borrowernumber = statistics.borrowernumber)
WHERE
    statistics.type IN ('issue', 'renew')
    AND statistics.datetime BETWEEN '2019-06-01' AND '2020-06-01'
GROUP BY borrowers.branchcode
ORDER BY borrowers.branchcode ASC

-- By account expiration date.
SELECT
    borrowers.branchcode,
    COUNT(*)
FROM borrowers
WHERE borrowers.dateexpiry >= '2020-06-01'
GROUP BY borrowers.branchcode
ORDER BY borrowers.branchcode

