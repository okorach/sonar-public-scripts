#!/bin/bash

PROJECT_LIST_FILE=sonar-projects-list.txt
if [ $# == 0 ]; then
	./sonar-projects-list.sh >$PROJECT_LIST_FILE
else
	PROJECT_LIST_FILE=$1
fi
list=$(cat $PROJECT_LIST_FILE)
nbr_projects=$(cat $PROJECT_LIST_FILE | wc -l)

echo --------------------------------------------------------------------------------
echo "List of project Keys: ($nbr_projects projects)"
echo $list
echo --------------------------------------------------------------------------------
echo "Type [return] to start export"
read foo

for key in $list
do
    ret_code=$(curl -s -u $SONAR_TOKEN: -X POST -I -w "%{http_code}" "$SONAR_HOST_URL/api/project_dump/export?key=$key" | head -n 1 | cut -d ' ' -f 2)
    if [ $ret_code -eq 200 ]; then
        echo "Request to export project key $key successfull"
    else
        echo "*** Request to export project key $key FAILED, code $ret_code ***"
	fi
done
