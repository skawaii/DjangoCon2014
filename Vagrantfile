# -*- mode: ruby -*-
# vi: set ft=ruby :

require 'chef'
require 'json'

Chef::Config.from_file(File.join(File.dirname(__FILE__), '.chef', 'knife.rb'))
vagrant_json = JSON.parse(Pathname(__FILE__).dirname.join('nodes', (ENV['NODE'] || 'polls.example.com.json')).read)

VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = "precise64"
  config.vm.network :forwarded_port, guest: 80, host: 8080
  config.vm.network :forwarded_port, guest: 8000, host: 8000

  config.omnibus.chef_version = :latest
  config.berkshelf.enabled = true

  config.vm.provision "chef_solo" do |chef|
    chef.roles_path = Chef::Config["role_path"]
    chef.data_bags_path = Chef::Config["data_bag_path"]
    chef.environments_path = Chef::Config["environment_path"]
    chef.environment = ENV['ENVIRONMENT'] || 'development'

    chef.run_list = vagrant_json.delete('run_list')
    chef.json = vagrant_json
  end

end
