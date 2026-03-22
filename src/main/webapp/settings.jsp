<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%
    if (session.getAttribute("user") == null) {
        response.sendRedirect("login.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Settings - Social Media</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="css/styles.css?v=<%= System.currentTimeMillis() %>">
    <link rel="stylesheet" href="css/app.css?v=<%= System.currentTimeMillis() %>">
    <style>
        .settings-container {
            max-width: 600px;
            margin: 2rem auto;
            background: var(--bg-white);
            border-radius: 16px;
            box-shadow: 0 4px 20px rgba(0,0,0,0.08);
            overflow: hidden;
            display: flex;
            flex-direction: column;
        }
        .settings-header {
            background: linear-gradient(135deg, var(--primary-color), #ff6b81);
            padding: 2rem;
            color: white;
            text-align: center;
        }
        .settings-body {
            padding: 2rem;
            display: flex;
            flex-direction: column;
            gap: 1.5rem;
        }
        .setting-item {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 1.25rem;
            background: var(--bg-light);
            border-radius: 12px;
            border: 1px solid var(--border-color);
            transition: transform 0.2s, box-shadow 0.2s;
        }
        .setting-item:hover {
            transform: translateY(-2px);
            box-shadow: 0 4px 12px rgba(0,0,0,0.05);
        }
        .setting-icon-wrapper {
            width: 44px;
            height: 44px;
            border-radius: 12px;
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
            font-size: 1.2rem;
        }
        .switch { position: relative; display: inline-block; width: 50px; height: 26px; }
        .switch input { opacity: 0; width: 0; height: 0; }
        .slider { position: absolute; cursor: pointer; top: 0; left: 0; right: 0; bottom: 0; background-color: #ccc; transition: .4s; border-radius: 34px; }
        .slider:before { position: absolute; content: ""; height: 20px; width: 20px; left: 3px; bottom: 3px; background-color: white; transition: .4s; border-radius: 50%; }
        input:checked + .slider { background-color: var(--primary-color); }
        input:checked + .slider:before { transform: translateX(24px); }
        
        .form-input {
            width: 100%;
            padding: 0.8rem 1rem;
            border: 1px solid var(--border-color);
            border-radius: 8px;
            background: var(--bg-white);
            font-family: inherit;
            margin-bottom: 0.75rem;
            transition: border-color 0.2s;
        }
        .form-input:focus {
            outline: none;
            border-color: var(--primary-color);
        }
    </style>
</head>
<body>
    <jsp:include page="components/navbar.jsp" />

    <div class="settings-container">
        <div class="settings-header">
            <div style="font-size: 2.5rem; margin-bottom: 0.5rem;"><i class="fas fa-cog fa-spin-hover"></i></div>
            <h1 style="margin: 0; font-size: 1.75rem; font-weight: 700;">Account Settings</h1>
            <p style="margin: 0.5rem 0 0; opacity: 0.8; font-size: 0.95rem;">Manage your preferences and security</p>
        </div>

        <div class="settings-body">
            <!-- Edit Profile -->
            <div class="setting-item" style="flex-direction: column; align-items: stretch; gap: 1rem;">
                <div style="display:flex; justify-content:space-between; align-items:center;">
                    <div style="display:flex; align-items:center; gap:1rem;">
                        <div class="setting-icon-wrapper" style="background: #e17055;">
                            <i class="fas fa-user-edit"></i>
                        </div>
                        <div>
                            <div style="font-weight:600; font-size:1.05rem; color:var(--text-main);">Edit Profile</div>
                            <small class="text-muted" style="font-size: 0.85rem;">Update your personal details & profile photo</small>
                        </div>
                    </div>
                </div>
                
                <div style="background: var(--bg-light); padding: 1.25rem; border-radius: 12px; border: 1px solid var(--border-color); margin-top: 0.5rem;">
                    <form action="EditProfileServlet" method="POST" enctype="multipart/form-data" style="display:flex; flex-direction:column; gap:1rem;">
                        <input type="file" id="profilePhoto" name="profilePhoto" accept="image/*" style="display:none;" onchange="previewAvatar(this)">
                        
                        <!-- Avatar Preview & Upload -->
                        <div style="display:flex; align-items:center; gap: 1rem; margin-bottom: 0.5rem;">
                            <div style="position:relative; display:inline-block; cursor:pointer;" onclick="document.getElementById('profilePhoto').click();" title="Click to change photo">
                                <img id="avatarPreview"
                                     src="${sessionScope.user.profilePhoto != null && (sessionScope.user.profilePhoto.startsWith('http') || sessionScope.user.profilePhoto.startsWith('data:')) ? sessionScope.user.profilePhoto : pageContext.request.contextPath.concat('/').concat(sessionScope.user.profilePhoto != null ? sessionScope.user.profilePhoto : 'images/default-avatar.png')}"
                                     style="width:70px; height:70px; border-radius:50%; object-fit:cover; border:2px solid var(--primary-color);">
                                <div style="position:absolute; bottom:-4px; right:-4px; background:var(--bg-white); border-radius:50%; width:24px; height:24px; display:flex; align-items:center; justify-content:center; box-shadow:0 2px 6px rgba(0,0,0,0.2);">
                                    <i class="fas fa-camera" style="font-size:0.7rem; color:var(--primary-color);"></i>
                                </div>
                            </div>
                            <div style="font-size: 0.85rem; color: var(--text-muted); line-height: 1.4;">
                                <strong>Profile Photo</strong><br>
                                Click the avatar to upload a professional photo.
                            </div>
                        </div>

                        <!-- Full Name -->
                        <div>
                            <label style="font-size:0.8rem; font-weight:700; color:var(--text-muted); text-transform:uppercase; letter-spacing:0.04em;">Full Name</label>
                            <input class="form-input" type="text" name="name" value="${sessionScope.user.name}" style="margin-top: 0.25rem;" required>
                        </div>

                        <!-- Professional Headline -->
                        <div>
                            <label style="font-size:0.8rem; font-weight:700; color:var(--text-muted); text-transform:uppercase; letter-spacing:0.04em;">Headline</label>
                            <input class="form-input" type="text" name="headline" value="${sessionScope.user.headline}" style="margin-top: 0.25rem;">
                        </div>
                        
                        <!-- Bio -->
                        <div>
                            <label style="font-size:0.8rem; font-weight:700; color:var(--text-muted); text-transform:uppercase; letter-spacing:0.04em;">Bio</label>
                            <textarea class="form-input" name="bio" rows="3" style="margin-top: 0.25rem; resize:vertical;">${sessionScope.user.bio}</textarea>
                        </div>

                        <button type="submit" style="width:100%; padding:0.8rem; background:linear-gradient(135deg,var(--primary-color),#ff6b81); color:white; border:none; border-radius:8px; cursor:pointer; font-weight:600; font-size:1rem; font-family:inherit; transition:opacity 0.2s; margin-top: 0.5rem;" onmouseover="this.style.opacity='0.9'" onmouseout="this.style.opacity='1'">Save Profile Changes</button>
                    </form>
                </div>
            </div>

            <!-- Dark Mode -->
            <div class="setting-item">
                <div style="display:flex; align-items:center; gap:1rem;">
                    <div class="setting-icon-wrapper" style="background: var(--primary-color);">
                        <i class="fas fa-moon"></i>
                    </div>
                    <div>
                        <div style="font-weight:600; font-size:1.05rem; color:var(--text-main);">Dark Mode</div>
                        <small id="themeStatus" class="text-muted" style="font-size: 0.85rem;">Off</small>
                    </div>
                </div>
                <label class="switch">
                    <input type="checkbox" id="themeToggle" onchange="ThemeManager.toggle()">
                    <span class="slider round"></span>
                </label>
            </div>

            <!-- Privacy -->
            <div class="setting-item">
                <div style="display:flex; align-items:center; gap:1rem;">
                    <div class="setting-icon-wrapper" style="background: #6c63ff;">
                        <i class="fas fa-lock"></i>
                    </div>
                    <div>
                        <div style="font-weight:600; font-size:1.05rem; color:var(--text-main);">Private Account</div>
                        <small id="privacyStatus" class="text-muted" style="font-size: 0.85rem;">${sessionScope.user.privateAccount ? "Private" : "Public"}</small>
                    </div>
                </div>
                <label class="switch">
                    <input type="checkbox" id="privacyToggle" ${sessionScope.user.privateAccount ? "checked" : ""} onchange="updatePrivacy(this.checked)">
                    <span class="slider round"></span>
                </label>
            </div>

            <!-- Change Password -->
            <div class="setting-item" style="flex-direction: column; align-items: stretch; gap: 1rem;">
                <div style="display:flex; align-items:center; gap:1rem;">
                    <div class="setting-icon-wrapper" style="background: #00b894;">
                        <i class="fas fa-key"></i>
                    </div>
                    <div>
                        <div style="font-weight:600; font-size:1.05rem; color:var(--text-main);">Change Password</div>
                        <small class="text-muted" style="font-size: 0.85rem;">Update your account password</small>
                    </div>
                </div>
                <form id="passwordForm" onsubmit="updatePassword(event)">
                    <input type="password" id="currentPassword" placeholder="Current Password" class="form-input" required>
                    <input type="password" id="newPassword" placeholder="New Password" class="form-input" required>
                    <button type="submit" style="width:100%; padding:0.8rem; background:linear-gradient(135deg,var(--primary-color),#ff6b81); color:white; border:none; border-radius:8px; cursor:pointer; font-weight:600; font-size:1rem; font-family:inherit; transition:opacity 0.2s;" onmouseover="this.style.opacity='0.9'" onmouseout="this.style.opacity='1'">Update Password</button>
                </form>
                <div id="passwordMessage" style="font-size:0.9rem; text-align:center;"></div>
            </div>

            <!-- Logout -->
            <button type="button" onclick="confirmLogout()" class="setting-item" style="cursor:pointer; width:100%; text-align:left; border:1px solid var(--border-color); background:var(--bg-light);">
                <div style="display:flex; align-items:center; gap:1rem;">
                    <div class="setting-icon-wrapper" style="background: #fdcb6e;">
                        <i class="fas fa-sign-out-alt"></i>
                    </div>
                    <div>
                        <div style="font-weight:600; font-size:1.05rem; color:var(--text-main);">Logout</div>
                        <small class="text-muted" style="font-size: 0.85rem;">Sign out of your account</small>
                    </div>
                </div>
                <i class="fas fa-chevron-right text-muted"></i>
            </button>

            <!-- Danger Zone: Delete Account -->
            <div class="setting-item" style="flex-direction: column; align-items: stretch; gap: 1rem; border:2px solid var(--danger-color); background:rgba(255,71,87,0.03);">
                <div style="display:flex; align-items:center; gap:0.5rem; color:var(--danger-color); font-weight:700; font-size:1rem;">
                    <i class="fas fa-exclamation-triangle"></i> Danger Zone
                </div>
                <p style="margin:0; font-size:0.9rem; color:var(--text-muted);">Permanently delete your account, posts, and messages. This action cannot be undone.</p>
                <form action="DeleteAccountServlet" method="POST" onsubmit="return confirm('⚠️ This will permanently delete your account, all posts, and messages. This CANNOT be undone. Are you sure?');">
                    <button type="submit" style="width:100%; padding:0.8rem; background:#ff3547; color:#ffffff !important; border:2px solid #cc0000; border-radius:8px; cursor:pointer; font-weight:700; display:flex; align-items:center; justify-content:center; gap:0.5rem; font-size:1rem; transition:background 0.2s;" onmouseover="this.style.background='#cc0000'" onmouseout="this.style.background='#ff3547'">
                        <i class="fas fa-user-slash"></i> Delete Account Permanently
                    </button>
                </form>
            </div>
        </div>
    </div>

    <script src="${pageContext.request.contextPath}/js/app_v2.js?v=20260317"></script>
    <script>
        const contextPath = '${pageContext.request.contextPath}';

        function previewAvatar(input) {
            if (input.files && input.files[0]) {
                const reader = new FileReader();
                reader.onload = e => {
                    document.getElementById('avatarPreview').src = e.target.result;
                };
                reader.readAsDataURL(input.files[0]);
            }
        }

        function updatePrivacy(isPrivate) {
            const statusText = document.getElementById('privacyStatus');
            fetch(contextPath + '/SettingsServlet', {
                method: 'POST',
                headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                body: 'action=privacy&isPrivate=' + isPrivate
            }).then(res => res.text()).then(data => {
                if(data === 'success') {
                    statusText.innerText = isPrivate ? "Private" : "Public";
                } else {
                    alert("Failed to update privacy settings.");
                    document.getElementById('privacyToggle').checked = !isPrivate;
                }
            });
        }

        function updatePassword(e) {
            e.preventDefault();
            const currentPassword = document.getElementById('currentPassword').value;
            const newPassword = document.getElementById('newPassword').value;
            const msgDiv = document.getElementById('passwordMessage');
            
            msgDiv.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Updating password...';
            msgDiv.className = 'text-muted';

            fetch(contextPath + '/SettingsServlet', {
                method: 'POST',
                headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                body: 'action=password&currentPassword=' + encodeURIComponent(currentPassword) + '&newPassword=' + encodeURIComponent(newPassword)
            }).then(res => res.text()).then(data => {
                if(data === 'success') {
                    msgDiv.innerHTML = '<i class="fas fa-check-circle"></i> Password updated successfully!';
                    msgDiv.className = 'text-success';
                    msgDiv.style.color = '#00b894';
                    document.getElementById('passwordForm').reset();
                } else {
                    msgDiv.innerHTML = '<i class="fas fa-exclamation-circle"></i> ' + data;
                    msgDiv.className = 'text-danger';
                    msgDiv.style.color = 'var(--danger-color)';
                }
            }).catch(err => {
                msgDiv.innerHTML = '<i class="fas fa-exclamation-circle"></i> Connection error.';
                msgDiv.style.color = 'var(--danger-color)';
            });
        }
        
        // Sync Theme Status Text
        document.addEventListener('DOMContentLoaded', () => {
            const isDark = document.documentElement.getAttribute('data-theme') === 'dark';
            document.getElementById('themeStatus').innerText = isDark ? 'On' : 'Off';
            
            // Override toggle to also update text
            const ogToggle = ThemeManager.toggle;
            ThemeManager.toggle = function() {
                ogToggle.call(ThemeManager);
                const darkNow = document.documentElement.getAttribute('data-theme') === 'dark';
                document.getElementById('themeStatus').innerText = darkNow ? 'On' : 'Off';
            };
        });
    </script>
</body>
</html>
