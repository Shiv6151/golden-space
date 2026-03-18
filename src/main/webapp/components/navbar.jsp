<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<script>
    // Priority theme bootstrapper to prevent flicker
    (function() {
        const theme = localStorage.getItem('theme') || 'light';
        document.documentElement.setAttribute('data-theme', theme);
    })();
</script>
<nav class="navbar">
    <div class="nav-container" style="display:flex; justify-content:space-between; align-items:center; max-width: 1200px; margin: 0 auto; width: 100%;">
        <div style="flex: 1; display:flex; justify-content:flex-start;">
            <a href="FeedServlet" class="nav-brand" style="text-decoration: none; font-size: 1.5rem; font-weight: 800; color: var(--primary-color); letter-spacing: -1px;">GoldenSpace</a>
        </div>
        
        <div class="nav-center" style="flex: 1.5; display: flex; justify-content: center;">
            <form action="${pageContext.request.contextPath}/SearchServlet" method="GET" class="premium-search-bar" id="searchForm">
                <i class="fas fa-search search-icon"></i>
                <input type="text" name="query" id="searchInput" placeholder="Search friends or posts..." required>
            </form>
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

        <div style="flex: 1; display:flex; justify-content:flex-end; align-items:center;">
            <!-- Placeholder to balance the flexbox layout -->
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
                    heartDot.style.display = data.friendRequests > 0 ? 'block' : 'none';
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
            body: 'action=getPendingFriendRequests'
        })
        .then(res => res.json())
        .then(data => {
            if (data.length === 0) {
                list.innerHTML = '<div style="padding:2rem; text-align:center; color:var(--text-muted);">No new notifications</div>';
            } else {
                let html = '';
                data.forEach(function(req) {
                    var ctx = '${pageContext.request.contextPath}';
                    var photo = req.photo ? req.photo : 'images/default-avatar.png';
                    var fullPhoto = (photo.startsWith('http') || photo.startsWith('data:')) ? photo : (ctx + '/' + photo);
                    html += '<div style="padding:1rem; border-bottom:1px solid var(--border-color); display:flex; align-items:center; gap:0.75rem;">' +
                        '<img src="' + fullPhoto + '" style="width:40px; height:40px; border-radius:50%; object-fit:cover; flex-shrink:0;">' +
                        '<div style="flex:1;">' +
                            '<div style="font-size:0.9rem;"><strong>' + req.name + '</strong> sent you a follow request.</div>' +
                            '<div style="margin-top:0.5rem; display:flex; gap:0.5rem;">' +
                                '<button class="btn btn-primary" style="padding:2px 10px; font-size:0.8rem;" onclick="handleRequest(' + req.senderId + ', \'accept\', this)">Accept</button>' +
                                '<button class="btn btn-outline" style="padding:2px 10px; font-size:0.8rem;" onclick="handleRequest(' + req.senderId + ', \'reject\', this)">Decline</button>' +
                            '</div>' +
                        '</div>' +
                    '</div>';
                });
                list.innerHTML = html;
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
