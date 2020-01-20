#!/bin/bash

#root permission check
if [ "$(whoami)" != "root" ]; then
  echo "Sorry, you need to run this script using sudo or as root."
  exit 1
fi

function separator {
  echo " "
  echo "------------------------------------------------"
  echo " "
}

#make sure scripts are runnable
chown -R root scripts/*.sh
chmod u+x scripts/*.sh

echo "Install requires some information..."
read -p "Full path to web root (ex. /web): " -e -i '/web' WEB_ROOT
while [ WEB_ROOT = "" ]; do
	read -p "Provide full path to web root (ex. /web): " -e -i '/web' WEB_ROOT
done
read -p "Default server hostname: " -e -i $HOSTNAME HOST_NAME
read -sp "Lucee Admin Password (Leave blank for randomly generated pw): " ADMIN_PASSWORD
echo
read -p "Lucee Admin white list IP: " WHITELIST_IP

export WEB_ROOT
export HOST_NAME
export ADMIN_PASSWORD
export WHITELIST_IP

#update ubuntu software
./scripts/100-ubuntu-update.sh
separator

#download commandbox
./scripts/200-commandbox.sh
separator

#install nginx
./scripts/300-nginx.sh
separator

#configure commandbox
./scripts/400-config.sh
separator

echo "Setup Complete"
separator
