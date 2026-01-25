FROM maven:3.9-eclipse-temurin-17 AS build
WORKDIR /app

# Copy parent POM
COPY pom.xml .

# Copy all module POMs
COPY eureka-server/pom.xml eureka-server/
COPY api-gateway/pom.xml api-gateway/
COPY user-service/pom.xml user-service/
COPY profile-service/pom.xml profile-service/
COPY JobService/pom.xml JobService/
COPY matching-service/pom.xml matching-service/
COPY notification-service/pom.xml notification-service/
COPY messaging-service/pom.xml messaging-service/

# Download dependencies
RUN mvn dependency:go-offline -B -pl api-gateway -am

# Copy source code
COPY api-gateway/src api-gateway/src

# Build
RUN mvn package -pl api-gateway -am -DskipTests

# Run stage
FROM eclipse-temurin:17-jre-jammy
WORKDIR /app
# Explicitly pick the artifact jar to avoid .original
COPY --from=build /app/api-gateway/target/api-gateway-1.0.0.jar app.jar
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]
