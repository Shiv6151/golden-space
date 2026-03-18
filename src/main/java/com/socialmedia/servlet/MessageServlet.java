package com.socialmedia.servlet;

import com.socialmedia.dao.FollowDAO;
import com.socialmedia.dao.FriendDAO;
import com.socialmedia.dao.MessageDAO;
import com.socialmedia.dao.NotificationDAO;
import com.socialmedia.dao.UserDAO;
import com.socialmedia.model.Friend;
import com.socialmedia.model.Message;
import com.socialmedia.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

@WebServlet("/MessageServlet")
@MultipartConfig(maxFileSize = 50 * 1024 * 1024) // 50MB max file size
public class MessageServlet extends HttpServlet {

    private MessageDAO messageDAO;
    private FollowDAO followDAO;
    private FriendDAO friendDAO;
    private UserDAO userDAO;
    private NotificationDAO notificationDAO;

    @Override
    public void init() {
        messageDAO = new MessageDAO();
        followDAO = new FollowDAO();
        friendDAO = new FriendDAO();
        userDAO = new UserDAO();
        notificationDAO = new NotificationDAO();
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
        
        // Fetch pending friend requests for top of sidebar
        List<Friend> pendingRequests = friendDAO.getPendingRequests(currentUser.getUserId());
        request.setAttribute("pendingRequests", pendingRequests);
        
        // Get list of friends to chat with
        List<User> friends = followDAO.getMutualFollowers(currentUser.getUserId());
        
        // Hydrate each friend's unreadCount so the JSP can use ${friend.unreadCount}
        java.util.Map<String, Integer> unreadCounts = messageDAO.getUnreadCountPerSender(currentUser.getUserId());
        for (User friend : friends) {
            Integer cnt = unreadCounts.get(String.valueOf(friend.getUserId()));
            if (cnt != null) friend.setUnreadCount(cnt);
        }
        request.setAttribute("friends", friends);
        
        // Check if there is a specific friend selected for chatting
        String withParam = request.getParameter("with");
        if (withParam != null && !withParam.trim().isEmpty()) {
            try {
                int chatUserId = Integer.parseInt(withParam);
                User chatUser = userDAO.getUserById(chatUserId);
                
                if (chatUser != null) {
                    messageDAO.markAsRead(currentUser.getUserId(), chatUserId);
                    List<Message> conversation = messageDAO.getConversation(currentUser.getUserId(), chatUserId);
                    request.setAttribute("chatUser", chatUser);
                    request.setAttribute("conversation", conversation);
                } else if (!"true".equals(request.getParameter("ajax"))) {
                    // Only redirect if not an AJAX call to avoid breaking polling
                    response.sendRedirect("MessageServlet?error=User not found");
                    return;
                }
            } catch (NumberFormatException e) {
                if (!"true".equals(request.getParameter("ajax"))) {
                    response.sendRedirect("MessageServlet?error=Invalid user ID");
                    return;
                }
            }
        }

        // Check if it's an AJAX polling request
        String isAjax = request.getParameter("ajax");
        String lastIdParam = request.getParameter("lastId");
        
        if ("true".equals(isAjax) && withParam != null && lastIdParam != null) {
            try {
                int chatUserId = Integer.parseInt(withParam);
                int lastId = Integer.parseInt(lastIdParam);
                List<Message> newMessages = messageDAO.getNewMessages(currentUser.getUserId(), chatUserId, lastId);
                
                response.setContentType("application/json");
                StringBuilder json = new StringBuilder("[");
                for (int i = 0; i < newMessages.size(); i++) {
                    Message m = newMessages.get(i);
                    String attachUrl = m.getAttachmentUrl() != null ? "\"" + m.getAttachmentUrl() + "\"" : "null";
                    String attachType = m.getAttachmentType() != null ? "\"" + m.getAttachmentType() + "\"" : "null";
                    String text = m.getMessageText() != null ? m.getMessageText().replace("\"", "\\\"").replace("\n", "\\n") : "";
                    
                    json.append("{")
                        .append("\"id\":").append(m.getMessageId()).append(",")
                        .append("\"senderId\":").append(m.getSenderId()).append(",")
                        .append("\"text\":\"").append(text).append("\",")
                        .append("\"attachmentUrl\":").append(attachUrl).append(",")
                        .append("\"attachmentType\":").append(attachType).append(",")
                        .append("\"time\":\"").append(m.getMessageTime()).append("\"")
                        .append("}");
                    if (i < newMessages.size() - 1) json.append(",");
                }
                json.append("]");
                response.getWriter().write(json.toString());
                return;
            } catch (Exception e) {
                response.setStatus(500);
                return;
            }
        }

        request.getRequestDispatcher("messages.jsp").forward(request, response);
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
        String action = request.getParameter("action");
        
        if ("clearChat".equals(action)) {
            int otherUserId = Integer.parseInt(request.getParameter("otherUserId"));
            messageDAO.clearConversation(currentUser.getUserId(), otherUserId);
            response.sendRedirect("MessageServlet?with=" + otherUserId);
            return;
        } else if ("deleteMessage".equals(action)) {
            int messageId = Integer.parseInt(request.getParameter("messageId"));
            int withUserId = Integer.parseInt(request.getParameter("withUserId"));
            messageDAO.deleteMessage(messageId, currentUser.getUserId());
            response.sendRedirect("MessageServlet?with=" + withUserId);
            return;
        }

        String messageText = request.getParameter("messageText");
        
        try {
            int receiverId = Integer.parseInt(request.getParameter("receiverId"));
            
            Message msg = new Message();
            msg.setSenderId(currentUser.getUserId());
            msg.setReceiverId(receiverId);
            msg.setMessageText(messageText);
            
            // Handle file upload
            jakarta.servlet.http.Part filePart = null;
            try {
                filePart = request.getPart("attachment");
            } catch (Exception e) {}
            
            if (filePart != null && filePart.getSize() > 0) {
                String contentType = filePart.getContentType();
                String type = "unknown";
                if (contentType != null) {
                    if (contentType.startsWith("image/")) type = "image";
                    else if (contentType.startsWith("video/")) type = "video";
                    else if (contentType.equals("application/pdf")) type = "pdf";
                }
                String url = com.socialmedia.util.CloudinaryUtil.upload(filePart);
                if (url != null) {
                    msg.setAttachmentUrl(url);
                    msg.setAttachmentType(type);
                }
            }
            
            if ((messageText != null && !messageText.trim().isEmpty()) || msg.getAttachmentUrl() != null) {
                messageDAO.sendMessage(msg);
                
                // If this is a post share, fire a SHARE notification for the receiver
                if (messageText != null) {
                    Pattern p = Pattern.compile("\\[POST_SHARE:(\\d+)\\]");
                    Matcher m = p.matcher(messageText);
                    if (m.find()) {
                        try {
                            int sharedPostId = Integer.parseInt(m.group(1));
                            notificationDAO.addNotification(receiverId, currentUser.getUserId(), "SHARE", sharedPostId);
                        } catch (NumberFormatException ignored) {}
                    }
                }
            }
            
            // If AJAX, we don't need to redirect
            if ("true".equals(request.getParameter("ajax"))) {
                response.setStatus(HttpServletResponse.SC_OK);
                return;
            }
            
            // Redirect back to conversation
            response.sendRedirect("MessageServlet?with=" + receiverId);
            
        } catch (NumberFormatException | NullPointerException e) {
            if (!"true".equals(request.getParameter("ajax"))) {
                response.sendRedirect("MessageServlet");
            } else {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            }
        }
    }
}

