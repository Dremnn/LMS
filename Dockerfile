# Stage 1: Build Maven application with JDK 21
FROM maven:3.9.6-eclipse-temurin-21 AS build
WORKDIR /app

COPY lms-project/pom.xml .
RUN mvn dependency:go-offline -B || true

COPY lms-project/src ./src
RUN mvn clean package -DskipTests

# Stage 2: Runtime on Tomcat 11 with JDK 21
FROM tomcat:11.0-jdk21-temurin
WORKDIR /usr/local/tomcat

RUN rm -rf webapps/*
COPY --from=build /app/target/*.war webapps/ROOT.war

ENV JAVA_OPTS="-Xms128m -Xmx320m -XX:+UseG1GC -XX:+UseStringDeduplication -XX:MaxMetaspaceSize=128m"

EXPOSE 8080
CMD ["sh", "-c", "sed -i \"s/port=\\\"8080\\\"/port=\\\"${PORT:-8080}\\\"/g\" conf/server.xml && catalina.sh run"]
