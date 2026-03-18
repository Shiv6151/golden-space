package com.socialmedia.servlet;

import com.socialmedia.dao.MessageDAO;
import com.socialmedia.model.Message;
import com.socialmedia.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.io.PrintWriter;
import java.text.SimpleDateFormat;
import java.util.List;

@WebServlet("/ExportChatServlet")
public class ExportChatServlet extends HttpServlet {

    private MessageDAO messageDAO;

    @Override
    public void init() {
        messageDAO = new MessageDAO();
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
        String withUserIdStr = request.getParameter("withUserId");
        String format = request.getParameter("format");

        if (withUserIdStr == null || format == null) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Missing parameters");
            return;
        }

        int withUserId = Integer.parseInt(withUserIdStr);
        List<Message> messages = messageDAO.getConversation(currentUser.getUserId(), withUserId);
        
        SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
        String filename = "chat_export_" + withUserId + "_" + System.currentTimeMillis();

        if ("txt".equalsIgnoreCase(format)) {
            response.setContentType("text/plain");
            response.setHeader("Content-Disposition", "attachment; filename=\"" + filename + ".txt\"");
            PrintWriter out = response.getWriter();
            for (Message msg : messages) {
                out.println("[" + sdf.format(msg.getMessageTime()) + "] " + msg.getSenderName() + ": " + msg.getMessageText());
            }
        } else if ("csv".equalsIgnoreCase(format)) {
            response.setContentType("text/csv");
            response.setHeader("Content-Disposition", "attachment; filename=\"" + filename + ".csv\"");
            PrintWriter out = response.getWriter();
            out.println("Date/Time,Sender,Message");
            for (Message msg : messages) {
                String text = msg.getMessageText().replace("\"", "\"\"");
                out.println("\"" + sdf.format(msg.getMessageTime()) + "\",\"" + msg.getSenderName() + "\",\"" + text + "\"");
            }
        } else if ("xml".equalsIgnoreCase(format)) {
            response.setContentType("text/xml");
            response.setHeader("Content-Disposition", "attachment; filename=\"" + filename + ".xml\"");
            PrintWriter out = response.getWriter();
            out.println("<?xml version=\"1.0\" encoding=\"UTF-8\"?>");
            out.println("<chat>");
            for (Message msg : messages) {
                out.println("  <message>");
                out.println("    <timestamp>" + sdf.format(msg.getMessageTime()) + "</timestamp>");
                out.println("    <sender>" + escapeXml(msg.getSenderName()) + "</sender>");
                out.println("    <text>" + escapeXml(msg.getMessageText()) + "</text>");
                out.println("  </message>");
            }
            out.println("</chat>");
        } else {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid format");
        }
    }

    private String escapeXml(String str) {
        if (str == null) return "";
        return str.replace("&", "&amp;")
                  .replace("<", "&lt;")
                  .replace(">", "&gt;")
                  .replace("\"", "&quot;")
                  .replace("'", "&apos;");
    }
}
