

#!/bin/bash

echo "Installing nginx"
debconf-apt-progress -- apt install nginx-extras -y
echo "Adding CommandBox nginx configuration files"
cp etc/nginx/conf.d/nginx-custom-global.conf /etc/nginx/conf.d/nginx-custom-global.conf
cp etc/nginx/commandbox.conf /etc/nginx/commandbox.conf
cp etc/nginx/commandbox-proxy.conf /etc/nginx/commandbox-proxy.conf

echo "Adding Default and Example Site to nginx"
cp etc/nginx/sites-available/*.conf /etc/nginx/sites-available/
echo "Removing nginx default site"
rm /etc/nginx/sites-enabled/default
rm /etc/nginx/sites-available/default
echo "Adding our default site"
ln -s /etc/nginx/sites-available/default.conf /etc/nginx/sites-enabled/default.conf

if [ "$REWRITES_ENABLED" = "true" ]; then
        sed -i "s/#REWRITES_ENABLED# //g" /etc/nginx/commandbox-proxy.conf
        sed -i "s/#REWRITES_ENABLED# //g" /etc/nginx/sites-available/default.conf
fi


#------------------------------
# Inject user defined $WEB_ROOT
#------------------------------
sed -i "s%root WEB_ROOT%root $WEB_ROOT%g" /etc/nginx/sites-available/default.conf


if [ "$WHITELIST_IP" != "" ];then
	echo "Granting $WHITELIST_IP access to /lucee"
	sed -i "s/#allow 10.0.0.10/allow $WHITELIST_IP/g" /etc/nginx/commandbox.conf
fi

if [ "$HOST_NAME" != "" ];then
	echo "Setting default site hostname"
	echo $HOST_NAME
	sed -i "s/#server_name xxx.com/server_name $HOST_NAME/g" /etc/nginx/sites-available/default.conf
fi


service nginx restart
