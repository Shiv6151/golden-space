-- Migration Script: Add Professional Profile Features
-- Run this on your existing database to enable Experience, Education, Skills, and Recommendations.

-- 1. Update Users Table
ALTER TABLE Users ADD COLUMN headline VARCHAR(255) AFTER bio;
ALTER TABLE Users ADD COLUMN professional_summary TEXT AFTER headline;

-- 2. Create Experience Table
CREATE TABLE IF NOT EXISTS Experience (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    company VARCHAR(100) NOT NULL,
    title VARCHAR(100) NOT NULL,
    location VARCHAR(100),
    start_date DATE NOT NULL,
    end_date DATE,
    description TEXT,
    is_current BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (user_id) REFERENCES Users(user_id) ON DELETE CASCADE
);

-- 3. Create Education Table
CREATE TABLE IF NOT EXISTS Education (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    school VARCHAR(100) NOT NULL,
    degree VARCHAR(100) NOT NULL,
    field_of_study VARCHAR(100),
    start_date DATE NOT NULL,
    end_date DATE,
    description TEXT,
    FOREIGN KEY (user_id) REFERENCES Users(user_id) ON DELETE CASCADE
);

-- 4. Create Skills Table
CREATE TABLE IF NOT EXISTS Skills (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) UNIQUE NOT NULL,
    category VARCHAR(50)
);

-- 5. Create UserSkills Table
CREATE TABLE IF NOT EXISTS UserSkills (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    skill_id INT NOT NULL,
    FOREIGN KEY (user_id) REFERENCES Users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (skill_id) REFERENCES Skills(id) ON DELETE CASCADE,
    UNIQUE KEY unique_user_skill (user_id, skill_id)
);

-- 6. Create Endorsements Table
CREATE TABLE IF NOT EXISTS Endorsements (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_skill_id INT NOT NULL,
    endorser_id INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_skill_id) REFERENCES UserSkills(id) ON DELETE CASCADE,
    FOREIGN KEY (endorser_id) REFERENCES Users(user_id) ON DELETE CASCADE,
    UNIQUE KEY unique_endorsement (user_skill_id, endorser_id)
);

-- 7. Create Recommendations Table
CREATE TABLE IF NOT EXISTS Recommendations (
    id INT AUTO_INCREMENT PRIMARY KEY,
    sender_id INT NOT NULL,
    receiver_id INT NOT NULL,
    text TEXT NOT NULL,
    status ENUM('PENDING', 'ACCEPTED', 'REJECTED') DEFAULT 'PENDING',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (sender_id) REFERENCES Users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (receiver_id) REFERENCES Users(user_id) ON DELETE CASCADE
);

-- 8. Create ProfileViews Table
CREATE TABLE IF NOT EXISTS ProfileViews (
    id INT AUTO_INCREMENT PRIMARY KEY,
    viewer_id INT NOT NULL,
    profile_id INT NOT NULL,
    view_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (viewer_id) REFERENCES Users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (profile_id) REFERENCES Users(user_id) ON DELETE CASCADE
);

-- 9. Seed some basic skills
INSERT INTO Skills (name, category) VALUES 
('Java', 'Technical'),
('Python', 'Technical'),
('JavaScript', 'Technical'),
('SQL', 'Technical'),
('Project Management', 'Business'),
('Leadership', 'Soft Skills'),
('Public Speaking', 'Soft Skills')
ON DUPLICATE KEY UPDATE name=name;
