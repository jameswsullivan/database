-- Vireo 4 troubleshooting and reporting SQLs.
-- https://github.com/TexasDigitalLibrary/Vireo

-- Export submissions from a given department, between a date range.
-- Columns: Last Name, First Name, Title, Abstract, Submission Date
COPY
(SELECT
    title_table.last_name AS "Last Name",
    title_table.first_name AS "First Name",
    title_table.submission_title AS "Title",
    field_value.value AS "Abstract",
    title_table.submission_date AS "Submission Date"
FROM
(SELECT
    dept_table.last_name AS "last_name",
    dept_table.first_name AS "first_name",
    dept_table.submission_dept AS "submission_dept",
    dept_table.submission_date AS "submission_date",
    dept_table.submission_id AS "submission_id",
    field_value.value AS "submission_title"
FROM
(SELECT
    last_name,
    first_name,
    field_value.value AS "submission_dept",
    submission_date,
    submission.id AS "submission_id"
FROM weaver_users
LEFT JOIN submission ON submission.submitter_id = weaver_users.id
LEFT JOIN submission_field_values ON submission.id = submission_field_values.submission_id
LEFT JOIN field_value ON submission_field_values.field_values_id = field_value.id
WHERE
    field_value.field_predicate_id = 19 AND
    field_value.value = '<DEPARTMENT>' AND
    submission.submission_date >= '<STARTING_DATE>' AND
    submission.submission_date <= '<ENDING_DATE>') dept_table
LEFT JOIN submission_field_values ON dept_table.submission_id = submission_field_values.submission_id
LEFT JOIN field_value ON submission_field_values.field_values_id = field_value.id
WHERE field_value.field_predicate_id = 29) title_table
LEFT JOIN submission_field_values ON title_table.submission_id = submission_field_values.submission_id
LEFT JOIN field_value ON submission_field_values.field_values_id = field_value.id
WHERE field_value.field_predicate_id = 33)
TO '<DESTINATION_FILE_PATH.CSV>'
WITH CSV HEADER;

-- List submissions from a given major.
-- Columns: Last Name, First Name, Major, Submission Date, Submission ID, Submission Title
SELECT
    major_table.last_name AS "last_name",
    major_table.first_name AS "first_name",
    major_table.submission_major AS "submission_major",
    major_table.submission_date AS "submission_date",
    major_table.submission_id AS "submission_id",
    field_value.value AS "submission_title"
FROM
(SELECT
    last_name,
    first_name,
    field_value.value AS "submission_major",
    submission_date,
    submission.id AS "submission_id"
FROM weaver_users
LEFT JOIN submission ON submission.submitter_id = weaver_users.id
LEFT JOIN submission_field_values ON submission.id = submission_field_values.submission_id
LEFT JOIN field_value ON submission_field_values.field_values_id = field_value.id
WHERE
    field_value.field_predicate_id = 21 AND
    field_value.value = '<MAJOR>') major_table
LEFT JOIN submission_field_values ON major_table.submission_id = submission_field_values.submission_id
LEFT JOIN field_value ON submission_field_values.field_values_id = field_value.id
WHERE field_value.field_predicate_id = 29;

-- Select all field values associated with a submisison
-- without Title and Abstract because the texts are too long
WITH vars AS (
    SELECT <SUBMISSION_ID>::BIGINT AS SUBMISSION_ID
)
SELECT
    submission.id AS "submission.id",
    submission.submitter_id AS "submitter_id",
    field_value.id AS "field_value.id",
    field_value.value AS "field_value.value",
    field_predicate.value AS "field_predicate.value",
    field_value.field_predicate_id AS "field_value.field_predicate_id"
FROM submission
LEFT JOIN weaver_users submitter ON submission.submitter_id = submitter.id
LEFT JOIN weaver_users assignee ON submission.assignee_id = assignee.id
LEFT JOIN organization ON submission.organization_id = organization.id
LEFT JOIN organization_category ON organization.category_id = organization_category.id
LEFT JOIN submission_status ON submission.submission_status_id = submission_status.id
LEFT JOIN submission_field_values ON submission.id = submission_field_values.submission_id
LEFT JOIN field_value ON submission_field_values.field_values_id = field_value.id
LEFT JOIN field_predicate ON field_predicate.id = field_value.field_predicate_id
JOIN vars ON submission.id = vars.SUBMISSION_ID
WHERE submission.id = vars.SUBMISSION_ID AND
    field_value.field_predicate_id != 33 AND
    field_value.field_predicate_id != 29;

