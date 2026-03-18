$sourceDir = "c:\Tomcat\apache-tomcat-10\apache-tomcat-10.1.52\webapps\social-media-java"
$backupDir = "C:\Users\shive\.gemini\antigravity\playground\golden-space\data_backup"

# Ensure backup directories exist
if (!(Test-Path "$backupDir\images")) { New-Item -ItemType Directory -Path "$backupDir\images" -Force }
if (!(Test-Path "$backupDir\uploads")) { New-Item -ItemType Directory -Path "$backupDir\uploads" -Force }

# Copy Images
if (Test-Path "$sourceDir\images") {
    Copy-Item -Path "$sourceDir\images\*" -Destination "$backupDir\images" -Recurse -Force -ErrorAction SilentlyContinue
}

# Copy Uploads
if (Test-Path "$sourceDir\uploads") {
    Copy-Item -Path "$sourceDir\uploads\*" -Destination "$backupDir\uploads" -Recurse -Force -ErrorAction SilentlyContinue
}

$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
Add-Content -Path "$backupDir\backup_log.txt" -Value "[$timestamp] Backup completed successfully."
