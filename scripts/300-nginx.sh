#!/bin/bash
web_root="/web"

echo "Installing nginx"
apt-get install nginx-extras -y
echo "Adding CommandBox nginx configuration files"
cp etc/nginx/conf.d/nginx-custom-global.conf /etc/nginx/conf.d/nginx-custom-global.conf
cp etc/nginx/commandbox.conf /etc/nginx/commandbox.conf
cp etc/nginx/commandbox-proxy.conf /etc/nginx/commandbox-proxy.conf

echo "Creating web root and default sites here: " $web_root
mkdir $web_root
mkdir $web_root/default
mkdir $web_root/default/www
mkdir $web_root/example.com
mkdir $web_root/example.com/www

echo "Creating a default index.html"
echo "<!doctype html><html><body><h1>Hello</h1></body></html>" > $web_root/default/www/index.html

#set the web directory permissions
chown -R root:www-data $web_root
chmod -R 750 $web_root


echo "Adding Default and Example Site to nginx"
cp etc/nginx/sites-available/*.conf /etc/nginx/sites-available/
echo "Removing nginx default site"
rm /etc/nginx/sites-enabled/default
echo "Adding our default site"
ln -s /etc/nginx/sites-available/default.conf /etc/nginx/sites-enabled/default.conf

if [[ $WHITELIST_IP ]];then
    echo "Granting $WHITELIST_IP access to /lucee"
    sed -i "s/#allow 10.0.0.10/allow $WHITELIST_IP/g" /etc/nginx/lucee.conf
fi


service nginx restart
