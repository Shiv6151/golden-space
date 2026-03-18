// Core Application JavaScript

function getImageUrl(path) {
    if (!path) return (window.contextPath || '') + '/images/placeholder.png';
    if (path.startsWith('http') || path.startsWith('data:') || path.startsWith('blob:')) return path;
    // Special case for default avatar
    if (path === 'images/default-avatar.png') return (window.contextPath || '') + '/images/default-avatar.png';
    return (window.contextPath || '') + '/' + path;
}

// ----------------------------------------------------
// Share Post Functionality
// ----------------------------------------------------
function openShareModal(postId) {
    document.getElementById('share-post-id-input').value = postId;
    document.getElementById('sharePostModal').style.display = 'flex';
    document.getElementById('share-friends-list').innerHTML = '<div style="padding:1rem; text-align:center; color:var(--text-muted);">Loading friends...</div>';
    
    fetch((window.contextPath || '') + '/InteractionServlet', {
        method: 'POST',
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: 'action=getAcceptedFriends'
    })
    .then(res => res.json())
    .then(friends => {
        let html = '';
        if (friends.length === 0) {
            html = '<div style="padding:1rem; text-align:center; color:var(--text-muted);">No friends available to share with.</div>';
        } else {
            friends.forEach(f => {
                const photo = getImageUrl(f.photo);
                html += `
                    <div style="display:flex; align-items:center; justify-content:space-between; padding:0.75rem 1rem; border-bottom:1px solid var(--border-color);">
                        <div style="display:flex; align-items:center; gap:0.75rem;">
                            <img src="\${photo}" style="width:40px; height:40px; border-radius:50%; object-fit:cover;">
                            <span style="font-weight:600;">\${f.name}</span>
                        </div>
                        <button class="btn btn-primary btn-sm" onclick="sendPostShare(\${f.id}, this)">Send</button>
                    </div>
                `;
            });
        }
        document.getElementById('share-friends-list').innerHTML = html;
    }).catch(err => {
        document.getElementById('share-friends-list').innerHTML = '<div style="padding:1rem; text-align:center; color:var(--danger-color);">Error loading friends</div>';
    });
}

function closeShareModal() {
    document.getElementById('sharePostModal').style.display = 'none';
}

function sendPostShare(friendId, btn) {
    const postId = document.getElementById('share-post-id-input').value;
    btn.disabled = true;
    btn.innerHTML = '<i class="fas fa-spinner fa-spin"></i>';
    
    const formData = new URLSearchParams();
    formData.append('receiverId', friendId);
    formData.append('messageText', '[POST_SHARE:' + postId + ']');
    formData.append('ajax', 'true');
    
    fetch((window.contextPath || '') + '/MessageServlet', {
        method: 'POST',
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: formData.toString()
    })
    .then(res => {
        if (res.ok) {
            btn.innerText = 'Sent';
            btn.classList.add('btn-success');
            btn.classList.remove('btn-primary');
            btn.style.background = '#2ecc71';
            btn.style.color = 'white';
            btn.style.border = 'none';
        } else {
            btn.innerText = 'Error';
            btn.disabled = false;
        }
    })
    .catch(() => {
        btn.innerText = 'Send';
        btn.disabled = false;
    });
}

function toggleLike(postId, showAnimation = false) {
    const btn = document.getElementById('like-btn-' + postId);
    const icon = document.getElementById('like-icon-' + postId);
    const countSpan = document.getElementById('like-count-' + postId);
    
    // Optimistic UI update
    const isLiked = icon.style.color === 'rgb(255, 71, 87)' || icon.style.color === '#ff4757';
    let currentCount = parseInt(countSpan.innerText);
    
    if (isLiked && !showAnimation) {
        // Only unlike if it's already liked AND not a double-click
        icon.style.color = 'inherit';
        countSpan.innerText = Math.max(0, currentCount - 1);
    } else if (!isLiked) {
        icon.style.color = '#ff4757';
        countSpan.innerText = currentCount + 1;
    }

    if (showAnimation) {
        const heart = document.getElementById('heart-animation-' + postId);
        if (heart) {
            heart.style.transform = 'translate(-50%, -50%) scale(1.2)';
            heart.style.opacity = '0.9';
            setTimeout(() => {
                heart.style.transform = 'translate(-50%, -50%) scale(0)';
                heart.style.opacity = '0';
            }, 800);
        }
    }
    
    // If double-click on already liked post, just show animation and don't toggle
    if (isLiked && showAnimation) return;

    // AJAX call to server
    fetch((window.contextPath || '') + '/InteractionServlet', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: 'action=like&postId=' + postId
    })
    .then(response => {
        if (!response.ok) {
            // Revert changes if failed
            console.error('Like action failed');
            if (isLiked && !showAnimation) {
                icon.style.color = '#ff4757';
                countSpan.innerText = currentCount;
            } else if (!isLiked) {
                icon.style.color = 'inherit';
                countSpan.innerText = currentCount;
            }
        }
    })
    .catch(err => {
        console.error(err);
        // Revert on network error
        if (isLiked && !showAnimation) {
            icon.style.color = '#ff4757';
            countSpan.innerText = currentCount;
        } else if (!isLiked) {
            icon.style.color = 'inherit';
            countSpan.innerText = currentCount;
        }
    });
}

function toggleComments(postId) {
    const commentsSection = document.getElementById('comments-' + postId);
    if (commentsSection.style.display === 'none') {
        commentsSection.style.display = 'block';
        const input = document.getElementById('comment-input-' + postId);
        if (input) input.focus();
    } else {
        commentsSection.style.display = 'none';
    }
}

function togglePostMenu(postId) {
    const menu = document.getElementById('postMenu-' + postId);
    menu.style.display = menu.style.display === 'none' ? 'block' : 'none';
}

