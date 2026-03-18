package com.socialmedia.servlet;

import com.socialmedia.dao.PostDAO;
import com.socialmedia.model.Post;
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

@WebServlet("/PostServlet")
@MultipartConfig(fileSizeThreshold = 1024 * 1024 * 2, // 2MB
                 maxFileSize = 1024 * 1024 * 10,      // 10MB
                 maxRequestSize = 1024 * 1024 * 50)   // 50MB
public class PostServlet extends HttpServlet {

    private PostDAO postDAO;

    @Override
    public void init() {
        postDAO = new PostDAO();
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
        String content = request.getParameter("content");
        String aspectRatio = request.getParameter("aspectRatio");
        if (aspectRatio == null) aspectRatio = "16/9";
        
        // Handle multi-file upload
        java.util.List<String> imageUrls = new java.util.ArrayList<>();
        try {
            java.util.Collection<Part> parts = request.getParts();
            for (Part part : parts) {
                if (part.getName().equals("imageFiles") && part.getSize() > 0) {
                    if (com.socialmedia.util.CloudinaryUtil.isConfigured()) {
                        String cloudUrl = com.socialmedia.util.CloudinaryUtil.upload(part);
                        if (cloudUrl != null) {
                            imageUrls.add(cloudUrl);
                        }
                    } else {
                        // Fallback to local if not configured (for development)
                        String fileName = part.getSubmittedFileName();
                        String uniqueFileName = UUID.randomUUID().toString() + "_" + fileName;
                        String uploadPath = getServletContext().getRealPath("") + File.separator + "uploads";
                        File uploadDir = new File(uploadPath);
                        if (!uploadDir.exists()) uploadDir.mkdir();
                        String filePath = uploadPath + File.separator + uniqueFileName;
                        part.write(filePath);
                        imageUrls.add("uploads/" + uniqueFileName);
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        if ((content != null && !content.trim().isEmpty()) || !imageUrls.isEmpty()) {
            Post post = new Post();
            post.setUserId(currentUser.getUserId());
            post.setPostContent(content != null ? content : "");
            post.setImages(imageUrls);
            post.setAspectRatio(aspectRatio);
            postDAO.createPost(post);
        }

        response.sendRedirect("FeedServlet");
    }
}
