#!/bin/sh

sudo cat << EOF | sudo tee /usr/local/config.app

APP_DBSERVER=${dbserver}
APP_DBNAME=${dbname}
APP_DBUSER="${dbuser}
APP_DBPASSWORD=${dbpass}


EOF