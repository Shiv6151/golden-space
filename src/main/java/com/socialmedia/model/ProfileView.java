package com.socialmedia.model;

import java.sql.Timestamp;

public class ProfileView {
    private int id;
    private int profileId; // The user whose profile was viewed
    private int viewerId;  // The user who viewed the profile
    private Timestamp viewTime;
    
    // UI Helper fields
    private String viewerName;
    private String viewerHeadline;
    private String viewerPhoto;

    public ProfileView() {}

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public int getProfileId() { return profileId; }
    public void setProfileId(int profileId) { this.profileId = profileId; }

    public int getViewerId() { return viewerId; }
    public void setViewerId(int viewerId) { this.viewerId = viewerId; }

    public Timestamp getViewTime() { return viewTime; }
    public void setViewTime(Timestamp viewTime) { this.viewTime = viewTime; }

    public String getViewerName() { return viewerName; }
    public void setViewerName(String viewerName) { this.viewerName = viewerName; }

    public String getViewerHeadline() { return viewerHeadline; }
    public void setViewerHeadline(String viewerHeadline) { this.viewerHeadline = viewerHeadline; }

    public String getViewerPhoto() { return viewerPhoto; }
    public void setViewerPhoto(String viewerPhoto) { this.viewerPhoto = viewerPhoto; }
}
