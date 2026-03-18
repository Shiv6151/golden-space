package com.socialmedia.util;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class DBConnection {
    private static final String URL = System.getenv("DB_URL") != null ? 
            System.getenv("DB_URL") : "jdbc:mysql://gateway01.ap-southeast-1.prod.aws.tidbcloud.com:4000/social_media_db?sslMode=VERIFY_IDENTITY&enabledTLSProtocols=TLSv1.2,TLSv1.3";
    private static final String USERNAME = System.getenv("DB_USER") != null ? 
            System.getenv("DB_USER") : "2XbkqGwZ1Mgg4dJ.root";
    private static final String PASSWORD = System.getenv("DB_PASSWORD") != null ? 
            System.getenv("DB_PASSWORD") : "JMzneMBgllqC0VOW";

    static {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
        } catch (ClassNotFoundException e) {
            e.printStackTrace();
        }
    }

    public static Connection getConnection() throws SQLException {
        return DriverManager.getConnection(URL, USERNAME, PASSWORD);
    }
}
