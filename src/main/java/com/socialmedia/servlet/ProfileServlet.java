package com.socialmedia.servlet;

import com.socialmedia.dao.UserDAO;
import com.socialmedia.dao.PostDAO;
import com.socialmedia.dao.FollowDAO;
import com.socialmedia.dao.FriendDAO;
import com.socialmedia.dao.CommentDAO;
import com.socialmedia.model.Post;
import com.socialmedia.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;
import com.socialmedia.dao.ExperienceDAO;
import com.socialmedia.dao.EducationDAO;
import com.socialmedia.dao.SkillDAO;
import com.socialmedia.dao.RecommendationDAO;
import com.socialmedia.dao.ProfileViewDAO;
import com.socialmedia.model.Experience;
import com.socialmedia.model.Education;
import com.socialmedia.model.UserSkill;
import com.socialmedia.model.Recommendation;
import com.socialmedia.model.ProfileView;

@WebServlet("/ProfileServlet")
public class ProfileServlet extends HttpServlet {

    private UserDAO userDAO;
    private PostDAO postDAO;
    private FollowDAO followDAO;
    private FriendDAO friendDAO;
    private CommentDAO commentDAO;
    private ExperienceDAO experienceDAO;
    private EducationDAO educationDAO;
    private SkillDAO skillDAO;
    private RecommendationDAO recommendationDAO;
    private ProfileViewDAO profileViewDAO;

    @Override
    public void init() {
        userDAO = new UserDAO();
        postDAO = new PostDAO();
        followDAO = new FollowDAO();
        friendDAO = new FriendDAO();
        commentDAO = new CommentDAO();
        experienceDAO = new ExperienceDAO();
        educationDAO = new EducationDAO();
        skillDAO = new SkillDAO();
        recommendationDAO = new RecommendationDAO();
        profileViewDAO = new ProfileViewDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
            
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        User currentUser = (User) session.getAttribute("user");
        
        // Determine whose profile to show (self or someone else)
        String userIdParam = request.getParameter("id");
        User profileUser = null;
        int profileUserId = -1;
        
        if (userIdParam != null && !userIdParam.trim().isEmpty()) {
            try {
                profileUserId = Integer.parseInt(userIdParam);
                profileUser = userDAO.getUserById(profileUserId);
            } catch (NumberFormatException e) {
                // If ID is not a number, maybe it's a future feature (username), 
                // but for now just show current user
            }
        }
        
        // Default to current user if no valid ID or user not found by ID
        if (profileUser == null) {
            profileUser = currentUser;
            profileUserId = currentUser.getUserId();
        }

        if (profileUser == null) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND, "User not found");
            return;
        }

        request.setAttribute("profileUser", profileUser);
        boolean isSelf = (currentUser.getUserId() == profileUserId);
        request.setAttribute("isSelf", isSelf);
        
        // Fetch follower metrics
        int followersCount = followDAO.getFollowersCount(profileUserId);
        int followingCount = followDAO.getFollowingCount(profileUserId);
        boolean isFollowing = followDAO.isFollowing(currentUser.getUserId(), profileUserId);
        
        request.setAttribute("followersCount", followersCount);
        request.setAttribute("followingCount", followingCount);
        request.setAttribute("isFollowing", isFollowing);
        
        // Check for pending request status
        if (!isSelf && !isFollowing) {
            String status = friendDAO.getFriendshipStatus(currentUser.getUserId(), profileUserId);
            if ("REQUEST_SENT".equals(status)) {
                request.setAttribute("isRequestPending", true);
            }
        }
        
        // Fetch post count
        int postCount = postDAO.getPostCountByUserId(profileUserId);
        request.setAttribute("postCount", postCount);
        
        // Mutual Follow Status for Messaging and Privacy
        boolean isMutual = false;
        if (!isSelf) {
            isMutual = followDAO.isMutualFollowing(currentUser.getUserId(), profileUserId);
            request.setAttribute("isMutualFollowing", isMutual);
            
            // Calculate Connection Degree
            int degree = followDAO.getConnectionDegree(currentUser.getUserId(), profileUserId);
            request.setAttribute("connectionDegree", degree);
        }

        // Privacy Logic: Can the current user see the posts?
        // Posts are visible if:
        // 1. It's the user's own profile.
        // 2. The account is public.
        // 3. The account is private BUT there is a mutual follow relationship.
        boolean canSeePosts = isSelf || !profileUser.isPrivateAccount() || isMutual;
        request.setAttribute("canSeePosts", canSeePosts);

        if (canSeePosts) {
            // Fetch posts for this user
            List<Post> userPosts = postDAO.getPostsByUserId(profileUserId, currentUser.getUserId());
            
            // Populate comments for each post
            if (userPosts != null) {
                for (Post post : userPosts) {
                    post.setComments(commentDAO.getCommentsByPostId(post.getPostId()));
                }
            }
            request.setAttribute("userPosts", userPosts);
        }

        // Fetch Professional Timeline & Skills & Recommendations
        List<Experience> experiences = experienceDAO.getExperienceByUserId(profileUserId);
        List<Education> educationList = educationDAO.getEducationByUserId(profileUserId);
        List<UserSkill> skills = skillDAO.getUserSkills(profileUserId, currentUser.getUserId());
        List<Recommendation> acceptedRecs = recommendationDAO.getAcceptedRecommendations(profileUserId);
        
        if (!isSelf && currentUser != null) {
            profileViewDAO.recordView(currentUser.getUserId(), profileUserId);
        }
        
        request.setAttribute("experiences", experiences);
        request.setAttribute("education", educationList);
        request.setAttribute("skills", skills);
        request.setAttribute("recommendations", acceptedRecs);
        
        if (isSelf) {
            List<Recommendation> pendingRecs = recommendationDAO.getPendingRecommendations(profileUserId);
            request.setAttribute("pendingRecommendations", pendingRecs);
            
            int viewCount = profileViewDAO.getViewCount(profileUserId);
            List<ProfileView> recentViews = profileViewDAO.getRecentViews(profileUserId);
            request.setAttribute("profileViewCount", viewCount);
            request.setAttribute("recentProfileViews", recentViews);
        }

        request.getRequestDispatcher("profile.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
            
        // Handle profile update
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        User currentUser = (User) session.getAttribute("user");
        
        String name = request.getParameter("name");
        String bio = request.getParameter("bio");
        
        // For simplicity, we assume profile photo is a URL or name, not full file upload yet
        // A real app would use multipart/form-data and save the file
        String profilePhoto = request.getParameter("profilePhoto"); 

        if (name != null && !name.trim().isEmpty()) currentUser.setName(name);
        if (bio != null) currentUser.setBio(bio);
        if (profilePhoto != null && !profilePhoto.trim().isEmpty()) {
            currentUser.setProfilePhoto(profilePhoto);
        }
        
        userDAO.updateUserProfile(currentUser);
        // Update session object
        session.setAttribute("user", currentUser);

        response.sendRedirect("ProfileServlet");
    }
}
