# base image
FROM node:10

# install pip and aws cli
RUN apt-get update && apt-get install python-pip -y && \
    pip install awscli

# install kubernetes
RUN apt-get update && apt-get install -y apt-transport-https && \
    curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add - && \
    echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | tee -a /etc/apt/sources.list.d/kubernetes.list && \
    apt-get update && \
    apt-get install -y kubectl

# install kops
RUN curl -LO https://github.com/kubernetes/kops/releases/download/$(curl -s https://api.github.com/repos/kubernetes/kops/releases/latest | grep tag_name | cut -d '"' -f 4)/kops-linux-amd64 && \
    chmod +x kops-linux-amd64 && \
    mv kops-linux-amd64 /usr/local/bin/kops

# install helm
RUN curl https://raw.githubusercontent.com/helm/helm/master/scripts/get | bash

# install Terraform
RUN apt-get install unzip wget && \
    wget https://releases.hashicorp.com/terraform/0.11.11/terraform_0.11.11_linux_amd64.zip && \
    unzip terra* && \
    mv terraform /usr/local/bin/ && \
    rm -f terra*

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
    apt-get -y --no-install-recommends install docker-ce

# install cxcloud cli
RUN npm install -g cxcloud

# Install OpenJDK 8
RUN apt-get -y install openjdk-8-jdk

# Jenkins CLI plugin
ARG VERSION=3.28
RUN curl --create-dirs -fsSLo /usr/share/jenkins/slave.jar \
    https://repo.jenkins-ci.org/public/org/jenkins-ci/main/remoting/${VERSION}/remoting-${VERSION}.jar \
    && chmod 755 /usr/share/jenkins \
    && chmod 644 /usr/share/jenkins/slave.jar

ADD jenkins-slave /usr/local/bin/jenkins-slave
RUN chmod 755 /usr/local/bin/jenkins-slave

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
