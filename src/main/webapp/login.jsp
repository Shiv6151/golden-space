<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Login - Social Media</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="css/styles.css?v=<%= System.currentTimeMillis() %>">
</head>
<body>
    <div class="auth-container">
        <div class="auth-card">
            <h1 class="auth-title">Welcome Back</h1>
            
            <% 
               String errorMsg = (String) request.getAttribute("errorMsg");
               String successMsg = (String) request.getAttribute("successMsg");
               if (errorMsg != null) { 
            %>
                <div class="alert alert-danger"><%= errorMsg %></div>
            <% } %>
            
            <% if (successMsg != null) { %>
                <div class="alert alert-success"><%= successMsg %></div>
            <% } %>

            <form action="LoginServlet" method="POST">
                <div class="form-group">
                    <label class="form-label" for="email">Email Address</label>
                    <input class="form-input" type="email" id="email" name="email" required autocomplete="email" placeholder="you@example.com">
                </div>
                <div class="form-group">
                    <div style="display:flex; justify-content:space-between; align-items:center;">
                        <label class="form-label" for="password" style="margin-bottom:0.1rem;">Password</label>
                        <a href="forgot-password.jsp" style="font-size:0.8rem; color:var(--primary-color); text-decoration:none; margin-bottom:0.1rem;">Forgot?</a>
                    </div>
                    <input class="form-input" type="password" id="password" name="password" required placeholder="••••••••">
                </div>
                <button type="submit" class="btn-primary">Sign In</button>
            </form>
            
            <div class="auth-footer">
                Don't have an account? <a href="register.jsp">Sign up</a>
            </div>
        </div>
    </div>
</body>
</html>
