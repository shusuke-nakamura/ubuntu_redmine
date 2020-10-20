# -*- mode: ruby -*-
# vi: set ft=ruby :

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure("2") do |config|
  # The most common configuration options are documented and commented below.
  # For a complete reference, please see the online documentation at
  # https://docs.vagrantup.com.

  # Every Vagrant development environment requires a box. You can search for
  # boxes at https://vagrantcloud.com/search.
  config.vm.box = "bento/ubuntu-20.04"
  config.vm.box_version = "202010.14.0"

  # Disable automatic box update checking. If you disable this, then
  # boxes will only be checked for updates when the user runs
  # `vagrant box outdated`. This is not recommended.
  # config.vm.box_check_update = false

  # Create a forwarded port mapping which allows access to a specific port
  # within the machine from a port on the host machine. In the example below,
  # accessing "localhost:8080" will access port 80 on the guest machine.
  # NOTE: This will enable public access to the opened port
  # config.vm.network "forwarded_port", guest: 80, host: 8080

  # Create a forwarded port mapping which allows access to a specific port
  # within the machine from a port on the host machine and only allow access
  # via 127.0.0.1 to disable public access
  config.vm.network "forwarded_port", guest: 22, host: 1234, id: 'ssh'
  config.vm.network "forwarded_port", guest: 80, host: 10081, id: 'apache'
  config.vm.network "forwarded_port", guest: 3000, host: 13001, id: 'rails'
  
  #config.ssh.insert_key = false
  #config.ssh.username = 'vagrant'
  #config.ssh.password = 'vagrant'

  # Create a private network, which allows host-only access to the machine
  # using a specific IP.
  config.vm.network "private_network", ip: "192.168.33.11"

  # Create a public network, which generally matched to bridged network.
  # Bridged networks make the machine appear as another physical device on
  # your network.
  # config.vm.network "public_network"

  # Share an additional folder to the guest VM. The first argument is
  # the path on the host to the actual folder. The second argument is
  # the path on the guest to mount the folder. And the optional third
  # argument is a set of non-required options.
  # config.vm.synced_folder "../data", "/vagrant_data"

  # Provider-specific configuration so you can fine-tune various
  # backing providers for Vagrant. These expose provider-specific options.
  # Example for VirtualBox:
  #
  # config.vm.provider "virtualbox" do |vb|
  #   # Display the VirtualBox GUI when booting the machine
  #   vb.gui = true
  #
  #   # Customize the amount of memory on the VM:
  #   vb.memory = "1024"
  # end
  #
  # View the documentation for the provider you are using for more
  # information on available options.
  config.vm.provider "virtualbox" do |vb|
    vb.customize ["setextradata", :id, "VBoxInternal2/SharedFoldersEnableSymlinksCreate/vagrant", "1"]
  end

  # Enable provisioning with a shell script. Additional provisioners such as
  # Ansible, Chef, Docker, Puppet and Salt are also available. Please see the
  # documentation for more information about their specific syntax and use.
  # config.vm.provision "shell", inline: <<-SHELL
  #   apt-get update
  #   apt-get install -y apache2
  # SHELL
  config.vm.provision :shell, privileged: false, inline: $script
end
$script = <<SCRIPT
######################################################################
# パッケージの更新
sudo apt-get update
sudo apt-get upgrade

# 日本語環境の作成
sudo locale-gen ja_JP.UTF-8

# 起動時に日本語設定で起動する
LOCALE_SETTING=`grep ja_JP.UTF-8 ~/.profile | wc -l`
if [ $LOCALE_SETTING -eq 0 ]
then
    echo export LANG=ja_JP.UTF-8 >> ~/.profile
fi

# デフォルトのタイムゾーンUTC ⇒ JSTに変更する
sudo timedatectl set-timezone Asia/Tokyo

#####################################################################
# マニュアルを日本語化
#####################################################################
MANPAGES_JA_INSTALLED=`sudo dpkg -l | grep manpages-ja | wc -l`
if [ $MANPAGES_JA_INSTALLED -eq 0 ]
then
    sudo apt-get install -y manpages-ja manpages-ja-dev
