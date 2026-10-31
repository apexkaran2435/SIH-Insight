USE SIH_Insight;

-- 1. Display all original problem statements
SELECT * FROM Problem_Statement;

-- 2. Display problem statements edition-wise
SELECT edition_year, COUNT(*) AS total_problem_statements
FROM Problem_Statement GROUP BY edition_year;

-- 3. Search problem statements by title keyword
SELECT ps_id, title, category, edition_year
FROM Problem_Statement WHERE title LIKE '%AI%';

-- 4. Search by organization
SELECT ps_id, title, organization_name
FROM Problem_Statement p
JOIN Organization o ON p.organization_id = o.organization_id
WHERE o.organization_name LIKE '%Ministry%';

-- 5. Search by theme
SELECT ps_id, title, theme_name
FROM Problem_Statement p JOIN Theme t ON p.theme_id = t.theme_id
WHERE t.theme_name = 'Disaster Management';

-- 6. Software problem statements
SELECT ps_id, title FROM Problem_Statement WHERE category = 'Software';

-- 7. Hardware problem statements
SELECT ps_id, title FROM Problem_Statement WHERE category = 'Hardware';

-- 8. Count statements by category and edition
SELECT edition_year, category, COUNT(*) AS total
FROM Problem_Statement GROUP BY edition_year, category;

-- 9. Count statements by organization
SELECT o.organization_name, COUNT(*) AS total
FROM Problem_Statement p JOIN Organization o ON p.organization_id = o.organization_id
GROUP BY o.organization_id, o.organization_name ORDER BY total DESC;

-- 10. Count statements by theme
SELECT t.theme_name, COUNT(*) AS total
FROM Problem_Statement p JOIN Theme t ON p.theme_id = t.theme_id
GROUP BY t.theme_id, t.theme_name ORDER BY total DESC;

-- 11. Full details for a particular PS ID (replace the ID)
SELECT * FROM Problem_Statement WHERE ps_id = 'SIH26001';

-- 12. Projects with their teams
SELECT pr.project_title, tm.team_name, pr.project_status
FROM Project pr JOIN Team tm ON pr.team_id = tm.team_id;

-- 13. Project mapped to original problem statement
SELECT pr.project_title, p.ps_id, p.title AS official_problem_statement
FROM Project pr JOIN Project_PS x ON pr.project_id = x.project_id
JOIN Problem_Statement p ON x.ps_id = p.ps_id;

-- 14. Students in each team
SELECT tm.team_name, s.student_name, m.member_role
FROM Team_Member m JOIN Team tm ON m.team_id = tm.team_id
JOIN Student s ON m.student_id = s.student_id;

-- 15. Technologies used by each project
SELECT pr.project_title, t.technology_name
FROM Project_Technology pt JOIN Project pr ON pt.project_id = pr.project_id
JOIN Technology t ON pt.technology_id = t.technology_id;

-- 16. Projects guided by each guide
SELECT g.guide_name, pr.project_title
FROM Project pr LEFT JOIN Guide g ON pr.guide_id = g.guide_id;

-- 17. Projects with submission details
SELECT pr.project_title, s.submission_round, s.submission_status, s.submission_date
FROM Project pr LEFT JOIN Submission s ON pr.project_id = s.project_id;

-- 18. Projects with results
SELECT pr.project_title, r.edition_year, r.result_status, r.rank_position, r.award_name
FROM Project pr LEFT JOIN Result r ON pr.project_id = r.project_id;

-- 19. Average review rating
SELECT AVG(rating) AS average_rating FROM Review;

-- 20. Projects having rating above 7
SELECT pr.project_title, r.rating FROM Project pr
JOIN Review r ON pr.project_id = r.project_id WHERE r.rating > 7;

-- 21. Number of students in each team
SELECT tm.team_name, COUNT(m.student_id) AS member_count
FROM Team tm LEFT JOIN Team_Member m ON tm.team_id = m.team_id
GROUP BY tm.team_id, tm.team_name;

-- 22. Themes having more than five statements
SELECT t.theme_name, COUNT(*) AS total
FROM Problem_Statement p JOIN Theme t ON p.theme_id = t.theme_id
GROUP BY t.theme_id, t.theme_name HAVING COUNT(*) > 5;

-- 23. Problem statements with missing descriptions
SELECT ps_id, title FROM Problem_Statement
WHERE description IS NULL OR description = '';

-- 24. Problem statements by year, newest first
SELECT ps_id, title, edition_year FROM Problem_Statement ORDER BY edition_year DESC, ps_id;

-- 25. UNION: unique categories across editions
SELECT category FROM Problem_Statement WHERE edition_year = 2025
UNION
SELECT category FROM Problem_Statement WHERE edition_year = 2026;

-- 26. Subquery: statements in the most common theme
SELECT ps_id, title FROM Problem_Statement
WHERE theme_id = (SELECT theme_id FROM Problem_Statement
GROUP BY theme_id ORDER BY COUNT(*) DESC LIMIT 1);

-- 27. CASE expression for category label
SELECT ps_id, title,
CASE WHEN category = 'Software' THEN 'Software Track'
     WHEN category = 'Hardware' THEN 'Hardware Track'
     ELSE 'Other / Not Specified' END AS track_name
FROM Problem_Statement;

-- 28. LEFT JOIN: list every team, including teams without projects
SELECT tm.team_name, pr.project_title
FROM Team tm LEFT JOIN Project pr ON tm.team_id = pr.team_id;

-- 29. Find projects with no submission
SELECT pr.project_id, pr.project_title FROM Project pr
LEFT JOIN Submission s ON pr.project_id = s.project_id
WHERE s.submission_id IS NULL;

-- 30. Find duplicate-looking project titles (grouping exercise)
SELECT project_title, COUNT(*) AS title_count FROM Project
GROUP BY project_title HAVING COUNT(*) > 1;

-- 31. Update demo project status (run only if required)
-- UPDATE Project SET project_status = 'Under Review' WHERE project_id = 1;

-- 32. Delete a demo review (run only if required)
-- DELETE FROM Review WHERE review_id = 1;

-- 33. Transaction demonstration
START TRANSACTION;
UPDATE Project SET project_status = 'Under Review' WHERE project_id = 1;
-- COMMIT;
-- ROLLBACK;

-- 34. Count all records in major tables
SELECT 'Problem_Statement' AS table_name, COUNT(*) AS total FROM Problem_Statement
UNION ALL SELECT 'Organization', COUNT(*) FROM Organization
UNION ALL SELECT 'Theme', COUNT(*) FROM Theme
UNION ALL SELECT 'Student', COUNT(*) FROM Student
UNION ALL SELECT 'Team', COUNT(*) FROM Team
UNION ALL SELECT 'Project', COUNT(*) FROM Project;
