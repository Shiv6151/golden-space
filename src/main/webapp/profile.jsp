<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.fmt" prefix="fmt" %>
<%@ taglib uri="jakarta.tags.functions" prefix="fn" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>${profileUser.name} - Profile</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="css/styles.css?v=<%= System.currentTimeMillis() %>">
    <link rel="stylesheet" href="css/app.css?v=<%= System.currentTimeMillis() %>">
    <style>
        @media (max-width: 768px) {
            .ig-profile-header {
                flex-direction: column !important;
                align-items: center !important;
                padding: 1rem !important;
                gap: 1rem !important;
            }
            .ig-avatar-section {
                align-items: center !important;
                text-align: center !important;
            }
            .ig-avatar { width: 80px !important; height: 80px !important; }
            .ig-info-section {
                width: 100% !important;
                align-items: center !important;
                text-align: center !important;
            }
            .ig-user-row {
                flex-wrap: wrap !important;
                justify-content: center !important;
                gap: 0.5rem !important;
            }
            .ig-stats {
                gap: 1.5rem !important;
                justify-content: center !important;
            }
            .ig-full-name { font-size: 1.15rem !important; }
            .ig-bio { font-size: 0.9rem !important; }
            .profile-grid {
                grid-template-columns: repeat(3, 1fr) !important;
                gap: 2px !important;
            }
            .main-container { padding: 0 !important; }
            #settingsModal .modal-content {
                width: 95vw !important;
                max-width: 95vw !important;
                margin: 1rem auto !important;
            }
            .btn { font-size: 0.85rem !important; padding: 0.4rem 0.9rem !important; }
        }
        @media (max-width: 480px) {
            .ig-avatar { width: 70px !important; height: 70px !important; }
            .ig-stats { gap: 1rem !important; }
            .profile-grid { gap: 1px !important; }
            /* Mobile adjustments for professional sections */
            .card { padding: 1rem !important; }
            .timeline-item { padding-bottom: 1rem !important; }
            .form-grid { grid-template-columns: 1fr !important; }
            .ig-profile-header { 
                flex-direction: column !important; 
                align-items: flex-start !important;
                gap: 1rem !important;
                padding: 1.5rem 1rem !important;
            }
            .ig-avatar-section {
                flex-direction: row !important;
                align-items: center !important;
                gap: 1.5rem !important;
                width: 100% !important;
            }
            .ig-avatar { width: 80px !important; height: 80px !important; }
            .ig-username { margin: 0 !important; font-size: 1.25rem !important; }
            .ig-info-section { width: 100% !important; }
            .ig-stats-row { 
                justify-content: space-around !important; 
                border-top: 1px solid var(--border-color);
                border-bottom: 1px solid var(--border-color);
                padding: 0.75rem 0 !important;
                margin: 1rem 0 !important;
            }
            .ig-user-row .btn { 
                width: 100% !important; 
                justify-content: center !important;
                padding: 0.6rem !important;
            }
            .ig-user-row { width: 100% !important; }
            .profile-headline { font-size: 0.95rem !important; }
        }
        
        /* Professional Form Styling */
        .form-label {
            display: block;
            margin-bottom: 0.5rem;
            font-weight: 600;
            color: var(--text-main);
            font-size: 0.9rem;
        }
        .form-input {
            width: 100%;
            padding: 0.75rem;
            border: 1px solid var(--border-color);
            border-radius: 8px;
            background: var(--bg-light);
            font-family: inherit;
            font-size: 1rem;
            transition: border-color 0.2s;
        }
        .form-input:focus {
            outline: none;
            border-color: var(--primary-color);
            background: #fff;
        }
        .mb-3 { margin-bottom: 1.25rem; }
        .form-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 1rem; }
    </style>
