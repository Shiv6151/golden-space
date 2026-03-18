package com.socialmedia.model;

import java.sql.Timestamp;

public class Message {
    private int messageId;
    private int senderId;
    private int receiverId;
    private String messageText;
    private Timestamp messageTime;
    private boolean isRead;

    // For display
    private String senderName;
    private String senderPhoto;

    public Message() {}

    public int getMessageId() { return messageId; }
    public void setMessageId(int messageId) { this.messageId = messageId; }

    public int getSenderId() { return senderId; }
    public void setSenderId(int senderId) { this.senderId = senderId; }

    public int getReceiverId() { return receiverId; }
    public void setReceiverId(int receiverId) { this.receiverId = receiverId; }

    public String getMessageText() { return messageText; }
    public void setMessageText(String messageText) { this.messageText = messageText; }

    public Timestamp getMessageTime() { return messageTime; }
    public void setMessageTime(Timestamp messageTime) { this.messageTime = messageTime; }

    public String getSenderName() { return senderName; }
    public void setSenderName(String senderName) { this.senderName = senderName; }

    public String getSenderPhoto() { return senderPhoto; }
    public void setSenderPhoto(String senderPhoto) { this.senderPhoto = senderPhoto; }

    public boolean isRead() { return isRead; }
    public void setRead(boolean read) { isRead = read; }
}
