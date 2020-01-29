#!/bin/bash

#Updat Ubuntu Software
debconf-apt-progress -- apt update -y
debconf-apt-progress -- apt upgrade -y
apt dist-upgrade -y

debconf-apt-progress -- apt install unzip curl apt-transport-https gnupg

#Set up unattended upgrades
#debconf-apt-progress -- apt install unattended-upgrades
dpkg-reconfigure unattended-upgrades
