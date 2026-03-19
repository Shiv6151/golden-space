package com.socialmedia.dao;

import com.socialmedia.util.DBConnection;

import java.sql.*;

public class EndorsementDAO {

    public boolean toggleEndorsement(int userSkillId, int endorserId) {
        if (isEndorsed(userSkillId, endorserId)) {
            // Remove endorsement
            String sql = "DELETE FROM Endorsements WHERE user_skill_id = ? AND endorser_id = ?";
            try (Connection conn = DBConnection.getConnection();
                 PreparedStatement stmt = conn.prepareStatement(sql)) {
                stmt.setInt(1, userSkillId);
                stmt.setInt(2, endorserId);
                return stmt.executeUpdate() > 0;
            } catch (SQLException e) {
                e.printStackTrace();
            }
        } else {
            // Add endorsement
            String sql = "INSERT INTO Endorsements (user_skill_id, endorser_id) VALUES (?, ?)";
            try (Connection conn = DBConnection.getConnection();
                 PreparedStatement stmt = conn.prepareStatement(sql)) {
                stmt.setInt(1, userSkillId);
                stmt.setInt(2, endorserId);
                return stmt.executeUpdate() > 0;
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
        return false;
    }

    public boolean isEndorsed(int userSkillId, int endorserId) {
        String sql = "SELECT 1 FROM Endorsements WHERE user_skill_id = ? AND endorser_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, userSkillId);
            stmt.setInt(2, endorserId);
            try (ResultSet rs = stmt.executeQuery()) {
                return rs.next();
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
}
