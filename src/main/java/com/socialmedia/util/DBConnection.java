package com.socialmedia.util;

import com.zaxxer.hikari.HikariConfig;
import com.zaxxer.hikari.HikariDataSource;

import java.sql.Connection;
import java.sql.SQLException;

public class DBConnection {
    private static final String URL = System.getenv("DB_URL") != null ? 
            System.getenv("DB_URL") : "jdbc:mysql://gateway01.ap-southeast-1.prod.aws.tidbcloud.com:4000/social_media_db?sslMode=VERIFY_IDENTITY&enabledTLSProtocols=TLSv1.2,TLSv1.3&connectTimeout=10000&socketTimeout=10000";
    private static final String USERNAME = System.getenv("DB_USER") != null ? 
            System.getenv("DB_USER") : "2XbkqGwZ1Mgg4dJ.root";
    private static final String PASSWORD = System.getenv("DB_PASSWORD") != null ? 
            System.getenv("DB_PASSWORD") : "JMzneMBgllqC0VOW";

    private static HikariDataSource dataSource;

    static {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            HikariConfig config = new HikariConfig();
            config.setJdbcUrl(URL);
            config.setUsername(USERNAME);
            config.setPassword(PASSWORD);
            
            // Pool configuration for high performance
            config.setMaximumPoolSize(10);
            config.setMinimumIdle(2);
            config.setIdleTimeout(30000); // 30 seconds
            config.setMaxLifetime(1800000); // 30 minutes
            config.setConnectionTimeout(10000); // 10 seconds timeout
            
            dataSource = new HikariDataSource(config);
            System.out.println("HikariCP Database Connection Pool initialized.");
            
            // Auto-migrate tables
            try (Connection conn = dataSource.getConnection();
                 java.sql.Statement stmt = conn.createStatement()) {
                stmt.executeUpdate("CREATE TABLE IF NOT EXISTS blocked_users (" +
                         "    id INT AUTO_INCREMENT PRIMARY KEY," +
                         "    blocker_id INT NOT NULL," +
                         "    blocked_id INT NOT NULL," +
                         "    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP," +
                         "    FOREIGN KEY (blocker_id) REFERENCES Users(user_id) ON DELETE CASCADE," +
                         "    FOREIGN KEY (blocked_id) REFERENCES Users(user_id) ON DELETE CASCADE," +
                         "    UNIQUE KEY unique_block (blocker_id, blocked_id)" +
                         ")");
                
                 stmt.executeUpdate("CREATE TABLE IF NOT EXISTS Recommendations (" +
                          "    id INT AUTO_INCREMENT PRIMARY KEY," +
                          "    sender_id INT NOT NULL," +
                          "    receiver_id INT NOT NULL," +
                          "    text TEXT NOT NULL," +
                          "    status ENUM('PENDING', 'ACCEPTED', 'REJECTED') DEFAULT 'PENDING'," +
                          "    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP," +
                          "    FOREIGN KEY (sender_id) REFERENCES Users(user_id) ON DELETE CASCADE," +
                          "    FOREIGN KEY (receiver_id) REFERENCES Users(user_id) ON DELETE CASCADE" +
                          ")");
                 
                 stmt.executeUpdate("CREATE TABLE IF NOT EXISTS user_activity (" +
                          "    user_id INT PRIMARY KEY," +
                          "    total_seconds INT DEFAULT 0," +
                          "    last_active TIMESTAMP DEFAULT CURRENT_TIMESTAMP," +
                          "    FOREIGN KEY (user_id) REFERENCES Users(user_id) ON DELETE CASCADE" +
                          ")");
            } catch (Exception ex) {
                System.err.println("Failed to auto-migrate schema: " + ex.getMessage());
            }
        } catch (Exception e) {
            System.err.println("Fatal Error: Could not initialize database connection pool.");
            e.printStackTrace();
        }
    }

    public static Connection getConnection() throws SQLException {
        return dataSource.getConnection();
    }
}
