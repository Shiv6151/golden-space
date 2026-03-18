package com.socialmedia.model;

import java.sql.Timestamp;

public class Comment {
    private int commentId;
    private int postId;
    private int userId;
    private String userName; // For display
    private String userPhoto; // For display
    private String commentText;
    private Timestamp commentDate;

    public Comment() {}

    public int getCommentId() { return commentId; }
    public void setCommentId(int commentId) { this.commentId = commentId; }

    public int getPostId() { return postId; }
    public void setPostId(int postId) { this.postId = postId; }

    public int getUserId() { return userId; }
    public void setUserId(int userId) { this.userId = userId; }

    public String getUserName() { return userName; }
    public void setUserName(String userName) { this.userName = userName; }

    public String getUserPhoto() { return userPhoto; }
    public void setUserPhoto(String userPhoto) { this.userPhoto = userPhoto; }

    public String getCommentText() { return commentText; }
    public void setCommentText(String commentText) { this.commentText = commentText; }

    public Timestamp getCommentDate() { return commentDate; }
    public void setCommentDate(Timestamp commentDate) { this.commentDate = commentDate; }
}
