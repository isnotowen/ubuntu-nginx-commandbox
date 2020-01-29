#!/bin/bash

#Updat Ubuntu Software
debconf-apt-progress -- apt-get update -y
debconf-apt-progress -- apt-get upgrade -y
debconf-apt-progress -- apt-get dist-upgrade -y

debconf-apt-progress -- apt-get install unzip curl apt-transport-https gnupg

#Set up unattended upgrades
debconf-apt-progress -- apt-get install unattended-upgrades
dpkg-reconfigure unattended-upgrades
