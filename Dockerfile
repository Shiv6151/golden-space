# Stage 1: Build the Application using Maven
FROM maven:3.9.6-eclipse-temurin-17 AS build
WORKDIR /app

# Copy the pom.xml and cache dependencies
COPY pom.xml .
RUN mvn dependency:go-offline -B

# Copy the source code and build the WAR file
COPY src ./src
RUN mvn clean package -DskipTests

# Stage 2: Create the Tomcat Runtime Environment
FROM tomcat:10.1-jdk17
WORKDIR /usr/local/tomcat

# Remove the default Tomcat webapps to prevent conflicts
RUN rm -rf webapps/*

# Copy the generated WAR file from the build stage to Tomcat's webapps directory.
# By naming it ROOT.war, Tomcat will deploy it at the root context path (/) instead of /social-media-java
COPY --from=build /app/target/social-media-java.war webapps/ROOT.war

# Render.com automatically maps external web traffic to the EXPOSEd port. Tomcat defaults to 8080.
EXPOSE 8080

# Start Tomcat server
CMD ["catalina.sh", "run"]
