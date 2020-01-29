#!/bin/bash

scriptversion="1.0"

backtitle="Version $scriptversion"
whiptitle="Setup nginx & commandbox"

. ./_installhelpers.sh --source-only


#---------------------
#root permission check
#---------------------
if [ "$(whoami)" != "root" ]; then
        whiptail --title "$whiptitle" --backtitle "$backtitle" "Sorry, you need to run this script using sudo or as root." 8 60
        exit 1
fi


#------------------
#cancel opportunity
#------------------
if (! whiptail --title "$whiptitle" --backtitle "$backtitle" --yesno "This script will configure nginx and commandbox. Do you want to continue?"  10 40 )
then
        abort
else
	#------------------------------
	#make sure scripts are runnable
	#------------------------------
	chown -R root scripts/*.sh
	chmod u+x scripts/*.sh
fi


#----------------------
#Get all the user input
#----------------------
getUserInputs







function separator {
	echo " "
	echo "------------------------------------------------"
	echo " "
}


#update ubuntu software
./scripts/100-ubuntu-update.sh
separator

#download commandbox
./scripts/200-commandbox.sh
separator

#install nginx
./scripts/300-nginx.sh
separator

#configure commandbox
./scripts/400-config.sh
separator

getSetupComplete

