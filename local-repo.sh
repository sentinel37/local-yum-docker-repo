#!/bin/bash

# Creating Local Repo
#          https://phoenixnap.com/kb/create-local-yum-repository-centos

# Creating Docker Registry:
#          https://www.youtube.com/watch?v=8gEs_zefNYA

echo '-------------------------------------'
echo '-------------------------------------'
echo 'Updating Server'
echo '-------------------------------------'
echo '-------------------------------------'
yum update -y
echo '-------------------------------------'
echo '-------------------------------------'
echo 'Installing Required Packages'
echo '-------------------------------------'
echo '-------------------------------------'
sudo yum install httpd -y
sudo yum install docker -y
sudo yum install createrepo -y
sudo yum install yum-utils
systemctl start httpd
systemctl enable httpd
echo '-------------------------------------'
echo '-------------------------------------'
echo 'Creating Repo Directories'
echo '-------------------------------------'
echo '-------------------------------------'
mkdir –p /var/www/html/repos
mkdir /var/www/html/repos/base
mkdir /var/www/html/repos/centosplus
mkdir /var/www/html/repos/extras
mkdir /var/www/html/repos/updates
chmod -R 777 /var/www/html/
sudo restorecon -R -v /var/www/
var="$(ip route get 1 | awk '{print $NF;exit}')"
echo '-------------------------------------'
echo '-------------------------------------'
echo 'Downloading All yum Packages to local repo'
echo '-------------------------------------'
echo '-------------------------------------'
reposync -g -l -d -m --repoid=base --newest-only --download-metadata --download_path=/var/www/html/repos/
reposync -g -l -d -m --repoid=centosplus --newest-only --download-metadata --download_path=/var/www/html/repos/
reposync -g -l -d -m --repoid=extras --newest-only --download-metadata --download_path=/var/www/html/repos/
reposync -g -l -d -m --repoid=updates --newest-only --download-metadata --download_path=/var/www/html/repos/
echo '-------------------------------------'
echo '-------------------------------------'
echo 'Add Yum Package Updates to Cron'
echo '-------------------------------------'
echo '-------------------------------------'
echo '  *  *  *  *  * root reposync -g -l -d -m --repoid=base --newest-only --download-metadata --download_path=/var/www/html/repos/'>>/etc/crontab
echo '  *  *  *  *  * root reposync -g -l -d -m --repoid=centosplus --newest-only --download-metadata --download_path=/var/www/html/repos/'>>/etc/crontab
echo '  *  *  *  *  * root reposync -g -l -d -m --repoid=extras --newest-only --download-metadata --download_path=/var/www/html/repos/'>>/etc/crontab
echo '  *  *  *  *  * root reposync -g -l -d -m --repoid=updates --newest-only --download-metadata --download_path=/var/www/html/repos/'>>/etc/crontab
# echo '-------------------------------------'
# echo '-------------------------------------'
# echo 'Removing Legacy Repos'
# echo '-------------------------------------'
# echo '-------------------------------------'
# createrepo /var/www/html
# # mv /etc/yum.repos.d/*.repo /tmp/
echo '-------------------------------------'
echo '-------------------------------------'
echo 'Creating Local Repo'
echo '-------------------------------------'
echo '-------------------------------------'
echo '[remote]'>>/etc/yum.repos.d/remote.repo
echo 'name=Centos Apache'>>/etc/yum.repos.d/remote.repo
echo "baseurl=http://$var">>/etc/yum.repos.d/remote.repo
echo 'enabled=1'>>/etc/yum.repos.d/remote.repo
echo 'gpgcheck=0'>>/etc/yum.repos.d/remote.repo
echo '-------------------------------------'
echo '-------------------------------------'
echo 'Enabling Web Access'
echo '-------------------------------------'
echo '-------------------------------------'
systemctl start firewalld
systemctl enable firewalld
firewall-cmd --zone=public --add-port=80/tcp --permanent
firewall-cmd --zone=public --add-port=8080/tcp --permanent
firewall-cmd --zone=public --add-port=5000/tcp --permanent
sudo firewall-cmd --reload
firewall-cmd --zone=public --list-ports
echo '-------------------------------------'
echo '-------------------------------------'
echo 'Configuring Docker Compose File'
echo '-------------------------------------'
echo '-------------------------------------'
mkdir /etc/docker
mkdir /etc/docker/volume
mkdir -p /var/lib/registry
echo "---">>/etc/docker/docker-compose.yml
echo "version: '3'">>/etc/docker/docker-compose.yml
echo "">>/etc/docker/docker-compose.yml
echo "services:">>/etc/docker/docker-compose.yml
echo "    docker-registry:">>/etc/docker/docker-compose.yml
echo "        container_name: local-docker-registry">>/etc/docker/docker-compose.yml
echo "        image: registry:2">>/etc/docker/docker-compose.yml
echo "        ports:">>/etc/docker/docker-compose.yml
echo "            - 5000:5000">>/etc/docker/docker-compose.yml
echo "        restart: always">>/etc/docker/docker-compose.yml
echo "        volumes:">>/etc/docker/docker-compose.yml
echo "            - ./volume:/var/lib/registry">>/etc/docker/docker-compose.yml
echo "    docker-registry-ui:">>/etc/docker/docker-compose.yml
echo "        container_name: docker-registry-ui">>/etc/docker/docker-compose.yml
echo "        image: konradkleine/docker-registry-frontend:v2">>/etc/docker/docker-compose.yml
echo "        ports:">>/etc/docker/docker-compose.yml
echo "            - 8080:80">>/etc/docker/docker-compose.yml
echo "        environment:">>/etc/docker/docker-compose.yml
echo "            ENV_DOCKER_REGISTRY_HOST: docker-registry">>/etc/docker/docker-compose.yml
echo "            ENV_DOCKER_REGISTRY_PORT: 5000">>/etc/docker/docker-compose.yml
systemctl enable docker
systemctl start docker
echo '-------------------------------------'
echo '-------------------------------------'
echo 'Install Docker Compose'
echo '-------------------------------------'
echo '-------------------------------------'
sudo curl -L "https://github.com/docker/compose/releases/download/1.25.4/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod 755 /usr/local/bin/docker-compose
echo '-------------------------------------'
echo '-------------------------------------'
echo 'Starting Locl Docker Registry'
echo '-------------------------------------'
echo '-------------------------------------'
/usr/local/bin/docker-compose -f /etc/docker/docker-compose.yml up -d
echo '-------------------------------------'
echo '-------------------------------------'
echo 'Local Repo and Docker Configuration Completed!!!!!!!!'
echo '-------------------------------------'
echo '-------------------------------------'
printf \\a
echo '-------------------------------------'
echo '-------------------------------------'
echo 'For Server Using this repo, run:     '
echo '	                              rm -rf /etc/yum.repos.d/*'
echo '-------------------------------------'
echo ''
echo 'Create the following file,/etc/yum.repos.d/remote.repo, and add the lines:'
echo '[remote]'
echo 'name=Centos Apache'
echo "baseurl=http://$var"
echo 'enabled=1'
echo 'gpgcheck=0'
echo ''
echo '-------------------------------------'
echo '-------------------------------------'
echo 'For Servers Using this local Docker Registry:'
echo 'create: /etc/docker/daemon.json'
echo 'Add:'
echo '{'
echo "     "insecure-registries":["$var:5000"]"
echo '}'
echo 'Then stop and start docker service'
echo '-------------------------------------'
echo '-------------------------------------'
echo '-------------------------------------'
echo 'Apache URL:'
echo "           http://$var/repos"
echo '-------------------------------------'
echo 'Docker Front End:'
echo "           http://$var:8080"
echo '-------------------------------------'