function showEditPost(postId) {
    const modal = document.getElementById('postDetailModal');
    if (modal && modal.style.display === 'flex') {
        const post = window.currentModalPost;
        if (!post) return;

        // Populate text
        document.getElementById('modal-caption-view').style.display = 'none';
        document.getElementById('modal-edit-view').style.display = 'block';
        document.getElementById('modal-edit-input').value = post.postContent;

        // Populate aspect ratio
        const ratio = post.aspectRatio || "16/9";
        const radio = document.querySelector(`input[name="modalEditAspectRatio"][value="${ratio}"]`);
        if (radio) radio.checked = true;

        // Populate previews
        const previewContainer = document.getElementById('modal-edit-previews');
        previewContainer.innerHTML = '';
        
        if (post.images) {
            post.images.forEach((img, index) => {
                const div = document.createElement('div');
                div.className = 'edit-preview-item';
                div.style.aspectRatio = ratio;
                div.style.position = 'relative';
                div.style.borderRadius = '4px';
                div.style.overflow = 'hidden';
                div.style.background = '#000';
                div.style.cursor = 'pointer';

                div.innerHTML = `
                    <img src="${getImageUrl(img)}" data-original="${img}" style="width:100%; height:100%; object-fit:cover;">
                    <div onclick="openModalEditCrop(${index})" style="position:absolute; top:0; left:0; width:100%; height:100%; background:rgba(0,0,0,0.3); display:flex; align-items:center; justify-content:center; color:white; font-size:10px; font-weight:600;">
                        <i class="fas fa-expand"></i> Adjust
                    </div>
                `;
                previewContainer.appendChild(div);
            });
        }
        updateModalEditPreviews();
    } else {
        // We are in the feed
        const content = document.getElementById('post-content-' + postId);
        const edit = document.getElementById('edit-post-' + postId);
        if (content) content.style.display = 'none';
        if (edit) edit.style.display = 'block';
    }
}

function cancelEditPost(postId) {
    document.getElementById('edit-post-' + postId).style.display = 'none';
    document.getElementById('post-content-' + postId).style.display = 'block';
}

function toggleLikers(postId) {
    const dropdown = document.getElementById('likers-dropdown-' + postId);
    if (dropdown.style.display === 'none') {
        dropdown.style.display = 'block';
        dropdown.innerHTML = '<div class="text-center text-muted"><i class="fas fa-spinner fa-spin"></i> Loading...</div>';
        
        // Fetch likers
        fetch((window.contextPath || '') + '/InteractionServlet', {
            method: 'POST',
            headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
            body: 'action=getLikers&postId=' + postId
        })
        .then(res => res.json())
        .then(data => {
            if (data.length === 0) {
                dropdown.innerHTML = '<div style="padding:0.5rem;text-align:center;color:var(--text-muted);">No likes yet</div>';
            } else {
                let html = '<div style="font-weight:600;margin-bottom:0.75rem;border-bottom:1px solid #eee;padding-bottom:0.5rem; font-size: 0.9rem;">Liked by</div>';
                data.forEach(u => {
                    html += '<div style="display:flex; align-items:center; gap:1rem; padding:0.5rem 0; border-bottom:1px solid #eee;">' +
                                '<img src="' + getImageUrl(u.photo || 'images/default-avatar.png') + '" style="width:40px; height:40px; border-radius:50%; object-fit:cover;">' +
                                '<div style="flex:1;">' +
                                    '<a href="' + (window.contextPath || '') + '/ProfileServlet?id=' + u.userId + '" style="font-weight:600; color:var(--text-color); text-decoration:none;">' + u.name + '</a>' +
                                    '<div style="font-size:0.85rem; color:var(--text-muted);">@' + u.username + '</div>' +
                                '</div>' +
                            '</div>';
                });
                dropdown.innerHTML = html;
            }
        })
        .catch(err => {
            dropdown.innerHTML = '<div style="color:red;padding:0.5rem;">Failed to load</div>';
        });
    } else {
        dropdown.style.display = 'none';
    }
}

function deleteComment(commentId, postId) {
    if (!confirm('Are you sure you want to delete this comment?')) return;
    
    fetch((window.contextPath || '') + '/InteractionServlet', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: 'action=deleteComment&commentId=' + commentId + '&postId=' + postId
    })
    .then(response => response.json())
    .then(data => {
        if (data.success) {
            location.reload();
        } else {
            alert('Failed to delete comment.');
        }
    })
    .catch(err => {
        console.error(err);
        alert('An error occurred.');
    });
}

// Close dropdowns if clicking outside
document.addEventListener('click', function(event) {
    const dropdowns = document.querySelectorAll('.dropdown-content, [id^="likers-dropdown-"]');
    dropdowns.forEach(dropdown => {
        if (dropdown.style.display === 'block') {
            // Check if click was outside the dropdown and its toggle button
            if (!dropdown.contains(event.target) && !event.target.closest('button')) {
                dropdown.style.display = 'none';
            }
        }
    });
});
// Carousel Functionality
function updateCarouselDots(postId) {
    const carousel = document.getElementById('carousel-' + postId);
    const dotsContainer = document.getElementById('dots-' + postId);
    if (!carousel || !dotsContainer) return;

    const scrollLeft = carousel.scrollLeft;
    const width = carousel.offsetWidth;
    const index = Math.round(scrollLeft / width);

    const dots = dotsContainer.querySelectorAll('.dot');
    dots.forEach((dot, i) => {
        if (i === index) {
            dot.style.background = 'rgba(255, 255, 255, 1)';
            dot.classList.add('active');
        } else {
            dot.style.background = 'rgba(255, 255, 255, 0.5)';
            dot.classList.remove('active');
        }
    });
}

function scrollToImage(postId, index) {
    const carousel = document.getElementById('carousel-' + postId);
    if (carousel) {
        const width = carousel.offsetWidth;
        carousel.scrollTo({
            left: width * index,
            behavior: 'smooth'
        });
    }
}

function nextImage(postId) {
    const carousel = document.getElementById('carousel-' + postId);
    if (carousel) {
        const width = carousel.offsetWidth;
        const index = Math.round(carousel.scrollLeft / width);
        const total = carousel.children.length;
        const nextIndex = (index + 1) % total;
        
        carousel.scrollTo({
            left: nextIndex * width,
            behavior: 'smooth'
        });
    }
}

