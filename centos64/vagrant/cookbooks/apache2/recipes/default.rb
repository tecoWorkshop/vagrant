#
# Cookbook Name:: apache2
# Recipe:: default
#
# Copyright 2013, Tecotec inc.
#
# All rights reserved - Do Not Redistribute
#

# package
package 'httpd' do
  action :install
end

# httpd.conf
template "/etc/httpd/conf/httpd.conf" do
  source "httpd.conf.erb"
  owner "root"
  group "root"
  mode "0644"
  variables(
    :servername  => node["apache"]["servername"],
    :ports       => node["apache"]["ports"],
    :serveradmin => node["apache"]["serveradmin"]
  )
end

# vhost.conf
template "/etc/httpd/conf.d/vhost.conf" do
  source "vhost.conf.erb"
  owner "root"
  group "root"
  mode 00644
end

# /var/log/httpd
directory "/var/log/httpd" do
  owner "root"
  group "root"
  mode "0755"
end

# /var/log/zend
directory "/var/log/zend" do
  owner "root"
  group "root"
  mode "0777"
end

# service
service "httpd" do
  supports :status => true, :restart => true
  action [:enable, :start]
  subscribes :restart, resources(:template => ["/etc/httpd/conf/httpd.conf", "/etc/httpd/conf.d/vhost.conf"])
end


