package com.socialmedia.servlet;

import com.socialmedia.dao.FollowDAO;
import com.socialmedia.dao.FriendDAO;
import com.socialmedia.dao.UserDAO;
import com.socialmedia.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

@WebServlet("/FollowServlet")
public class FollowServlet extends HttpServlet {

    private FollowDAO followDAO;
    private FriendDAO friendDAO;
    private UserDAO userDAO;

    @Override
    public void init() {
        followDAO = new FollowDAO();
        friendDAO = new FriendDAO();
        userDAO = new UserDAO();
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
            
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        User currentUser = (User) session.getAttribute("user");
        String action = request.getParameter("action");
        String targetIdStr = request.getParameter("targetId");
        
        if (targetIdStr == null || targetIdStr.trim().isEmpty()) {
            // Check for 'id' as a fallback
            targetIdStr = request.getParameter("id");
        }

        if (targetIdStr == null || targetIdStr.trim().isEmpty()) {
            String referer = request.getHeader("Referer");
            response.sendRedirect(referer != null ? referer : "ProfileServlet");
            return;
        }

        int targetUserId = Integer.parseInt(targetIdStr);
        User targetUser = userDAO.getUserById(targetUserId); // Changed to use instance variable

        if (action == null || "toggle".equals(action)) {
            if (targetUser != null && targetUser.isPrivateAccount() && !followDAO.isFollowing(currentUser.getUserId(), targetUserId)) {
                // If it's a private account and we're not already following, send a request
                String status = friendDAO.getFriendshipStatus(currentUser.getUserId(), targetUserId); // Changed to use instance variable
                if ("NONE".equals(status)) {
                    friendDAO.sendFriendRequest(currentUser.getUserId(), targetUserId); // Changed to use instance variable
                } else if ("REQUEST_SENT".equals(status)) {
                    // If already sent, maybe cancel it? (Optional)
                    friendDAO.deleteFriendRequest(currentUser.getUserId(), targetUserId); // Changed to use instance variable
                }
            } else {
                // Public account or already following (unfollow), use direct toggle
                followDAO.toggleFollow(currentUser.getUserId(), targetUserId);
            }
        }

        String referer = request.getHeader("Referer");
        if (referer != null) {
            response.sendRedirect(referer);
        } else {
            response.sendRedirect("ProfileServlet?id=" + targetUserId);
        }
    }
}
