<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.functions" prefix="fn" %>
<script>
    // Priority theme bootstrapper to prevent flicker
    (function() {
        const theme = localStorage.getItem('theme') || 'light';
        document.documentElement.setAttribute('data-theme', theme);
    })();
</script>
<style>
    .nav-link.active {
        color: var(--primary-color) !important;
        position: relative;
    }
    .nav-link.active::after {
        content: '';
        position: absolute;
        bottom: -5px;
        left: 50%;
        transform: translateX(-50%);
        width: 15px;
        height: 3px;
        background-color: var(--primary-color);
        border-radius: 3px;
    }
</style>
<nav class="navbar">
    <div class="nav-container" style="justify-content: center;">
        <c:set var="uri" value="${pageContext.request.requestURI}" />
        <div style="display: flex; align-items: center; justify-content: center; gap: 2rem;">
            <a href="FeedServlet" class="nav-link ${fn:contains(uri, 'FeedServlet') ? 'active' : ''}" title="Home"><i class="fas fa-home fa-lg"></i></a>
            <a href="${pageContext.request.contextPath}/search.jsp" class="nav-link ${fn:contains(uri, 'search.jsp') ? 'active' : ''}" title="Search"><i class="fas fa-search fa-lg"></i></a>
            <a href="${pageContext.request.contextPath}/create_post.jsp" class="nav-link ${fn:contains(uri, 'create_post.jsp') ? 'active' : ''}" title="Add Post"><i class="fas fa-plus fa-lg"></i></a>
            <div class="nav-item-dropdown" style="position:relative;" id="notif-nav-wrapper">
                <a href="javascript:void(0)" class="nav-link ${fn:contains(uri, 'NotificationServlet') || fn:contains(uri, 'notifications.jsp') ? 'active' : ''}" title="Notifications" id="heart-notification-btn" onclick="toggleFriendRequestsDropdown()">
                    <i class="fas fa-heart fa-lg"></i>
                    <span id="heart-notif-dot" style="display:none; position:absolute; top:-2px; right:-2px; background:var(--danger-color, red); width:10px; height:10px; border-radius:50%; border:2px solid var(--bg-white, white); z-index:10;"></span>
                </a>
                <div id="friend-requests-dropdown" class="card dropdown-panel" style="display:none; position:absolute; top:40px; right:-80px; width:320px; max-height:400px; overflow-y:auto; z-index:1000; padding:0; box-shadow:0 10px 25px rgba(0,0,0,0.15);">
                    <div style="padding:1rem; border-bottom:1px solid var(--border-color); font-weight:700;">Notifications</div>
                    <div id="dropdown-request-list">
                        <div style="padding:2rem; text-align:center; color:var(--text-muted);">Loading...</div>
                    </div>
                </div>
            </div>
            <a href="MessageServlet" class="nav-link ${fn:contains(uri, 'MessageServlet') || fn:contains(uri, 'messages.jsp') ? 'active' : ''}" title="Messages" style="position:relative;">
                <i class="fab fa-facebook-messenger fa-lg"></i>
                <span id="msg-badge" style="display:none; position:absolute; top:-4px; right:-6px; background:var(--danger-color, red); width:10px; height:10px; border-radius:50%; border:2px solid var(--bg-white, white); z-index:10;"></span>
            </a>
            <a href="ProfileServlet" class="nav-link ${fn:contains(uri, 'ProfileServlet') || fn:contains(uri, 'profile.jsp') ? 'active' : ''}" title="Profile">
                <img src="${sessionScope.user.profilePhoto != null && sessionScope.user.profilePhoto.startsWith('http') ? sessionScope.user.profilePhoto : pageContext.request.contextPath.concat('/').concat(sessionScope.user.profilePhoto != null ? sessionScope.user.profilePhoto : 'images/default-avatar.png')}" alt="Profile" style="width: 28px; height: 28px; border-radius: 50%; object-fit: cover; border: 2px solid var(--border-color); cursor: pointer;">
            </a>
        </div>
    </div>
</nav>