function prevImage(postId) {
    const carousel = document.getElementById('carousel-' + postId);
    if (carousel) {
        const width = carousel.offsetWidth;
        const index = Math.round(carousel.scrollLeft / width);
        const total = carousel.children.length;
        const prevIndex = (index - 1 + total) % total;
        
        carousel.scrollTo({
            left: prevIndex * width,
            behavior: 'smooth'
        });
    }
}

// Theme Management
const ThemeManager = {
    init: function() {
        const savedTheme = localStorage.getItem('theme') || 'light';
        this.apply(savedTheme);
        
        // Update toggle state if it exists
        const toggle = document.getElementById('themeToggle');
        if (toggle) {
            toggle.checked = savedTheme === 'dark';
            const statusText = document.getElementById('themeStatus');
            if (statusText) statusText.innerText = savedTheme === 'dark' ? 'On' : 'Off';
        }
    },
    
    apply: function(theme) {
        document.documentElement.setAttribute('data-theme', theme);
        localStorage.setItem('theme', theme);
        
        const statusText = document.getElementById('themeStatus');
        if (statusText) {
            statusText.innerText = theme === 'dark' ? 'On' : 'Off';
        }
    },
    
    toggle: function() {
        const currentTheme = document.documentElement.getAttribute('data-theme') || 'light';
        const newTheme = currentTheme === 'light' ? 'dark' : 'light';
        this.apply(newTheme);
    }
};

// Profile Grid & Modal Logic
function handleFollowClick(type, targetId, canSee) {
    if (canSee) {
        showFollowModal(type, targetId);
    }
}

function showPostDetail(postId) {
    const modal = document.getElementById('postDetailModal');
    if (!modal) return;
    
    modal.style.display = 'flex';
    const imageContainer = document.getElementById('modal-image-container');
    const userAvatar = document.getElementById('modal-user-avatar');
    const userLink = document.getElementById('modal-user-link');
    const postTime = document.getElementById('modal-post-time');
    const captionText = document.getElementById('modal-caption-text');
    const commentsList = document.getElementById('modal-comments-list');
    const likeCount = document.getElementById('modal-like-count');
    const commentCountText = document.getElementById('modal-comment-count-text');
    const likeBtn = document.getElementById('modal-like-btn');
    
    imageContainer.innerHTML = '<div class="text-white" style="padding: 100px 0;"><i class="fas fa-spinner fa-spin fa-2x"></i></div>';
    
    fetch((window.contextPath || '') + '/InteractionServlet', {
        method: 'POST',
        headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
        body: 'action=getPostDetail&postId=' + postId
    })
    .then(res => res.json())
    .then(post => {
        window.currentModalPost = post; // Store for edit mode
        // Images / Carousel
        if (post.images && post.images.length > 0) {
            if (post.images.length > 1) {
                // Simplified carousel for modal
                let html = `<div class="post-carousel" style="display:flex; overflow-x:auto; scroll-snap-type:x mandatory; width:100%; height:100%; max-height: 70vh;">`;
                post.images.forEach(img => {
                    html += `<div style="flex:0 0 100%; scroll-snap-align:start; display: flex; align-items: center; justify-content: center; background: #000;">
                                <img src="${getImageUrl(img)}" style="max-width:100%; max-height:70vh; object-fit:contain;">
                            </div>`;
                });
                html += `</div>`;
                // Add dots if multiple images
                html += `<div style="position:absolute; bottom:10px; left:50%; transform:translateX(-50%); display:flex; gap:5px; background:rgba(0,0,0,0.3); padding:4px 8px; border-radius:10px;">`;
                post.images.forEach((_, i) => {
                    html += `<div style="width:6px; height:6px; border-radius:50%; background:rgba(255,255,255,${i === 0 ? '1' : '0.5'})"></div>`;
                });
                html += `</div>`;
                imageContainer.innerHTML = html;
            } else {
                imageContainer.innerHTML = `<img src="${getImageUrl(post.images[0])}" style="max-width:100%; max-height:70vh; object-fit:contain;">`;
            }
        }
        
        // User Info
        userAvatar.src = getImageUrl(post.userPhoto || 'images/default-avatar.png');
        userLink.innerText = '@' + post.userHandle;
        userLink.href = 'ProfileServlet?id=' + post.userId;
        
        // Caption
        captionText.innerHTML = `<strong>@${post.userHandle}</strong> ${post.postContent}`;
        
        // Stats
        likeCount.innerText = post.likeCount;
        commentCountText.innerText = (post.commentCount || 0) + ' Comments';
        likeBtn.innerHTML = post.likedByCurrentUser ? '<i class="fas fa-heart text-danger"></i> Liked' : '<i class="far fa-heart"></i> Like';
        likeBtn.className = post.likedByCurrentUser ? 'action-btn text-danger' : 'action-btn';
        likeBtn.onclick = () => toggleModalLike(post.postId);
        
        // Comments
        let commHtml = '';
        if (post.comments && post.comments.length > 0) {
            post.comments.forEach(c => {
                commHtml += `
                    <div style="display:flex; gap:0.75rem; margin-bottom:1.25rem; align-items:flex-start;">
                        <img src="${getImageUrl(c.userPhoto || 'images/default-avatar.png')}" style="width:32px; height:32px; border-radius:50%; object-fit:cover; border: 1px solid var(--border-color);">
                        <div style="flex: 1; background: var(--bg-light); padding: 0.75rem; border-radius: 12px;">
                            <div style="display: flex; justify-content: space-between;">
                                <strong style="font-size: 0.85rem;">@${c.userName}</strong>
                            </div>
                            <div style="font-size:0.9rem; margin-top: 0.25rem;">${c.commentText}</div>
                        </div>
                    </div>
                `;
            });
        } else {
            commHtml = '<p class="text-muted text-center" style="padding: 2rem 0;">No comments yet.</p>';
        }
        commentsList.innerHTML = commHtml;
        
        // Store current post ID for comment submission
        window.currentModalPostId = post.postId;
        
        // Modal Post Options (Menu)
        const modalOptions = document.getElementById('modal-post-options');
        if (modalOptions) {
            if (window.loggedInUserId === post.userId) {
                modalOptions.innerHTML = `
                    <div class="dropdown" style="position:relative;">
                        <button class="action-btn text-muted" onclick="togglePostMenu(${post.postId}, event)" style="border:none;background:none; cursor:pointer; padding: 0.5rem;">
                            <i class="fas fa-ellipsis-h" style="font-size: 1.2rem;"></i>
                        </button>
                        <div id="postMenu-${post.postId}" class="dropdown-content post-dropdown-menu" style="right: 0; top: 35px;">
                            <button class="dropdown-item" onclick="showEditPost(${post.postId}); togglePostMenu(${post.postId});">
                                <i class="fas fa-edit"></i> Edit Post
                            </button>
                            <button class="dropdown-item" onclick="togglePin(${post.postId}); togglePostMenu(${post.postId});">
                                <i class="fas fa-thumbtack"></i> ${post.isPinned ? 'Unpin from Top' : 'Pin to Top'}
                            </button>
                            <div class="dropdown-divider"></div>
                            <button class="dropdown-item text-danger" onclick="if(confirm('Are you sure?')) { deletePost(${post.postId}); }">
                                <i class="fas fa-trash"></i> Delete Post
                            </button>
                        </div>
                    </div>
                `;
            } else {
                modalOptions.innerHTML = `
                    <div class="dropdown" style="position:relative;">
                        <button class="action-btn text-muted" onclick="togglePostMenu(${post.postId}, event)" style="border:none;background:none; cursor:pointer; padding: 0.5rem;">
                            <i class="fas fa-ellipsis-h" style="font-size: 1.2rem;"></i>
                        </button>
                        <div id="postMenu-${post.postId}" class="dropdown-content post-dropdown-menu" style="right: 0; top: 35px;">
                            <button class="dropdown-item" onclick="alert('Post Reported!'); togglePostMenu(${post.postId});">
                                <i class="fas fa-flag"></i> Report
                            </button>
                        </div>
                    </div>
                `;
            }
        }
    })
    .catch(err => {
        console.error(err);
        imageContainer.innerHTML = '<div class="text-white" style="padding: 50px 0;">Failed to load post detail</div>';
    });
}

