-- Vireo 4 troubleshooting and reporting SQLs.
-- https://github.com/TexasDigitalLibrary/Vireo

-- List all field_predicate:
SELECT * FROM field_predicate WHERE value != '' ORDER BY id ASC;

-- Find saved filters and their names and ID:
SELECT name, id, user_id FROM named_search_filter_group WHERE name != '';

-- Show all saved filters and their associated user ID:
SELECT * FROM weaver_users_saved_filters;

SELECT
    name AS "Saved Filter Name",
    id AS "Saved Filter ID",
    user_id AS "User ID"
FROM named_search_filter_group
WHERE name != '';

-- Find a user's saved filters id:
SELECT first_name, last_name, username, id, saved_filters_id
FROM weaver_users
LEFT JOIN weaver_users_saved_filters ON weaver_users.id = weaver_users_saved_filters.user_id
WHERE weaver_users.username = '<USERNAME/EMAIL>';

-- Find users' saved filters:
SELECT
    weaver_users.first_name,
    weaver_users.last_name,
    weaver_users.username,
    weaver_users.id AS "user_id",
    weaver_users_saved_filters.saved_filters_id,
    named_search_filter_group.name
FROM weaver_users
LEFT JOIN weaver_users_saved_filters ON weaver_users.id = weaver_users_saved_filters.user_id
LEFT JOIN named_search_filter_group ON weaver_users_saved_filters.saved_filters_id = named_search_filter_group.id
WHERE
    weaver_users.username = '<USERNAME/EMAIL>'
    AND named_search_filter_group.name != '';

-- Find submissions from a given department, between a date range.
WITH vars AS (
    SELECT
        '<DEPARTMENT_NAME>'::TEXT AS DEPARTMENT_NAME,
        '<STARTING_DATE>'::DATE AS STARTING_DATE,
        '<ENDING_DATE>'::DATE AS ENDING_DATE
)
SELECT
    submission.id AS "Submission ID",
    MAX(weaver_users.last_name) AS "Last Name",
    MAX(weaver_users.first_name) AS "First Name",
    MAX(title_table.value) AS "Title",
    MAX(abstract_table.value) AS "Abstract",
    MAX(submission.submission_date) AS "Submission Date"
FROM weaver_users
LEFT JOIN submission ON submission.submitter_id = weaver_users.id
LEFT JOIN submission_field_values dept_sfv ON submission.id = dept_sfv.submission_id
LEFT JOIN field_value dept_table ON dept_sfv.field_values_id = dept_table.id AND dept_table.field_predicate_id = 19
LEFT JOIN submission_field_values title_sfv ON submission.id = title_sfv.submission_id
LEFT JOIN field_value title_table ON title_sfv.field_values_id = title_table.id AND title_table.field_predicate_id = 29
LEFT JOIN submission_field_values abstract_sfv ON submission.id = abstract_sfv.submission_id
LEFT JOIN field_value abstract_table ON abstract_sfv.field_values_id = abstract_table.id AND abstract_table.field_predicate_id = 33
JOIN vars ON dept_table.value = vars.DEPARTMENT_NAME
WHERE
    dept_table.value = vars.DEPARTMENT_NAME AND
    submission.submission_date >= vars.STARTING_DATE AND
    submission.submission_date <= vars.ENDING_DATE
GROUP BY submission.id
ORDER BY submission.id ASC;

-- List submissions from a given major.
WITH vars AS (
    SELECT '<MAJOR>'::TEXT AS MAJOR
)
SELECT
    submission.id AS "Submission ID",
    MAX(weaver_users.last_name) AS "Last Name",
    MAX(weaver_users.first_name) AS "First Name",
    MAX(major_table.value) AS "Major",
    MAX(submission.submission_date) AS "Submission Date",
    MAX(title_table.value) AS "Title"
FROM weaver_users
LEFT JOIN submission ON submission.submitter_id = weaver_users.id
LEFT JOIN submission_field_values major_sfv ON submission.id = major_sfv.submission_id
LEFT JOIN field_value major_table ON major_sfv.field_values_id = major_table.id AND major_table.field_predicate_id = 21
LEFT JOIN submission_field_values title_sfv ON submission.id = title_sfv.submission_id
LEFT JOIN field_value title_table ON title_sfv.field_values_id = title_table.id AND title_table.field_predicate_id = 29
JOIN vars ON major_table.value = vars.MAJOR
GROUP BY submission.id
ORDER BY submission.id ASC;

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
WHERE submission.id = <SUBMISSION_ID>;

-- Export submissions by Document Type:
-- By date :
WITH vars AS (
    SELECT
        '<STARTING_DATE>'::DATE AS STARTING_DATE,
        '<ENDING_DATE>'::DATE AS ENDING_DATE
)
SELECT
    submission.id AS "Submission ID",
    MAX(CONCAT(weaver_users.last_name, ', ', weaver_users.first_name)) AS "Student Name",
    MAX(weaver_users.netid) AS "Student ID",
    MAX(college_table.value) AS "College",
    MAX(action_log.action_date) AS "Last Event Timestamp",
    MAX(action_log.entry) AS "Last Event"
