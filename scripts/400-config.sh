#!/bin/bash

if [[ !$ADMIN_PASSWORD ]]; then
	echo "No ADMIN_PASSWORD set, generating a random password and storing it here: /root/lucee-admin-password.txt"
	touch /root/lucee-admin-password.txt
	chown root:root /root/lucee-admin-password.txt
	chmod 700 /root/lucee-admin-password.txt
	openssl rand -base64 64 | tr -d '\n\/\+=' > /root/lucee-admin-password.txt
	export ADMIN_PASSWORD=`cat /root/lucee-admin-password.txt`
fi

echo "Copying CommandBox Startup Script"
cp etc/init.d/commandbox-startup.sh /etc/init.d/commandbox-startup.sh
chmod +x /etc/init.d/commandbox-startup.sh
echo "Adding CommandBox Startup Script to boot sequence"
update-rc.d commandbox-startup.sh defaults

echo "Configuring CommandBox for Default site"
cd $WEB_ROOT/default/
box server start port=8080 host=127.0.1.1 cfengine=lucee serverConfigFile=./server.json directory=www rewritesEnable=false openbrowser=false saveSettings=true

#box cfconfig set adminPassword=$ADMIN_PASSWORD to=/opt/lucee/config/server/lucee-server/ toFormat=luceeServer@5
#box cfconfig set adminPasswordDefault=$ADMIN_PASSWORD to=/opt/lucee/config/server/lucee-server/ toFormat=luceeServer@5

echo "Add Certbot PPA"
apt-get install software-properties-common -y
add-apt-repository universe
add-apt-repository ppa:certbot/certbot
apt-get update

echo "Install Certbot"
apt-get install certbot python-certbot-nginx -y
certbot --nginx