</head>
<body>
    <jsp:include page="components/navbar.jsp" />

    <div class="main-container">
        <!-- Elevated Premium Profile Header Section -->
        <div class="ig-profile-header" style="position: relative; background: var(--bg-white); border-radius: 20px; box-shadow: 0 8px 30px rgba(0,0,0,0.04); padding: 3rem 2.5rem; border: 1px solid rgba(0,0,0,0.05); margin-bottom: 2rem;">
            <c:if test="${isSelf}">
                <a href="settings.jsp" style="position: absolute; top: 1.5rem; right: 1.5rem; color: var(--text-muted); font-size: 1.4rem; transition: all 0.2s; text-decoration: none; width: 40px; height: 40px; display: flex; align-items: center; justify-content: center; border-radius: 50%; background: var(--bg-light);" onmouseover="this.style.color='var(--primary-color)'; this.style.transform='rotate(45deg)';" onmouseout="this.style.color='var(--text-muted)'; this.style.transform='rotate(0)';" title="Settings">
                    <i class="fas fa-cog"></i>
                </a>
            </c:if>
            <div class="ig-avatar-section">
                <img src="${profileUser.profilePhoto != null && (profileUser.profilePhoto.startsWith('http') || profileUser.profilePhoto.startsWith('data:')) ? profileUser.profilePhoto : pageContext.request.contextPath.concat('/').concat(profileUser.profilePhoto != null ? profileUser.profilePhoto : 'images/default-avatar.png')}" 
                     class="ig-avatar clickable" alt="${profileUser.name}"
                     onclick="showProfilePhoto(this.src)"
                     style="width: 150px; height: 150px; border: 4px solid var(--bg-white); box-shadow: 0 4px 15px rgba(0,0,0,0.1);">
                <h2 class="ig-username" style="margin-top: 1.5rem; font-weight: 700; color: var(--text-main); font-size: 1.5rem;">
                    ${profileUser.username}
                    <c:if test="${not isSelf && connectionDegree != null}">
                        <span class="connection-degree" style="font-size: 0.85rem; color: var(--text-muted); font-weight: 500; margin-left: 0.25rem;">
                            • ${connectionDegree == 1 ? '1st' : (connectionDegree == 2 ? '2nd' : '3rd')}
                        </span>
                    </c:if>
                </h2>
            </div>
            
            <div class="ig-info-section">
                <div class="ig-bio-section" style="margin-bottom: 1rem;">
                    <div class="ig-full-name" style="font-size: 1.25rem; font-weight: 700; margin-bottom: 0.15rem;">
                        ${profileUser.name}
                    </div>
                    <c:if test="${not empty profileUser.headline}">
                        <div class="profile-headline" style="color: var(--text-main); margin-bottom: 0.5rem; font-size: 1rem; line-height: 1.3;">
                            ${profileUser.headline}
                        </div>
                    </c:if>
                    <div class="ig-bio-text" style="font-size: 0.9rem; line-height: 1.4;">${profileUser.bio != null ? profileUser.bio : "No bio available."}</div>
                    <div class="ig-joined-date" style="margin-top: 0.5rem; font-size: 0.8rem; color: var(--text-muted);"><i class="far fa-calendar-alt"></i> Joined <fmt:formatDate value="${profileUser.createdAt}" pattern="MMMM yyyy" /></div>
                </div>

                <div class="ig-stats-row" style="margin: 1.5rem 0; padding: 1.5rem 0; border-top: 1px solid var(--border-color); border-bottom: 1px solid var(--border-color);">
                    <div class="ig-stat" style="transition: all 0.2s; border-radius: 12px; padding: 0.5rem; cursor: default;">
                        <strong style="font-size: 1.25rem; color: var(--text-main);">${postCount != null ? postCount : 0}</strong>
                        <span style="font-size: 0.85rem; color: var(--text-muted); text-transform: uppercase; letter-spacing: 0.05em; margin-top: 0.2rem;">posts</span>
                    </div>
                    <div class="ig-stat" onclick="handleFollowClick('followers', '${profileUser.userId}', '${canSeePosts != null ? canSeePosts : false}')" style="transition: all 0.2s; border-radius: 12px; padding: 0.5rem;">
                        <strong id="followers-count" style="font-size: 1.25rem; color: var(--text-main);">${followersCount != null ? followersCount : 0}</strong>
                        <span style="font-size: 0.85rem; color: var(--text-muted); text-transform: uppercase; letter-spacing: 0.05em; margin-top: 0.2rem;">followers</span>
                    </div>
                    <div class="ig-stat" onclick="handleFollowClick('following', '${profileUser.userId}', '${canSeePosts != null ? canSeePosts : false}')" style="transition: all 0.2s; border-radius: 12px; padding: 0.5rem;">
                        <strong id="following-count" style="font-size: 1.25rem; color: var(--text-main);">${followingCount != null ? followingCount : 0}</strong>
                        <span style="font-size: 0.85rem; color: var(--text-muted); text-transform: uppercase; letter-spacing: 0.05em; margin-top: 0.2rem;">following</span>
                    </div>
                </div>

                <div class="ig-user-row">
                    <c:choose>
                        <c:when test="${isSelf}">
                            <!-- Removed Edit Profile Button per user request -->
                        </c:when>
                        <c:otherwise>
                            <div style="display:flex; gap:0.5rem; width: 100%;">
                                <c:choose>
                                    <c:when test="${isFollowing}">
                                        <button class="btn btn-outline btn-sm" style="flex: 1;" id="follow-action-btn" onclick="removeFollow('${profileUser.userId}', this)">Unfollow</button>
                                    </c:when>
                                    <c:when test="${isRequestPending}">
                                        <button class="btn btn-outline btn-sm" style="flex: 1;" id="follow-action-btn" onclick="cancelFollowRequest('${profileUser.userId}', this)" style="background:var(--bg-light); color:var(--text-muted);">Requested</button>
                                    </c:when>
                                    <c:otherwise>
                                        <button class="btn btn-primary btn-sm" style="flex: 1;" id="follow-action-btn" onclick="openConnectModal()">Connect</button>
                                    </c:otherwise>
                                </c:choose>
                                <c:if test="${isMutualFollowing}">
                                    <a href="MessageServlet?with=${profileUser.userId}" class="btn btn-outline btn-sm" style="flex: 1; text-align: center; text-decoration: none;">Message</a>
                                </c:if>
                            </div>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>
        </div>

        <c:if test="${isSelf}">
            <!-- Professional Dashboard / Analytics -->
            <div class="main-container" style="max-width: 935px; margin-top: 1rem; padding: 0 1rem;">
                <div class="card" style="padding: 1.5rem; background: linear-gradient(135deg, var(--primary-light, #fdf2f8) 0%, #ffffff 100%); border: 1px solid var(--border-color);">
                    <div style="display: flex; justify-content: space-between; align-items: flex-start;">
                        <div>
                            <h3 style="margin: 0; color: var(--primary-dark); font-size: 1.25rem;">Analytics Dashboard</h3>
                            <p class="text-muted" style="margin: 0.25rem 0 1rem; font-size: 0.9rem;">Private to you</p>
                            
                            <div style="display: flex; gap: 2rem;">
                                <div style="cursor: pointer;" onclick="openViewersModal()">
                                    <div style="font-size: 1.5rem; font-weight: 700; color: var(--text-main);">${profileViewCount != null ? profileViewCount : 0}</div>
                                    <div style="font-size: 0.85rem; color: var(--text-muted);">Profile views</div>
                                </div>
                                <div>
                                    <div style="font-size: 1.5rem; font-weight: 700; color: var(--text-main);">${postCount != null ? postCount : 0}</div>
                                    <div style="font-size: 0.85rem; color: var(--text-muted);">Post impressions</div>
                                </div>
                            </div>
                        </div>
                        <button class="btn btn-outline btn-sm" onclick="openViewersModal()">See who viewed</button>
                    </div>
                </div>
            </div>

            <!-- Viewers Modal -->
            <div id="viewersModal" class="modal" style="display:none; align-items:center; justify-content:center; background:rgba(0,0,0,0.5); z-index:5001;">
                <div class="modal-content card" style="max-width:450px; width:95%; padding:1.5rem;">
                    <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:1.5rem;">
                        <h3 style="margin:0;">Recent Visitors</h3>
                        <span class="close" onclick="closeViewersModal()" style="font-size:1.5rem; cursor:pointer;">&times;</span>
                    </div>
                    <div style="max-height:400px; overflow-y:auto;">
                        <c:choose>
                            <c:when test="${not empty recentProfileViews}">
                                <c:forEach var="view" items="${recentProfileViews}">
                                    <a href="ProfileServlet?id=${view.viewerId}" style="display:flex; gap:1rem; padding:0.75rem; text-decoration:none; color:inherit; border-bottom:1px solid var(--border-color); align-items:center;">
                                        <img src="${view.viewerPhoto}" style="width:40px; height:40px; border-radius:50%; object-fit:cover;">
                                        <div>
                                            <div style="font-weight:600;">${view.viewerName}</div>
                                            <div style="font-size:0.75rem; color:var(--text-muted);">${view.viewerHeadline}</div>
                                            <div style="font-size:0.7rem; color:var(--text-muted);"><fmt:formatDate value="${view.viewTime}" pattern="MMM d, h:mm a" /></div>
                                        </div>
                                    </a>
                                </c:forEach>
                            </c:when>
                            <c:otherwise>
                                <p class="text-muted text-center" style="padding:2rem;">No recent visitors to show.</p>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </div>
            </div>
        </c:if>

        <!-- Professional Sections -->
        <div class="main-container" style="max-width: 935px; margin-top: 1rem; padding: 0 1rem;">
            <!-- About Section -->
            <c:if test="${not empty profileUser.professionalSummary}">
                <div class="card" style="margin-bottom: 1rem; padding: 1.5rem;">
                    <h3 style="margin-bottom: 1rem; border-bottom: 1px solid var(--border-color); padding-bottom: 0.5rem;">About</h3>
                    <div style="line-height: 1.6; color: var(--text-main); white-space: pre-wrap;">${profileUser.professionalSummary}</div>
                </div>
            </c:if>

            <!-- Experience Section -->
            <div class="card" style="margin-bottom: 1rem; padding: 1.5rem;">
                <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 1rem; border-bottom: 1px solid var(--border-color); padding-bottom: 0.5rem;">
                    <h3 style="margin: 0;">Experience</h3>
                    <c:if test="${isSelf}">
                        <button class="btn btn-primary btn-sm" onclick="openAddExperienceModal()" style="min-width: 120px; width: auto !important; white-space: nowrap;"><i class="fas fa-plus"></i> Add Experience</button>
                    </c:if>
                </div>
                <div id="experience-list">
                    <c:choose>
                        <c:when test="${not empty experiences}">
                            <c:forEach var="exp" items="${experiences}">
                                <div class="timeline-item" style="margin-bottom: 1.5rem; position: relative;">
                                    <div style="font-weight: 700; font-size: 1.1rem; color: var(--text-main);">${exp.title}</div>
                                    <div style="font-weight: 500; font-size: 1rem;">${exp.company} • ${exp.location}</div>
                                    <div style="color: var(--text-muted); font-size: 0.9rem; margin: 0.25rem 0;">
                                        <fmt:formatDate value="${exp.startDate}" pattern="MMM yyyy" /> - 
                                        <c:choose>
                                            <c:when test="${exp.current}">Present</c:when>
                                            <c:otherwise><fmt:formatDate value="${exp.endDate}" pattern="MMM yyyy" /></c:otherwise>
                                        </c:choose>
                                    </div>
                                    <div style="margin-top: 0.5rem; line-height: 1.5;">${exp.description}</div>
                                    <c:if test="${isSelf}">
                                        <div style="position: absolute; top: 0; right: 0; display: flex; gap: 0.5rem;">
                                            <button class="action-btn text-muted edit-exp-btn" 
                                                    data-id="${exp.id}"
                                                    data-company="${fn:escapeXml(exp.company)}"
                                                    data-title="${fn:escapeXml(exp.title)}"
                                                    data-location="${fn:escapeXml(exp.location)}"
                                                    data-start="<fmt:formatDate value="${exp.startDate}" pattern="yyyy-MM-dd" />"
                                                    data-end="<fmt:formatDate value="${exp.endDate}" pattern="yyyy-MM-dd" />"
                                                    data-current="${exp.current}"
                                                    data-desc="${fn:escapeXml(exp.description)}"
                                                    onclick="openEditExperienceModal(this)" style="padding: 5px;" title="Edit"><i class="fas fa-edit"></i></button>
                                            <button class="action-btn text-danger" onclick="deleteExperience('${exp.id}')" style="padding: 5px;" title="Delete"><i class="fas fa-trash-alt"></i></button>
                                        </div>
                                    </c:if>
                                </div>
                            </c:forEach>
                        </c:when>
                        <c:otherwise>
                            <p class="text-muted">No experience history shared.</p>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>

            <!-- Education Section -->
            <div class="card" style="margin-bottom: 1rem; padding: 1.5rem;">
                <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 1rem; border-bottom: 1px solid var(--border-color); padding-bottom: 0.5rem;">
                    <h3 style="margin: 0;">Education</h3>
                    <c:if test="${isSelf}">
                        <button class="btn btn-outline btn-sm" onclick="openAddEducationModal()" style="min-width: 120px; width: auto !important; white-space: nowrap;"><i class="fas fa-plus"></i> Add Education</button>
                    </c:if>
                </div>
                <div id="education-list">
                    <c:choose>
                        <c:when test="${not empty educationList}">
                            <c:forEach var="edu" items="${educationList}">
                                <div class="timeline-item" style="position: relative; padding-bottom: 1.5rem;">
                                    <div style="font-weight: 700; font-size: 1.1rem; color: var(--text-main);">${edu.school}</div>
                                    <div style="font-weight: 500; font-size: 1rem;">${edu.degree}, ${edu.fieldOfStudy}</div>
                                    <div style="color: var(--text-muted); font-size: 0.9rem; margin: 0.25rem 0;">
                                        <fmt:formatDate value="${edu.startDate}" pattern="yyyy" /> - 
                                        <c:choose>
                                            <c:when test="${not empty edu.endDate}"><fmt:formatDate value="${edu.endDate}" pattern="yyyy" /></c:when>
                                            <c:otherwise>Present</c:otherwise>
                                        </c:choose>
                                    </div>
                                    <c:if test="${not empty edu.description}">
                                        <div style="margin-top: 0.5rem; line-height: 1.5;">${edu.description}</div>
                                    </c:if>
                                    <c:if test="${isSelf}">
                                        <div style="position: absolute; top: 0; right: 0; display: flex; gap: 0.5rem;">
                                            <button class="action-btn text-muted edit-edu-btn" 
                                                    data-id="${edu.id}"
                                                    data-school="${fn:escapeXml(edu.school)}"
                                                    data-degree="${fn:escapeXml(edu.degree)}"
                                                    data-field="${fn:escapeXml(edu.fieldOfStudy)}"
                                                    data-start="<fmt:formatDate value="${edu.startDate}" pattern="yyyy-MM-dd" />"
                                                    data-end="<fmt:formatDate value="${edu.endDate}" pattern="yyyy-MM-dd" />"
                                                    data-desc="${fn:escapeXml(edu.description)}"
                                                    onclick="openEditEducationModal(this)" style="padding: 5px;" title="Edit"><i class="fas fa-edit"></i></button>
                                            <button class="action-btn text-danger" onclick="deleteEducation('${edu.id}')" style="padding: 5px;" title="Delete"><i class="fas fa-trash-alt"></i></button>
                                        </div>
                                    </c:if>
                                </div>
                            </c:forEach>
                        </c:when>
                        <c:otherwise>
                            <p class="text-muted">No education history shared.</p>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>

            </div>

            <!-- Recommendations Section -->
            <div class="card" style="margin-bottom: 1rem; padding: 1.5rem;">
                <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 1rem; border-bottom: 1px solid var(--border-color); padding-bottom: 0.5rem;">
                    <h3 style="margin: 0;">Recommendations</h3>
                    <c:if test="${not isSelf}">
                        <button class="btn btn-outline btn-sm" onclick="openWriteRecommendationModal()"><i class="fas fa-edit"></i> Write a Recommendation</button>
                    </c:if>
                </div>

                <!-- Pending Recommendations (Only for Owner) -->
                <c:if test="${isSelf && not empty pendingRecommendations}">
                    <div style="background: var(--bg-light); border: 1px solid var(--border-color); border-radius: 8px; padding: 1rem; margin-bottom: 1.5rem;">
                        <h4 style="margin-top: 0; display: flex; align-items: center; gap: 0.5rem;"><i class="fas fa-clock text-warning"></i> Pending Approval</h4>
                        <c:forEach var="prec" items="${pendingRecommendations}">
                            <div class="pending-rec-item" style="border-bottom: 1px solid var(--border-color); padding: 1rem 0;">
                                <div style="display: flex; gap: 1rem; margin-bottom: 0.5rem;">
                                    <img src="${prec.senderPhoto}" style="width: 40px; height: 40px; border-radius: 50%; object-fit: cover;">
                                    <div>
                                        <div style="font-weight: 700;">${prec.senderName}</div>
                                        <div style="font-size: 0.8rem; color: var(--text-muted);">${prec.senderHeadline}</div>
                                    </div>
                                </div>
                                <div style="margin-bottom: 1rem; line-height: 1.5; font-style: italic; color: var(--text-main);">"${prec.text}"</div>
                                <div style="display: flex; gap: 0.5rem;">
                                    <button class="btn btn-primary btn-sm" onclick="acceptRecommendation('${prec.id}')">Accept</button>
                                    <button class="btn btn-outline btn-sm text-danger" onclick="rejectRecommendation('${prec.id}')">Ignore</button>
                                </div>
                            </div>
                        </c:forEach>
                    </div>
                </c:if>

                <div id="recommendations-list">
                    <c:choose>
                        <c:when test="${not empty recommendations}">
                            <c:forEach var="rec" items="${recommendations}">
                                <div class="recommendation-item" style="margin-bottom: 1.5rem; position: relative; border-bottom: 1px solid var(--bg-light); padding-bottom: 1rem;">
                                    <div style="display: flex; gap: 1rem; margin-bottom: 0.75rem;">
                                        <img src="${rec.senderPhoto}" style="width: 50px; height: 50px; border-radius: 50%; object-fit: cover;">
                                        <div>
                                            <div style="font-weight: 700; font-size: 1rem; color: var(--text-main);">${rec.senderName}</div>
                                            <div style="font-size: 0.85rem; color: var(--text-muted);">${rec.senderHeadline}</div>
                                            <div style="font-size: 0.75rem; color: var(--text-muted);"><fmt:formatDate value="${rec.createdAt}" pattern="MMM d, yyyy" /></div>
                                        </div>
                                    </div>
                                    <div style="line-height: 1.6; color: var(--text-main); font-style: italic;">"${rec.text}"</div>
                                </div>
                            </c:forEach>
                        </c:when>
                        <c:otherwise>
                            <p class="text-muted">No recommendations received yet.</p>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>
        </div>

        <div class="ig-tabs">
            <div class="ig-tab active">
                <i class="fas fa-th"></i> POSTS
            </div>
        </div>

        <!-- User Posts Grid -->
        <div class="main-container" style="max-width: 935px; margin-top: 0;">
            <c:choose>
                <c:when test="${canSeePosts}">
                    <c:if test="${empty userPosts}">
                        <div class="card text-center" style="padding: 3rem; width: 100%;">
                            <i class="fas fa-camera fa-3x text-muted mb-3"></i>
                            <h3>No posts yet</h3>
                        </div>
                    </c:if>
                    
                    <div class="profile-grid">
                        <c:forEach var="userPost" items="${userPosts}">
                            <div class="grid-item" onclick="showPostDetail('${userPost.postId}')">
                                <c:if test="${userPost.pinned}">
                                    <div class="grid-pin">
                                        <i class="fas fa-thumbtack"></i>
                                    </div>
                                </c:if>
                                <c:choose>
                                    <c:when test="${not empty userPost.images}">
                                        <c:set var="firstImg" value="${userPost.images[0]}" />
                                        <img src="${firstImg.startsWith('http') ? firstImg : pageContext.request.contextPath.concat('/').concat(firstImg)}" alt="Post thumbnail">
                                    </c:when>
                                    <c:when test="${not empty userPost.image}">
                                        <img src="${userPost.image.startsWith('http') ? userPost.image : pageContext.request.contextPath.concat('/').concat(userPost.image)}" alt="Post thumbnail">
                                    </c:when>
                                    <c:otherwise>
                                        <img src="${pageContext.request.contextPath}/images/placeholder.png" alt="No image">
                                    </c:otherwise>
                                </c:choose>
                                <div class="grid-overlay">
                                    <span><i class="fas fa-heart"></i> ${userPost.likeCount}</span>
                                    <span><i class="fas fa-comment"></i> ${userPost.commentCount}</span>
                                </div>
                            </div>
                        </c:forEach>
                    </div>
                </c:when>
                <c:otherwise>
                    <!-- Private Account Placeholder -->
                    <div class="card text-center" style="padding: 4rem 2rem; width: 100%;">
                        <div style="width: 80px; height: 80px; border: 2px solid var(--text-muted); border-radius: 50%; display: flex; align-items: center; justify-content: center; margin: 0 auto 1.5rem;">
                            <i class="fas fa-lock fa-2x text-muted"></i>
                        </div>
                        <h3 style="margin-bottom: 0.5rem;">This account is private</h3>
                        <p class="text-muted">Follow this account to see their photos and videos.</p>
                    </div>
                </c:otherwise>
            </c:choose>
        </div>
    </div>

    <!-- Post Detail Modal -->
    <div id="postDetailModal" class="modal post-detail-modal">
        <div class="modal-content card" style="max-width: 650px; height: 90vh; display: flex; flex-direction: column;">
            <div class="modal-header" style="padding: 1rem; border-bottom: 1px solid var(--border-color); display: flex; justify-content: space-between; align-items: center;">
                <div style="display:flex; gap:1rem; align-items:center;">
                    <img src="" id="modal-user-avatar" class="post-avatar" style="width:40px; height:40px;">
                    <div>
                        <a href="#" id="modal-user-link" class="post-author" style="text-decoration:none; font-weight:700;"></a>
                        <div id="modal-post-time" class="post-time" style="font-size:0.75rem;"></div>
                    </div>
                </div>
                <div style="display:flex; gap:0.5rem; align-items:center;">
                    <div id="modal-post-options"></div>
                    <span class="close" onclick="closePostDetail()" style="position:static; font-size: 2rem;">&times;</span>
                </div>
            </div>

            <div class="modal-body" style="flex: 1; overflow-y: auto;">
                <div class="post-detail-media" id="modal-image-container" style="background: #000; display: flex; align-items: center; justify-content: center; position: relative;">
                    <!-- Carousel or single image injected here -->
                </div>

                <div style="padding: 1.25rem;">
                    <div id="modal-caption-area" style="margin-bottom: 1rem;">
                        <div id="modal-reactions-display" style="display:flex; gap:0.5rem; flex-wrap:wrap; margin-bottom:1rem;">
                            <!-- Emoji reactions icons go here -->
                        </div>
                        <div id="modal-caption-view">
                            <span id="modal-caption-text" style="font-size: 1rem; line-height: 1.5; white-space: pre-wrap;"></span>
                        </div>
                        <div id="modal-edit-view" style="display:none;">
                            <label style="font-weight:600; font-size: 0.85rem; display:block; margin-bottom:0.5rem;">Edit Aspect Ratio</label>
                            <div style="display:flex; gap:0.75rem; margin-bottom:1rem;">
                                <label class="ratio-btn-sm">
                                    <input type="radio" name="modalEditAspectRatio" value="1/1" style="display:none;" onchange="updateModalEditPreviews()">
                                    <div class="ratio-box-sm" style="aspect-ratio: 1/1; width: 30px; border: 2px solid #ddd; border-radius: 4px; display:flex; align-items:center; justify-content:center; cursor:pointer; font-size:10px;">1:1</div>
                                </label>
                                <label class="ratio-btn-sm">
                                    <input type="radio" name="modalEditAspectRatio" value="16/9" style="display:none;" onchange="updateModalEditPreviews()">
                                    <div class="ratio-box-sm" style="aspect-ratio: 16/9; width: 45px; border: 2px solid #ddd; border-radius: 4px; display:flex; align-items:center; justify-content:center; cursor:pointer; font-size:10px;">16:9</div>
                                </label>
                            </div>

                            <div id="modal-edit-previews" style="display:grid; grid-template-columns: repeat(auto-fill, minmax(80px, 1fr)); gap: 0.5rem; margin-bottom: 1rem;">
                                <!-- Adjustment previews go here -->
                            </div>

                            <label style="font-weight:600; font-size: 0.85rem; display:block; margin-bottom:0.5rem;">Edit Caption</label>
                            <textarea id="modal-edit-input" class="form-input" style="width:100%; min-height:80px; margin-bottom:1rem; font-family:inherit;"></textarea>
                            
                            <div style="display:flex; gap:0.5rem; border-top: 1px solid var(--border-color); padding-top: 1rem;">
                                <button class="btn btn-primary btn-sm" onclick="saveModalEditWithImages()">Save Changes</button>
                                <button class="btn btn-outline btn-sm" onclick="cancelModalEdit()">Cancel</button>
                            </div>
                        </div>
                    </div>

                    <div class="post-stats" style="display:flex; justify-content:space-between; margin-bottom: 1rem;">
                        <span style="font-weight:700;"><span id="modal-like-count">0</span> Likes</span>
                        <span id="modal-comment-count-text">0 Comments</span>
                    </div>

                    <div class="post-actions border-top" style="display:flex; justify-content:space-between; padding: 0.75rem 0;">
                        <button class="action-btn" id="modal-like-btn" onclick="" style="flex:1;"><i class="far fa-heart"></i> Like</button>
                        <button class="action-btn" onclick="document.getElementById('modal-comment-input').focus()" style="flex:1;"><i class="far fa-comment"></i> Comment</button>
                        <button class="action-btn" onclick="openShareModal(window.currentModalPost.postId)" style="flex:1;"><i class="far fa-paper-plane"></i> Share</button>
                    </div>

                    <div id="modal-comments-area" class="border-top" style="padding-top: 1rem;">
                        <h4 style="font-size: 0.9rem; color: var(--text-muted); margin-bottom: 1rem;">Comments</h4>
                        <div id="modal-comments-list">
                            <!-- Comments injected here -->
                        </div>
                    </div>
                </div>
            </div>

            <div class="modal-footer" style="padding: 1rem; border-top: 1px solid var(--border-color); background: var(--bg-white);">
                <form onsubmit="handleModalComment(event)" style="display:flex; width:100%; gap:0.5rem; align-items:center;">
                    <input type="text" id="modal-comment-input" class="form-input" placeholder="Add a comment..." style="flex:9; border:none; background:var(--bg-light); padding:0.65rem 1rem; border-radius:20px; min-width:0;" required>
                    <button type="submit" class="btn btn-primary" style="flex:1; border-radius:20px; padding:0.65rem 0; font-size:0.85rem; white-space:nowrap; min-width:0; display:flex; align-items:center; justify-content:center;">Post</button>
                </form>
            </div>
        </div>
    </div>



    <!-- Follow Modal (Global) -->
    <div id="followModal" class="modal">
        <div class="modal-content card" style="max-width:400px;">
            <span class="close" onclick="closeFollowModal()">&times;</span>
            <h2 id="followModalTitle">Users</h2>
            <div id="followModalContent" style="margin-top:1.5rem; max-height: 400px; overflow-y:auto; padding-right:0.5rem;">
                <div class="text-center text-muted"><i class="fas fa-spinner fa-spin"></i> Loading...</div>
            </div>
        </div>
    </div>

    <!-- Switch CSS -->
    <style>
        .switch { position: relative; display: inline-block; width: 46px; height: 24px; }
        .switch input { opacity: 0; width: 0; height: 0; }
        .slider { position: absolute; cursor: pointer; top: 0; left: 0; right: 0; bottom: 0; background-color: #ccc; transition: .4s; border-radius: 34px; }
        .slider:before { position: absolute; content: ""; height: 18px; width: 18px; left: 3px; bottom: 3px; background-color: white; transition: .4s; border-radius: 50%; }
        input:checked + .slider { background-color: var(--primary-color); }
        input:checked + .slider:before { transform: translateX(22px); }
        .setting-item { transition: background 0.2s; }
    </style>
    
    <script>
        const contextPath = '${pageContext.request.contextPath}';
        window.contextPath = contextPath;
        window.loggedInUserId = parseInt("${sessionScope.user.userId}");
        window.currentProfileUserId = "${profileUser.userId}";

        function showProfilePhoto(imgSrc) {
            const modal = document.getElementById('profilePhotoModal');
            const img = document.getElementById('fullProfilePhoto');
            img.src = imgSrc;
            modal.style.display = 'flex';
        }

        function closeProfilePhoto() {
            document.getElementById('profilePhotoModal').style.display = 'none';
        }

        function showFollowModal(type, targetId) {
            const title = document.getElementById('followModalTitle');
            const container = document.getElementById('followModalContent');
            
            title.innerText = type === 'followers' ? 'Followers' : 'Following';
            container.innerHTML = '<div class="text-center text-muted" style="padding:2rem;"><i class="fas fa-spinner fa-spin fa-2x"></i></div>';
            modal.style.display = 'flex';
            
            const actionUrl = type === 'followers' ? 'getFollowers' : 'getFollowing';
            
            fetch(contextPath + '/InteractionServlet', {
                method: 'POST',
                headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                body: 'action=' + actionUrl + '&targetId=' + targetId
            })
            .then(res => res.json())
            .then(users => {
                if(users.length === 0) {
                    container.innerHTML = '<div class="text-center text-muted" style="padding:2rem;">No users found.</div>';
                    return;
                }
                
                let html = '';
                users.forEach(u => {
                    const avatar = getImageUrl(u.photo || 'images/default-avatar.png');
                    html += '<div style="display:flex; align-items:center; gap:1rem; padding:0.5rem 0; border-bottom:1px solid #eee;">' +
                                '<img src="' + avatar + '" style="width:40px; height:40px; border-radius:50%; object-fit:cover;">' +
                                '<div style="flex:1;">' +
                                    '<a href="' + contextPath + '/ProfileServlet?id=' + u.userId + '" style="font-weight:600; color:var(--text-color); text-decoration:none;">' + u.name + '</a>' +
                                    '<div style="font-size:0.85rem; color:var(--text-muted);">@' + u.username + '</div>' +
                                '</div>' +
                            '</div>';
                });
                container.innerHTML = html;
            })
            .catch(err => {
                container.innerHTML = '<div class="text-danger text-center" style="padding:2rem;">Failed to load users.</div>';
            });
        }
    </script>

    <!-- Experience Modal -->
    <div id="experienceModal" class="modal" style="display:none; align-items:center; justify-content:center; background:rgba(0,0,0,0.5); z-index:5001;">
        <div class="modal-content card" style="max-width:500px; width:95%; padding:1.5rem;">
            <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:1.5rem;">
                <h3 id="expModalTitle" style="margin:0;">Add Experience</h3>
                <span class="close" onclick="closeAddExperienceModal()" style="font-size:1.5rem; cursor:pointer;">&times;</span>
            </div>
            <form id="experienceForm" onsubmit="submitExperience(event)">
                <input type="hidden" name="id" id="expId">
                <div class="mb-3">
                    <label class="form-label">Title</label>
                    <input type="text" name="title" id="expTitle" class="form-input" placeholder="e.g. Software Engineer" required>
                </div>
                <div class="mb-3">
                    <label class="form-label">Company</label>
                    <input type="text" name="company" id="expCompany" class="form-input" placeholder="e.g. Google" required>
                </div>
                <div class="mb-3">
                    <label class="form-label">Location</label>
                    <input type="text" name="location" id="expLocation" class="form-input" placeholder="e.g. Remote / New York">
                </div>
                <div class="form-grid mb-3">
                    <div>
                        <label class="form-label">Start Date</label>
                        <input type="date" name="startDate" id="expStartDate" class="form-input" required>
                    </div>
                    <div>
                        <label class="form-label">End Date</label>
                        <input type="date" name="endDate" class="form-input" id="exp-end-date">
                        <label style="display:flex; align-items:center; gap:0.5rem; margin-top:0.5rem; font-size:0.85rem;">
                            <input type="checkbox" name="isCurrent" id="expIsCurrent" value="true" onchange="document.getElementById('exp-end-date').disabled = this.checked"> I currently work here
                        </label>
                    </div>
                </div>
                <div class="mb-3">
                    <label class="form-label">Description</label>
                    <textarea name="description" id="expDescription" class="form-input" style="min-height:100px;"></textarea>
                </div>
                <button type="submit" class="btn btn-primary w-100">Save Experience</button>
            </form>
        </div>
    </div>

    <!-- Education Modal -->
    <div id="educationModal" class="modal" style="display:none; align-items:center; justify-content:center; background:rgba(0,0,0,0.5); z-index:5001;">
        <div class="modal-content card" style="max-width:500px; width:95%; padding:1.5rem;">
            <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:1.5rem;">
                <h3 id="eduModalTitle" style="margin:0;">Add Education</h3>
                <span class="close" onclick="closeAddEducationModal()" style="font-size:1.5rem; cursor:pointer;">&times;</span>
            </div>
            <form id="educationForm" onsubmit="submitEducation(event)">
                <input type="hidden" name="id" id="eduId">
                <div class="mb-3">
                    <label class="form-label">School / University</label>
                    <input type="text" name="school" id="eduSchool" class="form-input" placeholder="e.g. Harvard University" required>
                </div>
                <div class="mb-3">
                    <label class="form-label">Degree</label>
                    <input type="text" name="degree" id="eduDegree" class="form-input" placeholder="e.g. Bachelor's" required>
                </div>
                <div class="mb-3">
                    <label class="form-label">Field of Study</label>
                    <input type="text" name="fieldOfStudy" id="eduField" class="form-input" placeholder="e.g. Computer Science">
                </div>
                <div class="form-grid mb-3">
                    <div>
                        <label class="form-label">Start Date</label>
                        <input type="date" name="startDate" id="eduStartDate" class="form-input" required>
                    </div>
                    <div>
                        <label class="form-label">End Date (or expected)</label>
                        <input type="date" name="endDate" id="eduEndDate" class="form-input">
                    </div>
                </div>
                <div class="mb-3">
                    <label class="form-label">Description</label>
                    <textarea name="description" id="eduDescription" class="form-input" style="min-height:100px;"></textarea>
                </div>
                <button type="submit" class="btn btn-primary w-100">Save Education</button>
            </form>
        </div>
    </div>

    <!-- Profile Photo View Modal -->
    <div id="profilePhotoModal" class="modal" onclick="closeProfilePhoto()" style="display: none; background: rgba(0,0,0,0.9); z-index: 2000;">
        <span class="close" onclick="closeProfilePhoto()" style="color: white; top: 20px; right: 30px; font-size: 40px;">&times;</span>
        <div class="modal-content" style="background: none; border: none; box-shadow: none; display: flex; justify-content: center; align-items: center; max-width: 90vw; max-height: 90vh;">
            <img id="fullProfilePhoto" src="" style="max-width: 100%; max-height: 90vh; border-radius: 8px; object-fit: contain;">
        </div>
    </div>

    <!-- Add Skill Modal -->
    <div id="addSkillModal" class="modal" style="display:none; align-items:center; justify-content:center; background:rgba(0,0,0,0.5); z-index:5001;">
        <div class="modal-content card" style="max-width:450px; width:95%; padding:1.5rem;">
            <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:1.5rem;">
                <h3 style="margin:0;">Add professional skill</h3>
                <span class="close" onclick="closeAddSkillModal()" style="font-size:1.5rem; cursor:pointer;">&times;</span>
            </div>
            <div class="mb-3">
                <input type="text" id="skillSearchInput" class="form-input" placeholder="Search for a skill (e.g. Java, Leadership)" oninput="handleSkillSearch(this.value)">
            </div>
            <div id="skillSearchResults" style="max-height:300px; overflow-y:auto; border:1px solid var(--border-color); border-radius:8px;">
                <!-- Search results will appear here -->
            </div>
            <div style="margin-top:1rem;" class="text-muted small">
                Choose from our professional library to help others endorse your expertise.
            </div>
        </div>
    </div>

    <!-- Write Recommendation Modal -->
    <div id="writeRecommendationModal" class="modal" style="display:none; align-items:center; justify-content:center; background:rgba(0,0,0,0.5); z-index:5001;">
        <div class="modal-content card" style="max-width:550px; width:95%; padding:1.5rem;">
            <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:1.5rem;">
                <h3 style="margin:0;">Write a recommendation</h3>
                <span class="close" onclick="closeWriteRecommendationModal()" style="font-size:1.5rem; cursor:pointer;">&times;</span>
            </div>
            <div style="display:flex; gap:1rem; margin-bottom:1.5rem; background:var(--bg-light); padding:1rem; border-radius:8px;">
                <img src="${profileUser.profilePhoto}" style="width:50px; height:50px; border-radius:50%; object-fit:cover;">
                <div>
                    <div style="font-weight:700;">${profileUser.name}</div>
                    <div style="font-size:0.85rem; color:var(--text-muted);">${profileUser.headline}</div>
                </div>
            </div>
            <div class="mb-3">
                <label class="form-label">Your Recommendation</label>
                <textarea id="recommendationText" class="form-input" style="min-height:150px;" placeholder="Write a few sentences about your professional experience with ${profileUser.name}..."></textarea>
            </div>
            <div style="display:flex; gap:1rem;">
                <button class="btn btn-primary" style="flex:1;" onclick="submitRecommendation()">Submit for Approval</button>
                <button class="btn btn-outline" onclick="closeWriteRecommendationModal()">Cancel</button>
            </div>
        </div>
    </div>

    <!-- Connect with Message Modal -->
    <div id="connectModal" class="modal" style="display:none; align-items:center; justify-content:center; background:rgba(0,0,0,0.5); z-index:5001;">
        <div class="modal-content card" style="max-width:500px; width:95%; padding:1.5rem;">
            <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:1.5rem;">
                <h3 style="margin:0;">Connect with ${profileUser.name}</h3>
                <span class="close" onclick="closeConnectModal()" style="font-size:1.5rem; cursor:pointer;">&times;</span>
            </div>
            <p class="text-muted" style="margin-bottom:1rem;">Include a personalized note to introduce yourself and explain why you'd like to connect.</p>
            <div class="mb-3">
                <textarea id="connectNote" class="form-input" style="min-height:120px;" placeholder="Ex: Hi ${profileUser.name}, I'm interested in your work at ${not empty experiences ? experiences[0].company : 'your firm'} and would love to connect."></textarea>
            </div>
            <div style="display:flex; gap:1rem;">
                <button class="btn btn-primary" style="flex:1;" onclick="submitConnectRequest()">Send with Note</button>
                <button class="btn btn-outline" style="flex:1;" onclick="submitConnectRequest(true)">Send without Note</button>
            </div>
        </div>
    </div>
    <script>
        window.contextPath = '${pageContext.request.contextPath}';
        window.currentProfileUserId = '${profileUser.userId}';

        // Connect JS
        function openConnectModal() {
            document.getElementById('connectModal').style.display = 'flex';
        }
        function closeConnectModal() {
            document.getElementById('connectModal').style.display = 'none';
        }

        // Viewers Modal JS
        function openViewersModal() {
            const modal = document.getElementById('viewersModal');
            if(modal) modal.style.display = 'flex';
        }
        function closeViewersModal() {
            const modal = document.getElementById('viewersModal');
            if(modal) modal.style.display = 'none';
        }
        function submitConnectRequest(withoutNote = false) {
            const note = withoutNote ? '' : document.getElementById('connectNote').value;
            const btn = document.getElementById('follow-action-btn');
            
            fetch(contextPath + '/FriendServlet', {
                method: 'POST',
                headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                body: 'action=send&friendId=' + currentProfileUserId + '&message=' + encodeURIComponent(note)
            }).then(res => {
                if(res.ok) {
                    btn.innerText = 'Requested';
                    btn.classList.replace('btn-primary', 'btn-outline');
                    btn.style.color = 'var(--text-muted)';
                    btn.onclick = () => cancelFollowRequest(currentProfileUserId, btn);
                    closeConnectModal();
                } else alert("Failed to send request.");
            });
        }

        function previewAvatar(input) {
            if (input.files && input.files[0]) {
                const reader = new FileReader();
                reader.onload = e => {
                    document.getElementById('avatarPreview').src = e.target.result;
                };
                reader.readAsDataURL(input.files[0]);
            }
        }

        // Professional Timeline JS
        function openAddExperienceModal() {
            document.getElementById('experienceForm').reset();
            document.getElementById('expId').value = '';
            document.getElementById('expModalTitle').innerText = 'Add Experience';
            document.getElementById('experienceModal').style.display = 'flex';
        }
        function openEditExperienceModal(btn) {
            const d = btn.dataset;
            document.getElementById('expId').value = d.id;
            document.getElementById('expCompany').value = d.company;
            document.getElementById('expTitle').value = d.title;
            document.getElementById('expLocation').value = d.location;
            document.getElementById('expStartDate').value = d.start;
            document.getElementById('exp-end-date').value = d.end || '';
            const isCurrent = d.current === 'true';
            document.getElementById('expIsCurrent').checked = isCurrent;
            document.getElementById('exp-end-date').disabled = isCurrent;
            document.getElementById('expDescription').value = d.desc;
            document.getElementById('expModalTitle').innerText = 'Edit Experience';
            document.getElementById('experienceModal').style.display = 'flex';
        }
        function closeAddExperienceModal() { document.getElementById('experienceModal').style.display = 'none'; }
        
        function openAddEducationModal() {
            document.getElementById('educationForm').reset();
            document.getElementById('eduId').value = '';
            document.getElementById('eduModalTitle').innerText = 'Add Education';
            document.getElementById('educationModal').style.display = 'flex';
        }
        function openEditEducationModal(btn) {
            const d = btn.dataset;
            document.getElementById('eduId').value = d.id;
            document.getElementById('eduSchool').value = d.school;
            document.getElementById('eduDegree').value = d.degree;
            document.getElementById('eduField').value = d.field;
            document.getElementById('eduStartDate').value = d.start;
            document.getElementById('eduEndDate').value = d.end || '';
            document.getElementById('eduDescription').value = d.desc;
            document.getElementById('eduModalTitle').innerText = 'Edit Education';
            document.getElementById('educationModal').style.display = 'flex';
        }
        function closeAddEducationModal() { document.getElementById('educationModal').style.display = 'none'; }

        function submitExperience(e) {
            e.preventDefault();
            const formData = new FormData(e.target);
            const params = new URLSearchParams();
            const expId = document.getElementById('expId').value;
            params.append('action', expId ? 'updateExperience' : 'addExperience');
            formData.forEach((value, key) => params.append(key, value));

            fetch(contextPath + '/ProfessionalProfileServlet', {
                method: 'POST',
                headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                body: params.toString()
            }).then(res => res.text()).then(data => {
                if(data === 'success') location.reload();
                else alert("Failed to save experience: " + data);
            });
        }

        function deleteExperience(id) {
            if(!confirm("Are you sure you want to delete this experience?")) return;
            fetch(contextPath + '/ProfessionalProfileServlet', {
                method: 'POST',
                headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                body: 'action=deleteExperience&id=' + id
            }).then(res => res.text()).then(data => {
                if(data === 'success') location.reload();
                else alert("Failed to delete experience.");
            });
        }

        function submitEducation(e) {
            e.preventDefault();
            const formData = new FormData(e.target);
            const params = new URLSearchParams();
            const eduId = document.getElementById('eduId').value;
            params.append('action', eduId ? 'updateEducation' : 'addEducation');
            formData.forEach((value, key) => params.append(key, value));

            fetch(contextPath + '/ProfessionalProfileServlet', {
                method: 'POST',
                headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                body: params.toString()
            }).then(res => res.text()).then(data => {
                if(data === 'success') location.reload();
                else alert("Failed to save education.");
            });
        }

        function deleteEducation(id) {
            if(!confirm("Are you sure you want to delete this education?")) return;
            fetch(contextPath + '/ProfessionalProfileServlet', {
                method: 'POST',
                headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                body: 'action=deleteEducation&id=' + id
            }).then(res => res.text()).then(data => {
                if(data === 'success') location.reload();
                else alert("Failed to delete education.");
            });
        }

        function updatePrivacy(isPrivate) {
            const statusText = document.getElementById('privacyStatus');
            fetch(contextPath + '/SettingsServlet', {
                method: 'POST',
                headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                body: 'action=privacy&isPrivate=' + isPrivate
            }).then(res => res.text()).then(data => {
                if(data === 'success') {
                    statusText.innerText = isPrivate ? "Private Account" : "Public Account";
                } else {
                    alert("Failed to update privacy.");
                    document.getElementById('privacyToggle').checked = !isPrivate;
                }
            });
        }

        function updatePassword(e) {
            e.preventDefault();
            const currentPassword = document.getElementById('currentPassword').value;
            const newPassword = document.getElementById('newPassword').value;
            const msgDiv = document.getElementById('passwordMessage');
            
            msgDiv.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Updating...';
            msgDiv.className = 'text-muted';

            fetch(contextPath + '/SettingsServlet', {
                method: 'POST',
                headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                body: 'action=password&currentPassword=' + encodeURIComponent(currentPassword) + '&newPassword=' + encodeURIComponent(newPassword)
            }).then(res => res.text()).then(data => {
                if(data === 'success') {
                    msgDiv.innerText = 'Password updated successfully!';
                    msgDiv.className = 'text-success';
                    document.getElementById('passwordForm').reset();
                } else {
                    msgDiv.innerText = data;
                    msgDiv.className = 'text-danger';
                }
            });
        }

        function showProfilePhoto(src) {
            document.getElementById('fullProfilePhoto').src = src;
            document.getElementById('profilePhotoModal').style.display = 'flex';
        }

        function closeProfilePhoto() {
            document.getElementById('profilePhotoModal').style.display = 'none';
        }

        // Skills JS
        function openAddSkillModal() {
            document.getElementById('addSkillModal').style.display = 'flex';
        }
        function closeAddSkillModal() {
            document.getElementById('addSkillModal').style.display = 'none';
            document.getElementById('skillSearchInput').value = '';
            document.getElementById('skillSearchResults').innerHTML = '';
        }

        let skillSearchTimeout;
        function handleSkillSearch(query) {
            clearTimeout(skillSearchTimeout);
            if(query.length < 2) {
                document.getElementById('skillSearchResults').innerHTML = '';
                return;
            }
            skillSearchTimeout = setTimeout(() => {
                fetch(contextPath + '/ProfessionalProfileServlet?action=searchSkills&query=' + encodeURIComponent(query))
                    .then(res => res.json())
                    .then(skills => {
                        const results = document.getElementById('skillSearchResults');
                        results.innerHTML = '';
                        skills.forEach(s => {
                            const div = document.createElement('div');
                            div.className = 'search-result-item';
                            div.style = 'padding:0.75rem; cursor:pointer; border-bottom:1px solid var(--border-color);';
                            div.innerHTML = '<strong>' + s.name + '</strong>';
                            div.onclick = () => addSkill(s.id);
                            results.appendChild(div);
                        });
                        if(skills.length === 0) {
                            results.innerHTML = '<div style="padding:0.75rem;" class="text-muted">No matching skills found.</div>';
                        }
                    });
            }, 300);
        }

        function addSkill(skillId) {
            fetch(contextPath + '/ProfessionalProfileServlet', {
                method: 'POST',
                headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                body: 'action=addSkill&skillId=' + skillId
            }).then(res => res.text()).then(data => {
                if(data === 'success') location.reload();
                else alert("Failed to add skill. Maybe you already added it?");
            });
        }

        function removeSkill(skillId) {
            if(!confirm("Are you sure you want to remove this skill?")) return;
            fetch(contextPath + '/ProfessionalProfileServlet', {
                method: 'POST',
                headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                body: 'action=removeSkill&skillId=' + skillId
            }).then(res => res.text()).then(data => {
                if(data === 'success') location.reload();
                else alert("Failed to remove skill.");
            });
        }

        function toggleEndorsement(userSkillId, btn) {
            fetch(contextPath + '/ProfessionalProfileServlet', {
                method: 'POST',
                headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                body: 'action=toggleEndorsement&userSkillId=' + userSkillId
            }).then(res => res.text()).then(data => {
                if(data === 'success') {
                    const countSpan = btn.nextElementSibling;
                    let count = parseInt(countSpan.innerText);
                    if(btn.classList.contains('active')) {
                        btn.classList.remove('active');
                        btn.style.color = 'var(--text-muted)';
                        countSpan.innerText = count - 1;
                    } else {
                        btn.classList.add('active');
                        btn.style.color = 'var(--primary-color)';
                        countSpan.innerText = count + 1;
                    }
                } else {
                    alert("Failed to update endorsement.");
                }
            });
        }

        // Recommendations JS
        function openWriteRecommendationModal() {
            document.getElementById('writeRecommendationModal').style.display = 'flex';
        }
        function closeWriteRecommendationModal() {
            document.getElementById('writeRecommendationModal').style.display = 'none';
        }
        function submitRecommendation() {
            const text = document.getElementById('recommendationText').value;
            if(!text.trim()) return;
            fetch(contextPath + '/ProfessionalProfileServlet', {
                method: 'POST',
                headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                body: 'action=submitRecommendation&receiverId=' + currentProfileUserId + '&text=' + encodeURIComponent(text)
            }).then(res => res.text()).then(data => {
                if(data === 'success') {
                    alert("Recommendation submitted for approval!");
                    closeWriteRecommendationModal();
                } else alert("Failed to submit recommendation.");
            });
        }
        function acceptRecommendation(id) {
            updateRecommendationStatus(id, 'ACCEPTED');
        }
        function rejectRecommendation(id) {
            if(confirm("Ignore this recommendation?")) {
                updateRecommendationStatus(id, 'REJECTED');
            }
        }
        function updateRecommendationStatus(id, status) {
            fetch(contextPath + '/ProfessionalProfileServlet', {
                method: 'POST',
                headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                body: 'action=updateRecommendation&id=' + id + '&status=' + status
            }).then(res => res.text()).then(data => {
                if(data === 'success') location.reload();
                else alert("Failed to update status.");
            });
        }
    </script>
    <script src="${pageContext.request.contextPath}/js/app_v2.js?v=20260317"></script>

</body>
</html>
