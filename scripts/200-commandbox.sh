#install commandbox
echo "Installing Java"
apt-get install default-jre -y
apt-get install openjdk-11-jre-headless -y
apt-get install openjdk-8-jre-headless -y
apt-get install openjdk-9-jre-headless -y

apt-get install default-jre -y
java -version

echo "Installing CommandBox"

curl -fsSl https://downloads.ortussolutions.com/debs/gpg | apt-key add -
echo "deb https://downloads.ortussolutions.com/debs/noarch /" | tee -a /etc/apt/sources.list.d/commandbox.list
apt-get update && apt-get install commandbox -y

echo "Installing CommandBox CFCONFIG"
box install commandbox-cfconfig

echo "Installing CommandBox DOTENV"
box install commandbox-dotenv

echo "Creating web root and default sites here: " $WEB_ROOT
mkdir $WEB_ROOT
mkdir $WEB_ROOT/default
mkdir $WEB_ROOT/default/www
mkdir $WEB_ROOT/example.com
mkdir $WEB_ROOT/example.com/www

echo "Creating a default index.cfm"
echo "<!doctype html><html><body><cfoutput><h1>Hello</h1>Current Date/Time: <em>#dateTimeFormat( now() )#</em></cfoutput></body></html>" > $WEB_ROOT/default/www/index.cfm

#set the web directory permissions
chown -R root:www-data $WEB_ROOT
chmod -R 750 $WEB_ROOT

echo "Starting up CommandBox instances"
box server start name=default port=8080 host=127.0.1.1 cfengine=lucee serverConfigFile=/web/default/server.json directory=/web/default/www rewritesEnable=false openbrowser=false saveSettings=true --force;