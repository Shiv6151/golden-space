package com.socialmedia.dao;

import com.socialmedia.model.Notification;
import com.socialmedia.util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class NotificationDAO {

    public boolean addNotification(int userId, int actorId, String type, Integer targetId) {
        // Prevent notifying yourself (e.g. liking your own post shouldn't spam you)
        if (userId == actorId) return false;

        String query = "INSERT INTO Notifications (user_id, actor_id, type, target_id) VALUES (?, ?, ?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(query)) {
            
            stmt.setInt(1, userId);
            stmt.setInt(2, actorId);
            stmt.setString(3, type);
            if (targetId != null) {
                stmt.setInt(4, targetId);
            } else {
                stmt.setNull(4, Types.INTEGER);
            }
            return stmt.executeUpdate() > 0;
            
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public List<Notification> getRecentNotifications(int userId) {
        List<Notification> notifications = new ArrayList<>();
        // Fetch notifications from the last 24 hours, including actor details
        String query = "SELECT n.*, u.username as actor_name, u.profile_photo as actor_photo " +
                       "FROM Notifications n " +
                       "JOIN Users u ON n.actor_id = u.user_id " +
                       "WHERE n.user_id = ? AND n.created_at >= NOW() - INTERVAL 7 DAY " +
                       "ORDER BY n.created_at DESC";
                       
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(query)) {
            
            stmt.setInt(1, userId);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    Notification n = new Notification();
                    n.setId(rs.getInt("id"));
                    n.setUserId(rs.getInt("user_id"));
                    n.setActorId(rs.getInt("actor_id"));
                    n.setActorName(rs.getString("actor_name"));
                    n.setActorPhoto(rs.getString("actor_photo"));
                    n.setType(rs.getString("type"));
                    
                    int targetId = rs.getInt("target_id");
                    if (!rs.wasNull()) {
                        n.setTargetId(targetId);
                    }
                    
                    n.setCreatedAt(rs.getTimestamp("created_at"));
                    n.setRead(rs.getBoolean("is_read"));
                    
                    notifications.add(n);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return notifications;
    }

    public int getUnreadCount(int userId) {
        String query = "SELECT count(*) FROM Notifications WHERE user_id = ? AND is_read = FALSE AND created_at >= NOW() - INTERVAL 7 DAY";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(query)) {
            stmt.setInt(1, userId);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }

    public boolean markAllAsRead(int userId) {
        String query = "UPDATE Notifications SET is_read = TRUE WHERE user_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(query)) {
            stmt.setInt(1, userId);
            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }
}
