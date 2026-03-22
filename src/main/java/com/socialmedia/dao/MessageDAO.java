package com.socialmedia.dao;

import com.socialmedia.model.Message;
import com.socialmedia.util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class MessageDAO {

    public boolean sendMessage(Message message) {
        String query = "INSERT INTO Messages (sender_id, receiver_id, message_text, attachment_url, attachment_type) VALUES (?, ?, ?, ?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(query)) {
             
            stmt.setInt(1, message.getSenderId());
            stmt.setInt(2, message.getReceiverId());
            stmt.setString(3, message.getMessageText());
            stmt.setString(4, message.getAttachmentUrl());
            stmt.setString(5, message.getAttachmentType());
            
            return stmt.executeUpdate() > 0;
            
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public List<Message> getConversation(int viewerId, int otherUserId) {
        List<Message> messages = new ArrayList<>();
        String query = "SELECT m.*, u.name, u.profile_photo " +
            "FROM Messages m " +
            "JOIN Users u ON m.sender_id = u.user_id " +
            "WHERE ((m.sender_id = ? AND m.receiver_id = ?) " +
            "   OR (m.sender_id = ? AND m.receiver_id = ?)) " +
            "ORDER BY m.message_time ASC";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(query)) {
             
            stmt.setInt(1, viewerId);
            stmt.setInt(2, otherUserId);
            stmt.setInt(3, otherUserId);
            stmt.setInt(4, viewerId);
            
            ResultSet rs = stmt.executeQuery();
            while (rs.next()) {
                Message msg = new Message();
                msg.setMessageId(rs.getInt("message_id"));
                msg.setSenderId(rs.getInt("sender_id"));
                msg.setReceiverId(rs.getInt("receiver_id"));
                msg.setMessageText(rs.getString("message_text"));
                msg.setMessageTime(rs.getTimestamp("message_time"));
                msg.setRead(rs.getBoolean("is_read"));
                msg.setSenderName(rs.getString("name"));
                msg.setSenderPhoto(rs.getString("profile_photo"));
                msg.setAttachmentUrl(rs.getString("attachment_url"));
                msg.setAttachmentType(rs.getString("attachment_type"));
                messages.add(msg);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return messages;
    }

    public List<Message> getNewMessages(int viewerId, int otherUserId, int lastMessageId) {
        List<Message> messages = new ArrayList<>();
        String query = "SELECT m.*, u.name, u.profile_photo " +
            "FROM Messages m " +
            "JOIN Users u ON m.sender_id = u.user_id " +
            "WHERE (((m.sender_id = ? AND m.receiver_id = ?) " +
            "   OR (m.sender_id = ? AND m.receiver_id = ?))) " +
            "   AND m.message_id > ? " +
            "ORDER BY m.message_time ASC";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(query)) {
             
            stmt.setInt(1, viewerId);
            stmt.setInt(2, otherUserId);
            stmt.setInt(3, otherUserId);
            stmt.setInt(4, viewerId);
            stmt.setInt(5, lastMessageId);
            
            ResultSet rs = stmt.executeQuery();
            while (rs.next()) {
                Message msg = new Message();
                msg.setMessageId(rs.getInt("message_id"));
                msg.setSenderId(rs.getInt("sender_id"));
                msg.setReceiverId(rs.getInt("receiver_id"));
                msg.setMessageText(rs.getString("message_text"));
                msg.setMessageTime(rs.getTimestamp("message_time"));
                msg.setRead(rs.getBoolean("is_read"));
                msg.setSenderName(rs.getString("name"));
                msg.setSenderPhoto(rs.getString("profile_photo"));
                msg.setAttachmentUrl(rs.getString("attachment_url"));
                msg.setAttachmentType(rs.getString("attachment_type"));
                messages.add(msg);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return messages;
    }

    public boolean clearConversation(int viewerId, int otherUserId) {
        String query = "DELETE FROM Messages WHERE (sender_id = ? AND receiver_id = ?) OR (receiver_id = ? AND sender_id = ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(query)) {
            stmt.setInt(1, viewerId);
            stmt.setInt(2, otherUserId);
            stmt.setInt(3, viewerId);
            stmt.setInt(4, otherUserId);
            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public int getUnreadCount(int userId) {
        String query = "SELECT COUNT(*) FROM Messages WHERE receiver_id = ? AND is_read = FALSE";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(query)) {
            stmt.setInt(1, userId);
            ResultSet rs = stmt.executeQuery();
            if (rs.next()) return rs.getInt(1);
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }

    public java.util.Map<String, Integer> getUnreadCountPerSender(int receiverId) {
        java.util.Map<String, Integer> counts = new java.util.HashMap<>();
        String query = "SELECT sender_id, COUNT(*) as cnt FROM Messages WHERE receiver_id = ? AND is_read = FALSE GROUP BY sender_id";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(query)) {
            stmt.setInt(1, receiverId);
            ResultSet rs = stmt.executeQuery();
            while (rs.next()) {
                counts.put(String.valueOf(rs.getInt("sender_id")), rs.getInt("cnt"));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return counts;
    }

    public void markAsRead(int receiverId, int senderId) {
        String query = "UPDATE Messages SET is_read = TRUE WHERE receiver_id = ? AND sender_id = ? AND is_read = FALSE";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(query)) {
            stmt.setInt(1, receiverId);
            stmt.setInt(2, senderId);
            stmt.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    public boolean deleteMessage(int messageId, int userId) {
        String query = "DELETE FROM Messages WHERE message_id = ? AND sender_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(query)) {
            stmt.setInt(1, messageId);
            stmt.setInt(2, userId);
            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean toggleMessageReaction(int messageId, int userId, String emoji) {
        String checkQuery = "SELECT emoji_code FROM MessageReactions WHERE message_id = ? AND user_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement checkStmt = conn.prepareStatement(checkQuery)) {
            checkStmt.setInt(1, messageId);
            checkStmt.setInt(2, userId);
            ResultSet rs = checkStmt.executeQuery();
            
            if (rs.next()) {
                String existingEmoji = rs.getString("emoji_code");
                if (existingEmoji.equals(emoji)) {
                    // Same emoji: toggle off
                    String deleteQuery = "DELETE FROM MessageReactions WHERE message_id = ? AND user_id = ?";
                    try (PreparedStatement delStmt = conn.prepareStatement(deleteQuery)) {
                        delStmt.setInt(1, messageId);
                        delStmt.setInt(2, userId);
                        delStmt.executeUpdate();
                    }
                    return false;
                } else {
                    // Different emoji: update to new emoji
                    String updateQuery = "UPDATE MessageReactions SET emoji_code = ? WHERE message_id = ? AND user_id = ?";
                    try (PreparedStatement updStmt = conn.prepareStatement(updateQuery)) {
                        updStmt.setString(1, emoji);
                        updStmt.setInt(2, messageId);
                        updStmt.setInt(3, userId);
                        updStmt.executeUpdate();
                    }
                    return true;
                }
            } else {
                // No existing reaction: insert it
                String insertQuery = "INSERT INTO MessageReactions (message_id, user_id, emoji_code) VALUES (?, ?, ?)";
                try (PreparedStatement insStmt = conn.prepareStatement(insertQuery)) {
                    insStmt.setInt(1, messageId);
                    insStmt.setInt(2, userId);
                    insStmt.setString(3, emoji);
                    insStmt.executeUpdate();
                }
                return true;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public List<String> getMessageReactions(int messageId) {
        List<String> reactions = new ArrayList<>();
        String query = "SELECT emoji_code, COUNT(*) as count FROM MessageReactions WHERE message_id = ? GROUP BY emoji_code";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(query)) {
            stmt.setInt(1, messageId);
            ResultSet rs = stmt.executeQuery();
            while (rs.next()) {
                reactions.add(rs.getString("emoji_code") + ":" + rs.getInt("count"));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return reactions;
    }
    
    public void markViewOnceViewed(int messageId) {
        String query = "UPDATE Messages SET attachment_type = 'image_viewed', attachment_url = NULL WHERE message_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(query)) {
            ps.setInt(1, messageId);
            ps.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
}
