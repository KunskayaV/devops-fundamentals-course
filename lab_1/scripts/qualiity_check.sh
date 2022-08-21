#!/usr/bin/env bash
#===============================================================================
#
#          FILE:  qualiity_check.sh
# 
#         USAGE:  ./qualiity_check.sh 
# 
#   DESCRIPTION:  lab1 task
# 
#       OPTIONS:  ---
#  REQUIREMENTS:  ---
#          BUGS:  ---
#         NOTES:  ---
#        AUTHOR:   (), 
#       COMPANY:  
#       VERSION:  1.0
#       CREATED:  21/08/22 12:12:41 +03
#      REVISION:  ---
#===============================================================================
source ${ENV_SOURCE:=set_env_dev.sh}

export NVM_DIR=$HOME/.nvm;
source $NVM_DIR/nvm.sh;

function main ()
{
	google-chrome-stable -version

	if [[ $? -ne 0 ]]; then
		sudo apt update
		apt-get install -y libappindicator1 fonts-liberation
		apt-get install -f
		wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
		sudo dpkg -i google-chrome*.deb
	fi

	export CHROME_BIN="/usr/bin/google-chrome"

	nvm use 16

  cd $REPO_PATH
	npm ci	
	npm run lint && npm run test
}   # ----------  end of function main  ----------


main $@
