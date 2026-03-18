package com.socialmedia.servlet;

import com.socialmedia.dao.UserDAO;
import com.socialmedia.util.EmailSender;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.Random;

@WebServlet("/RegisterServlet")
public class RegisterServlet extends HttpServlet {

    private UserDAO userDAO;

    @Override
    public void init() {
        userDAO = new UserDAO();
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
            
        String name = request.getParameter("name");
        String username = request.getParameter("username");
        String email = request.getParameter("email");
        String password = request.getParameter("password");

        // Validate Gmail
        if (email == null || !email.toLowerCase().endsWith("@gmail.com")) {
            request.setAttribute("error", "Only @gmail.com addresses are allowed.");
            request.getRequestDispatcher("register.jsp").forward(request, response);
            return;
        }

        // Validate Unique Username and Email
        if (userDAO.isUsernameTaken(username)) {
            request.setAttribute("error", "Username is already taken.");
            request.getRequestDispatcher("register.jsp").forward(request, response);
            return;
        }
        if (userDAO.isEmailTaken(email)) {
            request.setAttribute("error", "Email is already registered.");
            request.getRequestDispatcher("register.jsp").forward(request, response);
            return;
        }

        // Generate 6-digit OTP
        String otp = String.format("%06d", new Random().nextInt(999999));

        // Save OTP request
        boolean saved = userDAO.saveOtpRequest(name, username, email, password, otp);
        if (saved) {
            boolean emailSent = EmailSender.sendOtpEmail(email, otp);
            if (emailSent) {
                request.getSession().setAttribute("verifyEmail", email);
                response.sendRedirect("otp_verify.jsp");
                return;
            } else {
                request.setAttribute("error", "Failed to send OTP email. Try again later.");
            }
        } else {
            request.setAttribute("error", "Registration failed. Please try again.");
        }
        
        request.getRequestDispatcher("register.jsp").forward(request, response);
    }
}
