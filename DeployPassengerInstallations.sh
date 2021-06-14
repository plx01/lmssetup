# -----
# Deployment: installations
sudo cp DeployPassengerInstallations.sh dpi.sh
# -----
# Installing Ruby with RVM - Debian, Ubuntu
# Prepare the system
sudo apt-get update
sudo apt-get install -y curl gnupg build-essential
# Install RVM
# use gpg2 instead of gpg on some systems.
sudo gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB
curl -sSL https://get.rvm.io | sudo bash -s stable
# add user 'rvm' group with 'umask usr wx,g=rwx,o=rx'
sudo usermod -a -G rvm root
exit
source /etc/profile.d/rvm.sh
# Install the Ruby version you want
# rvm install ruby && rvm --default use ruby
rvm install ruby-2.5.1 && rvm --default use ruby-2.5.1
# Install Bundler: gem install bundler --no-rdoc --no-ri
gem install bundler
# Optional: install Node.js if you're using Rails - Ubuntu
sudo apt-get install -y nodejs && sudo ln -sf /usr/bin/nodejs /usr/local/bin/node
# Heads-up: sudo vs rvmsudo

# Installing Passenger + Apache on a digital_ocean production server
# Step 1: install Passenger packages
sudo apt-get install apache2

# Install our PGP key and add HTTPS support for APT
sudo apt-get install -y dirmngr gnupg
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 561F9B9CAC40B2F7
sudo apt-get install -y apt-transport-https ca-certificates

# Add our APT repository
sudo sh -c 'echo deb https://oss-binaries.phusionpassenger.com/apt/passenger focal main > /etc/apt/sources.list.d/passenger.list'
sudo apt-get update

# Install Passenger + Apache module
sudo apt-get install -y libapache2-mod-passenger

# Step 2: enable the Passenger Apache module and restart Apache
sudo a2enmod passenger && 
sudo service apache2 restart

# Step 3: check installation
sudo /usr/bin/passenger-config validate-install
sudo /usr/sbin/passenger-memory-stats
# 12517  83.2 MB   0.6 MB    Passenger watchdog
# 12520  266.0 MB  3.4 MB    Passenger core
# 12531  149.5 MB  1.4 MB    Passenger ust-router

# Step 4: update regularly
sudo apt-get update &&
sudo apt-get upgrade
