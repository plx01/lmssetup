#!/bin/bash
################################################################################
# sudo apt install git-core
# git clone https://github.com/plx01/lmssetup ~/01l
# sudo chmod +x l01.sh
# ./l01.sh
$OE_USER = "canvas"
sudo apt update && sudo apt upgrade
cd

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

sudo apt-get install python

