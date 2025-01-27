# Use OpenJDK base image
FROM openjdk:17-jdk-slim

# Set the working directory
WORKDIR /app

# Copy the built artifact (JAR file) from the target directory to the container
COPY target/*.jar /usr/local/tomcat/webapps/your-app.jar
# Expose port 8085 to allow external access
EXPOSE 8085

# Set the command to run the JAR file
CMD ["java", "-jar", "/app/hello-world.jar"]


