<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.fmt" prefix="fmt" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Search - Golden Space</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="css/styles.css?v=<%= System.currentTimeMillis() %>">
    <link rel="stylesheet" href="css/app.css?v=<%= System.currentTimeMillis() %>">
    <style>
        .search-page-container { max-width: 680px; margin: 2rem auto; padding: 0 1rem; }
        .hero-search-form { display: flex; align-items: center; background: var(--bg-light); border-radius: 30px; padding: 0.5rem 1.5rem; border: 1px solid var(--border-color); margin-bottom: 2rem; }
        .hero-search-form input { flex: 1; border: none; background: transparent; padding: 0.8rem; font-size: 1.1rem; color: var(--text-color); outline: none; }
        .hero-search-form button { background: none; border: none; color: var(--text-muted); cursor: pointer; font-size: 1.2rem; }
        .search-tabs { display: flex; gap: 1rem; border-bottom: 1px solid var(--border-color); margin-bottom: 1.5rem; }
        .search-tab { padding: 0.75rem 1.5rem; cursor: pointer; color: var(--text-muted); font-weight: 600; border-bottom: 2px solid transparent; transition: all 0.2s; }
        .search-tab.active { color: var(--primary-color); border-bottom-color: var(--primary-color); }
        .user-card { display: flex; align-items: center; justify-content: space-between; padding: 1rem; margin-bottom: 0.75rem; background: var(--bg-white); border-radius: 12px; border: 1px solid var(--border-color); }
        .user-info { display: flex; align-items: center; gap: 1rem; }
        .user-avatar { width: 50px; height: 50px; border-radius: 50%; object-fit: cover; }
        .user-name { font-weight: 600; font-size: 1rem; color: var(--text-color); text-decoration: none; }
        @media (max-width: 600px) {
            .hero-search-form input { font-size: 1rem; }
            .search-page-container { padding: 0 0.5rem; }
        }
    </style>
</head>
<body>
    <jsp:include page="components/navbar.jsp" />

    <div class="search-page-container mt-4 pt-4">
        <!-- Search Bar -->
        <form action="${pageContext.request.contextPath}/SearchServlet" method="GET" class="hero-search-form">
            <i class="fas fa-search text-muted"></i>
            <input type="text" name="query" value="${searchQuery}" placeholder="Search friends or type #hashtag..." autofocus>
            <button type="submit" title="Search"><i class="fas fa-arrow-right"></i></button>
        </form>

        <c:choose>
            <c:when test="${not empty searchQuery}">
                <div class="search-tabs">
                    <div class="search-tab active" onclick="switchTab('users')" id="tab-users">
                        <i class="fas fa-users"></i> Users (${searchResults.size()})
                    </div>
                    <div class="search-tab" onclick="switchTab('posts')" id="tab-posts">
                        <i class="fas fa-hashtag"></i> Posts (${postResults.size()})
                    </div>
                </div>

                <!-- Users View -->
                <div id="view-users">
                    <c:if test="${empty searchResults}">
                        <div class="text-center" style="padding:3rem; color:var(--text-muted);">No users found for "${searchQuery}"</div>
                    </c:if>
                    <c:forEach var="user" items="${searchResults}">
                        <div class="user-card">
                            <div class="user-info">
                                <img src="${user.profilePhoto != null && user.profilePhoto.startsWith('http') ? user.profilePhoto : pageContext.request.contextPath.concat('/').concat(user.profilePhoto != null ? user.profilePhoto : 'images/default-avatar.png')}"
                                     alt="${user.name}" class="user-avatar">
                                <div>
                                    <a href="ProfileServlet?id=${user.userId}" class="user-name">${user.name}</a>
                                    <div class="text-muted" style="font-size:0.85rem;">@${user.username}</div>
                                </div>
                            </div>
                            <div>
                                <c:choose>
                                    <c:when test="${user.followedByMe}">
                                        <button class="btn btn-outline btn-sm" onclick="toggleFollow(${user.userId}, this)" title="Unfollow">Unfollow</button>
                                    </c:when>
                                    <c:otherwise>
                                        <button class="btn btn-primary btn-sm" onclick="toggleFollow(${user.userId}, this)" title="Follow">Follow</button>
                                    </c:otherwise>
                                </c:choose>
                            </div>
                        </div>
                    </c:forEach>
                </div>

                <!-- Posts View — full feed style using post.jsp component -->
                <div id="view-posts" style="display:none;">
                    <c:if test="${empty postResults}">
                        <div class="text-center" style="padding:3rem;">
                            <i class="fas fa-hashtag" style="font-size:3rem; opacity:0.3; margin-bottom:1rem; display:block; color:var(--primary-color);"></i>
                            <p class="text-muted">No posts found for "${searchQuery}"</p>
                        </div>
                    </c:if>
                    <c:forEach var="post" items="${postResults}">
                        <jsp:include page="components/post.jsp">
                            <jsp:param name="postId" value="${post.postId}"/>
                        </jsp:include>
                    </c:forEach>
                </div>
            </c:when>
            <c:otherwise>
                <div class="text-center" style="padding: 4rem 0;">
                    <i class="fas fa-search fa-3x" style="opacity:0.3; display:block; margin-bottom:1rem; color:var(--primary-color);"></i>
                    <h3 style="color: var(--text-muted); font-weight: 500;">Find friends and topics</h3>
                    <p style="color: var(--text-muted); font-size: 0.95rem;">Search by names, handles, or #hashtags.</p>
                </div>
            </c:otherwise>
        </c:choose>
    </div>

    <script src="${pageContext.request.contextPath}/js/app_v2.js?v=<%= System.currentTimeMillis() %>"></script>
    <script>
        window.contextPath = '${pageContext.request.contextPath}';
        function switchTab(tab) {
            document.getElementById('view-users').style.display = tab === 'users' ? 'block' : 'none';
            document.getElementById('view-posts').style.display = tab === 'posts' ? 'block' : 'none';
            document.getElementById('tab-users').classList.toggle('active', tab === 'users');
            document.getElementById('tab-posts').classList.toggle('active', tab === 'posts');
        }
    </script>
</body>
</html>
