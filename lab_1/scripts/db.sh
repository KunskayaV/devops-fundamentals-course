#!/usr/bin/env bash

#===============================================================================
#
#          FILE:  db.sh
# 
#         USAGE:  ./db.sh 
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
#       CREATED:  13/08/22 19:53:54 +03
#      REVISION:  ---
#===============================================================================
USERS_FILE_PATH="../data/users.db"

function check_only_latin () {
 grep "[^a-z,A-Z]" <<< "$1" >> /dev/null 2>&1
}

function prompt_value () {
	prompt_text=$1
	validation_func=$2

	is_value_invalid=0
	while [[ -z "$value" ||  $is_value_invalid -eq 0 ]]
	do
	echo -n "${prompt_text}" >&2
  read value
	($validation_func $value)

  is_value_invalid=$?
  done

  echo "${value}"
}

function check_is_file_exists () {
	if [[ -f $1 ]]; then
		echo 0
	else
		echo 1

	fi
}


function request_action () {
	 prompt_text=$1
	 is_confirmed=1

	 while [[ $is_confirmed -ne 0 ]]
	 do
		 echo -n "${prompt_text}" >&2
		 read create

  	 shopt -s nocasematch
  	 case $create in
			 Y) is_confirmed=0 
				  echo 0
				 	;;
	
	  	 N) is_confirmed=0
				 	echo 1
			   	;;
	
			 *) echo "Unknown options. There are two options (Y/N)" >&2
			   ;;
	
		esac    # --- end of case ---
		shopt -u nocasematch
		
	done
}


function add_user ()
{
	username=$(prompt_value "Please provide username to add: " check_only_latin)
  role=$(prompt_value "Please provide role for the user: " check_only_latin)

	entity_to_add="$username, $role"
 
	if [[ $(check_is_file_exists $USERS_FILE_PATH) -eq 0 ]]
	then
 		echo "$entity_to_add" >> $USERS_FILE_PATH
	else
		request_result=$(request_action "File is not found. Do you want to create file with this path: $USERS_FILE_PATH? (Y/N): ")
		
		if [[ $request_result -eq 0 ]]
		then
			touch $USERS_FILE_PATH
	 		echo "$entity_to_add" >> $USERS_FILE_PATH
		fi
	fi
}    # ----------  end of function add_user  ----------



function print_help ()
{
	help_text="
	add       Command adds a line in \"username, role\" format to the $USERS_FILE_PATH file
	backup    Command creates backup for the $USERS_FILE_PATH file
	restore   Command restores database file from the last backup
	find      Command find user with specified username in database
	list      Command lists users added into database. With optinal parameter \"--inverse\" inverts the list
	help      Command prints help info for the script
	" 
	echo -e "$help_text"
	
}    # ----------  end of function print_help  ----------


function create_backup ()
{
	DIR="$(dirname "${USERS_FILE_PATH}")"
	FILENAME="$(basename "${USERS_FILE_PATH}")"
	
	if [[ $(check_is_file_exists $USERS_FILE_PATH) -eq 0 ]]
	then
			cp "$USERS_FILE_PATH" "${DIR}/%$(date +"%Y-%m-%dT%H:%M:%S%z")%-${FILENAME}.backup" 
	else
		request_result=$(request_action "File is not found. Do you want to create file with this path: $USERS_FILE_PATH? (Y/N): ")
		
		if [[ $request_result -eq 0 ]]; then
			touch $USERS_FILE_PATH
			cp "$USERS_FILE_PATH" "${DIR}/%$(date +"%Y-%m-%dT%H:%M:%S%z")%-${FILENAME}.backup" 
		fi
	fi
}    # ----------  end of function create_backup  ----------

function restore_file ()
{
	DIR="$(dirname "${USERS_FILE_PATH}")"
	FILENAME="$(basename "${USERS_FILE_PATH}")"

	if [[ $(check_is_file_exists $USERS_FILE_PATH) -eq 0 ]]
	then
		last_backup=$(find $DIR -type f -name "*.backup" | sort -r | head -n 1)

		if [[ ! -z $last_backup ]]; then
			cat $last_backup > $USERS_FILE_PATH
		else
			echo "No backup file found"
		fi
	else
		request_result=$(request_action "File is not found. Do you want to create file with this path: $USERS_FILE_PATH? (Y/N): ")
		
		if [[ $request_result -eq 0 ]]; then
			touch $USERS_FILE_PATH
		fi

		echo "No backup file found"
	fi
}    # ----------  end of function restore_file  ----------

function find_user ()
{
	while [ -z $username ]
	do
		echo -n "Please provide username to find: "
		read username
	done

	if [[ $(check_is_file_exists $USERS_FILE_PATH) -eq 0 ]]
	then
		matches=$(grep "^$username," $USERS_FILE_PATH)
  
    if [[ $? -ne 0 ]]; then
      echo "User not found"
    else
      while read line ; do
        echo "Username: "${line%%,*}"; Role: ${line##*, }"
      done <<< $matches
    fi
  else
    request_result=$(request_action "File is not found. Do you want to create file with this path: $USERS_FILE_PATH? (Y/N): ")

    if [[ $request_result -eq 0 ]]; then
      touch $USERS_FILE_PATH
    fi

		echo "User not  found"
  fi 
}    # ----------  end of function find_user  ----------

function list_entities ()
{
	PARAM=$1

  if [[ $(check_is_file_exists $USERS_FILE_PATH) -eq 0 ]]
  then
		case ${PARAM##*--} in
			inverse) source=$(tac $USERS_FILE_PATH)
				;;
			*) source=$(cat $USERS_FILE_PATH)
		esac

		number=1
 		while read line ; do
    	echo "$number. ${line}"
    	((number += 1))
  	done <<<$source
  else
    request_result=$(request_action "File is not found. Do you want to create file with this path: $USERS_FILE_PATH? (Y/N): ")

    if [[ $request_result -eq 0 ]]; then
      touch $USERS_FILE_PATH
    fi
	fi
}

function main ()
{
  COMMAND=$1

	case $COMMAND in
		add) add_user
			;;
		help|"") print_help
			;;
		backup) create_backup
			;;
		restore) restore_file
			;;
		find) find_user
			;;
		list) list_entities ${@: 2}
			;;
		another) echo "Another command"
			;;

		*) echo "${COMMAND}: such command was not found"
			;;

	esac    # --- end of case ---

}    # ----------  end of function main  ----------

main $@
