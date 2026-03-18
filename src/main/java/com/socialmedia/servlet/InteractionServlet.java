package com.socialmedia.servlet;

import com.socialmedia.dao.CommentDAO;
import com.socialmedia.dao.PostDAO;
import com.socialmedia.dao.FriendDAO;
import com.socialmedia.dao.UserDAO;
import com.socialmedia.model.Comment;
import com.socialmedia.model.User;
import com.socialmedia.dao.NotificationDAO;
import com.socialmedia.model.Notification;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.io.PrintWriter;

@WebServlet("/InteractionServlet")
public class InteractionServlet extends HttpServlet {

    private PostDAO postDAO;
    private CommentDAO commentDAO;
    private com.socialmedia.dao.FollowDAO followDAO;
    private FriendDAO friendDAO;
    private UserDAO userDAO;
    private com.socialmedia.dao.MessageDAO messageDAO;
    private NotificationDAO notificationDAO;

    @Override
    public void init() {
        postDAO = new PostDAO();
        commentDAO = new CommentDAO();
        followDAO = new com.socialmedia.dao.FollowDAO();
        friendDAO = new FriendDAO();
        userDAO = new UserDAO();
        messageDAO = new com.socialmedia.dao.MessageDAO();
        notificationDAO = new NotificationDAO();
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
        String action = request.getParameter("action");
        
        if ("like".equals(action)) {
            int postId = Integer.parseInt(request.getParameter("postId"));
            boolean isLiked = postDAO.toggleLike(postId, currentUser.getUserId());
            
            // Return simple JSON response
            response.setContentType("application/json");
            PrintWriter out = response.getWriter();
            out.print("{\"liked\": " + isLiked + "}");
            out.flush();
            
        } else if ("pin".equals(action)) {
            int postId = Integer.parseInt(request.getParameter("postId"));
            String result = postDAO.togglePin(postId, currentUser.getUserId());
            
            response.setContentType("application/json");
            PrintWriter out = response.getWriter();
            out.print("{\"status\": \"" + result + "\"}");
            out.flush();

        } else if ("checkPendingRequests".equals(action)) {
            int friendRequests = friendDAO.getPendingRequestsCount(currentUser.getUserId());
            int unreadMessages = new com.socialmedia.dao.MessageDAO().getUnreadCount(currentUser.getUserId());
            int unreadNotifications = notificationDAO.getUnreadCount(currentUser.getUserId());
            response.setContentType("application/json");
            PrintWriter out = response.getWriter();
            out.print("{\"count\": " + (friendRequests + unreadMessages + unreadNotifications) + ", \"friendRequests\": " + friendRequests + ", \"unreadMessages\": " + unreadMessages + ", \"unreadNotifications\": " + unreadNotifications + "}");
            out.flush();
            
        } else if ("getLikers".equals(action)) {
            int postId = Integer.parseInt(request.getParameter("postId"));
            java.util.List<com.socialmedia.model.User> likers = postDAO.getLikersForPost(postId);
            
            response.setContentType("application/json");
            PrintWriter out = response.getWriter();
            out.print("[");
            for (int i = 0; i < likers.size(); i++) {
                com.socialmedia.model.User u = likers.get(i);
                String p = u.getProfilePhoto() != null ? u.getProfilePhoto() : "images/default-avatar.png";
                out.print("{\"userId\": " + u.getUserId() + ", \"name\": \"" + u.getName() + "\", \"username\": \"" + u.getUsername() + "\", \"photo\": \"" + p + "\"}");
                if (i < likers.size() - 1) out.print(",");
            }
            out.print("]");
            out.flush();

        } else if ("getLikeCounts".equals(action)) {
            String postIdsParam = request.getParameter("postIds");
            response.setContentType("application/json");
            PrintWriter out = response.getWriter();
            out.print("{");
            if (postIdsParam != null && !postIdsParam.trim().isEmpty()) {
                String[] ids = postIdsParam.split(",");
                for (int i = 0; i < ids.length; i++) {
                    try {
                        int pid = Integer.parseInt(ids[i].trim());
                        int count = postDAO.getLikeCount(pid);
                        out.print("\"" + pid + "\":" + count);
                        if (i < ids.length - 1) out.print(",");
                    } catch (NumberFormatException ignored) {}
                }
            }
            out.print("}");
            out.flush();

        } else if ("getFollowers".equals(action)) {
            int targetId = Integer.parseInt(request.getParameter("targetId"));
            User targetUser = userDAO.getUserById(targetId);
            boolean isSelf = (currentUser.getUserId() == targetId);
            boolean isMutual = followDAO.isMutualFollowing(currentUser.getUserId(), targetId);
            
            if (isSelf || !targetUser.isPrivateAccount() || isMutual) {
                java.util.List<com.socialmedia.model.User> users = followDAO.getFollowers(targetId);
                sendUserListJson(response, users);
            } else {
                response.getWriter().write("[]");
            }
            
        } else if ("getFollowing".equals(action)) {
            int targetId = Integer.parseInt(request.getParameter("targetId"));
            User targetUser = userDAO.getUserById(targetId);
            boolean isSelf = (currentUser.getUserId() == targetId);
            boolean isMutual = followDAO.isMutualFollowing(currentUser.getUserId(), targetId);
            
            if (isSelf || !targetUser.isPrivateAccount() || isMutual) {
                java.util.List<com.socialmedia.model.User> users = followDAO.getFollowing(targetId);
                sendUserListJson(response, users);
            } else {
                response.getWriter().write("[]");
            }

        } else if ("comment".equals(action)) {
            int postId = Integer.parseInt(request.getParameter("postId"));
            String commentText = request.getParameter("commentText");
            
            if (commentText != null && !commentText.trim().isEmpty()) {
                Comment comment = new Comment();
                comment.setPostId(postId);
                comment.setUserId(currentUser.getUserId());
                comment.setCommentText(commentText);
                commentDAO.addComment(comment);
            }
            
            // For simplicity, just redirect back
            String referer = request.getHeader("Referer");
            if (referer != null) {
                response.sendRedirect(referer);
            } else {
                response.sendRedirect("FeedServlet");
            }
        } else if ("deleteComment".equals(action)) {
            String commentIdStr = request.getParameter("commentId");
            boolean success = false;
            
            if (commentIdStr != null) {
                try {
                    int commentId = Integer.parseInt(commentIdStr);
                    success = commentDAO.deleteComment(commentId);
                } catch (NumberFormatException e) {
                    e.printStackTrace();
                }
            }
            
            response.setContentType("application/json");
            PrintWriter out = response.getWriter();
            out.print("{\"success\": " + success + "}");
            out.flush();
        } else if ("getPostDetail".equals(action)) {
            int postId = Integer.parseInt(request.getParameter("postId"));
            com.socialmedia.model.Post post = postDAO.getPostById(postId, currentUser.getUserId());
            if (post != null) {
                post.setComments(commentDAO.getCommentsByPostId(postId));
                
                response.setContentType("application/json");
                PrintWriter out = response.getWriter();
                // Minimal JSON manual building (better to use Gson but we don't have it explicitly shown in lib, 
                // using manual for safety with existing code style)
                out.print("{");
                out.print("\"postId\": " + post.getPostId() + ",");
                out.print("\"userId\": " + post.getUserId() + ",");
                out.print("\"userName\": \"" + post.getUserName() + "\",");
                out.print("\"userHandle\": \"" + post.getUserHandle() + "\",");
                out.print("\"userPhoto\": \"" + (post.getUserPhoto() != null ? post.getUserPhoto() : "images/default-avatar.png") + "\",");
                out.print("\"postContent\": \"" + post.getPostContent().replace("\"", "\\\"").replace("\n", "\\n") + "\",");
                out.print("\"likeCount\": " + post.getLikeCount() + ",");
                out.print("\"commentCount\": " + post.getCommentCount() + ",");
                out.print("\"likedByCurrentUser\": " + post.isLikedByCurrentUser() + ",");
                out.print("\"isPinned\": " + post.isPinned() + ",");
                
                // Images
                out.print("\"images\": [");
                for (int i = 0; i < post.getImages().size(); i++) {
                    out.print("\"" + post.getImages().get(i) + "\"");
                    if (i < post.getImages().size() - 1) out.print(",");
                }
                out.print("],");
                
                // Comments
                out.print("\"comments\": [");
                for (int i = 0; i < post.getComments().size(); i++) {
                    com.socialmedia.model.Comment c = post.getComments().get(i);
                    out.print("{");
                    out.print("\"commentId\": " + c.getCommentId() + ",");
                    out.print("\"userName\": \"" + c.getUserName() + "\",");
                    out.print("\"userId\": " + c.getUserId() + ",");
                    out.print("\"userPhoto\": \"" + (c.getUserPhoto() != null ? c.getUserPhoto() : "images/default-avatar.png") + "\",");
                    out.print("\"commentText\": \"" + c.getCommentText().replace("\"", "\\\"").replace("\n", "\\n") + "\"");
                    out.print("}");
                    if (i < post.getComments().size() - 1) out.print(",");
                }
                out.print("]");
                out.print("}");
                out.flush();
            }
        } else if ("react".equals(action)) {
            int postId = Integer.parseInt(request.getParameter("postId"));
            String emoji = request.getParameter("emoji");
            boolean reacted = postDAO.toggleReaction(postId, currentUser.getUserId(), emoji);
            
            response.setContentType("application/json");
            PrintWriter out = response.getWriter();
            out.print("{\"reacted\": " + reacted + "}");
            out.flush();
        } else if ("getReactions".equals(action)) {
            int postId = Integer.parseInt(request.getParameter("postId"));
            java.util.List<String> reactions = postDAO.getReactionsForPost(postId);
            
            response.setContentType("application/json");
            PrintWriter out = response.getWriter();
            out.print("[");
            for (int i = 0; i < reactions.size(); i++) {
                String[] parts = reactions.get(i).split(":");
                out.print("{\"emoji\": \"" + parts[0] + "\", \"count\": " + parts[1] + "}");
                if (i < reactions.size() - 1) out.print(",");
            }
            out.print("]");
            out.flush();
        } else if ("reactMessage".equals(action)) {
            int messageId = Integer.parseInt(request.getParameter("messageId"));
            String emoji = request.getParameter("emoji");
            boolean reacted = messageDAO.toggleMessageReaction(messageId, currentUser.getUserId(), emoji);
            
            response.setContentType("application/json");
            PrintWriter out = response.getWriter();
            out.print("{\"reacted\": " + reacted + "}");
            out.flush();
        } else if ("getMessageReactions".equals(action)) {
            int messageId = Integer.parseInt(request.getParameter("messageId"));
            java.util.List<String> reactions = messageDAO.getMessageReactions(messageId);
            
            response.setContentType("application/json");
            PrintWriter out = response.getWriter();
            out.print("[");
            for (int i = 0; i < reactions.size(); i++) {
                String[] parts = reactions.get(i).split(":");
                out.print("{\"emoji\": \"" + parts[0] + "\", \"count\": " + parts[1] + "}");
                if (i < reactions.size() - 1) out.print(",");
            }
            out.print("]");
            out.flush();
        } else if ("getPendingFriendRequests".equals(action)) {
            // Keeping for backwards compatibility if needed, but we now use getNotifications
            java.util.List<com.socialmedia.model.Friend> pending = friendDAO.getPendingRequests(currentUser.getUserId());
            response.setContentType("application/json");
            PrintWriter out = response.getWriter();
            out.print("[");
            for (int i = 0; i < pending.size(); i++) {
                com.socialmedia.model.Friend f = pending.get(i);
                String p = f.getFriendPhoto() != null ? f.getFriendPhoto() : "images/default-avatar.png";
                out.print("{");
                out.print("\"senderId\": " + f.getFriendId() + ",");
                out.print("\"name\": \"" + f.getFriendName() + "\",");
                out.print("\"photo\": \"" + p + "\"");
                out.print("}");
                if (i < pending.size() - 1) out.print(",");
            }
            out.print("]");
            out.flush();
        } else if ("getNotifications".equals(action)) {
            java.util.List<Notification> notifications = notificationDAO.getRecentNotifications(currentUser.getUserId());
            response.setContentType("application/json");
            PrintWriter out = response.getWriter();
            out.print("[");
            for (int i = 0; i < notifications.size(); i++) {
                Notification n = notifications.get(i);
                String p = n.getActorPhoto() != null ? n.getActorPhoto() : "images/default-avatar.png";
                out.print("{");
                out.print("\"id\": " + n.getId() + ",");
                out.print("\"actorId\": " + n.getActorId() + ",");
                out.print("\"actorName\": \"" + n.getActorName().replace("\"", "\\\"") + "\",");
                out.print("\"actorPhoto\": \"" + p + "\",");
                out.print("\"type\": \"" + n.getType() + "\",");
                out.print("\"targetId\": " + (n.getTargetId() != null ? n.getTargetId() : "null") + ",");
                out.print("\"isRead\": " + n.isRead() + ",");
                out.print("\"time\": \"" + n.getCreatedAt().toString() + "\"");
                out.print("}");
                if (i < notifications.size() - 1) out.print(",");
            }
            out.print("]");
            out.flush();
        } else if ("markNotificationsRead".equals(action)) {
            boolean success = notificationDAO.markAllAsRead(currentUser.getUserId());
            response.setContentType("application/json");
            PrintWriter out = response.getWriter();
            out.print("{\"success\": " + success + "}");
            out.flush();
        } else if ("getAcceptedFriends".equals(action)) {
            java.util.List<com.socialmedia.model.Friend> friends = friendDAO.getAcceptedFriends(currentUser.getUserId());
            response.setContentType("application/json");
            PrintWriter out = response.getWriter();
            out.print("[");
            for (int i = 0; i < friends.size(); i++) {
                com.socialmedia.model.Friend f = friends.get(i);
                String p = f.getFriendPhoto() != null ? f.getFriendPhoto() : "images/default-avatar.png";
                out.print("{");
                out.print("\"id\": " + f.getFriendId() + ",");
                out.print("\"name\": \"" + f.getFriendName().replace("\"", "\\\"") + "\",");
                out.print("\"photo\": \"" + p + "\"");
                out.print("}");
                if (i < friends.size() - 1) out.print(",");
            }
            out.print("]");
            out.flush();
        }
    }

    private void sendUserListJson(HttpServletResponse response, java.util.List<com.socialmedia.model.User> users) throws IOException {
        response.setContentType("application/json");
        PrintWriter out = response.getWriter();
        out.print("[");
        for (int i = 0; i < users.size(); i++) {
            com.socialmedia.model.User u = users.get(i);
            String photo = u.getProfilePhoto() != null ? u.getProfilePhoto() : "images/default-avatar.png";
            out.print("{\"userId\": " + u.getUserId() + ", \"name\": \"" + u.getName() + "\", \"username\": \"" + u.getUsername() + "\", \"photo\": \"" + photo + "\"}");
            if (i < users.size() - 1) out.print(",");
        }
        out.print("]");
        out.flush();
    }
}
