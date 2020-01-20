#!/bin/bash

echo "Updating Ubuntu Software"
apt-get update
apt-get upgrade -y
apt-get dist-upgrade -y

apt-get install unzip curl apt-transport-https gnupg

echo "Setting up unattended upgrades..."
apt-get install unattended-upgrades
dpkg-reconfigure unattended-upgrades
