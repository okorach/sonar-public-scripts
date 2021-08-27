#!/bin/bash

set -euo pipefail

# If not defined as environment variable you may set your SonarQUbe URL and Token below
# SONAR_HOST_URL=http://localhost:9000
# SONAR_TOKEN=6990c5089kngf780a3e5527922hnm9gqn9035ea6

usage() {
	echo ""
   echo "$(basename $0) <year> <month>"
	echo "Deletes all projects not analyzed since the selected month (inclusive of the month)"
	echo ""
}

if [ "$#" != "2" ]; then
	usage
	exit 1
fi

year=$(printf "%04d" $1)
month=$(printf "%02d" $2)

for d in {1..31}; do
	day=$(printf "%02d" $d)

	echo curl -X POST -u \$SONAR_TOKEN: "$SONAR_HOST_URL/api/projects/bulk_delete?analyzedBefore=$year-$month-$day"
	# BULK DELETE PROJECTS
	curl -X POST -u $SONAR_TOKEN: "$SONAR_HOST_URL/api/projects/bulk_delete?analyzedBefore=$year-$month-$day"
done
