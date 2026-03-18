package com.socialmedia.servlet;

import com.socialmedia.dao.UserDAO;
import com.socialmedia.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import jakarta.servlet.http.Part;
import java.io.File;
import java.io.IOException;
import java.util.UUID;

@WebServlet("/EditProfileServlet")
@MultipartConfig(fileSizeThreshold = 1024 * 1024 * 2, // 2MB
                 maxFileSize = 1024 * 1024 * 10,      // 10MB
                 maxRequestSize = 1024 * 1024 * 50)   // 50MB
public class EditProfileServlet extends HttpServlet {

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
            response.sendRedirect("login.jsp");
            return;
        }

        User currentUser = (User) session.getAttribute("user");
        String name = request.getParameter("name");
        String bio = request.getParameter("bio");

        String photoUrl = currentUser.getProfilePhoto(); // Default to existing

        try {
            Part filePart = request.getPart("profilePhoto");
            if (filePart != null && filePart.getSize() > 0) {
                if (com.socialmedia.util.CloudinaryUtil.isConfigured()) {
                    String cloudUrl = com.socialmedia.util.CloudinaryUtil.upload(filePart);
                    if (cloudUrl != null) photoUrl = cloudUrl;
                } else {
                    String fileName = filePart.getSubmittedFileName();
                    String uniqueFileName = UUID.randomUUID().toString() + "_" + fileName;
                    String uploadPath = getServletContext().getRealPath("") + File.separator + "uploads";
                    File uploadDir = new File(uploadPath);
                    if (!uploadDir.exists()) uploadDir.mkdir();
                    String filePath = uploadPath + File.separator + uniqueFileName;
                    filePart.write(filePath);
                    photoUrl = "uploads/" + uniqueFileName;
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        currentUser.setName(name);
        currentUser.setBio(bio);
        currentUser.setProfilePhoto(photoUrl);

        userDAO.updateUserProfile(currentUser);
        
        // Update the session user
        session.setAttribute("user", currentUser);

        response.sendRedirect("ProfileServlet?id=" + currentUser.getUserId());
    }
}
