#
# Cookbook:: ctoaccess
# Recipe:: default
#
# Copyright:: 2019, The Authors, All Rights Reserved.
createUser = data_bag_item('users', 'user_info') 
user "#{createUser['name']}" do
  comment 'CTO User'
  home "/home/#{createUser['name']}"
  shell '/bin/bash'
  password "#{createUser['pass']}"
end

group 'sudo' do
  action :modify
  members "#{createUser['name']}"
  append true
end

cookbook_file "/etc/ssh/sshd_config" do
  source "ssh/sshd_config"
  mode "0644"
  action :create
end

service 'sshd' do
  action :restart
end
