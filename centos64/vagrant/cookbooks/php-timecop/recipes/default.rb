#
# Cookbook Name:: php-timecop
# Recipe:: default
#
# Copyright 2013, Tecotec inc.
#
# All rights reserved - Do Not Redistribute
#

# source build
bash "install php-timecop" do
  user "root"
  cwd "/usr/local/src"
  not_if { File.exists?("/usr/lib64/php/modules/timecop.so") }
  code <<-EOH
  curl -L -O https://github.com/hnw/php-timecop/archive/master.zip
  unzip master.zip
  cd php-timecop-master
  phpize
  ./configure
  make
  make install
  EOH
end

template node["timecop"]["confdir"] + "/timecop.ini" do
  source "timecop.ini.erb"
  owner "root"
  group "root"
  mode "0644"
  variables(
    :port => node["timecop"]["port"]
  )
  notifies :restart ,"service[httpd]"
end

