<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Search Results - SocialConnect</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="css/styles.css?v=<%= System.currentTimeMillis() %>">
    <link rel="stylesheet" href="css/app.css?v=<%= System.currentTimeMillis() %>">
    <style>
        .search-container { max-width: 800px; margin: 2rem auto; padding: 0 1rem; }
        .user-card { display: flex; align-items: center; justify-content: space-between; padding: 1.5rem; margin-bottom: 1rem; }
        .user-info { display: flex; align-items: center; gap: 1rem; }
        .user-avatar { width: 60px; height: 60px; border-radius: 50%; object-fit: cover; }
        .user-name { font-weight: 600; font-size: 1.1rem; color: var(--text-color); text-decoration: none; }
        .user-name:hover { text-decoration: underline; }
    </style>
</head>
<body>
    <jsp:include page="components/navbar.jsp" />

    <div class="search-container">
        <h2>Search Results for "${searchQuery}"</h2>
        
        <c:if test="${empty searchResults}">
            <div class="card text-center p-5 mt-4">
                <i class="fas fa-search fa-3x text-muted mb-3"></i>
                <h3 class="text-muted">No users found.</h3>
                <p>We couldn't find any matches for that name.</p>
            </div>
        </c:if>
        
        <div class="mt-4">
            <c:forEach var="user" items="${searchResults}">
                <c:if test="${user.userId ne sessionScope.user.userId}">
                    <div class="card user-card">
                        <div class="user-info">
                            <img src="${user.profilePhoto != null && user.profilePhoto.startsWith('http') ? user.profilePhoto : pageContext.request.contextPath.concat('/').concat(user.profilePhoto != null ? user.profilePhoto : 'images/default-avatar.png')}" alt="${user.name}" class="user-avatar">
                            <div>
                                <a href="ProfileServlet?id=${user.userId}" class="user-name">@${user.name}</a>
                                <p class="text-muted" style="margin: 0; font-size: 0.9rem;">${user.bio != null ? user.bio : "No bio available"}</p>
                            </div>
                        </div>
                        <div class="user-actions">
                            <form action="FollowServlet" method="POST">
                                <input type="hidden" name="action" value="toggle">
                                <input type="hidden" name="targetId" value="${user.userId}">
                                <c:choose>
                                    <c:when test="${user.followedByMe}">
                                        <button type="submit" class="btn btn-outline" style="border-color: #ddd; color: var(--text-muted);">
                                            <i class="fas fa-user-minus"></i> Unfollow
                                        </button>
                                    </c:when>
                                    <c:otherwise>
                                        <button type="submit" class="btn btn-primary">
                                            <i class="fas fa-user-plus"></i> Follow
                                        </button>
                                    </c:otherwise>
                                </c:choose>
                            </form>
                        </div>
                    </div>
                </c:if>
            </c:forEach>
        </div>
    </div>
</body>
</html>
