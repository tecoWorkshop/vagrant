#
# Cookbook Name:: php-xdebug
# Recipe:: default
#
# Copyright 2013, Tecotec inc.
#
# All rights reserved - Do Not Redistribute
#

# pecl
execute "pecl install " + node["xhprof"]["name"] do
  not_if { File.exists?("/usr/lib64/php/modules/xhprof.so") }
end

# log dir
directory node["xhprof"]["logdir"] do
  owner "root"
  group "root"
  mode 00777
  action :create
end

# conf
template node["xhprof"]["confdir"] + "/xhprof.ini" do
  source "xhprof.ini.erb"
  owner "root"
  group "root"
  mode "0644"
  variables(
    :logdir => node["xhprof"]["logdir"]
  )
  notifies :restart ,"service[httpd]"
end

# init xhgui
execute "cd /vagrant/vagrant/htdocs/xhgui" do
  command "cd /vagrant/vagrant/htdocs/xhgui; php install.php"
  not_if { File.exists?("/vagrant/vagrant/htdocs/xhgui/composer.lock") }
end

