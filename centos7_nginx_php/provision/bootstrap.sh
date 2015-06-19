#!/bin/bash

command -v wget >/dev/null 2>&1 || {
    sudo yum -y install wget;
}

command -v ansible >/dev/null 2>&1 || {
    wget https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm;
    sudo rpm -Uvh epel-release-latest-7.noarch.rpm;
    sudo yum -y install ansible;
}

ansible-playbook -i /vagrant/provision/hosts /vagrant/provision/playbook.yml
