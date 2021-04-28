FROM ubuntu:latest

RUN apt-get update \
    && apt-get install -y curl iputils-ping traceroute dnsutils \
    && apt-get install -y bash-completion telnet


CMD [ "tail", "-f", "/dev/null" ]
