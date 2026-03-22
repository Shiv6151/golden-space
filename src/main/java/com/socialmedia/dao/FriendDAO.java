package com.socialmedia.dao;

import com.socialmedia.model.Friend;
import com.socialmedia.util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class FriendDAO {

    public boolean sendFriendRequest(int userId, int friendId, String message) {
        String query = "INSERT INTO friend_requests (sender_id, receiver_id, status, message) VALUES (?, ?, 'PENDING', ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(query)) {
             
            stmt.setInt(1, userId);
            stmt.setInt(2, friendId);
            stmt.setString(3, message);
            
            if (stmt.executeUpdate() > 0) {
                new NotificationDAO().addNotification(friendId, userId, "FRIEND_REQUEST", null);
                return true;
            }
            
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean updateFriendRequestStatus(int friendId, int userId, String status) {
        // friendId is the original sender, userId is the receiver who is accepting/rejecting
        String query = "UPDATE friend_requests SET status = ? WHERE sender_id = ? AND receiver_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(query)) {
             
            stmt.setString(1, status);
            stmt.setInt(2, friendId);
            stmt.setInt(3, userId);
            
            if (stmt.executeUpdate() > 0) {
                if ("ACCEPTED".equals(status)) {
                    // Automatically add to followers table
                    String followQuery = "INSERT IGNORE INTO followers (follower_id, following_id) VALUES (?, ?)";
                    try (PreparedStatement followStmt = conn.prepareStatement(followQuery)) {
                        followStmt.setInt(1, friendId); // The one who sent the request is the follower
                        followStmt.setInt(2, userId);   // The one who accepted is being followed
                        followStmt.executeUpdate();
                    }
                } else if ("REJECTED".equals(status)) {
                    deleteFriendRequest(userId, friendId);
                }
                return true;
            }
            
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
    
    public boolean deleteFriendRequest(int userId, int friendId) {
        String query = "DELETE FROM friend_requests WHERE (sender_id = ? AND receiver_id = ?) OR (sender_id = ? AND receiver_id = ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(query)) {
             
            stmt.setInt(1, userId);
            stmt.setInt(2, friendId);
            stmt.setInt(3, friendId);
            stmt.setInt(4, userId);
            
            return stmt.executeUpdate() > 0;
            
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public List<Friend> getPendingRequests(int userId) {
        List<Friend> requests = new ArrayList<>();
        // Get requests where user_id is the receiver and status is PENDING
        String query = 
            "SELECT f.*, u.name, u.profile_photo " +
            "FROM friend_requests f " +
            "JOIN Users u ON f.sender_id = u.user_id " +
            "WHERE f.receiver_id = ? AND f.status = 'PENDING'";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(query)) {
             
            stmt.setInt(1, userId);
            
            ResultSet rs = stmt.executeQuery();
            while (rs.next()) {
                Friend f = new Friend();
                f.setUserId(rs.getInt("receiver_id"));
                f.setFriendId(rs.getInt("sender_id"));
                f.setStatus(rs.getString("status"));
                f.setCreatedAt(rs.getTimestamp("created_at"));
                f.setFriendName(rs.getString("name"));
                f.setFriendPhoto(rs.getString("profile_photo"));
                f.setMessage(rs.getString("message"));
                requests.add(f);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return requests;
    }

    public int getPendingRequestsCount(int userId) {
        String query = "SELECT COUNT(*) FROM friend_requests WHERE receiver_id = ? AND status = 'PENDING'";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(query)) {
            stmt.setInt(1, userId);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }

    public List<Friend> getAcceptedFriends(int userId) {
        List<Friend> friends = new ArrayList<>();
        // Mutual: if status is ACCEPTED, either user initiated it or received it
        String query = 
            "SELECT u.user_id, u.name, u.profile_photo " +
            "FROM Users u " +
            "JOIN friend_requests f ON (u.user_id = f.receiver_id OR u.user_id = f.sender_id) " +
            "WHERE (f.sender_id = ? OR f.receiver_id = ?) AND f.status = 'ACCEPTED' AND u.user_id != ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(query)) {
             
            stmt.setInt(1, userId);
            stmt.setInt(2, userId);
            
            ResultSet rs = stmt.executeQuery();
            while (rs.next()) {
                Friend f = new Friend();
                f.setFriendId(rs.getInt("user_id"));
                f.setFriendName(rs.getString("name"));
                f.setFriendPhoto(rs.getString("profile_photo"));
                f.setStatus("ACCEPTED");
                friends.add(f);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return friends;
    }
    
    public String getFriendshipStatus(int userId, int targetUserId) {
        String query = "SELECT status, sender_id FROM friend_requests WHERE (sender_id = ? AND receiver_id = ?) OR (sender_id = ? AND receiver_id = ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(query)) {
             
            stmt.setInt(1, userId);
            stmt.setInt(2, targetUserId);
            stmt.setInt(3, targetUserId);
            stmt.setInt(4, userId);
            
            ResultSet rs = stmt.executeQuery();
            if (rs.next()) {
                String status = rs.getString("status");
                int senderId = rs.getInt("sender_id");
                if ("PENDING".equals(status)) {
                    if (senderId == userId) {
                        return "REQUEST_SENT";
                    } else {
                        return "REQUEST_RECEIVED";
                    }
                }
                return status;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return "NONE";
    }

    public boolean blockUser(int blockerId, int blockedId) {
        // First delete any existing friend request or follow connection
        deleteFriendRequest(blockerId, blockedId);
        String sql = "INSERT IGNORE INTO blocked_users (blocker_id, blocked_id) VALUES (?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, blockerId);
            stmt.setInt(2, blockedId);
            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean unblockUser(int blockerId, int blockedId) {
        String sql = "DELETE FROM blocked_users WHERE blocker_id = ? AND blocked_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, blockerId);
            stmt.setInt(2, blockedId);
            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
}
