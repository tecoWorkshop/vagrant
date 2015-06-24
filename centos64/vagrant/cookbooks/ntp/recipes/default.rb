#
# Cookbook Name:: ntp
# Recipe:: default
#
# Copyright 2014, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

# ntpパッケージをインストール
package "ntp" do
  action :install
end

# ntpdサービスを自動起動にし、このrecipe実行時に再起動する
service "ntpd" do
  supports :status => true, :restart => true
  action [ :enable, :start ]
end

# あらかじめ用意した設定ファイルを/etc/ntp.confとして配置する
template "/etc/ntp.conf" do
  source "ntp.conf"
  group "root"
  owner "root"
  mode "400"
  notifies :restart, "service[ntpd]"
end
