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
        
        /* Collapsible Settings CSS */
        .setting-group {
            background: var(--bg-light);
            border-radius: 12px;
            border: 1px solid var(--border-color);
            overflow: hidden;
            transition: box-shadow 0.2s, transform 0.2s;
        }
        .setting-group:hover {
            box-shadow: 0 4px 12px rgba(0,0,0,0.05);
            transform: translateY(-2px);
        }
        .setting-header-btn {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 1.25rem;
            width: 100%;
            background: none;
            border: none;
            cursor: pointer;
            text-align: left;
            font-family: inherit;
        }
        .setting-content-area {
            display: none;
            padding: 0 1.25rem 1.25rem 1.25rem;
            border-top: 1px solid var(--border-color);
        }
        .setting-content-area.active {
            display: flex;
            flex-direction: column;
            gap: 1.5rem;
            animation: slideDown 0.3s ease-out;
        }
        .chevron-icon {
            transition: transform 0.3s;
            color: var(--text-muted);
            font-size: 1.2rem;
        }
        .active-header .chevron-icon {
            transform: rotate(180deg);
            color: var(--primary-color);
        }
        @keyframes slideDown {
            from { opacity: 0; transform: translateY(-10px); }
            to { opacity: 1; transform: translateY(0); }
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
        <div class="settings-body">
            
            <!-- Edit Profile Group -->
            <div class="setting-group">
                <button type="button" class="setting-header-btn" onclick="toggleSection('editProfileSection', this)">
                    <div style="display:flex; align-items:center; gap:1rem;">
                        <div class="setting-icon-wrapper" style="background: #e17055;">
                            <i class="fas fa-user-edit"></i>
                        </div>
                        <div>
                            <div style="font-weight:600; font-size:1.05rem; color:var(--text-main);">Edit Profile</div>
                            <small class="text-muted" style="font-size: 0.85rem;">Update your personal details & profile photo</small>
                        </div>
                    </div>
                    <i class="fas fa-chevron-down chevron-icon"></i>
                </button>
                <div id="editProfileSection" class="setting-content-area">
                    <form action="EditProfileServlet" method="POST" enctype="multipart/form-data" style="display:flex; flex-direction:column; gap:1rem; margin-top:1rem;">
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

            <!-- Account Privacy Group -->
            <div class="setting-group">
                <button type="button" class="setting-header-btn" onclick="toggleSection('privacySection', this)">
                    <div style="display:flex; align-items:center; gap:1rem;">
                        <div class="setting-icon-wrapper" style="background: #6c63ff;">
                            <i class="fas fa-shield-alt"></i>
                        </div>
                        <div>
                            <div style="font-weight:600; font-size:1.05rem; color:var(--text-main);">Account Privacy</div>
                            <small class="text-muted" style="font-size: 0.85rem;">Manage visibility and security</small>
                        </div>
                    </div>
                    <i class="fas fa-chevron-down chevron-icon"></i>
                </button>
                <div id="privacySection" class="setting-content-area">
                    <!-- Account Type Toggle -->
                    <div style="display:flex; justify-content:space-between; align-items:center; padding-top:1rem;">
                        <div>
                            <div style="font-weight:600; color:var(--text-main);">Private Account</div>
                            <small id="privacyStatus" class="text-muted" style="font-size: 0.85rem;">${sessionScope.user.privateAccount ? "Private" : "Public"}</small>
                        </div>
                        <label class="switch">
                            <input type="checkbox" id="privacyToggle" ${sessionScope.user.privateAccount ? "checked" : ""} onchange="updatePrivacy(this.checked)">
                            <span class="slider round"></span>
                        </label>
                    </div>
                    
                    <hr style="border:0; border-top:1px solid var(--border-color); margin: 0.5rem 0;">
                    
                    <!-- Change Password -->
                    <div>
                        <div style="font-weight:600; color:var(--text-main); margin-bottom: 0.5rem;">Change Password</div>
                        <form id="passwordForm" onsubmit="updatePassword(event)">
                            <input type="password" id="currentPassword" placeholder="Current Password" class="form-input" required>
                            <input type="password" id="newPassword" placeholder="New Password" class="form-input" required>
                            <button type="submit" style="width:100%; padding:0.8rem; background:linear-gradient(135deg,var(--primary-color),#ff6b81); color:white; border:none; border-radius:8px; cursor:pointer; font-weight:600; font-size:1rem; font-family:inherit; transition:opacity 0.2s;" onmouseover="this.style.opacity='0.9'" onmouseout="this.style.opacity='1'">Update Password</button>
                        </form>
                        <div id="passwordMessage" style="font-size:0.9rem; text-align:center; margin-top: 0.5rem;"></div>
                    </div>
                </div>
            </div>

            <!-- Chat Settings Group -->
            <div class="setting-group">
                <button type="button" class="setting-header-btn" onclick="toggleSection('chatSettingsSection', this)">
                    <div style="display:flex; align-items:center; gap:1rem;">
                        <div class="setting-icon-wrapper" style="background: #00cec9;">
                            <i class="fas fa-comments"></i>
                        </div>
                        <div>
                            <div style="font-weight:600; font-size:1.05rem; color:var(--text-main);">Chat Settings</div>
                            <small class="text-muted" style="font-size: 0.85rem;">Themes and Wallpapers</small>
                        </div>
                    </div>
                    <i class="fas fa-chevron-down chevron-icon"></i>
                </button>
                <div id="chatSettingsSection" class="setting-content-area" style="padding-top:1rem;">
                    
                    <!-- Chat Background -->
                    <div style="display: flex; justify-content: space-between; align-items: center; padding: 1rem; background: var(--bg-white); border-radius: 12px; border: 1px solid var(--border-color);">
                        <div style="display: flex; align-items: center; gap: 0.75rem;">
                            <i class="fas fa-image" style="color: var(--primary-color); font-size: 1.25rem;"></i>
                            <div>
                                <div style="font-weight: 600;">Custom Chat Background</div>
                                <div style="font-size: 0.85rem; color: var(--text-muted);">Set a wallpaper for conversations</div>
                            </div>
                        </div>
                        <div style="display: flex; gap: 0.5rem;">
                            <button type="button" onclick="document.getElementById('settingChatBgInput').click()" class="btn btn-primary" style="padding: 0.35rem 0.75rem; border-radius: 8px; font-size: 0.85rem; color: white;">Change</button>
                            <button type="button" onclick="removeChatBgSetting()" class="btn" style="padding: 0.35rem 0.75rem; border-radius: 8px; border: 1px solid var(--border-color); color: var(--danger-color); font-size: 0.85rem; background: transparent;">Remove</button>
                        </div>
                        <input type="file" id="settingChatBgInput" accept="image/*" style="display:none" onchange="handleSettingChatBg(this)">
                    </div>
                    
                    <!-- Chat Themes -->
                    <div style="display: flex; flex-direction: column; gap: 1rem; padding: 1rem; background: var(--bg-white); border-radius: 12px; border: 1px solid var(--border-color);">
                        <div style="display: flex; align-items: center; gap: 0.75rem;">
                            <i class="fas fa-palette" style="color: var(--primary-color); font-size: 1.25rem;"></i>
                            <div>
                                <div style="font-weight: 600;">Chat Theme Colors</div>
                                <div style="font-size: 0.85rem; color: var(--text-muted);">Choose a color palette for your message bubbles</div>
                            </div>
                        </div>
                        <div id="themes-grid" style="display: grid; grid-template-columns: repeat(auto-fill, minmax(200px, 1fr)); gap: 1rem; margin-top: 0.5rem;">
                            <!-- Themes injected dynamically here -->
                        </div>
                    </div>

                </div>
            </div>

            <!-- Display Settings Group -->
            <div class="setting-group">
                <button type="button" class="setting-header-btn" onclick="toggleSection('displaySection', this)">
                    <div style="display:flex; align-items:center; gap:1rem;">
                        <div class="setting-icon-wrapper" style="background: var(--primary-color);">
                            <i class="fas fa-desktop"></i>
                        </div>
                        <div>
                            <div style="font-weight:600; font-size:1.05rem; color:var(--text-main);">Display Settings</div>
                            <small class="text-muted" style="font-size: 0.85rem;">App appearance and theme</small>
                        </div>
                    </div>
                    <i class="fas fa-chevron-down chevron-icon"></i>
                </button>
                <div id="displaySection" class="setting-content-area">
                    <div style="display:flex; align-items:center; justify-content:space-between; padding-top:1rem;">
                        <div style="display:flex; align-items:center; gap:1rem;">
                            <i class="fas fa-moon text-primary" style="font-size:1.2rem;"></i>
                            <div>
                                <div style="font-weight:600; color:var(--text-main);">Dark Mode</div>
                                <small id="themeStatus" class="text-muted" style="font-size: 0.85rem;">Off</small>
                            </div>
                        </div>
                        <label class="switch">
                            <input type="checkbox" id="themeToggle" onchange="ThemeManager.toggle()">
                            <span class="slider round"></span>
                        </label>
                    </div>
                </div>
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

        function toggleSection(sectionId, btn) {
            const content = document.getElementById(sectionId);
            const isActive = content.classList.contains('active');
            
            // Close all
            document.querySelectorAll('.setting-content-area').forEach(el => el.classList.remove('active'));
            document.querySelectorAll('.setting-header-btn').forEach(el => el.classList.remove('active-header'));
            
            if(!isActive) {
                content.classList.add('active');
                if(btn) btn.classList.add('active-header');
            }
        }

        function previewAvatar(input) {
            if (input.files && input.files[0]) {
                const reader = new FileReader();
                reader.onload = e => {
                    document.getElementById('avatarPreview').src = e.target.result;
                };
                reader.readAsDataURL(input.files[0]);
            }
        }

        function handleSettingChatBg(input) {
            const file = input.files[0];
            if (!file) return;
            const reader = new FileReader();
            reader.onload = (event) => {
                const img = new Image();
                img.onload = () => {
                    const canvas = document.createElement('canvas');
                    let width = img.width; let height = img.height;
                    const MAX = 800;
                    if(width>height){if(width>MAX){height*=MAX/width; width=MAX;}}
                    else{if(height>MAX){width*=MAX/height; height=MAX;}}
                    canvas.width=width; canvas.height=height;
                    const ctx=canvas.getContext('2d');
                    ctx.drawImage(img,0,0,width,height);
                    const dataUrl = canvas.toDataURL('image/jpeg', 0.6);
                    try {
                        localStorage.setItem('chatBg_${sessionScope.user.userId}', dataUrl);
                        alert("Chat background updated successfully!");
                    } catch(e) {
                        alert("Image too large to save. Try a smaller one.");
                    }
                };
                img.src = event.target.result;
            };
            reader.readAsDataURL(file);
        }

        function removeChatBgSetting() {
            localStorage.removeItem('chatBg_${sessionScope.user.userId}');
            alert("Chat background removed.");
        }

        const chatThemes = [
            { id: "default", name: "Default Light", bg: "var(--bg-light)", sent: "var(--primary-color)", received: "var(--bg-white)", sentText: "white", receivedText: "var(--text-main)" },
            { id: "dark", name: "Dark Mode", bg: "#1f2937", sent: "#3b82f6", received: "#374151", sentText: "white", receivedText: "#f3f4f6" },
            { id: "ocean", name: "Ocean Blue", bg: "linear-gradient(to right, #00c6ff, #0072ff)", sent: "rgba(255,255,255,0.9)", received: "rgba(0,0,0,0.6)", sentText: "#0072ff", receivedText: "white" },
            { id: "sunset", name: "Sunset Orange", bg: "linear-gradient(to top, #ff7e5f, #feb47b)", sent: "#ff512f", received: "#fff", sentText: "white", receivedText: "#333" },
            { id: "forest", name: "Forest Green", bg: "linear-gradient(135deg, #43e97b 0%, #38f9d7 100%)", sent: "#15803d", received: "#fff", sentText: "white", receivedText: "#15803d" },
            { id: "purple", name: "Purple Dream", bg: "linear-gradient(to right, #feac5e, #c779d0, #4bc0c8)", sent: "#8b5cf6", received: "#fff", sentText: "white", receivedText: "#4c1d95" },
            { id: "cherry", name: "Cherry Blossom", bg: "linear-gradient(to top, #ff0844 0%, #ffb199 100%)", sent: "#e11d48", received: "#ffe4e6", sentText: "white", receivedText: "#881337" },
            { id: "midnight", name: "Midnight City", bg: "linear-gradient(to top, #0f2027, #203a43, #2c5364)", sent: "#06b6d4", received: "rgba(255,255,255,0.1)", sentText: "white", receivedText: "white" },
            { id: "neon", name: "Neon Vibes", bg: "#000000", sent: "#ff00ff", received: "#00ffff", sentText: "white", receivedText: "black" },
            { id: "coffee", name: "Coffee Warm", bg: "#dfd2c0", sent: "#8b5a2b", received: "#fff8dc", sentText: "white", receivedText: "#4a3b2c" }
        ];

        function renderSettingThemes() {
            const grid = document.getElementById('themes-grid');
            if(!grid) return;
            const activeId = localStorage.getItem('chatTheme_${sessionScope.user.userId}') || 'default';
            let html = '';
            chatThemes.forEach(t => {
                const isActive = t.id === activeId;
                html += `
                    <div style="display:flex; align-items:center; justify-content:space-between; padding:10px; border-radius:12px; border:2px solid \${isActive ? 'var(--primary-color)' : 'transparent'}; background:var(--bg-light); cursor:pointer; box-shadow:0 1px 3px rgba(0,0,0,0.05);" onclick="applySettingTheme('\${t.id}')">
                        <div style="display:flex; align-items:center; gap:12px;">
                            <div style="width:30px; height:30px; border-radius:50%; background:\${t.bg}; border:1px solid rgba(0,0,0,0.1); display:flex; align-items:center; justify-content:center; overflow:hidden;"></div>
                            <span style="font-weight:600; font-size:0.9rem; \${isActive ? 'color:var(--primary-color)' : 'color:var(--text-main)'}">\${t.name}</span>
                        </div>
                        \${isActive ? '<i class="fas fa-check-circle text-primary" style="font-size:1rem;"></i>' : ''}
                    </div>
                `;
            });
            grid.innerHTML = html;
        }

        function applySettingTheme(themeId) {
            const theme = chatThemes.find(t => t.id === themeId);
            if (!theme) return;
            localStorage.setItem('chatTheme_${sessionScope.user.userId}', themeId);
            localStorage.setItem('chatThemeData_${sessionScope.user.userId}', JSON.stringify(theme));
            renderSettingThemes();
            alert("Chat theme updated to " + theme.name + "!");
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
