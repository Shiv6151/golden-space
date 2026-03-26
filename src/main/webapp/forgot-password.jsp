<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Forgot Password - Golden Space</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <link rel="stylesheet" href="css/styles.css">
    <style>
        :root {
            --primary-color: #6c63ff;
            --bg-white: #ffffff;
            --text-main: #2d3436;
            --text-muted: #636e72;
            --border-color: #dfe6e9;
            --bg-light: #f8f9fa;
        }
        body {
            font-family: 'Inter', sans-serif;
            background: var(--bg-light);
            display: flex;
            align-items: center;
            justify-content: center;
            min-height: 100vh;
            margin: 0;
        }
        .container {
            width: 100%;
            max-width: 420px;
            padding: 20px;
        }
        .card {
            background: var(--bg-white);
            border-radius: 20px;
            box-shadow: 0 10px 30px rgba(0,0,0,0.05);
            padding: 2.5rem;
            border: 1px solid var(--border-color);
        }
        .logo-area {
            text-align: center;
            margin-bottom: 2rem;
        }
        .logo-area h2 {
            margin: 0.5rem 0 0.2rem;
            color: var(--text-main);
        }
        .logo-area p {
            color: var(--text-muted);
            font-size: 0.9rem;
            margin-top: 0;
        }
        .form-input {
            width: 100%;
            padding: 0.8rem 1rem;
            border-radius: 10px;
            border: 1.5px solid var(--border-color);
            background: var(--bg-white);
            font-family: inherit;
            font-size: 0.95rem;
            transition: border-color 0.2s;
            margin-bottom: 1.2rem;
            box-sizing: border-box;
        }
        .form-input:focus {
            outline: none;
            border-color: var(--primary-color);
        }
        .btn {
            width: 100%;
            padding: 0.8rem;
            border-radius: 10px;
            border: none;
            background: linear-gradient(135deg, var(--primary-color), #8e87ff);
            color: white;
            font-weight: 600;
            font-size: 1rem;
            cursor: pointer;
            transition: opacity 0.2s, transform 0.1s;
        }
        .btn:active {
            transform: scale(0.98);
        }
        .btn:disabled {
            opacity: 0.6;
            cursor: not-allowed;
        }
        .back-link {
            display: block;
            text-align: center;
            margin-top: 1.5rem;
            font-size: 0.9rem;
            color: var(--text-muted);
            text-decoration: none;
            font-weight: 500;
        }
        .back-link:hover {
            color: var(--primary-color);
        }
        .step {
            display: none;
            animation: fadeIn 0.3s ease-out;
        }
        .step.active {
            display: block;
        }
        @keyframes fadeIn {
            from { opacity: 0; transform: translateY(5px); }
            to { opacity: 1; transform: translateY(0); }
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="card">
            <div class="logo-area">
                <i class="fas fa-key" style="font-size: 2rem; color: var(--primary-color);"></i>
                <h2>Reset Password</h2>
                <p id="stepDescription">Enter your email to receive an OTP</p>
            </div>

            <!-- Step 1: Enter Email -->
            <div id="step1" class="step active">
                <input type="email" id="email" class="form-input" placeholder="Email Address" required>
                <button onclick="sendOtp()" id="sendBtn" class="btn">Send OTP</button>
            </div>

            <!-- Step 2: Verify OTP -->
            <div id="step2" class="step">
                <p style="font-size: 0.85rem; color: var(--text-muted); text-align: center; margin-bottom: 1rem;">We've sent a 6-digit code to <br><b id="displayEmail"></b></p>
                <input type="text" id="otp" class="form-input" placeholder="6-digit OTP" maxlength="6" style="text-align: center; letter-spacing: 0.5rem; font-weight: 700;">
                <button onclick="verifyOtp()" id="verifyBtn" class="btn">Verify Code</button>
                <a href="javascript:void(0)" onclick="goToStep(1)" class="back-link">Change Email</a>
            </div>

            <!-- Step 3: New Password -->
            <div id="step3" class="step">
                <input type="password" id="newPassword" class="form-input" placeholder="New Password" required>
                <input type="password" id="confirmPassword" class="form-input" placeholder="Confirm Password" required>
                <button onclick="resetPassword()" id="resetBtn" class="btn">Update Password</button>
            </div>

            <a href="login.jsp" class="back-link"><i class="fas fa-arrow-left"></i> Back to Login</a>
        </div>
    </div>

    <script>
        const contextPath = ''; // Usually empty if at root

        function goToStep(step) {
            document.querySelectorAll('.step').forEach(s => s.classList.remove('active'));
            document.getElementById('step' + step).classList.add('active');
            
            const desc = document.getElementById('stepDescription');
            if(step == 1) desc.innerText = "Enter your email to receive an OTP";
            if(step == 2) desc.innerText = "Check your email for OTP";
            if(step == 3) desc.innerText = "Create a strong new password";
        }

        function sendOtp() {
            const email = document.getElementById('email').value;
            if(!email) return alert("Please enter your email.");

            const btn = document.getElementById('sendBtn');
            btn.innerHTML = '<i class="fas fa-circle-notch fa-spin"></i> Sending...';
            btn.disabled = true;

            fetch('ForgotPasswordServlet', {
                method: 'POST',
                headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                body: 'action=sendOtp&email=' + encodeURIComponent(email)
            })
            .then(res => res.json())
            .then(data => {
                btn.innerHTML = 'Send OTP';
                btn.disabled = false;
                if(data.success) {
                    if(data.message) alert(data.message);
                    document.getElementById('displayEmail').innerText = email;
                    goToStep(2);
                } else {
                    alert(data.message || "Failed to send OTP.");
                }
            })
            .catch(err => {
                alert("Connection error.");
                btn.innerHTML = 'Send OTP';
                btn.disabled = false;
            });
        }

        function verifyOtp() {
            const otp = document.getElementById('otp').value;
            if(otp.length < 6) return alert("Enter 6-digit OTP.");

            const btn = document.getElementById('verifyBtn');
            btn.innerHTML = '<i class="fas fa-circle-notch fa-spin"></i> Verifying...';
            btn.disabled = true;

            fetch('ForgotPasswordServlet', {
                method: 'POST',
                headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                body: 'action=verifyOtp&otp=' + otp
            })
            .then(res => res.json())
            .then(data => {
                btn.innerHTML = 'Verify Code';
                btn.disabled = false;
                if(data.success) {
                    goToStep(3);
                } else {
                    alert(data.message || "Invalid OTP.");
                }
            })
            .catch(err => {
                alert("Connection error.");
                btn.innerHTML = 'Verify Code';
                btn.disabled = false;
            });
        }

        function resetPassword() {
            const pass1 = document.getElementById('newPassword').value;
            const pass2 = document.getElementById('confirmPassword').value;
            
            if(pass1.length < 6) return alert("Password must be at least 6 characters.");
            if(pass1 !== pass2) return alert("Passwords do not match.");

            const btn = document.getElementById('resetBtn');
            btn.innerHTML = '<i class="fas fa-circle-notch fa-spin"></i> Updating...';
            btn.disabled = true;

            fetch('ForgotPasswordServlet', {
                method: 'POST',
                headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                body: 'action=resetPassword&password=' + encodeURIComponent(pass1)
            })
            .then(res => res.json())
            .then(data => {
                btn.innerHTML = 'Update Password';
                btn.disabled = false;
                if(data.success) {
                    alert("Password updated successfully! Please login.");
                    window.location.href = "login.jsp";
                } else {
                    alert(data.message || "Error updating password.");
                }
            })
            .catch(err => {
                alert("Connection error.");
                btn.innerHTML = 'Update Password';
                btn.disabled = false;
            });
        }
    </script>
</body>
</html>
