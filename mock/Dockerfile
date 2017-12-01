FROM nguyenthaitho/docker-alpine-curl-bash2
MAINTAINER Tho Nguyen <thonguyen@fortna.com>

VOLUME /mock_mapping

RUN curl http://repo1.maven.org/maven2/com/github/tomakehurst/wiremock-standalone/2.12.0/wiremock-standalone-2.12.0.jar --output wiremock-standalone.jar
RUN sh -c 'touch /wiremock-standalone.jar'

ENV RUNNING_PORT=6500
RUN echo "java -jar /wiremock-standalone.jar --port=\$RUNNING_PORT --root-dir=/mock_mapping --global-response-templating" > run.sh
RUN chmod +x run.sh
RUN cat run.sh
ENTRYPOINT ["/bin/bash", "./run.sh" ]