fi
#####################################################################
# ビルドツールのインストール
#####################################################################
BUILD_TOOL_INSTALLED=`sudo dpkg -l | grep build-essential | wc -l`
if [ $BUILD_TOOL_INSTALLED -eq 0 ]
then
    sudo apt-get install -y build-essential zlib1g-dev libssl-dev libreadline-dev libyaml-dev libcurl4-openssl-dev libffi-dev expect
fi
#####################################################################
# PostgreSQLのインストール
#####################################################################
POSTGRE_SQL_INSTALLED=`sudo dpkg -l | grep postgresql | wc -l`
if [ $POSTGRE_SQL_INSTALLED -eq 0 ]
then
    sudo apt-get install -y postgresql libpq-dev
fi
#####################################################################
# Apacheのインストール
#####################################################################
APACHE_INSTALLED=`sudo dpkg -l | grep apache2 | wc -l`
if [ $APACHE_INSTALLED -eq 0 ]
then
    sudo apt-get install -y apache2 apache2-dev
fi
#####################################################################
# 日本語フォントのインストール
#####################################################################
IMAGE_MAGIC_INSTALLED=`sudo dpkg -l | grep imagemagick | wc -l`
if [ $IMAGE_MAGIC_INSTALLED -eq 0 ]
then
    sudo apt-get install -y imagemagick fonts-takao-pgothic
fi
#####################################################################
# subversionのインストール
#####################################################################
SVN_INSTALLED=`sudo dpkg -l | grep subversion | wc -l`
if [ $SVN_INSTALLED -eq 0 ]
then
    sudo apt-get install -y subversion
fi
#####################################################################
# gitのインストール
#####################################################################
GIT_INSTALLED=`sudo dpkg -l | grep git | wc -l`
if [ $GIT_INSTALLED -eq 0 ]
then
    sudo apt-get install -y git
fi
#####################################################################
# Ruby2.6.6のインストール
#####################################################################
# rbenvのインストール
if [ ! -f /usr/local/bin/ruby ]
then
    curl -O https://cache.ruby-lang.org/pub/ruby/2.6/ruby-2.6.6.tar.gz
    tar xvf ruby-2.6.6.tar.gz
    cd ruby-2.6.6
    ./configure --disable-install-doc
    make
    sudo make install
    cd ..
fi
#####################################################################
# Redmineのインストール
#####################################################################
RED_PW="redmine"
if [ ! -d /var/lib/redmine ]
then
    # PostgreSQL Redmine用ユーザの作成
    bash /vagrant/create_redmine_user.sh
    bash /vagrant/create_db.sh
    # Redmineの配置(SVN)
    sudo mkdir /var/lib/redmine
    sudo chown www-data:www-data /var/lib/redmine
    sudo -u www-data svn co https://svn.redmine.org/redmine/branches/4.1-stable /var/lib/redmine
fi
if [ ! -f /var/lib/redmine/config/database.yml ]
then
    sudo cp /vagrant/database.yml /var/lib/redmine/config/database.yml
    sudo chown www-data:www-data /var/lib/redmine/config/database.yml
    sudo chmod 664 /var/lib/redmine/config/database.yml
fi
if [ ! -f /var/lib/redmine/config/configuration.yml ]
then
    sudo cp /vagrant/configuration.yml /var/lib/redmine/config/configuration.yml
    sudo chown www-data:www-data /var/lib/redmine/config/configuration.yml
    sudo chmod 664 /var/lib/redmine/config/configuration.yml
fi
if [ ! -d /var/lib/redmine/vendor/bundle ]
then
    cd /var/lib/redmine
    sudo -u www-data bundle install --without development test --path vendor/bundle
    sudo -u www-data bin/rake generate_secret_token
    sudo -u www-data RAILS_ENV=production bin/rake db:migrate
fi
#####################################################################
# Passengerのインストール
#####################################################################
PASSENGER_INSTALLED=`sudo gem list | grep passenger | wc -l`
if [ $PASSENGER_INSTALLED -eq 0 ]
then
    sudo gem install passenger -N
    sudo passenger-install-apache2-module --auto --languages ruby
fi
if [ ! -f /etc/apache2/conf-available/redmine.conf ]
then
    sudo cp /vagrant/redmine.conf /etc/apache2/conf-available/redmine.conf
    sudo chmod 644 /etc/apache2/conf-available/redmine.conf
    sudo a2enconf redmine
    apache2ctl configtest
    sudo systemctl reload apache2
fi

SCRIPT
