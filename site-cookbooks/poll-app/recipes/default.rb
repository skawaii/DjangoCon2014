#
# Cookbook Name:: poll-app
# Recipe:: default
#
# Copyright (C) 2014 YOUR_NAME
#
# All rights reserved - Do Not Redistribute
#
include_recipe "postgres"

# CREATE POSTGRESQL USER
pg_user "polluser" do
  privileges superuser: false, createdb: false, login: true
  password "polluserpwd"
end

# CREATE POSTGRES DB
pg_database "polldb" do
  owner "polluser"
  encoding "UTF-8"
  template "template0"
  locale "en_US.UTF-8"
end

# LOAD THE DB WITH DATA
bash "load_database" do
  user "vagrant"
  cwd "/vagrant/src"
  code <<-EOH
  PGPASSWORD=polluserpwd ./scripts/load_demo_database.sh
  EOH
end

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

# SET THE DEFAULT NGINX CONF FILE
template "/etc/nginx/sites-available/default" do
  owner "root"
  group "root"
  mode 0644
  source "default_site.nginx.erb"
end

# RELOAD NGINX SERVICE
bash "reload_nginx" do
  code <<-EOH
  sudo service nginx reload
  EOH
end
