FROM jenkins/jenkins:2.162

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
USER jenkins
ADD plugins.txt /usr/share/jenkins/ref/plugins.txt
RUN /usr/local/bin/install-plugins.sh < /usr/share/jenkins/ref/plugins.txt
