#
# Cookbook Name:: php-xdebug
# Recipe:: default
#
# Copyright 2013, Tecotec inc.
#
# All rights reserved - Do Not Redistribute
#

# package
package "php-pecl-xdebug" do
  action :install
end

template node["xdebug"]["confdir"] + "/xdebug.ini" do
  source "xdebug.ini.erb"
  owner "root"
  group "root"
  mode "0644"
  variables(
    :port => node["xdebug"]["port"]
  )
  notifies :restart ,"service[httpd]"
end

