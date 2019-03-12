#
# Cookbook:: apachevh
# Recipe:: default
#
# Copyright:: 2019, The Authors, All Rights Reserved.
package 'apache2' do
  action :install
end

environments = ['dev', 'qa', 'prod']
environments.each do |env|
  # create the environments
  directory "/var/www/#{env}/" do
    action :create
  end
  directory "/var/log/apache2/#{env}/" do
    action :create
  end
  cookbook_file "/var/www/#{env}/index.html" do
    source "#{env}/index.html"
    mode "0644"
    action :create
  end
  cookbook_file "/etc/apache2/sites-available/mbafiap.#{env}.com.br.conf" do
    source "sites-available/mbafiap.#{env}.com.br.conf"
    mode "0644"
    action :create
  end
  bash 'adicionado_ambientes' do
    code "sudo a2ensite mbafiap.#{env}.com.br"
  end
end

service 'apache2' do
  action [:enable, :start]
  supports :reload => true
end
