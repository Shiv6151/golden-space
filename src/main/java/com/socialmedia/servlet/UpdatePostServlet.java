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
import java.io.IOException;

@WebServlet("/UpdatePostServlet")
@MultipartConfig(fileSizeThreshold = 1024 * 1024 * 2, // 2MB
                 maxFileSize = 1024 * 1024 * 10,      // 10MB
                 maxRequestSize = 1024 * 1024 * 50)   // 50MB
public class UpdatePostServlet extends HttpServlet {

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
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            return;
        }

        User currentUser = (User) session.getAttribute("user");
        int postId = Integer.parseInt(request.getParameter("postId"));
        String newContent = request.getParameter("content");
        String aspectRatio = request.getParameter("aspectRatio");

        // Handle images
        java.util.List<String> imageUrls = new java.util.ArrayList<>();
        try {
            java.util.Collection<jakarta.servlet.http.Part> parts = request.getParts();
            for (jakarta.servlet.http.Part part : parts) {
                if (part.getName().equals("imageFiles") && part.getSize() > 0) {
                    if (com.socialmedia.util.CloudinaryUtil.isConfigured()) {
                        String cloudUrl = com.socialmedia.util.CloudinaryUtil.upload(part);
                        if (cloudUrl != null) imageUrls.add(cloudUrl);
                    } else {
                        String fileName = part.getSubmittedFileName();
                        String uniqueFileName = java.util.UUID.randomUUID().toString() + "_" + (fileName != null ? fileName : "adjusted.jpg");
                        String uploadPath = getServletContext().getRealPath("") + java.io.File.separator + "uploads";
                        java.io.File uploadDir = new java.io.File(uploadPath);
                        if (!uploadDir.exists()) uploadDir.mkdir();
                        String filePath = uploadPath + java.io.File.separator + uniqueFileName;
                        part.write(filePath);
                        imageUrls.add("uploads/" + uniqueFileName);
                    }
                } else if (part.getName().equals("existingImages")) {
                    try (java.io.BufferedReader reader = new java.io.BufferedReader(new java.io.InputStreamReader(part.getInputStream()))) {
                        String path = reader.readLine();
                        if (path != null && !path.isEmpty()) {
                            imageUrls.add(path);
                        }
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        Post post = new Post();
        post.setPostId(postId);
        post.setUserId(currentUser.getUserId());
        post.setPostContent(newContent != null ? newContent : "");
        post.setAspectRatio(aspectRatio != null ? aspectRatio : "16/9");
        post.setImages(imageUrls);

        boolean success = postDAO.updatePost(post);

        if ("XMLHttpRequest".equals(request.getHeader("X-Requested-With"))) {
            response.setContentType("text/plain");
            response.getWriter().write(success ? "success" : "error");
        } else {
            String referer = request.getHeader("Referer");
            if (referer != null) {
                response.sendRedirect(referer);
            } else {
                response.sendRedirect("ProfileServlet?id=" + currentUser.getUserId());
            }
        }
    }
}
