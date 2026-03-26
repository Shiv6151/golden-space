<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.fmt" prefix="fmt" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Messages - Social Media</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="css/styles.css?v=<%= System.currentTimeMillis() %>">
    <link rel="stylesheet" href="css/app.css?v=<%= System.currentTimeMillis() %>">
    <style>
        .chat-layout {
            display: flex;
            height: calc(100vh - 80px); /* Subtract navbar */
            max-width: 1200px;
            margin: 0 auto;
            background: var(--bg-white);
            box-shadow: var(--shadow-sm);
        }
        .chat-sidebar {
            width: 320px;
            border-right: 1px solid var(--border-color);
            display: flex;
            flex-direction: column;
            overflow-y: auto;
        }
        .chat-sidebar-header {
            padding: 1.5rem;
            border-bottom: 1px solid var(--border-color);
            font-weight: 600;
            font-size: 1.25rem;
        }
        .friend-item {
            display: flex;
            align-items: center;
            gap: 1rem;
            padding: 1rem 1.5rem;
            cursor: pointer;
            transition: background 0.2s;
            text-decoration: none;
            color: var(--text-main);
            border-bottom: 1px solid var(--border-color);
        }
        .friend-item:hover, .friend-item.active {
            background-color: var(--bg-light);
        }
        .friend-item.active { border-left: 4px solid var(--primary-color); }
        .chat-main {
            flex: 1;
            display: flex;
            flex-direction: column;
        }
        .chat-header {
            padding: 1.5rem;
            border-bottom: 1px solid var(--border-color);
            display: flex;
            align-items: center;
            gap: 1rem;
        }
        .chat-messages {
            flex: 1;
            padding: 1.5rem;
            overflow-y: auto;
            display: flex;
            flex-direction: column;
            gap: 1rem;
            background-color: var(--bg-light);
        }
        .message-bubble {
            max-width: 70%;
            padding: 0.75rem 1rem;
            border-radius: 1.5rem;
            position: relative;
        }
        .message-sent {
            align-self: flex-end;
            background-color: var(--primary-color);
            color: white;
            border-bottom-right-radius: 0.25rem;
        }
        .message-received {
            align-self: flex-start;
            background-color: white;
            border: 1px solid var(--border-color);
            border-bottom-left-radius: 0.25rem;
        }
        .msg-time {
            font-size: 0.7rem;
            margin-top: 0.25rem;
            opacity: 0.8;
            text-align: right;
        }
        .chat-input-area {
            padding: 1rem 1.5rem;
            border-top: 1px solid var(--border-color);
            background: white;
        }
        .chat-form {
            display: flex;
            gap: 1rem;
        }
        .message-bubble:hover .delete-msg-btn {
            opacity: 1;
        }
        .delete-msg-btn {
            opacity: 0;
            position: absolute;
            top: -10px;
            right: -10px;
            background: var(--bg-white);
            color: var(--danger-color);
            border-radius: 50%;
            width: 24px;
            height: 24px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 0.8rem;
            cursor: pointer;
            box-shadow: var(--shadow-sm);
            transition: opacity 0.2s, background 0.2s;
            border: 1px solid var(--border-color);
        }
        .delete-msg-btn:hover {
            background: var(--danger-color);
            color: white;
            border-color: var(--danger-color);
        }
        .react-msg-btn {
            opacity: 0;
            position: absolute;
            top: -10px;
            left: -10px;
            background: var(--bg-white);
            color: var(--text-muted);
            border-radius: 50%;
            width: 24px;
            height: 24px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 0.8rem;
            cursor: pointer;
            box-shadow: var(--shadow-sm);
            transition: opacity 0.2s, background 0.2s;
            border: 1px solid var(--border-color);
            z-index: 5;
        }
        .message-bubble:hover .react-msg-btn {
            opacity: 1;
        }
        .react-msg-btn:hover {
            color: var(--primary-color);
            background: var(--bg-light);
        }
        .msg-reactions {
            display: flex;
            flex-wrap: wrap;
            gap: 4px;
            margin-top: 6px;
        }
        .msg-options-trigger {
            position: absolute;
            top: 4px;
            right: 8px;
            cursor: pointer;
            color: inherit;
            opacity: 0;
            transition: opacity 0.2s;
            z-index: 10;
        }
        .message-bubble:hover .msg-options-trigger {
            opacity: 0.6;
        }
        .msg-options-trigger:hover {
            opacity: 1 !important;
        }
        .message-sent .msg-reactions {
            justify-content: flex-end;
        }
        .reaction-item {
            font-size: 1.15rem;
            cursor: pointer;
            border-radius: 12px;
            padding: 2px 4px;
            display: flex;
            align-items: center;
            gap: 2px;
            background: transparent;
            border: none;
            transition: transform 0.2s;
        }
        .reaction-item:hover {
            transform: scale(1.1);
        }
        .reaction-item .count {
            display: none;
        }
        .emoji-picker-popup {
            display: none;
            position: absolute;
            top: -40px;
            left: -10px;
            background: var(--bg-white);
            border: 1px solid var(--border-color);
            border-radius: 20px;
            padding: 5px 10px;
            box-shadow: var(--shadow-md);
            z-index: 100;
            gap: 8px;
            animation: fadeIn 0.2s ease-out;
        }
        @keyframes fadeIn {
            from { opacity: 0; transform: translateY(5px); }
            to { opacity: 1; transform: translateY(0); }
        }
        .date-divider {
            text-align: center;
            margin: 1.5rem 0;
            position: relative;
            display: flex;
            align-items: center;
            justify-content: center;
        }
        .date-divider span {
            background: var(--bg-white);
            padding: 4px 12px;
            border-radius: 12px;
            font-size: 0.75rem;
            color: var(--text-muted);
            border: 1px solid var(--border-color);
            position: relative;
            z-index: 1;
        }
        .date-divider::before {
            content: "";
            position: absolute;
            left: 0;
            right: 0;
            height: 1px;
            background: var(--border-color);
            top: 50%;
            z-index: 0;
            opacity: 0.5;
        }
        .message-row {
            display: flex;
            align-items: flex-end;
            gap: 0.5rem;
            margin-bottom: 20px;
        }
        .message-row.sent {
            flex-direction: row-reverse;
        }
        .msg-avatar {
            width: 32px;
            height: 32px;
            border-radius: 50%;
            object-fit: cover;
            border: 1px solid var(--border-color);
            flex-shrink: 0;
        }
        .export-dropdown {
            position: relative;
            display: inline-block;
        }
        .export-content {
            display: none;
            position: absolute;
            right: 0;
            background-color: var(--bg-white);
            min-width: 160px;
            box-shadow: var(--shadow-md);
            border-radius: 8px;
            z-index: 1000;
            border: 1px solid var(--border-color);
            margin-top: 5px;
        }
        .export-content a {
            color: var(--text-color);
            padding: 10px 15px;
            text-decoration: none;
            display: flex;
            align-items: center;
            gap: 8px;
            font-size: 0.9rem;
            transition: background 0.2s;
        }
        .export-content a:hover {
            background-color: var(--bg-light);
        }
        .export-btn-group {
            display: flex;
            align-items: center;
            background: var(--bg-light);
            border: 1px solid var(--border-color);
            border-radius: 20px;
            padding: 4px 12px;
            cursor: pointer;
            transition: all 0.2s;
            gap: 8px;
            color: var(--text-color);
            font-weight: 500;
            font-size: 0.85rem;
        }
        .export-btn-group:hover {
            background: var(--border-color);
            border-color: #ccc;
        }

        /* ---- MOBILE RESPONSIVE CHAT ---- */
        .back-btn {
            display: none;
            align-items: center;
            gap: 6px;
            background: none;
            border: none;
            font-size: 1rem;
            font-weight: 600;
            color: var(--primary-color);
            cursor: pointer;
            padding: 0;
            margin-right: 8px;
        }
        .mobile-only {
            display: none;
        }
        @media (max-width: 768px) {
            .mobile-only {
                display: block;
            }
            body {
                overflow: auto !important;
                height: auto !important;
            }
            .chat-layout {
                flex-direction: column;
                height: 100vh;
                margin-top: 60px; /* Account for navbar */
                max-width: 100vw;
            }
            .chat-sidebar {
                width: 100%;
                z-index: 100;
                border-right: none;
                background: var(--bg-white);
                display: flex;
                flex-direction: column;
                overflow-y: auto !important;
            }
            .friend-item {
                padding: 0.85rem 1rem !important;
                gap: 0.85rem !important;
                background: var(--bg-white) !important;
                border-bottom: 1px solid var(--border-color) !important;
                opacity: 1 !important;
                display: flex !important;
                align-items: center !important;
            }
            .friend-item img {
                width: 44px !important;
                height: 44px !important;
                flex-shrink: 0 !important;
            }
            .friend-name {
                font-size: 1rem !important;
                color: var(--text-main) !important;
                opacity: 1 !important;
            }
            .chat-main {
                display: none; /* Hidden by default */
                width: 100%;
                height: 100vh;
                background: var(--bg-light);
            }
            body.chat-open .chat-sidebar {
                display: none; /* Hide sidebar completely when chatting */
            }
            body.chat-open .chat-main {
                display: flex; /* Show chat */
            }
            body.chat-open.sidebar-active .chat-sidebar {
                transform: translateX(0);
                width: 85%;
                z-index: 1000;
                box-shadow: 5px 0 25px rgba(0,0,0,0.2);
            }
            #mobile-chat-overlay {
                display: none;
                position: absolute;
                top: 0; left: 0; width: 100%; height: 100%;
                background: rgba(0,0,0,0.4);
                z-index: 900;
                backdrop-filter: blur(2px);
                transition: opacity 0.3s;
            }
            body.chat-open.sidebar-active #mobile-chat-overlay {
                display: block;
            }
            .back-btn {
                display: none; /* Changed to hamburger menu */
            }
            .message-bubble {
                max-width: 85% !important;
            }
            .chat-messages {
                padding: 0.75rem !important;
            }
            .chat-header {
                padding: 0.75rem 1rem !important;
            }
            .chat-sidebar-header {
                padding: 1rem 1rem !important;
            }
        }
        .msg-reactions {
            position: absolute;
            bottom: -10px;
            right: 5px;
            display: flex;
            gap: 2px;
            background: var(--bg-white);
            padding: 2px 4px;
            border-radius: 12px;
            box-shadow: 0 2px 5px rgba(0,0,0,0.1);
            z-index: 5;
        }
    </style>
