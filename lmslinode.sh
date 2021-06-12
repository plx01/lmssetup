#!/bin/bash
# sudo chmod +x lmslinode.sh
# Execute the script to setup lms:
# ./lmslinode.sh
sudo apt update && sudo apt upgrade

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
#-------------------------
# 2 Install PostgreSQL
# 1
sudo apt-get install postgresql
# 2
sudo -u postgres createuser canvas --no-createdb --no-superuser --no-createrole --pwprompt
# 3
sudo -u postgres createdb canvas_production --owner=canvas
# 4
sudo -u postgres psql -c "alter user $USER with superuser" postgres

#-------------------------
# 3 Install Ruby
# 1
sudo apt install software-properties-common
sudo add-apt-repository ppa:brightbox/ruby-ng
sudo apt update
# 2
sudo apt-get install ruby2.6 ruby2.6-dev zlib1g-dev libxml2-dev libsqlite3-dev postgresql libpq-dev  libxmlsec1-dev curl make g++
# 3
sudo gem install bundler --version 2.2.17

#-------------------------
# 4 Install Node.js and Yarn
# 1 Install Node.js.
curl -sL https://deb.nodesource.com/setup_14.x | sudo -E bash -
sudo apt-get install nodejs
sudo npm install -g npm@latest
# 2 Install Yarn, a package manager used in the Canvas installation process.
curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
sudo apt-get update && sudo apt-get install yarn=1.19.1-1

#-------------------------
# 5 Install Canvas
# 1
sudo apt-get install git-core
# 2
git clone https://github.com/instructure/canvas-lms.git ~/canvas
# 3
cd ~/canvas  && git checkout stable
# 4-5
sudo mkdir -p /var/canvas  && sudo chown -R $USER /var/canvas
sudo cp -R ~/canvas /var  && cd /var/canvas
# 6
bundle config set path 'vendor/bundle'
bundle config set --local without 'pulsar'
sudo chown -R $USER /var/canvas
bundle install
# 7
sudo chown -R $USER /var/canvas
yarn install

#-------------------------
# 6 Set Up the Canvas Configuration Files
# 1
for config in amazon_s3 database delayed_jobs domain file_store outgoing_mail security external_migration; do cp config/$config.yml.example config/$config.yml; done
sudo apt install nano
# 2
sudo nano /var/canvas/config/database.yml
# 3
sudo nano /var/canvas/config/domain.yml
# 4
sudo nano /var/canvas/config/outgoing_mail.yml
# 5
sudo nano /var/canvas/config/security.yml

# Generate the Canvas Assets and Data
