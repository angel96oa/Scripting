FROM debian:latest

RUN apt-get update && \
        apt-get -y install curl && \
        apt-get install -y apt-transport-https

RUN printf "deb http://archive.debian.org/debian/ jessie main\ndeb-src http://archive.debian.org/debian/ jessie main\ndeb http://security.debian$



RUN apt-get autoclean && \
        apt-get -f install && \
            dpkg --configure -a && \
               apt-get update

RUN apt-get -y -f install sysbench