</head>
<body style="background-color: var(--bg-light); margin: 0; height: 100vh; overflow: hidden;">
    <jsp:include page="components/navbar.jsp" />
    <script>
        window.contextPath = '${pageContext.request.contextPath}';
        window.currentUserId = '${sessionScope.user.userId}';
    </script>
    <script src="${pageContext.request.contextPath}/js/app_v2.js?v=20260319"></script>

    <div class="chat-layout">
        <!-- Sidebar: Friend List -->
        <div class="chat-sidebar">
            <c:if test="${not empty pendingRequests}">
                <a href="FriendServlet" class="friend-item" style="background: var(--primary-light, #fff5f6); border-bottom: 2px solid var(--primary-color); padding: 1.25rem 1.5rem;">
                    <div style="width: 48px; height: 48px; border-radius: 50%; background: var(--primary-color); display: flex; align-items: center; justify-content: center; color: white;">
                        <i class="fas fa-user-plus"></i>
                    </div>
                    <div style="flex: 1;">
                        <div style="font-weight: 700; color: var(--primary-color);">Follow Requests</div>
                        <div style="font-size: 0.8rem; color: var(--text-muted);">${pendingRequests.size()} people want to follow you</div>
                    </div>
                    <div style="background: var(--danger-color); color: white; border-radius: 12px; padding: 2px 8px; font-size: 0.75rem; font-weight: 700;">
                        ${pendingRequests.size()}
                    </div>
                </a>
            </c:if>

            <div class="chat-sidebar-header">
                Chats
            </div>
            
            <a href="MessageServlet?with=${sessionScope.user.userId}" class="friend-item ${sessionScope.user.userId == chatUser.userId ? 'active' : ''}" style="border-bottom: 1px solid var(--border-color); margin-bottom: 0.5rem; position: relative;">
                <div style="width: 48px; height: 48px; border-radius: 50%; background: var(--primary-light, #e0e7ff); display: flex; align-items: center; justify-content: center; color: var(--primary-color); border: 1px solid var(--border-color); flex-shrink: 0;">
                    <i class="fas fa-bookmark" style="font-size: 1.2rem;"></i>
                </div>
                <div style="flex: 1; margin-left: 12px; min-width: 0;">
                    <div style="font-weight: 700; color: var(--text-main); font-size: 0.95rem;">Message Yourself</div>
                    <div style="font-size: 0.8rem; color: var(--text-muted); overflow: hidden; text-overflow: ellipsis; white-space: nowrap;">Save messages & files</div>
                </div>
            </a>
            
            <c:if test="${empty friends}">
                <div class="p-4 text-muted text-center">
                    No friends yet. <br> Add friends to start chatting!
                </div>
            </c:if>
            
            <c:forEach var="friend" items="${friends}">
                <a href="MessageServlet?with=${friend.userId}" class="friend-item ${friend.userId == chatUser.userId ? 'active' : ''}">
                    <img src="${friend.profilePhoto != null && friend.profilePhoto.startsWith('http') ? friend.profilePhoto : pageContext.request.contextPath.concat('/').concat(friend.profilePhoto != null ? friend.profilePhoto : 'images/default-avatar.png')}" style="width: 48px; height: 48px; border-radius: 50%; object-fit: cover; border: 1px solid var(--border-color);">
                    <div style="flex: 1; min-width: 0;">
                        <div class="friend-name" style="font-weight: ${friend.unreadCount > 0 ? '700' : '600'}; font-size: 0.95rem; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; color: var(--text-main);">${friend.name}</div>
                        <c:if test="${friend.unreadCount > 0}">
                            <div style="font-size: 0.75rem; color: var(--primary-color); font-weight: 600; margin-top: 1px;">
                                <c:choose>
                                    <c:when test="${friend.unreadCount > 4}">4+ messages unread</c:when>
                                    <c:otherwise>${friend.unreadCount} message<c:if test="${friend.unreadCount > 1}">s</c:if> unread</c:otherwise>
                                </c:choose>
                            </div>
                        </c:if>
                    </div>
                    <c:if test="${friend.unreadCount > 0}">
                        <div style="background: var(--primary-color); color: white; border-radius: 12px; padding: 2px 8px; font-size: 0.75rem; font-weight: 700; flex-shrink: 0;">
                            <c:choose>
                                <c:when test="${friend.unreadCount > 4}">4+</c:when>
                                <c:otherwise>${friend.unreadCount}</c:otherwise>
                            </c:choose>
                        </div>
                    </c:if>
                </a>
            </c:forEach>
        </div>

        <!-- Main Chat Area -->
        <div class="chat-main">
            <c:choose>
                <c:when test="${not empty chatUser}">
                    <c:if test="${not empty chatUser}">
                        <script>document.body.classList.add('chat-open');</script>
                    </c:if>
                    <div class="chat-header" style="justify-content: space-between;">
                        <div style="display: flex; align-items: center; gap: 1rem;">
                            <!-- Hamburger Menu Toggle -->
                            <button class="mobile-only" onclick="toggleMobileSidebar()" style="background: none; border: none; color: var(--text-color); font-size: 1.25rem; font-weight: 600; cursor: pointer; padding: 0;">
                                <i class="fas fa-bars"></i>
                            </button>
                            <!-- Default back button for those without JS or standard wide views -->
                            <button class="back-btn" onclick="goBackToSidebar()" title="Back to chats">
                                <i class="fas fa-arrow-left"></i>
                            </button>
                            <img src="${chatUser.profilePhoto != null && chatUser.profilePhoto.startsWith('http') ? chatUser.profilePhoto : pageContext.request.contextPath.concat('/').concat(chatUser.profilePhoto != null ? chatUser.profilePhoto : 'images/default-avatar.png')}" class="post-avatar">
                            <h3 style="margin: 0;"><a href="#" onclick="openSharedMediaModal(); return false;" style="color: inherit;" title="View Shared Media">${chatUser.name}</a></h3>
                        </div>
                        <div style="display: flex; align-items: center; gap: 0.5rem;">
                            <!-- Video Call Button -->
                            <button id="startVideoCallBtn" class="btn" style="background: none; border: none; color: var(--primary-color); cursor: pointer; padding: 8px;" title="Video Call">
                                <i class="fas fa-video" style="font-size: 1.2rem;"></i>
                            </button>
                            
                            <!-- 3-dots Menu for clear chat etc -->
                            <div style="position: relative;">
                                <button type="button" class="btn" onclick="toggleChatHeaderMenu(event)" style="background: none; border: none; color: var(--text-muted); cursor: pointer; padding: 8px; transition: color 0.2s;" onmouseover="this.style.color='var(--primary-color)'" onmouseout="this.style.color='var(--text-muted)'">
                                    <i class="fas fa-ellipsis-v" style="font-size: 1.2rem;"></i>
                                </button>
                                <div id="chatHeaderMenu" class="msg-dropdown-menu" style="display:none; position:absolute; right:0; top:45px; background:var(--bg-white); border-radius:12px; box-shadow:0 8px 24px rgba(0,0,0,0.15); border:1px solid var(--border-color); padding:0.5rem 0; min-width:200px; z-index:200;">
                                    <div class="dropdown-item" onclick="document.getElementById('chatThemeModal').style.display='flex'; document.getElementById('chatHeaderMenu').style.display='none';" style="padding: 0.75rem 1rem; cursor: pointer; display:flex; align-items:center; transition:background 0.2s;" onmouseover="this.style.background='var(--bg-light)'" onmouseout="this.style.background='transparent'">
                                        <i class="fas fa-palette" style="width: 24px; color:var(--primary-color);"></i> Change Theme
                                    </div>
                                    <div class="dropdown-item" onclick="goToFirstMessage()" style="padding: 0.75rem 1rem; cursor: pointer; display:flex; align-items:center; transition:background 0.2s;" onmouseover="this.style.background='var(--bg-light)'" onmouseout="this.style.background='transparent'">
                                        <i class="fas fa-arrow-up" style="width: 24px; color:#10b981;"></i> Go to First Message
                                    </div>
                                    <div class="dropdown-item text-danger" onclick="blockUserConfirm('${chatUser.userId}')" style="padding: 0.75rem 1rem; cursor: pointer; display:flex; align-items:center; transition:background 0.2s;" onmouseover="this.style.background='var(--danger-light, #ffe4e6)'" onmouseout="this.style.background='transparent'">
                                        <i class="fas fa-ban" style="width: 24px;"></i> Block User
                                    </div>
                                    <form action="MessageServlet" method="POST" style="margin:0;" onsubmit="return confirm('Clear chat history for you? The other user will still see the conversation.');">
                                        <input type="hidden" name="action" value="clearChat">
                                        <input type="hidden" name="otherUserId" value="${chatUser.userId}">
                                        <button type="submit" class="dropdown-item text-danger" style="width: 100%; text-align: left; background: none; border: none; padding: 0.75rem 1rem; cursor: pointer; display:flex; align-items:center; font-family:inherit; font-size:inherit; transition:background 0.2s;" onmouseover="this.style.background='var(--danger-light, #ffe4e6)'" onmouseout="this.style.background='transparent'">
                                            <i class="fas fa-trash-alt" style="width: 24px;"></i> Clear Chat
                                        </button>
                                    </form>
                                </div>
                            </div>
                        </div>
                    </div>
                    
                    <div style="position: relative; flex: 1; display:flex; flex-direction:column; overflow:hidden;">
                        <!-- Mobile Backdrop -->
                        <div id="mobile-chat-overlay" onclick="toggleMobileSidebar()"></div>
                        <!-- Video Overlay -->
                        <div id="video-overlay" style="display:none; position:absolute; top:0; left:0; width:100%; height:100%; background:rgba(0,0,0,0.85); backdrop-filter:blur(10px); z-index:100; flex-direction:column; align-items:center; justify-content:center; color:white;">
                            <div style="position:relative; width:100%; height:100%; display:flex; flex-direction:column;">
                                <video id="remoteVideo" autoplay playsinline style="width:100%; height:100%; object-fit:cover;"></video>
                                <video id="localVideo" autoplay playsinline muted style="position:absolute; bottom:20px; right:20px; width:150px; border:2px solid white; border-radius:8px; box-shadow:0 4px 15px rgba(0,0,0,0.5);"></video>
                                
                                <div id="call-controls" style="position:absolute; bottom:40px; left:50%; transform:translateX(-50%); display:flex; gap:2rem; align-items:center;">
                                    <button onclick="endCall()" class="btn btn-danger" style="border-radius:50%; width:60px; height:60px; padding:0; display:flex; justify-content:center; align-items:center; font-size:1.5rem;">
                                        <i class="fas fa-phone-slash"></i>
                                    </button>
                                </div>

                                <div id="incoming-call-ui" style="display:none; position:absolute; top:50%; left:50%; transform:translate(-50%, -50%); text-align:center;">
                                    <img src="${chatUser.profilePhoto != null && chatUser.profilePhoto.startsWith('http') ? chatUser.profilePhoto : pageContext.request.contextPath.concat('/').concat(chatUser.profilePhoto != null ? chatUser.profilePhoto : 'images/default-avatar.png')}" class="post-avatar" style="width:100px; height:100px; margin-bottom:1rem; border:3px solid var(--primary-color);">
                                    <h2 style="margin-bottom:2rem;">Incoming call from ${chatUser.name}...</h2>
                                    <div style="display:flex; gap:2rem; justify-content:center;">
                                        <button onclick="acceptCall()" class="btn btn-primary" style="border-radius:50%; width:65px; height:65px; font-size:1.5rem;">
                                            <i class="fas fa-phone"></i>
                                        </button>
                                        <button onclick="endCall()" class="btn btn-danger" style="border-radius:50%; width:65px; height:65px; font-size:1.5rem;">
                                            <i class="fas fa-phone-slash"></i>
                                        </button>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <div class="chat-messages" id="chatWindow">
                            <c:if test="${empty conversation}">
                                <div class="text-center text-muted mt-4">No messages yet. Say hi!</div>
                            </c:if>
                            
                            <c:set var="prevDate" value="" />
                            <c:forEach var="msg" items="${conversation}">
                                <c:if test="${not msg.messageText.startsWith('[SIGNAL]')}">
                                    <fmt:formatDate var="currentMsgDate" value="${msg.messageTime}" pattern="MMMM dd, yyyy" />
                                    <c:if test="${empty prevDate or currentMsgDate ne prevDate}">
                                        <div class="date-divider">
                                            <span>
                                                <fmt:formatDate value="${msg.messageTime}" pattern="MMMM dd, yyyy" />
                                            </span>
                                        </div>
                                        <c:set var="prevDate" value="${currentMsgDate}" />
                                    </c:if>

                                    <div class="message-row ${msg.senderId == sessionScope.user.userId ? 'sent' : 'received'}" style="position:relative;">
                                        <c:if test="${msg.senderId != sessionScope.user.userId}">
                                            <img src="${chatUser.profilePhoto != null && chatUser.profilePhoto.startsWith('http') ? chatUser.profilePhoto : pageContext.request.contextPath.concat('/').concat(chatUser.profilePhoto != null ? chatUser.profilePhoto : 'images/default-avatar.png')}" class="msg-avatar">
                                        </c:if>
                                        
                                        <div class="message-bubble ${msg.senderId == sessionScope.user.userId ? 'message-sent' : 'message-received'}" data-id="${msg.messageId}" 
                                             ondblclick="toggleMsgOptions('${msg.messageId}', event)" 
                                             onmousedown="startLongPress('${msg.messageId}', event)" 
                                             onmouseup="cancelLongPress()" 
                                             onmouseleave="cancelLongPress()"
                                             ontouchstart="startLongPress('${msg.messageId}', event)" 
                                             ontouchend="cancelLongPress()" 
                                             style="margin-bottom: 0px; max-width: 80%; width: fit-content; cursor: pointer; user-select: none; -webkit-user-select: none;">
                                             
                                            <!-- ATTACHMENT RENDERING -->
                                            <c:if test="${not empty msg.attachmentUrl}">
                                                <div style="margin-bottom: 8px;">
                                                    <c:choose>
                                                        <c:when test="${msg.attachmentType == 'image_view_once'}">
                                                            <c:choose>
                                                                <c:when test="${msg.senderId == sessionScope.user.userId}">
                                                                    <div style="padding:10px; background:var(--bg-light); border:1px solid var(--border-color); border-radius:8px; font-style:italic; font-size:0.85rem; color:var(--text-muted);">
                                                                        <i class="fas fa-bomb text-danger"></i> You sent a View Once photo.
                                                                    </div>
                                                                </c:when>
                                                                <c:otherwise>
                                                                    <button type="button" class="btn btn-primary" onclick="viewOncePhoto('${msg.attachmentUrl}', '${msg.messageId}', this)" style="border-radius:20px; padding: 6px 16px; font-size: 0.9rem;">
                                                                        <i class="fas fa-image"></i> View Photo
                                                                    </button>
                                                                </c:otherwise>
                                                            </c:choose>
                                                        </c:when>
                                                        <c:when test="${msg.attachmentType == 'image_viewed'}">
                                                            <div style="padding:10px; border-radius:8px; font-style:italic; font-size:0.85rem; color:var(--text-muted);">
                                                                <i class="fas fa-eye"></i> Photo viewed
                                                            </div>
                                                        </c:when>
                                                        <c:when test="${msg.attachmentType == 'image'}">
                                                            <div style="position: relative; display: inline-block;">
                                                                <a href="${msg.attachmentUrl}" target="_blank">
                                                                    <img src="${msg.attachmentUrl}" style="max-width: 100%; max-height: 250px; border-radius: 8px; object-fit: contain;">
                                                                </a>
                                                                <a href="${msg.attachmentUrl}" download="chat_image" target="_blank" style="position: absolute; top: 8px; right: 8px; background: rgba(0,0,0,0.6); color: white; padding: 6px 10px; border-radius: 6px; text-decoration: none; font-size: 0.9rem; transition: background 0.2s;" title="Download Image" onmouseover="this.style.background='rgba(0,0,0,0.8)'" onmouseout="this.style.background='rgba(0,0,0,0.6)'">
                                                                    <i class="fas fa-download"></i>
                                                                </a>
                                                            </div>
                                                        </c:when>
                                                        <c:when test="${msg.attachmentType == 'video'}">
                                                            <video controls style="max-width: 100%; max-height: 250px; border-radius: 8px;">
                                                                <source src="${msg.attachmentUrl}" type="video/mp4">
                                                                Your browser does not support the video tag.
                                                            </video>
                                                        </c:when>
                                                        <c:when test="${msg.attachmentType == 'pdf'}">
                                                            <a href="${msg.attachmentUrl}" target="_blank" style="display: flex; align-items: center; gap: 8px; text-decoration: none; color: inherit; background: rgba(0,0,0,0.05); padding: 8px 12px; border-radius: 8px;">
                                                                <i class="fas fa-file-pdf" style="font-size: 1.5rem; color: #e25555;"></i>
                                                                <span style="text-decoration: underline;">View Document</span>
                                                            </a>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <a href="${msg.attachmentUrl}" target="_blank" style="display: flex; align-items: center; gap: 8px; text-decoration: none; color: inherit; background: rgba(0,0,0,0.05); padding: 8px 12px; border-radius: 8px;">
                                                                <i class="fas fa-file" style="font-size: 1.5rem;"></i>
                                                                <span style="text-decoration: underline;">Open File</span>
                                                            </a>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </div>
                                            </c:if>

                                            ${msg.messageText}
                                            <div style="display:flex; flex-direction: column; align-items: flex-end; margin-top: 4px;">
                                                <div style="display:flex; align-items:center; gap:4px;">
                                                    <span class="msg-time" style="font-size: 0.65rem; opacity: 0.7;">
                                                        <fmt:formatDate value="${msg.messageTime}" pattern="HH:mm" />
                                                    </span>
                                                    <c:if test="${msg.senderId == sessionScope.user.userId && loop.last}">
                                                        <c:choose>
                                                            <c:when test="${msg.read}"><span style="font-size:0.65rem; color:inherit; opacity:0.6;">Seen</span></c:when>
                                                            <c:otherwise><span style="font-size:0.65rem; color:inherit; opacity:0.6;">Sent</span></c:otherwise>
                                                        </c:choose>
                                                    </c:if>
                                                </div>
                                            </div>
                                            <div id="msg-reactions-${msg.messageId}" class="msg-reactions"></div>
                                            
                                            <div class="msg-options-trigger" onclick="toggleMsgOptions('${msg.messageId}', event)">
                                                <i class="fas fa-ellipsis-v"></i>
                                            </div>
                                        </div>
                                        
                                        <!-- Message Dropdown Menu -->
                                        <div id="msg-dropdown-${msg.messageId}" class="msg-dropdown-menu" style="display: none; position: absolute; ${msg.senderId == sessionScope.user.userId ? 'right: 30px;' : 'left: 40px;'} top: 100%; z-index: 100; background: white; border-radius: 8px; box-shadow: 0 4px 12px rgba(0,0,0,0.15); border: 1px solid var(--border-color); padding: 0.25rem 0; min-width: 160px;">
                                            <div class="dropdown-item" onclick="toggleEmojiPicker('${msg.messageId}', event)" style="padding: 0.5rem 1rem; cursor: pointer;">
                                                <i class="far fa-smile" style="width: 20px;"></i> React
                                            </div>
                                            <c:if test="${not empty msg.attachmentUrl && msg.attachmentType == 'image'}">
                                                <div class="dropdown-item" onclick="forceDownload('${msg.attachmentUrl}', 'photo_${msg.messageId}.jpg')" style="padding: 0.5rem 1rem; cursor: pointer;">
                                                    <i class="fas fa-download" style="width: 20px;"></i> Download Image
                                                </div>
                                            </c:if>
                                            <c:if test="${msg.senderId == sessionScope.user.userId}">
                                                <div class="dropdown-item text-danger" onclick="unsendMessage('${msg.messageId}', '${chatUser.userId}')" style="padding: 0.5rem 1rem; cursor: pointer;">
                                                    <i class="fas fa-undo" style="width: 20px;"></i> Unsend message
                                                </div>
                                            </c:if>
                                            <div class="dropdown-item" onclick="hideMessageLocally(this)" style="padding: 0.5rem 1rem; cursor: pointer;">
                                                <i class="fas fa-eye-slash" style="width: 20px;"></i> Delete for me
                                            </div>
                                        </div>
                                        
                                        <!-- Emoji Picker -->
                                        <div id="emoji-picker-${msg.messageId}" class="emoji-picker-popup" style="display:none; position:absolute; ${msg.senderId == sessionScope.user.userId ? 'right: 30px;' : 'left: 40px;'} top: calc(100% + 40px); z-index: 101; background:var(--bg-white); border:1px solid var(--border-color); border-radius:12px; padding:8px; box-shadow:0 8px 24px rgba(0,0,0,0.15); width: 260px; max-height: 180px; overflow-y: auto; grid-template-columns: repeat(6, 1fr); gap: 6px;">
                                            <c:forTokens items="❤️,🔥,😂,😮,👏,🙌,😢,👍,👎,😀,😃,😄,😁,😆,😅,🤣,🥲,☺️,😊,😇,🙂,🙃,😉,😌,😍,🥰,😘,😗,😙,😚,😋,😛,😝,😜,🤪,🤨,🧐,🤓,😎,🥸,🤩,🥳,😏,😒,😞,😔,😟,😕,🙁,☹️,😣,😖,😫,😩,🥺,😭,😤,😠,😡,🤬,🤯,😳,🥵,🥶,😱,😨,😰,😥,😓,👋,🤚,🖐,✋,🖖,👌,🤌,🤏,✌️,🤞,🤟,🤘,🤙,👈,👉,👆,🖕,👇,☝️,✊,👊,🤛,🤜,👐,🤲,🤝,🙏,✨,💯" delims="," var="emoji">
                                                <span onclick="toggleMessageReaction('${msg.messageId}', '${emoji}', event)" style="cursor:pointer; font-size:1.4rem; text-align:center; transition:transform 0.1s;" onmouseover="this.style.transform='scale(1.2)'" onmouseout="this.style.transform='scale(1)'">${emoji}</span>
                                            </c:forTokens>
                                        </div>
                                    </div>
                                    <c:set var="lastMsgId" value="${msg.messageId}" />
                                </c:if>
                            </c:forEach>
                            
                            <!-- Typing Indicator -->
                            <div id="typingIndicator" style="display: none; padding: 10px 20px; color: var(--text-muted); font-size: 0.85rem; font-style: italic;">
                                ${chatUser.name} is typing...
                            </div>
                        </div>
                        <script>
                            document.querySelectorAll('.message-bubble').forEach(bubble => {
                                const id = bubble.getAttribute('data-id');
                                if (id) loadMessageReactions(id);
                                
                                // Intercept [POST_SHARE:X] tags and render as rich interactive cards
                                let html = bubble.innerHTML;
                                if (html.includes('[POST_SHARE:')) {
                                    bubble.innerHTML = html.replace(/\[POST_SHARE:(\d+)\]/g, (match, p1) => {
                                        const uniqueId = 'share-' + p1 + '-' + Math.floor(Math.random() * 1000000);
                                        // Wait a bit more to ensure scripts are loaded
                                        setTimeout(() => {
                                            const container = document.getElementById(uniqueId);
                                            if (container && typeof renderRichPostPreview === 'function') {
                                                renderRichPostPreview(container, p1);
                                            } else {
                                                // Retry once if scripts are still loading
                                                setTimeout(() => {
                                                    const retryContainer = document.getElementById(uniqueId);
                                                    if (retryContainer && typeof renderRichPostPreview === 'function') {
                                                        renderRichPostPreview(retryContainer, p1);
                                                    }
                                                }, 500);
                                            }
                                        }, 100);
                                        
                                        return `<div id="${uniqueId}" style="margin: 0.5rem 0; width: 100%; max-width: 300px; min-height: 120px; display: flex; align-items: center; justify-content: center; background: var(--bg-light); border-radius: 12px; overflow: hidden; border: 1px solid var(--border-color);">
                                            <div style="text-align:center;"><i class="fas fa-spinner fa-spin" style="margin-bottom:8px;"></i><br><span style="font-size:0.75rem; color:var(--text-muted);">Loading post...</span></div>
                                        </div>`;
                                    });
                                }
                            });
                        </script>
                    </div>
                    
                    <input type="hidden" id="lastMessageId" value="${lastMsgId != null ? lastMsgId : 0}">
                    <input type="hidden" id="currentChatUserId" value="${chatUser.userId}">
                    <input type="hidden" id="currentUserId" value="${sessionScope.user.userId}">
                    
                    <div class="chat-input-area" style="position: relative; display: flex; flex-direction: column; padding: 0.75rem 1rem; border-top: 1px solid var(--border-color); background: var(--bg-white);">
                        <!-- Preview container -->
                        <div id="attachment-preview-container" style="display: none; padding: 8px 12px; background: var(--bg-light); border-radius: 8px; margin-bottom: 8px; align-items: center; justify-content: space-between; border: 1px solid var(--border-color);">
                            <div style="display: flex; align-items: center; gap: 8px;">
                                <i id="attachment-preview-icon" class="fas fa-file text-muted"></i>
                                <span id="attachment-preview-name" style="font-size: 0.9rem; font-weight: 500; overflow: hidden; text-overflow: ellipsis; max-width: 200px; white-space: nowrap;"></span>
                            </div>
                            <button type="button" onclick="clearChatAttachment()" style="background: none; border: none; cursor: pointer; color: var(--danger-color); padding: 4px;">
                                <i class="fas fa-times"></i>
                            </button>
                        </div>
                            </button>

                            <input type="text" name="messageText" class="form-input" placeholder="Type a message..." autocomplete="off" style="flex: 1; border-radius: 2rem; min-width: 0;">

                            <button type="submit" class="btn btn-primary" style="flex-shrink:0; border-radius: 50%; width: 42px; height: 42px; padding: 0; display:flex; justify-content:center; align-items:center;" onclick="showSendingIndicator(this)">
                                <i class="fas fa-paper-plane" id="chat-send-icon"></i>
                            </button>
                        </form>
                    </div>

                    <!-- Client-Side Attachment Preview Logic -->
                    <script>
                        function handleChatAttachmentPreview(input) {
                            const container = document.getElementById('attachment-preview-container');
                            const nameSpan = document.getElementById('attachment-preview-name');
                            const icon = document.getElementById('attachment-preview-icon');
                            const viewOnceLabel = document.getElementById('viewOnceLabel');
                            
                            if (input.files && input.files[0]) {
                                const file = input.files[0];
                                nameSpan.innerText = file.name;
                                
                                // Set icon based on type
                                icon.className = 'fas text-muted';
                                if (file.type.startsWith('image/')) {
                                    icon.classList.add('fa-image');
                                    icon.style.color = '#3b82f6';
                                    if(viewOnceLabel) viewOnceLabel.style.display = 'flex';
                                } else if (file.type.startsWith('video/')) {
                                    icon.classList.add('fa-video');
                                    icon.style.color = '#8b5cf6';
                                    if(viewOnceLabel) viewOnceLabel.style.display = 'none';
                                } else if (file.type === 'application/pdf') {
                                    icon.classList.add('fa-file-pdf');
                                    icon.style.color = '#e25555';
                                    if(viewOnceLabel) viewOnceLabel.style.display = 'none';
                                } else {
                                    icon.classList.add('fa-file');
                                    if(viewOnceLabel) viewOnceLabel.style.display = 'none';
                                }
                                
                                container.style.display = 'flex';
                            } else {
                                container.style.display = 'none';
                                if(viewOnceLabel) viewOnceLabel.style.display = 'none';
                            }
                        }
                        
                        function clearChatAttachment() {
                            const input = document.getElementById('chat-attachment');
                            input.value = '';
                            document.getElementById('attachment-preview-container').style.display = 'none';
                        }

                        function showSendingIndicator(btn) {
                            const form = document.getElementById('chatFormObject');
                            const msgInput = form.querySelector('input[name="messageText"]');
                            const fileInput = form.querySelector('input[name="attachment"]');
                            
                            // Only show loading if there is actually data to send
                            if ((msgInput.value && msgInput.value.trim() !== '') || (fileInput.files && fileInput.files.length > 0)) {
                                const icon = document.getElementById('chat-send-icon');
                                icon.className = 'fas fa-spinner fa-spin';
                            }
                        }
                    </script>
                    <script>
                        // Convert times to local timezone
                        function formatLocalTimes() {
                            document.querySelectorAll('.local-time-convert:not(.converted)').forEach(el => {
                                const d = new Date(parseInt(el.getAttribute('data-time')));
                                if (el.getAttribute('data-format') === 'time') {
                                    el.innerHTML = d.toLocaleTimeString([], {hour: '2-digit', minute:'2-digit'});
                                } else {
                                    el.innerHTML = d.toLocaleDateString([], {month: 'short', day: 'numeric', year: 'numeric'}) + ' ' + d.toLocaleTimeString([], {hour: '2-digit', minute:'2-digit'});
                                }
                                el.classList.add('converted');
                            });
                        }
                        formatLocalTimes();

                        // Chat Polling and Typing Logic
                        let lastMessageId = parseInt(document.getElementById('lastMessageId').value) || 0;
                        const mainChatUserId = document.getElementById('currentChatUserId').value;
                        const typingIndicator = document.getElementById('typingIndicator');
                        
                        function sendTypingPing() {
                            fetch((window.contextPath || '') + '/MessageServlet', {
                                method: 'POST',
                                headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                                body: 'action=typing&withUserId=' + mainChatUserId
                            }).catch(console.error);
                        }
                        
                        const msgInputArea = document.querySelector('input[name="messageText"]');
                        if (msgInputArea) {
                            msgInputArea.addEventListener('input', () => {
                                // debounce typing ping
                                if(window.typingTimer) clearTimeout(window.typingTimer);
                                window.typingTimer = setTimeout(sendTypingPing, 500);
                            });
                        }

                        function pollMessages() {
                            fetch((window.contextPath || '') + '/MessageServlet?ajax=true&with=' + mainChatUserId + '&lastId=' + lastMessageId)
                            .then(res => res.json())
                            .then(data => {
                                // data could be an array of messages or { typing: true/false, messages: [...] }
                                let messages = [];
                                if (Array.isArray(data)) {
                                    messages = data;
                                } else if (data.messages) {
                                    messages = data.messages;
                                    typingIndicator.style.display = data.isTyping ? 'block' : 'none';
                                }
                                
                                if (messages.length > 0) {
                                    const chatWindow = document.getElementById('chatWindow');
                                    messages.forEach(msg => {
                                        if (msg.text && msg.text.startsWith('[SIGNAL]')) {
                                            handleWebRTCSignal(msg.text);
                                        } else {
                                            appendMessageToChat(msg);
                                        }
                                        if (msg.id > lastMessageId) lastMessageId = msg.id;
                                    });
                                    document.getElementById('lastMessageId').value = lastMessageId;
                                    chatWindow.scrollTop = chatWindow.scrollHeight;
                                    setTimeout(formatLocalTimes, 100);
                                }
                            })
                            .catch(err => {
                                // Silent fail for polling
                            });
                        }
                        
                        function appendMessageToChat(msg) {
                            const chatWindow = document.getElementById('chatWindow');
                            const isSender = msg.senderId == window.currentUserId;
                            const avatarHtml = !isSender ? `<img src="${chatUser.profilePhoto != null ? chatUser.profilePhoto : 'images/default-avatar.png'}" class="msg-avatar">` : '';
                            
                            const div = document.createElement('div');
                            div.className = 'message-row ' + (isSender ? 'sent' : 'received');
                            div.style.position = 'relative';
                            
                            let attachmentHtml = '';
                            if (msg.attachmentType === 'image_view_once') {
                                if (isSender) {
                                    attachmentHtml = `<div style="margin-bottom:8px;"><div style="padding:10px; background:var(--bg-light); border:1px solid var(--border-color); border-radius:8px; font-style:italic; font-size:0.85rem; color:var(--text-muted);">
                                        <i class="fas fa-bomb text-danger"></i> You sent a View Once photo.
                                    </div></div>`;
                                } else {
                                    attachmentHtml = `<div style="margin-bottom:8px;"><button type="button" class="btn btn-primary" onclick="viewOncePhoto('\${msg.attachmentUrl}', '\${msg.id}', this)" style="border-radius:20px; padding: 6px 16px; font-size: 0.9rem;">
                                        <i class="fas fa-image"></i> View Photo
                                    </button></div>`;
                                }
                            } else if (msg.attachmentType === 'image_viewed') {
                                attachmentHtml = `<div style="margin-bottom:8px;"><div style="padding:10px; border-radius:8px; font-style:italic; font-size:0.85rem; color:var(--text-muted);">
                                    <i class="fas fa-eye"></i> Photo viewed
                                </div></div>`;
                            } else if (msg.attachmentUrl && msg.attachmentUrl !== 'null') {
                                if (msg.attachmentType === 'image') {
                                    attachmentHtml = `<div style="margin-bottom:8px;"><img src="\${msg.attachmentUrl}" style="max-width:100%; max-height:250px; border-radius:8px; object-fit:contain;"></div>`;
                                } else if (msg.attachmentType === 'video') {
                                    attachmentHtml = `<div style="margin-bottom:8px;"><video controls src="\${msg.attachmentUrl}" style="max-width:100%; max-height:250px; border-radius:8px;"></video></div>`;
                                }
                            }
                            
                            div.innerHTML = `
                                \${avatarHtml}
                                <div class="message-bubble \${isSender ? 'message-sent' : 'message-received'}" data-id="\${msg.id}"
                                     ondblclick="toggleMsgOptions('\${msg.id}', event)" 
                                     onmousedown="startLongPress('\${msg.id}', event)" 
                                     onmouseup="cancelLongPress()" 
                                     onmouseleave="cancelLongPress()"
                                     ontouchstart="startLongPress('\${msg.id}', event)" 
                                     ontouchend="cancelLongPress()" 
                                     style="margin-bottom: 0px; max-width: 80%; width: fit-content; cursor: pointer; user-select: none; -webkit-user-select: none;">
                                    \${attachmentHtml}
                                    ${(function() {
                                        var rawText = msg.text || '';
                                        if (rawText.includes('[POST_SHARE:')) {
                                            var postShareRegex = /\[POST_SHARE:(\d+)\]/g;
                                            return rawText.replace(postShareRegex, function(match, p1) {
                                                var cId = 'poll-post-' + msg.id + '-' + p1;
                                                setTimeout(function() {
                                                    var el = document.getElementById(cId);
                                                    if (el && typeof renderRichPostPreview === 'function') {
                                                        renderRichPostPreview(el, p1);
                                                    } else {
                                                        setTimeout(function() {
                                                            var el2 = document.getElementById(cId);
                                                            if (el2 && typeof renderRichPostPreview === 'function') {
                                                                renderRichPostPreview(el2, p1);
                                                            }
                                                        }, 800);
                                                    }
                                                }, 150);
                                                return '<div id="' + cId + '" style="min-height:100px; display:flex; align-items:center; justify-content:center; padding:1rem; border:1px solid var(--border-color); border-radius:12px; background:var(--bg-light); margin-top:0.5rem;"><i class="fas fa-spinner fa-spin text-muted" style="font-size:1.5rem;"></i><span style="margin-left:8px; font-size:0.85rem; color:var(--text-muted);">Loading Shared Post...</span></div>';
                                            });
                                        }
                                        return rawText;
                                    })()}
                                    <div style="display:flex; justify-content:flex-end; align-items:center; gap:4px; margin-top:4px;">
                                        <div class="msg-time local-time-convert" data-time="\${msg.time}" data-format="time"></div>
                                    </div>
                                    <div id="msg-reactions-\${msg.id}" class="msg-reactions"></div>
                                </div>
                                
                                <div class="msg-options-trigger" onclick="toggleMsgOptions('\${msg.id}', event)" style="padding: 0 8px; cursor: pointer; color: var(--text-muted); display: flex; align-items: center;">
                                    <i class="fas fa-ellipsis-v"></i>
                                </div>
                                
                                <div id="msg-dropdown-\${msg.id}" class="msg-dropdown-menu" style="display: none; position: absolute; \${isSender ? 'right: 30px;' : 'left: 40px;'} top: 100%; z-index: 100; background: white; border-radius: 8px; box-shadow: 0 4px 12px rgba(0,0,0,0.15); border: 1px solid var(--border-color); padding: 0.25rem 0; min-width: 160px;">
                                    <div class="dropdown-item" onclick="toggleEmojiPicker('\${msg.id}', event)" style="padding: 0.5rem 1rem; cursor: pointer;">
                                        <i class="far fa-smile" style="width: 20px;"></i> React
                                    </div>
                                    \${msg.attachmentUrl && msg.attachmentUrl !== 'null' && msg.attachmentType === 'image' ? 
                                        '<div class="dropdown-item" onclick="forceDownload(\\''+msg.attachmentUrl+'\\', \\'photo_'+msg.id+'.jpg\\')" style="padding: 0.5rem 1rem; cursor: pointer;"><i class="fas fa-download" style="width: 20px;"></i> Download Image</div>' 
                                    : ''}
                                    \${isSender ? '<div class="dropdown-item text-danger" onclick="unsendMessage(\\''+msg.id+'\\', \\''+mainChatUserId+'\\')" style="padding: 0.5rem 1rem; cursor: pointer;"><i class="fas fa-undo" style="width: 20px;"></i> Unsend message</div>' : ''}
                                    <div class="dropdown-item" onclick="hideMessageLocally(this)" style="padding: 0.5rem 1rem; cursor: pointer;">
                                        <i class="fas fa-eye-slash" style="width: 20px;"></i> Delete for me
                                    </div>
                                </div>
                                
                                <div id="emoji-picker-\${msg.id}" class="emoji-picker-popup" style="display:none; position:absolute; \${isSender ? 'right: 30px;' : 'left: 40px;'} top: calc(100% + 40px); z-index: 101; background:var(--bg-white); border:1px solid var(--border-color); border-radius:12px; padding:8px; box-shadow:0 8px 24px rgba(0,0,0,0.15); width: 260px; max-height: 180px; overflow-y: auto; grid-template-columns: repeat(6, 1fr); gap: 6px;">
                                    \${"❤️,🔥,😂,😮,👏,🙌,😢,👍,👎,😀,😃,😄,😁,😆,😅,🤣,🥲,☺️,😊,😇,🙂,🙃,😉,😌,😍,🥰,😘,😗,😙,😚,😋,😛,😝,😜,🤪,🤨,🧐,🤓,😎,🥸,🤩,🥳,😏,😒,😞,😔,😟,😕,🙁,☹️,😣,😖,😫,😩,🥺,😭,😤,😠,😡,🤬,🤯,😳,🥵,🥶,😱,😨,😰,😥,😓,👋,🤚,🖐,✋,🖖,👌,🤌,🤏,✌️,🤞,🤟,🤘,🤙,👈,👉,👆,🖕,👇,☝️,✊,👊,🤛,🤜,👐,🤲,🤝,🙏,✨,💯".split(',').map(emoji => 
                                        '<span onclick="toggleMessageReaction(\\''+msg.id+'\\', \\''+emoji+'\\', event)" style="cursor:pointer; font-size:1.4rem; text-align:center; transition:transform 0.1s;" onmouseover="this.style.transform=\\'scale(1.2)\\'" onmouseout="this.style.transform=\\'scale(1)\\'">'+emoji+'</span>'
                                    ).join('')}
                                </div>
                            `;
                            chatWindow.insertBefore(div, typingIndicator);
                        }

                        setInterval(pollMessages, 2000); // Poll every 2 seconds
                    </script>
                    
                    <!-- Chat Background Image Logic -->
                    <script>
                        const chatMainBg = document.getElementById('chatWindow'); // Applies to messages area
                        const savedBg = localStorage.getItem('chatBg_${sessionScope.user.userId}');
                        if (savedBg && chatMainBg) {
                            chatMainBg.style.backgroundImage = `url(\${savedBg})`;
                            chatMainBg.style.backgroundSize = 'cover';
                            chatMainBg.style.backgroundPosition = 'center';
                        }
                    </script>
                    
                    <!-- Scroll to bottom script -->
                    <script>
                        const chatWindow = document.getElementById('chatWindow');
                        chatWindow.scrollTop = chatWindow.scrollHeight;
                    </script>
                </c:when>
                
                <c:otherwise>
                    <!-- No chat selected -->
                    <div style="display: flex; flex-direction: column; align-items: center; justify-content: center; height: 100%; color: var(--text-muted);">
                        <i class="far fa-comments fa-5x mb-3 text-primary" style="opacity: 0.5;"></i>
                        <h2>Your Messages</h2>
                        <p>Select a friend from the sidebar to view your conversation.</p>
                    </div>
                </c:otherwise>
            </c:choose>
        </div>
        </div>
    </div>
    
    <!-- Shared Media Modal -->
    <div id="sharedMediaModal" class="modal" style="display:none; align-items:center; justify-content:center; background:rgba(0,0,0,0.6); z-index:9000;">
        <div class="modal-content card" style="max-width:600px; width:95%; height:80vh; display:flex; flex-direction:column; padding:0; overflow:hidden;">
            <div style="padding: 1rem 1.5rem; border-bottom: 1px solid var(--border-color); display: flex; justify-content: space-between; align-items: center; background: var(--bg-white);">
                <h3 style="margin: 0; display:flex; align-items:center; gap:0.5rem;"><i class="fas fa-images text-primary"></i> Shared Media</h3>
                <span class="close" onclick="document.getElementById('sharedMediaModal').style.display='none'" style="font-size:1.5rem; cursor:pointer;">&times;</span>
            </div>
            <div style="flex: 1; overflow-y: auto; padding: 1.5rem; background: var(--bg-light);">
                <div id="shared-media-grid" style="display: grid; grid-template-columns: repeat(auto-fill, minmax(120px, 1fr)); gap: 1rem;">
                    <!-- Media items injected here via JS -->
                </div>
            </div>
            <div style="padding: 1rem; border-top: 1px solid var(--border-color); text-align: center; background: var(--bg-white);">
                <a href="ProfileServlet?id=${chatUser.userId}" class="btn btn-outline" style="width: 100%;">View Full Profile</a>
            </div>
        </div>
    </div>
    
    <!-- Chat Themes Modal -->
    <div id="chatThemeModal" class="modal" style="display:none; align-items:center; justify-content:center; background:rgba(0,0,0,0.6); z-index:9000;">
        <div class="modal-content card" style="max-width:400px; width:95%; height:auto; display:flex; flex-direction:column; padding:0; overflow:hidden;">
            <div style="padding: 1rem 1.5rem; border-bottom: 1px solid var(--border-color); display: flex; justify-content: space-between; align-items: center; background: var(--bg-white);">
                <h3 style="margin: 0; display:flex; align-items:center; gap:0.5rem;"><i class="fas fa-palette text-primary"></i> Chat Themes</h3>
                <span class="close" onclick="document.getElementById('chatThemeModal').style.display='none'" style="font-size:1.5rem; cursor:pointer;">&times;</span>
            </div>
            <div style="flex: 1; overflow-y: auto; padding: 1.5rem; background: var(--bg-light);">
                <div id="themes-grid" style="display: grid; grid-template-columns: 1fr; gap: 1rem;">
                    <!-- Themes injected here -->
                </div>
            </div>
        </div>
    </div>
    
    <!-- Theme Logic -->
    <script>
        const chatThemes = [
            { id: "default", name: "Default Light", bg: "var(--bg-light)", sent: "var(--primary-color)", received: "var(--bg-white)", sentText: "white", receivedText: "var(--text-main)" },
            { id: "dark", name: "Dark Mode", bg: "#1f2937", sent: "#3b82f6", received: "#374151", sentText: "white", receivedText: "#f3f4f6" },
            { id: "ocean", name: "Ocean Blue", bg: "linear-gradient(to right, #00c6ff, #0072ff)", sent: "rgba(255,255,255,0.9)", received: "rgba(0,0,0,0.6)", sentText: "#0072ff", receivedText: "white" },
            { id: "sunset", name: "Sunset Orange", bg: "linear-gradient(to top, #ff7e5f, #feb47b)", sent: "#ff512f", received: "#fff", sentText: "white", receivedText: "#333" },
            { id: "purple", name: "Purple Dream", bg: "linear-gradient(to right, #feac5e, #c779d0, #4bc0c8)", sent: "#8b5cf6", received: "#fff", sentText: "white", receivedText: "#4c1d95" },
            { id: "custom", name: "Custom", bg: "var(--custom-bg, #fff)", sent: "var(--primary-color)", received: "var(--bg-white)", sentText: "white", receivedText: "var(--text-main)" }
        ];

        function applyTheme(themeId) {
            const theme = chatThemes.find(t => t.id === themeId);
            if (!theme) return;
            
            const chatMainBg = document.getElementById('chatWindow');
            if (chatMainBg) {
                if (themeId === 'custom') {
                    const customBg = localStorage.getItem('chatCustomBg_' + window.currentUserId) || '#ffffff';
                    chatMainBg.style.background = customBg;
                    chatMainBg.style.backgroundImage = customBg.includes('gradient') ? customBg : 'none';
                } else {
                    const hasCustomImg = localStorage.getItem('chatBg_' + window.currentUserId);
                    if (!hasCustomImg || themeId !== 'default') {
                        chatMainBg.style.background = theme.bg;
                        if(themeId === 'default' && hasCustomImg) {
                            chatMainBg.style.backgroundImage = 'url('+hasCustomImg+')';
                            chatMainBg.style.backgroundSize = 'cover';
                        } else {
                            chatMainBg.style.backgroundImage = theme.bg.includes('gradient') ? theme.bg : 'none';
                        }
                    }
                }
                
                chatMainBg.style.setProperty('--chat-msg-sent', theme.sent);
                chatMainBg.style.setProperty('--chat-msg-recv', theme.received);
                chatMainBg.style.setProperty('--chat-text-sent', theme.sentText);
                chatMainBg.style.setProperty('--chat-text-recv', theme.receivedText);
                
                if (themeId !== 'default') chatMainBg.classList.add('theme-active');
                else chatMainBg.classList.remove('theme-active');
            }
            localStorage.setItem('chatTheme_' + window.currentUserId, themeId);
            document.getElementById('chatThemeModal').style.display='none';
            renderThemes();
        }

        function renderThemes() {
            const grid = document.getElementById('themes-grid');
            if (!grid) return;
            grid.innerHTML = '';
            const activeThemeId = localStorage.getItem('chatTheme_' + window.currentUserId) || 'default';
            
            chatThemes.forEach(t => {
                const isActive = t.id === activeThemeId;
                grid.innerHTML += `
                    <div style="display:flex; align-items:center; justify-content:space-between; padding:10px; border-radius:12px; border:2px solid \${isActive ? 'var(--primary-color)' : 'transparent'}; background:var(--bg-white); cursor:pointer; box-shadow:0 1px 3px rgba(0,0,0,0.05);" onclick="applyTheme('\${t.id}')">
                        <div style="display:flex; align-items:center; gap:12px;">
                            <div style="width:40px; height:40px; border-radius:50%; background:\${t.bg}; border:1px solid rgba(0,0,0,0.1); display:flex; align-items:center; justify-content:center; overflow:hidden;"></div>
                            <span style="font-weight:600; font-size:1rem; \${isActive ? 'color:var(--primary-color)' : 'color:var(--text-main)'}">\${t.name}</span>
                        </div>
                        \${isActive ? '<i class="fas fa-check-circle text-primary" style="font-size:1.2rem;"></i>' : ''}
                    </div>
                `;
            });

            // Add Custom Base UI
            grid.innerHTML += `
                <div style="margin-top:1rem; padding-top:1rem; border-top:1px solid var(--border-color);">
                    <label style="font-weight:600; display:block; margin-bottom:0.5rem;">Custom Background</label>
                    <div style="display:flex; gap:10px; align-items:center;">
                        <input type="color" id="customColorPicker" onchange="applyCustomBg(this.value)" style="width:40px; height:40px; border:none; border-radius:8px; cursor:pointer;" value="#ffffff">
                        <select onchange="applyCustomBg(this.value)" style="flex:1; padding:8px; border-radius:8px; border:1px solid var(--border-color); background:var(--bg-white);">
                            <option value="">Solid Color</option>
                            <option value="linear-gradient(135deg, #667eea 0%, #764ba2 100%)">Royal Purple</option>
                            <option value="linear-gradient(135deg, #f093fb 0%, #f5576c 100%)">Soft Pink</option>
                            <option value="linear-gradient(45deg, #8baaaa 0%, #ae8b9c 100%)">Muted Blend</option>
                            <option value="linear-gradient(to top, #ff9a9e 0%, #fecfef 99%, #fecfef 100%)">Sugar Fresh</option>
                        </select>
                    </div>
                </div>
            `;
        }

        function applyCustomBg(val) {
            if (!val) return;
            localStorage.setItem('chatCustomBg_' + window.currentUserId, val);
            applyTheme('custom');
        }
        
        document.addEventListener('DOMContentLoaded', () => {
            const savedThemeId = localStorage.getItem('chatTheme_' + window.currentUserId) || 'default';
            if (savedThemeId !== 'default') {
                applyTheme(savedThemeId);
            }
            renderThemes();
        });
    </script>
    
    <!-- Message Context Menu Logic -->
    <script>
        // Long Press and Double Click Logic
        let longPressTimer;
        
        function startLongPress(msgId, e) {
            cancelLongPress();
            longPressTimer = setTimeout(() => {
                toggleMsgOptions(msgId, e);
            }, 600); // 600ms = long press
        }
        
        function cancelLongPress() {
            clearTimeout(longPressTimer);
        }
        
        function toggleMsgOptions(msgId, e) {
            if (e) e.stopPropagation();
            
            // Close all others first
            document.querySelectorAll('.msg-dropdown-menu').forEach(menu => {
                if (menu.id !== 'msg-dropdown-' + msgId) menu.style.display = 'none';
            });
            document.querySelectorAll('.emoji-picker-popup').forEach(p => p.style.display = 'none');
            
            const menu = document.getElementById('msg-dropdown-' + msgId);
            if (menu) {
                const isVisible = menu.style.display === 'block';
                menu.style.display = isVisible ? 'none' : 'block';
            }
        }
        
        function unsendMessage(msgId, withUserId) {
            if (!confirm("Unsend this message for everyone?")) return;
            const form = document.createElement('form');
            form.method = 'POST';
            form.action = 'MessageServlet';
            form.innerHTML = `<input type="hidden" name="action" value="deleteMessage"><input type="hidden" name="messageId" value="\${msgId}"><input type="hidden" name="withUserId" value="\${withUserId}">`;
            document.body.appendChild(form);
            form.submit();
        }
        
        function hideMessageLocally(btn) {
            const row = btn.closest('.message-row');
            if (row) {
                row.style.opacity = '0';
                setTimeout(() => row.style.display = 'none', 300);
            }
        }
        
        function forceDownload(url, filename) {
            fetch(url).then(response => response.blob()).then(blob => {
                const link = document.createElement('a');
                link.href = URL.createObjectURL(blob);
                link.download = filename || 'download.jpeg';
                document.body.appendChild(link);
                link.click();
                document.body.removeChild(link);
                URL.revokeObjectURL(link.href);
            }).catch(e => {
                console.error("Download failed, opening cross-origin fallback", e);
                window.open(url, '_blank');
            });
        }
        
        function viewOncePhoto(url, msgId, btn) {
            // Show modal covering screen
            const modal = document.createElement('div');
            modal.style = "position:fixed; top:0;left:0;width:100%;height:100%;background:black;z-index:9999;display:flex;align-items:center;justify-content:center;flex-direction:column;";
            modal.innerHTML = `
                <div style="position:absolute; top:20px; right:20px; color:white; font-size:1.5rem; cursor:pointer;" onclick="this.parentElement.remove()">
                    <i class="fas fa-times"></i>
                </div>
                <img src="\${url}" style="max-width:100%; max-height:80vh; object-fit:contain;">
                <div style="color:white; margin-top:20px; font-size:0.9rem;"><i class="fas fa-fire" style="color:#ff6b6b;"></i> This photo will disappear when you close this screen.</div>
            `;
            document.body.appendChild(modal);
            
            // Replace the button with "Viewed" text
            const parent = btn.parentElement;
            parent.innerHTML = `<div style="padding:10px; border-radius:8px; font-style:italic; font-size:0.85rem; color:var(--text-muted);"><i class="fas fa-eye"></i> Photo viewed</div>`;
            
            // Tell server to mark it as viewed (which clears DB attachment_url and changes type to image_viewed)
            fetch((window.contextPath || '') + '/MessageServlet', {
                method: 'POST',
                headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                body: 'action=markViewOnce&messageId=' + msgId
            }).catch(console.error);
        }
        
        function openSharedMediaModal() {
            const modal = document.getElementById('sharedMediaModal');
            const container = document.getElementById('shared-media-grid');
            container.innerHTML = '';
            
            // Extract media from the chat DOM
            const mediaElements = document.querySelectorAll('.message-bubble img[src], .message-bubble video source');
            
            if (mediaElements.length === 0) {
                container.innerHTML = '<div class="text-center text-muted" style="grid-column: 1/-1; padding: 3rem;"><i class="fas fa-folder-open fa-3x mb-3" style="opacity:0.3;"></i><br>No media shared in this conversation yet.</div>';
            } else {
                const uniqueSrcs = new Set();
                mediaElements.forEach(el => {
                    // Ignore emojis or default avatars if they accidentally have img tags instead of span
                    if (el.classList.contains('msg-avatar')) return; 
                    
                    const src = el.tagName === 'SOURCE' ? el.src : el.src;
                    
                    const msgRow = el.closest('.message-bubble');
                    const timeEl = msgRow ? msgRow.querySelector('.msg-time') : null;
                    const timeText = timeEl ? timeEl.innerText.trim() : 'Unknown Time';
                    
                    if (!uniqueSrcs.has(src)) {
                        uniqueSrcs.add(src);
                        if (el.tagName === 'SOURCE') {
                            container.innerHTML += `
                                <div class="media-item shadow-sm" style="position:relative; aspect-ratio:1/1; background:#000; overflow:hidden; border-radius:12px;">
                                    <video src="\${src}" style="width:100%; height:100%; object-fit:cover;"></video>
                                    <i class="fas fa-video" style="position:absolute; top:8px; right:8px; color:white; text-shadow:0 1px 3px rgba(0,0,0,0.8);"></i>
                                    <div style="position:absolute; bottom:0; left:0; right:0; background:linear-gradient(transparent, rgba(0,0,0,0.8)); color:white; font-size:10px; padding:8px 6px 4px;">\${timeText}</div>
                                </div>`;
                        } else {
                            container.innerHTML += `
                                <div class="media-item shadow-sm" style="position:relative; aspect-ratio:1/1; background:#eee; overflow:hidden; border-radius:12px;">
                                    <img src="\${src}" style="width:100%; height:100%; object-fit:cover; cursor:pointer;" onclick="window.open('\${src}', '_blank')">
                                    <div style="position:absolute; bottom:0; left:0; right:0; background:linear-gradient(transparent, rgba(0,0,0,0.8)); color:white; font-size:10px; padding:8px 6px 4px;">\${timeText}</div>
                                </div>`;
                        }
                    }
                });
            }
            modal.style.display = 'flex';
        }
        
        // Hide dropdowns when clicking outside
        document.addEventListener('click', (e) => {
            if (!e.target.closest('.msg-dropdown-menu') && !e.target.closest('.msg-options-trigger') && !e.target.closest('.message-bubble') && !e.target.closest('button[onclick="toggleChatHeaderMenu(event)"]')) {
                document.querySelectorAll('.msg-dropdown-menu').forEach(menu => menu.style.display = 'none');
            }
        });
        
        function toggleChatHeaderMenu(e) {
            e.stopPropagation();
            const menu = document.getElementById('chatHeaderMenu');
            // Hide other menus
            document.querySelectorAll('.msg-dropdown-menu').forEach(m => {
                if(m !== menu) m.style.display = 'none';
            });
            menu.style.display = menu.style.display === 'block' ? 'none' : 'block';
        }
        
        function goToFirstMessage() {
            const chatWindow = document.getElementById('chatWindow');
            if (chatWindow) {
                chatWindow.scrollTo({ top: 0, behavior: 'smooth' });
                document.getElementById('chatHeaderMenu').style.display = 'none';
            }
        }
    </script>
    
    <!-- Message Reaction Logic -->
    <script>
        function toggleEmojiPicker(messageId, e) {
            e.stopPropagation();
            const picker = document.getElementById('emoji-picker-' + messageId);
            if (picker.style.display === 'grid') {
                picker.style.display = 'none';
            } else {
                document.querySelectorAll('.emoji-picker-popup').forEach(p => p.style.display = 'none');
                picker.style.display = 'grid';
            }
        }
        
        document.addEventListener('click', documentClickListener);
        function documentClickListener(e) {
            document.querySelectorAll('.emoji-picker-popup').forEach(p => p.style.display = 'none');
        }

        function toggleMessageReaction(messageId, emoji, e) {
            e.stopPropagation();
            document.getElementById('emoji-picker-' + messageId).style.display = 'none';
            fetch((window.contextPath || '') + '/InteractionServlet', {
                method: 'POST',
                headers: {'Content-Type': 'application/x-www-form-urlencoded'},
                body: 'action=reactMessage&messageId=' + messageId + '&emoji=' + encodeURIComponent(emoji)
            })
            .then(res => res.json())
            .then(data => {
                loadMessageReactions(messageId);
            })
            .catch(err => console.error('Error toggling reaction:', err));
        }

        function loadMessageReactions(messageId) {
            fetch((window.contextPath || '') + '/InteractionServlet', {
                method: 'POST',
                headers: {'Content-Type': 'application/x-www-form-urlencoded'},
                body: 'action=getMessageReactions&messageId=' + messageId
            })
            .then(res => res.json())
            .then(data => {
                const container = document.getElementById('msg-reactions-' + messageId);
                if (!container) return;
                
                if (data.length === 0) {
                    container.innerHTML = '';
                    return;
                }
                
                let html = '';
                data.forEach(r => {
                    html += '<span class="reaction-badge" title="React with '+r.emoji+'" style="background:transparent; border:none; padding:2px 4px; font-size:1.15rem; margin-right:2px; cursor:pointer;" onclick="toggleMessageReaction(\''+messageId+'\', \''+r.emoji+'\', event)">' + r.emoji + '</span>';
                });
                container.innerHTML = html;
            })
            .catch(err => console.error('Error loading reactions:', err));
        }
    </script>
    
    <!-- WebRTC Video Call Logic -->
    <script>
        let localStream;
        let peerConnection;
        let isCaller = false;
        let callInterval;
        
        const servers = {
            iceServers: [
                { urls: 'stun:stun.l.google.com:19302' }
            ]
        };

        const startVideoCallBtn = document.getElementById('startVideoCallBtn');
        const videoOverlay = document.getElementById('video-overlay');
        const incomingCallUI = document.getElementById('incoming-call-ui');
        const callControls = document.getElementById('call-controls');
        
        if (startVideoCallBtn) {
            startVideoCallBtn.onclick = () => {
                isCaller = true;
                startCallUI();
                setupWebRTC();
            };
        }

        function startCallUI() {
            videoOverlay.style.display = 'flex';
            incomingCallUI.style.display = 'none';
            callControls.style.display = 'flex';
        }

        async function setupWebRTC() {
            try {
                localStream = await navigator.mediaDevices.getUserMedia({ video: true, audio: true });
                document.getElementById('localVideo').srcObject = localStream;
                
                peerConnection = new RTCPeerConnection(servers);
                localStream.getTracks().forEach(track => peerConnection.addTrack(track, localStream));
                
                peerConnection.ontrack = event => {
                    document.getElementById('remoteVideo').srcObject = event.streams[0];
                };
                
                peerConnection.onicecandidate = event => {
                    if (event.candidate) {
                        sendSignal({ type: 'ice', candidate: event.candidate });
                    }
                };

                if (isCaller) {
                    const offer = await peerConnection.createOffer();
                    await peerConnection.setLocalDescription(offer);
                    sendSignal({ type: 'offer', offer: offer });
                }
            } catch (err) {
                console.error("WebRTC Error:", err);
                alert("Could not access camera/microphone.");
                endCall();
            }
        }

        function sendSignal(data) {
            const chatUserId = new URLSearchParams(window.location.search).get('with');
            if(!chatUserId) return;
            const signalStr = '[SIGNAL]' + JSON.stringify(data);
            fetch((window.contextPath || '') + '/MessageServlet', {
                method: 'POST',
                headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                body: `action=send&receiverId=${chatUserId}&messageText=${encodeURIComponent(signalStr)}&ajax=true`
            });
        }

        // Function called periodically from pollMessages if [SIGNAL] is detected
        async function handleWebRTCSignal(signalText) {
            if (!peerConnection && !signalText.includes('"type":"offer"')) return; // Ignore if not in call and not an offer
            
            try {
                const data = JSON.parse(signalText.replace('[SIGNAL]', ''));
                
                if (data.type === 'offer') {
                    if (!peerConnection) {
                        videoOverlay.style.display = 'flex';
                        callControls.style.display = 'none';
                        incomingCallUI.style.display = 'block';
                        window.pendingOffer = data.offer;
                    }
                } else if (data.type === 'answer') {
                    if (peerConnection) await peerConnection.setRemoteDescription(new RTCSessionDescription(data.answer));
                } else if (data.type === 'ice') {
                    if (peerConnection) await peerConnection.addIceCandidate(new RTCIceCandidate(data.candidate));
                } else if (data.type === 'end') {
                    endCall(false);
                }
            } catch (e) {
                console.error("Signal parse error", e);
            }
        }

        async function acceptCall() {
            isCaller = false;
            startCallUI();
            await setupWebRTC();
            if (window.pendingOffer) {
                await peerConnection.setRemoteDescription(new RTCSessionDescription(window.pendingOffer));
                const answer = await peerConnection.createAnswer();
                await peerConnection.setLocalDescription(answer);
                sendSignal({ type: 'answer', answer: answer });
                window.pendingOffer = null;
            }
        }

        function endCall(notify = true) {
            if (notify) sendSignal({ type: 'end' });
            if (peerConnection) { peerConnection.close(); peerConnection = null; }
            if (localStream) { localStream.getTracks().forEach(t => t.stop()); localStream = null; }
            document.getElementById('video-overlay').style.display = 'none';
            document.getElementById('remoteVideo').srcObject = null;
            document.getElementById('localVideo').srcObject = null;
        }
    </script>
    <script src="${pageContext.request.contextPath}/js/app_v2.js?v=20260317"></script>
</body>
<script>
function goBackToSidebar() {
    document.body.classList.remove('chat-open');
}
function goToFirstMessage() {
    const chatWindow = document.getElementById('chatWindow');
    if (chatWindow) {
        chatWindow.scrollTo({ top: 0, behavior: 'smooth' });
    }
}
function toggleMobileSidebar() {
    document.body.classList.toggle('sidebar-active');
}
</script>
</html>
