package com.socialmedia.dao;

import com.socialmedia.model.Education;
import com.socialmedia.util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class EducationDAO {

    public boolean addEducation(Education edu) {
        String query = "INSERT INTO Education (user_id, school, degree, field_of_study, start_date, end_date, description) VALUES (?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(query)) {
            stmt.setInt(1, edu.getUserId());
            stmt.setString(2, edu.getSchool());
            stmt.setString(3, edu.getDegree());
            stmt.setString(4, edu.getFieldOfStudy());
            stmt.setDate(5, new java.sql.Date(edu.getStartDate().getTime()));
            if (edu.getEndDate() != null) {
                stmt.setDate(6, new java.sql.Date(edu.getEndDate().getTime()));
            } else {
                stmt.setNull(6, Types.DATE);
            }
            stmt.setString(7, edu.getDescription());
            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public List<Education> getEducationByUserId(int userId) {
        List<Education> educationList = new ArrayList<>();
        String query = "SELECT * FROM Education WHERE user_id = ? ORDER BY start_date DESC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(query)) {
            stmt.setInt(1, userId);
            ResultSet rs = stmt.executeQuery();
            while (rs.next()) {
                Education edu = new Education();
                edu.setId(rs.getInt("id"));
                edu.setUserId(rs.getInt("user_id"));
                edu.setSchool(rs.getString("school"));
                edu.setDegree(rs.getString("degree"));
                edu.setFieldOfStudy(rs.getString("field_of_study"));
                edu.setStartDate(rs.getDate("start_date"));
                edu.setEndDate(rs.getDate("end_date"));
                edu.setDescription(rs.getString("description"));
                educationList.add(edu);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return educationList;
    }

    public boolean updateEducation(Education edu) {
        String query = "UPDATE Education SET school=?, degree=?, field_of_study=?, start_date=?, end_date=?, description=? WHERE id=? AND user_id=?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(query)) {
            stmt.setString(1, edu.getSchool());
            stmt.setString(2, edu.getDegree());
            stmt.setString(3, edu.getFieldOfStudy());
            stmt.setDate(4, new java.sql.Date(edu.getStartDate().getTime()));
            if (edu.getEndDate() != null) {
                stmt.setDate(5, new java.sql.Date(edu.getEndDate().getTime()));
            } else {
                stmt.setNull(5, Types.DATE);
            }
            stmt.setString(6, edu.getDescription());
            stmt.setInt(7, edu.getId());
            stmt.setInt(8, edu.getUserId());
            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean deleteEducation(int id, int userId) {
        String query = "DELETE FROM Education WHERE id = ? AND user_id = ?";
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
