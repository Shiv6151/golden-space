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
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect("login.jsp");
            return;
        }
        User currentUser = (User) session.getAttribute("user");
        int totalSeconds = userDAO.getTimeSpent(currentUser.getUserId());
        request.setAttribute("timeSpentSeconds", totalSeconds);
        request.getRequestDispatcher("settings.jsp").forward(request, response);
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
        } else if ("sendOtp".equals(action)) {
            String otp = String.format("%06d", new java.util.Random().nextInt(999999));
            session.setAttribute("passwordResetOtp", otp);
            session.setAttribute("passwordResetOtpTime", System.currentTimeMillis());
            
            String toEmail = currentUser.getEmail();
            if (toEmail == null || toEmail.trim().isEmpty()) {
                response.setContentType("application/json");
                response.getWriter().write("{\"success\": false, \"message\": \"No email address associated with your account.\"}");
                return;
            }
            
            boolean emailSent = sendEmailOtp(toEmail, otp);
            System.out.println("OTP for password reset requested by user " + currentUser.getUserId() + ": " + otp);
            
            response.setContentType("application/json");
            if (emailSent) {
                response.getWriter().write("{\"success\": true}");
            } else {
                // Return success if email fails, but provide a message with the OTP for development purposes
                response.getWriter().write("{\"success\": true, \"message\": \"Development Mode: SMTP not configured. OTP: " + otp + "\"}");
            }
        } else if ("verifyOtp".equals(action)) {
            String inputOtp = request.getParameter("otp");
            String sessionOtp = (String) session.getAttribute("passwordResetOtp");
            Long otpTime = (Long) session.getAttribute("passwordResetOtpTime");
            
            response.setContentType("application/json");
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
        } else if ("resetPasswordWithOtp".equals(action)) {
            response.setContentType("application/json");
            Boolean verified = (Boolean) session.getAttribute("otpVerified");
            if (verified != null && verified) {
                String newPassword = request.getParameter("newPassword");
                if (userDAO.updatePassword(currentUser.getUserId(), newPassword)) {
                    currentUser.setPassword(newPassword);
                    session.setAttribute("user", currentUser);
                    session.removeAttribute("passwordResetOtp");
                    session.removeAttribute("passwordResetOtpTime");
                    session.removeAttribute("otpVerified");
                    response.getWriter().write("{\"success\": true}");
                } else {
                    response.getWriter().write("{\"success\": false, \"message\": \"Server error updating password.\"}");
                }
            } else {
                response.getWriter().write("{\"success\": false, \"message\": \"Unauthorized request. Please verify OTP first.\"}");
            }
        } else if ("getBlockedUsers".equals(action)) {
            response.setContentType("application/json");
            java.util.List<User> blocked = userDAO.getBlockedUsers(currentUser.getUserId());
            StringBuilder json = new StringBuilder("[");
            for (int i = 0; i < blocked.size(); i++) {
                User u = blocked.get(i);
                String profilePhoto = u.getProfilePhoto() != null ? u.getProfilePhoto() : "images/default-avatar.png";
                json.append(String.format("{\"id\":%d, \"name\":\"%s\", \"username\":\"%s\", \"photo\":\"%s\"}", 
                    u.getUserId(), u.getName(), u.getUsername(), profilePhoto));
                if (i < blocked.size() - 1) json.append(",");
            }
            json.append("]");
            response.getWriter().write(json.toString());
        } else if ("unblockUser".equals(action)) {
            int targetId = Integer.parseInt(request.getParameter("targetId"));
            if (userDAO.unblockUser(currentUser.getUserId(), targetId)) {
                response.getWriter().write("success");
            } else {
                response.getWriter().write("error");
            }
        }
    }

    private boolean sendEmailOtp(String toAddress, String otp) {
        String host = "smtp.gmail.com";
        String from = "your-email@gmail.com"; 
        String pass = "your-app-password"; 
        
        java.util.Properties properties = System.getProperties();
        properties.put("mail.smtp.host", host);
        properties.put("mail.smtp.port", "465");
        properties.put("mail.smtp.ssl.enable", "true");
        properties.put("mail.smtp.auth", "true");
        // Add timeouts to prevent hanging
        properties.put("mail.smtp.connectiontimeout", "5000"); // 5s
        properties.put("mail.smtp.timeout", "5000"); // 5s
        properties.put("mail.smtp.writetimeout", "5000"); // 5s
        
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
            System.err.println("SMTP Email failed: " + mex.getMessage());
            return false;
        }
    }
}
