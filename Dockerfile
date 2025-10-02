# Use official OpenJDK runtime as base
FROM openjdk:17-jdk-slim

# Argument to pass in the JAR file name
ARG JAR_FILE=target/spring-petclinic-3.0.5-SNAPSHOT.jar

# Copy the JAR into the container
COPY ${JAR_FILE} app.jar

# Expose the default Spring Boot port
EXPOSE 7070

# Run the JAR
ENTRYPOINT ["java","-jar","/app.jar"]
