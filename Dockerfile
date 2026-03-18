# Use official Tomcat 10 image with JDK 17
FROM tomcat:10.1-jdk17-ready-to-use

# Remove default webapps
RUN rm -rf /usr/local/tomcat/webapps/*

# Copy the WAR file to the webapps directory as ROOT.war
# This ensures the app is served at the root URL (/)
COPY target/social-media-java.war /usr/local/tomcat/webapps/ROOT.war

# Set environment variables (Can also be set in Render dashboard)
# ENV DB_URL=...
# ENV DB_USER=...
# ENV DB_PASSWORD=...
# ENV CLOUDINARY_CLOUD_NAME=...
# ENV CLOUDINARY_API_KEY=...
# ENV CLOUDINARY_API_SECRET=...

# Expose port 8080
EXPOSE 8080

# Start Tomcat
CMD ["catalina.sh", "run"]
