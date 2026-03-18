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
import java.util.List;

@WebServlet("/SearchServlet")
public class SearchServlet extends HttpServlet {

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
        String query = request.getParameter("query");
        if (query != null && !query.trim().isEmpty()) {
            List<User> searchResults = userDAO.searchUsersByName(query, currentUser.getUserId());
            request.setAttribute("searchResults", searchResults);
            
            com.socialmedia.dao.PostDAO postDAO = new com.socialmedia.dao.PostDAO();
            java.util.List<com.socialmedia.model.Post> postResults = postDAO.searchPostsByHashtag(query, currentUser.getUserId());
            request.setAttribute("postResults", postResults);
            
            request.setAttribute("searchQuery", query);
        }

        request.getRequestDispatcher("search.jsp").forward(request, response);
    }
}