-- Select all field values associated with a submission. With Title and Abstract.
WITH vars AS (
    SELECT <SUBMISSION_ID>::BIGINT AS SUBMISSION_ID
)
SELECT
    submission.id AS "submission.id",
    submission.submitter_id AS "submitter_id",
    field_value.id AS "field_value.id",
    field_value.value AS "field_value.value",
    field_predicate.value AS "field_predicate.value",
    field_value.field_predicate_id AS "field_value.field_predicate_id"
FROM submission
LEFT JOIN weaver_users submitter ON submission.submitter_id = submitter.id
LEFT JOIN weaver_users assignee ON submission.assignee_id = assignee.id
LEFT JOIN organization ON submission.organization_id = organization.id
LEFT JOIN organization_category ON organization.category_id = organization_category.id
LEFT JOIN submission_status ON submission.submission_status_id = submission_status.id
LEFT JOIN submission_field_values ON submission.id = submission_field_values.submission_id
LEFT JOIN field_value ON submission_field_values.field_values_id = field_value.id
LEFT JOIN field_predicate ON field_predicate.id = field_value.field_predicate_id
JOIN vars ON submission.id = vars.SUBMISSION_ID
WHERE submission.id = vars.SUBMISSION_ID;

-- Find submission and the submitter info
WITH vars AS (
    SELECT <SUBMISSION_ID>::BIGINT AS SUBMISSION_ID
)
SELECT
    submission.id, submission.approve_advisor_date, submission.approve_application_date, submission.submission_date,
    weaver_users.id, username, email, first_name, last_name, netid
FROM submission
LEFT JOIN weaver_users ON submission.submitter_id = weaver_users.id
JOIN vars ON submission.id = vars.SUBMISSION_ID
WHERE submission.id = vars.SUBMISSION_ID;

-- Find weaver_user or submitter
SELECT
    first_name, last_name,
    id AS "submitter_id",
    username, email,netid, role, active_filter_id,
    current_contact_info_id, permanent_contact_info_id
FROM weaver_users
WHERE id = <USER_ID>;

-- Find submission and the submitter info
SELECT
    submission.id AS "submission_id",submitter.first_name, submitter.last_name,
    submitter.id AS "submitter_id", submitter.netid,
    submitter.username, submitter.email,submission.submission_date,
    submission.approve_advisor_date, submission.approve_application_date
FROM submission
LEFT JOIN weaver_users submitter ON submission.submitter_id = submitter.id
WHERE submission.id = <SUBMISSION_ID>;

-- Find submission, submitter, and asignee info
SELECT
    submission.id AS "submission_id",
    submission.submission_date,
    submitter.first_name AS "submitter_first_name",
    submitter.last_name AS "submitter_last_name",
    submitter.id AS "submitter_id",
    submitter.netid AS "submitter_netid",
    submitter.username AS "submitter_username",
    submitter.email AS "submitter_email",
    assignee.first_name AS "asignee_first_name",
    assignee.last_name AS "asignee_last_name",
    assignee.id AS "assignee_id",
    assignee.netid AS "asignee_netid",
    assignee.username AS "asignee_username",
    assignee.email AS "asignee_email",
    submission.approve_advisor_date, submission.approve_application_date
FROM submission
LEFT JOIN weaver_users submitter ON submission.submitter_id = submitter.id
LEFT JOIN weaver_users assignee ON submission.assignee_id = assignee.id
LEFT JOIN organization ON submission.organization_id = organization.id
LEFT JOIN submission_status ON submission.submission_status_id = submission_status.id
WHERE submission.id = <SUBMISSION_ID>;

-- Export submissions by Document Type:
-- By date :
COPY
(SELECT
    student_name AS "Student name",
    student_id AS "Student ID",
    college AS "College",
    last_event AS "Last Event",
    submission_type_table.value AS "Document Type"
FROM
(SELECT
    submission.id AS "submission_id",
    CONCAT(weaver_users.last_name, ', ', weaver_users.first_name) AS "student_name",
    weaver_users.netid AS "student_id",
    college_table.value AS "college",
    action_log.action_date AS "last_event_timestamp",
    action_log.entry AS "last_event"
FROM submission
LEFT JOIN weaver_users ON submission.submitter_id = weaver_users.id
LEFT JOIN submission_field_values ON submission.id = submission_field_values.submission_id
LEFT JOIN field_value college_table ON submission_field_values.field_values_id = college_table.id
LEFT JOIN action_log ON submission.last_action_id = action_log.id
WHERE
    submission.submission_date >= '<STARTING_DATE>' AND
    submission.submission_date <= '<ENDING_DATE>' AND
    college_table.field_predicate_id = 17
ORDER BY submission_id DESC) AS first_table
LEFT JOIN submission_field_values ON first_table.submission_id = submission_field_values.submission_id
LEFT JOIN field_value submission_type_table ON submission_field_values.field_values_id = submission_type_table.id
WHERE submission_type_table.field_predicate_id = 32)
TO '<DESTINATION_FILE_NAME>.csv'
WITH CSV HEADER;

