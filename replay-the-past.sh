#!/bin/bash

EXIT_OK=0
EXIT_USAGE=1
EXIT_GIT_ERROR=2
EXIT_SCAN_ERROR=3

#scan="mvn clean org.jacoco:jacoco-maven-plugin:prepare-agent install -Dmaven.test.failure.ignore=true sonar:sonar"
scan="sonar-scanner"
repo="."
tags=""

usage() {
   echo "Usage: $0 -g [<git repo>] [-s <scan command>] [-t <tag list>]

-g: URL of the git repo to scan, for instance https://github.com/okorach/sonar-scripts.git
    If not specified, assumed to be the local directory and to be a valid local git repository
-s: Build+Scan command to run, by default simply \"sonar-scanner\", but you may provide \"mvn clean install sonar:sonar\"
    or \"gradlew sonarqube\" or \"sonar-scanner -Dsonar.... -X\" or a shell that wraps several commands...
-t: List of tags to scan. All tags will be scanned if not specified, but that can generate a lot of scans.
    You may wish to pick only a few out of all the tags in the history of the project.
    Get the list of tags with \"git tag --sort=creatordate\"
-h: Display this help
"
   exit $EXIT_USAGE;
}

# Read input options
while getopts ":g:s:t:?:" o; do
   case "${o}" in
      s)
         scan=${OPTARG}
         ;;
      g)
         repo=${OPTARG}
         ;;
      t)
         tags="${OPTARG}"
         ;;
      *)
         usage
         ;;
   esac
done
shift $((OPTIND-1))

if [ "$repo" != "." ]; then
   if [ ! -z "$repo" ]; then
      git clone $repo
      if [ $? -ne 0 ]; then
         echo "REPLAY-THE-PAST: Error while cloning repository" 1>&2
         exit $EXIT_GIT_ERROR
      else
         dir=$(basename $repo | sed 's/\.git$//')
         cd $dir
      fi
   fi
fi

echo "REPLAY-THE-PAST: Replaying the past from $PWD"

if [ "$tags" = "" ]; then
   # Get all tags of the repo in historical order
   tags=$(git tag --sort=creatordate)
fi
# Checkout each chosen tag of the projects and run a scan
for tag in $tags
do
   echo "REPLAY-THE-PAST: Fetching tag $tag"
   d=$(git show -s --format=%ci $tag^{commit} | sed -e 's/ /T/' -e 's/ //')
   # Get date without time
   # d=$(git show -s --format=%ci $tag^{commit} | cut -d ' ' -f 1)
   ret=$?
	[ $ret -ne 0 ] && "REPLAY-THE-PAST: Error $ret to get date for tag $tag" && exit $EXIT_GIT_ERROR
   now=$(date +"%Y-%m-%d %H:%M:%S")
   cat <<EOF
========================================================================

     $now: Analysing project code at $tag on date $d

========================================================================
EOF

   echo git checkout -f tags/$tag
   git checkout -f tags/$tag
   ret=$?
	[ $ret -ne 0 ] && "REPLAY-THE-PAST: Error $ret when checking out tag $tag" && exit $EXIT_GIT_ERROR
   echo "REPLAY-THE-PAST: Running: $scan -Dsonar.projectDate=$d -Dsonar.projectVersion=$tag"
   filetag=$(echo $tag | sed 's/\//./g')
   $scan -Dsonar.projectDate=$d -Dsonar.projectVersion=$tag >replay.$filetag.log 2>&1
   echo "REPLAY-THE-PAST: Done for tag $tag, handling next"
	# [ $? -ne 0 ] && exit $EXIT_SCAN_ERROR
done
