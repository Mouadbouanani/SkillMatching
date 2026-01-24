FROM maven:3.9-eclipse-temurin-17 AS build
WORKDIR /app
COPY pom.xml .
COPY api-gateway/pom.xml api-gateway/
COPY user-service/pom.xml user-service/
COPY profile-service/pom.xml profile-service/
COPY JobService/pom.xml JobService/
COPY matching-service/pom.xml matching-service/
COPY notification-service/pom.xml notification-service/
COPY messaging-service/pom.xml messaging-service/
RUN mvn dependency:go-offline -B -pl messaging-service -am
COPY messaging-service/src messaging-service/src
RUN mvn package -pl messaging-service -am -DskipTests

FROM eclipse-temurin:17-jre-jammy
WORKDIR /app
COPY --from=build /app/messaging-service/target/messaging-service-1.0.0.jar app.jar
EXPOSE 8086
ENTRYPOINT ["java", "--add-opens=java.base/java.time=ALL-UNNAMED", "--add-opens=java.base/java.time.chrono=ALL-UNNAMED", "-jar", "app.jar"]
