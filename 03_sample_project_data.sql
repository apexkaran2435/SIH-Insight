USE SIH_Insight;

-- DEMONSTRATION DATA ONLY: these are example student/team/project records,
-- not official SIH participant or result records.
INSERT IGNORE INTO Guide (guide_id, guide_name, email, department, designation) VALUES
(1, 'Dr. Sample Faculty', 'faculty@example.edu', 'Information Technology', 'Project Guide');

INSERT IGNORE INTO Student (student_id, student_name, email, phone, department, academic_year) VALUES
(1, 'Aarav Patil', 'aarav.demo@example.edu', '9000000001', 'Information Technology', 2),
(2, 'Riya Shah', 'riya.demo@example.edu', '9000000002', 'Information Technology', 2),
(3, 'Kabir Joshi', 'kabir.demo@example.edu', '9000000003', 'Information Technology', 2);

INSERT IGNORE INTO Team (team_id, team_name, college_name, department, created_on) VALUES
(1, 'Innovators Demo Team', 'Demo Engineering College', 'Information Technology', '2026-01-15');

INSERT IGNORE INTO Team_Member (team_id, student_id, member_role) VALUES
(1, 1, 'Team Leader'), (1, 2, 'Developer'), (1, 3, 'Research Member');

INSERT IGNORE INTO Technology (technology_id, technology_name, technology_category) VALUES
(1, 'Python', 'Programming Language'),
(2, 'MySQL', 'Database'),
(3, 'HTML', 'Frontend'),
(4, 'CSS', 'Frontend');

INSERT IGNORE INTO Project (project_id, project_title, project_abstract, proposed_solution, project_status, created_on, team_id, guide_id) VALUES
(1, 'Demo SIH Solution Portal', 'Demonstration project record for testing SIH Insight database relationships.', 'This is sample project data used only to demonstrate project and submission management.', 'Draft', '2026-02-01', 1, 1);

INSERT IGNORE INTO Project_Technology (project_id, technology_id) VALUES
(1, 1), (1, 2), (1, 3), (1, 4);

INSERT IGNORE INTO Submission (submission_id, project_id, submission_date, submission_round, submission_status, submission_link) VALUES
(1, 1, '2026-02-10', 'Internal Demo', 'Sample', 'https://example.com/demo');

INSERT IGNORE INTO Review (review_id, project_id, reviewer_name, rating, feedback, reviewed_on) VALUES
(1, 1, 'Sample Reviewer', 8.0, 'Demonstration feedback only.', '2026-02-12');

INSERT IGNORE INTO Document (document_id, project_id, document_name, document_type, document_path, uploaded_on) VALUES
(1, 1, 'Demo Synopsis', 'PDF', 'sample/demo_synopsis.pdf', '2026-02-10');
