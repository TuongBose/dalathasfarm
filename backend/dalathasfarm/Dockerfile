#Build
FROM maven:3.9.6-eclipse-temurin-21 AS build
WORKDIR /app
COPY . .
RUN mvn clean package -DskipTests

#multi-staging
FROM eclipse-temurin:21-jdk

# set timezone
RUN ln -sf /usr/share/zoneinfo/Asia/Ho_Chi_Minh /etc/localtime \
    && echo "Asia/Ho_Chi_Minh" > /etc/timezone

WORKDIR /app
COPY --from=build /app/target/dalathasfarm-0.0.1-SNAPSHOT.jar app.jar
COPY --from=build /app/uploads uploads

EXPOSE 8080
CMD ["java","-jar","app.jar"]