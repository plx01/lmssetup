#!/bin/bash
################################################################################
# Script for setup lms on Ubuntu 14.04, 15.04, 16.04 and 18.04 (could be used 
# for other version too)
# Author: 
#-------------------------------------------------------------------------------
# This script will setup lms
#-------------------------------------------------------------------------------
# Make a new file:
# sudo nano lmssetup.sh
# Place this content in it and then make the file executable:
# or Download: sudo wget https://raw.githubusercontent.com/plx01/lmssetup.sh
# sudo chmod +x lmssetup.sh
# Execute the script to setup lms:
# ./lmssetup.sh
################################################################################
# sudo groupadd -g 10000 canvasuser
# sudo groupadd canvasuser
# sudo tail /etc/group
# sudo adduser canvas canvasuser
# sudo adduser sysadmin canvasuser
#--------------------------------------------------
# Update Server
#--------------------------------------------------
echo -e "\n---- Update Server ----"
# universe package is for Ubuntu 18.x
sudo add-apt-repository universe
# libpng12-0 dependency for wkhtmltopdf
sudo add-apt-repository "deb http://mirrors.kernel.org/ubuntu/ xenial main"
sudo apt-get update && sudo apt-get upgrade -y

#--------------------------------------------------
# Installing Postgres
#--------------------------------------------------
sudo apt-get install postgresql
# createuser will prompt you for a password for database user
sudo -u postgres createuser canvas --no-createdb --no-superuser --no-createrole --pwprompt
sudo -u postgres createdb canvas_production --owner=canvas

sudo -u postgres createuser $USER
sudo -u postgres psql -c "alter user $USER with superuser" postgres

#--------------------------------------------------
# Getting the code
#--------------------------------------------------
# Using Git
sudo apt-get install git-core
git clone https://github.com/instructure/canvas-lms.git ~/canvas
cd ~/canvas && git checkout stable

#--------------------------------------------------
# Code installation
#--------------------------------------------------
sudo mkdir -p /var/canvas  && sudo chown -R $USER /var/canvas
cd ~/canvas && ls  && cp -av . /var/canvas
cd /var/canvas  && ls

#--------------------------------------------------
# Dependency Installation
#--------------------------------------------------
sudo apt-get install software-properties-common
sudo add-apt-repository ppa:brightbox/ruby-ng  && sudo apt-get update
# Install Ruby 2.6
# sudo apt-get install ruby2.6 ruby2.6-dev zlib1g-dev libxml2-dev libsqlite3-dev postgresql libpq-dev libxmlsec1-dev curl make g++
sudo apt-get install ruby2.6 ruby2.6-dev zlib1g-dev libxml2-dev \
                       libsqlite3-dev postgresql libpq-dev \
                       libxmlsec1-dev curl make g++
# Node.js installation
curl -sL https://deb.nodesource.com/setup_14.x | sudo -E bash -
sudo apt-get install nodejs  && sudo npm install -g npm@latest

#--------------------------------------------------
# Ruby Gems
#--------------------------------------------------

#--------------------------------------------------
# Bundler and Canvas dependencies
#--------------------------------------------------
sudo gem install bundler --version 2.2.17
# bundle _2.2.15_ install --without pulsar --path vendor/bundle
# bundle _2.2.15_ install 
bundle config set path 'vendor/bundle'  && bundle config set --local without 'pulsar'
sudo chown -R $USER /var/canvas
bundle install
#--------------------------------------------------
# Yarn Installation
#--------------------------------------------------
curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
sudo apt-get update  && sudo apt-get install yarn=1.19.1-1

sudo apt-get install python

sudo chown -R $USER /home/$USER
yarn install

#--------------------------------------------------
# Canvas default configuration
#--------------------------------------------------
# for config in amazon_s3 database delayed_jobs domain file_store outgoing_mail security external_migration; do cp config/$config.yml.example config/$config.yml; done
for config in amazon_s3 database \
  delayed_jobs domain file_store outgoing_mail security external_migration; \
  do cp config/$config.yml.example config/$config.yml; done
