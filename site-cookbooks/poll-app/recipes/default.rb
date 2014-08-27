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

# This is for creating a user
pg_user "polluser" do
  privileges superuser: false, createdb: false, login: true
  password "polluserpwd"
end

# This is for creating a database
pg_database "polldb" do
  owner "polluser"
  encoding "UTF-8"
  template "template0"
  locale "en_US.UTF-8"
end

# PYTHON STUFF
python_virtualenv "/home/vagrant/polls_ve" do
  owner "vagrant"
  group "vagrant"
  action :create
end
