## About Koha

The Koha Library Software (also referred to as the KOHA ILS) is an open source Integrated Library Software developed and support by the Koha Community.
For more information about the KOHA ILS, please refer to the [Koha Community Website](https://koha-community.org/).

## About The SQL Queries

I used to support all aspects of the IT needs of a public library system in California. These SQL queries were written back then to serve user requests and gather statistics.

**Note:**

If you are a savvy SQL programmer, you will often find that some of the queries are written in a "cumbersome/chunky" way and can definitely be optimized or simplified. However, on one hand, the KOHA ILS's built-in report module has its own limitations and functionalities that dictate what you can/cannot do with all your SQL magic such as some advanced query functions and window functions. If, for example, you have the option to write queries in a C# console app via an ODBC connection directly to the database, the codes will become much more elegant. On the other hand, some of these reports were written to serve specific user requests and they wanted certain things to be displayed/formatted in a specific way (e.g. financial reports that would match the reports they get from other systems), and occasionally also to accommodate non-tech savvy users so that they can modify the reports as-needed on their own, thus some compromises were made for the ease of their use.

For better performance, I recommend that you **optimize** the queries before using them.