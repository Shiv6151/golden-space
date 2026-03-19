package com.socialmedia.dao;

import com.socialmedia.model.Experience;
import com.socialmedia.util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class ExperienceDAO {

    public boolean addExperience(Experience exp) {
        String query = "INSERT INTO Experience (user_id, company, title, location, start_date, end_date, description, is_current) VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(query)) {
            stmt.setInt(1, exp.getUserId());
            stmt.setString(2, exp.getCompany());
            stmt.setString(3, exp.getTitle());
            stmt.setString(4, exp.getLocation());
            stmt.setDate(5, new java.sql.Date(exp.getStartDate().getTime()));
            if (exp.getEndDate() != null) {
                stmt.setDate(6, new java.sql.Date(exp.getEndDate().getTime()));
            } else {
                stmt.setNull(6, Types.DATE);
            }
            stmt.setString(7, exp.getDescription());
            stmt.setBoolean(8, exp.isCurrent());
            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public List<Experience> getExperienceByUserId(int userId) {
        List<Experience> experiences = new ArrayList<>();
        String query = "SELECT * FROM Experience WHERE user_id = ? ORDER BY start_date DESC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(query)) {
            stmt.setInt(1, userId);
            ResultSet rs = stmt.executeQuery();
            while (rs.next()) {
                Experience exp = new Experience();
                exp.setId(rs.getInt("id"));
                exp.setUserId(rs.getInt("user_id"));
                exp.setCompany(rs.getString("company"));
                exp.setTitle(rs.getString("title"));
                exp.setLocation(rs.getString("location"));
                exp.setStartDate(rs.getDate("start_date"));
                exp.setEndDate(rs.getDate("end_date"));
                exp.setDescription(rs.getString("description"));
                exp.setCurrent(rs.getBoolean("is_current"));
                experiences.add(exp);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return experiences;
    }

    public boolean deleteExperience(int id, int userId) {
        String query = "DELETE FROM Experience WHERE id = ? AND user_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(query)) {
            stmt.setInt(1, id);
            stmt.setInt(2, userId);
            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
}