function closePostDetail() {
    document.getElementById('postDetailModal').style.display = 'none';
}

function toggleModalLike(postId) {
    const likeBtn = document.getElementById('modal-like-btn');
    const likeCount = document.getElementById('modal-like-count');
    const isLiked = likeBtn.querySelector('i').classList.contains('fas');
    
    // UI Update
    if (isLiked) {
        likeBtn.innerHTML = '<i class="far fa-heart"></i>';
        likeCount.innerText = parseInt(likeCount.innerText) - 1;
    } else {
        likeBtn.innerHTML = '<i class="fas fa-heart text-danger"></i>';
        likeCount.innerText = parseInt(likeCount.innerText) + 1;
    }
    
    fetch((window.contextPath || '') + '/InteractionServlet', {
        method: 'POST',
        headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
        body: 'action=like&postId=' + postId
    });
}

function handleModalComment(e) {
    e.preventDefault();
    const input = document.getElementById('modal-comment-input');
    const text = input.value.trim();
    const postId = window.currentModalPostId;
    
    if (!text || !postId) return;
    
    fetch((window.contextPath || '') + '/InteractionServlet', {
        method: 'POST',
        headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
        body: 'action=comment&postId=' + postId + '&commentText=' + encodeURIComponent(text)
    })
    .then(() => {
        input.value = '';
        showPostDetail(postId); // Refresh comments
    });
}

// Initializations
document.addEventListener('DOMContentLoaded', () => {
    ThemeManager.init();
    
    // Close modal on escape
    document.addEventListener('keydown', (e) => {
        if (e.key === 'Escape') {
            closePostDetail();
            if (typeof closeFollowModal === 'function') closeFollowModal();
        }
    });
});

function confirmLogout() {
    if (confirm("Are you sure you want to logout?")) {
        window.location.href = (window.contextPath || '') + "/LogoutServlet";
    }
}

// Post Edit Adjustment Logic
let currentEditPostId = null;
let currentEditImgIndex = null;
let editAdjustmentData = {}; // Store {postId: {index: {x, y, s, blob, originalSrc}}}

function updateEditPreviews(postId) {
    const container = document.getElementById('edit-previews-' + postId);
    const ratioRadio = document.querySelector(`input[name="editAspectRatio-${postId}"]:checked`);
    if (!ratioRadio) return;
    const ratio = ratioRadio.value;
    
    // Update active class on labels
    document.querySelectorAll(`#edit-post-${postId} .ratio-box-sm`).forEach(box => {
        box.classList.remove('active');
        if (box.innerText === (ratio === '1/1' ? '1:1' : '16:9')) {
            box.classList.add('active');
        }
    });

    // Update aspect ratio of preview items
    if (container) {
        container.querySelectorAll('.edit-preview-item').forEach(item => {
            item.style.aspectRatio = ratio;
        });
    }
}

