<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.fmt" prefix="fmt" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>News Feed - Social Media</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="css/styles.css?v=<%= System.currentTimeMillis() %>">
    <link rel="stylesheet" href="css/app.css?v=<%= System.currentTimeMillis() %>">
    <style>
        .feed-layout {
            display: flex;
            flex-direction: column;
            gap: 2rem;
            max-width: 680px;
            margin: 2rem auto;
            align-items: center;
        }
        .feed-container { width: 100%; }
        @media (max-width: 768px) {
            .feed-layout { padding: 0 1rem; }
        }
    </style>
</head>
<body>
    <jsp:include page="components/navbar.jsp" />

    <div class="feed-layout">
        <!-- Main Feed Column -->
        <div class="feed-container">
            
            <!-- Create Post Box Removed (Now a dedicated page) -->

            <!-- Feed Posts -->
            <c:if test="${empty feedPosts}">
                <div class="card text-center text-muted p-5" style="padding: 3rem;">
                    <h3>No posts to show</h3>
                    <p>Follow some users to see their posts here!</p>
                </div>
            </c:if>
            
            <c:forEach var="feedPost" items="${feedPosts}">
                <c:set var="post" value="${feedPost}" scope="request" />
                <jsp:include page="components/post.jsp" />
            </c:forEach>
        </div>
        <!-- Sidebar removed -->

    <!-- Core App JS -->
    <script src="${pageContext.request.contextPath}/js/app_v2.js?v=20260317"></script>

</body>
</html>
</body>
</html>
