package com.socialmedia.dao;

import com.socialmedia.model.Recommendation;
import com.socialmedia.util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class RecommendationDAO {

    public boolean submitRecommendation(Recommendation rec) {
        String sql = "INSERT INTO Recommendations (sender_id, receiver_id, text, status) VALUES (?, ?, ?, 'PENDING')";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, rec.getSenderId());
            stmt.setInt(2, rec.getReceiverId());
            stmt.setString(3, rec.getText());
            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public List<Recommendation> getAcceptedRecommendations(int userId) {
        List<Recommendation> recs = new ArrayList<>();
        String sql = "SELECT r.*, u.name as sender_name, u.headline as sender_headline, u.profile_photo as sender_photo " +
                     "FROM Recommendations r " +
                     "JOIN Users u ON r.sender_id = u.user_id " +
                     "WHERE r.receiver_id = ? AND r.status = 'ACCEPTED' " +
                     "ORDER BY r.created_at DESC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, userId);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    Recommendation r = extractRecommendation(rs);
                    recs.add(r);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return recs;
    }

    public List<Recommendation> getPendingRecommendations(int userId) {
        List<Recommendation> recs = new ArrayList<>();
        String sql = "SELECT r.*, u.name as sender_name, u.headline as sender_headline, u.profile_photo as sender_photo " +
                     "FROM Recommendations r " +
                     "JOIN Users u ON r.sender_id = u.user_id " +
                     "WHERE r.receiver_id = ? AND r.status = 'PENDING' " +
                     "ORDER BY r.created_at DESC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, userId);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    recs.add(extractRecommendation(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return recs;
    }

    public boolean updateStatus(int id, int receiverId, String status) {
        String sql = "UPDATE Recommendations SET status = ? WHERE id = ? AND receiver_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, status);
            stmt.setInt(2, id);
            stmt.setInt(3, receiverId);
            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    private Recommendation extractRecommendation(ResultSet rs) throws SQLException {
        Recommendation r = new Recommendation();
        r.setId(rs.getInt("id"));
        r.setSenderId(rs.getInt("sender_id"));
        r.setReceiverId(rs.getInt("receiver_id"));
        r.setText(rs.getString("text"));
        r.setStatus(rs.getString("status"));
        r.setCreatedAt(rs.getTimestamp("created_at"));
        r.setSenderName(rs.getString("sender_name"));
        r.setSenderHeadline(rs.getString("sender_headline"));
        r.setSenderPhoto(rs.getString("sender_photo"));
        return r;
    }
}
