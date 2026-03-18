<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.fmt" prefix="fmt" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Notifications</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="css/styles.css?v=<%= System.currentTimeMillis() %>">
    <link rel="stylesheet" href="css/app.css?v=<%= System.currentTimeMillis() %>">
    <style>
        .notif-page { max-width: 640px; margin: 1.5rem auto; padding: 0 1rem; }
        .notif-header { font-size: 1.4rem; font-weight: 700; margin-bottom: 1.25rem; display:flex; align-items:center; gap:0.6rem; }
        .notif-item {
            display: flex; align-items: center; gap: 0.9rem;
            padding: 0.9rem 1rem; border-radius: 12px;
            margin-bottom: 0.5rem; transition: background 0.15s;
            background: var(--bg-white);
            border: 1px solid var(--border-color);
        }
        .notif-item:hover { background: var(--bg-light); }
        .notif-item.unread { background: rgba(255,71,87,0.04); border-color: rgba(255,71,87,0.18); }
        .notif-avatar { width: 46px; height: 46px; border-radius: 50%; object-fit: cover; border: 2px solid var(--border-color); flex-shrink:0; }
        .notif-icon { width: 22px; height: 22px; border-radius: 50%; display:flex; align-items:center; justify-content:center; font-size:0.7rem; color:white; flex-shrink:0; }
        .notif-text { flex: 1; min-width: 0; font-size:0.92rem; line-height:1.4; }
        .notif-time { font-size: 0.75rem; color: var(--text-muted); white-space:nowrap; }
        .notif-actor-link { font-weight: 700; color: var(--text-main); text-decoration: none; }
        .notif-actor-link:hover { text-decoration: underline; color: var(--primary-color); }
        .notif-unread-dot { width: 8px; height: 8px; background: var(--primary-color); border-radius: 50%; flex-shrink:0; }
        @media (max-width: 768px) {
            .notif-page { padding: 0 0.5rem; }
        }
    </style>
</head>
<body>
    <jsp:include page="components/navbar.jsp" />

    <div class="notif-page">
        <div class="notif-header">
            <i class="fas fa-bell" style="color:var(--primary-color);"></i>
            Notifications
        </div>

        <c:if test="${empty notifications}">
            <div style="text-align:center; padding:3rem; color:var(--text-muted);">
                <i class="far fa-bell" style="font-size:3rem; margin-bottom:1rem; display:block; opacity:0.4;"></i>
                <p>No notifications yet</p>
            </div>
        </c:if>

        <c:forEach var="notif" items="${notifications}">
            <%-- Parse actorName|actorFullname format --%>
            <c:set var="parts" value="${fn:split(notif.actorName, '|')}" />

            <c:set var="iconColor" value="#6c63ff" />
            <c:set var="iconClass" value="fas fa-bell" />
            <c:set var="message" value="interacted with you." />

            <c:choose>
                <c:when test="${notif.type == 'LIKE'}">
                    <c:set var="iconColor" value="#ff4757" />
                    <c:set var="iconClass" value="fas fa-heart" />
                    <c:set var="message" value="liked your post." />
                </c:when>
                <c:when test="${notif.type == 'COMMENT'}">
                    <c:set var="iconColor" value="#0984e3" />
                    <c:set var="iconClass" value="fas fa-comment" />
                    <c:set var="message" value="commented on your post." />
                </c:when>
                <c:when test="${notif.type == 'FOLLOW'}">
                    <c:set var="iconColor" value="#00b894" />
                    <c:set var="iconClass" value="fas fa-user-plus" />
                    <c:set var="message" value="started following you." />
                </c:when>
                <c:when test="${notif.type == 'FOLLOW_REQUEST'}">
                    <c:set var="iconColor" value="#fdcb6e" />
                    <c:set var="iconClass" value="fas fa-user-clock" />
                    <c:set var="message" value="sent you a follow request." />
                </c:when>
                <c:when test="${notif.type == 'SHARE'}">
                    <c:set var="iconColor" value="#a29bfe" />
                    <c:set var="iconClass" value="far fa-paper-plane" />
                    <c:set var="message" value="shared a post with you." />
                </c:when>
            </c:choose>

            <div class="notif-item ${notif.read ? '' : 'unread'}">
                <%-- Avatar — clickable to profile --%>
                <a href="ProfileServlet?id=${notif.actorId}" style="position:relative; flex-shrink:0;">
                    <c:choose>
                        <c:when test="${not empty notif.actorPhoto && (notif.actorPhoto.startsWith('http') || notif.actorPhoto.startsWith('/'))}">
                            <img src="${notif.actorPhoto}" class="notif-avatar" alt="avatar">
                        </c:when>
                        <c:otherwise>
                            <img src="${pageContext.request.contextPath}/images/default-avatar.png" class="notif-avatar" alt="avatar">
                        </c:otherwise>
                    </c:choose>
                    <div class="notif-icon" style="background:${iconColor}; position:absolute; bottom:-2px; right:-2px;">
                        <i class="${iconClass}"></i>
                    </div>
                </a>

                <div class="notif-text">
                    <a href="ProfileServlet?id=${notif.actorId}" class="notif-actor-link">
                        @${notif.actorName.contains('|') ? notif.actorName.substring(0, notif.actorName.indexOf('|')) : notif.actorName}
                    </a>
                    ${message}
                    <c:if test="${notif.type == 'LIKE' || notif.type == 'COMMENT'}">
                        <c:if test="${not empty notif.targetId}">
                            <a href="FeedServlet?postId=${notif.targetId}" style="color:var(--primary-color); font-size:0.85rem; display:inline-block; margin-top:2px;">View post →</a>
                        </c:if>
                    </c:if>
                </div>

                <div style="display:flex; flex-direction:column; align-items:flex-end; gap:4px;">
                    <span class="notif-time local-time" data-utc="${notif.createdAt.time}">
                        <fmt:formatDate value="${notif.createdAt}" pattern="MMM d, h:mm a" />
                    </span>
                    <c:if test="${!notif.read}">
                        <div class="notif-unread-dot" title="Unread"></div>
                    </c:if>
                </div>
            </div>
        </c:forEach>
    </div>

    <script src="js/app_v2.js?v=<%= System.currentTimeMillis() %>"></script>
    <script>
        window.contextPath = '${pageContext.request.contextPath}';
    </script>
</body>
</html>