-- By date and limit to a graduation semester :
COPY
(SELECT
    student_name AS "Student name",
    student_id AS "Student ID",
    college AS "College",
    last_event AS "Last Event",
    submission_type_table.value AS "Document Type"
FROM
(SELECT
    MAX(graduation_semester_table.value) AS "graduation_semester",
    submission.id AS "submission_id",
    MAX(CONCAT(weaver_users.last_name, ', ', weaver_users.first_name)) AS "student_name",
    MAX(weaver_users.netid) AS "student_id",
    MAX(college_table.value) AS "college",
    MAX(action_log.action_date) AS "last_event_timestamp",
    MAX(action_log.entry) AS "last_event"
FROM submission
LEFT JOIN weaver_users ON submission.submitter_id = weaver_users.id
LEFT JOIN submission_field_values ON submission.id = submission_field_values.submission_id
LEFT JOIN field_value college_table ON submission_field_values.field_values_id = college_table.id AND college_table.field_predicate_id = 17
LEFT JOIN field_value graduation_semester_table ON submission_field_values.field_values_id = graduation_semester_table.id AND graduation_semester_table.field_predicate_id = 30 AND graduation_semester_table.value = '<GRADUATION_SEMESTER>'
LEFT JOIN action_log ON submission.last_action_id = action_log.id
WHERE
    submission.submission_date >= '<STARTING_DATE>' AND
    submission.submission_date <= '<ENDING_DATE>'
GROUP BY submission.id
ORDER BY submission_id DESC) AS first_table
LEFT JOIN submission_field_values ON first_table.submission_id = submission_field_values.submission_id
LEFT JOIN field_value submission_type_table ON submission_field_values.field_values_id = submission_type_table.id
WHERE
    submission_type_table.field_predicate_id = 32 AND
    first_table.graduation_semester = '<GRADUATION_SEMESTER>')
TO '<DESTINATION_FILE_NAME>.csv'
WITH CSV HEADER;

-- By date, limit to a particular graduation semester, and display students' email and permanent email columns,
-- and display advisor's email :
COPY
(SELECT
    student_name AS "Student name",
    student_id AS "Student ID",
    college AS "College",
    last_event AS "Last Event",
    submission_type_table.value AS "Document Type",
    student_email AS "Student Email",
    permanent_email AS "Permanent Email",
    advisor_name AS "Advisor Name",
    advisor_email AS "Advisor Email"
FROM
(SELECT
    MAX(graduation_semester_table.value) AS "graduation_semester",
    submission.id AS "submission_id",
    MAX(CONCAT(weaver_users.last_name, ', ', weaver_users.first_name)) AS "student_name",
    MAX(weaver_users.netid) AS "student_id",
    MAX(college_table.value) AS "college",
    MAX(action_log.action_date) AS "last_event_timestamp",
    MAX(action_log.entry) AS "last_event",
    MAX(weaver_users.email) AS "student_email",
    MAX(permanent_email_table.value) AS "permanent_email",
    MAX(vocabulary_word.name) AS "advisor_name",
    MAX(vocabulary_word_contacts.contacts) AS "advisor_email"
FROM submission
LEFT JOIN weaver_users ON submission.submitter_id = weaver_users.id
LEFT JOIN submission_field_values ON submission.id = submission_field_values.submission_id
LEFT JOIN field_value college_table ON submission_field_values.field_values_id = college_table.id AND college_table.field_predicate_id = 17
LEFT JOIN field_value graduation_semester_table ON submission_field_values.field_values_id = graduation_semester_table.id AND graduation_semester_table.field_predicate_id = 30 AND graduation_semester_table.value = '<GRADUATION_SEMESTER>'
LEFT JOIN field_value permanent_email_table ON submission_field_values.field_values_id = permanent_email_table.id AND permanent_email_table.field_predicate_id = 24
LEFT JOIN field_value advisor_table ON submission_field_values.field_values_id = advisor_table.id AND advisor_table.field_predicate_id = 37
LEFT JOIN vocabulary_word ON advisor_table.value = vocabulary_word.name
LEFT JOIN vocabulary_word_contacts ON vocabulary_word.id = vocabulary_word_contacts.vocabulary_word_id AND vocabulary_word.controlled_vocabulary_id = 10
LEFT JOIN action_log ON submission.last_action_id = action_log.id
WHERE
    submission.submission_date >= '<STARTING_DATE>' AND
    submission.submission_date <= '<ENDING_DATE>'
GROUP BY submission.id
ORDER BY submission_id DESC) AS first_table
LEFT JOIN submission_field_values ON first_table.submission_id = submission_field_values.submission_id
LEFT JOIN field_value submission_type_table ON submission_field_values.field_values_id = submission_type_table.id
WHERE
    submission_type_table.field_predicate_id = 32 AND
    first_table.graduation_semester = '<GRADUATION_SEMESTER>')
