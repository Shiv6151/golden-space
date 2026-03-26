<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.fmt" prefix="fmt" %>

<div class="card post-card" style="padding: 0.75rem;">
    <div class="post-header" style="display:flex; justify-content:space-between; align-items:flex-start; margin-bottom: 0.5rem;">
        <div style="display:flex; gap:1rem; align-items:center;">
            <c:choose>
                <c:when test="${not empty post.userPhoto}">
                    <img src="${post.userPhoto != null && post.userPhoto.startsWith('http') ? post.userPhoto : pageContext.request.contextPath.concat('/').concat(post.userPhoto != null ? post.userPhoto : 'images/default-avatar.png')}" alt="${post.userName}" class="post-avatar">
                </c:when>
                <c:otherwise>
                    <img src="${pageContext.request.contextPath}/images/default-avatar.png" alt="${post.userName}" class="post-avatar">
                </c:otherwise>
            </c:choose>
            <div>
                <a href="ProfileServlet?id=${post.userId}" class="post-author" style="text-decoration:none; font-weight:700;">@${post.userHandle}</a>
                <c:if test="${post.pinned}">
                    <span class="pinned-badge" style="margin-left:0.5rem; color:var(--primary-color); font-size:0.75rem; background:rgba(255, 71, 87, 0.1); padding:2px 6px; border-radius:10px;">
                        <i class="fas fa-thumbtack" style="transform: rotate(45deg);"></i> Pinned
                    </span>
                </c:if>
                <div class="post-time"><fmt:formatDate value="${post.postDate}" pattern="MMM d, hh:mm a" /></div>
            </div>
        </div>
        
        <div class="post-options" style="display:flex; align-items:center;">
            <c:if test="${post.pinned}">
                <i class="fas fa-thumbtack" style="color:var(--primary-color); transform: rotate(45deg); margin-right: 0.5rem;" title="Pinned Post"></i>
            </c:if>
            <div class="dropdown" style="position:relative;">
                <button class="action-btn text-muted" onclick="togglePostMenu('${post.postId}', event)" style="border:none;background:none; cursor:pointer; padding: 0.5rem;">
                    <i class="fas fa-ellipsis-h" style="font-size: 1.2rem;"></i>
                </button>
                <div id="postMenu-${post.postId}" class="dropdown-content post-dropdown-menu">
                    <c:choose>
                        <c:when test="${sessionScope.user.userId == post.userId}">
                            <button class="dropdown-item" onclick="showEditPost('${post.postId}'); togglePostMenu('${post.postId}');">
                                <i class="fas fa-edit"></i> Edit Post
                            </button>
                            <button class="dropdown-item" onclick="togglePin('${post.postId}'); togglePostMenu('${post.postId}');">
                                <i class="fas fa-thumbtack"></i> ${post.pinned ? 'Unpin from Top' : 'Pin to Top'}
                            </button>
                            <div class="dropdown-divider"></div>
                            <form action="DeletePostServlet" method="POST" onsubmit="return confirm('Are you sure you want to delete this post?');" style="margin:0; width: 100%;">
                                <input type="hidden" name="postId" value="${post.postId}">
                                <button type="submit" class="dropdown-item text-danger" style="width: 100%; text-align: left; background: none; border: none; font-family: inherit;">
                                    <i class="fas fa-trash"></i> Delete Post
                                </button>
                            </form>
                        </c:when>
                        <c:otherwise>
                            <button class="dropdown-item" onclick="alert('Post Reported!'); togglePostMenu(${post.postId});">
                                <i class="fas fa-flag"></i> Report
                            </button>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>
        </div>
    </div>
    
    <c:choose>
        <c:when test="${not empty post.images}">
            <div class="post-carousel-container" style="position:relative; width:100%; border-radius:8px; overflow:hidden; background:#fafafa; margin-bottom: 0;">
                <div class="post-carousel" id="carousel-${post.postId}" 
                     style="display:flex; overflow-x:auto; scroll-snap-type:x mandatory; scrollbar-width:none; -ms-overflow-style:none; aspect-ratio: ${not empty post.aspectRatio ? post.aspectRatio : '16/9'}; cursor:pointer;"
                     ondblclick="toggleLike('${post.postId}', true)"
                     onscroll="updateCarouselDots('${post.postId}')">
                    
                    <c:forEach var="img" items="${post.images}" varStatus="status">
                        <div class="carousel-item" style="flex:0 0 100%; scroll-snap-align:start; position:relative;">
                            <img src="${img.startsWith('http') ? img : (pageContext.request.contextPath.concat('/').concat(img))}" alt="Post image ${status.index + 1}" 
                                 style="width:100%; height:100%; object-fit:cover; display:block;"
                                 onerror="this.onerror=null; this.src='${pageContext.request.contextPath}/images/placeholder.png';">
                        </div>
                    </c:forEach>
                </div>

                <!-- Carousel Dots -->
                <c:if test="${post.images.size() > 1}">
                    <div class="carousel-dots" id="dots-${post.postId}" style="position:absolute; bottom:15px; left:50%; transform:translateX(-50%); display:flex; gap:6px; z-index:10; background:rgba(0,0,0,0.3); padding:5px 8px; border-radius:20px; backdrop-filter:blur(4px);">
                        <c:forEach var="img" items="${post.images}" varStatus="status">
                            <div class="dot ${status.first ? 'active' : ''}" 
                                 onclick="scrollToImage('${post.postId}', '${status.index}')"
                                 style="width:6px; height:6px; border-radius:50%; background:rgba(255,255,255,${status.first ? '1' : '0.5'}); cursor:pointer; transition:all 0.3s;"></div>
                        </c:forEach>
                    </div>

                    <!-- Navigation Arrows -->
                    <button onclick="prevImage('${post.postId}')" style="position:absolute; left:10px; top:50%; transform:translateY(-50%); background:rgba(255,255,255,0.7); border:none; border-radius:50%; width:30px; height:30px; cursor:pointer; display:flex; align-items:center; justify-content:center; color:var(--primary-color); z-index:10; opacity:0.8;">
                        <i class="fas fa-chevron-left"></i>
                    </button>
                    <button onclick="nextImage('${post.postId}')" style="position:absolute; right:10px; top:50%; transform:translateY(-50%); background:rgba(255,255,255,0.7); border:none; border-radius:50%; width:30px; height:30px; cursor:pointer; display:flex; align-items:center; justify-content:center; color:var(--primary-color); z-index:10; opacity:0.8;">
                        <i class="fas fa-chevron-right"></i>
                    </button>
                </c:if>

                <!-- Heart Animation Overlay -->
                <div id="heart-animation-${post.postId}" style="position:absolute; top:50%; left:50%; transform:translate(-50%, -50%) scale(0); color:#fff; font-size:5rem; opacity:0; pointer-events:none; transition: all 0.4s cubic-bezier(0.175, 0.885, 0.32, 1.275); z-index:15;">
                    <i class="fas fa-heart"></i>
                </div>
            </div>
        </c:when>
        <c:when test="${not empty post.image}">
            <div class="post-carousel-container" style="position:relative; width:100%; border-radius:8px; overflow:hidden; background:#fafafa; margin-bottom: 0;">
                <img src="${post.image.startsWith('http') ? post.image : (pageContext.request.contextPath.concat('/').concat(post.image))}" alt="Post image" 
                     style="width:100%; aspect-ratio: ${not empty post.aspectRatio ? post.aspectRatio : '16/9'}; object-fit:cover; display:block;"
                     onerror="this.onerror=null; this.src='${pageContext.request.contextPath}/images/placeholder.png';">
            </div>
        </c:when>
    </c:choose>

    <div class="post-content" id="post-content-${post.postId}" style="margin: 0 0 0.5rem 0; font-size: 0.95rem; line-height: 1.4; font-family: 'Inter', system-ui, -apple-system, sans-serif;">
        <p class="post-text" style="color: #2d3436; margin: 0; white-space: pre-wrap; word-break: break-word;">${post.postContent}</p>
    </div>

    <!-- Hidden Edit Form -->
    <div id="edit-post-${post.postId}" style="display:none; margin: 1rem 0; background: var(--bg-light); padding: 1rem; border-radius: 12px; border: 1px solid var(--border-color);">
        <form onsubmit="handleEditPostSubmit(event, ${post.postId})" id="edit-form-${post.postId}">
            <input type="hidden" name="postId" value="${post.postId}">
            
            <div class="form-group mb-3">
                <label style="font-weight:600; font-size: 0.85rem; display:block; margin-bottom:0.5rem;">Aspect Ratio</label>
                <div style="display:flex; gap:0.5rem;">
                    <label class="ratio-btn">
                        <input type="radio" name="editAspectRatio-${post.postId}" value="1/1" ${post.aspectRatio == '1/1' ? 'checked' : ''} style="display:none;" onchange="updateEditPreviews(${post.postId})">
                        <div class="ratio-box-sm ${post.aspectRatio == '1/1' ? 'active' : ''}">1:1</div>
                    </label>
                    <label class="ratio-btn">
                        <input type="radio" name="editAspectRatio-${post.postId}" value="16/9" ${post.aspectRatio == '16/9' ? 'checked' : ''} style="display:none;" onchange="updateEditPreviews(${post.postId})">
                        <div class="ratio-box-sm ${post.aspectRatio == '16/9' ? 'active' : ''}">16:9</div>
                    </label>
                </div>
            </div>

            <div class="form-group mb-3">
                <label style="font-weight:600; font-size: 0.85rem; display:block; margin-bottom:0.5rem;">Content</label>
                <textarea name="content" class="form-input" style="width:100%; min-height:80px; margin-bottom:0.5rem; font-family:inherit; font-size: 0.9rem;">${post.postContent}</textarea>
            </div>

            <div class="edit-previews-container" id="edit-previews-${post.postId}" style="display:grid; grid-template-columns: repeat(auto-fill, minmax(80px, 1fr)); gap: 0.5rem; margin-bottom: 1rem;">
                <c:forEach var="img" items="${post.images}" varStatus="status">
                    <div class="edit-preview-item" style="aspect-ratio: ${post.aspectRatio}; position:relative; overflow:hidden; border-radius:4px; background:#000; cursor:pointer;" onclick="openEditCropModal(${post.postId}, ${status.index})">
                        <img src="${img.startsWith('http') ? img : (pageContext.request.contextPath.concat('/').concat(img))}" style="width:100%; height:100%; object-fit:cover;" data-original="${img}">
                        <div class="adjust-overlay" style="position:absolute; top:0; left:0; width:100%; height:100%; background:rgba(0,0,0,0.4); display:flex; align-items:center; justify-content:center; color:white; font-size:0.7rem; font-weight:700;">
                            ADJUST
                        </div>
                    </div>
                </c:forEach>
            </div>

            <div style="display:flex; gap:0.5rem;">
                <button type="submit" class="btn btn-primary btn-sm" style="flex:1;">Save Changes</button>
                <button type="button" class="btn btn-outline btn-sm" onclick="cancelEditPost(${post.postId})">Cancel</button>
            </div>
        </form>
    </div>

    <style>
        .ratio-box-sm {
            padding: 4px 10px;
            border: 1px solid var(--border-color);
            border-radius: 4px;
            font-size: 0.75rem;
            cursor: pointer;
            background: var(--bg-white);
        }
        .ratio-box-sm.active {
            border-color: var(--primary-color);
            background: rgba(255, 71, 87, 0.1);
            color: var(--primary-color);
            font-weight: 700;
        }
        .edit-preview-item:hover .adjust-overlay {
            opacity: 1;
        }
        .adjust-overlay {
            opacity: 0;
            transition: opacity 0.2s;
        }
    </style>
    
    <div class="post-stats" style="display:flex; justify-content:space-between; margin-bottom:0.5rem;">
        <span style="position:relative; cursor:pointer;" onclick="toggleLikers('${post.postId}')">
            <i class="fas fa-heart" style="color: #ff4757;"></i> <span id="like-count-${post.postId}">${post.likeCount}</span> Likes
            <button onclick="event.stopPropagation(); toggleLikers('${post.postId}')" style="border:none;background:none;font-size:0.8rem;color:var(--text-muted);cursor:pointer;" title="See who liked"><i class="fas fa-chevron-down" id="likers-chevron-${post.postId}"></i></button>
            <div id="likers-dropdown-${post.postId}" style="display:none; position:absolute; top:25px; left:0; background:white; border-radius:8px; box-shadow:0 4px 12px rgba(0,0,0,0.15); padding:1rem; z-index:10; width:200px; max-height:200px; overflow-y:auto;">
                <div class="text-center text-muted"><i class="fas fa-spinner fa-spin"></i> Loading...</div>
            </div>
        </span>
        <span style="cursor:pointer;" onclick="toggleComments('${post.postId}')">${post.commentCount} Comments <i class="fas fa-chevron-down"></i></span>
    </div>

    <!-- Action Buttons: Like | Comment | Share — all in one row -->
    <div style="display:flex; align-items:center; border-top:1px solid var(--border-color); padding-top:0.5rem;">
        <button id="like-btn-${post.postId}" type="button" class="action-btn text-muted" onclick="toggleLike('${post.postId}', false)" style="flex:1; text-align:center; display:flex; align-items:center; justify-content:center; gap:0.4rem;" title="Like this post">
            <i id="like-icon-${post.postId}" class="fa${post.likedByCurrentUser ? 's' : 'r'} fa-heart" style="color:${post.likedByCurrentUser ? '#ff4757' : 'inherit'};"></i> Like
        </button>
        <button type="button" class="action-btn text-muted" onclick="toggleComments('${post.postId}')" style="flex:1; text-align:center; display:flex; align-items:center; justify-content:center; gap:0.4rem;" title="Comment on this post">
            <i class="fas fa-comment"></i> Comment
        </button>
        <button type="button" class="action-btn text-muted" onclick="openShareModal('${post.postId}')" style="flex:1; text-align:center; display:flex; align-items:center; justify-content:center; gap:0.4rem;" title="Share this post">
            <i class="far fa-paper-plane"></i> Share
        </button>
    </div>
    
    <!-- Comments Section (Hidden by default) -->
    <div class="comments-section" id="comments-${post.postId}" style="display: none; background: #f8f9fa; border-radius: 8px; padding: 1rem; margin-top: 1rem;">
        
        <form action="InteractionServlet" method="POST" class="comment-form" style="margin-bottom: 1rem;">
            <input type="hidden" name="action" value="comment">
            <input type="hidden" name="postId" value="${post.postId}">
            <c:choose>
                <c:when test="${not empty sessionScope.user.profilePhoto}">
                    <img src="${sessionScope.user.profilePhoto != null && sessionScope.user.profilePhoto.startsWith('http') ? sessionScope.user.profilePhoto : pageContext.request.contextPath.concat('/').concat(sessionScope.user.profilePhoto != null ? sessionScope.user.profilePhoto : 'images/default-avatar.png')}" class="comment-avatar">
                </c:when>
                <c:otherwise>
                    <img src="${pageContext.request.contextPath}/images/default-avatar.png" class="comment-avatar">
                </c:otherwise>
            </c:choose>
            <input type="text" name="commentText" id="comment-input-${post.postId}" class="form-input" placeholder="Write a comment..." required>
            <button type="submit" class="btn btn-primary"><i class="fas fa-paper-plane"></i></button>
        </form>

        <hr style="margin: 0.5rem 0 1rem 0;">

        <!-- Render Comments if they exist -->
        <div id="comment-list-${post.postId}" style="max-height: 250px; overflow-y: auto;">
            <c:choose>
                <c:when test="${not empty post.comments}">
                    <c:forEach var="comment" items="${post.comments}">
                        <div style="display:flex; gap:0.5rem; margin-bottom:0.75rem; background:white; padding:0.5rem; border-radius:8px; border:1px solid #eee;">
                            <c:choose>
                                <c:when test="${not empty comment.userPhoto}">
                                    <img src="${comment.userPhoto != null && comment.userPhoto.startsWith('http') ? comment.userPhoto : pageContext.request.contextPath.concat('/').concat(comment.userPhoto != null ? comment.userPhoto : 'images/default-avatar.png')}" alt="${comment.userName}" style="width:30px; height:30px; border-radius:50%; object-fit:cover;">
                                </c:when>
                                <c:otherwise>
                                    <img src="${pageContext.request.contextPath}/images/default-avatar.png" alt="${comment.userName}" style="width:30px; height:30px; border-radius:50%; object-fit:cover;">
                                </c:otherwise>
                            </c:choose>
                            <div style="flex:1;">
                                <div style="display:flex; justify-content:space-between; align-items:center;">
                                    <div style="font-weight:600; font-size:0.9rem;">
                                        <a href="ProfileServlet?id=${comment.userId}" style="color:inherit; text-decoration:none;">${comment.userName}</a>
                                        <span style="font-weight:400; color:var(--text-muted); font-size:0.75rem; margin-left:0.5rem;"><fmt:formatDate value="${comment.commentDate}" pattern="MMM d, hh:mm a" /></span>
                                    </div>
                                    <c:if test="${sessionScope.user.userId == comment.userId || sessionScope.user.userId == post.userId}">
                                        <button onclick="deleteComment('${comment.commentId}', '${post.postId}')" 
                                                style="border:none; background:none; color:var(--text-muted); cursor:pointer; font-size:0.8rem;"
                                                title="Delete Comment">
                                            <i class="fas fa-trash-alt"></i>
                                        </button>
                                    </c:if>
                                </div>
                                <div style="font-size:0.95rem; margin-top:0.2rem; color:var(--text-color);">${comment.commentText}</div>
                            </div>
                        </div>
                    </c:forEach>
                </c:when>
                <c:otherwise>
                    <div class="text-center text-muted" style="padding:1rem;">No comments yet. Be the first to reply!</div>
                </c:otherwise>
            </c:choose>
        </div>
    </div>
</div>
