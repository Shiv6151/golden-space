<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Create Account - Social Media</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="css/styles.css?v=<%= System.currentTimeMillis() %>">
</head>
<body>
    <div class="auth-container">
        <div class="auth-card">
            <h1 class="auth-title">Create Account</h1>
            
            <% 
               String errorMsg = (String) request.getAttribute("errorMsg");
               if (errorMsg != null) { 
            %>
                <div class="alert alert-danger"><%= errorMsg %></div>
            <% } %>

            <form action="RegisterServlet" method="POST">
                <div class="form-group">
                    <label class="form-label" for="name">Full Name</label>
                    <div class="input-icon-wrapper">
                        <i class="fas fa-user input-icon"></i>
                        <input class="form-input" type="text" id="name" name="name" placeholder="Enter your full name" required>
                    </div>
                </div>

                <div class="form-group">
                    <label class="form-label" for="username">Username</label>
                    <div class="input-icon-wrapper">
                        <i class="fas fa-at input-icon"></i>
                        <input class="form-input" type="text" id="username" name="username" placeholder="Choose a unique username" required>
                    </div>
                </div>
                
                <div class="form-group">
                    <label class="form-label" for="email">Email Address</label>
                    <div class="input-icon-wrapper">
                        <i class="fas fa-envelope input-icon"></i>
                        <input class="form-input" type="email" id="email" name="email" placeholder="Must be @gmail.com" required pattern=".+@gmail\.com$" title="Please provide a valid @gmail.com address">
                    </div>
                </div>
                <div class="form-group">
                    <label class="form-label" for="password">Password</label>
                    <input class="form-input" type="password" id="password" name="password" required placeholder="••••••••">
                </div>
                <button type="submit" class="btn-primary">Sign Up</button>
            </form>
            
            <div class="auth-footer">
                Already have an account? <a href="login.jsp">Sign in</a>
            </div>
        </div>
    </div>
</body>
</html>
