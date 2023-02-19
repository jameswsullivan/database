/* List unique branchcode */

SELECT DISTINCT branchcode
FROM borrowers

/*
Library card numbers and their length.

There are a lot of library accounts and card numbers in the system that are created for different
administrative/technical purposes, some are alphanumeric, some are numeric only.
In order for some third party vendors to authenticate their apps/product via library card numbers
they usually require we provide card number prefix and their length.
This report is to list all the card numbers and their length for administrators to find any card numbers
that are out of the range, have typos, etc..
*/

SELECT
    cardnumber,
    LENGTH(cardnumber),
    CONCAT('<a href=\"/cgi-bin/koha/members/memberentry.pl?op=modify&borrowernumber=', borrowernumber, '&step=3\">', borrowernumber, '</a>' ) AS borrowernumber 
FROM borrowers
WHERE
    cardnumber regexp '^\\d+$'
ORDER BY LENGTH(cardnumber) DESC, cardnumber DESC

/* 
List library card numbers that are greater than or equal to a given starting card number.
Change the Specify_Your_Starting_Card_Number to what you use in your system.
*/

-- Version 1
SELECT
    CONCAT('<a href=\"/cgi-bin/koha/circ/circulation.pl?borrowernumber=', borrowers.borrowernumber, '\" target=/"_blank\">', borrowers.cardnumber, '</a>' ) AS 'PatronCardNumber',
    borrowers.cardnumber,
    LENGTH(borrowers.cardnumber) AS 'LibraryCardLength',
    CONCAT(borrowers.firstname, ' ', borrowers.surname) AS 'Name',
    borrowers.dateenrolled AS 'RegistrationDate',
    borrowers.dateexpiry AS 'ExpirationDate',
    borrowers.branchcode AS 'BranchCode',
    borrowers.categorycode AS 'CategoryCode'
FROM borrowers
WHERE
    borrowers.cardnumber regexp '^[0-9]+$'
    AND CAST(borrowers.cardnumber AS INT) >= Specify_Your_Starting_Card_Number
ORDER BY CAST(borrowers.cardnumber AS INT) DESC

-- Version 2
SELECT
    borrowers.cardnumber,
    LENGTH(borrowers.cardnumber) AS 'LibraryCardLength',
    CONCAT(borrowers.firstname, ' ', borrowers.surname) AS 'Name',
    borrowers.dateenrolled AS 'RegistrationDate',
    borrowers.dateexpiry AS 'ExpirationDate',
    borrowers.branchcode AS 'BranchCode',
    borrowers.categorycode AS 'CategoryCode',
    CONCAT(borrowers.address, ' ', borrowers.city, ' ', borrowers.state, ' ', borrowers.zipcode) AS 'Addr',
    borrowers.email,
    borrowers.phone,
    borrowers.dateofbirth,
    borrowers.sort2
FROM borrowers
WHERE
    borrowers.cardnumber regexp '^[0-9]+$'
    AND CAST(borrowers.cardnumber AS INT) >= Specify_Your_Starting_Card_Number
ORDER BY CAST(borrowers.cardnumber AS INT) DESC