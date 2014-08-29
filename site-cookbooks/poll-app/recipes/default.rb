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
