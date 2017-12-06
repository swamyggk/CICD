FROM openjdk:8-jre-alpine
MAINTAINER GGK_DevOps

VOLUME /tmp
VOLUME /logs
VOLUME /configs

ADD target/sampleproject-0.0.1-SNAPSHOT.jar app.jar
RUN sh -c 'touch /app.jar'
ENV JAVA_OPTS=""
ENTRYPOINT [ "java","-jar","/app.jar" ]

