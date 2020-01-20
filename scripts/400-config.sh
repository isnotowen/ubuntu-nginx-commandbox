#!/bin/bash

if [[ !$ADMIN_PASSWORD ]]; then
	echo "No ADMIN_PASSWORD set, generating a random password and storing it here: /root/lucee-admin-password.txt"
	touch /root/lucee-admin-password.txt
	chown root:root /root/lucee-admin-password.txt
	chmod 700 /root/lucee-admin-password.txt
	openssl rand -base64 64 | tr -d '\n\/\+=' > /root/lucee-admin-password.txt
	export ADMIN_PASSWORD=`cat /root/lucee-admin-password.txt`
fi

echo "Copying CommandBox Service (Default)"
cp etc/init.d/commandbox-default /etc/init.d/commandbox-default
chmod +x /etc/init.d/commandbox-default
echo "Adding CommandBox Default as service"
update-rc.d commandbox-default defaults

echo "Add Certbot PPA"
apt-get install software-properties-common -y
add-apt-repository universe
add-apt-repository ppa:certbot/certbot
apt-get update

echo "Install Certbot"
apt-get install certbot python-certbot-nginx -y
certbot --nginx
