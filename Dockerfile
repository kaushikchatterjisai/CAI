# Use official Java runtime as base image
FROM openjdk:11-jre-slim

# Set working directory
WORKDIR /app

# Copy WAR file
COPY abc_tech.war /app/abc_tech.war

# Expose port
EXPOSE 8080

# Run the WAR file
ENTRYPOINT ["java", "-jar", "abc_tech.war"]
