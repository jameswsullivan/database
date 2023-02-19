/* Count checkout & renewal, filter by item type. */
SELECT
	biblio.title,
	biblio.author,
	items.ccode,
	items.location,
	items.itype,
	COUNT(statistics.itemnumber) AS "checkout&renewal"
FROM statistics
LEFT JOIN items ON (statistics.itemnumber = items.itemnumber)
LEFT JOIN biblio ON (items.biblionumber = biblio.biblionumber)
WHERE
	statistics.datetime BETWEEN <<Transaction happened BETWEEN |date>> AND <<and |date>>
	AND statistics.type IN ('issue', 'renew')
	AND items.itype = <<Item Type |itemtypes>>
GROUP BY biblio.title
ORDER BY COUNT(statistics.itemnumber) DESC
LIMIT 10
/* With slight modification, report can be changed to only count checkouts or renewals */

/* Checkout counts by Item Type, date range, and branch */
SELECT
CONCAT('') AS 'Branch',
CONCAT('') AS 'Data'
UNION
SELECT
CONCAT('BRANCH'),
CONCAT('NO. OF ISSUES (CURRENT ITEMS)')
UNION
SELECT
	items.homebranch,
	COUNT(*)
FROM statistics
LEFT JOIN items ON (statistics.itemnumber = items.itemnumber)
WHERE
	items.itype = (@ItemTypeVar:= <<Item Type |itemtypes>>) COLLATE utf8mb4_unicode_ci
	AND statistics.datetime BETWEEN (@StartDateVar:=<<Checkout date BETWEEN |date>>) AND (@EndDateVar:=<<and |date>>)
	AND statistics.type = 'issue'
GROUP BY items.homebranch ASC
UNION
SELECT
CONCAT('BRANCH'),
CONCAT('NO. OF CURRENT ITEMS')
UNION
SELECT
	items.homebranch,
	COUNT(DISTINCT items.itemnumber)
FROM items
WHERE
	items.itype = @ItemTypeVar COLLATE utf8mb4_unicode_ci
	AND items.dateaccessioned <= @EndDateVar
GROUP BY items.homebranch ASC
UNION
SELECT
CONCAT('BRANCH'),
CONCAT('NO. OF ISSUES (DELETED ITEMS)')
UNION
SELECT
	deleteditems.homebranch,
	COUNT(*)
FROM statistics
LEFT JOIN deleteditems ON (statistics.itemnumber = deleteditems.itemnumber)
WHERE
	deleteditems.itype = @ItemTypeVar COLLATE utf8mb4_unicode_ci
	AND statistics.datetime BETWEEN @StartDateVar AND @EndDateVar
	AND statistics.type = 'issue'
GROUP BY deleteditems.homebranch ASC
UNION
SELECT
CONCAT('BRANCH'),
CONCAT('NO. OF DELETED ITEMS')
UNION
SELECT
	deleteditems.homebranch,
	COUNT(DISTINCT deleteditems.itemnumber)
FROM deleteditems
WHERE
	deleteditems.itype = @ItemTypeVar COLLATE utf8mb4_unicode_ci
	AND deleteditems.dateaccessioned <= @EndDateVar
GROUP BY deleteditems.homebranch ASC

/* Items that are currently checked out and their upcoming due date */
SELECT
	borrowers.surname,
	borrowers.firstname,
	borrowers.cardnumber,
	borrowers.city,
	biblio.title,
	items.barcode,
	items.price,
	items.homebranch,
	issues.issuedate,
	issues.date_due,
	issues.branchcode AS "Checkout Location"
FROM borrowers
LEFT JOIN issues USING (borrowernumber)
LEFT JOIN items USING (itemnumber)
LEFT JOIN biblio USING (biblionumber)
WHERE
	items.barcode IS NOT NULL
	AND (issues.issuedate BETWEEN <<Items checked out between |date>> AND <<and |date>>)
	AND (issues.date_due >= <<Due date greater than or equal to |date>>	)
	AND borrowers.city IN ('PARADISE', 'MAGALIA')
ORDER BY borrowers.surname, issues.date_due ASC