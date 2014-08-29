#
# Cookbook Name:: poll-app-supervisor
# Recipe:: default
#
# Copyright (C) 2014 YOUR_NAME
#
# All rights reserved - Do Not Redistribute
#
# CREATE ~/logs DIRECTORY

# CREATE ~/bin DIRECTORY
directory "/home/vagrant/bin" do
  owner "vagrant"
  group "vagrant"
  mode 00755
  action :create
end

# PUT SUPERVISOR FILE TO START GUNICORN IN ~/bin
template "/home/vagrant/bin/gunicorn_start.bash" do
  owner "vagrant"
  group "vagrant"
  mode 0754
  source "gunicorn_start.bash.erb"
end

# SET THE NEW SUPERVISORD.CONF FILE
template "/etc/supervisord.conf" do
  owner "root"
  group "root"
  mode 0644
  source "supervisord.conf.erb"
end

# CREATE ~/logs DIRECTORY
directory "/home/vagrant/logs" do
  owner "vagrant"
  group "vagrant"
  mode 00755
  action :create
end

# SET SUPERVISOR POLL_APP.CONF FILE
template "/etc/supervisor.d/poll_app.conf" do
  owner "root"
  group "root"
  mode 0644
  source "poll_app.conf.erb"
end

# RESTART SUPERVISOR
bash "restart_supervisor" do
  code <<-EOH
  sudo service supervisor force-reload
  EOH
end
