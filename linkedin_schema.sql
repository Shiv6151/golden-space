-- LinkedIn Features Migration Script

-- 1. Update Users Table
ALTER TABLE Users ADD COLUMN headline VARCHAR(255) DEFAULT NULL;
ALTER TABLE Users ADD COLUMN professional_summary TEXT DEFAULT NULL;

-- 2. Professional Experience Table
CREATE TABLE IF NOT EXISTS Experience (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    company VARCHAR(255) NOT NULL,
    title VARCHAR(255) NOT NULL,
    location VARCHAR(255),
    start_date DATE NOT NULL,
    end_date DATE DEFAULT NULL,
    description TEXT,
    is_current BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES Users(user_id) ON DELETE CASCADE
);

-- 3. Professional Education Table
CREATE TABLE IF NOT EXISTS Education (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    school VARCHAR(255) NOT NULL,
    degree VARCHAR(255),
    field_of_study VARCHAR(255),
    start_date DATE NOT NULL,
    end_date DATE DEFAULT NULL,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES Users(user_id) ON DELETE CASCADE
);

-- 4. Skills Table (Canonical list of skills)
CREATE TABLE IF NOT EXISTS Skills (
    id INT AUTO_INCREMENT PRIMARY KEY,
    skill_name VARCHAR(100) UNIQUE NOT NULL
);

-- 5. User Skills (Many-to-Many mapping)
CREATE TABLE IF NOT EXISTS UserSkills (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    skill_id INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES Users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (skill_id) REFERENCES Skills(id) ON DELETE CASCADE,
    UNIQUE KEY (user_id, skill_id)
);

-- 6. Endorsements Table
CREATE TABLE IF NOT EXISTS Endorsements (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_skill_id INT NOT NULL,
    endorser_id INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_skill_id) REFERENCES UserSkills(id) ON DELETE CASCADE,
    FOREIGN KEY (endorser_id) REFERENCES Users(user_id) ON DELETE CASCADE,
    UNIQUE KEY (user_skill_id, endorser_id)
);

-- 7. Recommendations Table
CREATE TABLE IF NOT EXISTS Recommendations (
    id INT AUTO_INCREMENT PRIMARY KEY,
    giver_id INT NOT NULL,
    receiver_id INT NOT NULL,
    recommendation_text TEXT NOT NULL,
    status ENUM('PENDING', 'APPROVED') DEFAULT 'PENDING',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (giver_id) REFERENCES Users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (receiver_id) REFERENCES Users(user_id) ON DELETE CASCADE
);

-- 8. Profile Views Table
CREATE TABLE IF NOT EXISTS ProfileViews (
    id INT AUTO_INCREMENT PRIMARY KEY,
    viewer_id INT NOT NULL,
    profile_id INT NOT NULL,
    view_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (viewer_id) REFERENCES Users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (profile_id) REFERENCES Users(user_id) ON DELETE CASCADE
);

-- 9. Update FriendRequests for Personalized Notes
ALTER TABLE friend_requests ADD COLUMN message TEXT DEFAULT NULL;
