<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.fmt" prefix="fmt" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>${profileUser.name} - Profile</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="css/styles.css?v=<%= System.currentTimeMillis() %>">
    <link rel="stylesheet" href="css/app.css?v=<%= System.currentTimeMillis() %>">
    <style>
        @media (max-width: 768px) {
            .ig-profile-header {
                flex-direction: column !important;
                align-items: center !important;
                padding: 1rem !important;
                gap: 1rem !important;
            }
            .ig-avatar-section {
                align-items: center !important;
                text-align: center !important;
            }
            .ig-avatar { width: 80px !important; height: 80px !important; }
            .ig-info-section {
                width: 100% !important;
                align-items: center !important;
                text-align: center !important;
            }
            .ig-user-row {
                flex-wrap: wrap !important;
                justify-content: center !important;
                gap: 0.5rem !important;
            }
            .ig-stats {
                gap: 1.5rem !important;
                justify-content: center !important;
            }
            .ig-full-name { font-size: 1.15rem !important; }
            .ig-bio { font-size: 0.9rem !important; }
            .profile-grid {
                grid-template-columns: repeat(3, 1fr) !important;
                gap: 2px !important;
            }
            .main-container { padding: 0 !important; }
            #settingsModal .modal-content {
                width: 95vw !important;
                max-width: 95vw !important;
                margin: 1rem auto !important;
            }
            .btn { font-size: 0.85rem !important; padding: 0.4rem 0.9rem !important; }
        }
        @media (max-width: 480px) {
            .ig-avatar { width: 70px !important; height: 70px !important; }
            .ig-stats { gap: 1rem !important; }
            .profile-grid { gap: 1px !important; }
        }
    </style>
