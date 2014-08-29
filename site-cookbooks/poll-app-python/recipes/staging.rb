#
# Cookbook Name:: poll-app-python
# Recipe:: default
#
# Copyright (C) 2014 YOUR_NAME
#
# All rights reserved - Do Not Redistribute
#

# INSTALLING PYTHON STUFF
bash "install_requirements-dev.txt" do
  user "vagrant"
  cwd "/vagrant/src/"
  code <<-EOH
  . /home/vagrant/polls_ve/bin/activate && pip install -r requirements/requirements-staging.txt
  mkdir -p static
  . /home/vagrant/polls_ve/bin/activate && ./manage.py collectstatic -c --noinput
  EOH
end
