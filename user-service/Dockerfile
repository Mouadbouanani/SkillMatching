FROM maven:3.9-eclipse-temurin-17 AS build
WORKDIR /app
COPY pom.xml .
COPY eureka-server/pom.xml eureka-server/
COPY api-gateway/pom.xml api-gateway/
COPY user-service/pom.xml user-service/
COPY profile-service/pom.xml profile-service/
COPY JobService/pom.xml JobService/
COPY matching-service/pom.xml matching-service/
COPY notification-service/pom.xml notification-service/
COPY messaging-service/pom.xml messaging-service/
RUN mvn dependency:go-offline -B -pl user-service -am
COPY user-service/src user-service/src
RUN mvn package -pl user-service -am -DskipTests

FROM eclipse-temurin:17-jre-jammy
WORKDIR /app
COPY --from=build /app/user-service/target/user-service-1.0.0.jar app.jar
EXPOSE 8081
ENTRYPOINT ["java", "-jar", "app.jar"]