function openEditCropModal(postId, index) {
    currentEditPostId = postId;
    currentEditImgIndex = index;
    
    const previewContainer = document.getElementById('edit-previews-' + postId);
    if (!previewContainer) return;
    const previewItem = previewContainer.children[index];
    const img = previewItem.querySelector('img');
    const ratioRadio = document.querySelector(`input[name="editAspectRatio-${postId}"]:checked`);
    const aspectRatio = ratioRadio ? ratioRadio.value : "16/9";
    
    // Check if we have modified this image already
    if (!editAdjustmentData[postId]) editAdjustmentData[postId] = {};
    const data = editAdjustmentData[postId][index] || {
        originalSrc: img.dataset.original || img.getAttribute('src').replace((window.contextPath || '') + '/', ''),
        x: 0, y: 0, s: 1, adjusted: false
    };

    let cropModal = document.getElementById('cropModal');
    if (!cropModal) {
        // Inject modal if missing
        const modalHtml = `
            <div id="cropModal" class="modal" style="display:none; align-items:center; justify-content:center; background:rgba(0,0,0,0.85); z-index:2000;">
                <div class="modal-content card" style="max-width:500px; width:95%; padding:1.5rem;">
                    <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:1.5rem;">
                        <h3 style="margin:0;">Adjust Image</h3>
                        <span class="close" onclick="closeCropModal()" style="font-size:1.5rem; cursor:pointer;">&times;</span>
                    </div>
                    <div id="cropContainer" style="width:100%; background:#000; overflow:hidden; border-radius:8px; position:relative; cursor:move; user-select:none; aspect-ratio: 16/9;">
                        <img id="cropImg" src="" style="position:absolute; top:0; left:0; pointer-events:none;">
                        <div style="position:absolute; top:0; left:0; width:100%; height:100%; box-shadow: 0 0 0 1000px rgba(0,0,0,0.5); pointer-events:none; border: 2px solid var(--primary-color);"></div>
                    </div>
                    <div style="margin-top:1.5rem; text-align:center;">
                        <div style="display:flex; align-items:center; justify-content:center; gap:1rem; margin-bottom:1rem;">
                            <i class="fas fa-search-minus text-muted"></i>
                            <input type="range" id="zoomSlider" min="1" max="3" step="0.01" value="1" style="flex:1;">
                            <i class="fas fa-search-plus text-muted"></i>
                        </div>
                        <small class="text-muted d-block mb-3">Drag the image to position it</small>
                        <button type="button" class="btn btn-primary w-100" onclick="saveEditCrop()">Apply Adjustment</button>
                    </div>
                </div>
            </div>`;
        document.body.insertAdjacentHTML('beforeend', modalHtml);
        cropModal = document.getElementById('cropModal');
        
        const cropContainer = document.getElementById('cropContainer');
        const cropImg = document.getElementById('cropImg');
        const zoomSlider = document.getElementById('zoomSlider');
        let isDragging = false, startX, startY, currentX = 0, currentY = 0, scale = 1;

        const updateTransform = () => {
             cropImg.style.transform = "translate(" + currentX + "px, " + currentY + "px) scale(" + scale + ")";
        };

        const startDrag = (e) => {
            isDragging = true;
            const clientX = e.touches ? e.touches[0].clientX : e.clientX;
            const clientY = e.touches ? e.touches[0].clientY : e.clientY;
            startX = clientX - currentX;
            startY = clientY - currentY;
        };

        const doDrag = (e) => {
            if (!isDragging) return;
            const clientX = e.touches ? e.touches[0].clientX : e.clientX;
            const clientY = e.touches ? e.touches[0].clientY : e.clientY;
            currentX = clientX - startX;
            currentY = clientY - startY;
            updateTransform();
        };

        cropContainer.addEventListener('mousedown', startDrag);
        cropContainer.addEventListener('touchstart', startDrag, { passive: false });
        window.addEventListener('mousemove', doDrag);
        window.addEventListener('touchmove', doDrag, { passive: false });
        window.addEventListener('mouseup', () => isDragging = false);
        window.addEventListener('touchend', () => isDragging = false);

        zoomSlider.addEventListener('input', () => {
            scale = parseFloat(zoomSlider.value);
            updateTransform();
        });

        window._cropState = {
            set: (x, y, s) => { currentX = x; currentY = y; scale = s; updateTransform(); },
            get: () => ({ x: currentX, y: currentY, s: scale })
        };
    }

    const cropContainer = document.getElementById('cropContainer');
    const cropImg = document.getElementById('cropImg');
    const zoomSlider = document.getElementById('zoomSlider');

    cropModal.style.display = 'flex';
    cropContainer.style.aspectRatio = aspectRatio;

    cropImg.onload = () => {
        const containerRect = cropContainer.getBoundingClientRect();
        cropImg.style.width = containerRect.width + 'px';
        cropImg.style.height = 'auto';
        
        if (data.adjusted) {
            window._cropState.set(data.x, data.y, data.s);
            zoomSlider.value = data.s;
        } else {
            setTimeout(() => {
                const y = (containerRect.height - cropImg.offsetHeight) / 2;
                window._cropState.set(0, y, 1);
                zoomSlider.value = 1;
            }, 50);
        }
    };
    
    cropImg.src = getImageUrl(data.originalSrc);
}

function closeCropModal() {
    document.getElementById('cropModal').style.display = 'none';
}

function saveEditCrop() {
    const postId = currentEditPostId;
    const index = currentEditImgIndex;
    const state = window._cropState.get();
    const ratioRadio = document.querySelector(`input[name="editAspectRatio-${postId}"]:checked`);
    const aspectRatio = ratioRadio ? ratioRadio.value : "16/9";
    const previewContainer = document.getElementById('edit-previews-' + postId);
    const img = previewContainer.children[index].querySelector('img');

    const canvas = document.createElement('canvas');
    const parts = aspectRatio.split('/');
    const rw = parseInt(parts[0]);
    const rh = parseInt(parts[1]);
    canvas.width = 1080;
    canvas.height = 1080 * (rh / rw);
    const ctx = canvas.getContext('2d');
    
    const cropContainer = document.getElementById('cropContainer');
    const cropImg = document.getElementById('cropImg');
    const containerWidth = cropContainer.offsetWidth;
    const drawScale = 1080 / containerWidth;

    ctx.fillStyle = '#000';
    ctx.fillRect(0, 0, canvas.width, canvas.height);

    const fullImg = new Image();
    fullImg.onload = () => {
        const dw = cropImg.offsetWidth * state.s * drawScale;
        const dh = cropImg.offsetHeight * state.s * drawScale;
        ctx.drawImage(fullImg, state.x * drawScale, state.y * drawScale, dw, dh);
        
        const blobUrl = canvas.toDataURL('image/jpeg', 0.9);
        img.src = blobUrl;
        
        if (!editAdjustmentData[postId]) editAdjustmentData[postId] = {};
        editAdjustmentData[postId][index] = {
            ...state,
            originalSrc: img.dataset.original || img.getAttribute('src').replace((window.contextPath || '') + '/', ''),
            previewBlob: blobUrl,
            adjusted: true
        };

        closeCropModal();
    };
    fullImg.src = cropImg.src;
}

