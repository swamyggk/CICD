FROM nguyenthaitho/docker-alpine-curl-bash2
MAINTAINER Tho Nguyen <thonguyen@fortna.com>

VOLUME /mock_mapping

RUN curl http://10.240.17.13:80/artifactory/fortna-product-tools/wiremock/wiremock-standalone/wiremock-standalone-2.10.1.jar --output wiremock-standalone.jar
RUN sh -c 'touch /wiremock-standalone.jar'

ENV RUNNING_PORT=6500
RUN echo "java -jar /wiremock-standalone.jar --port=\$RUNNING_PORT --root-dir=/mock_mapping --global-response-templating" > run.sh
RUN chmod +x run.sh
RUN cat run.sh
ENTRYPOINT ["/bin/bash", "./run.sh" ]