FROM submission
LEFT JOIN weaver_users ON submission.submitter_id = weaver_users.id
LEFT JOIN submission_field_values college_sfv ON submission.id = college_sfv.submission_id
LEFT JOIN field_value college_table ON college_sfv.field_values_id = college_table.id AND college_table.field_predicate_id = 17
LEFT JOIN submission_field_values submission_type_sfv ON submission.id = submission_type_sfv.submission_id
LEFT JOIN field_value submission_type_table ON submission_type_sfv.field_values_id = submission_type_table.id AND submission_type_table.field_predicate_id = 32
LEFT JOIN action_log ON submission.last_action_id = action_log.id
JOIN vars ON submission.submission_date BETWEEN vars.STARTING_DATE AND vars.ENDING_DATE
GROUP BY submission.id
ORDER BY submission.id ASC;

-- By date and limit to a graduation semester :
WITH vars AS (
    SELECT
        '<GRADUATION_SEMESTER>'::TEXT AS GRADUATION_SEMESTER,
        '<STARTING_DATE>'::DATE AS STARTING_DATE,
        '<ENDING_DATE>'::DATE AS ENDING_DATE
)
SELECT
    submission.id AS "Submission ID",
    MAX(graduation_semester_table.value) AS "Graduation Semester",
    MAX(CONCAT(weaver_users.last_name, ', ', weaver_users.first_name)) AS "Student Name",
    MAX(weaver_users.netid) AS "Student ID",
    MAX(college_table.value) AS "College",
    MAX(action_log.action_date) AS "Last Event Timestamp",
    MAX(action_log.entry) AS "Last Event"
FROM submission
LEFT JOIN weaver_users ON submission.submitter_id = weaver_users.id
LEFT JOIN submission_field_values college_sfv ON submission.id = college_sfv.submission_id
LEFT JOIN field_value college_table ON college_sfv.field_values_id = college_table.id AND college_table.field_predicate_id = 17
LEFT JOIN submission_field_values graduation_semester_sfv ON submission.id = graduation_semester_sfv.submission_id
LEFT JOIN field_value graduation_semester_table ON graduation_semester_sfv.field_values_id = graduation_semester_table.id AND graduation_semester_table.field_predicate_id = 30
LEFT JOIN submission_field_values submission_type_sfv ON submission.id = submission_type_sfv.submission_id
LEFT JOIN field_value submission_type_table ON submission_type_sfv.field_values_id = submission_type_table.id AND submission_type_table.field_predicate_id = 32
LEFT JOIN action_log ON submission.last_action_id = action_log.id
JOIN vars ON submission.submission_date BETWEEN vars.STARTING_DATE AND vars.ENDING_DATE
WHERE graduation_semester_table.value = vars.GRADUATION_SEMESTER
GROUP BY submission.id
ORDER BY submission.id ASC;

-- By date, limit to a particular graduation semester, and display students' email and permanent email columns,
-- and display advisor's email :
WITH vars AS (
    SELECT
        '<GRADUATION_SEMESTER>'::TEXT AS GRADUATION_SEMESTER,
        '<STARTING_DATE>'::DATE AS STARTING_DATE,
        '<ENDING_DATE>'::DATE AS ENDING_DATE
)
SELECT
    submission.id AS "Submission ID",
    MAX(graduation_semester_table.value) AS "Graduation Semester",
    MAX(CONCAT(weaver_users.last_name, ', ', weaver_users.first_name)) AS "Student Name",
    MAX(weaver_users.netid) AS "Student ID",
    MAX(college_table.value) AS "College",
    MAX(action_log.action_date) AS "Last Event Timestamp",
    MAX(action_log.entry) AS "Last Event",
    MAX(weaver_users.email) AS "Student Email",
    MAX(permanent_email_table.value) AS "Permanent Email",
    MAX(vocabulary_word.name) AS "Advisor Name",
    MAX(vocabulary_word_contacts.contacts) AS "Advisor Email"
FROM submission
LEFT JOIN weaver_users ON submission.submitter_id = weaver_users.id
LEFT JOIN submission_field_values college_sfv ON submission.id = college_sfv.submission_id
LEFT JOIN field_value college_table ON college_sfv.field_values_id = college_table.id AND college_table.field_predicate_id = 17
LEFT JOIN submission_field_values graduation_semester_sfv ON submission.id = graduation_semester_sfv.submission_id
LEFT JOIN field_value graduation_semester_table ON graduation_semester_sfv.field_values_id = graduation_semester_table.id AND graduation_semester_table.field_predicate_id = 30
LEFT JOIN submission_field_values permanent_email_sfv ON submission.id = permanent_email_sfv.submission_id
LEFT JOIN field_value permanent_email_table ON permanent_email_sfv.field_values_id = permanent_email_table.id AND permanent_email_table.field_predicate_id = 24
LEFT JOIN submission_field_values advisor_sfv ON submission.id = advisor_sfv.submission_id
LEFT JOIN field_value advisor_table ON advisor_sfv.field_values_id = advisor_table.id AND advisor_table.field_predicate_id = 37
LEFT JOIN submission_field_values submission_type_sfv ON submission.id = submission_type_sfv.submission_id
LEFT JOIN field_value submission_type_table ON submission_type_sfv.field_values_id = submission_type_table.id AND submission_type_table.field_predicate_id = 32
LEFT JOIN vocabulary_word ON advisor_table.value = vocabulary_word.name
LEFT JOIN vocabulary_word_contacts ON vocabulary_word.id = vocabulary_word_contacts.vocabulary_word_id AND vocabulary_word.controlled_vocabulary_id = 10
LEFT JOIN action_log ON submission.last_action_id = action_log.id
JOIN vars ON submission.submission_date BETWEEN vars.STARTING_DATE AND vars.ENDING_DATE
WHERE graduation_semester_table.value = vars.GRADUATION_SEMESTER
GROUP BY submission.id
ORDER BY submission.id ASC;

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
