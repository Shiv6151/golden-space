package com.socialmedia.dao;

import com.socialmedia.model.Post;
import com.socialmedia.model.User;
import com.socialmedia.util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class PostDAO {

    public boolean createPost(Post post) {
        String query = "INSERT INTO Posts (user_id, post_content, image, aspect_ratio) VALUES (?, ?, ?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(query, Statement.RETURN_GENERATED_KEYS)) {
             
            stmt.setInt(1, post.getUserId());
            stmt.setString(2, post.getPostContent());
            // Store the first image in the main table for backward compatibility if needed, 
            // but we'll primarily use PostImages table
            stmt.setString(3, post.getImages().isEmpty() ? null : post.getImages().get(0));
            stmt.setString(4, post.getAspectRatio());
            
            int affectedRows = stmt.executeUpdate();
            if (affectedRows > 0) {
                try (ResultSet generatedKeys = stmt.getGeneratedKeys()) {
                    if (generatedKeys.next()) {
                        int postId = generatedKeys.getInt(1);
                        // Insert all images into PostImages table
                        String imgQuery = "INSERT INTO PostImages (post_id, image_path, sort_order) VALUES (?, ?, ?)";
                        try (PreparedStatement imgStmt = conn.prepareStatement(imgQuery)) {
                            for (int i = 0; i < post.getImages().size(); i++) {
                                imgStmt.setInt(1, postId);
                                imgStmt.setString(2, post.getImages().get(i));
                                imgStmt.setInt(3, i);
                                imgStmt.addBatch();
                            }
                            imgStmt.executeBatch();
                        }
                    }
                }
                return true;
            }
            
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean deletePost(int postId, int userId) {
        String query = "DELETE FROM Posts WHERE post_id = ? AND user_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(query)) {
            stmt.setInt(1, postId);
            stmt.setInt(2, userId);
            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean updatePost(Post post) {
        String query = "UPDATE Posts SET post_content = ?, aspect_ratio = ? WHERE post_id = ? AND user_id = ?";
        try (Connection conn = DBConnection.getConnection()) {
            conn.setAutoCommit(false);
            try (PreparedStatement stmt = conn.prepareStatement(query)) {
                stmt.setString(1, post.getPostContent());
                stmt.setString(2, post.getAspectRatio());
                stmt.setInt(3, post.getPostId());
                stmt.setInt(4, post.getUserId());
                
                int updated = stmt.executeUpdate();
                if (updated > 0 && post.getImages() != null && !post.getImages().isEmpty()) {
                    // Delete old images
                    String deleteImg = "DELETE FROM PostImages WHERE post_id = ?";
                    try (PreparedStatement delStmt = conn.prepareStatement(deleteImg)) {
                        delStmt.setInt(1, post.getPostId());
                        delStmt.executeUpdate();
                    }
                    
                    // Insert new/adjusted images
                    String insertImg = "INSERT INTO PostImages (post_id, image_path, sort_order) VALUES (?, ?, ?)";
                    try (PreparedStatement insStmt = conn.prepareStatement(insertImg)) {
                        for (int i = 0; i < post.getImages().size(); i++) {
                            insStmt.setInt(1, post.getPostId());
                            insStmt.setString(2, post.getImages().get(i));
                            insStmt.setInt(3, i);
                            insStmt.addBatch();
                        }
                        insStmt.executeBatch();
                    }
                }
                conn.commit();
                return updated > 0;
            } catch (SQLException e) {
                conn.rollback();
                e.printStackTrace();
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean updatePostContent(int postId, int userId, String newContent) {
        String query = "UPDATE Posts SET post_content = ? WHERE post_id = ? AND user_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(query)) {
            stmt.setString(1, newContent);
            stmt.setInt(2, postId);
            stmt.setInt(3, userId);
            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public List<Post> getFeedPosts(int currentUserId) {
        List<Post> posts = new ArrayList<>();
        // Fetch posts from friends AND user's own posts, ordered by newest first
        String query = 
            "SELECT p.*, u.name, u.username, u.profile_photo, " +
            "(SELECT COUNT(*) FROM Likes WHERE post_id = p.post_id) AS like_count, " +
            "(SELECT COUNT(*) FROM Comments WHERE post_id = p.post_id) AS comment_count, " +
            "(SELECT COUNT(*) FROM Likes WHERE post_id = p.post_id AND user_id = ?) " +
            "AS is_liked_by_me " +
            "FROM Posts p " +
            "JOIN Users u ON p.user_id = u.user_id " +
            "WHERE p.user_id = ? " +
            "OR (p.user_id IN (SELECT following_id FROM followers WHERE follower_id = ?) " +
            "    AND (u.is_private = 0 OR " +
            "         p.user_id IN (SELECT follower_id FROM followers WHERE following_id = ?))) " +
            "ORDER BY p.post_date DESC";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(query)) {
             
            stmt.setInt(1, currentUserId);
            stmt.setInt(2, currentUserId);
            stmt.setInt(3, currentUserId);
            stmt.setInt(4, currentUserId);
            
            ResultSet rs = stmt.executeQuery();
            while (rs.next()) {
                posts.add(extractPostFromResultSet(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return posts;
    }

    public List<Post> getPostsByUserId(int userId, int currentUserId) {
        List<Post> posts = new ArrayList<>();
        String query = 
            "SELECT p.*, u.name, u.username, u.profile_photo, " +
            "(SELECT COUNT(*) FROM Likes WHERE post_id = p.post_id) AS like_count, " +
            "(SELECT COUNT(*) FROM Comments WHERE post_id = p.post_id) AS comment_count, " +
            "(SELECT COUNT(*) FROM Likes WHERE post_id = p.post_id AND user_id = ?) " +
            "AS is_liked_by_me " +
            "FROM Posts p " +
            "JOIN Users u ON p.user_id = u.user_id " +
            "WHERE p.user_id = ? ORDER BY p.is_pinned DESC, p.post_date DESC";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(query)) {
             
            stmt.setInt(1, currentUserId);
            stmt.setInt(2, userId);
            
            ResultSet rs = stmt.executeQuery();
            while (rs.next()) {
                posts.add(extractPostFromResultSet(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return posts;
    }

    public int getPostCountByUserId(int userId) {
        String query = "SELECT COUNT(*) FROM Posts WHERE user_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(query)) {
            stmt.setInt(1, userId);
            ResultSet rs = stmt.executeQuery();
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }

    public Post getPostById(int postId, int currentUserId) {
        String query = 
            "SELECT p.*, u.name, u.username, u.profile_photo, " +
            "(SELECT COUNT(*) FROM Likes WHERE post_id = p.post_id) AS like_count, " +
            "(SELECT COUNT(*) FROM Comments WHERE post_id = p.post_id) AS comment_count, " +
            "(SELECT COUNT(*) FROM Likes WHERE post_id = p.post_id AND user_id = ?) " +
            "AS is_liked_by_me " +
            "FROM Posts p " +
            "JOIN Users u ON p.user_id = u.user_id " +
            "WHERE p.post_id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(query)) {
             
            stmt.setInt(1, currentUserId);
            stmt.setInt(2, postId);
            
            ResultSet rs = stmt.executeQuery();
            if (rs.next()) {
                return extractPostFromResultSet(rs);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    public boolean toggleLike(int postId, int userId) {
        String checkQuery = "SELECT * FROM Likes WHERE post_id = ? AND user_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement checkStmt = conn.prepareStatement(checkQuery)) {
            
            checkStmt.setInt(1, postId);
            checkStmt.setInt(2, userId);
            ResultSet rs = checkStmt.executeQuery();
            
            if (rs.next()) {
                // Unlike
                String deleteQuery = "DELETE FROM Likes WHERE post_id = ? AND user_id = ?";
                try (PreparedStatement delStmt = conn.prepareStatement(deleteQuery)) {
                    delStmt.setInt(1, postId);
                    delStmt.setInt(2, userId);
                    delStmt.executeUpdate();
                }
                return false; // Result is "not liked"
            } else {
                // Like
                String insertQuery = "INSERT INTO Likes (post_id, user_id) VALUES (?, ?)";
                try (PreparedStatement insertStmt = conn.prepareStatement(insertQuery)) {
                    insertStmt.setInt(1, postId);
                    insertStmt.setInt(2, userId);
                    insertStmt.executeUpdate();
                }
                return true; // Result is "liked"
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public String togglePin(int postId, int userId) {
        // First, check how many posts are already pinned
        String countQuery = "SELECT COUNT(*) FROM Posts WHERE user_id = ? AND is_pinned = TRUE";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement countStmt = conn.prepareStatement(countQuery)) {
            
            countStmt.setInt(1, userId);
            ResultSet rs = countStmt.executeQuery();
            int pinnedCount = 0;
            if (rs.next()) pinnedCount = rs.getInt(1);

            // Get current pin status
            String statusQuery = "SELECT is_pinned FROM Posts WHERE post_id = ? AND user_id = ?";
            try (PreparedStatement statusStmt = conn.prepareStatement(statusQuery)) {
                statusStmt.setInt(1, postId);
                statusStmt.setInt(2, userId);
                ResultSet statusRs = statusStmt.executeQuery();
                if (statusRs.next()) {
                    boolean isCurrentlyPinned = statusRs.getBoolean("is_pinned");
                    if (!isCurrentlyPinned && pinnedCount >= 3) {
                        return "limit_reached";
                    }
                    
                    String updateQuery = "UPDATE Posts SET is_pinned = ? WHERE post_id = ? AND user_id = ?";
                    try (PreparedStatement updateStmt = conn.prepareStatement(updateQuery)) {
                        updateStmt.setBoolean(1, !isCurrentlyPinned);
                        updateStmt.setInt(2, postId);
                        updateStmt.setInt(3, userId);
                        updateStmt.executeUpdate();
                        return !isCurrentlyPinned ? "pinned" : "unpinned";
                    }
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return "error";
    }

    public List<User> getLikersForPost(int postId) {
        List<User> likers = new ArrayList<>();
        String query = "SELECT u.user_id, u.name, u.username, u.profile_photo FROM Likes l JOIN Users u ON l.user_id = u.user_id WHERE l.post_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(query)) {
            stmt.setInt(1, postId);
            ResultSet rs = stmt.executeQuery();
            while (rs.next()) {
                User u = new User();
                u.setUserId(rs.getInt("user_id"));
                u.setName(rs.getString("name"));
                u.setUsername(rs.getString("username"));
                u.setProfilePhoto(rs.getString("profile_photo"));
                likers.add(u);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return likers;
    }

    public boolean toggleReaction(int postId, int userId, String emoji) {
        String checkQuery = "SELECT * FROM PostReactions WHERE post_id = ? AND user_id = ? AND emoji_code = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement checkStmt = conn.prepareStatement(checkQuery)) {
            checkStmt.setInt(1, postId);
            checkStmt.setInt(2, userId);
            checkStmt.setString(3, emoji);
            ResultSet rs = checkStmt.executeQuery();
            
            if (rs.next()) {
                String deleteQuery = "DELETE FROM PostReactions WHERE post_id = ? AND user_id = ? AND emoji_code = ?";
                try (PreparedStatement delStmt = conn.prepareStatement(deleteQuery)) {
                    delStmt.setInt(1, postId);
                    delStmt.setInt(2, userId);
                    delStmt.setString(3, emoji);
                    delStmt.executeUpdate();
                }
                return false;
            } else {
                String insertQuery = "INSERT INTO PostReactions (post_id, user_id, emoji_code) VALUES (?, ?, ?)";
                try (PreparedStatement insStmt = conn.prepareStatement(insertQuery)) {
                    insStmt.setInt(1, postId);
                    insStmt.setInt(2, userId);
                    insStmt.setString(3, emoji);
                    if (insStmt.executeUpdate() > 0) {
                        Post p = getPostById(postId, userId);
                        if (p != null) {
                            new NotificationDAO().addNotification(p.getUserId(), userId, "LIKE", postId);
                        }
                    }
                }
                return true;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public List<String> getReactionsForPost(int postId) {
        List<String> reactions = new ArrayList<>();
        String query = "SELECT emoji_code, COUNT(*) as count FROM PostReactions WHERE post_id = ? GROUP BY emoji_code";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(query)) {
            stmt.setInt(1, postId);
            ResultSet rs = stmt.executeQuery();
            while (rs.next()) {
                reactions.add(rs.getString("emoji_code") + ":" + rs.getInt("count"));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return reactions;
    }

    public List<Post> searchPostsByHashtag(String hashtag, int currentUserId) {
        List<Post> posts = new ArrayList<>();
        String query = 
            "SELECT p.*, u.name, u.username, u.profile_photo, " +
            "(SELECT COUNT(*) FROM Likes WHERE post_id = p.post_id) AS like_count, " +
            "(SELECT COUNT(*) FROM Comments WHERE post_id = p.post_id) AS comment_count, " +
            "(SELECT COUNT(*) FROM Likes WHERE post_id = p.post_id AND user_id = ?) " +
            "AS is_liked_by_me " +
            "FROM Posts p " +
            "JOIN Users u ON p.user_id = u.user_id " +
            "WHERE p.post_content LIKE ? " +
            "AND (u.is_private = 0 OR p.user_id = ? OR " +
            "     p.user_id IN (SELECT following_id FROM followers WHERE follower_id = ?)) " +
            "ORDER BY p.post_date DESC";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(query)) {
             
            stmt.setInt(1, currentUserId);
            
            // Allow user to search "new" and match `#new`
            String searchPattern = hashtag.startsWith("#") ? "%" + hashtag + "%" : "%#" + hashtag + "%";
            stmt.setString(2, searchPattern);
            
            stmt.setInt(3, currentUserId);
            stmt.setInt(4, currentUserId);
            
            ResultSet rs = stmt.executeQuery();
            while (rs.next()) {
                posts.add(extractPostFromResultSet(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return posts;
    }

    private Post extractPostFromResultSet(ResultSet rs) throws SQLException {
        Post post = new Post();
        int postId = rs.getInt("post_id");
        post.setPostId(postId);
        post.setUserId(rs.getInt("user_id"));
        post.setUserName(rs.getString("name"));
        post.setUserHandle(rs.getString("username"));
        post.setUserPhoto(rs.getString("profile_photo"));
        post.setPostContent(rs.getString("post_content"));
        post.setImage(rs.getString("image"));
        post.setAspectRatio(rs.getString("aspect_ratio"));
        post.setPostDate(rs.getTimestamp("post_date"));
        post.setLikeCount(rs.getInt("like_count"));
        post.setCommentCount(rs.getInt("comment_count"));
        post.setLikedByCurrentUser(rs.getInt("is_liked_by_me") > 0);
        post.setPinned(rs.getBoolean("is_pinned"));
        
        // Fetch multiple images
        List<String> images = new ArrayList<>();
        String imgQuery = "SELECT image_path FROM PostImages WHERE post_id = ? ORDER BY sort_order";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement imgStmt = conn.prepareStatement(imgQuery)) {
            imgStmt.setInt(1, postId);
            ResultSet imgRs = imgStmt.executeQuery();
            while (imgRs.next()) {
                images.add(imgRs.getString("image_path"));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        // Fallback for old posts without PostImages entries
        if (images.isEmpty() && post.getImage() != null && !post.getImage().isEmpty()) {
            images.add(post.getImage());
        }
        post.setImages(images);
        
        return post;
    }
}
