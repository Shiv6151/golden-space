package com.socialmedia.dao;

import com.socialmedia.model.Comment;
import com.socialmedia.util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class CommentDAO {

    public boolean addComment(Comment comment) {
        String query = "INSERT INTO Comments (post_id, user_id, comment_text) VALUES (?, ?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(query)) {
             
            stmt.setInt(1, comment.getPostId());
            stmt.setInt(2, comment.getUserId());
            stmt.setString(3, comment.getCommentText());
            
            if (stmt.executeUpdate() > 0) {
                 com.socialmedia.model.Post p = new PostDAO().getPostById(comment.getPostId(), comment.getUserId());
                 if (p != null) {
                     new NotificationDAO().addNotification(p.getUserId(), comment.getUserId(), "COMMENT", comment.getPostId());
                 }
                 return true;
            }
            
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public List<Comment> getCommentsByPostId(int postId) {
        List<Comment> comments = new ArrayList<>();
        String query = 
            "SELECT c.*, u.name, u.profile_photo " +
            "FROM Comments c " +
            "JOIN Users u ON c.user_id = u.user_id " +
            "WHERE c.post_id = ? " +
            "ORDER BY c.comment_date ASC";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(query)) {
             
            stmt.setInt(1, postId);
            
            ResultSet rs = stmt.executeQuery();
            while (rs.next()) {
                Comment comment = new Comment();
                comment.setCommentId(rs.getInt("comment_id"));
                comment.setPostId(rs.getInt("post_id"));
                comment.setUserId(rs.getInt("user_id"));
                comment.setUserName(rs.getString("name"));
                comment.setUserPhoto(rs.getString("profile_photo"));
                comment.setCommentText(rs.getString("comment_text"));
                comment.setCommentDate(rs.getTimestamp("comment_date"));
                comments.add(comment);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return comments;
    }
    public boolean deleteComment(int commentId) {
        String query = "DELETE FROM Comments WHERE comment_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(query)) {
            stmt.setInt(1, commentId);
            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
}
