package com.socialmedia.model;

import java.util.Date;

public class User {
    private int userId;
    private String username;
    private String name;
    private String email;
    private String password;
    private String profilePhoto;
    private String bio;
    private String headline;
    private String professionalSummary;
    private java.util.Date createdAt;
    private boolean isFollowedByMe;
    private boolean privateAccount;
    private int unreadCount; // transient: unread messages from this user

    public User() {}

    public User(int userId, String username, String name, String email, String password, String profilePhoto, String bio, String headline, String professionalSummary, java.util.Date createdAt, boolean privateAccount) {
        this.userId = userId;
        this.username = username;
        this.name = name;
        this.email = email;
        this.password = password;
        this.profilePhoto = profilePhoto;
        this.bio = bio;
        this.headline = headline;
        this.professionalSummary = professionalSummary;
        this.createdAt = createdAt;
        this.privateAccount = privateAccount;
    }

    public int getUserId() { return userId; }
    public void setUserId(int userId) { this.userId = userId; }

    public String getUsername() { return username; }
    public void setUsername(String username) { this.username = username; }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }

    public String getPassword() { return password; }
    public void setPassword(String password) { this.password = password; }

    public String getProfilePhoto() { return profilePhoto; }
    public void setProfilePhoto(String profilePhoto) { this.profilePhoto = profilePhoto; }

    public String getBio() { return bio; }
    public void setBio(String bio) { this.bio = bio; }

    public String getHeadline() { return headline; }
    public void setHeadline(String headline) { this.headline = headline; }

    public String getProfessionalSummary() { return professionalSummary; }
    public void setProfessionalSummary(String professionalSummary) { this.professionalSummary = professionalSummary; }

    public java.util.Date getCreatedAt() { return createdAt; }
    public void setCreatedAt(java.util.Date createdAt) { this.createdAt = createdAt; }

    public boolean isFollowedByMe() { return isFollowedByMe; }
    public void setFollowedByMe(boolean followedByMe) { isFollowedByMe = followedByMe; }

    public boolean isPrivateAccount() { return privateAccount; }
    public boolean getPrivateAccount() { return privateAccount; }
    public void setPrivateAccount(boolean privateAccount) { this.privateAccount = privateAccount; }

    public int getUnreadCount() { return unreadCount; }
    public void setUnreadCount(int unreadCount) { this.unreadCount = unreadCount; }
}
