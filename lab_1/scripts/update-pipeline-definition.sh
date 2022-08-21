#!/usr/bin/env bash
#===============================================================================
#
#          FILE:  update-pipeline-definition.sh
# 
#         USAGE:  ./update-pipeline-definition.sh 
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
#       CREATED:  21/08/22 13:45:11 +03
#      REVISION:  ---
#===============================================================================
JSON_FILE=""
BRANCH="main"
OWNER=""
REPO=""
CONFIGURATION=""
POLL_FOR_SOURCE_CHANGES="false"

function parse_arguments ()
{
	while [[ $# -gt 0 ]]; do
		case $1 in
			--configuration)
				CONFIGURATION="$2"
				shift # past argument
				shift # past value
				;;
			--branch)
				BRANCH="$2"
				shift # past argument
				shift # past value
				;;
			--owner)
				OWNER="$2"
				shift # past argument
				shift # past value
				;;
			--repo)
				REPO="$2"
        shift # past argument
        shift # past value
				;;
			--poll-for-source-changes)
				POLL_FOR_SOURCE_CHANGES="$2"
					shift # past argument
          shift # past value
          ;;
		esac
	done
}    # ----------  end of function parse_arguments  ----------


function check_reqs ()
{
	is_JQ_lib=$(which jq)
	status=0
	if [[ -z $is_JQ_lib ]]; then
		echo "JQ lib is not present" >&2
		status=1
	fi

	if [[ -z $1 ]]; then
		echo "Path to pipeline json file is not provided" >&2 
		status=1
	fi

	echo $status
}    # ----------  end of function check_reqs  ----------

function check_property() {
	property=".$1"
	description=$2
	jq -e $property "$FILE_COPY" >/dev/null 2>&1
	is_error=$?

	if [[ $is_error -ne 0 ]]; then
    echo "No $description property present" >&2
		echo 1
	else
		echo 0
  fi
}


function main ()
{
	check_result=$(check_reqs $1)
	if [[ $check_result -ne 0 ]]; then
		exit 1
	fi

	JSON_FILE=$1
	parse_arguments ${@: 2}
	
	FILENAME=$(basename $JSON_FILE)
	FILE_COPY="$(dirname ${JSON_FILE})/${FILENAME%%.*}-$(date +"%Y-%m-%dT%H:%M:%S%z").json"

	cp $JSON_FILE "$FILE_COPY"
	
	# remove metadata
	if [[ $(check_property "metadata" "metadata") -eq 0 ]]; then
		contents=$(jq 'del(.metadata)' "$FILE_COPY")
		echo "$contents" > "$FILE_COPY"
	else
		exit 1
	fi

	# update version
	if [[ $(check_property "pipeline.version" "version") -eq 0 ]]; then
		contents=$(jq '.pipeline.version += 1' "$FILE_COPY")	
		echo "$contents" > "$FILE_COPY"
	else
		exit 1
	fi

  if [[ ! -z $BRANCH ]]; then
		if [[ $(check_property "pipeline.stages[].actions[]" "actions") -eq 0 ]]; then
			contents=$(jq --arg branch "$BRANCH" \
				'.pipeline.stages[].actions[] |= if .name == "Source" then .configuration.Branch = $branch else . end' "$FILE_COPY")
			echo "$contents" > "$FILE_COPY"
		else
			exit 1
		fi
	fi

	if [[ ! -z $OWNER ]]; then
		if [[ $(check_property "pipeline.stages[].actions[]" "actions") -eq 0 ]]; then
			contents=$(jq --arg owner "$OWNER" \
				'.pipeline.stages[].actions[] |= if .name == "Source" then .configuration.Owner = $owner else . end' "$FILE_COPY")
			echo "$contents" > "$FILE_COPY"
		else
			exit 1
		fi
	fi

	if [[ ! -z $REPO ]]; then
		if [[ $(check_property "pipeline.stages[].actions[]" "actions") -eq 0 ]]; then
			contents=$(jq --arg repo "$REPO" \
				'.pipeline.stages[].actions[] |= if .name == "Source" then .configuration.Repo = $repo else . end' "$FILE_COPY")
      echo "$contents" > "$FILE_COPY"
		else
      exit 1
		fi
	fi

	if [[ ! -z $POLL_FOR_SOURCE_CHANGES ]]; then
		if [[ $(check_property "pipeline.stages[].actions[]" "actions") -eq 0 ]]; then
			contents=$(jq --arg poll "$POLL_FOR_SOURCE_CHANGES" \
				'.pipeline.stages[].actions[] |= if .name == "Source" then .configuration.PollForSourceChanges = $poll else . end' "$FILE_COPY")
			echo "$contents" > "$FILE_COPY"
		else
			exit 1
		fi
	fi

	if [[ ! -z $CONFIGURATION ]]; then
		if [[ $(check_property "pipeline.stages[].actions[]" "actions") -eq 0 ]]; then
			contents=$(jq --arg configuration "$CONFIGURATION" \
			 '.pipeline.stages[].actions[].configuration.EnvironmentVariables |= if . != null then . | fromjson | .[].value = $configuration | tojson else empty end' "$FILE_COPY")
      echo "$contents" > "$FILE_COPY"
    else
      exit 1
		fi
	fi
}    # ----------  end of function main  ----------

main $@
