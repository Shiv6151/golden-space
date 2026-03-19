package com.socialmedia.model;

import java.sql.Timestamp;

public class Endorsement {
    private int id;
    private int userSkillId;
    private int endorserId;
    private Timestamp createdAt;

    public Endorsement() {}

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public int getUserSkillId() { return userSkillId; }
    public void setUserSkillId(int userSkillId) { this.userSkillId = userSkillId; }

    public int getEndorserId() { return endorserId; }
    public void setEndorserId(int endorserId) { this.endorserId = endorserId; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }
}
