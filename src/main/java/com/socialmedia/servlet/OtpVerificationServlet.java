package com.socialmedia.servlet;

import com.socialmedia.dao.UserDAO;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

@WebServlet("/OtpVerificationServlet")
public class OtpVerificationServlet extends HttpServlet {

    private UserDAO userDAO;

    @Override
    public void init() {
        userDAO = new UserDAO();
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
            
        String email = (String) request.getSession().getAttribute("verifyEmail");
        String otp = request.getParameter("otp");

        if (email == null) {
            response.sendRedirect("register.jsp");
            return;
        }

        boolean verified = userDAO.verifyAndCreateUser(email, otp);
        if (verified) {
            request.getSession().removeAttribute("verifyEmail");
            response.sendRedirect("login.jsp?registered=true");
        } else {
            request.setAttribute("error", "Invalid or expired OTP. Please try again.");
            request.getRequestDispatcher("otp_verify.jsp").forward(request, response);
        }
    }
}
