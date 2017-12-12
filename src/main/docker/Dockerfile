FROM openjdk:8-jre-alpine
MAINTAINER GGK_DevOps
ARG jarfile_name
ARG port
ARG db_details

VOLUME /tmp
VOLUME /logs
VOLUME /configs

ADD src/main/docker/wait-for-it.sh /wait-for-it.sh
ADD target/${jarfile_name} app.jar
ENV CP_JAVA_OPTS="-Dserver.port=${port} -Dspring.datasource.username=${db_details} -Dspring.datasource.password=${db_details}"

RUN chmod +x wait-for-it.sh
RUN echo "java -jar \$CP_JAVA_OPTS /app.jar" > run.sh
RUN chmod +x run.sh

ENTRYPOINT ["sh", "./run.sh" ]





