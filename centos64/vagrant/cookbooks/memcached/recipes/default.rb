#
# Cookbook Name:: memcached
# Recipe:: default
#
# Copyright 2013, Tecotec inc.
#
# All rights reserved - Do Not Redistribute
#

# package
package 'memcached' do
  action :install
end

# /etc/sysconfig/memcached
template "/etc/sysconfig/memcached" do
  source "memcached.conf.erb"
  owner "root"
  group "root"
  mode "0644"
  variables(
    :port      => node["memcached"]["port"],
    :user      => node["memcached"]["user"],
    :maxconn   => node["memcached"]["maxconn"],
    :cachesize => node["memcached"]["cachesize"],
    :options   => node["memcached"]["options"]
  )
end

# service
service "memcached" do
  supports :status => true, :restart => true
  action [:enable, :start]
  subscribes :restart, resources(:template => ["/etc/sysconfig/memcached"])
end

