import com.socialmedia.util.DBConnection;
import java.sql.Connection;
import java.sql.Statement;

public class UpdateSchema {
    public static void main(String[] args) {
        System.out.println("Starting Database Schema Update...");
        try (Connection conn = DBConnection.getConnection();
             Statement stmt = conn.createStatement()) {

            // 1. Create Notifications Table
            System.out.println("Creating Notifications table...");
            String createNotifications = "CREATE TABLE IF NOT EXISTS Notifications (" +
                    "id INT AUTO_INCREMENT PRIMARY KEY, " +
                    "user_id INT NOT NULL, " +
                    "actor_id INT NOT NULL, " +
                    "type ENUM('FRIEND_REQUEST', 'FOLLOW', 'LIKE', 'COMMENT', 'SHARE') NOT NULL, " +
                    "target_id INT DEFAULT NULL, " +
                    "created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, " +
                    "is_read BOOLEAN DEFAULT FALSE, " +
                    "FOREIGN KEY (user_id) REFERENCES Users(user_id) ON DELETE CASCADE, " +
                    "FOREIGN KEY (actor_id) REFERENCES Users(user_id) ON DELETE CASCADE" +
                    ")";
            stmt.executeUpdate(createNotifications);
            System.out.println("Notifications table created.");

            // 2. Alter Messages Table
            System.out.println("Altering Messages table...");
            try {
                String alterMessagesUrl = "ALTER TABLE Messages ADD COLUMN attachment_url VARCHAR(512) DEFAULT NULL";
                stmt.executeUpdate(alterMessagesUrl);
                System.out.println("Added attachment_url to Messages.");
            } catch (Exception e) {
                System.out.println("attachment_url might already exist: " + e.getMessage());
            }

            try {
                String alterMessagesType = "ALTER TABLE Messages ADD COLUMN attachment_type VARCHAR(50) DEFAULT NULL";
                stmt.executeUpdate(alterMessagesType);
                System.out.println("Added attachment_type to Messages.");
            } catch (Exception e) {
                System.out.println("attachment_type might already exist: " + e.getMessage());
            }

            System.out.println("Database Schema Update Complete!");

        } catch (Exception e) {
            System.err.println("Error updating schema: " + e.getMessage());
            e.printStackTrace();
        }
    }
}
