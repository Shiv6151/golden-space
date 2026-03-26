<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.fmt" prefix="fmt" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>News Feed - Golden Space</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="css/styles.css?v=<%= System.currentTimeMillis() %>">
    <link rel="stylesheet" href="css/app.css?v=<%= System.currentTimeMillis() %>">
    <style>
        .feed-layout {
            display: flex;
            flex-direction: column;
            gap: 1.5rem;
            max-width: 680px;
            margin: 2rem auto;
            align-items: center;
        }
        .feed-container { width: 100%; }
        @media (max-width: 768px) {
            .feed-layout { padding: 0 0.75rem; }
        }

        /* Suggested Users Section */
        .suggested-users-card {
            width: 100%;
            background: var(--bg-white);
            border-radius: 18px;
            border: 1px solid var(--border-color);
            padding: 1.25rem 1.5rem;
            box-shadow: 0 2px 8px rgba(0,0,0,0.04);
        }
        .suggested-users-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 1rem;
        }
        .suggested-users-header h4 {
            margin: 0;
            font-size: 1rem;
            font-weight: 700;
            color: var(--text-main);
        }
        .suggested-scroll {
            display: flex;
            gap: 1rem;
            overflow-x: auto;
            padding-bottom: 0.5rem;
            -webkit-overflow-scrolling: touch;
            scrollbar-width: none;
        }
        .suggested-scroll::-webkit-scrollbar { display: none; }
        .suggested-user-card {
            flex-shrink: 0;
            display: flex;
            flex-direction: column;
            align-items: center;
            gap: 0.5rem;
            width: 110px;
            background: var(--bg-light);
            border-radius: 16px;
            padding: 1rem 0.75rem;
            border: 1px solid var(--border-color);
            transition: box-shadow 0.2s, transform 0.2s;
        }
        .suggested-user-card:hover {
            box-shadow: 0 4px 16px rgba(0,0,0,0.08);
            transform: translateY(-2px);
        }
        .suggested-user-card img {
            width: 56px;
            height: 56px;
            border-radius: 50%;
            object-fit: cover;
            border: 2px solid var(--border-color);
        }
        .suggested-user-card .sug-name {
            font-weight: 600;
            font-size: 0.78rem;
            color: var(--text-main);
            text-align: center;
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
            max-width: 90px;
        }
        .suggested-user-card .sug-handle {
            font-size: 0.72rem;
            color: var(--text-muted);
            text-align: center;
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
            max-width: 90px;
        }
        .sug-follow-btn {
            margin-top: 0.25rem;
            padding: 0.3rem 0.75rem;
            border-radius: 20px;
            font-size: 0.75rem;
            font-weight: 600;
            background: var(--primary-color);
            color: white;
            border: none;
            cursor: pointer;
            transition: opacity 0.2s;
        }
        .sug-follow-btn:hover { opacity: 0.85; }
        .sug-follow-btn.followed {
            background: var(--bg-white);
            border: 1px solid var(--border-color);
            color: var(--text-muted);
        }
    </style>
</head>
<body>
    <jsp:include page="components/navbar.jsp" />

    <div class="feed-layout">

        <!-- People You May Know -->
        <c:if test="${not empty suggestedUsers}">
            <div class="suggested-users-card feed-container">
                <div class="suggested-users-header">
                    <h4><i class="fas fa-users" style="color:var(--primary-color); margin-right:0.5rem;"></i>People You May Know</h4>
                </div>
                <div class="suggested-scroll">
                    <c:forEach var="su" items="${suggestedUsers}">
                        <div class="suggested-user-card">
                            <a href="${pageContext.request.contextPath}/ProfileServlet?id=${su.userId}" style="text-decoration:none; display:contents;">
                                <img src="${su.profilePhoto != null && (su.profilePhoto.startsWith('http') || su.profilePhoto.startsWith('data:')) ? su.profilePhoto : pageContext.request.contextPath.concat('/').concat(su.profilePhoto != null ? su.profilePhoto : 'images/default-avatar.png')}"
                                     alt="${su.name}"
                                     onerror="this.src='${pageContext.request.contextPath}/images/default-avatar.png'">
                                <span class="sug-name">${su.name}</span>
                                <span class="sug-handle">@${su.username}</span>
                            </a>
                            <button class="sug-follow-btn" id="sug-btn-${su.userId}"
                                onclick="sugFollow(${su.userId}, this)">Follow</button>
                        </div>
                    </c:forEach>
                </div>
            </div>
        </c:if>

        <!-- Main Feed Column -->
        <div class="feed-container">
            
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
    </div>

    <!-- Core App JS -->
    <script src="${pageContext.request.contextPath}/js/app_v2.js?v=20260326"></script>
    <script>
        function sugFollow(userId, btn) {
            var ctx = window.contextPath || '';
            fetch(ctx + '/InteractionServlet', {
                method: 'POST',
                headers: {'Content-Type': 'application/x-www-form-urlencoded'},
                body: 'action=follow&targetId=' + userId
            }).then(function(res) {
                if (res.ok) {
                    btn.innerText = 'Following';
                    btn.classList.add('followed');
                    btn.disabled = true;
                }
            }).catch(function() {});
        }
    </script>

</body>
</html>
