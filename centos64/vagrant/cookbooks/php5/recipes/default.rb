#
# Cookbook Name:: php5
# Recipe:: default
#
# Copyright 2013, Tecotec inc.
#
# All rights reserved - Do Not Redistribute
#

# package
%w{php php-common php-cli php-pdo php-gd php-mysql php-devel php-mbstring php-pear php-mcrypt php-pecl-memcache php-pecl-memcached php-pecl-igbinary php-pecl-apcu php-domxml-php4-php5 php-pecl-mongo}.each do |p|
  package p do
    action :install
  end
end

# php.ini
template "/etc/php.ini" do
  source "php.ini.erb"
  owner "root"
  group "root"
  mode "0644"
  notifies :restart ,"service[httpd]"
end

