package com.socialmedia.servlet;

import com.socialmedia.dao.UserDAO;
import com.socialmedia.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

@WebServlet("/SettingsServlet")
public class SettingsServlet extends HttpServlet {
    private UserDAO userDAO;

    @Override
    public void init() {
        userDAO = new UserDAO();
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendError(HttpServletResponse.SC_UNAUTHORIZED);
            return;
        }

        User currentUser = (User) session.getAttribute("user");
        String action = request.getParameter("action");

        if ("privacy".equals(action)) {
            boolean isPrivate = "true".equals(request.getParameter("isPrivate"));
            if (userDAO.updatePrivacy(currentUser.getUserId(), isPrivate)) {
                currentUser.setPrivateAccount(isPrivate);
                session.setAttribute("user", currentUser);
                response.getWriter().write("success");
            } else {
                response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            }
        } else if ("password".equals(action)) {
            String currentPassword = request.getParameter("currentPassword");
            String newPassword = request.getParameter("newPassword");

            if (!currentUser.getPassword().equals(currentPassword)) {
                response.getWriter().write("Incorrect current password.");
                return;
            }

            if (userDAO.updatePassword(currentUser.getUserId(), newPassword)) {
                currentUser.setPassword(newPassword);
                session.setAttribute("user", currentUser);
                response.getWriter().write("success");
            } else {
                response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            }
        } else if ("updatePostContent".equals(action)) {
            int postId = Integer.parseInt(request.getParameter("postId"));
            String content = request.getParameter("content");
            com.socialmedia.dao.PostDAO postDAO = new com.socialmedia.dao.PostDAO();
            if (postDAO.updatePostContent(postId, currentUser.getUserId(), content)) {
                response.getWriter().write("success");
            } else {
                response.getWriter().write("failed");
            }
        }
    }
}
