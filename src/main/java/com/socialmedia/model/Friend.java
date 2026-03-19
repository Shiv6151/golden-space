package com.socialmedia.model;

import java.sql.Timestamp;

public class Friend {
    private int userId;
    private int friendId;
    private String status; // 'PENDING', 'ACCEPTED', 'REJECTED'
    private String message;
    private Timestamp createdAt;

    // For display purposes, to show info about the friend
    private String friendName;
    private String friendPhoto;

    public Friend() {}

    public int getUserId() { return userId; }
    public void setUserId(int userId) { this.userId = userId; }

    public int getFriendId() { return friendId; }
    public void setFriendId(int friendId) { this.friendId = friendId; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }

    public String getFriendName() { return friendName; }
    public void setFriendName(String friendName) { this.friendName = friendName; }

    public String getFriendPhoto() { return friendPhoto; }
    public void setFriendPhoto(String friendPhoto) { this.friendPhoto = friendPhoto; }

    public String getMessage() { return message; }
    public void setMessage(String message) { this.message = message; }
}