async function handleEditPostSubmit(e, postId) {
    e.preventDefault();
    const form = e.target;
    const submitBtn = form.querySelector('button[type="submit"]');
    const originalText = submitBtn.innerText;
    
    submitBtn.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Saving...';
    submitBtn.disabled = true;

    const formData = new FormData();
    formData.append('postId', postId);
    formData.append('content', form.querySelector('textarea[name="content"]').value);
    const ratioRadio = form.querySelector(`input[name="editAspectRatio-${postId}"]:checked`);
    formData.append('aspectRatio', ratioRadio ? ratioRadio.value : "16/9");

    const previewContainer = document.getElementById('edit-previews-' + postId);
    const previews = previewContainer ? previewContainer.querySelectorAll('.edit-preview-item img') : [];
    
    try {
        for (let i = 0; i < previews.length; i++) {
            const img = previews[i];
            const adj = editAdjustmentData[postId] ? editAdjustmentData[postId][i] : null;

            if (adj && adj.adjusted) {
                const res = await fetch(adj.previewBlob);
                const blob = await res.blob();
                formData.append('imageFiles', blob, "adjusted_" + i + ".jpg");
            } else {
                const path = img.dataset.original || img.getAttribute('src').replace((window.contextPath || '') + '/', '');
                formData.append('existingImages', path);
            }
        }

        const res = await fetch((window.contextPath || '') + '/UpdatePostServlet', {
            method: 'POST',
            body: formData,
            headers: { 'X-Requested-With': 'XMLHttpRequest' }
        });

        if (res.ok && (await res.text()) === 'success') {
            window.location.reload();
        } else {
            alert('Failed to save changes.');
            submitBtn.innerText = originalText;
            submitBtn.disabled = false;
        }
    } catch (err) {
        console.error(err);
        alert('An error occurred.');
        submitBtn.innerText = originalText;
        submitBtn.disabled = false;
    }
}

function updateModalEditPreviews() {
    const container = document.getElementById('modal-edit-previews');
    const ratioRadio = document.querySelector('input[name="modalEditAspectRatio"]:checked');
    if (!ratioRadio || !container) return;
    const ratio = ratioRadio.value;
    
    // Update active class on labels
    document.querySelectorAll('#modal-edit-view .ratio-box-sm').forEach(box => {
        box.classList.remove('active');
        if (box.innerText === (ratio === '1/1' ? '1:1' : '16:9')) {
            box.classList.add('active');
        }
    });

    container.querySelectorAll('.edit-preview-item').forEach(item => {
        item.style.aspectRatio = ratio;
    });
}

function openModalEditCrop(index) {
    const postId = window.currentModalPostId;
    if (!postId) return;
    
    // Reuse the existing openEditCropModal logic but for the modal context
    currentEditPostId = postId;
    currentEditImgIndex = index;
    
    const previewContainer = document.getElementById('modal-edit-previews');
    const previewItem = previewContainer.children[index];
    const img = previewItem.querySelector('img');
    const ratioRadio = document.querySelector('input[name="modalEditAspectRatio"]:checked');
    const aspectRatio = ratioRadio ? ratioRadio.value : "16/9";
    
    // Check if we have modified this image already
    if (!editAdjustmentData[postId]) editAdjustmentData[postId] = {};
    const data = editAdjustmentData[postId][index] || {
        originalSrc: img.dataset.original,
        x: 0, y: 0, s: 1, adjusted: false
    };

    const cropModal = document.getElementById('cropModal');
    const cropContainer = document.getElementById('cropContainer');
    const cropImg = document.getElementById('cropImg');
    const zoomSlider = document.getElementById('zoomSlider');

    cropModal.style.display = 'flex';
    cropContainer.style.aspectRatio = aspectRatio;

    cropImg.onload = () => {
        const containerRect = cropContainer.getBoundingClientRect();
        cropImg.style.width = containerRect.width + 'px';
        cropImg.style.height = 'auto';
        
        if (data.adjusted) {
            window._cropState.set(data.x, data.y, data.s);
            zoomSlider.value = data.s;
        } else {
            setTimeout(() => {
                const y = (containerRect.height - cropImg.offsetHeight) / 2;
                window._cropState.set(0, y, 1);
                zoomSlider.value = 1;
            }, 50);
        }
    };
    
    cropImg.src = (window.contextPath || '') + '/' + data.originalSrc;
}

async function saveModalEditWithImages() {
    const postId = window.currentModalPostId;
    const text = document.getElementById('modal-edit-input').value;
    if (!postId) return;
    
    const submitBtn = document.querySelector('#modal-edit-view .btn-primary');
    const originalText = submitBtn.innerText;
    submitBtn.innerText = 'Saving...';
    submitBtn.disabled = true;

    const formData = new FormData();
    formData.append('postId', postId);
    formData.append('content', text);
    const ratioRadio = document.querySelector('input[name="modalEditAspectRatio"]:checked');
    formData.append('aspectRatio', ratioRadio ? ratioRadio.value : "16/9");

    const previews = document.querySelectorAll('#modal-edit-previews .edit-preview-item img');
    
    try {
        for (let i = 0; i < previews.length; i++) {
            const img = previews[i];
            const adj = editAdjustmentData[postId] ? editAdjustmentData[postId][i] : null;

            if (adj && adj.adjusted) {
                const res = await fetch(adj.previewBlob);
                const blob = await res.blob();
                formData.append('imageFiles', blob, "adjusted_" + i + ".jpg");
            } else {
                formData.append('existingImages', img.dataset.original);
            }
        }

        const res = await fetch((window.contextPath || '') + '/UpdatePostServlet', {
            method: 'POST',
            body: formData,
            headers: { 'X-Requested-With': 'XMLHttpRequest' }
        });

        if (res.ok && (await res.text()) === 'success') {
            window.location.reload();
        } else {
            alert('Failed to save changes.');
            submitBtn.innerText = originalText;
            submitBtn.disabled = false;
        }
    } catch (err) {
        console.error(err);
        alert('An error occurred.');
        submitBtn.innerText = originalText;
        submitBtn.disabled = false;
    }
}

function togglePostMenu(postId, event) {
    if (event) event.stopPropagation();
    const menu = document.getElementById('postMenu-' + postId);
    const allMenus = document.querySelectorAll('.post-dropdown-menu');
    
    // Close others
    allMenus.forEach(m => {
        if (m.id !== 'postMenu-' + postId) m.style.display = 'none';
    });

    if (menu) {
        menu.style.display = (menu.style.display === 'block') ? 'none' : 'block';
    }
}

