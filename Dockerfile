# Ubuntu 16.04
# Oracle Java 1.8.0_101
# Maven 3.3.9
# Docker 18.03.1
# Docker-Compose 1.21.1
# Fargate v0.6.0
# jq
# aws_iam_authenticator
# kubectl
# stable node version
# serverless
# tearrform 0.11.13
# Jruby 9.1.13.0
FROM ubuntu:16.04
MAINTAINER Sivakumar Vunnam <sivakumarvunnam1@gmail.com>
# convenient aliases
RUN echo "alias dc=docker-compose" >> ~/.bashrc && \
    echo "alias f=fargate" >> ~/.bashrc && \
    echo "alias k=kubectl" >> ~/.bashrc

# install docker
ENV DOCKER_VERSION 18.03.1
RUN apt-get update && apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    wget \
    jq \
    unzip \
    python-pip \
    software-properties-common
RUN curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
RUN add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"
RUN apt-get update && apt-get install -y docker-ce=${DOCKER_VERSION}~ce-0~ubuntu

# get maven 3.3.9
RUN wget --no-verbose -O /tmp/apache-maven-3.3.9.tar.gz http://archive.apache.org/dist/maven/maven-3/3.3.9/binaries/apache-maven-3.3.9-bin.tar.gz

# verify checksum
RUN echo "516923b3955b6035ba6b0a5b031fbd8b /tmp/apache-maven-3.3.9.tar.gz" | md5sum -c

# install maven
RUN tar xzf /tmp/apache-maven-3.3.9.tar.gz -C /opt/
RUN ln -s /opt/apache-maven-3.3.9 /opt/maven
RUN ln -s /opt/maven/bin/mvn /usr/local/bin
RUN rm -f /tmp/apache-maven-3.3.9.tar.gz
ENV MAVEN_HOME /opt/maven

# remove download archive files
RUN apt-get clean

# set shell variables for java installation
ENV java_version 1.8.0_101
ENV filename jdk-8u101-linux-x64.tar.gz
ENV downloadlink https://dl.cactifans.com/jdk/jdk-8u101-linux-x64.tar.gz

# download java, accepting the license agreement
RUN wget --no-cookies --header "Cookie: oraclelicense=accept-securebackup-cookie" -O /tmp/$filename $downloadlink

# unpack java
RUN mkdir /opt/java-oracle && tar -zxf /tmp/$filename -C /opt/java-oracle/
ENV JAVA_HOME /opt/java-oracle/jdk$java_version
ENV PATH $JAVA_HOME/bin:$PATH

# configure symbolic links for the java and javac executables
RUN update-alternatives --install /usr/bin/java java $JAVA_HOME/bin/java 20000 && update-alternatives --install /usr/bin/javac javac $JAVA_HOME/bin/javac 20000

# install docker-compose
ENV DC_VERSION 1.21.1
RUN curl -L https://github.com/docker/compose/releases/download/${DC_VERSION}/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose && chmod +x /usr/local/bin/docker-compose

#install aws-cli
RUN curl -O https://bootstrap.pypa.io/get-pip.py && python get-pip.py --user
RUN python -m pip install awscli

# install fargate-cli
ENV FARGATE_VERSION v0.6.0
RUN curl -SLo /usr/local/bin/fargate https://github.com/turnerlabs/fargate/releases/download/${FARGATE_VERSION}/ncd_linux_amd64 && chmod +x /usr/local/bin/fargate

# install node
RUN curl https://raw.githubusercontent.com/isaacs/nave/master/nave.sh | bash -s -- usemain lts && npm install global serverless

# Install Kubectl
ENV KUBECTL_VERSION 1.11.5
ARG KUBECTL_URL=https://amazon-eks.s3-us-west-2.amazonaws.com/${KUBECTL_VERSION}/2018-12-06/bin/linux/amd64/kubectl

#install iam authenticator
ENV AWS_IAM_AUTHENTICATOR_VERSION 1.11.5
ARG AWS_IAM_AUTHENTICATOR_URL=https://amazon-eks.s3-us-west-2.amazonaws.com/${AWS_IAM_AUTHENTICATOR_VERSION}/2018-12-06/bin/linux/amd64/aws-iam-authenticator

ADD ${KUBECTL_URL} /usr/local/bin/kubectl
ADD ${AWS_IAM_AUTHENTICATOR_URL} /usr/local/bin/aws-iam-authenticator

ENV HOME /home/jenkins
RUN addgroup --system --gid 10000 jenkins
RUN adduser --system --ingroup jenkins --home $HOME --uid 10000 jenkins

RUN chmod +x /usr/local/bin/kubectl && \
    chmod +x /usr/local/bin/aws-iam-authenticator

#install terraform
ENV TERRAFORM_VERSION 0.11.13
RUN wget --quiet https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip \
    && unzip terraform_${TERRAFORM_VERSION}_linux_amd64.zip \
    && mv terraform /usr/bin \
    && rm terraform_${TERRAFORM_VERSION}_linux_amd64.zip

# SOAP UI Version to download
ENV SOAPUI_VERSION 5.4.0
# Download and unarchive SoapUI
RUN wget --no-verbose -O /tmp/SoapUI-${SOAPUI_VERSION}-linux-bin.tar.gz https://s3.amazonaws.com/downloads.eviware/soapuios/5.4.0/SoapUI-${SOAPUI_VERSION}-linux-bin.tar.gz
RUN tar xzf /tmp/SoapUI-${SOAPUI_VERSION}-linux-bin.tar.gz -C /opt/
RUN ln -s /opt/SoapUI-${SOAPUI_VERSION} /opt/soapui
# Set environment
ENV SOAPUI_HOME /opt/soapui
ENV PATH $SOAPUI_HOME/bin:$PATH

# install jruby 
ENV JRUBY_VERSION 9.1.13.0
RUN wget --no-verbose -O /tmp/jruby-bin-${JRUBY_VERSION}.tar.gz https://s3.amazonaws.com/jruby.org/downloads/${JRUBY_VERSION}/jruby-bin-${JRUBY_VERSION}.tar.gz && \
    tar xzf /tmp/jruby-bin-${JRUBY_VERSION}.tar.gz -C /opt/ && \
    rm -rf /tmp/jruby-bin-${JRUBY_VERSION}.tar.gz
ENV JRUBY_HOME /opt/jruby-${JRUBY_VERSION}
ENV PATH $JRUBY_HOME/bin:$PATH

CMD ["/bin/bash"]

