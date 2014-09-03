**  **

## Vagrant, chef-solo and a Django Project

### Ramon Maria Gallart

This is a novice-level tutorial-like document. Its goal is to serve as a first entry-point to create a re-usable machine to develop Django projects, so that it can be spun up in minutes by any developer team member in your team. Or whoever you want.



Table of Contents



# Main Goal

This is a very straightforward step-by-step tutorial walkthrough that will guide you in the process of spinning up a development machine to work with a Django project using Virtualbox, Vagrant and Chef-solo. The Django project is the Polls app from the [Django tutorial](https://docs.djangoproject.com/en/1.6/).

We will not explain here how to develop a Django project. Just our experience on what do you need to use Chef-solo with a Django project.

# What do we need

Install [Virtualbox](https://www.virtualbox.org/wiki/Downloads) and [Vagrant](https://www.vagrantup.com/downloads) if you haven't already done so.

Virtualbox allows us to install VMs to our system. Vagrant acts as a wrapper to Virtualbox (and many others) and allows us to configure the VMs using a Ruby script named Vagrantfile in an easy way. It should be easy to locate and install a version for your OS.

Install [ChefDK](https://downloads.getchef.com/chef-dk/). This will install Chef (but not Chef-solo) along commonly used commands (knife, berks…)

Install Bundler. Bundler allows us to install Ruby gems and its dependencies on our system:

    $ sudo gem install bundler

Install chef plugin, berkshelf plugin and vagrant-omnibus too for Vagrant if they are not installed. They can take a bit of a long time:

    $ vagrant plugin install chef

    $ vagrant plugin install vagrant-berkshelf --plugin-version 2.0.1

    $ vagrant plugin install vagrant-omnibus


The chef plugin will allow us to use some Chef modules from inside the Vagrantfile.

Vagrant-berkshelf will run Berkshelf automatically each time the Vagrantfile is loaded, thus downloading all the cookbooks defined in the Berksfile.

Vagrant-omnibus, installs the chef-client inside he VM and runs it once the VM loads up.

# Getting your hands dirty

Create a directory for the project:

    $ mkdir ~/projects/django-con

    $ cd django-con

Initialize a Vagrant machine:

    $ vagrant init precise64

Resulting file (comments omitted)

    # -*- mode: ruby -*-
    # vi: set ft=ruby :

    VAGRANTFILE_API_VERSION = "2"

    Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
      config.vm.box = "precise64"
      config.omnibus.chef_version = :latest
      config.berkshelf.enabled = true
    end

Create a file named Gemfile:

    $ cd ~/projects/django-con

    $ vim Gemfile

And write this content in it:

    source "https://rubygems.org"

    gem 'knife-solo'

This will instruct bundle to install the open source tool knife-solo.

    $ cd ~/projects/django-con

    $ bundle install

At this point we will have the chef-solo gem installed. chef-solo will create a base infrastructure to develop our own cookbooks or download already created ones.

So, in order to continue creating our environment we need to initialize the kitchen!

    $ cd ~/projects/django-con

    $ knife solo init .

Once this command has ran, we have the following directory infrastructure:

    ramonmariagallart@Olympos $ ll -a
    total 32
    drwxr-xr-x 14 ramonmariagallart staff 476B 21 ago 16:36 ./
    drwxr-xr-x 11 ramonmariagallart staff 374B 21 ago 16:14 ../
    drwxr-xr-x 3 ramonmariagallart staff 102B 21 ago 16:36 .chef/
    -rw-r--r-- 1 ramonmariagallart staff 12B 21 ago 16:36 .gitignore
    drwxr-xr-x 3 ramonmariagallart staff 102B 21 ago 16:19 .vagrant/
    -rw-r--r-- 1 ramonmariagallart staff 48B 21 ago 16:32 Gemfile
    -rw-r--r-- 1 ramonmariagallart staff 1,8K 21 ago 16:36 Gemfile.lock
    -rw-r--r-- 1 ramonmariagallart staff 238B 21 ago 16:25 Vagrantfile
    drwxr-xr-x 3 ramonmariagallart staff 102B 21 ago 16:36 cookbooks/
    drwxr-xr-x 3 ramonmariagallart staff 102B 21 ago 16:36 data_bags/
    drwxr-xr-x 3 ramonmariagallart staff 102B 21 ago 16:36 environments/
    drwxr-xr-x 3 ramonmariagallart staff 102B 21 ago 16:36 nodes/
    drwxr-xr-x 3 ramonmariagallart staff 102B 21 ago 16:36 roles/
    drwxr-xr-x 3 ramonmariagallart staff 102B 21 ago 16:36 site-cookbooks/

A detailed description of every directory is out of this HOWTO scope. Just say that:

- .chef/: has the file knife.rb which will have default constants that we will use in the Vagrantfile
- cookbooks/: contains third-party cookbooks that will be downloaded by Berkshelf
- data_bags/ environments/ nodes/ roles/: JSON file definitions for each one of those
- site-cookbooks/: this will keep our own cookbooks
- .gitignore: at creation time it only has /cookbooks/ as we are not interested in keeping them in a CVS

Following we create a Berksfile. In that file we will enumerate the cookbooks we want to use on our environment. Berkshelf will take into account the different dependencies existing between the cookbooks we need and automatically downloading those that are necessary:

    $ cd ~/projects/django-con

    $ vim Berksfile

Arguably the best resource to find cookbooks is the [Chef supermarket](https://supermarket.getchef.com/) web, as we can be pretty sure that the cookbooks held in there are regularly updated and mantained. Nevertheless there are other resources where we can find very good cookbooks (if not better). One of those resources is Github (or for what matters, any git repository). Luckily enough, the Berksfile file format allows us to download cookbooks from the supermarket repository and from git repositories and even from local paths.

That said, lets write this into the file:

    source "https://supermarket.getchef.com/"
    cookbook 'apt', '~> 2.5.2'
    cookbook 'nginx', '~> 2.7.4'
    cookbook "postgresql", git: 'https://github.com/phlipper/chef-postgresql.git'
    cookbook 'python', '~> 1.4.6'
    cookbook 'supervisor', '~> 0.4.12'

If we start the environment up now we will see that none of these cookbooks are getting installed. This is because we have to tell Vagrant (specifically indicate to it inside the Vagrantfile) which cookbooks must be installed.

To that end we will modify our Vagrantfile until it looks something like this:

    # -*- mode: ruby -*-
    # vi: set ft=ruby :

    require 'chef'
    require 'json'

    Chef::Config.from_file(File.join(File.dirname(__FILE__), '.chef', 'knife.rb'))
    vagrant_json = JSON.parse(Pathname(__FILE__).dirname.join('nodes', (ENV['NODE'] || 'polls.example.com.json')).read)
    environment_node = (ENV['NODE'] || 'polls.example.com.json')

    VAGRANTFILE_API_VERSION = "2"

    Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
      config.vm.box = "precise64"
      config.vm.network :forwarded_port, guest: 80, host: 8080 if environment_node == 'staging-polls.example.com.json'
      config.vm.network :forwarded_port, guest: 8000, host: 8000 if environment_node == 'polls.example.com.json'
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

As said before, Vagrantfile is a Ruby script and we can take advantage of that. We set up the Config object from the Chef module to include the data that is inside the file ./.chef/knife.rb.

We load too a node named 'polls.example.com.json' from which we still have not talked about. Next we forward the our host's ports 80 and 8000 to our guest machine's port 8080 and 8000 respectively. But we do that depending on what node will be used. By default, in the case of no defining any node, the development node is used. When spinning up the vagrant machine we can load up the development or the staging machine just switching between those two commands:

    $ NODE=polls.example.com.json vagrant up # spins up the development machine

or

    $ NODE=staging-polls.example.com.json vagrant up # spins up the staging machine

Finally we configure Vagrant's chef_solo provisioner indicating where it can find different resources.

# Nodes

Nodes in Chef refer to different machines in our environment. We can configure different environments too. For that HOWTO we've named our main development node 'polls.example.com' and we have to create a file named 'development.json' in the environments/ directory and another one named 'polls.example.com.json' inside our nodes/ directory. On the repo you will find another node file named staging-polls.example.com.json. It uses more recipes than polls.example.com.json and it is included as a demonstration on how to have more than one node for us to test different environments.

So, lets create the files:

    $ cd ~/projects/django-con/environments/

    $ vim development.json

This is the content for the file:

    {
        "name": "development",
        "description": "development environment",
        "chef_type": "environment",
        "json_class": "Chef::Environment"
    }

One of the parameters that this file may contain is "default_attributes" which we can leverage in order to modify some attributes of the downloaded cookbooks.

    $ cd ~/projects/django-con/nodes/

    $ vim polls.example.com.json

Write in the following content:

    {
        "environment": "development",
        "run_list": [
            "recipe[apt]",
            "recipe[vim]",
            "recipe[git]",
            "recipe[postgresql]",
            "recipe[postgresql::server]",
            "recipe[postgresql::client]",
            "recipe[postgresql::server\_dev]",
            "recipe[python]"
        ]
    }

As we can see, inside the file we define this node to belong to the development environment and a "run_list". This list contains the recipes we want to run for this node. **It is important to mention that recipes are executed in the same order found in the list** .

So the next step is to provision our environment with those recipes:

    $ vagrant up # if it is not already up

    $ vagrant provision # so chef will run and install all the recipes

We can make a minimal check in order to know if everything went OK. The first thing to look at is the output produced by the vagrant provision command. No errors? Cool! Another thing we can try is vagrant ssh into the VM and execute psql. It should return an error saying there is no "vagrant" role. That's fine for now, we have not created any user for Postgres, but it got installed! You can check further:

    $ vagrant ssh

    $ sudo -u postgres psql

You should see something like that:

    psql (9.3.5)

    Type "help" for help.

    postgres=#

Hooray! The server got installed too!

Anyway, this will just install the software that we need in order to run our application. The next step is to create our own cookbook that will configure all of this software so that it will run as we intend it to do it.

# Creating our own cookbook for fun and profit

The goal creating our own cookbook is to manage configuration for our environment the way we want it to be. This can be achieved mainly in two different ways:

- Create a new cookbook and use recipes, resources and attributes from other already downloaded cookboks
- Create a new cookbook and set your own scripts to do the things you need

## The postgresql cookbook

Anyway, we need to create a new cookbook. So, to create it:

    $ cd ~/projects/django-con/site-cookbooks/

    $ berks cookbook poll-app

This will create poll_app cookbook with this directory structure:

    ramonmariagallart@Olympos $ ls -la poll-app/
    total 88
    drwxr-xr-x 22 ramonmariagallart staff 748B 21 ago 18:21 ./
    drwxr-xr-x 4 ramonmariagallart staff 136B 21 ago 18:21 ../
    drwxr-xr-x 10 ramonmariagallart staff 340B 21 ago 18:21 .git/
    -rw-r--r-- 1 ramonmariagallart staff 155B 21 ago 18:21 .gitignore
    -rw-r--r-- 1 ramonmariagallart staff 173B 21 ago 18:21 .kitchen.yml
    -rw-r--r-- 1 ramonmariagallart staff 51B 21 ago 18:21 Berksfile
    -rw-r--r-- 1 ramonmariagallart staff 99B 21 ago 18:21 CHANGELOG.md
    -rw-r--r-- 1 ramonmariagallart staff 449B 21 ago 18:21 Gemfile
    -rw-r--r-- 1 ramonmariagallart staff 72B 21 ago 18:21 LICENSE
    -rw-r--r-- 1 ramonmariagallart staff 850B 21 ago 18:21 README.md
    -rw-r--r-- 1 ramonmariagallart staff 241B 21 ago 18:21 Thorfile
    -rw-r--r-- 1 ramonmariagallart staff 3,3K 21 ago 18:21 Vagrantfile
    drwxr-xr-x 2 ramonmariagallart staff 68B 21 ago 18:21 attributes/
    -rw-r--r-- 1 ramonmariagallart staff 960B 21 ago 18:21 chefignore
    drwxr-xr-x 3 ramonmariagallart staff 102B 21 ago 18:21 files/
    drwxr-xr-x 2 ramonmariagallart staff 68B 21 ago 18:21 libraries/
    -rw-r--r-- 1 ramonmariagallart staff 248B 21 ago 18:21 metadata.rb
    drwxr-xr-x 2 ramonmariagallart staff 68B 21 ago 18:21 providers/
    drwxr-xr-x 3 ramonmariagallart staff 102B 21 ago 18:21 recipes/
    drwxr-xr-x 2 ramonmariagallart staff 68B 21 ago 18:21 resources/
    drwxr-xr-x 3 ramonmariagallart staff 102B 21 ago 18:21 templates/
    drwxr-xr-x 3 ramonmariagallart staff 102B 21 ago 18:21 test/

The first thing we have to do is update the metadata.rb file which contains main information about the cookbook.

    $ cd cd ~/projects/django-con/site-cookbooks/poll-app/

    $ vim metadata.rb

And we can leave it like this:

    name 'poll-app'
    maintainer 'Ramon Maria Gallart'
    maintainer_email 'rgallart@ramagaes.com'
    license 'MIT'
    description 'Installs/Configures poll-app'
    long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
    version '0.1.0'

Pretty self-explanatory. For the long-description we will insert the contents of the README.md file contained in the same directory as metadata.rb.

OK. So now it's time to use some of the other downloaded recipes the way we want. For example, we would like to create a user and a database for our PostgreSQL. How can we do that?

First of all, we do have to add our recently created cookbook to our run_list for the node we want it to be ran:

    # nodes/polls.example.com.json
    ...
            "recipe[python]",
            "recipe[supervisor]",
            "recipe[poll-app]"
        ]
    }

But this is the first step of two. We have to modify our Berksfile like this:

    # ./Berksfile
    ...
    postgresql.git'
    cookbook 'python', '~> 1.4.6'
    cookbook 'supervisor', '~> 0.4.12'
    cookbook 'poll-app', path: "./site-cookbooks/poll-app"

Doing that we ensure ourselves that Chef will be able to find our cookbook.

After that two-step procedure, if we want our cookbook to use some of the other already downloaded cookbooks we have to tell it we want to do so. First, in the metadata.rb file in our cookbook we include a line like this:

    # metadata.rb
    ...
    depends "postgres"

And then, in our recipe.rb file:

    # recipes/default.rb
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

With that script we will create a polluser on our database with login permissions and a polldb database whose owner is the polluser previously created.

Run vagrant provision or vagrant up --provision followed by vagrant ssh and check that the user and the database have been correctly created:

    $ psql -d polldb -Upolluser -W

    Password for user polluser:

    psql (9.3.5)

    Type "help" for help.

    polldb=>

Cool! We can see that the user has been created as well as the database!

## The python cookbook

So, what's our next step? If we want to develop a Django app it is common to use tools like pip and virtualenv. The previous python cookbook allows us to install and use those two pieces of software. Lets create a new cookbook to manage that:

    $ cd ~/projects/django-con/site-cookbooks/

    $ berks cookbook poll-app-python

In the recipes/metadata.rb we will write the following code:

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

What we are instructing chef-solo to do here is that we want to install "python-psycopg2" if it is not already. After that we state that we will need recipes inside the "python" cookbook.

So, with that we create a virtualenv using the python_virtualenv LWRP from the python cookbook. The virtualenv gets created at /home/vagrant/polls_ve.

Next we use the bash resource provided by chef to install the requirements needed by the app. The bash resource allows us to run bash scripts from our recipes. To do that we need to state under which user the script will be ran, what's the working directory and the command to run.

As the poll-app cookbook we have to declare our new recipe to the Berksfile and add it to the polls.example.com.json node file:

    # nodes/polls.example.com.json
    ...
            "recipe[python]",
            "recipe[supervisor]",
            "recipe[poll-app]",
            "recipe[poll-app-python]"
        ]
    }

