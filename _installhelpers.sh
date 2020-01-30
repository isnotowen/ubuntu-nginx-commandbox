#!/bin/bash

function abort {
	echo Aborted.
	exit 1
}

function separator {
	echo " "
	echo "------------------------------------------------"
	echo " "
}


function getWebRoot {
	WEB_ROOT=$(whiptail --title "$whiptitle" --backtitle "$backtitle" --inputbox "What is the full path to your web root (ex. /web)" 10 80 "/web" 3>&1 1>&2 2>&3)
	if [ ! $? = 0 ]; then
		confirmCancel
		getWebRoot
	elif [ "$WEB_ROOT" = "" ]; then
		getWebRoot
	fi

	export WEB_ROOT
}

function getHostName {
	HOST_NAME=$(whiptail --title "$whiptitle" --backtitle "$backtitle" --inputbox "What is the default server hostname?" 10 80 "$HOSTNAME" 3>&1 1>&2 2>&3)
	if [ ! $? = 0 ]; then
		confirmCancel
		getHostName
	elif [ "$HOST_NAME" = "" ]; then
		getHostName
	fi

	export HOST_NAME
}

function getWhiteList {
	WHITELIST_IP=$(whiptail --title "$whiptitle" --backtitle "$backtitle" --inputbox "Enter an IP address you'd like to whitelist for Admin (optional)" 10 80 "" 3>&1 1>&2 2>&3)
	if [ ! $? = 0 ]; then
		confirmCancel
		getWhiteLlist
	fi

	export WHITELIST_IP
}

function getAdminPassword {
	ADMIN_PASSWORD=$(whiptail --title "$whiptitle" --backtitle "$backtitle" --passwordbox "Admin Password (Leave blank for a randomly generated password)" 10 80 3>&1 1>&2 2>&3)
	if [ ! $? = 0 ]; then
		confirmCancel
		getAdminPassword
	fi

	if [ "$ADMIN_PASSWORD" = "" ]; then
		RANDPASS="Random"
		ADMIN_PASSWORD=$(tr -cd '[:alnum:]' < /dev/urandom | fold -w20 | head -n1)
	else
		RANDPASS="User Defined"
	fi

	export ADMIN_PASSWORD
}

CF_ENGINE="lucee"
function getCFEngine {
	# RE for determining validity of cfengine
	engineCheck="^(lucee|adobe)@?([0-9]|\.|\-)*$"
	shopt -s nocasematch;

	CF_ENGINE=$(whiptail --title "$whiptitle" --backtitle "$backtitle" --inputbox "Which CF engine should be used?" 10 80 "$CF_ENGINE" 3>&1 1>&2 2>&3)
	if [ ! $? = 0 ]; then
		confirmCancel
		getCFEngine
	elif ! [[ "$CF_ENGINE" =~ $engineCheck ]]; then
		getCFEngine
	fi

	export CF_ENGINE
}


function getRewritesEnabled {
	if( whiptail --title "$whiptitle" --backtitle "$backtitle" --yesno "Do you want to enable commandbox URL rewrites?" 10 40 )
	then
		REWRITES_ENABLED="true"
	else
		REWRITES_ENABLED="false"
	fi

	export REWRITES_ENABLED
}



function getCertBotSetup {
	if( whiptail --title "$whiptitle" --backtitle "$backtitle" --yesno "Do you want to setup a certificate with certbot?" 10 40 )
	then
		CERTBOT="Yes"
	else
		CERTBOT="No"
	fi

	export CERTBOT
}


function confirmInputs {
	if(! whiptail --title "$whiptitle" --backtitle "$backtitle" --yesno "Is this information correct?\n\nWEBROOT..........: $WEB_ROOT \nHOSTNAME.........: $HOST_NAME \nCF ENGINE........: $CF_ENGINE \nWHITELIST........: $WHITELIST_IP \nREWRITES.........: $REWRITES_ENABLED \nPASSWORD.........: $RANDPASS \nSETUP CERT:......: $CERTBOT" 14 60 )
	then
		getUserInputs
	fi
}


function confirmCancel {
	if ( whiptail --title "$whiptitle" --backtitle "$backtitle" --yesno "Are you sure you want to cancel?" 10 40 )
	then
		abort
	fi
}


function getSetupComplete {
	whiptail --title "$whiptitle" --backtitle "$backtitle" --msgbox "All done! \n\nOpen http://$HOSTNAME to test it out." 10 40
}


function getUserInputs {
	getWebRoot
	getHostName
	getCFEngine
	getWhiteList
	getRewritesEnabled
	getAdminPassword
	getCertBotSetup
	confirmInputs
}
