package com.socialmedia.servlet;

import com.socialmedia.dao.UserDAO;
import com.socialmedia.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

@WebServlet("/LoginServlet")
public class LoginServlet extends HttpServlet {

    private UserDAO userDAO;

    @Override
    public void init() {
        userDAO = new UserDAO();
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
            
        String email = request.getParameter("email");
        String password = request.getParameter("password");
        
        // Validation
        if(email == null || password == null || email.trim().isEmpty() || password.trim().isEmpty()) {
            request.setAttribute("errorMsg", "Email and Password are required.");
            request.getRequestDispatcher("login.jsp").forward(request, response);
            return;
        }
        
        User user = userDAO.authenticateUser(email, password);

        if (user != null) {
            // Authentication successful, start session
            request.getSession().setAttribute("user", user);
            // Redirect to the news feed
            response.sendRedirect("FeedServlet");
        } else {
            // Authentication failed
            request.setAttribute("errorMsg", "Invalid email or password.");
            request.getRequestDispatcher("login.jsp").forward(request, response);
        }
    }
}