But, remember, this is the first step of two. We have to modify our Berksfile like this:

    # ./Berksfile
    ...
    postgresql.git'
    cookbook 'python', '~> 1.4.6'
    cookbook 'supervisor', '~> 0.4.12'
    cookbook 'poll-app', path: "./site-cookbooks/poll-app"
    cookbook 'poll-app', path: "./site-cookbooks/poll-app-python"

Lets check if that works! As before, run first vagrant provision or vagrant up --provision and then vagrant ssh.

    vagrant@precise64:~$ pwd
    /home/vagrant
    vagrant@precise64:~$ . polls_ve/bin/activate
    (polls_ve)vagrant@precise64:~$ cd /vagrant/src/
    (polls_ve)vagrant@precise64:/vagrant/src$ ./manage.py shell
    Python 2.7.3 (default, Feb 27 2014, 19:58:35)
    Type "copyright", "credits" or "license" for more information.
    IPython 2.2.0 -- An enhanced Interactive Python.
    ? -> Introduction and overview of IPython's features.
    %quickref -> Quick reference.
    help -> Python's own help system.
    object? -> Details about 'object', use 'object??' for extra details.

    In [1]: import django

    In [2]: django.VERSION

    Out[2]: (1, 6, 6, 'final', 0)

    In [3]: quit
    (polls_ve)vagrant@precise64:/vagrant/src$

