#!/bin/sh

me=$(basename $0)
install_dir=$(dirname $0)

usage() {
         cat << EOF

Usage: $me [-h] <cobertura-xml-report>

Converts a Cobertura coverage report into the SonarQube generic format using XSLT transformation

-h: Displays this help and exit
Examples:

$me cobertura_coverage.xml >sq_generic_coverage.xml
cat cobertura_coverage.xml | $me >sq_generic_coverage.xml
EOF
}

cobertura_cov=""

while [ $# -gt 0 ]; do
   case $1 in
      -h)
         usage
         exit 1
         ;;
      *)
         cobertura_cov=$1
         ;;
   esac
   shift
done

if [ "$(which xsltproc)" == "" ]; then
    echo "ERROR: xsltproc not found. This is required for trasnformation, please install or add to the path"
    exit 2
fi

if [ "$cobertura_cov" == "" ]; then
    echo "ERROR: <cobertura-xml-report> mandatory."
    usage
    exit 4
elif [ ! -f $cobertura_cov ]; then
    echo "ERROR: $cobertura_cov file not found."
    exit 3
fi
xsltproc $install_dir/cobertura2sonar.xsl $cobertura_cov | xmllint --format -
exit $?
