package com.socialmedia.servlet;

import com.socialmedia.dao.PostDAO;
import com.socialmedia.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

@WebServlet("/DeletePostServlet")
public class DeletePostServlet extends HttpServlet {

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
        int postId = Integer.parseInt(request.getParameter("postId"));

        postDAO.deletePost(postId, currentUser.getUserId());

        String referer = request.getHeader("Referer");
        if (referer != null) {
            response.sendRedirect(referer);
        } else {
            response.sendRedirect("ProfileServlet?id=" + currentUser.getUserId());
        }
    }
}
