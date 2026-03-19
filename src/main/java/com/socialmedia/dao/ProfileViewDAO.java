package com.socialmedia.dao;

import com.socialmedia.model.ProfileView;
import com.socialmedia.util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class ProfileViewDAO {

    public void recordView(int viewerId, int profileId) {
        if (viewerId == profileId) return; // Don't record self-views

        // Check if viewed in the last 24 hours to avoid spamming
        String checkSql = "SELECT id FROM ProfileViews WHERE viewer_id = ? AND profile_id = ? AND view_time > NOW() - INTERVAL 1 DAY";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement checkStmt = conn.prepareStatement(checkSql)) {
            checkStmt.setInt(1, viewerId);
            checkStmt.setInt(2, profileId);
            try (ResultSet rs = checkStmt.executeQuery()) {
                if (rs.next()) return; // Already viewed recently
            }

            String insertSql = "INSERT INTO ProfileViews (viewer_id, profile_id) VALUES (?, ?)";
            try (PreparedStatement insertStmt = conn.prepareStatement(insertSql)) {
                insertStmt.setInt(1, viewerId);
                insertStmt.setInt(2, profileId);
                insertStmt.executeUpdate();
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    public List<ProfileView> getRecentViews(int userId) {
        List<ProfileView> views = new ArrayList<>();
        String sql = "SELECT pv.*, u.name as viewer_name, u.headline as viewer_headline, u.profile_photo as viewer_photo " +
                     "FROM ProfileViews pv " +
                     "JOIN Users u ON pv.viewer_id = u.user_id " +
                     "WHERE pv.profile_id = ? " +
                     "ORDER BY pv.view_time DESC LIMIT 10";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, userId);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    ProfileView pv = new ProfileView();
                    pv.setId(rs.getInt("id"));
                    pv.setViewerId(rs.getInt("viewer_id"));
                    pv.setProfileId(rs.getInt("profile_id"));
                    pv.setViewTime(rs.getTimestamp("view_time"));
                    pv.setViewerName(rs.getString("viewer_name"));
                    pv.setViewerHeadline(rs.getString("viewer_headline"));
                    pv.setViewerPhoto(rs.getString("viewer_photo"));
                    views.add(pv);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return views;
    }

    public int getViewCount(int userId) {
        String sql = "SELECT COUNT(*) FROM ProfileViews WHERE profile_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, userId);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }
}
