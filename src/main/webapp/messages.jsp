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
            gap: 4px;
            position: absolute;
            bottom: -15px;
            left: 10px;
            z-index: 2;
        }
        .message-sent .msg-reactions {
            left: auto;
            right: 10px;
        }
        .reaction-item {
            background: var(--bg-white);
            border: 1px solid var(--border-color);
            border-radius: 10px;
            padding: 2px 6px;
            font-size: 0.75rem;
            cursor: pointer;
            display: flex;
            align-items: center;
            gap: 2px;
            box-shadow: var(--shadow-xs);
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
    </style>
</head>
<body style="background-color: var(--bg-light); margin: 0; height: 100vh; overflow: hidden;">
    <jsp:include page="components/navbar.jsp" />

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
            
            <c:if test="${empty friends}">
                <div class="p-4 text-muted text-center">
                    No friends yet. <br> Add friends to start chatting!
                </div>
            </c:if>
            
            <c:forEach var="friend" items="${friends}">
                <a href="MessageServlet?with=${friend.userId}" class="friend-item ${friend.userId == chatUser.userId ? 'active' : ''}">
                    <img src="${friend.profilePhoto != null && friend.profilePhoto.startsWith('http') ? friend.profilePhoto : pageContext.request.contextPath.concat('/').concat(friend.profilePhoto != null ? friend.profilePhoto : 'images/default-avatar.png')}" class="post-avatar">
                    <div style="flex: 1; min-width: 0;">
                        <div style="font-weight: ${friend.unreadCount > 0 ? '700' : '500'}; overflow: hidden; text-overflow: ellipsis; white-space: nowrap;">${friend.name}</div>
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
                    <div class="chat-header" style="justify-content: space-between;">
                        <div style="display: flex; align-items: center; gap: 1rem;">
                            <img src="${chatUser.profilePhoto != null && chatUser.profilePhoto.startsWith('http') ? chatUser.profilePhoto : pageContext.request.contextPath.concat('/').concat(chatUser.profilePhoto != null ? chatUser.profilePhoto : 'images/default-avatar.png')}" class="post-avatar">
                            <h3 style="margin: 0;"><a href="ProfileServlet?id=${chatUser.userId}" style="color: inherit;">${chatUser.name}</a></h3>
                        </div>
                        <div style="display: flex; align-items: center; gap: 0.5rem;">
                            <button id="startVideoCallBtn" class="btn" style="background: none; border: none; color: var(--primary-color); cursor: pointer; padding: 8px;" title="Video Call">
                                <i class="fas fa-video" style="font-size: 1.2rem;"></i>
                            </button>
                            <form action="MessageServlet" method="POST" onsubmit="return confirm('Clear chat history for you? The other user will still see the conversation.');">
                                <input type="hidden" name="action" value="clearChat">
                                <input type="hidden" name="otherUserId" value="${chatUser.userId}">
                                <button type="submit" class="btn text-danger" style="background: none; border: none; cursor: pointer; padding: 8px;" title="Clear Chat">
                                    <i class="fas fa-trash-alt"></i>
                                </button>
                            </form>
                        </div>
                    </div>
                    
                    <div style="position: relative; flex: 1; display:flex; flex-direction:column; overflow:hidden;">
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

                                    <div class="message-row ${msg.senderId == sessionScope.user.userId ? 'sent' : 'received'}">
                                        <c:if test="${msg.senderId != sessionScope.user.userId}">
                                            <img src="${chatUser.profilePhoto != null && chatUser.profilePhoto.startsWith('http') ? chatUser.profilePhoto : pageContext.request.contextPath.concat('/').concat(chatUser.profilePhoto != null ? chatUser.profilePhoto : 'images/default-avatar.png')}" class="msg-avatar">
                                        </c:if>
                                        <div class="message-bubble ${msg.senderId == sessionScope.user.userId ? 'message-sent' : 'message-received'}" data-id="${msg.messageId}" style="margin-bottom: 0px; max-width: 80%; width: fit-content;">
                                            <div class="react-msg-btn" title="React" onclick="toggleEmojiPicker('${msg.messageId}', event)">
                                                <i class="far fa-smile"></i>
                                            </div>
                                            <div id="emoji-picker-${msg.messageId}" class="emoji-picker-popup">
                                                <span onclick="toggleMessageReaction('${msg.messageId}', '❤️', event)">❤️</span>
                                                <span onclick="toggleMessageReaction('${msg.messageId}', '🔥', event)">🔥</span>
                                                <span onclick="toggleMessageReaction('${msg.messageId}', '😂', event)">😂</span>
                                                <span onclick="toggleMessageReaction('${msg.messageId}', '😮', event)">😮</span>
                                                <span onclick="toggleMessageReaction('${msg.messageId}', '👏', event)">👏</span>
                                            </div>
                                            <c:if test="${msg.senderId == sessionScope.user.userId}">
                                                <form action="MessageServlet" method="POST" style="margin:0;">
                                                    <input type="hidden" name="action" value="deleteMessage">
                                                    <input type="hidden" name="messageId" value="${msg.messageId}">
                                                    <input type="hidden" name="withUserId" value="${chatUser.userId}">
                                                    <button type="submit" class="delete-msg-btn" title="Delete Message" onclick="return confirm('Delete this message?');">
                                                        <i class="fas fa-times"></i>
                                                    </button>
                                                </form>
                                            </c:if>
                                            ${msg.messageText}
                                            <div class="msg-time"><fmt:formatDate value="${msg.messageTime}" pattern="hh:mm a" /></div>
                                            <div id="msg-reactions-${msg.messageId}" class="msg-reactions"></div>
                                        </div>
                                    </div>
                                    <c:set var="lastMsgId" value="${msg.messageId}" />
                                </c:if>
                            </c:forEach>
                        </div>
                        <script>
                            document.querySelectorAll('.message-bubble').forEach(bubble => {
                                const id = bubble.getAttribute('data-id');
                                if (id) loadMessageReactions(id);
                            });
                        </script>
                    </div>
                    
                    <input type="hidden" id="lastMessageId" value="${lastMsgId != null ? lastMsgId : 0}">
                    <input type="hidden" id="currentChatUserId" value="${chatUser.userId}">
                    <input type="hidden" id="currentUserId" value="${sessionScope.user.userId}">
                    
                    <div class="chat-input-area">
                        <form action="MessageServlet" method="POST" class="chat-form">
                            <input type="hidden" name="receiverId" value="${chatUser.userId}">
                            <input type="text" name="messageText" class="form-input" placeholder="Type a message..." required autocomplete="off" style="flex: 1; border-radius: 2rem;">
                            <button type="submit" class="btn btn-primary" style="border-radius: 50%; width: 48px; height: 48px; padding: 0; display:flex; justify-content:center; align-items:center;">
                                <i class="fas fa-paper-plane"></i>
                            </button>
                        </form>
                    </div>
                    
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
</body>
</html>
