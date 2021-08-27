#!/bin/bash

me=$(basename $0)

usage() {
         cat << EOF

Usage: $me [-u <sq_url>] [-h] [<download_directory>]

-u: Define SQ URL, defaults to \$SONAR_HOST_URL, or to http://localhost:9000 if not set
-t: Define SQ token, defaults to \$SONAR_TOKEN
-h: Displays this help and exit

Examples:

$me -u http://localhost:9000 wrapper_download_dir

EOF
}

wrapper_download_loc="wrapper"
sq=${SONAR_HOST_URL:-http://localhost:9000}

while [ $# -gt 0 ]; do
   case $1 in
      -u)
         shift
         sq=$1
         ;;
      -t)
         shift
         token=$1
         ;;
      -h)
         usage
         exit 1
         ;;
      *)
         wrapper_download_loc=$1
         ;;
   esac
   shift
done

if [ `uname` = "Darwin" ]; then
  os_wrapper=build-wrapper-macosx-x86
else
  os_wrapper=build-wrapper-linux-x86-64
fi

# Download and unzip latest build wrapper
echo "Downloading build wrapper:"
echo "- from $sq/static/cpp/$os_wrapper.zip"
echo "- to $wrapper_download_loc/wrapper.zip..."
curl -s --create-dirs -o $wrapper_download_loc/wrapper.zip $sq/static/cpp/$os_wrapper.zip
echo "Unzipping..."
cd $wrapper_download_loc; unzip -q -o wrapper.zip; cd - 1>/dev/null
echo "Build Wrapper downloaded at $wrapper_download_loc/$os_wrapper/$os_wrapper"
$wrapper_download_loc/$os_wrapper/$os_wrapper -v

exit $?