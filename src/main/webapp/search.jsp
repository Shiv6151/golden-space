<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Search - SocialConnect</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="css/styles.css?v=<%= System.currentTimeMillis() %>">
    <link rel="stylesheet" href="css/app.css?v=<%= System.currentTimeMillis() %>">
    <style>
        .search-page-container { max-width: 800px; margin: 2rem auto; padding: 0 1rem; }
        .hero-search-form { display: flex; align-items: center; background: var(--bg-light); border-radius: 30px; padding: 0.5rem 1.5rem; border: 1px solid var(--border-color); margin-bottom: 2rem; }
        .hero-search-form input { flex: 1; border: none; background: transparent; padding: 0.8rem; font-size: 1.1rem; color: var(--text-color); outline: none; }
        .hero-search-form button { background: none; border: none; color: var(--text-muted); cursor: pointer; font-size: 1.2rem; }
        
        /* Nav Pills for Tabs */
        .search-tabs { display: flex; gap: 1rem; border-bottom: 1px solid var(--border-color); margin-bottom: 1.5rem; }
        .search-tab { padding: 0.75rem 1.5rem; cursor: pointer; color: var(--text-muted); font-weight: 600; border-bottom: 2px solid transparent; }
        .search-tab.active { color: var(--primary-color); border-bottom-color: var(--primary-color); }
        
        /* User Results */
        .user-card { display: flex; align-items: center; justify-content: space-between; padding: 1rem; margin-bottom: 1rem; background: var(--bg-card); border-radius: 12px; border: 1px solid var(--border-color); }
        .user-info { display: flex; align-items: center; gap: 1rem; }
        .user-avatar { width: 50px; height: 50px; border-radius: 50%; object-fit: cover; }
        .user-name { font-weight: 600; font-size: 1rem; color: var(--text-color); text-decoration: none; }
        
        /* Post Grid */
        .post-grid { display: grid; grid-template-columns: repeat(3, 1fr); gap: 4px; }
        .grid-item { position: relative; aspect-ratio: 1/1; background: var(--bg-light); overflow: hidden; cursor: pointer; }
        .grid-item img { width: 100%; height: 100%; object-fit: cover; }
        .grid-item-overlay { position: absolute; top: 0; left: 0; width: 100%; height: 100%; background: rgba(0,0,0,0.4); display: flex; align-items: center; justify-content: center; opacity: 0; transition: opacity 0.2s; color: white; font-weight: 600; gap: 1rem; }
        .grid-item:hover .grid-item-overlay { opacity: 1; }
        
        /* Mobile adjustment */
        @media (max-width: 600px) {
            .hero-search-form input { font-size: 1rem; }
            .post-grid { gap: 2px; }
        }
    </style>
