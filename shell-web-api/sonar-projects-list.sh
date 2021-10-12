#!/bin/bash

# Retrieves the list of projects keys from a platform pointed by $SONAR_HOST_URL

nb_projects=`curl -s -u $SONAR_TOKEN: -X GET "$SONAR_HOST_URL/api/projects/search?qualifiers=TRK" | jq '.paging.total'`

page_size=500
page=0
let total=0
while [ $nb_projects -gt $total ]
do
    let page=$page+1
    # echo "curl -s -u $SONAR_TOKEN: -X GET $SONAR_HOST_URL/api/projects/search?ps=$page_size&p=$page&qualifiers=TRK"
    curl -s -u $SONAR_TOKEN: -X GET "$SONAR_HOST_URL/api/projects/search?ps=$page_size&p=$page&qualifiers=TRK" | jq '.components[].key' | cut -d '"' -f 2
    let total=$page_size*$page
done