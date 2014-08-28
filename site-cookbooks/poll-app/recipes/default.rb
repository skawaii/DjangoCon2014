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

# POSTGRESQL STUFF
pg_user "polluser" do
  privileges superuser: false, createdb: false, login: true
  password "polluserpwd"
end

pg_database "polldb" do
  owner "polluser"
  encoding "UTF-8"
  template "template0"
  locale "en_US.UTF-8"
end

bash "load_database" do
  user "vagrant"
  cwd "/vagrant/src"
  code <<-EOH
  PGPASSWORD=polluserpwd ./scripts/load_demo_database.sh
  EOH
end

# PYTHON STUFF
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
