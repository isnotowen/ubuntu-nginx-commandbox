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
