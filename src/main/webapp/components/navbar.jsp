<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<script>
    // Priority theme bootstrapper to prevent flicker
    (function() {
        const theme = localStorage.getItem('theme') || 'light';
        document.documentElement.setAttribute('data-theme', theme);
    })();
</script>
<nav class="navbar">
    <div class="nav-container">
        <div class="nav-left" style="flex: 1; display:flex; justify-content:flex-start;">
            <!-- Brand text removed as requested -->
        </div>
        
        <div class="nav-center" style="flex: 1.5; display: flex; justify-content: center;">
            <a href="${pageContext.request.contextPath}/search.jsp" class="nav-link" title="Search" style="background: var(--bg-light); border-radius: 50%; width: 40px; height: 40px; display: flex; align-items: center; justify-content: center;">
                <i class="fas fa-search"></i>
            </a>
        </div>
        
        <div class="nav-right" style="flex: 1; display:flex; justify-content:flex-end; align-items:center; gap: 2rem;">
            <a href="FeedServlet" class="nav-link" title="Home"><i class="fas fa-home fa-lg"></i></a>
            <a href="${pageContext.request.contextPath}/create_post.jsp" class="nav-link" title="Add Post"><i class="fas fa-plus fa-lg"></i></a>
            
            <!-- Heart Icon with Notification Dot -->
            <div class="nav-item-dropdown" style="position:relative;">
                <a href="javascript:void(0)" class="nav-link" title="Notifications" id="heart-notification-btn" onclick="toggleFriendRequestsDropdown()">
                    <i class="fas fa-heart fa-lg"></i>
                    <span id="heart-notif-dot" style="display:none; position:absolute; top:-2px; right:-2px; background:var(--danger-color, red); width:10px; height:10px; border-radius:50%; border:2px solid var(--bg-white, white); z-index:10;"></span>
                </a>
                
                <!-- Friend Requests Dropdown -->
                <div id="friend-requests-dropdown" class="card dropdown-panel" style="display:none; position:absolute; top:40px; right:0; width:320px; max-height:400px; overflow-y:auto; z-index:1000; padding:0; box-shadow:0 10px 25px rgba(0,0,0,0.15);">
                    <div style="padding:1rem; border-bottom:1px solid var(--border-color); font-weight:700;">Notifications</div>
                    <div id="dropdown-request-list">
                        <div style="padding:2rem; text-align:center; color:var(--text-muted);">Loading...</div>
                    </div>
                </div>
            </div>

            <a href="MessageServlet" class="nav-link" title="Messages" style="position:relative;">
                <i class="fab fa-facebook-messenger fa-lg"></i>
                <span id="msg-badge" style="display:none; position:absolute; top:-4px; right:-6px; background:var(--danger-color, red); width:10px; height:10px; border-radius:50%; border:2px solid var(--bg-white, white); z-index:10;"></span>
            </a>
            <a href="ProfileServlet" class="nav-link" title="Profile">
                <img src="${sessionScope.user.profilePhoto != null && sessionScope.user.profilePhoto.startsWith('http') ? sessionScope.user.profilePhoto : pageContext.request.contextPath.concat('/').concat(sessionScope.user.profilePhoto != null ? sessionScope.user.profilePhoto : 'images/default-avatar.png')}" alt="Profile" style="width: 28px; height: 28px; border-radius: 50%; object-fit: cover; border: 2px solid var(--border-color); cursor: pointer;">
            </a>
        </div>

    </div>
</nav>

<script>
    window.contextPath = '${pageContext.request.contextPath}';

    window.contextPath = '${pageContext.request.contextPath}';

    function checkPendingRequests() {
        const msgBadge = document.getElementById('msg-badge');
        const friendBadge = document.getElementById('friend-request-badge');
        if (!msgBadge && !friendBadge) return;
        
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
                const heartDot = document.getElementById('heart-notif-dot');
                if (heartDot) {
                    heartDot.style.display = data.unreadNotifications > 0 ? 'block' : 'none';
                }
            }
        })
        .catch(err => console.error(err));
    }

    function toggleFriendRequestsDropdown() {
        const dropdown = document.getElementById('friend-requests-dropdown');
        const list = document.getElementById('dropdown-request-list');
        
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
            if (data.length === 0) {
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
                checkPendingRequests(); // Update count dots
            }
        });
    }
    
    // Close dropdown when clicking outside
    document.addEventListener('click', function(e) {
        const dropdown = document.getElementById('friend-requests-dropdown');
        const btn = document.getElementById('heart-notification-btn');
        if (dropdown && !dropdown.contains(e.target) && !btn.contains(e.target)) {
            dropdown.style.display = 'none';
        }
    });
    
    // Check on load and poll every 15 seconds for real-time notifications
    document.addEventListener('DOMContentLoaded', function() {
        checkPendingRequests();
        setInterval(checkPendingRequests, 15000); // Poll every 15 seconds
    });
</script>

<!-- Share Post Modal (Global) -->
<div id="sharePostModal" class="modal" style="display:none; align-items:center; justify-content:center; background:rgba(0,0,0,0.5); z-index:2000;">
    <div class="modal-content card" style="max-width:400px; width:95%; padding:1.5rem; position:relative;">
        <span class="close" onclick="closeShareModal()" style="position:absolute; top:15px; right:15px; font-size:1.5rem; cursor:pointer;">&times;</span>
        <h3 style="margin-top:0; margin-bottom:1.25rem;">Share Post</h3>
        <div id="share-friends-list" style="max-height: 300px; overflow-y: auto;">
            <div style="padding:1rem; text-align:center; color:var(--text-muted);">Loading friends...</div>
        </div>
        <input type="hidden" id="share-post-id-input" value="">
    </div>
</div>