function togglePin(postId) {
    fetch((window.contextPath || '') + '/InteractionServlet', {
        method: 'POST',
        headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
        body: 'action=pin&postId=' + postId
    })
    .then(res => {
        if (!res.ok) throw new Error('Network response was not ok');
        return res.json();
    })
    .then(data => {
        if (data.status === 'pinned') {
            alert('Post pinned to top!');
            window.location.reload();
        } else if (data.status === 'unpinned') {
            alert('Post unpinned!');
            window.location.reload();
        } else if (data.status === 'limit_reached') {
            alert('You can only pin up to 3 posts.');
        } else {
            console.error('Server returned error status:', data.status);
            alert('Failed to update pin status. (DB Error)');
        }
    })
    .catch(err => {
        console.error('Pinning error:', err);
        alert('An error occurred. Make sure your database is updated.');
    });
}

function cancelModalEdit() {
    document.getElementById('modal-caption-view').style.display = 'block';
    document.getElementById('modal-edit-view').style.display = 'none';
}

function saveModalEdit() {
    const postId = window.currentModalPostId;
    const text = document.getElementById('modal-edit-input').value;
    
    if (!postId) return;
    
    const submitBtn = document.querySelector('#modal-edit-view .btn-primary');
    const originalText = submitBtn.innerText;
    submitBtn.innerText = 'Saving...';
    submitBtn.disabled = true;

    fetch((window.contextPath || '') + '/SettingsServlet', {
        method: 'POST',
        headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
        body: 'action=updatePostContent&postId=' + postId + '&content=' + encodeURIComponent(text)
    })
    .then(res => res.text())
    .then(data => {
        if (data === 'success') {
            alert('Post updated!');
            showPostDetail(postId); // Refresh modal content
            cancelModalEdit();
        } else {
            alert('Failed to update post: ' + data);
        }
    })
    .catch(err => {
        console.error(err);
        alert('An error occurred.');
    })
    .finally(() => {
        submitBtn.innerText = originalText;
        submitBtn.disabled = false;
    });
}

function deletePost(postId) {
    if (!confirm('Are you sure you want to delete this post?')) return;
    
    fetch((window.contextPath || '') + '/DeletePostServlet', {
        method: 'POST',
        headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
        body: 'postId=' + postId
    })
    .then(res => {
        if (res.ok) {
            alert('Post deleted!');
            window.location.reload();
        } else {
            alert('Failed to delete post.');
        }
    })
    .catch(err => {
        console.error(err);
        alert('An error occurred.');
    });
}

// --- Instagram-style request-based follow (sends a friend request that needs approval) ---
function sendFollowRequest(targetId, btn) {
    btn.disabled = true;
    fetch((window.contextPath || '') + '/FriendServlet', {
        method: 'POST',
        headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
        body: 'action=send&friendId=' + targetId
    })
    .then(res => {
        if (res.ok || res.redirected) {
            btn.innerText = 'Requested';
            btn.classList.remove('btn-primary');
            btn.classList.add('btn-outline');
            btn.style.background = 'var(--bg-light)';
            btn.style.color = 'var(--text-muted)';
            btn.onclick = function() { cancelFollowRequest(targetId, btn); };
        }
        btn.disabled = false;
    }).catch(() => { btn.disabled = false; });
}

function cancelFollowRequest(targetId, btn) {
    btn.disabled = true;
    fetch((window.contextPath || '') + '/FriendServlet', {
        method: 'POST',
        headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
        body: 'action=remove&friendId=' + targetId
    })
    .then(res => {
        if (res.ok || res.redirected) {
            btn.innerText = 'Follow';
            btn.classList.remove('btn-outline');
            btn.classList.add('btn-primary');
            btn.style.background = '';
            btn.style.color = '';
            btn.onclick = function() { sendFollowRequest(targetId, btn); };
        }
        btn.disabled = false;
    }).catch(() => { btn.disabled = false; });
}

function removeFollow(targetId, btn) {
    btn.disabled = true;
    fetch((window.contextPath || '') + '/FollowServlet', {
        method: 'POST',
        headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
        body: 'action=toggle&targetId=' + targetId
    })
    .then(res => {
        if (res.ok) {
            // Update follower count
            const followersElem = document.getElementById('followers-count');
            if (followersElem) {
                let count = parseInt(followersElem.innerText) || 0;
                followersElem.innerText = Math.max(0, count - 1);
            }
            btn.innerText = 'Follow';
            btn.classList.remove('btn-outline');
            btn.classList.add('btn-primary');
            btn.onclick = function() { sendFollowRequest(targetId, btn); };
        }
        btn.disabled = false;
    }).catch(() => { btn.disabled = false; });
}
// --- End follow request functions ---

function toggleFollow(targetId, btn) {
    fetch((window.contextPath || '') + '/FollowServlet', {
        method: 'POST',
        headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
        body: 'action=toggle&targetId=' + targetId
    })
    .then(res => {
        if (res.ok) {
            // Determine action: btn-outline = "Unfollow" = currently following → will unfollow
            const wasFollowing = btn.classList.contains('btn-outline');

            // Update button state
            if (wasFollowing) {
                btn.classList.remove('btn-outline');
                btn.classList.add('btn-primary');
                btn.innerText = 'Follow';
            } else {
                btn.classList.remove('btn-primary');
                btn.classList.add('btn-outline');
                btn.innerText = 'Unfollow';
            }

            // Update follower count if we are on the target user's profile
            const followersElem = document.getElementById('followers-count');
            const followingElem = document.getElementById('following-count');
            const profileOwner = String(window.currentProfileUserId || '');
            const profileIsTarget = profileOwner !== '' && profileOwner === String(targetId);
            const profileIsSelf = profileOwner !== '' && profileOwner === String(window.loggedInUserId || '');

            if (followersElem && profileIsTarget) {
                let count = parseInt(followersElem.innerText) || 0;
                followersElem.innerText = wasFollowing ? Math.max(0, count - 1) : count + 1;
            }

            if (followingElem && profileIsSelf) {
                let count = parseInt(followingElem.innerText) || 0;
                followingElem.innerText = wasFollowing ? Math.max(0, count - 1) : count + 1;
            }
        } else {
            alert('Failed to update follow status.');
        }
    })
    .catch(err => {
        console.error(err);
        alert('An error occurred.');
    });
}

