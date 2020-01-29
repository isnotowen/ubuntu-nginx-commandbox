#!/bin/bash

#Updat Ubuntu Software
apt update -y && apt upgrade -y && apt dist-upgrade -y

debconf-apt-progress -- apt install unzip curl apt-transport-https gnupg -y

#Set up unattended upgrades
#debconf-apt-progress -- apt install unattended-upgrades
dpkg-reconfigure unattended-upgrades
