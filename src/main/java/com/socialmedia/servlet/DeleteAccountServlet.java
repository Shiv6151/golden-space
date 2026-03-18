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

@WebServlet("/DeleteAccountServlet")
public class DeleteAccountServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");
        
        if (user != null) {
            UserDAO userDAO = new UserDAO();
            if (userDAO.deleteUserAccount(user.getUserId())) {
                session.invalidate();
                response.sendRedirect("login.jsp?message=Account deleted successfully");
                return;
            } else {
                response.sendRedirect("profile.jsp?id=" + user.getUserId() + "&error=Could not delete account. Please try again.");
            }
        } else {
            response.sendRedirect("login.jsp");
        }
    }
}