</head>
<body>
    <jsp:include page="components/navbar.jsp" />

    <div class="main-container">
        <!-- Instagram Style Profile Header Section -->
        <div class="ig-profile-header">
            <div class="ig-avatar-section">
                <img src="${profileUser.profilePhoto != null && (profileUser.profilePhoto.startsWith('http') || profileUser.profilePhoto.startsWith('data:')) ? profileUser.profilePhoto : pageContext.request.contextPath.concat('/').concat(profileUser.profilePhoto != null ? profileUser.profilePhoto : 'images/default-avatar.png')}" 
                     class="ig-avatar clickable" alt="${profileUser.name}"
                     onclick="showProfilePhoto(this.src)">
                <h2 class="ig-username" style="margin-top: 1rem;">${profileUser.username}</h2>
            </div>
            
            <div class="ig-info-section">
                <div class="ig-bio-section" style="margin-bottom: 1.5rem;">
                    <div class="ig-full-name" style="font-size: 1.5rem; margin-bottom: 0.25rem;">${profileUser.name}</div>
                    <div class="ig-bio-text">${profileUser.bio != null ? profileUser.bio : "No bio available."}</div>
                    <div class="ig-joined-date" style="margin-top: 0.5rem;"><i class="far fa-calendar-alt"></i> Joined <fmt:formatDate value="${profileUser.createdAt}" pattern="MMMM yyyy" /></div>
                </div>

                <div class="ig-stats-row" style="margin-bottom: 1.5rem;">
                    <div class="ig-stat">
                        <strong>${postCount != null ? postCount : 0}</strong>
                        <span>posts</span>
                    </div>
                    <div class="ig-stat" onclick="handleFollowClick('followers', '${profileUser.userId}', '${canSeePosts != null ? canSeePosts : false}')">
                        <strong id="followers-count">${followersCount != null ? followersCount : 0}</strong>
                        <span>followers</span>
                    </div>
                    <div class="ig-stat" onclick="handleFollowClick('following', '${profileUser.userId}', '${canSeePosts != null ? canSeePosts : false}')">
                        <strong id="following-count">${followingCount != null ? followingCount : 0}</strong>
                        <span>following</span>
                    </div>
                </div>

                <div class="ig-user-row">
                    <c:choose>
                        <c:when test="${isSelf}">
                            <div style="display:flex; gap:0.5rem; align-items:center;">
                                <button class="btn btn-outline btn-sm" onclick="toggleEditModal()">Edit Profile</button>
                                <button class="action-btn" onclick="toggleSettingsModal()" title="Settings" style="padding:4px 8px; background:none; border:none; cursor:pointer;"><i class="fas fa-cog fa-lg"></i></button>
                            </div>
                        </c:when>
                        <c:otherwise>
                            <div style="display:flex; gap:0.5rem; align-items:center;">
                                <c:choose>
                                    <c:when test="${isFollowing}">
                                        <button class="btn btn-outline btn-sm" id="follow-action-btn" onclick="removeFollow('${profileUser.userId}', this)">Unfollow</button>
                                    </c:when>
                                    <c:when test="${isRequestPending}">
                                        <button class="btn btn-outline btn-sm" id="follow-action-btn" onclick="cancelFollowRequest('${profileUser.userId}', this)" style="background:var(--bg-light); color:var(--text-muted);">Requested</button>
                                    </c:when>
                                    <c:otherwise>
                                        <button class="btn btn-primary btn-sm" id="follow-action-btn" onclick="sendFollowRequest('${profileUser.userId}', this)">Follow</button>
                                    </c:otherwise>
                                </c:choose>
                                <c:if test="${isMutualFollowing}">
                                    <a href="MessageServlet?with=${profileUser.userId}" class="btn btn-outline btn-sm">Message</a>
                                </c:if>
                            </div>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>
        </div>

        <!-- Followers / Following List Modal -->
        <div id="followListModal" style="display:none; position:fixed; top:0; left:0; width:100%; height:100%; background:rgba(0,0,0,0.5); z-index:9999; align-items:center; justify-content:center;">
            <div class="card" style="width:100%; max-width:400px; max-height:70vh; display:flex; flex-direction:column; border-radius:12px; overflow:hidden; padding:0;">
                <div style="display:flex; align-items:center; justify-content:space-between; padding:1rem 1.25rem; border-bottom:1px solid var(--border-color); font-weight:700; font-size:1rem;">
                    <span id="followListTitle">Followers</span>
                    <button onclick="closeFollowListModal()" style="background:none; border:none; font-size:1.5rem; cursor:pointer; color:var(--text-muted); line-height:1;">&times;</button>
                </div>
                <div id="followListBody" style="overflow-y:auto; padding:0.5rem 0;">
                    <div style="padding:2rem; text-align:center; color:var(--text-muted);">Loading...</div>
                </div>
            </div>
        </div>
        <!-- End Follow List Modal -->

        <div class="ig-tabs">
            <div class="ig-tab active">
                <i class="fas fa-th"></i> POSTS
            </div>
        </div>

        <!-- User Posts Grid -->
        <div class="main-container" style="max-width: 935px; margin-top: 0;">
            <c:choose>
                <c:when test="${canSeePosts}">
                    <c:if test="${empty userPosts}">
                        <div class="card text-center" style="padding: 3rem; width: 100%;">
                            <i class="fas fa-camera fa-3x text-muted mb-3"></i>
                            <h3>No posts yet</h3>
                        </div>
                    </c:if>
                    
                    <div class="profile-grid">
                        <c:forEach var="userPost" items="${userPosts}">
                            <div class="grid-item" onclick="showPostDetail('${userPost.postId}')">
                                <c:if test="${userPost.pinned}">
                                    <div class="grid-pin">
                                        <i class="fas fa-thumbtack"></i>
                                    </div>
                                </c:if>
                                <c:choose>
                                    <c:when test="${not empty userPost.images}">
                                        <c:set var="firstImg" value="${userPost.images[0]}" />
                                        <img src="${firstImg.startsWith('http') ? firstImg : pageContext.request.contextPath.concat('/').concat(firstImg)}" alt="Post thumbnail">
                                    </c:when>
                                    <c:when test="${not empty userPost.image}">
                                        <img src="${userPost.image.startsWith('http') ? userPost.image : pageContext.request.contextPath.concat('/').concat(userPost.image)}" alt="Post thumbnail">
                                    </c:when>
                                    <c:otherwise>
                                        <img src="${pageContext.request.contextPath}/images/placeholder.png" alt="No image">
                                    </c:otherwise>
                                </c:choose>
                                <div class="grid-overlay">
                                    <span><i class="fas fa-heart"></i> ${userPost.likeCount}</span>
                                    <span><i class="fas fa-comment"></i> ${userPost.commentCount}</span>
                                </div>
                            </div>
                        </c:forEach>
                    </div>
                </c:when>
                <c:otherwise>
                    <!-- Private Account Placeholder -->
                    <div class="card text-center" style="padding: 4rem 2rem; width: 100%;">
                        <div style="width: 80px; height: 80px; border: 2px solid var(--text-muted); border-radius: 50%; display: flex; align-items: center; justify-content: center; margin: 0 auto 1.5rem;">
                            <i class="fas fa-lock fa-2x text-muted"></i>
                        </div>
                        <h3 style="margin-bottom: 0.5rem;">This account is private</h3>
                        <p class="text-muted">Follow this account to see their photos and videos.</p>
                    </div>
                </c:otherwise>
            </c:choose>
        </div>
    </div>

    <!-- Post Detail Modal -->
    <div id="postDetailModal" class="modal post-detail-modal">
        <div class="modal-content card" style="max-width: 650px; height: 90vh; display: flex; flex-direction: column;">
            <div class="modal-header" style="padding: 1rem; border-bottom: 1px solid var(--border-color); display: flex; justify-content: space-between; align-items: center;">
                <div style="display:flex; gap:1rem; align-items:center;">
                    <img src="" id="modal-user-avatar" class="post-avatar" style="width:40px; height:40px;">
                    <div>
                        <a href="#" id="modal-user-link" class="post-author" style="text-decoration:none; font-weight:700;"></a>
                        <div id="modal-post-time" class="post-time" style="font-size:0.75rem;"></div>
                    </div>
                </div>
                <div style="display:flex; gap:0.5rem; align-items:center;">
                    <div id="modal-post-options"></div>
                    <span class="close" onclick="closePostDetail()" style="position:static; font-size: 2rem;">&times;</span>
                </div>
            </div>

            <div class="modal-body" style="flex: 1; overflow-y: auto;">
                <div class="post-detail-media" id="modal-image-container" style="background: #000; display: flex; align-items: center; justify-content: center; position: relative;">
                    <!-- Carousel or single image injected here -->
                </div>

                <div style="padding: 1.25rem;">
                    <div id="modal-caption-area" style="margin-bottom: 1rem;">
                        <div id="modal-reactions-display" style="display:flex; gap:0.5rem; flex-wrap:wrap; margin-bottom:1rem;">
                            <!-- Emoji reactions icons go here -->
                        </div>
                        <div id="modal-caption-view">
                            <span id="modal-caption-text" style="font-size: 1rem; line-height: 1.5; white-space: pre-wrap;"></span>
                        </div>
                        <div id="modal-edit-view" style="display:none;">
                            <label style="font-weight:600; font-size: 0.85rem; display:block; margin-bottom:0.5rem;">Edit Aspect Ratio</label>
                            <div style="display:flex; gap:0.75rem; margin-bottom:1rem;">
                                <label class="ratio-btn-sm">
                                    <input type="radio" name="modalEditAspectRatio" value="1/1" style="display:none;" onchange="updateModalEditPreviews()">
                                    <div class="ratio-box-sm" style="aspect-ratio: 1/1; width: 30px; border: 2px solid #ddd; border-radius: 4px; display:flex; align-items:center; justify-content:center; cursor:pointer; font-size:10px;">1:1</div>
                                </label>
                                <label class="ratio-btn-sm">
                                    <input type="radio" name="modalEditAspectRatio" value="16/9" style="display:none;" onchange="updateModalEditPreviews()">
                                    <div class="ratio-box-sm" style="aspect-ratio: 16/9; width: 45px; border: 2px solid #ddd; border-radius: 4px; display:flex; align-items:center; justify-content:center; cursor:pointer; font-size:10px;">16:9</div>
                                </label>
                            </div>

                            <div id="modal-edit-previews" style="display:grid; grid-template-columns: repeat(auto-fill, minmax(80px, 1fr)); gap: 0.5rem; margin-bottom: 1rem;">
                                <!-- Adjustment previews go here -->
                            </div>

                            <label style="font-weight:600; font-size: 0.85rem; display:block; margin-bottom:0.5rem;">Edit Caption</label>
                            <textarea id="modal-edit-input" class="form-input" style="width:100%; min-height:80px; margin-bottom:1rem; font-family:inherit;"></textarea>
                            
                            <div style="display:flex; gap:0.5rem; border-top: 1px solid var(--border-color); padding-top: 1rem;">
                                <button class="btn btn-primary btn-sm" onclick="saveModalEditWithImages()">Save Changes</button>
                                <button class="btn btn-outline btn-sm" onclick="cancelModalEdit()">Cancel</button>
                            </div>
                        </div>
                    </div>

                    <div class="post-stats" style="display:flex; justify-content:space-between; margin-bottom: 1rem;">
                        <span style="font-weight:700;"><span id="modal-like-count">0</span> Likes</span>
                        <span id="modal-comment-count-text">0 Comments</span>
                    </div>

                    <div class="emoji-bar" style="display:flex; justify-content:space-around; padding: 0.5rem; background: var(--bg-light); border-radius: 8px; margin-bottom: 0.5rem;">
                        <span onclick="toggleReaction(window.currentModalPost.postId, '❤️')" style="cursor:pointer; font-size:1.2rem;" title="Heart">❤️</span>
                        <span onclick="toggleReaction(window.currentModalPost.postId, '🔥')" style="cursor:pointer; font-size:1.2rem;" title="Fire">🔥</span>
                        <span onclick="toggleReaction(window.currentModalPost.postId, '😂')" style="cursor:pointer; font-size:1.2rem;" title="Laugh">😂</span>
                        <span onclick="toggleReaction(window.currentModalPost.postId, '😮')" style="cursor:pointer; font-size:1.2rem;" title="Wow">😮</span>
                        <span onclick="toggleReaction(window.currentModalPost.postId, '👏')" style="cursor:pointer; font-size:1.2rem;" title="Clap">👏</span>
                        <span onclick="toggleReaction(window.currentModalPost.postId, '🙌')" style="cursor:pointer; font-size:1.2rem;" title="Hands Up">🙌</span>
                    </div>
                    <div class="post-actions border-top" style="display:flex; justify-content:space-between; padding: 0.75rem 0;">
                        <button class="action-btn" id="modal-like-btn" onclick="" style="flex:1;"><i class="far fa-heart"></i> Like</button>
                        <button class="action-btn" onclick="document.getElementById('modal-comment-input').focus()" style="flex:1;"><i class="far fa-comment"></i> Comment</button>
                        <button class="action-btn" onclick="openShareModal(window.currentModalPost.postId)" style="flex:1;"><i class="far fa-paper-plane"></i> Share</button>
                    </div>

                    <div id="modal-comments-area" class="border-top" style="padding-top: 1rem;">
                        <h4 style="font-size: 0.9rem; color: var(--text-muted); margin-bottom: 1rem;">Comments</h4>
                        <div id="modal-comments-list">
                            <!-- Comments injected here -->
                        </div>
                    </div>
                </div>
            </div>

            <div class="modal-footer" style="padding: 1rem; border-top: 1px solid var(--border-color); background: var(--bg-white);">
                <form onsubmit="handleModalComment(event)" style="display:flex; width:100%; gap:0.5rem; align-items:center;">
                    <input type="text" id="modal-comment-input" class="form-input" placeholder="Add a comment..." style="flex:9; border:none; background:var(--bg-light); padding:0.65rem 1rem; border-radius:20px; min-width:0;" required>
                    <button type="submit" class="btn btn-primary" style="flex:1; border-radius:20px; padding:0.65rem 0; font-size:0.85rem; white-space:nowrap; min-width:0; display:flex; align-items:center; justify-content:center;">Post</button>
                </form>
            </div>
        </div>
    </div>

    <!-- Edit Profile Modal -->
    <c:if test="${isSelf}">
    <div id="editProfileModal" class="modal">
        <div class="modal-content card" style="max-width:480px; padding:0; overflow:hidden; border-radius:16px;">
            <!-- Header with avatar preview -->
            <div style="background:linear-gradient(135deg,var(--primary-color),#ff6b81); padding:1.75rem 1.5rem 2.5rem; text-align:center; position:relative;">
                <button onclick="toggleEditModal()" style="position:absolute; top:12px; right:12px; background:rgba(255,255,255,0.2); border:none; color:white; width:32px; height:32px; border-radius:50%; cursor:pointer; font-size:1.1rem; display:flex; align-items:center; justify-content:center;">&times;</button>
                <div style="position:relative; display:inline-block; cursor:pointer;" onclick="document.getElementById('profilePhoto').click();" title="Click to change photo">
                    <img id="avatarPreview"
                         src="${profileUser.profilePhoto != null && (profileUser.profilePhoto.startsWith('http') || profileUser.profilePhoto.startsWith('data:')) ? profileUser.profilePhoto : pageContext.request.contextPath.concat('/').concat(profileUser.profilePhoto != null ? profileUser.profilePhoto : 'images/default-avatar.png')}"
                         style="width:80px; height:80px; border-radius:50%; object-fit:cover; border:3px solid rgba(255,255,255,0.8); box-shadow:0 4px 12px rgba(0,0,0,0.2);">
                    <div style="position:absolute; bottom:0; right:0; background:white; border-radius:50%; width:26px; height:26px; display:flex; align-items:center; justify-content:center; box-shadow:0 2px 6px rgba(0,0,0,0.2);">
                        <i class="fas fa-camera" style="font-size:0.7rem; color:var(--primary-color);"></i>
                    </div>
                </div>
                <h3 style="margin:0.75rem 0 0; color:white; font-size:1.15rem; font-weight:700;">Edit Profile</h3>
                <p style="margin:0.3rem 0 0; color:rgba(255,255,255,0.8); font-size:0.82rem;">@${profileUser.username}</p>
            </div>

            <form action="EditProfileServlet" method="POST" enctype="multipart/form-data" style="padding:1.25rem; display:flex; flex-direction:column; gap:0.9rem;">
                <!-- Hidden file input -->
                <input type="file" id="profilePhoto" name="profilePhoto" accept="image/*" style="display:none;" onchange="previewAvatar(this)">

                <!-- Name -->
                <div style="display:flex; flex-direction:column; gap:0.35rem;">
                    <label style="font-size:0.8rem; font-weight:700; color:var(--text-muted); text-transform:uppercase; letter-spacing:0.04em; display:flex; align-items:center; gap:0.4rem;">
                        <i class="fas fa-user" style="color:var(--primary-color); font-size:0.75rem;"></i> Full Name
                    </label>
                    <input class="form-input" type="text" name="name" value="${profileUser.name}"
                           style="border-radius:10px; padding:0.65rem 0.9rem; font-size:0.95rem;" placeholder="Your full name" required>
                </div>

                <!-- Bio -->
                <div style="display:flex; flex-direction:column; gap:0.35rem;">
                    <label style="font-size:0.8rem; font-weight:700; color:var(--text-muted); text-transform:uppercase; letter-spacing:0.04em; display:flex; align-items:center; gap:0.4rem;">
                        <i class="fas fa-align-left" style="color:var(--primary-color); font-size:0.75rem;"></i> Bio
                    </label>
                    <textarea class="form-input" name="bio" rows="3"
                              style="border-radius:10px; padding:0.65rem 0.9rem; font-size:0.95rem; resize:vertical; font-family:inherit;"
                              placeholder="Tell people a bit about yourself...">${profileUser.bio}</textarea>
                </div>

                <!-- Photo upload hint -->
                <div style="background:var(--bg-light); border-radius:10px; padding:0.75rem 1rem; display:flex; align-items:center; gap:0.6rem; cursor:pointer; border:2px dashed var(--border-color);" onclick="document.getElementById('profilePhoto').click();">
                    <i class="fas fa-image" style="color:var(--primary-color);"></i>
                    <span style="font-size:0.85rem; color:var(--text-muted);">Click to upload a new profile photo</span>
                    <i class="fas fa-upload" style="color:var(--text-muted); margin-left:auto;"></i>
                </div>

                <!-- Save button -->
                <button type="submit" style="width:100%; padding:0.75rem; background:linear-gradient(135deg,var(--primary-color),#ff6b81); color:white; border:none; border-radius:10px; cursor:pointer; font-weight:700; font-size:1rem; font-family:inherit; letter-spacing:0.01em; box-shadow:0 4px 12px rgba(255,71,87,0.3);">
                    <i class="fas fa-save"></i> Save Changes
                </button>
            </form>
        </div>
    </div>

    <!-- Settings Modal -->
    <div id="settingsModal" class="modal">
        <div class="modal-content card" style="max-width:420px; padding:0; overflow:hidden; border-radius:16px;">
            <!-- Header -->
            <div style="background: linear-gradient(135deg, var(--primary-color), #ff6b81); padding: 1.5rem; display:flex; justify-content:space-between; align-items:center;">
                <div style="display:flex; align-items:center; gap:0.75rem;">
                    <div style="width:40px; height:40px; border-radius:50%; background:rgba(255,255,255,0.2); display:flex; align-items:center; justify-content:center; color:white; font-size:1.1rem;">
                        <i class="fas fa-cog"></i>
                    </div>
                    <h2 style="margin:0; font-size:1.25rem; color:white; font-weight:700;">Settings</h2>
                </div>
                <button onclick="toggleSettingsModal()" style="background:rgba(255,255,255,0.2); border:none; color:white; width:32px; height:32px; border-radius:50%; cursor:pointer; font-size:1.1rem; display:flex; align-items:center; justify-content:center;">&times;</button>
            </div>

            <div style="padding:1.25rem; display:flex; flex-direction:column; gap:0.5rem;">
                <!-- Dark Mode -->
                <div style="display:flex; justify-content:space-between; align-items:center; padding:0.9rem 1rem; background:var(--bg-light); border-radius:12px;">
                    <div style="display:flex; align-items:center; gap:0.75rem;">
                        <div style="width:36px; height:36px; border-radius:10px; background:var(--primary-color); display:flex; align-items:center; justify-content:center; color:white;">
                            <i class="fas fa-moon"></i>
                        </div>
                        <div>
                            <div style="font-weight:600; font-size:0.95rem;">Dark Mode</div>
                            <small id="themeStatus" class="text-muted">Off</small>
                        </div>
                    </div>
                    <label class="switch">
                        <input type="checkbox" id="themeToggle" onchange="ThemeManager.toggle()">
                        <span class="slider round"></span>
                    </label>
                </div>

                <!-- Privacy -->
                <div style="display:flex; justify-content:space-between; align-items:center; padding:0.9rem 1rem; background:var(--bg-light); border-radius:12px;">
                    <div style="display:flex; align-items:center; gap:0.75rem;">
                        <div style="width:36px; height:36px; border-radius:10px; background:#6c63ff; display:flex; align-items:center; justify-content:center; color:white;">
                            <i class="fas fa-lock"></i>
                        </div>
                        <div>
                            <div style="font-weight:600; font-size:0.95rem;">Private Account</div>
                            <small id="privacyStatus" class="text-muted">${profileUser.privateAccount ? "Private" : "Public"}</small>
                        </div>
                    </div>
                    <label class="switch">
                        <input type="checkbox" id="privacyToggle" ${profileUser.privateAccount ? "checked" : ""} onchange="updatePrivacy(this.checked)">
                        <span class="slider round"></span>
                    </label>
                </div>

                <!-- Change Password -->
                <div style="padding:0.9rem 1rem; background:var(--bg-light); border-radius:12px;">
                    <div style="display:flex; align-items:center; gap:0.75rem; margin-bottom:0.75rem;">
                        <div style="width:36px; height:36px; border-radius:10px; background:#00b894; display:flex; align-items:center; justify-content:center; color:white;">
                            <i class="fas fa-key"></i>
                        </div>
                        <div style="font-weight:600; font-size:0.95rem;">Change Password</div>
                    </div>
                    <form id="passwordForm" onsubmit="updatePassword(event)">
                        <input type="password" id="currentPassword" placeholder="Current Password" class="form-input" style="margin-bottom:0.5rem;" required>
                        <input type="password" id="newPassword" placeholder="New Password" class="form-input" style="margin-bottom:0.5rem;" required>
                        <button type="submit" style="width:100%; padding:0.6rem; background:linear-gradient(135deg,var(--primary-color),#ff6b81); color:white; border:none; border-radius:8px; cursor:pointer; font-weight:600; font-size:0.9rem; font-family:inherit;">Update Password</button>
                    </form>
                    <div id="passwordMessage" style="font-size:0.8rem; margin-top:0.3rem;"></div>
                </div>

                <!-- Logout -->
                <button type="button" onclick="confirmLogout()" style="display:flex; align-items:center; gap:0.75rem; padding:0.9rem 1rem; background:var(--bg-light); border-radius:12px; border:none; cursor:pointer; width:100%; text-align:left; color:var(--text-main);">
                    <div style="width:36px; height:36px; border-radius:10px; background:#fdcb6e; display:flex; align-items:center; justify-content:center; color:white;">
                        <i class="fas fa-sign-out-alt"></i>
                    </div>
                    <span style="font-weight:600; font-size:0.95rem;">Logout</span>
                </button>

                <!-- Danger Zone: Delete Account -->
                <div style="margin-top:0.5rem; border:2px solid var(--danger-color); border-radius:12px; padding:0.9rem 1rem; background:rgba(255,71,87,0.04);">
                    <div style="display:flex; align-items:center; gap:0.5rem; margin-bottom:0.6rem; color:var(--danger-color); font-weight:700; font-size:0.85rem;">
                        <i class="fas fa-exclamation-triangle"></i> Danger Zone
                    </div>
                    <form action="DeleteAccountServlet" method="POST" onsubmit="return confirm('⚠️ This will permanently delete your account, all posts, and messages. This CANNOT be undone. Are you sure?');">
                        <button type="submit" style="width:100%; padding:0.65rem; background:#ff3547; color:#ffffff !important; border:2px solid #cc0000; border-radius:8px; cursor:pointer; font-weight:700; display:flex; align-items:center; justify-content:center; gap:0.5rem; font-size:0.9rem; letter-spacing:0.02em;">
                            <i class="fas fa-user-slash"></i> ⚠ Delete Account Permanently
                        </button>
                    </form>
                </div>
            </div>
        </div>
    </div>
    </c:if>
    
    <!-- Follow Modal (Global) -->
    <div id="followModal" class="modal">
        <div class="modal-content card" style="max-width:400px;">
            <span class="close" onclick="closeFollowModal()">&times;</span>
            <h2 id="followModalTitle">Users</h2>
            <div id="followModalContent" style="margin-top:1.5rem; max-height: 400px; overflow-y:auto; padding-right:0.5rem;">
                <div class="text-center text-muted"><i class="fas fa-spinner fa-spin"></i> Loading...</div>
            </div>
        </div>
    </div>

    <!-- Switch CSS -->
    <style>
        .switch { position: relative; display: inline-block; width: 46px; height: 24px; }
        .switch input { opacity: 0; width: 0; height: 0; }
        .slider { position: absolute; cursor: pointer; top: 0; left: 0; right: 0; bottom: 0; background-color: #ccc; transition: .4s; border-radius: 34px; }
        .slider:before { position: absolute; content: ""; height: 18px; width: 18px; left: 3px; bottom: 3px; background-color: white; transition: .4s; border-radius: 50%; }
        input:checked + .slider { background-color: var(--primary-color); }
        input:checked + .slider:before { transform: translateX(22px); }
        .setting-item { transition: background 0.2s; }
    </style>
    
    <script>
        const contextPath = '${pageContext.request.contextPath}';
        window.contextPath = contextPath;
        window.loggedInUserId = parseInt("${sessionScope.user.userId}");
        window.currentProfileUserId = "${profileUser.userId}";

        function showProfilePhoto(imgSrc) {
            const modal = document.getElementById('profilePhotoModal');
            const img = document.getElementById('fullProfilePhoto');
            img.src = imgSrc;
            modal.style.display = 'flex';
        }

        function closeProfilePhoto() {
            document.getElementById('profilePhotoModal').style.display = 'none';
        }

        function showFollowModal(type, targetId) {
            const title = document.getElementById('followModalTitle');
            const container = document.getElementById('followModalContent');
            
            title.innerText = type === 'followers' ? 'Followers' : 'Following';
            container.innerHTML = '<div class="text-center text-muted" style="padding:2rem;"><i class="fas fa-spinner fa-spin fa-2x"></i></div>';
            modal.style.display = 'flex';
            
            const actionUrl = type === 'followers' ? 'getFollowers' : 'getFollowing';
            
            fetch(contextPath + '/InteractionServlet', {
                method: 'POST',
                headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                body: 'action=' + actionUrl + '&targetId=' + targetId
            })
            .then(res => res.json())
            .then(users => {
                if(users.length === 0) {
                    container.innerHTML = '<div class="text-center text-muted" style="padding:2rem;">No users found.</div>';
                    return;
                }
                
                let html = '';
                users.forEach(u => {
                    const avatar = getImageUrl(u.photo || 'images/default-avatar.png');
                    html += '<div style="display:flex; align-items:center; gap:1rem; padding:0.5rem 0; border-bottom:1px solid #eee;">' +
                                '<img src="' + avatar + '" style="width:40px; height:40px; border-radius:50%; object-fit:cover;">' +
                                '<div style="flex:1;">' +
                                    '<a href="' + contextPath + '/ProfileServlet?id=' + u.userId + '" style="font-weight:600; color:var(--text-color); text-decoration:none;">' + u.name + '</a>' +
                                    '<div style="font-size:0.85rem; color:var(--text-muted);">@' + u.username + '</div>' +
                                '</div>' +
                            '</div>';
                });
                container.innerHTML = html;
            })
            .catch(err => {
                container.innerHTML = '<div class="text-danger text-center" style="padding:2rem;">Failed to load users.</div>';
            });
        }
        
        function closeFollowModal() {
            document.getElementById('followModal').style.display = 'none';
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
function toggleEditModal() {
            const modal = document.getElementById('editProfileModal');
            if(modal) modal.style.display = modal.style.display === 'flex' ? 'none' : 'flex';
        }

        function toggleSettingsModal() {
            const modal = document.getElementById('settingsModal');
            if(modal) modal.style.display = modal.style.display === 'flex' ? 'none' : 'flex';
        }

        function updatePrivacy(isPrivate) {
            const statusText = document.getElementById('privacyStatus');
            fetch(contextPath + '/SettingsServlet', {
                method: 'POST',
                headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                body: 'action=privacy&isPrivate=' + isPrivate
            }).then(res => res.text()).then(data => {
                if(data === 'success') {
                    statusText.innerText = isPrivate ? "Private Account" : "Public Account";
                } else {
                    alert("Failed to update privacy.");
                    document.getElementById('privacyToggle').checked = !isPrivate;
                }
            });
        }

        function updatePassword(e) {
            e.preventDefault();
            const currentPassword = document.getElementById('currentPassword').value;
            const newPassword = document.getElementById('newPassword').value;
            const msgDiv = document.getElementById('passwordMessage');
            
            msgDiv.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Updating...';
            msgDiv.className = 'text-muted';

            fetch(contextPath + '/SettingsServlet', {
                method: 'POST',
                headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                body: 'action=password&currentPassword=' + encodeURIComponent(currentPassword) + '&newPassword=' + encodeURIComponent(newPassword)
            }).then(res => res.text()).then(data => {
                if(data === 'success') {
                    msgDiv.innerText = 'Password updated successfully!';
                    msgDiv.className = 'text-success';
                    document.getElementById('passwordForm').reset();
                } else {
                    msgDiv.innerText = data;
                    msgDiv.className = 'text-danger';
                }
            });
        }
    </script>

    <!-- Profile Photo View Modal -->
    <div id="profilePhotoModal" class="modal" onclick="closeProfilePhoto()" style="display: none; background: rgba(0,0,0,0.9); z-index: 2000;">
        <span class="close" onclick="closeProfilePhoto()" style="color: white; top: 20px; right: 30px; font-size: 40px;">&times;</span>
        <div class="modal-content" style="background: none; border: none; box-shadow: none; display: flex; justify-content: center; align-items: center; max-width: 90vw; max-height: 90vh;">
            <img id="fullProfilePhoto" src="" style="max-width: 100%; max-height: 90vh; border-radius: 8px; object-fit: contain;">
        </div>
    </div>

    <!-- Cropping Modal (Shared) -->
    <div id="cropModal" class="modal" style="display:none; align-items:center; justify-content:center; background:rgba(0,0,0,0.85); z-index:5000;">
        <div class="modal-content card" style="max-width:500px; width:95%; padding:1.5rem;">
            <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:1.5rem;">
                <h3 style="margin:0;">Adjust Image</h3>
                <span class="close" onclick="closeCropModal()" style="font-size:1.5rem; cursor:pointer;">&times;</span>
            </div>
            
            <div id="cropContainer" style="width:100%; background:#000; overflow:hidden; border-radius:8px; position:relative; cursor:move; user-select:none;">
                <img id="cropImg" src="" style="position:absolute; top:0; left:0; pointer-events:none;">
                <div style="position:absolute; top:0; left:0; width:100%; height:100%; box-shadow: 0 0 0 1000px rgba(0,0,0,0.5); pointer-events:none; border: 2px solid var(--primary-color);"></div>
            </div>

            <div style="margin-top:1.5rem; text-align:center;">
                <div style="display:flex; align-items:center; justify-content:center; gap:1rem; margin-bottom:1rem;">
                    <i class="fas fa-search-minus text-muted"></i>
                    <input type="range" id="zoomSlider" min="1" max="3" step="0.01" value="1" style="flex:1;">
                    <i class="fas fa-search-plus text-muted"></i>
                </div>
                <small class="text-muted d-block mb-3">Drag the image to position it</small>
function toggleEditModal() {
            const modal = document.getElementById('editProfileModal');
            if(modal) modal.style.display = modal.style.display === 'flex' ? 'none' : 'flex';
        }

        function toggleSettingsModal() {
            const modal = document.getElementById('settingsModal');
            if(modal) modal.style.display = modal.style.display === 'flex' ? 'none' : 'flex';
        }

        function updatePrivacy(isPrivate) {
            const statusText = document.getElementById('privacyStatus');
            fetch(contextPath + '/SettingsServlet', {
                method: 'POST',
                headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                body: 'action=privacy&isPrivate=' + isPrivate
            }).then(res => res.text()).then(data => {
                if(data === 'success') {
                    statusText.innerText = isPrivate ? "Private Account" : "Public Account";
                } else {
                    alert("Failed to update privacy.");
                    document.getElementById('privacyToggle').checked = !isPrivate;
                }
            });
        }

        function updatePassword(e) {
            e.preventDefault();
            const currentPassword = document.getElementById('currentPassword').value;
            const newPassword = document.getElementById('newPassword').value;
            const msgDiv = document.getElementById('passwordMessage');
            
            msgDiv.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Updating...';
            msgDiv.className = 'text-muted';

            fetch(contextPath + '/SettingsServlet', {
                method: 'POST',
                headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                body: 'action=password&currentPassword=' + encodeURIComponent(currentPassword) + '&newPassword=' + encodeURIComponent(newPassword)
            }).then(res => res.text()).then(data => {
                if(data === 'success') {
                    msgDiv.innerText = 'Password updated successfully!';
                    msgDiv.className = 'text-success';
                    document.getElementById('passwordForm').reset();
                } else {
                    msgDiv.innerText = data;
                    msgDiv.className = 'text-danger';
                }
            });
        }
    </script>

    <!-- Profile Photo View Modal -->
    <div id="profilePhotoModal" class="modal" onclick="closeProfilePhoto()" style="display: none; background: rgba(0,0,0,0.9); z-index: 2000;">
        <span class="close" onclick="closeProfilePhoto()" style="color: white; top: 20px; right: 30px; font-size: 40px;">&times;</span>
        <div class="modal-content" style="background: none; border: none; box-shadow: none; display: flex; justify-content: center; align-items: center; max-width: 90vw; max-height: 90vh;">
            <img id="fullProfilePhoto" src="" style="max-width: 100%; max-height: 90vh; border-radius: 8px; object-fit: contain;">
        </div>
    </div>

    <!-- Cropping Modal (Shared) -->
    <div id="cropModal" class="modal" style="display:none; align-items:center; justify-content:center; background:rgba(0,0,0,0.85); z-index:5000;">
        <div class="modal-content card" style="max-width:500px; width:95%; padding:1.5rem;">
            <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:1.5rem;">
                <h3 style="margin:0;">Adjust Image</h3>
                <span class="close" onclick="closeCropModal()" style="font-size:1.5rem; cursor:pointer;">&times;</span>
            </div>
            
            <div id="cropContainer" style="width:100%; background:#000; overflow:hidden; border-radius:8px; position:relative; cursor:move; user-select:none;">
                <img id="cropImg" src="" style="position:absolute; top:0; left:0; pointer-events:none;">
                <div style="position:absolute; top:0; left:0; width:100%; height:100%; box-shadow: 0 0 0 1000px rgba(0,0,0,0.5); pointer-events:none; border: 2px solid var(--primary-color);"></div>
            </div>

            <div style="margin-top:1.5rem; text-align:center;">
                <div style="display:flex; align-items:center; justify-content:center; gap:1rem; margin-bottom:1rem;">
                    <i class="fas fa-search-minus text-muted"></i>
                    <input type="range" id="zoomSlider" min="1" max="3" step="0.01" value="1" style="flex:1;">
                    <i class="fas fa-search-plus text-muted"></i>
                </div>
                <small class="text-muted d-block mb-3">Drag the image to position it</small>
                <button type="button" class="btn btn-primary w-100" onclick="saveEditCrop()">Apply Adjustment</button>
            </div>
        </div>
    </div>

    <!-- Core App JS -->
    <script>
        window.contextPath = '${pageContext.request.contextPath}';
        window.loggedInUserId = '${sessionScope.user.userId}';
        window.currentProfileUserId = '${profileUser.userId}';
    </script>
    <script src="${pageContext.request.contextPath}/js/app_v2.js?v=20260317"></script>

</body>
</html>
