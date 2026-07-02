FROM eclipse-temurin:17-jdk-jammy AS build

WORKDIR /app
COPY .mvn/ .mvn/
COPY mvnw pom.xml ./   
     
RUN ./mvnw dependency:go-offline

COPY src/ src/

RUN ./mvnw package -DskipTests

FROM eclipse-temurin:17-jre-jammy

WORKDIR /app

RUN apt-get update && \
    apt-get install -y --no-install-recommends curl && \
    rm -rf /var/lib/apt/lists/*

# COPY wait-for-it.sh wait-for-it.sh
# RUN chmod +x wait-for-it.sh

COPY --from=build /app/target/*.jar app.jar

EXPOSE 8082

ENTRYPOINT ["java", "-jar", "app.jar"]

