<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Verify OTP - SocialConnect</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="css/styles.css?v=<%= System.currentTimeMillis() %>">
    <style>
        .auth-container { display: flex; align-items: center; justify-content: center; min-height: 100vh; background: linear-gradient(135deg, #f6f8fd 0%, #f1f5f9 100%); padding: 2rem; }
        .auth-card { background: white; border-radius: 12px; padding: 3rem; width: 100%; max-width: 450px; box-shadow: 0 10px 25px rgba(0,0,0,0.05); }
        .auth-header { text-align: center; margin-bottom: 2rem; }
        .auth-title { font-size: 1.8rem; font-weight: 700; color: var(--text-color); margin-bottom: 0.5rem; }
        .auth-subtitle { color: var(--text-muted); font-size: 0.95rem; }
        .error-message { background-color: #fee2e2; color: #b91c1c; padding: 10px; border-radius: 6px; margin-bottom: 1rem; font-size: 0.9rem; text-align: center; }
    </style>
</head>
<body>
    <div class="auth-container">
        <div class="auth-card">
            <div class="auth-header">
                <div style="font-size: 3rem; color: var(--primary-color); margin-bottom: 1rem;">
                    <i class="fas fa-envelope-open-text"></i>
                </div>
                <h1 class="auth-title">Verify Your Email</h1>
                <p class="auth-subtitle">We sent a 6-digit code to <b>${sessionScope.verifyEmail}</b>.</p>
            </div>
            
            <c:if test="${not empty error}">
                <div class="error-message">
                    <i class="fas fa-exclamation-circle"></i> ${error}
                </div>
            </c:if>

            <c:if test="${not empty sessionScope.otpMessage}">
                <div style="background-color: #dcfce7; color: #166534; padding: 12px; border-radius: 8px; margin-bottom: 1.5rem; font-size: 0.95rem; text-align: center; border: 1px solid #bbf7d0;">
                    <i class="fas fa-info-circle"></i> ${sessionScope.otpMessage}
                    <% session.removeAttribute("otpMessage"); %>
                </div>
            </c:if>
            
            <form action="OtpVerificationServlet" method="POST">
                <div class="form-group mb-4">
                    <label class="form-label" for="otp">Enter OTP</label>
                    <div class="input-icon-wrapper">
                        <i class="fas fa-key input-icon"></i>
                        <input class="form-input" type="text" id="otp" name="otp" placeholder="123456" required pattern="\d{6}" maxlength="6">
                    </div>
                </div>
                
                <button type="submit" class="btn btn-primary w-100 mb-3">Verify & Register</button>
                
                <div class="text-center" style="font-size: 0.9rem;">
                    <a href="register.jsp" style="color: var(--primary-color); text-decoration: none;">Wrong email? Go back</a>
                </div>
            </form>
        </div>
    </div>
</body>
</html>
