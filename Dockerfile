FROM openjdk:8-jre-alpine
VOLUME /tmp
ADD build/libs/docker-hub*.jar app.jar
ADD .env .env
ENTRYPOINT [ "sh", "-c", "source .env && java -jar app.jar" ]
