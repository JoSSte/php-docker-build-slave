# PHP docker build slave
Docker build slave for php for Jenkins

## About
Image inspired by bibinwilson/jenkins-docker-slave  
Used in a setup like the one found in [this article](https://devopscube.com/docker-containers-as-build-slaves-jenkins/)

## Building
Because I also deploy from these images i have som ssh related files in the [ssh](ssh) folder which are not included.

### Prerequisites
* Create your ssh key and put it in `ssh/id_rsa`
* Add the host identifier to `ssh/known_hosts`
* Add the public key that the jenkins server needs to use to connect to the image to `ssh/authorized_keys`

### Create

To build the image run `docker-compose build`

I prefer not having to remember a lot of parameters and so on, so there is both a [Dockerfile](Dockerfile) and a [docker-compose.yml](docker-compose.yml) the yml file is solely there to tag and name the image correctly, if you choose to just keep the image on your docker host instead of forking it and putting it in github.

## Useful tidbits

### Adding host keys to the known_hosts explicitly
instead of digging though an existing known_hosts, just execute this command:  
`ssh-keyscan -H remote.server.dk >> ssh/known_hosts`
There is a pitfall - a malicious actor may do a man-in-the-middle attack. by doing this in the image creation, and not in the jenkinsfile, My thought is that the risk is smaller, since we do it less often., this does require rebuilding the image when the keys change.