</head>
<body>
    <jsp:include page="components/navbar.jsp" />

    <div class="search-page-container mt-4 pt-4">
        <!-- Search Bar -->
        <form action="${pageContext.request.contextPath}/SearchServlet" method="GET" class="hero-search-form">
            <i class="fas fa-search text-muted"></i>
            <input type="text" name="query" value="${searchQuery}" placeholder="Search friends or type #hashtag..." autofocus required>
            <button type="submit"><i class="fas fa-arrow-right"></i></button>
        </form>

        <c:choose>
            <c:when test="${not empty searchQuery}">
                <div class="search-tabs">
                    <div class="search-tab active" onclick="switchTab('users')" id="tab-users">Users (${searchResults.size()})</div>
                    <div class="search-tab" onclick="switchTab('posts')" id="tab-posts">Hashtags (${postResults.size()})</div>
                </div>

                <!-- Users View -->
                <div id="view-users">
                    <c:if test="${empty searchResults}">
                        <div class="text-center p-5 text-muted">No users found for "${searchQuery}"</div>
                    </c:if>
                    <c:forEach var="user" items="${searchResults}">
                        <div class="user-card">
                            <div class="user-info">
                                <img src="${user.profilePhoto != null && user.profilePhoto.startsWith('http') ? user.profilePhoto : pageContext.request.contextPath.concat('/').concat(user.profilePhoto != null ? user.profilePhoto : 'images/default-avatar.png')}" alt="${user.name}" class="user-avatar">
                                <div>
                                    <a href="ProfileServlet?id=${user.userId}" class="user-name">${user.name}</a>
                                    <div class="text-muted" style="font-size:0.85rem;">@${user.username}</div>
                                </div>
                            </div>
                            <div class="user-actions">
                                <form action="FollowServlet" method="POST">
                                    <input type="hidden" name="action" value="toggle">
                                    <input type="hidden" name="targetId" value="${user.userId}">
                                    <c:choose>
                                        <c:when test="${user.followedByMe}">
                                            <button type="submit" class="btn btn-outline" style="border-color: #ddd; color: var(--text-muted); padding: 0.4rem 1rem;">Unfollow</button>
                                        </c:when>
                                        <c:otherwise>
                                            <button type="submit" class="btn btn-primary" style="padding: 0.4rem 1rem;">Follow</button>
                                        </c:otherwise>
                                    </c:choose>
                                </form>
                            </div>
                        </div>
                    </c:forEach>
                </div>

                <!-- Posts View -->
                <div id="view-posts" style="display:none;">
                    <c:if test="${empty postResults}">
                        <div class="text-center p-5 text-muted">No posts found containing "${searchQuery}"</div>
                    </c:if>
                    <div class="post-grid">
                        <c:forEach var="post" items="${postResults}">
                            <div class="grid-item" onclick="showPostDetail(${post.postId})">
                                <c:choose>
                                    <c:when test="${not empty post.images}">
                                        <img src="${post.images[0] != null && post.images[0].startsWith('http') ? post.images[0] : pageContext.request.contextPath.concat('/').concat(post.images[0])}">
                                    </c:when>
                                    <c:otherwise>
                                        <div style="width:100%; height:100%; padding:1rem; display:flex; align-items:center; justify-content:center; text-align:center; font-size:0.9rem; background:var(--bg-card); color:var(--text-color);">
                                            ${post.postContent.length() > 50 ? post.postContent.substring(0, 50).concat('...') : post.postContent}
                                        </div>
                                    </c:otherwise>
                                </c:choose>
                                <div class="grid-item-overlay">
                                    <span><i class="fas fa-heart"></i> ${post.likeCount}</span>
                                    <span><i class="fas fa-comment"></i> ${post.commentCount}</span>
                                </div>
                            </div>
                        </c:forEach>
                    </div>
                </div>
            </c:when>
            <c:otherwise>
                <!-- Initial State (No Search) -->
                <div class="text-center" style="padding: 4rem 0;">
                    <i class="fas fa-search fa-3x text-muted mb-3" style="opacity: 0.5;"></i>
                    <h3 style="color: var(--text-muted); font-weight: 500;">Find your friends and topics</h3>
                    <p style="color: var(--text-muted); font-size: 0.95rem;">Search by names, handles, or #hashtags.</p>
                </div>
            </c:otherwise>
        </c:choose>
    </div>

    <!-- Post Detail Modal Overlay -->
    <div id="postDetailModal" class="modal" style="display:none; align-items:center; justify-content:center; background:rgba(0,0,0,0.85); z-index:2000;">
        <div class="modal-content" style="max-width:1000px; width:95%; height:85vh; display:flex; flex-direction:row; background:var(--bg-card); overflow:hidden; border-radius:12px;">
            <!-- Left: Image -->
            <div id="modal-image-container" style="flex:1.5; background:#000; display:flex; align-items:center; justify-content:center; position:relative;">
                <!-- Filled dynamically -->
            </div>
            
            <!-- Right: Details -->
            <div style="flex:1; display:flex; flex-direction:column; border-left:1px solid var(--border-color); max-width: 400px; background: var(--bg-card);">
                <!-- Header -->
                <div style="padding:1rem; border-bottom:1px solid var(--border-color); display:flex; align-items:center; justify-content:space-between;">
                    <div style="display:flex; align-items:center; gap:0.75rem;">
                        <img id="modal-user-avatar" src="" style="width:36px; height:36px; border-radius:50%; object-fit:cover;">
                        <a id="modal-user-link" href="#" style="font-weight:600; color:var(--text-color); text-decoration:none;"></a>
                    </div>
                    <div style="display: flex; gap: 1rem; align-items: center;">
                        <div id="modal-post-options"></div>
                        <span class="close" onclick="closePostDetail()" style="font-size:1.5rem; cursor:pointer; color:var(--text-muted);">&times;</span>
                    </div>
                </div>
                
                <!-- Comments/Caption Area -->
                <div style="flex:1; overflow-y:auto; padding:1rem; display:flex; flex-direction:column; gap:1rem;">
                    <!-- Normal View -->
                    <div id="modal-caption-view">
                        <div id="modal-caption-text" style="font-size:0.95rem; line-height:1.5;"></div>
                        <div id="modal-post-time" class="text-muted" style="font-size:0.8rem; margin-top:0.5rem; margin-bottom: 1rem;"></div>
                        <hr style="border: 0; border-top: 1px solid var(--border-color); margin: 0 -1rem 1rem -1rem;">
                        <div id="modal-comments-list"></div>
                    </div>
                </div>
                
                <!-- Footer actions -->
                <div style="padding:1rem; border-top:1px solid var(--border-color);">
                    <div style="display:flex; gap:1.5rem; margin-bottom:0.75rem;">
                        <button id="modal-like-btn" class="action-btn text-muted" style="font-size:1.5rem; padding:0;"></button>
                        <button class="action-btn text-muted" style="font-size:1.5rem; padding:0;"><i class="far fa-comment"></i></button>
                    </div>
                    <div style="font-weight:600; font-size:0.95rem; margin-bottom:0.25rem;"><span id="modal-like-count"></span> likes</div>
                    <div id="modal-comment-count-text" class="text-muted" style="font-size:0.85rem; margin-bottom:1rem;"></div>
                    
                    <form onsubmit="handleModalComment(event)" style="display:flex; gap:0.5rem; align-items:center;">
                        <i class="far fa-smile text-muted" style="font-size:1.2rem;"></i>
                        <input type="text" id="modal-comment-input" placeholder="Add a comment..." style="flex:1; border:none; background:transparent; font-size:0.95rem; outline:none; color:var(--text-color);">
                        <button type="submit" style="border:none; background:none; color:var(--primary-color); font-weight:600; cursor:pointer;">Post</button>
                    </form>
                </div>
            </div>
        </div>
    </div>

    <script src="${pageContext.request.contextPath}/js/app_v2.js?v=<%= System.currentTimeMillis() %>"></script>
    <script>
        function switchTab(tab) {
            document.getElementById('view-users').style.display = tab === 'users' ? 'block' : 'none';
            document.getElementById('view-posts').style.display = tab === 'posts' ? 'block' : 'none';
            
            document.getElementById('tab-users').classList.toggle('active', tab === 'users');
            document.getElementById('tab-posts').classList.toggle('active', tab === 'posts');
        }
    </script>
</body>
</html>