sudo apt-get install nano
# Dynamic settings configuration
cp config/dynamic_settings.yml.example config/dynamic_settings.yml
sudo nano config/dynamic_settings.yml
# Database configuration
cp config/database.yml.example config/database.yml
sudo nano config/database.yml
# Outgoing mail configuration
cp config/outgoing_mail.yml.example config/outgoing_mail.yml
sudo nano config/outgoing_mail.yml
# URL configuration
cp config/domain.yml.example config/domain.yml
sudo nano config/domain.yml
# Security configuration
cp config/security.yml.example config/security.yml
sudo nano config/security.yml

#--------------------------------------------------
# Generate Assets
#--------------------------------------------------
cd /var/canvas
mkdir -p log tmp/pids public/assets app/stylesheets/brandable_css_brands
touch app/stylesheets/_brandable_variables_defaults_autogenerated.scss
touch Gemfile.lock
touch log/production.log
# sudo chown -R $USER config/environment.rb log tmp public/assets app/stylesheets/_brandable_variables_defaults_autogenerated.scss app/stylesheets/brandable_css_brands Gemfile.lock config.ru
sudo chown -R $USER config/environment.rb log tmp public/assets \
                              app/stylesheets/_brandable_variables_defaults_autogenerated.scss \
                              app/stylesheets/brandable_css_brands Gemfile.lock config.ru

yarn install
RAILS_ENV=production bundle exec rake canvas:compile_assets
sudo chown -R $USER public/dist/brandable_css

# Subsequent Updates (NOT NEEDED FOR INITIAL DEPLOY)
# RAILS_ENV=production bundle exec rake brand_configs:generate_and_upload_all

#--------------------------------------------------
# Database population
#--------------------------------------------------
RAILS_ENV=production bundle exec rake db:initial_setup

#--------------------------------------------------
# Canvas ownership
#--------------------------------------------------
# Making sure Canvas can't write to more things than it should.
sudo adduser --disabled-password --gecos canvas canvasuser
# Making sure other users can't read private Canvas files
sudo chown $USER config/*.yml  && sudo chmod 400 config/*.yml
# Making sure to use the "most restrictive" permissions
# Passenger will choose the user to run the application based on the ownership settings of config/environment.rb (you can view the ownership settings via the ls -l command). 

#--------------------------------------------------
# Apache configuration
#--------------------------------------------------
# Installation
# sudo apt-get install passenger libapache2-mod-passenger apache2
# sudo a2enmod rewrite
# Configure Passenger with Apache
# sudo a2enmod passenger
#-------------------------
# 1. Install Apache
# 1
sudo apt install dirmngr gnupg
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 561F9B9CAC40B2F7
sudo apt install apt-transport-https ca-certificates
# 2
sudo sh -c 'echo deb https://oss-binaries.phusionpassenger.com/apt/passenger bionic main > /etc/apt/sources.list.d/passenger.list'
sudo apt update
# 3
sudo apt-get install -y libapache2-mod-passenger
sudo apt install -y apache2 apache2-dev passenger
passenger -v
# 4
sudo a2enmod passenger rewrite
# In other setups, you just need to make sure you add the following lines to your Apache configuration, changing paths to appropriate values if necessary:
# LoadModule passenger_module /usr/lib/apache2/modules/mod_passenger.so
# PassengerRoot /usr
# PassengerRuby /usr/bin/ruby

# If you have trouble starting the application because of permissions problems, you might need to add this line to your passenger.conf, site configuration file, or httpd.conf (where canvasuser is the user that Canvas runs as, www-data on Debian/Ubuntu systems for example):
# PassengerDefaultUser canvasuser

# Configure SSL with Apache
sudo a2enmod ssl
# On other systems, you need to make sure something like below is in your config:

# Configure Canvas with Apache
sudo unlink /etc/apache2/sites-enabled/000-default.conf
git clone https://github.com/plx01/lmssetup ~/01lms
sudo cp ~/01lms/canvas.conf /etc/apache2/sites-available/canvas.conf
sudo nano /etc/apache2/sites-available/canvas.conf
sudo a2ensite canvas

sudo systemctl restart apache2
