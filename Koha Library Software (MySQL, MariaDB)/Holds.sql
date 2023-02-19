/* List expired holds for books on hold cleanup. */
SELECT *
FROM
(
SELECT
	borrowers.cardnumber AS "Cardnumber",
	CONCAT(borrowers.surname, ', ', borrowers.firstname) AS "Patron",
	items.barcode "ItemBarcode",
	CONCAT(biblio.title, ' by ', biblio.author) AS "Title",
	old_reserves.reservedate AS "ReservedDate",
	old_reserves.waitingdate AS "WaitingDate",
	old_reserves.expirationdate AS "ExpirationDate",
	old_reserves.branchcode AS "PickupLocation"
FROM old_reserves
LEFT JOIN items ON (items.itemnumber = old_reserves.itemnumber)
LEFT JOIN biblio ON (biblio.biblionumber = old_reserves.biblionumber)
LEFT JOIN borrowers ON (borrowers.borrowernumber = old_reserves.borrowernumber)
WHERE
	old_reserves.expirationdate = (@HoldsExpirationDate := <<Select an expiration date |date>>) COLLATE utf8mb4_unicode_ci
	AND old_reserves.branchcode = (@PickupBranch := <<Select a pickup branch |branches>>) COLLATE utf8mb4_unicode_ci
UNION
SELECT
	borrowers.cardnumber "Cardnumber",
	CONCAT(borrowers.surname, ', ', borrowers.firstname) AS "Patron",
	items.barcode "ItemBarcode",
	CONCAT(biblio.title, ' by ', biblio.author) AS "Title",
	reserves.reservedate AS "ReservedDate",
	reserves.waitingdate AS "WaitingDate",
	reserves.expirationdate AS "ExpirationDate",
	reserves.branchcode AS "PickupLocation"
FROM reserves
LEFT JOIN items ON (items.itemnumber = reserves.itemnumber)
LEFT JOIN biblio ON (biblio.biblionumber = reserves.biblionumber)
LEFT JOIN borrowers ON (borrowers.borrowernumber = reserves.borrowernumber)
WHERE
	reserves.expirationdate = @HoldsExpirationDate COLLATE utf8mb4_unicode_ci
	AND reserves.branchcode = @PickupBranch COLLATE utf8mb4_unicode_ci
) AS final
ORDER BY Patron, WaitingDate ASC