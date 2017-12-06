FROM gliderlabs/alpine:3.3

LABEL name="Docker image for the Robot Framework http://robotframework.org/"
LABEL usage="docker run -e ROBOT_TESTS=tests/sampletest.robot --rm -v $(pwd)tests/sampletest.robot:tests/sampletest.robot -ti <docker_image_name>"

# Install Python Pip and the Robot framework
RUN apk-install bash py-pip && \
    pip install --upgrade pip && \
    pip install robotframework robotframework-requests requests && \
    python --version

RUN apk-install curl && \
    curl https://pypi.python.org/packages/9b/8d/20dfc853d7580babeb94b055597fbfdf5758116e6d51e52a1d3eb5a9b2b6/robotframework-databaselibrary-1.0.1.tar.gz --output robo-db.tar.gz
RUN tar -xvzf robo-db.tar.gz
WORKDIR /robotframework-databaselibrary-1.0.1
#RUN cd /robotframework-databaselibrary-1.0.1 && python setup.py install
RUN python setup.py install

ADD run.sh /usr/local/bin/run.sh
RUN chmod +x /usr/local/bin/run.sh

CMD ["run.sh"]
