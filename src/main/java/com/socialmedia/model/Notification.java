package com.socialmedia.model;

import java.sql.Timestamp;

public class Notification {
    private int id;
    private int userId;
    private int actorId;
    private String actorName;
    private String actorPhoto;
    private String type; // FRIEND_REQUEST, FOLLOW, LIKE, COMMENT, SHARE
    private Integer targetId;
    private Timestamp createdAt;
    private boolean isRead;

    // Default constructor
    public Notification() {}

    // Getters and Setters
    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public int getUserId() { return userId; }
    public void setUserId(int userId) { this.userId = userId; }

    public int getActorId() { return actorId; }
    public void setActorId(int actorId) { this.actorId = actorId; }

    public String getActorName() { return actorName; }
    public void setActorName(String actorName) { this.actorName = actorName; }

    public String getActorPhoto() { return actorPhoto; }
    public void setActorPhoto(String actorPhoto) { this.actorPhoto = actorPhoto; }

    public String getType() { return type; }
    public void setType(String type) { this.type = type; }

    public Integer getTargetId() { return targetId; }
    public void setTargetId(Integer targetId) { this.targetId = targetId; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }

    public boolean isRead() { return isRead; }
    public void setRead(boolean isRead) { this.isRead = isRead; }
}
