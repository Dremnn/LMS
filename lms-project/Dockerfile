# Stage 1: Build the Maven application with JDK 25
FROM maven:3.9.15-eclipse-temurin-25 AS build
WORKDIR /app

# Cache dependencies
COPY pom.xml .
RUN mvn dependency:go-offline -B || true

# Copy source code and build WAR
COPY src ./src
RUN mvn clean package -DskipTests

# Stage 2: Runtime on Tomcat 11 with JDK 25
FROM tomcat:11.0-jdk25-temurin
WORKDIR /usr/local/tomcat

# Remove default sample apps
RUN rm -rf webapps/*

# Copy the built WAR as ROOT.war so the app runs at the root domain /
COPY --from=build /app/target/*.war webapps/ROOT.war

# Optimized JVM memory for Render Free Tier (512MB RAM) to avoid OOM
ENV JAVA_OPTS="-Xms128m -Xmx320m -XX:+UseG1GC -XX:+UseStringDeduplication -XX:MaxMetaspaceSize=128m"

# Render provides $PORT or listens on 8080
EXPOSE 8080
CMD ["sh", "-c", "sed -i \"s/port=\\\"8080\\\"/port=\\\"${PORT:-8080}\\\"/g\" conf/server.xml && catalina.sh run"]
