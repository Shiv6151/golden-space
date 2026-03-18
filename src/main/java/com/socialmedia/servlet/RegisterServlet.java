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
            request.setAttribute("errorMsg", "Only @gmail.com addresses are allowed.");
            request.getRequestDispatcher("register.jsp").forward(request, response);
            return;
        }

        // Validate Unique Username and Email
        if (userDAO.isUsernameTaken(username)) {
            request.setAttribute("errorMsg", "Username is already taken.");
            request.getRequestDispatcher("register.jsp").forward(request, response);
            return;
        }
        if (userDAO.isEmailTaken(email)) {
            request.setAttribute("errorMsg", "Email is already registered.");
            request.getRequestDispatcher("register.jsp").forward(request, response);
            return;
        }

        // Generate 6-digit OTP
        String otp = String.format("%06d", new Random().nextInt(999999));

        // Save OTP request
        System.out.println("DEBUG: Saving OTP request to DB...");
        getServletContext().log("DEBUG: Saving OTP request to DB...");
        
        try {
            boolean saved = userDAO.saveOtpRequest(name, username, email, password, otp);
            if (saved) {
                System.out.println("DEBUG: OTP request saved. Sending email...");
                getServletContext().log("DEBUG: OTP request saved. Sending email...");
                
                boolean emailSent = EmailSender.sendOtpEmail(email, otp, getServletContext());
                if (emailSent) {
                    System.out.println("DEBUG: Email sent! Redirecting...");
                    request.getSession().setAttribute("verifyEmail", email);
                    response.sendRedirect("otp_verify.jsp");
                    return;
                } else {
                    // CLOUD BYPASS: If email is blocked, show the OTP directly for testing
                    request.setAttribute("errorMsg", "Email Blocked by Render Free Tier. YOUR TEST OTP IS: " + otp + " (Please use this code to verify)");
                    request.getSession().setAttribute("verifyEmail", email);
                }
            } else {
                request.setAttribute("errorMsg", "Database timeout (10s) or TiDB Connection error.");
            }
        } catch (Exception e) {
            getServletContext().log("CRITICAL ERROR in RegisterServlet", e);
            request.setAttribute("errorMsg", "System Error: " + e.getMessage());
        }
        
        request.getRequestDispatcher("register.jsp").forward(request, response);
    }
}
