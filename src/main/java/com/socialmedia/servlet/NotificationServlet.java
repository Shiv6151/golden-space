package com.socialmedia.servlet;

import com.socialmedia.dao.NotificationDAO;
import com.socialmedia.model.Notification;
import com.socialmedia.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import com.socialmedia.util.DBConnection;

@WebServlet("/NotificationServlet")
public class NotificationServlet extends HttpServlet {

    private NotificationDAO notificationDAO;

    @Override
    public void init() {
        notificationDAO = new NotificationDAO();
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
        int userId = currentUser.getUserId();

        // Fetch ALL notifications (not just last 24hr)
        List<Notification> notifications = getAllNotifications(userId);
        
        // Mark all as read
        notificationDAO.markAllAsRead(userId);

        request.setAttribute("notifications", notifications);
        request.getRequestDispatcher("notifications.jsp").forward(request, response);
    }

    private List<Notification> getAllNotifications(int userId) {
        List<Notification> notifications = new ArrayList<>();
        String query = "SELECT n.*, u.username as actor_name, u.name as actor_fullname, " +
                       "u.profile_photo as actor_photo, u.user_id as actor_user_id " +
                       "FROM Notifications n " +
                       "JOIN Users u ON n.actor_id = u.user_id " +
                       "WHERE n.user_id = ? " +
                       "ORDER BY n.created_at DESC LIMIT 100";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(query)) {
            stmt.setInt(1, userId);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    Notification n = new Notification();
                    n.setId(rs.getInt("id"));
                    n.setUserId(rs.getInt("user_id"));
                    n.setActorId(rs.getInt("actor_user_id"));
                    n.setActorName(rs.getString("actor_name"));
                    n.setActorPhoto(rs.getString("actor_photo"));
                    n.setType(rs.getString("type"));
                    int targetId = rs.getInt("target_id");
                    if (!rs.wasNull()) n.setTargetId(targetId);
                    n.setCreatedAt(rs.getTimestamp("created_at"));
                    n.setRead(rs.getBoolean("is_read"));
                    // Store fullname in actorName field with format "username|fullname"
                    String fullname = rs.getString("actor_fullname");
                    n.setActorName(rs.getString("actor_name") + "|" + (fullname != null ? fullname : ""));
                    notifications.add(n);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return notifications;
    }
}
