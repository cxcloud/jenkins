# ===============================================
# Base Image with aws cli, docker-client and gitcrypt
# ===============================================
FROM node:8.11

LABEL maintainer="cxcloud@tieto.com" 
LABEL version="0.3"
LABEL description="Used for building/deploying cxcloud svc to aws"

USER root

# Scripts for aws ecr login and ecr deploy
COPY scripts/ /usr/local/bin

# Install docker cli
ENV DOCKERVERSION=18.06.0-ce
RUN curl -fsSLO https://download.docker.com/linux/static/stable/x86_64/docker-${DOCKERVERSION}.tgz \
    && tar xzvf docker-${DOCKERVERSION}.tgz --strip 1 \
                 -C /usr/local/bin docker/docker \
    && rm docker-${DOCKERVERSION}.tgz

# Install aws cli
RUN apt-get update && \ 
    apt-get install -y python2.7 python2.7-dev && \
    curl -O https://bootstrap.pypa.io/get-pip.py && \
    python get-pip.py && \
    pip install awscli --upgrade && \
    aws --version

# Install git-crypt, jq (json processor), summon
RUN apt-get update && apt-get install unzip && \
    cd /tmp && \
    curl -Lo git-crypt.zip https://github.com/AGWA/git-crypt/archive/master.zip && \
    unzip git-crypt.zip && \
    cd git-crypt-master && \
    make && make install && \
    apt-get install -y jq sudo && \
    curl -sSL https://raw.githubusercontent.com/cyberark/summon/master/install.sh | bash && \
    curl -sSL https://raw.githubusercontent.com/cyberark/summon-aws-secrets/master/install.sh | bash

CMD ["/bin/bash"]
