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
import java.util.Properties;
import java.util.Random;

@WebServlet("/ForgotPasswordServlet")
public class ForgotPasswordServlet extends HttpServlet {
    private UserDAO userDAO;

    @Override
    public void init() {
        userDAO = new UserDAO();
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String action = request.getParameter("action");
        response.setContentType("application/json");

        if ("sendOtp".equals(action)) {
            String email = request.getParameter("email");
            User user = userDAO.getUserByEmail(email);
            
            if (user == null) {
                response.getWriter().write("{\"success\": false, \"message\": \"No account found with this email.\"}");
                return;
            }

            String otp = String.format("%06d", new Random().nextInt(999999));
            HttpSession session = request.getSession();
            session.setAttribute("resetEmail", email);
            session.setAttribute("resetOtp", otp);
            session.setAttribute("resetOtpTime", System.currentTimeMillis());
            
            boolean emailSent = sendEmailOtp(email, otp);
            System.out.println("Public Forgot Password OTP for " + email + ": " + otp);
            
            if (emailSent) {
                response.getWriter().write("{\"success\": true}");
            } else {
                response.getWriter().write("{\"success\": true, \"message\": \"Development Mode: SMTP not configured. OTP: " + otp + "\"}");
            }

        } else if ("verifyOtp".equals(action)) {
            String inputOtp = request.getParameter("otp");
            HttpSession session = request.getSession();
            String sessionOtp = (String) session.getAttribute("resetOtp");
            Long otpTime = (Long) session.getAttribute("resetOtpTime");
            
            if (sessionOtp != null && otpTime != null && sessionOtp.equals(inputOtp)) {
                if (System.currentTimeMillis() - otpTime > 5 * 60 * 1000) {
                    response.getWriter().write("{\"success\": false, \"message\": \"OTP expired.\"}");
                } else {
                    session.setAttribute("otpVerified", true);
                    response.getWriter().write("{\"success\": true}");
                }
            } else {
                response.getWriter().write("{\"success\": false, \"message\": \"Invalid OTP.\"}");
            }

        } else if ("resetPassword".equals(action)) {
            HttpSession session = request.getSession();
            Boolean verified = (Boolean) session.getAttribute("otpVerified");
            String email = (String) session.getAttribute("resetEmail");
            String newPassword = request.getParameter("password");

            if (verified != null && verified && email != null) {
                User user = userDAO.getUserByEmail(email);
                if (user != null && userDAO.updatePassword(user.getUserId(), newPassword)) {
                    session.invalidate();
                    response.getWriter().write("{\"success\": true}");
                } else {
                    response.getWriter().write("{\"success\": false, \"message\": \"Error updating password.\"}");
                }
            } else {
                response.getWriter().write("{\"success\": false, \"message\": \"Unauthorized. Verify OTP first.\"}");
            }
        }
    }

    private boolean sendEmailOtp(String toAddress, String otp) {
        String host = "smtp.gmail.com";
        String from = "your-email@gmail.com"; 
        String pass = "your-app-password"; 
        
        Properties properties = System.getProperties();
        properties.put("mail.smtp.host", host);
        properties.put("mail.smtp.port", "465");
        properties.put("mail.smtp.ssl.enable", "true");
        properties.put("mail.smtp.auth", "true");
        properties.put("mail.smtp.connectiontimeout", "5000");
        properties.put("mail.smtp.timeout", "5000");
        properties.put("mail.smtp.writetimeout", "5000");
        
        jakarta.mail.Session session = jakarta.mail.Session.getInstance(properties, new jakarta.mail.Authenticator() {
            protected jakarta.mail.PasswordAuthentication getPasswordAuthentication() {
                return new jakarta.mail.PasswordAuthentication(from, pass);
            }
        });
        
        try {
            jakarta.mail.internet.MimeMessage message = new jakarta.mail.internet.MimeMessage(session);
            message.setFrom(new jakarta.mail.internet.InternetAddress(from));
            message.addRecipient(jakarta.mail.Message.RecipientType.TO, new jakarta.mail.internet.InternetAddress(toAddress));
            message.setSubject("Your Golden Space Password Reset OTP");
            message.setText("Your OTP for resetting your password is: " + otp + "\n\nThis OTP is valid for 5 minutes.");
            jakarta.mail.Transport.send(message);
            return true;
        } catch (Exception mex) {
            return false;
        }
    }
}
