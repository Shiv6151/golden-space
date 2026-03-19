package com.socialmedia.model;

import java.util.List;

public class UserSkill {
    private int id;
    private int userId;
    private int skillId;
    private String skillName;
    private int endorsementCount;
    private List<User> endorsers;
    private boolean endorsedByMe;

    public UserSkill() {}

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public int getUserId() { return userId; }
    public void setUserId(int userId) { this.userId = userId; }

    public int getSkillId() { return skillId; }
    public void setSkillId(int skillId) { this.skillId = skillId; }

    public String getSkillName() { return skillName; }
    public void setSkillName(String skillName) { this.skillName = skillName; }

    public int getEndorsementCount() { return endorsementCount; }
    public void setEndorsementCount(int endorsementCount) { this.endorsementCount = endorsementCount; }

    public List<User> getEndorsers() { return endorsers; }
    public void setEndorsers(List<User> endorsers) { this.endorsers = endorsers; }

    public boolean isEndorsedByMe() { return endorsedByMe; }
    public void setEndorsedByMe(boolean endorsedByMe) { this.endorsedByMe = endorsedByMe; }
}
