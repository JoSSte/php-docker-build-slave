FROM ubuntu:22.04

LABEL maintainer="Jonas Stevnsvig <jonas@stevnsvig.com>"

ENV TZ=Europe/Copenhagen
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
ARG DEBIAN_FRONTEND=noninteractive
#RUN apt-get install -qy --no-install-recommends tzdata

RUN apt-get autoremove
#--fix-missing
RUN apt-get clean

# Make sure the package repository is up to date.
RUN apt-get update && \
    apt-get -qy full-upgrade && \
    apt-get install -qy git

# Install a basic SSH server
RUN apt-get install -qy openssh-server && \
    sed -i 's|session    required     pam_loginuid.so|session    optional     pam_loginuid.so|g' /etc/pam.d/sshd && \
    mkdir -p /var/run/sshd 

# install java for Jenkins
RUN apt-get install -qy openjdk-11-jdk

# install rsync
RUN apt-get install -qy rsync

# install PHP 8.1 & mysql
RUN apt-get install -qy php8.1-curl php8.1-gd apache2 mysql-server php8.1 unzip php8.1-mysql php8.1-zip php8.1-mbstring php-xdebug php-pear*

# install composer
RUN wget -O composer-setup.php https://getcomposer.org/installer
RUN php composer-setup.php --install-dir=/usr/local/bin --filename=composer
RUN composer self-update  

# Cleanup old packages
RUN apt-get -qy autoremove

# Add user jenkins to the image
RUN adduser --disabled-password --gecos "" jenkins 

# fix java

RUN ln -s /usr/lib/jvm/java-11-openjdk-amd64/ /home/jenkins/jdk
RUN chown jenkins:jenkins /home/jenkins/jdk

# Copy authorized_keys & known_hosts & private key for ssh deploys
COPY ssh/authorized_keys /home/jenkins/.ssh/authorized_keys
COPY ssh/known_hosts /home/jenkins/.ssh/known_hosts

COPY resources/xdebug.ini /etc/php/8.1/mods-available/xdebug.ini

RUN ssh-keyscan -H bitbucket.org >> /home/jenkins/.ssh/known_hosts
RUN ssh-keyscan -H github.com >> /home/jenkins/.ssh/known_hosts
RUN chown -R jenkins:jenkins /home/jenkins/.ssh/


# Standard SSH port
EXPOSE 22

CMD ["/usr/sbin/sshd", "-D"]
