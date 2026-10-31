SIH INSIGHT - MYSQL WORKBENCH PROJECT
====================================

IMPORTANT HONEST DATA NOTE
--------------------------
This ZIP contains the complete SQL project structure and a Python generator.
The original SIH 2025/2026 rows are NOT pre-embedded in this ZIP because the
source exports must be fetched and parsed on the user's computer. Running
GENERATE_ORIGINAL_SQL.bat downloads the archived source files and generates
02_original_sih_data.sql containing SQL INSERT statements for the records
actually present in those source files. The script stops instead of inventing
records if a source download or column-detection step fails.

DATA SOURCES
------------
SIH 2025 source workbook (community-hosted export of portal data):
https://github.com/sathish126/SIH-2025-PROBLEM-STATEMENTS
Official SIH 2025 portal:
https://www.sih.gov.in/sih2025PS

SIH 2026 source JSON (community-hosted structured export; snapshot 21-Aug-2026):
https://github.com/iamsayanmanna/SIH-2026-Problem-Statements
Official SIH 2026 portal:
https://www.sih.gov.in/sih2026PS

HOW TO RUN
----------
1. Extract this ZIP folder.
2. Install Python 3 if it is not installed.
3. Double-click GENERATE_ORIGINAL_SQL.bat.
4. Wait for 02_original_sih_data.sql to be generated. Check printed row counts.
5. Open MySQL Workbench and execute files in this order:
   01_schema.sql
   02_original_sih_data.sql
   03_sample_project_data.sql
   04_queries.sql (run selected queries as needed)
   05_views_reports.sql
6. Verify with:
   USE SIH_Insight;
   SELECT edition_year, COUNT(*) FROM Problem_Statement GROUP BY edition_year;

TABLES
------
Edition, Organization, Theme, Problem_Statement, Guide, Student, Team,
Team_Member, Technology, Project, Project_PS, Project_Technology, Submission,
Result, Review, Document.

DATA SEPARATION
---------------
Problem_Statement contains original SIH problem-statement records.
Student, Team, Project, Submission, Result and Review demo rows are clearly
labelled sample/demo data. They are NOT claimed to be official SIH participant,
submission, shortlist or result records.

NOTE ON DATA FIELDS
-------------------
The SIH 2026 source export includes full problem descriptions. The SIH 2025
workbook may not include full descriptions; where the source workbook has no
description field, the SQL generator stores NULL rather than fabricating text.
The SIH 2026 dataset's difficulty score/level is community-derived, not an
official SIH field, so it is intentionally not inserted into the official PS table.
