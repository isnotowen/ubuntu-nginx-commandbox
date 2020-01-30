
#install commandbox
debconf-apt-progress -- apt install default-jre -y
debconf-apt-progress -- apt install openjdk-11-jre-headless -y
debconf-apt-progress -- apt install openjdk-8-jre-headless -y
debconf-apt-progress -- apt install openjdk-9-jre-headless -y
debconf-apt-progress -- apt install default-jre -y

#java -version

echo "Installing CommandBox"

curl -fsSl https://downloads.ortussolutions.com/debs/gpg | apt-key add -
echo "deb https://downloads.ortussolutions.com/debs/noarch /" | tee -a /etc/apt/sources.list.d/commandbox.list

debconf-apt-progress -- apt update
debconf-apt-progress -- apt install commandbox -y

echo "Installing CommandBox CFCONFIG"
box install commandbox-cfconfig

echo "Installing CommandBox DOTENV"
box install commandbox-dotenv

echo "Creating web root and default sites here: " $WEB_ROOT
[ -d $WEB_ROOT ] && echo "Using $WEB_ROOT as the webroot"
[ ! -d $WEB_ROOT ] && mkdir -p $WEB_ROOT && echo "Creating web root here: " $WEB_ROOT
[ ! -f $WEB_ROOT/index.cfm ] && echo "Creating a default index.cfm" && echo "<!doctype html><html><body><cfoutput><h1>Hello</h1>Current Date/Time: <em>#dateTimeFormat( now() )#</em></cfoutput></body></html>" > $WEB_ROOT/index.cfm


#set the web directory permissions
chown -R root:www-data $WEB_ROOT
chmod -R 750 $WEB_ROOT

echo "Setting up CommandBox instance"
box server start name=default port=8080 host=127.0.1.1 cfengine=$CF_ENGINE serverConfigFile=$WEB_ROOT/server.json directory=$WEB_ROOT rewritesEnable=$REWRITES_ENABLED openbrowser=false saveSettings=true --force;

echo "Setting Admin Password"
box cfconfig set adminPassword=$ADMIN_PASSWORD to=default

echo "Restarting Commandbox instance"
box server restart default


if [ "$CF_ENGINE" = "Lucee" ]; then
	#Double check passwords
	if ( curl --silent http://127.0.0.1/lucee/admin/server.cfm | grep -i new_password_re > /dev/null );
	then
		whiptail --title "$whiptitle" --backtitle "$backtitle" --msgbox "The server context password was not set correctly. Please be sure to set it manually." 10 40
	fi

        if ( curl --silent http://127.0.0.1/lucee/admin/web.cfm | grep -i new_password_re > /dev/null );
	then
                whiptail --title "$whiptitle" --backtitle "$backtitle" --msgbox "The web context password was not set correctly. Please be sure to set it manually." 10 40
        fi
fi


