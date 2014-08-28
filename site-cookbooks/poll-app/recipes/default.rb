#
# Cookbook Name:: poll-app
# Recipe:: default
#
# Copyright (C) 2014 YOUR_NAME
#
# All rights reserved - Do Not Redistribute
#
package "python-psycopg2"

include_recipe "postgres"
include_recipe "python"

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

# CREATE A VIRTUALENV
python_virtualenv "/home/vagrant/polls_ve" do
  owner "vagrant"
  group "vagrant"
  action :create
end

# INSTALLING PYTHON STUFF
bash "install_requirements.txt" do
  user "vagrant"
  cwd "/vagrant/"
  code <<-EOH
  . /home/vagrant/polls_ve/bin/activate && pip install -r requirements/requirements.txt
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
