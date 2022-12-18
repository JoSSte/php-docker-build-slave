FROM ubuntu:21.04

LABEL maintainer="Jonas Stevnsvig <jonas@stevnsvig.com>"

#ENV TZ=Europe/Copenhagen
#RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
ARG DEBIAN_FRONTEND=noninteractive
#RUN apt-get install -qy --no-install-recommends tzdata

RUN apt-get autoremove
#--fix-missing
RUN apt-get clean

RUN cat /etc/apt/sources.list

# hirsute is end-of-life. replace archive with old-releases:
RUN sed -i "s|archive.ubuntu|old-releases.ubuntu|" /etc/apt/sources.list
# EOL releases do not get security updates:
RUN sed -i "s|deb http://security.ubuntu.com|#deb http://security.ubuntu.com|" /etc/apt/sources.list

RUN cat /etc/apt/sources.list

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

# install PHP 7.4 & mysql
RUN apt-get install -qy apache2 php7.4-curl php7.4-gd apache2 mysql-server php7.4 unzip php7.4-mysql php7.4-mbstring php7.4-zip php-xdebug php-pear*

# install composer
RUN wget -O composer-setup.php https://getcomposer.org/installer
RUN php composer-setup.php --install-dir=/usr/local/bin --filename=composer
RUN composer self-update

# Cleanup old packages
RUN apt-get -qy autoremove
# Add user jenkins to the image
RUN adduser --disabled-password --gecos "" jenkins

# Copy authorized keys
COPY ssh/authorized_keys /home/jenkins/.ssh/authorized_keys
COPY ssh/known_hosts /home/jenkins/.ssh/known_hosts
COPY ssh/id_rsa /home/jenkins/.ssh/id_rsa

COPY resources/xdebug.ini /etc/php/7.4/mods-available/xdebug.ini

RUN ssh-keyscan -H bitbucket.org >> /home/jenkins/.ssh/known_hosts
RUN ssh-keyscan -H github.com >> /home/jenkins/.ssh/known_hosts
RUN chown -R jenkins:jenkins /home/jenkins/.ssh/
RUN chmod 600 /home/jenkins/.ssh/id_rsa

# Standard SSH port
EXPOSE 22

CMD ["/usr/sbin/sshd", "-D"]
