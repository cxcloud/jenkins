# base image
FROM node:10

USER root

# Scripts to be used in the pipeline
COPY scripts/ /usr/local/bin
RUN mv /usr/local/bin/flowdock.sh /usr/local/bin/flowdock

# install pip and aws cli
RUN apt-get update && apt-get install python-pip -y && \
    pip install awscli

# install kubectl
RUN apt-get update && apt-get install -y apt-transport-https && \
    curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add - && \
    echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | tee -a /etc/apt/sources.list.d/kubernetes.list && \
    apt-get update && \
    apt-get install -y kubectl

# install helm
RUN curl https://raw.githubusercontent.com/helm/helm/master/scripts/get | bash

# install docker
RUN apt-get -y --no-install-recommends install \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg2 \
    software-properties-common && \
    curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add - && \
    add-apt-repository \
    "deb [arch=amd64] https://download.docker.com/linux/debian \
    $(lsb_release -cs) \
    stable" && \
    apt-get update && \
    apt-get -y --no-install-recommends install docker-ce && \
    usermod -a -G docker node

# install cxcloud cli
RUN npm install -g cxcloud@latest && \
    chown -R root:node /usr/local/lib/node_modules && \
    chmod -R 775 /usr/local/lib/node_modules

# CX Cloud CLI will bypass some checks if I_AM_SERVER=true
ENV I_AM_SERVER=true

# install jq json library
RUN apt-get install jq -y

# install yq yaml library
ARG YQ_VERSION=2.2.1
RUN curl -fsSLo /usr/local/bin/yq \ 
    https://github.com/mikefarah/yq/releases/download/${YQ_VERSION}/yq_linux_amd64 && \
    chmod 755 /usr/local/bin/yq

# Install OpenJDK 8
RUN apt-get -y install openjdk-8-jdk

# Jenkins CI plugin
ARG JENKINS_CI_VERSION=4.3
RUN curl --create-dirs -fsSLo /usr/share/jenkins/slave.jar \
    https://repo.jenkins-ci.org/public/org/jenkins-ci/main/remoting/${JENKINS_CI_VERSION}/remoting-${JENKINS_CI_VERSION}.jar && \
    chmod 755 /usr/share/jenkins && \
    chmod 644 /usr/share/jenkins/slave.jar

# Instal Sonar Scanner (Note that old versions might get removed)
ARG SONAR_VERSION=3.3.0.1492
RUN curl --insecure -o /usr/local/sonarscanner.zip \
    -L https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-${SONAR_VERSION}-linux.zip \
    && unzip /usr/local/sonarscanner.zip -d /usr/local/ \
    && rm /usr/local/sonarscanner.zip
ENV SONAR_RUNNER_HOME=/usr/local/sonar-scanner-${SONAR_VERSION}-linux
ENV PATH=$PATH:/usr/local/sonar-scanner-${SONAR_VERSION}-linux/bin

# Create jenkins working directory
RUN mkdir /home/jenkins && chown node:node /home/jenkins

USER node
ARG AGENT_WORKDIR=/home/jenkins/agent
ENV AGENT_WORKDIR=${AGENT_WORKDIR}

RUN mkdir /home/jenkins/.jenkins && mkdir -p ${AGENT_WORKDIR}

VOLUME /home/jenkins/.jenkins
VOLUME ${AGENT_WORKDIR}

# Set the working directory to /home/jenkins
WORKDIR /home/jenkins

ENTRYPOINT ["jenkins-slave"]
