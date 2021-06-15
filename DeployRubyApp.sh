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
sudo usermod -a -G rvm myappuser
sudo -u myappuser -H bash -l
# source /etc/profile.d/rvm.sh
# rvm use ruby-2.5.1
# rvm install ruby-2.5.0  && rvm --default use ruby-2.5.0
# rvm install ruby-2.5.1  && rvm --default use ruby-2.5.1
# gem install json -v '1.8.2' --source 'https://rubygems.org/'
# gem install rake -v '10.4.2' --source 'https://rubygems.org/'
bundle update json
exit

# 2.2 Install app dependencies
sudo chown myappuser: /var/www/myapp
sudo -u myappuser -H bash -l
cd /var/www/myapp/code && 
bundle install
# --path ./vendor/bundle/
# --deployment --without development test

# 2.3 Configure database.yml and secrets.yml
nano config/database.yml
# bundle exec rake secret
nano config/secrets.yml
chmod 700 config db && 
chmod 600 config/database.yml config/secrets.yml

# 2.4 Compile Rails assets and run database migrations
bundle exec rake assets:precompile db:migrate RAILS_ENV=production

# 3 Configuring Apache and Passenger
# 3.1 Determine the Ruby command that Passenger should use
passenger-config about ruby-command
# Out: ommand: /usr/local/rvm/gems/ruby-2.5.1/wrappers/ruby

# 3.2 Go back to the admin account
exit

# 3.3 Edit Apache configuration file
# sudo nano /etc/apache2/sites-enabled/myapp.conf
# sudo nano /etc/httpd/conf.d/myapp.conf
git clone https://github.com/plx01/lmssetup ~/02l
sudo cp ~/02l/myapp.conf /etc/apache2/sites-enabled/myapp.conf
sudo service apache2 restart && sudo service apache restart

# 3.4 Test drive
curl http://phucenter.net/

