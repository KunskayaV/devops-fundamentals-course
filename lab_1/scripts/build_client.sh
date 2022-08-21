#!/usr/bin/env bash
#===============================================================================
#
#          FILE:  build_client.sh
# 
#         USAGE:  ./build_client.sh 
# 
#   DESCRIPTION: lab1 task
# 
#       OPTIONS:  ---
#  REQUIREMENTS:  ---
#          BUGS:  ---
#         NOTES:  ---
#        AUTHOR:   (), 
#       COMPANY:  
#       VERSION:  1.0
#       CREATED:  20/08/22 16:48:30 +03
#      REVISION:  ---
#===============================================================================
source ${ENV_SOURCE:=set_env_dev.sh}

export NVM_DIR=$HOME/.nvm;
source $NVM_DIR/nvm.sh;


function create_archive() {
	if [[ -d "dist/app" ]]; then
		if [[ -f "dist/${ZIP_FILENAME}.zip" ]]; then
			rm "dist/${ZIP_FILENAME}.zip"
		fi

		cd dist && zip -r "${ZIP_FILENAME}.zip" app && cd - > /dev/null
	fi
}


function main ()
{
	nvm use 16
	cd $REPO_PATH
	npm ci
	npm run build --configuration "${ENV_CONFIGURATION:=""}" &
	wait && create_archive
}    # ----------  end of function main  ----------
main $@
