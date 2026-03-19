package com.socialmedia.dao;

import com.socialmedia.util.DBConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

public class FollowDAO {

    public int getFollowersCount(int userId) {
        String query = "SELECT COUNT(*) FROM followers WHERE following_id = ?";
        return getCount(query, userId);
    }

    public int getFollowingCount(int userId) {
        String query = "SELECT COUNT(*) FROM followers WHERE follower_id = ?";
        return getCount(query, userId);
    }

    public boolean isFollowing(int followerId, int followingId) {
        String query = "SELECT 1 FROM followers WHERE follower_id = ? AND following_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(query)) {
            stmt.setInt(1, followerId);
            stmt.setInt(2, followingId);
            try (ResultSet rs = stmt.executeQuery()) {
                return rs.next();
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean isMutualFollowing(int userA, int userB) {
        return isFollowing(userA, userB) && isFollowing(userB, userA);
    }

    public boolean toggleFollow(int followerId, int followingId) {
        if (followerId == followingId) {
            return false; // Users cannot follow themselves
        }
        
        if (isFollowing(followerId, followingId)) {
            // Unfollow
            String query = "DELETE FROM followers WHERE follower_id = ? AND following_id = ?";
            executeUpdate(query, followerId, followingId);
            return false;
        } else {
            // Follow
            String query = "INSERT INTO followers (follower_id, following_id) VALUES (?, ?)";
            executeUpdate(query, followerId, followingId);
            new NotificationDAO().addNotification(followingId, followerId, "FOLLOW", null);
            return true;
        }
    }

    private int getCount(String query, int userId) {
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

    private void executeUpdate(String query, int id1, int id2) {
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(query)) {
            stmt.setInt(1, id1);
            stmt.setInt(2, id2);
            stmt.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    public java.util.List<com.socialmedia.model.User> getFollowers(int userId) {
        java.util.List<com.socialmedia.model.User> followers = new java.util.ArrayList<>();
        String query = "SELECT u.user_id, u.name, u.username, u.profile_photo FROM followers f JOIN Users u ON f.follower_id = u.user_id WHERE f.following_id = ?";
        return getUsers(query, userId, followers);
    }

    public java.util.List<com.socialmedia.model.User> getFollowing(int userId) {
        java.util.List<com.socialmedia.model.User> following = new java.util.ArrayList<>();
        String query = "SELECT u.user_id, u.name, u.username, u.profile_photo FROM followers f JOIN Users u ON f.following_id = u.user_id WHERE f.follower_id = ?";
        return getUsers(query, userId, following);
    }
    
    public java.util.List<com.socialmedia.model.User> getMutualFollowers(int userId) {
        java.util.List<com.socialmedia.model.User> mutuals = new java.util.ArrayList<>();
        String query = "SELECT u.user_id, u.name, u.username, u.profile_photo " +
                       "FROM followers f1 " +
                       "JOIN Users u ON f1.following_id = u.user_id " +
                       "WHERE f1.follower_id = ? " +
                       "AND f1.following_id IN (SELECT follower_id FROM followers WHERE following_id = ?)";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(query)) {
            stmt.setInt(1, userId);
            stmt.setInt(2, userId);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    com.socialmedia.model.User u = new com.socialmedia.model.User();
                    u.setUserId(rs.getInt("user_id"));
                    u.setName(rs.getString("name"));
                    u.setUsername(rs.getString("username"));
                    u.setProfilePhoto(rs.getString("profile_photo"));
                    mutuals.add(u);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return mutuals;
    }

    public int getConnectionDegree(int userA, int userB) {
        if (userA == userB) return 0;
        
        // 1st Degree: Mutual Following
        if (isMutualFollowing(userA, userB)) return 1;
        
        // 2nd Degree: Have at least one mutual friend (where friend = mutual follower)
        String query = 
            "SELECT 1 FROM followers f1 " +
            "JOIN followers f2 ON f1.following_id = f2.following_id " +
            "WHERE f1.follower_id = ? AND f2.follower_id = ? " +
            "AND f1.following_id IN (SELECT follower_id FROM followers WHERE following_id = f1.following_id) " +
            "AND f2.following_id IN (SELECT follower_id FROM followers WHERE following_id = f2.following_id) LIMIT 1";
            
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(query)) {
            stmt.setInt(1, userA);
            stmt.setInt(2, userB);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) return 2;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return 3;
    }

    private java.util.List<com.socialmedia.model.User> getUsers(String query, int userId, java.util.List<com.socialmedia.model.User> list) {
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(query)) {
            stmt.setInt(1, userId);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    com.socialmedia.model.User u = new com.socialmedia.model.User();
                    u.setUserId(rs.getInt("user_id"));
                    u.setName(rs.getString("name"));
                    u.setUsername(rs.getString("username"));
                    u.setProfilePhoto(rs.getString("profile_photo"));
                    list.add(u);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }
}
