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
   >&2 echo "Usage: $0 -g [<git repo>] [-t <tag list>]

-g: URL of the git repo to scan, for instance https://github.com/okorach/sonar-public-scripts.git
    If not specified, assumed to be the local directory and to be a valid local git repository
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
      g)
         repo=${OPTARG}
         ;;
      t)
         tags=${OPTARG}
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
         >&2 echo "LOC-ACTIVITY: Error while cloning repository" 1>&2
         exit $EXIT_GIT_ERROR
      else
         dir=$(basename $repo | sed 's/\.git$//')
         cd $dir
      fi
   fi
fi

>&2 echo "LOC-ACTIVITY: Replaying the past from $PWD"

if [ "$tags" = "" ]; then
   # Get all tags of the repo in historical order
   tags=$(git tag --sort=creatordate | awk '{print}' ORS=' ')
fi
# Checkout each chosen tag of the projects and run a scan
is_first=1
last_date=""
total_add=0
total_rm=0
for tag in $tags
do
   >&2 echo "LOC-ACTIVITY: Fetching tag $tag"
   #d=$(git show -s --format=%ci $tag^{commit} | sed -e 's/ /T/' -e 's/ //')
   # Get date without time
   d=$(git show -s --format=%ci $tag^{commit} | cut -d ' ' -f 1)
   ret=$?
   [ $ret -ne 0 ] && >&2 echo "LOC-ACTIVITY: Error $ret to get date for tag $tag" && exit $EXIT_GIT_ERROR

   >&2 echo git checkout -f tags/$tag
   #git checkout -f tags/$tag
   ret=$?
   [ $ret -ne 0 ] && >&2 echo "LOC-ACTIVITY: Error $ret when checking out tag $tag" && exit $EXIT_GIT_ERROR
   if [ $is_first -eq 1 ]; then
      added_loc=$(git diff $tag | grep -e '^+' | wc -l  | sed 's/ //g')
      removed_loc=0
   else
      removed_loc=$(git diff $oldtag $tag | grep -e '^-' | wc -l | sed 's/ //g')
      added_loc=$(git diff $oldtag $tag | grep -e '^+' | wc -l  | sed 's/ //g')
   fi
   if [ "$d" == "$last_date" ]; then
      >&2 echo "LOC-ACTIVITY: same date as last tag, adding up LoCs"
      total_add=$((total_add + added_loc))
      total_rm=$((total_rm + removed_loc))
      continue
   fi

   echo "$d,$tag,$added_loc,$removed_loc"
   last_date=$d
   total_add=0
   total_rm=0

   >&2 echo "LOC-ACTIVITY: Done for tag $tag, handling next"
   # [ $? -ne 0 ] && exit $EXIT_SCAN_ERROR
   is_first=0
   oldtag=$tag
done
