FROM jenkins/jenkins:2.187

USER root

# Install Docker
RUN curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add - \
    && apt update \
    && apt install -y software-properties-common apt-transport-https \
    && add-apt-repository -y "deb [arch=amd64] https://download.docker.com/linux/ubuntu xenial stable" \
    && apt update \
    && apt install -y docker-ce

# Add group docker to user jenkins
RUN usermod -a -G docker jenkins

# Pre-install plugins
ADD plugins.txt /usr/share/jenkins/ref/plugins.txt
RUN /usr/local/bin/install-plugins.sh < /usr/share/jenkins/ref/plugins.txt

# Pre-install jobs
ADD jobs/ /jenkins_jobs/

ADD copy-jobs.sh /usr/local/bin/
RUN chmod 755 /usr/local/bin/copy-jobs.sh

RUN sed -i -e "s|#! /bin/bash -e|#! /bin/bash -e\n/usr/local/bin/copy-jobs.sh|g" /usr/local/bin/jenkins.sh

USER jenkins