function toggleReaction(postId, emoji) {
    if (!postId) return;
    
    fetch((window.contextPath || '') + '/InteractionServlet', {
        method: 'POST',
        headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
        body: 'action=react&postId=' + postId + '&emoji=' + encodeURIComponent(emoji)
    })
    .then(res => res.json())
    .then(data => {
        loadReactions(postId);
    })
    .catch(err => console.error('Reaction error:', err));
}

function loadReactions(postId) {
    if (!postId) return;
    const display = document.getElementById('modal-reactions-display');
    if (!display) return;
    
    fetch((window.contextPath || '') + '/InteractionServlet', {
        method: 'POST',
        headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
        body: 'action=getReactions&postId=' + postId
    })
    .then(res => res.json())
    .then(data => {
        if (data.length === 0) {
            display.innerHTML = '';
            return;
        }
        
        let html = '';
        data.forEach(r => {
            html += `
                <div style="background: var(--bg-light); padding: 2px 8px; border-radius: 12px; font-size: 0.85rem; display:flex; align-items:center; gap:4px; border: 1px solid var(--border-color); cursor:pointer;" onclick="toggleReaction(${postId}, '${r.emoji}')">
                    <span>${r.emoji}</span>
                    <span style="font-weight:600;">${r.count}</span>
                </div>
            `;
        });
        display.innerHTML = html;
    })
    .catch(err => console.error('Load reactions error:', err));
}

function toggleEmojiPicker(messageId, event) {
    if (event) event.stopPropagation();
    const picker = document.getElementById('emoji-picker-' + messageId);
    if (!picker) return;
    
    // Close all other pickers
    document.querySelectorAll('.emoji-picker-popup').forEach(p => {
        if (p.id !== 'emoji-picker-' + messageId) p.style.display = 'none';
    });
    
    picker.style.display = picker.style.display === 'flex' ? 'none' : 'flex';
}

function toggleMessageReaction(messageId, emoji, event) {
    if (event) event.stopPropagation();
    fetch((window.contextPath || '') + '/InteractionServlet', {
        method: 'POST',
        headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
        body: 'action=reactMessage&messageId=' + messageId + '&emoji=' + encodeURIComponent(emoji)
    })
    .then(res => res.json())
    .then(data => {
        loadMessageReactions(messageId);
        const picker = document.getElementById('emoji-picker-' + messageId);
        if (picker) picker.style.display = 'none';
    })
    .catch(err => console.error('Message reaction error:', err));
}

function loadMessageReactions(messageId) {
    const display = document.getElementById('msg-reactions-' + messageId);
    if (!display) return;
    
    fetch((window.contextPath || '') + '/InteractionServlet', {
        method: 'POST',
        headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
        body: 'action=getMessageReactions&messageId=' + messageId
    })
    .then(res => res.json())
    .then(data => {
        if (!data || data.length === 0) {
            display.innerHTML = '';
            return;
        }
        
        let html = '';
        data.forEach(r => {
            html += `
                <div class="reaction-item" onclick="toggleMessageReaction(${messageId}, '${r.emoji}', event)">
                    <span>${r.emoji}</span>
                    <span style="font-weight:600;">${r.count}</span>
                </div>
            `;
        });
        display.innerHTML = html;
    })
    .catch(err => console.error('Load message reactions error:', err));
}

// Close emoji pickers on click outside
document.addEventListener('click', () => {
    document.querySelectorAll('.emoji-picker-popup').forEach(p => p.style.display = 'none');
});

// --- Followers / Following List Modal ---
function handleFollowClick(type, targetUserId, canSeePosts) {
    const modal = document.getElementById('followListModal');
    const title = document.getElementById('followListTitle');
    const body  = document.getElementById('followListBody');
    if (!modal) return;

    title.innerText = type === 'followers' ? 'Followers' : 'Following';
    body.innerHTML  = '<div style="padding:2rem; text-align:center; color:var(--text-muted);">Loading...</div>';
    modal.style.display = 'flex';

    var action = type === 'followers' ? 'getFollowers' : 'getFollowing';
    fetch((window.contextPath || '') + '/InteractionServlet', {
        method: 'POST',
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: 'action=' + action + '&targetId=' + targetUserId
    })
    .then(function(res) { return res.json(); })
    .then(function(users) {
        if (!users || users.length === 0) {
            body.innerHTML = '<div style="padding:2rem; text-align:center; color:var(--text-muted);">No ' + type + ' yet.</div>';
            return;
        }
        var html = '';
        users.forEach(function(u) {
            var ctx   = window.contextPath || '';
            var photo = u.photo ? u.photo : 'images/default-avatar.png';
            html += '<a href="' + ctx + '/ProfileServlet?id=' + u.userId + '" style="display:flex; align-items:center; gap:0.85rem; padding:0.75rem 1.25rem; text-decoration:none; color:inherit; transition:background 0.15s;" onmouseover="this.style.background=\'var(--bg-light)\'" onmouseout="this.style.background=\'transparent\'">' +
                '<img src="' + ctx + '/' + photo + '" style="width:46px; height:46px; border-radius:50%; object-fit:cover; flex-shrink:0; border:1px solid var(--border-color);">' +
                '<div style="display:flex; flex-direction:column; gap:2px;">' +
                    '<span style="font-weight:600; font-size:0.95rem;">@' + u.username + '</span>' +
                '</div>' +
            '</a>';
        });
        body.innerHTML = html;
    })
    .catch(function() {
        body.innerHTML = '<div style="padding:2rem; text-align:center; color:var(--text-muted);">Could not load list.</div>';
    });
}

function closeFollowListModal() {
    var modal = document.getElementById('followListModal');
    if (modal) modal.style.display = 'none';
}

// Close when clicking outside the card
document.addEventListener('click', function(e) {
    var modal = document.getElementById('followListModal');
    if (modal && e.target === modal) modal.style.display = 'none';
});
// --- End Followers / Following List Modal ---
