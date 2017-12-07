FROM openjdk:8-jre-alpine
MAINTAINER GGK_DevOps

VOLUME /tmp
VOLUME /logs
VOLUME /configs

ADD src/main/docker/wait-for-it.sh /wait-for-it.sh
ADD target/sampleproject-0.0.1-SNAPSHOT.jar app.jar
RUN sh -c 'touch /app.jar'
RUN chmod +x wait-for-it.sh
ENV JAVA_OPTS=""
ENTRYPOINT [ "java","-jar","/app.jar" ]

