#!/bin/bash

secretFiles=`find src -type f  -exec grep -l CONFIDENTIAL {} \; `
excludedFiles=`grep sonar.exclusions sonar-project.properties | cut -d = -f 2-`
echo $secretFiles $excludedFiles | sed 's/ /,/g'
