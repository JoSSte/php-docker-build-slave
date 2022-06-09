FROM ubuntu:21.04

LABEL maintainer="Jonas Stevnsvig <jonas@stevnsvig.com>"

#ENV TZ=Europe/Copenhagen
#RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
ARG DEBIAN_FRONTEND=noninteractive
#RUN apt-get install -qy --no-install-recommends tzdata

# Make sure the package repository is up to date.
RUN apt-get update && \
    apt-get -qy full-upgrade && \
    apt-get install -qy git
# Install a basic SSH server
RUN apt-get install -qy openssh-server && \
    sed -i 's|session    required     pam_loginuid.so|session    optional     pam_loginuid.so|g' /etc/pam.d/sshd && \
    mkdir -p /var/run/sshd

# install java for Jenkins
RUN apt-get install -qy openjdk-8-jdk

# install PHP 7.4 & mysql
RUN apt-get install -qy apache2 php7.4-curl php7.4-gd apache2 mysql-server php7.4 unzip php7.4-mysql php7.4-mbstring php7.4-zip php-xdebug php-pear*

# Cleanup old packages
RUN apt-get -qy autoremove
# Add user jenkins to the image
RUN adduser --disabled-password --gecos "" jenkins

# Copy authorized keys
COPY ssh/authorized_keys /home/jenkins/.ssh/authorized_keys

RUN chown -R jenkins:jenkins /home/jenkins/.ssh/

# Standard SSH port
EXPOSE 22

CMD ["/usr/sbin/sshd", "-D"]
