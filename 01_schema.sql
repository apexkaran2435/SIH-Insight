CREATE DATABASE IF NOT EXISTS SIH_Insight;
USE SIH_Insight;

CREATE TABLE IF NOT EXISTS Edition (
    edition_year INT PRIMARY KEY,
    edition_name VARCHAR(100) NOT NULL
);

CREATE TABLE IF NOT EXISTS Organization (
    organization_id INT AUTO_INCREMENT PRIMARY KEY,
    organization_name VARCHAR(255) NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS Theme (
    theme_id INT AUTO_INCREMENT PRIMARY KEY,
    theme_name VARCHAR(180) NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS Problem_Statement (
    ps_id VARCHAR(30) PRIMARY KEY,
    edition_year INT NOT NULL,
    title TEXT NOT NULL,
    category VARCHAR(50),
    theme_id INT,
    organization_id INT,
    department VARCHAR(255),
    description LONGTEXT,
    deadline VARCHAR(100),
    ideas_submitted VARCHAR(50),
    official_source_url VARCHAR(500),
    dataset_source_url VARCHAR(500),
    snapshot_date DATE,
    FOREIGN KEY (edition_year) REFERENCES Edition(edition_year),
    FOREIGN KEY (theme_id) REFERENCES Theme(theme_id),
    FOREIGN KEY (organization_id) REFERENCES Organization(organization_id)
);

CREATE TABLE IF NOT EXISTS Guide (
    guide_id INT AUTO_INCREMENT PRIMARY KEY,
    guide_name VARCHAR(120) NOT NULL,
    email VARCHAR(150),
    department VARCHAR(100),
    designation VARCHAR(100)
);

CREATE TABLE IF NOT EXISTS Student (
    student_id INT AUTO_INCREMENT PRIMARY KEY,
    student_name VARCHAR(120) NOT NULL,
    email VARCHAR(150) UNIQUE,
    phone VARCHAR(20),
    department VARCHAR(100),
    academic_year INT
);

CREATE TABLE IF NOT EXISTS Team (
    team_id INT AUTO_INCREMENT PRIMARY KEY,
    team_name VARCHAR(120) NOT NULL,
    college_name VARCHAR(180),
    department VARCHAR(100),
    created_on DATE
);

CREATE TABLE IF NOT EXISTS Team_Member (
    team_id INT NOT NULL,
    student_id INT NOT NULL,
    member_role VARCHAR(80),
    PRIMARY KEY (team_id, student_id),
    FOREIGN KEY (team_id) REFERENCES Team(team_id) ON DELETE CASCADE,
    FOREIGN KEY (student_id) REFERENCES Student(student_id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS Technology (
    technology_id INT AUTO_INCREMENT PRIMARY KEY,
    technology_name VARCHAR(100) NOT NULL UNIQUE,
    technology_category VARCHAR(100)
);

CREATE TABLE IF NOT EXISTS Project (
    project_id INT AUTO_INCREMENT PRIMARY KEY,
    project_title VARCHAR(220) NOT NULL,
    project_abstract TEXT,
    proposed_solution LONGTEXT,
    project_status VARCHAR(50) DEFAULT 'Draft',
    created_on DATE,
    team_id INT NOT NULL,
    guide_id INT,
    FOREIGN KEY (team_id) REFERENCES Team(team_id),
    FOREIGN KEY (guide_id) REFERENCES Guide(guide_id)
);

CREATE TABLE IF NOT EXISTS Project_PS (
    project_id INT NOT NULL,
    ps_id VARCHAR(30) NOT NULL,
    PRIMARY KEY (project_id, ps_id),
    FOREIGN KEY (project_id) REFERENCES Project(project_id) ON DELETE CASCADE,
    FOREIGN KEY (ps_id) REFERENCES Problem_Statement(ps_id)
);

CREATE TABLE IF NOT EXISTS Project_Technology (
    project_id INT NOT NULL,
    technology_id INT NOT NULL,
    PRIMARY KEY (project_id, technology_id),
    FOREIGN KEY (project_id) REFERENCES Project(project_id) ON DELETE CASCADE,
    FOREIGN KEY (technology_id) REFERENCES Technology(technology_id)
);

CREATE TABLE IF NOT EXISTS Submission (
    submission_id INT AUTO_INCREMENT PRIMARY KEY,
    project_id INT NOT NULL,
    submission_date DATE,
    submission_round VARCHAR(80),
    submission_status VARCHAR(50),
    submission_link VARCHAR(500),
    FOREIGN KEY (project_id) REFERENCES Project(project_id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS Result (
    result_id INT AUTO_INCREMENT PRIMARY KEY,
    project_id INT NOT NULL,
    edition_year INT NOT NULL,
    result_status VARCHAR(80),
    rank_position INT,
    award_name VARCHAR(150),
    remarks TEXT,
    FOREIGN KEY (project_id) REFERENCES Project(project_id) ON DELETE CASCADE,
    FOREIGN KEY (edition_year) REFERENCES Edition(edition_year)
);

CREATE TABLE IF NOT EXISTS Review (
    review_id INT AUTO_INCREMENT PRIMARY KEY,
    project_id INT NOT NULL,
    reviewer_name VARCHAR(120),
    rating DECIMAL(3,1),
    feedback TEXT,
    reviewed_on DATE,
    FOREIGN KEY (project_id) REFERENCES Project(project_id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS Document (
    document_id INT AUTO_INCREMENT PRIMARY KEY,
    project_id INT NOT NULL,
    document_name VARCHAR(180),
    document_type VARCHAR(80),
    document_path VARCHAR(500),
    uploaded_on DATE,
    FOREIGN KEY (project_id) REFERENCES Project(project_id) ON DELETE CASCADE
);

INSERT IGNORE INTO Edition VALUES
(2025, 'Smart India Hackathon 2025'),
(2026, 'Smart India Hackathon 2026');
