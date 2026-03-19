package com.socialmedia.model;

import java.util.Date;

public class Experience {
    private int id;
    private int userId;
    private String company;
    private String title;
    private String location;
    private Date startDate;
    private Date endDate;
    private String description;
    private boolean isCurrent;

    public Experience() {}

    // Getters and Setters
    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    public int getUserId() { return userId; }
    public void setUserId(int userId) { this.userId = userId; }
    public String getCompany() { return company; }
    public void setCompany(String company) { this.company = company; }
    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }
    public String getLocation() { return location; }
    public void setLocation(String location) { this.location = location; }
    public Date getStartDate() { return startDate; }
    public void setStartDate(Date startDate) { this.startDate = startDate; }
    public Date getEndDate() { return endDate; }
    public void setEndDate(Date endDate) { this.endDate = endDate; }
    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }
    public boolean isCurrent() { return isCurrent; }
    public void setCurrent(boolean isCurrent) { this.isCurrent = isCurrent; }
}
