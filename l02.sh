#!/bin/bash
################################################################################
# sudo chmod +x l01.sh
# Execute the script to setup lms:
# ./l01.sh#-------------------------
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