Great! All the requirements have been installed and seems like we are now ready to work with the app running it from the VM and editing from our preferred editor in our host machine!

Lets start the runserver:

    (polls_ve)vagrant@precise64:/vagrant/src$ ./manage.py runserver 0.0.0.0:8000
    Validating models...
    0 errors found
    September 01, 2014 - 11:54:26
    Django version 1.6.6, using settings 'mysite.settings'
    Starting development server at http://0.0.0.0:8000/
    Quit the server with CONTROL-C.

    [01/Sep/2014 11:54:46] "GET /polls HTTP/1.1" 301 0
    [01/Sep/2014 11:54:46] "GET /polls/ HTTP/1.1" 200 173
    [01/Sep/2014 11:54:46] "GET /static/polls/style.css HTTP/1.1" 200 27

And, effectively, we can see the iconic Polls app on our browsers:

 ![](data:image/*;base64,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)

# Things left behind

- Data bags
- Resources and providers
- Cookbook testing

# Resources

## Info and tutorials about chef and chef-solo
- [http://chef.leopard.in.ua/](http://chef.leopard.in.ua/)
- [http://blog.smalleycreative.com/tutorials/setup-a-django-vm-with-vagrant-virtualbox-and-chef/](http://blog.smalleycreative.com/tutorials/setup-a-django-vm-with-vagrant-virtualbox-and-chef/)
- [http://tumblr.nrako.com/post/22320729770/vagrant-chef-librarian](http://tumblr.nrako.com/post/22320729770/vagrant-chef-librarian)
- [http://stackoverflow.com/questions/11325479/how-to-control-the-version-of-chef-that-vagrant-uses-to-provision-vms](http://stackoverflow.com/questions/11325479/how-to-control-the-version-of-chef-that-vagrant-uses-to-provision-vms)
- [http://www.getchef.com/blog/2013/12/03/doing-wrapper-cookbooks-right/](http://www.getchef.com/blog/2013/12/03/doing-wrapper-cookbooks-right/)

## Tools
- [Vagrant](http://www.vagrantup.com/)
- [Virtualbox](https://www.virtualbox.org/wiki/Downloads)
- [ChefDK](https://downloads.getchef.com/chef-dk/)
- [Git](http://git-scm.com/download/mac)
- [Berkshelf](http://berkshelf.com/)
- [Chef Supermarket](https://supermarket.getchef.com/)
