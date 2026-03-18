package com.socialmedia.servlet;

import com.socialmedia.dao.FriendDAO;
import com.socialmedia.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

@WebServlet("/FriendServlet")
public class FriendServlet extends HttpServlet {

    private FriendDAO friendDAO;

    @Override
    public void init() {
        friendDAO = new FriendDAO();
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
        java.util.List<com.socialmedia.model.Friend> pendingRequests = friendDAO.getPendingRequests(currentUser.getUserId());
        
        request.setAttribute("pendingRequests", pendingRequests);
        request.getRequestDispatcher("friend_requests.jsp").forward(request, response);
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
        int friendId = Integer.parseInt(request.getParameter("friendId"));

        if ("send".equals(action)) {
            friendDAO.sendFriendRequest(currentUser.getUserId(), friendId);
        } else if ("accept".equals(action)) {
            // Note: The original sender is friendId, and the current user is the receiver
            friendDAO.updateFriendRequestStatus(friendId, currentUser.getUserId(), "ACCEPTED");
        } else if ("reject".equals(action)) {
            friendDAO.updateFriendRequestStatus(friendId, currentUser.getUserId(), "REJECTED");
        } else if ("remove".equals(action)) {
            friendDAO.deleteFriendRequest(currentUser.getUserId(), friendId);
        }

        // Check if there is a referer to redirect back
        String referer = request.getHeader("Referer");
        if (referer != null) {
            response.sendRedirect(referer);
        } else {
            response.sendRedirect("ProfileServlet?id=" + friendId);
        }
    }
}
