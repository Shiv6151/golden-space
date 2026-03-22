package com.socialmedia.dao;

import com.socialmedia.model.Skill;
import com.socialmedia.model.UserSkill;
import com.socialmedia.util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class SkillDAO {

    public List<Skill> searchSkills(String query) {
        List<Skill> skills = new ArrayList<>();
        String sql = "SELECT * FROM Skills WHERE LOWER(name) LIKE LOWER(?) LIMIT 10";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, "%" + query + "%");
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    skills.add(new Skill(rs.getInt("id"), rs.getString("name"), rs.getString("category")));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return skills;
    }

    public List<UserSkill> getUserSkills(int userId, int currentUserId) {
        List<UserSkill> userSkills = new ArrayList<>();
        String sql = "SELECT us.*, s.name as skill_name, " +
                     "(SELECT COUNT(*) FROM Endorsements WHERE user_skill_id = us.id) as endorsement_count, " +
                     "(SELECT 1 FROM Endorsements WHERE user_skill_id = us.id AND endorser_id = ?) as endorsed_by_me " +
                     "FROM UserSkills us " +
                     "JOIN Skills s ON us.skill_id = s.id " +
                     "WHERE us.user_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, currentUserId);
            stmt.setInt(2, userId);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    UserSkill us = new UserSkill();
                    us.setId(rs.getInt("id"));
                    us.setUserId(rs.getInt("user_id"));
                    us.setSkillId(rs.getInt("skill_id"));
                    us.setSkillName(rs.getString("skill_name"));
                    us.setEndorsementCount(rs.getInt("endorsement_count"));
                    us.setEndorsedByMe(rs.getInt("endorsed_by_me") == 1);
                    userSkills.add(us);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return userSkills;
    }

    public boolean addUserSkill(int userId, int skillId) {
        String sql = "INSERT INTO UserSkills (user_id, skill_id) VALUES (?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, userId);
            stmt.setInt(2, skillId);
            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean removeUserSkill(int userId, int skillId) {
        String sql = "DELETE FROM UserSkills WHERE user_id = ? AND skill_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, userId);
            stmt.setInt(2, skillId);
            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
}
