package com.socialmedia.dao;

import com.socialmedia.model.User;
import com.socialmedia.util.DBConnection;

import java.sql.*;

public class UserDAO {

    public boolean registerUser(User user) {
        return false;
    }

    public boolean isUsernameTaken(String username) {
        String query = "SELECT 1 FROM Users WHERE username = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(query)) {
            stmt.setString(1, username);
            try (ResultSet rs = stmt.executeQuery()) {
                return rs.next();
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return true; // Default to true on error to prevent duplicates
    }

    public boolean isEmailTaken(String email) {
        String query = "SELECT 1 FROM Users WHERE email = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(query)) {
            stmt.setString(1, email);
            try (ResultSet rs = stmt.executeQuery()) {
                return rs.next();
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return true;
    }

    public boolean saveOtpRequest(String name, String username, String email, String password, String otp) {
        String query = "INSERT INTO otp_verification (name, username, email, password, otp, expires_at) " +
                       "VALUES (?, ?, ?, ?, ?, DATE_ADD(NOW(), INTERVAL 5 MINUTE))";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(query)) {
             
            stmt.setString(1, name);
            stmt.setString(2, username);
            stmt.setString(3, email);
            stmt.setString(4, password);
            stmt.setString(5, otp);
            
            return stmt.executeUpdate() > 0;
            
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean verifyAndCreateUser(String email, String otpSubmitted) {
        String verifyQuery = "SELECT * FROM otp_verification WHERE email = ? AND otp = ? AND expires_at > NOW() ORDER BY created_at DESC LIMIT 1";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement verifyStmt = conn.prepareStatement(verifyQuery)) {
            
            verifyStmt.setString(1, email);
            verifyStmt.setString(2, otpSubmitted);
            
            try (ResultSet rs = verifyStmt.executeQuery()) {
                if (rs.next()) {
                    // Valid OTP, extract data
                    String name = rs.getString("name");
                    String username = rs.getString("username");
                    String pass = rs.getString("password");
                    
                    // Proceed to create the real user immediately
                    String insertUser = "INSERT INTO Users (name, username, email, password) VALUES (?, ?, ?, ?)";
                    try (PreparedStatement insertStmt = conn.prepareStatement(insertUser)) {
                        insertStmt.setString(1, name);
                        insertStmt.setString(2, username);
                        insertStmt.setString(3, email);
                        insertStmt.setString(4, pass);
                        return insertStmt.executeUpdate() > 0;
                    }
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public User authenticateUser(String email, String password) {
        String query = "SELECT * FROM Users WHERE email = ? AND password = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(query)) {
             
            stmt.setString(1, email);
            stmt.setString(2, password);
            
            ResultSet rs = stmt.executeQuery();
            if (rs.next()) {
                return extractUserFromResultSet(rs);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    public User getUserById(int userId) {
        String query = "SELECT * FROM Users WHERE user_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(query)) {
             
            stmt.setInt(1, userId);
            ResultSet rs = stmt.executeQuery();
            if (rs.next()) {
                return extractUserFromResultSet(rs);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    public User getUserByEmail(String email) {
        String query = "SELECT * FROM Users WHERE email = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(query)) {
             
            stmt.setString(1, email);
            ResultSet rs = stmt.executeQuery();
            if (rs.next()) {
                return extractUserFromResultSet(rs);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    public boolean updatePassword(int userId, String password) {
        String query = "UPDATE Users SET password = ? WHERE user_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(query)) {
            stmt.setString(1, password);
            stmt.setInt(2, userId);
            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean updatePrivacy(int userId, boolean isPrivate) {
        String query = "UPDATE Users SET is_private = ? WHERE user_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(query)) {
            stmt.setInt(1, isPrivate ? 1 : 0);
            stmt.setInt(2, userId);
            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
    public boolean updateUserProfile(User user) {
        String query = "UPDATE Users SET name = ?, bio = ?, profile_photo = ?, is_private = ?, headline = ?, professional_summary = ? WHERE user_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(query)) {
             
            stmt.setString(1, user.getName());
            stmt.setString(2, user.getBio());
            stmt.setString(3, user.getProfilePhoto());
            stmt.setInt(4, user.isPrivateAccount() ? 1 : 0);
            stmt.setString(5, user.getHeadline());
            stmt.setString(6, user.getProfessionalSummary());
            stmt.setInt(7, user.getUserId());
            
            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public java.util.List<User> searchUsersByName(String nameQuery, int currentUserId) {
        java.util.List<User> users = new java.util.ArrayList<>();
        String query = "SELECT u.*, " +
                       "(SELECT 1 FROM followers WHERE follower_id = ? AND following_id = u.user_id) AS is_followed " +
                       "FROM Users u " +
                       "WHERE LOWER(u.name) LIKE LOWER(?) OR LOWER(u.username) LIKE LOWER(?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(query)) {
             
            stmt.setInt(1, currentUserId);
            stmt.setString(2, "%" + nameQuery + "%");
            stmt.setString(3, "%" + nameQuery + "%");
            ResultSet rs = stmt.executeQuery();
            while (rs.next()) {
                User u = extractUserFromResultSet(rs);
                u.setFollowedByMe(rs.getInt("is_followed") == 1);
                users.add(u);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return users;
    }

    public boolean deleteUserAccount(int userId) {
        String query = "DELETE FROM Users WHERE user_id = ?";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(query)) {
            stmt.setInt(1, userId);
            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public java.util.List<User> getBlockedUsers(int blockerId) {
        java.util.List<User> blockedUsers = new java.util.ArrayList<>();
        String query = "SELECT u.* FROM Users u JOIN blocked_users b ON u.user_id = b.blocked_id WHERE b.blocker_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(query)) {
            stmt.setInt(1, blockerId);
            ResultSet rs = stmt.executeQuery();
            while (rs.next()) {
                blockedUsers.add(extractUserFromResultSet(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return blockedUsers;
    }

    public boolean unblockUser(int blockerId, int blockedId) {
        String query = "DELETE FROM blocked_users WHERE blocker_id = ? AND blocked_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(query)) {
            stmt.setInt(1, blockerId);
            stmt.setInt(2, blockedId);
            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean updateActivityTime(int userId, int seconds) {
        String query = "INSERT INTO user_activity (user_id, total_seconds, last_active) VALUES (?, ?, NOW()) " +
                       "ON DUPLICATE KEY UPDATE total_seconds = total_seconds + ?, last_active = NOW()";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(query)) {
            stmt.setInt(1, userId);
            stmt.setInt(2, seconds);
            stmt.setInt(3, seconds);
            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public int getTimeSpent(int userId) {
        String query = "SELECT total_seconds FROM user_activity WHERE user_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(query)) {
            stmt.setInt(1, userId);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("total_seconds");
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }

    public boolean isBlocked(int blockerId, int blockedId) {
        String query = "SELECT 1 FROM blocked_users WHERE (blocker_id = ? AND blocked_id = ?) OR (blocker_id = ? AND blocked_id = ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(query)) {
            stmt.setInt(1, blockerId);
            stmt.setInt(2, blockedId);
            stmt.setInt(3, blockedId);
            stmt.setInt(4, blockerId);
            try (ResultSet rs = stmt.executeQuery()) {
                return rs.next();
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public java.util.List<User> getSuggestedUsers(int currentUserId, int limit) {
        java.util.List<User> users = new java.util.ArrayList<>();
        // Suggest users the current user is NOT following, is NOT blocked by/blocking, and is NOT themselves
        String query =
            "SELECT u.*, " +
            "    (SELECT COUNT(*) FROM followers f2 WHERE f2.following_id = u.user_id) AS follower_count " +
            "FROM Users u " +
            "WHERE u.user_id != ? " +
            "  AND u.user_id NOT IN (SELECT following_id FROM followers WHERE follower_id = ?) " +
            "  AND u.user_id NOT IN (SELECT blocked_id FROM blocked_users WHERE blocker_id = ?) " +
            "  AND u.user_id NOT IN (SELECT blocker_id FROM blocked_users WHERE blocked_id = ?) " +
            "ORDER BY follower_count DESC " +
            "LIMIT ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(query)) {
            stmt.setInt(1, currentUserId);
            stmt.setInt(2, currentUserId);
            stmt.setInt(3, currentUserId);
            stmt.setInt(4, currentUserId);
            stmt.setInt(5, limit);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    users.add(extractUserFromResultSet(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return users;
    }

    private User extractUserFromResultSet(ResultSet rs) throws SQLException {
        return new User(
            rs.getInt("user_id"),
            rs.getString("username"),
            rs.getString("name"),
            rs.getString("email"),
            rs.getString("password"),
            rs.getString("profile_photo"),
            rs.getString("bio"),
            rs.getString("headline"),
            rs.getString("professional_summary"),
            rs.getTimestamp("created_at"),
            rs.getInt("is_private") == 1
        );
    }
}
