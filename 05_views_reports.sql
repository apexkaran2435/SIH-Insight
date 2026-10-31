USE SIH_Insight;

CREATE OR REPLACE VIEW Problem_Statement_Directory AS
SELECT p.ps_id, p.edition_year, p.title, p.category,
       t.theme_name, o.organization_name, p.department,
       p.deadline, p.ideas_submitted
FROM Problem_Statement p
LEFT JOIN Theme t ON p.theme_id = t.theme_id
LEFT JOIN Organization o ON p.organization_id = o.organization_id;

CREATE OR REPLACE VIEW Edition_Category_Summary AS
SELECT edition_year, category, COUNT(*) AS total_problem_statements
FROM Problem_Statement GROUP BY edition_year, category;

CREATE OR REPLACE VIEW Organization_Problem_Count AS
SELECT o.organization_name, COUNT(p.ps_id) AS total_problem_statements
FROM Organization o LEFT JOIN Problem_Statement p
ON o.organization_id = p.organization_id
GROUP BY o.organization_id, o.organization_name;

CREATE OR REPLACE VIEW Project_Management_Report AS
SELECT pr.project_id, pr.project_title, tm.team_name,
       g.guide_name, pr.project_status
FROM Project pr JOIN Team tm ON pr.team_id = tm.team_id
LEFT JOIN Guide g ON pr.guide_id = g.guide_id;

CREATE OR REPLACE VIEW Project_Review_Report AS
SELECT pr.project_title, rv.reviewer_name, rv.rating, rv.feedback, rv.reviewed_on
FROM Project pr JOIN Review rv ON pr.project_id = rv.project_id;

SELECT * FROM Problem_Statement_Directory;
SELECT * FROM Edition_Category_Summary;
SELECT * FROM Organization_Problem_Count;
SELECT * FROM Project_Management_Report;
