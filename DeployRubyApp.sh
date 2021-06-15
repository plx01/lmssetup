#!/bin/bash
# Deploying a Ruby app on Digital Ocean production server
# git clone https://github.com/plx01/lmssetup ~/01l
# sudo cp ~/01l/DeployRubyApp.sh ~/dra.sh
# sudo chmod +x ~/dra.sh  && sudo ~/dra.sh

# 1 Transferring the app code to the server

1.1 Push your code to a Git repository
git push

# 1.2 Login to your server, create a user for the app
# ssh adminuser@yourserver.com
sudo adduser myappuser  && 
sudo mkdir -p ~myappuser/.ssh  && 
touch $HOME/.ssh/authorized_keys
sudo sh -c "cat $HOME/.ssh/authorized_keys >> ~myappuser/.ssh/authorized_keys"
sudo chown -R myappuser: ~myappuser/.ssh  &&
sudo chmod 700 ~myappuser/.ssh  &&
sudo sh -c "chmod 600 ~myappuser/.ssh/*"

# 1.3 Install Git on the server - Debian, Ubuntu
sudo apt-get install -y git

# 1.4 Pull code
sudo mkdir -p /var/www/myapp  && 
sudo chown myappuser: /var/www/myapp
cd /var/www/myapp  && 
sudo -u myappuser -H git clone --branch=end_result https://github.com/phusion/passenger-ruby-rails-demo.git code
sudo usermod -a -G sudo myappuser

# 2 Preparing the app's environment

# 2.1 Login as the app's user
sudo -u myappuser -H bash -l
# source /etc/profile.d/rvm.sh
# rvm use ruby-2.5.1
# rvm insatall ruby-2.5.0  && rvm --default use ruby-2.5.0
gem install json -v '1.8.2' --source 'https://rubygems.org/'
exit

# 2.2 Install app dependencies
sudo chown myappuser: /var/www/myapp
sudo -u myappuser -H bash -l
cd /var/www/myapp/code && 
bundle install
# --path ./vendor/bundle/
# --deployment --without development test
