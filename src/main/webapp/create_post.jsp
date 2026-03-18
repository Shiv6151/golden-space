<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Create Post - SocialConnect</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="css/styles.css?v=<%= System.currentTimeMillis() %>">
    <link rel="stylesheet" href="css/app.css?v=<%= System.currentTimeMillis() %>">
    <style>
        .create-container { max-width: 600px; margin: 3rem auto; padding: 0 1rem; }
        .image-preview { width: 100%; max-height: 400px; object-fit: contain; border-radius: 8px; margin-top: 1rem; display: none; }
        .file-upload-wrapper { position: relative; overflow: hidden; display: inline-block; cursor: pointer; }
        .file-upload-wrapper input[type=file] { font-size: 100px; position: absolute; left: 0; top: 0; opacity: 0; cursor: pointer; }
    </style>
</head>
<body>
    <jsp:include page="components/navbar.jsp" />

    <div class="create-container">
        <div class="card p-4">
            <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom: 2rem;">
                <h2 style="margin:0;">Create New Post</h2>
                <a href="FeedServlet" class="btn btn-outline btn-sm"><i class="fas fa-times"></i></a>
            </div>
            
            <form action="PostServlet" method="POST" enctype="multipart/form-data" id="postForm">
                <div class="form-group mb-3">
                    <label style="font-weight:600; display:block; margin-bottom:0.5rem;">Select Aspect Ratio</label>
                    <div style="display:flex; gap:1rem;">
                        <label class="ratio-btn">
                            <input type="radio" name="aspectRatio" value="1/1" style="display:none;">
                            <div class="ratio-box" style="aspect-ratio: 1/1; width: 40px; border: 2px solid #ddd; border-radius: 4px; display:flex; align-items:center; justify-content:center; cursor:pointer;">1:1</div>
                        </label>
                        <label class="ratio-btn">
                            <input type="radio" name="aspectRatio" value="16/9" checked style="display:none;">
                            <div class="ratio-box active" style="aspect-ratio: 16/9; width: 60px; border: 2px solid var(--primary-color); border-radius: 4px; display:flex; align-items:center; justify-content:center; cursor:pointer; background:rgba(255, 71, 87, 0.1);">16:9</div>
                        </label>
                    </div>
                </div>

                <div class="form-group mb-3">
                    <label style="font-weight:600; display:block; margin-bottom:0.5rem;">What's on your mind?</label>
                    <textarea class="form-input" name="content" id="postContent" rows="3" placeholder="Write something here..." style="resize:none;"></textarea>
                </div>
                
                <div class="form-group mb-4">
                    <div class="file-upload-wrapper" style="width: 100%; text-align: center; border: 2px dashed #ddd; padding: 2rem; border-radius: 12px; transition: all 0.3s; position:relative;" id="dropZone">
                        <i class="fas fa-images fa-3x mb-3" style="color: #ccc;"></i>
                        <div style="font-weight: 500; color: #666;">Click to upload photos</div>
                        <small class="text-muted" style="display:block; margin-top:0.5rem;">Adjust each photo after selection</small>
                        <input type="file" id="imageInput" accept="image/*" multiple style="position:absolute; top:0; left:0; width:100%; height:100%; opacity:0; cursor:pointer;">
                    </div>
                </div>
                
                <div id="previews-container" style="display:grid; grid-template-columns: repeat(auto-fill, minmax(120px, 1fr)); gap: 1rem; margin-bottom: 2rem; min-height: 50px;">
                    <!-- Previews go here -->
                </div>
                
                <div style="text-align: right;">
                    <button type="submit" id="submitBtn" class="btn btn-primary btn-block" style="width:100%; padding: 1rem; font-size: 1.1rem;">
                        <i class="fas fa-paper-plane mr-2"></i> Post to Feed
                    </button>
                </div>
            </form>
        </div>
    </div>

    <!-- Cropping Modal -->
    <div id="cropModal" class="modal" style="display:none; align-items:center; justify-content:center; background:rgba(0,0,0,0.85); z-index:2000;">
        <div class="modal-content card" style="max-width:500px; width:95%; padding:1.5rem;">
            <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:1.5rem;">
                <h3 style="margin:0;">Adjust Image</h3>
                <span class="close" onclick="closeCropModal()" style="font-size:1.5rem; cursor:pointer;">&times;</span>
            </div>
            
            <div id="cropContainer" style="width:100%; background:#000; overflow:hidden; border-radius:8px; position:relative; cursor:move; user-select:none;">
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
                <button type="button" class="btn btn-primary w-100" onclick="saveCrop()">Apply Adjustment</button>
            </div>
        </div>
    </div>

    <style>
        .ratio-box.active {
            border-color: var(--primary-color) !important;
            color: var(--primary-color);
            font-weight: 700;
        }
        .preview-item {
            position: relative;
            border-radius: 8px;
            overflow: hidden;
            background: #eee;
            cursor: pointer;
        }
        .preview-item img {
            width: 100%;
            height: 100%;
            object-fit: cover;
        }
        .preview-item:hover .adjust-overlay {
            opacity: 1;
        }
        .adjust-overlay {
            position: absolute;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background: rgba(0,0,0,0.4);
            display: flex;
            align-items: center;
            justify-content: center;
            opacity: 0;
            transition: opacity 0.3s;
            color: white;
            font-size: 0.8rem;
            font-weight: 600;
        }
        .remove-btn {
            position: absolute;
            top: 5px;
            right: 5px;
            background: rgba(0,0,0,0.5);
            color: white;
            border: none;
            border-radius: 50%;
            width: 24px;
            height: 24px;
            cursor: pointer;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 0.8rem;
            z-index: 5;
        }
    </style>

    <!-- Debug Log -->
    <div id="debug-log" style="position:fixed; bottom:0; left:0; width:100%; background:rgba(0,0,0,0.9); color:#00ff00; font-family:monospace; font-size:10px; max-height:100px; overflow-y:auto; z-index:9999; padding:5px; pointer-events:none; display:none;"></div>

    <style>
        .ratio-btn input:checked + .ratio-box {
            border-color: var(--primary-color) !important;
            background: rgba(255, 71, 87, 0.1);
            color: var(--primary-color);
        }
        .preview-item {
            position: relative;
            border-radius: 8px;
            overflow: hidden;
            background: #f8f9fa;
            border: 1px solid #ddd;
            display: flex;
            flex-direction: column;
            transition: all 0.2s;
            min-height: 150px;
        }
        .preview-viewport {
            width: 100%;
            height: 100%;
            position: relative;
            overflow: hidden;
            background: #000;
            flex-grow: 1;
        }
        .preview-viewport img {
            width: 100%;
            height: 100%;
            object-fit: cover;
            cursor: pointer;
        }
        .preview-actions {
            padding: 8px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            background: white;
            border-top: 1px solid #eee;
        }
        .remove-btn-new {
            color: #ff4757;
            background: none;
            border: none;
            cursor: pointer;
            font-size: 1rem;
        }
    </style>

    <script>
        const debugLog = document.getElementById('debug-log');
        function log(msg) {
            console.log(msg);
            const entry = document.createElement('div');
            entry.textContent = '[' + new Date().toLocaleTimeString() + '] ' + msg;
            debugLog.appendChild(entry);
            debugLog.scrollTop = debugLog.scrollHeight;
        }

        const imageInput = document.getElementById('imageInput');
        const previewsContainer = document.getElementById('previews-container');
        const ratioBtns = document.querySelectorAll('input[name="aspectRatio"]');
        const cropModal = document.getElementById('cropModal');
        const cropImg = document.getElementById('cropImg');
        const cropContainer = document.getElementById('cropContainer');
        const zoomSlider = document.getElementById('zoomSlider');
        const postForm = document.getElementById('postForm');

        let preparedFiles = []; 
        let currentCropId = null;
        let isDragging = false;
        let startX, startY;
        let currentX = 0, currentY = 0;
        let scale = 1;

        imageInput.addEventListener('change', function() {
            const files = Array.from(this.files);
            log("Files selected: " + files.length);
            
            files.forEach((file) => {
                const objectUrl = URL.createObjectURL(file);
                const id = Date.now() + Math.random();
                const item = {
                    id: id,
                    originalSrc: objectUrl,
                    blob: file, 
                    previewBlob: objectUrl,
                    aspectRatio: document.querySelector('input[name="aspectRatio"]:checked').value,
                    x: 0, y: 0, s: 1, adjusted: false
                };
                preparedFiles.push(item);
            });
            renderPreviews();
            this.value = ''; 
        });

        function renderPreviews() {
            previewsContainer.innerHTML = '';
            const globalRatio = document.querySelector('input[name="aspectRatio"]:checked').value;
            log("Rendering previews at: " + globalRatio);
            
            preparedFiles.forEach((item, index) => {
                const div = document.createElement('div');
                div.className = 'preview-item';
                div.style.aspectRatio = globalRatio;

                // Fixed: Using string concatenation to avoid JSP EL issues
                let html = '<div class="preview-viewport" onclick="openCropModal(' + index + ')">';
                html += '<img src="' + item.previewBlob + '">';
                html += '<div style="position:absolute; top:8px; right:8px; background:rgba(0,0,0,0.6); color:white; padding:4px 8px; border-radius:4px; font-size:10px;">';
                html += '<i class="fas fa-expand"></i> Adjust</div></div>';
                html += '<div class="preview-actions">';
                html += '<span style="font-size:11px; font-weight:600; color:#666;">Image ' + (index + 1) + (item.adjusted ? ' (Adjusted)' : '') + '</span>';
                html += '<button type="button" class="remove-btn-new" onclick="removeImage(' + index + ', event)"><i class="fas fa-trash"></i></button>';
                html += '</div>';
                
                div.innerHTML = html;
                previewsContainer.appendChild(div);
            });
            
            if (preparedFiles.length === 0) log("No previews to render.");
        }

        function removeImage(index, e) {
            e.stopPropagation();
            const item = preparedFiles[index];
            if (item.originalSrc.startsWith('blob:')) URL.revokeObjectURL(item.originalSrc);
            preparedFiles.splice(index, 1);
            renderPreviews();
        }

        function openCropModal(index) {
            const item = preparedFiles[index];
            currentCropId = index;
            log("Opening adjustment for index " + index);
            
            cropModal.style.display = 'flex';
            cropContainer.style.aspectRatio = item.aspectRatio;

            cropImg.onload = () => {
                log("Img natural size: " + cropImg.naturalWidth + "x" + cropImg.naturalHeight);
                const containerRect = cropContainer.getBoundingClientRect();
                cropImg.style.width = containerRect.width + 'px';
                cropImg.style.height = 'auto';
                
                // Centering logic
                if (item.adjusted) {
                    currentX = item.x;
                    currentY = item.y;
                    scale = item.s;
                } else {
                    currentX = 0;
                    // wait for height to render
                    setTimeout(() => {
                        currentY = (containerRect.height - cropImg.offsetHeight) / 2;
                        updateCropTransform();
                    }, 10);
                    scale = 1;
                }
                
                zoomSlider.value = scale;
                updateCropTransform();
            };

            cropImg.src = item.originalSrc;
            if (cropImg.complete) cropImg.onload();
        }

        function closeCropModal() {
            cropModal.style.display = 'none';
        }

        function startDrag(e) {
            isDragging = true;
            const clientX = e.touches ? e.touches[0].clientX : e.clientX;
            const clientY = e.touches ? e.touches[0].clientY : e.clientY;
            startX = clientX - currentX;
            startY = clientY - currentY;
            if (e.type === 'touchstart') e.preventDefault();
        }

        function doDrag(e) {
            if (!isDragging) return;
            const clientX = e.touches ? e.touches[0].clientX : e.clientX;
            const clientY = e.touches ? e.touches[0].clientY : e.clientY;
            currentX = clientX - startX;
            currentY = clientY - startY;
            updateCropTransform();
            if (e.type === 'touchmove') e.preventDefault();
        }

        cropContainer.addEventListener('mousedown', startDrag);
        cropContainer.addEventListener('touchstart', startDrag, { passive: false });
        window.addEventListener('mousemove', doDrag);
        window.addEventListener('touchmove', doDrag, { passive: false });
        window.addEventListener('mouseup', () => isDragging = false);
        window.addEventListener('touchend', () => isDragging = false);

        zoomSlider.addEventListener('input', () => {
            scale = parseFloat(zoomSlider.value);
            updateCropTransform();
        });

        function updateCropTransform() {
            cropImg.style.transform = 'translate(' + currentX + 'px, ' + currentY + 'px) scale(' + scale + ')';
        }

        function saveCrop() {
            log("Generating crop canvas...");
            const item = preparedFiles[currentCropId];
            
            const canvas = document.createElement('canvas');
            const [rw, rh] = item.aspectRatio.split('/');
            canvas.width = 1080;
            canvas.height = 1080 * (rh / rw);
            
            const ctx = canvas.getContext('2d');
            const containerWidth = cropContainer.offsetWidth;
            const drawScale = 1080 / containerWidth;
            
            ctx.fillStyle = '#000';
            ctx.fillRect(0, 0, canvas.width, canvas.height);
            
            const img = new Image();
            img.onload = () => {
                const dw = cropImg.offsetWidth * scale * drawScale;
                const dh = cropImg.offsetHeight * scale * drawScale;
                
                ctx.drawImage(img, currentX * drawScale, currentY * drawScale, dw, dh);
                
                item.previewBlob = canvas.toDataURL('image/jpeg', 0.9);
                item.x = currentX; item.y = currentY; item.s = scale;
                item.adjusted = true;
                
                log("Adjustment applied.");
                renderPreviews();
                closeCropModal();
            };
            img.src = item.originalSrc;
        }

        ratioBtns.forEach(btn => {
            btn.addEventListener('change', function() {
                document.querySelectorAll('.ratio-box').forEach(box => box.classList.remove('active'));
                this.nextElementSibling.classList.add('active');
                renderPreviews();
            });
        });

        postForm.addEventListener('submit', async function(e) {
            e.preventDefault();
            const submitBtn = document.getElementById('submitBtn');
            const originalHtml = submitBtn.innerHTML;
            
            submitBtn.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Finalizing...';
            submitBtn.disabled = true;

            const formData = new FormData();
            formData.append('content', document.getElementById('postContent').value);
            formData.append('aspectRatio', document.querySelector('input[name="aspectRatio"]:checked').value);

            try {
                for (let i = 0; i < preparedFiles.length; i++) {
                    const item = preparedFiles[i];
                    if (item.adjusted) {
                        const resp = await fetch(item.previewBlob);
                        const blob = await resp.blob();
                        formData.append('imageFiles', blob, 'image_' + i + '.jpg');
                    } else {
                        formData.append('imageFiles', item.blob);
                    }
                }

                log("Submitting to server...");
                const res = await fetch('PostServlet', { method: 'POST', body: formData });
                if (res.ok) {
                    window.location.href = 'FeedServlet';
                } else {
                    alert("Submission failed with status: " + res.status);
                    submitBtn.innerHTML = originalHtml;
                    submitBtn.disabled = false;
                }
            } catch (err) {
                log("Error during submission: " + err.message);
                alert("An error occurred during upload.");
                submitBtn.innerHTML = originalHtml;
                submitBtn.disabled = false;
            }
        });
    </script>
</body>
</html>
