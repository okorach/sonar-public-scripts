#!/bin/bash

if [ $# == 0 ]; then
	PROJECT_LIST_FILE=projectList.txt
else
    PROJECT_LIST_FILE=$1
fi
if [ -f $PROJECT_LIST_FILE ]; then
	echo "Usage: $0 <projectListFile>"
	exit 1
fi

list=$(cat $PROJECT_LIST_FILE)
nbr_projects=$(cat $PROJECT_LIST_FILE | wc -l)

echo --------------------------------------------------------------------------------
echo "List of project Keys: ($nbr_projects projects)"
echo $list
echo --------------------------------------------------------------------------------
echo "Type [return] to start import"
read foo

for key in $list
do
    ret_code=$(curl -s -u $SONAR_TOKEN: -X POST -I -w "%{http_code}" "$SONAR_HOST_URL/api/projects/create?project=$key&name=$key" | head -n 1 | cut -d ' ' -f 2)
    if [ $ret_code -eq 200 ]; then
        ret_code=$(curl -s -u $SONAR_TOKEN: -X POST -I -w "%{http_code}" "$SONAR_HOST_URL/api/project_dump/import?key=$key" | head -n 1 | cut -d ' ' -f 2)
        if [ $ret_code -eq 200 ]; then
            echo "Request to import project key $key successfull"
        else
            echo "*** Project key creation successful, but request to export project key $key FAILED, code $ret_code ***"
        fi
    else
        echo "*** Project key $key creation FAILED, code $ret_code ***"
	fi
done