TO '<DESTINATION_FILE_NAME>.csv'
WITH CSV HEADER;

-- By submission ID :
COPY
(SELECT
    student_name AS "Student name",
    student_id AS "Student ID",
    college AS "College",
    last_event AS "Last Event",
    submission_type_table.value AS "Document Type"
FROM
(SELECT
    submission.id AS "submission_id",
    CONCAT(weaver_users.last_name, ', ', weaver_users.first_name) AS "student_name",
    weaver_users.netid AS "student_id",
    college_table.value AS "college",
    action_log.action_date AS "last_event_timestamp",
    action_log.entry AS "last_event"
FROM submission
LEFT JOIN weaver_users ON submission.submitter_id = weaver_users.id
LEFT JOIN submission_field_values ON submission.id = submission_field_values.submission_id
LEFT JOIN field_value college_table ON submission_field_values.field_values_id = college_table.id
LEFT JOIN action_log ON submission.last_action_id = action_log.id
WHERE
    submission_id > <CHANGE_SUBMISSION_ID_HERE> AND
    college_table.field_predicate_id = 17) AS first_table
LEFT JOIN submission_field_values ON first_table.submission_id = submission_field_values.submission_id
LEFT JOIN field_value submission_type_table ON submission_field_values.field_values_id = submission_type_table.id
WHERE submission_type_table.field_predicate_id = 32)
TO '<DESTINATION_FILE_NAME>.csv'
WITH CSV HEADER;

-- Export dissertations by given month-year:
COPY
(SELECT * FROM
(SELECT
  submission.id AS "submission_id",
  MAX(college_table.value) AS "college",
  MAX(weaver_users.last_name) AS "last_name",
  MAX(weaver_users.first_name) AS "first_name",
  MAX(title_table.value) AS "title",
  MAX(major_table.value) AS "major",
  MAX(committee_chair_table.value) AS "committee_chair",
  MAX(committee_cochair_table.value) AS "committee_cochair",
  MAX(graduation_semester_table.value) AS "graduation_semester",
  MAX(submission_type_table.value) AS "submission_type"
FROM submission
LEFT JOIN weaver_users ON submission.submitter_id = weaver_users.id
LEFT JOIN submission_field_values ON submission.id = submission_field_values.submission_id
LEFT JOIN field_value college_table ON submission_field_values.field_values_id = college_table.id AND college_table.field_predicate_id = 17
LEFT JOIN field_value title_table ON submission_field_values.field_values_id = title_table.id AND title_table.field_predicate_id = 29
LEFT JOIN field_value major_table ON submission_field_values.field_values_id = major_table.id AND major_table.field_predicate_id = 21
LEFT JOIN field_value committee_chair_table ON submission_field_values.field_values_id = committee_chair_table.id AND committee_chair_table.field_predicate_id = 37
LEFT JOIN field_value committee_cochair_table ON submission_field_values.field_values_id = committee_cochair_table.id AND committee_cochair_table.field_predicate_id = 43
LEFT JOIN field_value graduation_semester_table ON submission_field_values.field_values_id = graduation_semester_table.id AND graduation_semester_table.field_predicate_id = 30 AND graduation_semester_table.value = 'December 2024'
LEFT JOIN field_value submission_type_table ON submission_field_values.field_values_id = submission_type_table.id AND submission_type_table.field_predicate_id = 32 AND submission_type_table.value = 'Dissertation'
WHERE submission.id >= <SUBMISSION_ID>
GROUP BY submission.id) full_table
WHERE full_table.submission_type = 'Dissertation' and full_table.graduation_semester = '<Month Year>')
TO '<DESTINATION_FILE_NAME>.csv'
WITH CSV HEADER;
