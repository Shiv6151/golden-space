package com.socialmedia.servlet;

import com.socialmedia.dao.CommentDAO;
import com.socialmedia.dao.PostDAO;
import com.socialmedia.dao.UserDAO;
import com.socialmedia.model.Post;
import com.socialmedia.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;

@WebServlet("/FeedServlet")
public class FeedServlet extends HttpServlet {

    private PostDAO postDAO;
    private CommentDAO commentDAO;
    private UserDAO userDAO;

    @Override
    public void init() {
        postDAO = new PostDAO();
        commentDAO = new CommentDAO();
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
        
        // Fetch posts for the news feed
        List<Post> feedPosts = postDAO.getFeedPosts(currentUser.getUserId());
        
        // Populate comments for each post
        if (feedPosts != null) {
            for (Post post : feedPosts) {
                post.setComments(commentDAO.getCommentsByPostId(post.getPostId()));
            }
        }
        
        request.setAttribute("feedPosts", feedPosts);

        // Fetch suggested users ("People You May Know")
        List<User> suggestedUsers = userDAO.getSuggestedUsers(currentUser.getUserId(), 8);
        request.setAttribute("suggestedUsers", suggestedUsers);

        request.getRequestDispatcher("feed.jsp").forward(request, response);
    }
}
