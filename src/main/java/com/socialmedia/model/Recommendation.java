package com.socialmedia.model;

import java.sql.Timestamp;

public class Recommendation {
    private int id;
    private int senderId;
    private int receiverId;
    private String text;
    private String status; // PENDING, ACCEPTED, REJECTED
    private Timestamp createdAt;
    
    // UI helper fields
    private String senderName;
    private String senderHeadline;
    private String senderPhoto;

    public Recommendation() {}

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public int getSenderId() { return senderId; }
    public void setSenderId(int senderId) { this.senderId = senderId; }

    public int getReceiverId() { return receiverId; }
    public void setReceiverId(int receiverId) { this.receiverId = receiverId; }

    public String getText() { return text; }
    public void setText(String text) { this.text = text; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }

    public String getSenderName() { return senderName; }
    public void setSenderName(String senderName) { this.senderName = senderName; }

    public String getSenderHeadline() { return senderHeadline; }
    public void setSenderHeadline(String senderHeadline) { this.senderHeadline = senderHeadline; }

    public String getSenderPhoto() { return senderPhoto; }
    public void setSenderPhoto(String senderPhoto) { this.senderPhoto = senderPhoto; }
}
