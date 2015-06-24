#
# Cookbook Name:: yum
# Recipe:: default

# Copyright 2013, Tecotec inc.
#
# All rights reserved - Do Not Redistribute
#

# openssl-devel
package "openssl-devel" do
  action :install
end

# mlocate
package "mlocate" do
  action :install
end

# vim
package "vim" do
  action :install
end

# telnet
package "telnet" do
  action :install
end

# bind-utils
package "bind-utils" do
  action :install
end

# tcpdump
package "tcpdump" do
  action :install
end

# dstat
package "dstat" do
  action :install
end
