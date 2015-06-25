#apache
sudo yum -y install httpd

#php
sudo yum -y install php

#mysql
sudo yum -y install mysql

#phpモジュール
sudo yum -y install php php-mysql
sudo yum -y install php php-pgsql
sudo yum -y install php php-gd
sudo yum -y install php php-freetype2
sudo yum -y install php php-mbstring
sudo yum -y install php-xml

#mariadb
sudo yum -y install mariadb-server

# services
sudo systemctl start httpd.service && sudo systemctl enable httpd.service
#sudo systemctl start mysqld.service && sudo systemctl enable mysqld.service
sudo systemctl start mariadb.service && sudo systemctl enable mariadb.service

# firewalld
sudo systemctl start firewalld && sudo systemctl enable firewalld
sudo firewall-cmd --add-service=http && sudo firewall-cmd --add-service=http --permanent
sudo firewall-cmd --add-service=https && sudo firewall-cmd --add-service=https --permanent

# Document root
sudo mkdir -p /var/www/virtualhost/eccube

# Virtualhost
sudo mkdir -p /etc/httpd/conf.d
sudo cp /vagrant/vhost.conf > sudo /etc/httpd/conf.d/vhost.conf
sudo rm -f /etc/httpd/conf/httpd.conf
sudo cp /vagrant/httpd.conf > sudo /etc/httpd/conf/httpd.conf

# link
sudo ln -s /vagrant/eccube/data/ /var/www/virtualhost/eccube/data
sudo ln -s /vagrant/eccube/html/ /var/www/virtualhost/eccube/html