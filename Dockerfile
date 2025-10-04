FROM openjdk:17-jdk-slim

# Flexible JAR argument
ARG JAR_FILE=target/spring-petclinic-*.jar

# Copy the JAR into the container
COPY ${JAR_FILE} app.jar

# Expose port (Spring Boot default is 8080)
EXPOSE 8080

# Run the JAR on port 8080 (map to 7070 outside if you want)
ENTRYPOINT ["java","-jar","/app.jar"]

