#
# Cookbook Name:: poll-app-python
# Recipe:: default
#
# Copyright (C) 2014 YOUR_NAME
#
# All rights reserved - Do Not Redistribute
#
package "python-psycopg2"

include_recipe "python"

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
