#
# Cookbook Name:: mongodb
# Recipe:: default
#
# Copyright 2013, Tecotec inc.
#
# All rights reserved - Do Not Redistribute
#

# package
%w{mongodb mongodb-server}.each do |p|
  package p do
    action :install
  end
end

# service
service "mongod" do
  supports :status => true, :restart => true
  action [:enable, :start]
end

