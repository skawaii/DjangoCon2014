#
# Cookbook Name:: poll-app-nginx
# Recipe:: default
#
# Copyright (C) 2014 YOUR_NAME
#
# All rights reserved - Do Not Redistribute
#

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