<script>
    window.contextPath = '${pageContext.request.contextPath}';
    window.currentUserId = '${sessionScope.user.userId}';

    function checkPendingRequests() {
        const msgBadge = document.getElementById('msg-badge');
        const heartDot = document.getElementById('heart-notif-dot');
        
        fetch('${pageContext.request.contextPath}/InteractionServlet', {
            method: 'POST',
            headers: {'Content-Type': 'application/x-www-form-urlencoded'},
            body: 'action=checkPendingRequests'
        })
        .then(res => res.json())
        .then(data => {
            if (data) {
                if (msgBadge) {
                    msgBadge.style.display = data.unreadMessages > 0 ? 'block' : 'none';
                }
                if (heartDot) {
                    heartDot.style.display = data.unreadNotifications > 0 ? 'block' : 'none';
                }
            }
        })
        .catch(err => console.error('Error checking requests:', err));
    }

    function toggleFriendRequestsDropdown() {
        const dropdown = document.getElementById('friend-requests-dropdown');
        if (dropdown.style.display === 'none') {
            dropdown.style.display = 'block';
            fetchRequests();
        } else {
            dropdown.style.display = 'none';
        }
    }

    function fetchRequests() {
        const list = document.getElementById('dropdown-request-list');
        fetch('${pageContext.request.contextPath}/InteractionServlet', {
            method: 'POST',
            headers: {'Content-Type': 'application/x-www-form-urlencoded'},
            body: 'action=getNotifications'
        })
        .then(res => res.json())
        .then(data => {
            if (!data || data.length === 0) {
                list.innerHTML = '<div style="padding:2rem; text-align:center; color:var(--text-muted);">No new notifications</div>';
            } else {
                let html = '';
                data.forEach(function(notif) {
                    var ctx = '${pageContext.request.contextPath}';
                    var photo = notif.actorPhoto ? notif.actorPhoto : 'images/default-avatar.png';
                    var fullPhoto = (photo.startsWith('http') || photo.startsWith('data:')) ? photo : (ctx + '/' + photo);
                    
                    let message = '';
                    let actionBtn = '';
                    if (notif.type === 'FRIEND_REQUEST') {
                        message = 'sent you a friend request.';
                        actionBtn = '<div style="margin-top:0.5rem; display:flex; gap:0.5rem;">' +
                                    '<button class="btn btn-primary" style="padding:2px 10px; font-size:0.8rem;" onclick="handleRequest(' + notif.actorId + ', \'accept\', this)">Accept</button>' +
                                    '<button class="btn btn-outline" style="padding:2px 10px; font-size:0.8rem;" onclick="handleRequest(' + notif.actorId + ', \'reject\', this)">Decline</button>' +
                                    '</div>';
                    } else if (notif.type === 'FOLLOW') {
                        message = 'started following you.';
                    } else if (notif.type === 'LIKE') {
                        message = 'liked your post.';
                    } else if (notif.type === 'COMMENT') {
                        message = 'commented on your post.';
                    } else if (notif.type === 'SHARE') {
                        message = 'shared a post with you.';
                    }

                    html += '<div style="padding:1rem; border-bottom:1px solid var(--border-color); display:flex; align-items:center; gap:0.75rem; background: ' + (notif.isRead ? 'transparent' : 'rgba(255,107,129,0.05)') + ';">' +
                        '<img src="' + fullPhoto + '" style="width:40px; height:40px; border-radius:50%; object-fit:cover; flex-shrink:0;">' +
                        '<div style="flex:1;">' +
                            '<div style="font-size:0.9rem;"><strong>' + notif.actorName + '</strong> ' + message + '</div>' +
                            actionBtn +
                        '</div>' +
                    '</div>';
                });
                list.innerHTML = html;
                
                // Mark as read after opening dropdown
                fetch('${pageContext.request.contextPath}/InteractionServlet', {
                    method: 'POST',
                    headers: {'Content-Type': 'application/x-www-form-urlencoded'},
                    body: 'action=markNotificationsRead'
                }).then(() => checkPendingRequests());
            }
        });
    }

    function handleRequest(userId, action, btn) {
        const container = btn.closest('div').parentElement.parentElement;
        fetch('${pageContext.request.contextPath}/FriendServlet', {
            method: 'POST',
            headers: {'Content-Type': 'application/x-www-form-urlencoded'},
            body: 'action=' + action + '&friendId=' + userId
        })
        .then(res => {
            if (res.ok) {
                container.style.opacity = '0.5';
                container.innerHTML = `<div style="padding:1rem; text-align:center; color:var(--text-muted); width:100%;">Request ${action}ed</div>`;
                checkPendingRequests();
            }
        });
    }
    
    document.addEventListener('click', function(e) {
        const dropdown = document.getElementById('friend-requests-dropdown');
        const btn = document.getElementById('heart-notification-btn');
        if (dropdown && !dropdown.contains(e.target) && !btn.contains(e.target)) {
            dropdown.style.display = 'none';
        }
    });
    
    document.addEventListener('DOMContentLoaded', function() {
        checkPendingRequests();
        setInterval(checkPendingRequests, 15000);
    });
</script>

<!-- Share Post Modal (Global) - Handled by app_v2.js -->
<div id="sharePostModal" class="modal" style="display:none; align-items:center; justify-content:center; background:rgba(0,0,0,0.5); z-index:2000;">
    <div class="modal-content card" style="max-width:520px; width:95%; padding:0; position:relative; overflow:hidden; border-radius:16px;">
        <div style="padding:1.25rem 1.5rem; border-bottom:1px solid var(--border-color); display:flex; justify-content:space-between; align-items:center;">
            <h3 style="margin:0; font-size:1.1rem; font-weight:700;">Send Post To...</h3>
            <button onclick="closeShareModal()" style="background:var(--bg-light); border:none; border-radius:50%; width:32px; height:32px; cursor:pointer; font-size:1.1rem; display:flex; align-items:center; justify-content:center;">&times;</button>
        </div>
        <div style="padding: 1rem 1.5rem; border-bottom: 1px solid var(--border-color); background: var(--bg-light);">
            <div style="position:relative;">
                <i class="fas fa-search" style="position:absolute; left:12px; top:50%; transform:translateY(-50%); color:var(--text-muted); font-size:0.9rem;"></i>
                <input type="text" id="share-search-input" placeholder="Search followers..." oninput="filterShareList()" style="width:100%; padding:0.6rem 1rem 0.6rem 2.25rem; border:1px solid var(--border-color); border-radius:20px; font-size:0.9rem; background:var(--bg-white); font-family:inherit; outline:none; transition:border-color 0.2s;" onfocus="this.style.borderColor='var(--primary-color)'" onblur="this.style.borderColor='var(--border-color)'">
            </div>
        </div>
        <div id="share-friends-list" style="padding:0; max-height:360px; overflow-y:auto;">
            <!-- Content dynamically generated by app_v2.js -->
        </div>
        <input type="hidden" id="share-post-id-input" value="">
    </div>
</div>