package com.socialmedia.model;

import java.sql.Timestamp;

public class Post {
    private int postId;
    private int userId;
    private String userName; // For display
    private String userHandle; // For display (@username)
    private String userPhoto; // For display
    private String postContent;
    private String image;
    private java.util.List<String> images; // Multiple images
    private String aspectRatio; // 1:1, 16:9, etc.
    private Timestamp postDate;
    private int likeCount;
    private int commentCount;
    private boolean isLikedByCurrentUser;
    private boolean pinned;
    private java.util.List<Comment> comments;

    public Post() {
        this.images = new java.util.ArrayList<>();
    }

    public int getPostId() { return postId; }
    public void setPostId(int postId) { this.postId = postId; }

    public int getUserId() { return userId; }
    public void setUserId(int userId) { this.userId = userId; }

    public String getUserName() { return userName; }
    public void setUserName(String userName) { this.userName = userName; }
    
    public String getUserHandle() { return userHandle; }
    public void setUserHandle(String userHandle) { this.userHandle = userHandle; }
    
    public String getUserPhoto() { return userPhoto; }
    public void setUserPhoto(String userPhoto) { this.userPhoto = userPhoto; }

    public String getPostContent() { return postContent; }
    public void setPostContent(String postContent) { this.postContent = postContent; }

    public String getImage() { return image; }
    public void setImage(String image) { this.image = image; }

    public java.util.List<String> getImages() { return images; }
    public void setImages(java.util.List<String> images) { this.images = images; }

    public String getAspectRatio() { return aspectRatio; }
    public void setAspectRatio(String aspectRatio) { this.aspectRatio = aspectRatio; }

    public Timestamp getPostDate() { return postDate; }
    public void setPostDate(Timestamp postDate) { this.postDate = postDate; }

    public int getLikeCount() { return likeCount; }
    public void setLikeCount(int likeCount) { this.likeCount = likeCount; }

    public int getCommentCount() { return commentCount; }
    public void setCommentCount(int commentCount) { this.commentCount = commentCount; }

    public boolean isLikedByCurrentUser() { return isLikedByCurrentUser; }
    public void setLikedByCurrentUser(boolean isLikedByCurrentUser) { this.isLikedByCurrentUser = isLikedByCurrentUser; }
    
    public boolean isPinned() { return pinned; }
    public boolean getPinned() { return pinned; }
    public void setPinned(boolean pinned) { this.pinned = pinned; }

    public java.util.List<Comment> getComments() { return comments; }
    public void setComments(java.util.List<Comment> comments) { this.comments = comments; }
}
