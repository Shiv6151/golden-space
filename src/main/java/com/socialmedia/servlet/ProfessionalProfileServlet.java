package com.socialmedia.servlet;

import com.socialmedia.dao.EducationDAO;
import com.socialmedia.dao.ExperienceDAO;
import com.socialmedia.dao.SkillDAO;
import com.socialmedia.dao.EndorsementDAO;
import com.socialmedia.dao.RecommendationDAO;
import com.socialmedia.dao.UserDAO;
import com.socialmedia.model.Education;
import com.socialmedia.model.Experience;
import com.socialmedia.model.Skill;
import com.socialmedia.model.Recommendation;
import com.socialmedia.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.io.PrintWriter;
import java.text.SimpleDateFormat;
import java.util.List;

@WebServlet("/ProfessionalProfileServlet")
public class ProfessionalProfileServlet extends HttpServlet {
    private ExperienceDAO experienceDAO;
    private EducationDAO educationDAO;
    private UserDAO userDAO;
    private SkillDAO skillDAO;
    private EndorsementDAO endorsementDAO;
    private RecommendationDAO recommendationDAO;
    private SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd");

    @Override
    public void init() {
        experienceDAO = new ExperienceDAO();
        educationDAO = new EducationDAO();
        userDAO = new UserDAO();
        skillDAO = new SkillDAO();
        endorsementDAO = new EndorsementDAO();
        recommendationDAO = new RecommendationDAO();
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            return;
        }

        User currentUser = (User) session.getAttribute("user");
        String action = request.getParameter("action");
        PrintWriter out = response.getWriter();

        try {
            if ("addExperience".equals(action)) {
                Experience exp = new Experience();
                exp.setUserId(currentUser.getUserId());
                exp.setCompany(request.getParameter("company"));
                exp.setTitle(request.getParameter("title"));
                exp.setLocation(request.getParameter("location"));
                exp.setStartDate(dateFormat.parse(request.getParameter("startDate")));
                String endDateStr = request.getParameter("endDate");
                if (endDateStr != null && !endDateStr.isEmpty()) {
                    exp.setEndDate(dateFormat.parse(endDateStr));
                }
                exp.setDescription(request.getParameter("description"));
                exp.setCurrent("true".equals(request.getParameter("isCurrent")));
                
                boolean success = experienceDAO.addExperience(exp);
                out.print(success ? "success" : "error");

            } else if ("deleteExperience".equals(action)) {
                int id = Integer.parseInt(request.getParameter("id"));
                boolean success = experienceDAO.deleteExperience(id, currentUser.getUserId());
                out.print(success ? "success" : "error");

            } else if ("addEducation".equals(action)) {
                Education edu = new Education();
                edu.setUserId(currentUser.getUserId());
                edu.setSchool(request.getParameter("school"));
                edu.setDegree(request.getParameter("degree"));
                edu.setFieldOfStudy(request.getParameter("fieldOfStudy"));
                edu.setStartDate(dateFormat.parse(request.getParameter("startDate")));
                String endDateStr = request.getParameter("endDate");
                if (endDateStr != null && !endDateStr.isEmpty()) {
                    edu.setEndDate(dateFormat.parse(endDateStr));
                }
                edu.setDescription(request.getParameter("description"));
                
                boolean success = educationDAO.addEducation(edu);
                out.print(success ? "success" : "error");

            } else if ("deleteEducation".equals(action)) {
                int id = Integer.parseInt(request.getParameter("id"));
                boolean success = educationDAO.deleteEducation(id, currentUser.getUserId());
                out.print(success ? "success" : "error");
                
            } else if ("updateProfessionalInfo".equals(action)) {
                currentUser.setHeadline(request.getParameter("headline"));
                currentUser.setProfessionalSummary(request.getParameter("summary"));
                boolean success = userDAO.updateUserProfile(currentUser);
                if (success) {
                    session.setAttribute("user", currentUser);
                }
                out.print(success ? "success" : "error");

            } else if ("addSkill".equals(action)) {
                int skillId = Integer.parseInt(request.getParameter("skillId"));
                boolean success = skillDAO.addUserSkill(currentUser.getUserId(), skillId);
                out.print(success ? "success" : "error");

            } else if ("removeSkill".equals(action)) {
                int skillId = Integer.parseInt(request.getParameter("skillId"));
                boolean success = skillDAO.removeUserSkill(currentUser.getUserId(), skillId);
                out.print(success ? "success" : "error");

            } else if ("toggleEndorsement".equals(action)) {
                int userSkillId = Integer.parseInt(request.getParameter("userSkillId"));
                boolean success = endorsementDAO.toggleEndorsement(userSkillId, currentUser.getUserId());
                out.print(success ? "success" : "error");

            } else if ("searchSkills".equals(action)) {
                String query = request.getParameter("query");
                List<Skill> skills = skillDAO.searchSkills(query);
                StringBuilder json = new StringBuilder("[");
                for (int i = 0; i < skills.size(); i++) {
                    Skill s = skills.get(i);
                    json.append(String.format("{\"id\":%d, \"name\":\"%s\"}", s.getId(), s.getName()));
                    if (i < skills.size() - 1) json.append(",");
                }
                json.append("]");
                out.print(json.toString());

            } else if ("submitRecommendation".equals(action)) {
                Recommendation rec = new Recommendation();
                rec.setSenderId(currentUser.getUserId());
                rec.setReceiverId(Integer.parseInt(request.getParameter("receiverId")));
                rec.setText(request.getParameter("text"));
                boolean success = recommendationDAO.submitRecommendation(rec);
                out.print(success ? "success" : "error");

            } else if ("updateRecommendation".equals(action)) {
                int recId = Integer.parseInt(request.getParameter("id"));
                String status = request.getParameter("status");
                boolean success = recommendationDAO.updateStatus(recId, currentUser.getUserId(), status);
                out.print(success ? "success" : "error");
            }

        } catch (Exception e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            out.print("error: " + e.getMessage());
        }
    }
}
