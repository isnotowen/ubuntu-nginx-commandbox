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

function setupInfo {
	echo " "
	echo "------------------------------------------------"
	echo " "
	echo "CONFIGURATION:"
	echo " "
	echo "------------------------------------------------"
	echo " "
	echo "Domain(s): $DOMAIN"
	echo "Site Root: $SITE_ROOT"
	echo "Service Name: $SERVICE_NAME"
	echo "CommandBox IP: $SERVICE_IP"

	if [[ !$ADMIN_PASSWORD ]]; then
		echo "Lucee Admin Password will be randomly generated and saved to /root/lucee-admin-password-$PRIMARY_DOMAIN.txt"
	else
		echo "Lucee Admin Password was provided."
	fi
	echo " "
	echo "------------------------------------------------"
	echo " "
}

echo "Add new site..."
read -p "Domain(s) (seperate multiple with spaces): " DOMAIN

PRIMARY_DOMAIN=${DOMAIN%% *}

echo
read -p "Full path to site root (ex. /web/example.com): " -e -i "/web/${PRIMARY_DOMAIN}" SITE_ROOT
while [ SITE_ROOT == "" ]; do
	read -p "Full path to site root (ex. /web/example.com): " -e -i "/web/${PRIMARY_DOMAIN}" SITE_ROOT
done
echo
read -p "Service name for CommandBox instance: " -e -i "commandbox-${PRIMARY_DOMAIN}" SERVICE_NAME
echo
echo "Generating list of current CommandBox instances..."
box server list
read -p "Bind CommandBox instance to IP (This should be a unique local IP not used by any other CommandBox instance. Ex. 127.0.1.100): " SERVICE_IP
echo
read -sp "Lucee Admin Password (Leave blank for randomly generated pw): " ADMIN_PASSWORD

separator

echo "Confirm Configuration..."
setupInfo
read -p "Is everything above correct? [Y/n]: " CONTINUE_INSTALL
echo
echo
separator

if [ ${CONTINUE_INSTALL^^} == "Y" ]; then

	echo "Creating site root here: " $SITE_ROOT
	mkdir -p $SITE_ROOT/www

	echo "Creating a default index.cfm"
	echo "<!doctype html><html><body><cfoutput><h1>${PRIMARY_DOMAIN}</h1>Current Date/Time: <em>#dateTimeFormat( now() )#</em></cfoutput></body></html>" > $SITE_ROOT/www/index.cfm

	#set the web directory permissions
	chown -R root:www-data $SITE_ROOT
	chmod -R 750 $SITE_ROOT

	echo "Starting up CommandBox instance"
	box server start name=${PRIMARY_DOMAIN} port=8080 host=${SERVICE_IP} cfengine=lucee serverConfigFile=${SITE_ROOT}/server.json directory=${SITE_ROOT}/www rewritesEnable=false openbrowser=false saveSettings=true --force;

	echo "Setting up CommandBox Service"
	cp etc/init.d/commandbox-default /etc/init.d/${SERVICE_NAME}
	sed -i "s/commandbox-default/$SERVICE_NAME/g" /etc/init.d/${SERVICE_NAME}
	sed -i "s/default/$PRIMARY_DOMAIN/g" /etc/init.d/${SERVICE_NAME}
	chmod +x /etc/init.d/${SERVICE_NAME}
	echo "Adding CommandBox ${SERVICE_NAME} as service"
	update-rc.d ${SERVICE_NAME} defaults
	systemctl enable ${SERVICE_NAME}

	echo "Adding Site to nginx"
	cp etc/nginx/sites-available/default.conf /etc/nginx/sites-available/${PRIMARY_DOMAIN}.conf
	sed -i "s|#server_name xxx.com|server_name $DOMAIN|g" /etc/nginx/sites-available/${PRIMARY_DOMAIN}.conf
	sed -i "s|root /web/default/www/|root ${SITE_ROOT}/www|g" /etc/nginx/sites-available/${PRIMARY_DOMAIN}.conf
	sed -i "s|boxProxy http://127.0.1.1:8080|boxProxy http://${SERVICE_IP}:8080|g" /etc/nginx/sites-available/${PRIMARY_DOMAIN}.conf
	sed -i "s|listen 80 default_server|listen 80|g" /etc/nginx/sites-available/${PRIMARY_DOMAIN}.conf
	ln -s /etc/nginx/sites-available/${PRIMARY_DOMAIN}.conf /etc/nginx/sites-enabled/${PRIMARY_DOMAIN}.conf

	service nginx reload

	read -p "Would you like to execute certbot for this new site? [Y/n]: " EXEC_CERTBOT
	if [ ${EXEC_CERTBOT^^} == "Y" ]; then
		echo "Set up secure certificate for site..."
		certbot -d ${DOMAIN// /,} --nginx
	fi

	separator

	setupInfo

	echo "Setup Complete"
else
	echo "Setup Canceled"
fi

separator
