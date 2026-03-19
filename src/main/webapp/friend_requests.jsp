<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.fmt" prefix="fmt" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Friend Requests - Social Media</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="css/styles.css?v=<%= System.currentTimeMillis() %>">
    <link rel="stylesheet" href="css/app.css?v=<%= System.currentTimeMillis() %>">
    <style>
        .request-card {
            display: flex;
            align-items: center;
            justify-content: space-between;
            background: var(--bg-white);
            border-radius: var(--radius-lg);
            padding: 1.25rem;
            margin-bottom: 1rem;
            box-shadow: var(--shadow-sm);
            transition: transform 0.2s ease, box-shadow 0.2s ease;
            border: 1px solid var(--border-color);
        }
        
        .request-card:hover {
            transform: translateY(-2px);
            box-shadow: var(--shadow-md);
        }
        
        .user-info {
            display: flex;
            align-items: center;
            gap: 1.25rem;
            text-decoration: none;
            color: inherit;
        }
        
        .user-avatar {
            width: 56px;
            height: 56px;
            border-radius: 50%;
            object-fit: cover;
            border: 2px solid var(--primary-light, #ffe4e6);
        }
        
        .user-details h4 {
            margin: 0;
            font-size: 1rem;
            font-weight: 600;
            color: var(--text-main);
        }
        
        .user-details p {
            margin: 0.25rem 0 0;
            font-size: 0.875rem;
            color: var(--text-muted);
        }
        
        .action-buttons {
            display: flex;
            gap: 0.75rem;
        }
        
        .btn-accept {
            background-color: var(--primary-color);
            color: white;
            padding: 0.6rem 1.25rem;
            border-radius: 8px;
            font-weight: 600;
            font-size: 0.9rem;
            border: none;
            cursor: pointer;
            transition: opacity 0.2s;
        }
        
        .btn-reject {
            background-color: var(--bg-light);
            color: var(--text-main);
            padding: 0.6rem 1.25rem;
            border-radius: 8px;
            font-weight: 600;
            font-size: 0.9rem;
            border: 1px solid var(--border-color);
            cursor: pointer;
            transition: background 0.2s;
        }
        
        .btn-accept:hover { opacity: 0.9; }
        .btn-reject:hover { background-color: var(--border-color); }
        
        .empty-state {
            text-align: center;
            padding: 4rem 2rem;
            background: var(--bg-white);
            border-radius: var(--radius-lg);
            border: 2px dashed var(--border-color);
        }
        
        .empty-state i {
            font-size: 3rem;
            color: var(--text-muted);
            margin-bottom: 1.5rem;
            opacity: 0.5;
        }
    </style>
</head>
<body>
    <jsp:include page="components/navbar.jsp" />

    <div class="main-container">
        <div style="margin-bottom: 2rem; display: flex; align-items: center; gap: 1rem;">
            <a href="FeedServlet" style="color: var(--text-muted);"><i class="fas fa-arrow-left"></i></a>
            <h2 style="margin: 0;">Friend Requests</h2>
        </div>

        <c:choose>
            <c:when test="${not empty pendingRequests}">
                <div class="requests-list">
                    <c:forEach var="request" items="${pendingRequests}">
                        <div class="request-card">
                            <a href="ProfileServlet?id=${request.friendId}" class="user-info">
                                <img src="${not empty request.friendPhoto && request.friendPhoto.startsWith('http') ? request.friendPhoto : pageContext.request.contextPath.concat('/').concat(not empty request.friendPhoto ? request.friendPhoto : 'images/default-avatar.png')}" alt="${request.friendName}" class="user-avatar">
                                <div class="user-details">
                                    <h4>${request.friendName}</h4>
                                    <p>Sent you a request</p>
                                </div>
                            </a>
                            <c:if test="${not empty request.message}">
                                <div style="flex: 1; margin: 0 2rem; background: var(--bg-light); padding: 0.75rem 1.25rem; border-radius: 8px; font-style: italic; color: var(--text-main); font-size: 0.9rem; border-left: 3px solid var(--primary-color);">
                                    "${request.message}"
                                </div>
                            </c:if>
                            <div class="action-buttons">
                                <form action="FriendServlet" method="POST" style="display:inline;">
                                    <input type="hidden" name="action" value="accept">
                                    <input type="hidden" name="friendId" value="${request.friendId}">
                                    <button type="submit" class="btn-accept">Accept</button>
                                </form>
                                <form action="FriendServlet" method="POST" style="display:inline;">
                                    <input type="hidden" name="action" value="reject">
                                    <input type="hidden" name="friendId" value="${request.friendId}">
                                    <button type="submit" class="btn-reject">Reject</button>
                                </form>
                            </div>
                        </div>
                    </c:forEach>
                </div>
            </c:when>
            <c:otherwise>
                <div class="empty-state">
                    <i class="fas fa-user-clock"></i>
                    <h3>No pending requests</h3>
                    <p>When people send you friend requests, they'll appear here.</p>
                    <a href="FeedServlet" class="btn btn-outline mt-4">Back to Feed</a>
                </div>
            </c:otherwise>
        </c:choose>
    </div>

    <script src="${pageContext.request.contextPath}/js/app_v2.js?v=20260317"></script>

</body>
</html>
