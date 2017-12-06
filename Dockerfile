FROM ubuntu:latest

# Install Python Pip and the Robot framework
RUN apt-get update -y && \
    apt-get install -y apt-utils && \
    apt-get install -y netcat && \
    apt-get install -y python python-pip python-dev gcc && \
    pip install --upgrade pip && \
    pip install robotframework robotframework-requests requests && \
    pip install robotframework-sshlibrary&& \
    pip install cx_Oracle --upgrade

RUN apt-get install -y curl && \
    curl https://pypi.python.org/packages/9b/8d/20dfc853d7580babeb94b055597fbfdf5758116e6d51e52a1d3eb5a9b2b6/robotframework-databaselibrary-1.0.1.tar.gz --output robo-db.tar.gz
RUN tar -xvzf robo-db.tar.gz
WORKDIR /robotframework-databaselibrary-1.0.1
#RUN cd /robotframework-databaselibrary-1.0.1 && python setup.py install
RUN python setup.py install
