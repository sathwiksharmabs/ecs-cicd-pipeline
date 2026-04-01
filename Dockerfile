# Stage 1 — Build
FROM maven:3.9-eclipse-temurin-17 AS builder

WORKDIR /build

COPY . .

RUN mvn clean package -DskipTests


# Stage 2 — Run
FROM eclipse-temurin:17-jre-jammy

WORKDIR /app

ARG APP_VERSION
ENV APP_VERSION=$APP_VERSION

COPY --from=builder /build/target/ecs-cicd-app-0.0.1-SNAPSHOT.jar app.jar

EXPOSE 8080

ENTRYPOINT ["java", "-jar", "app.jar"]