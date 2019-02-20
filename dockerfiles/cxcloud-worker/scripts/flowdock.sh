#!/bin/bash

function help {
    printf "
This script will update Development acctivity on Flowdock

All arguments are required:
    -t  Secret flowdock application token
    -m  The body of the notification
    -j  Jenkins URL to build job
    -b  Git branch
    -g  Git URL
    -s  Build status
    -c  Build Color
    -e  Environment URL to test the build
    \n";
}

# Get parameters
while getopts t:m:j:g:b:s:c:e: option; do
    case "${option}" in
        t) flow_token=${OPTARG};;
        m) message=${OPTARG};;
        j) jenkins_url=${OPTARG};;
        g) git_url=${OPTARG};;
        b) git_branch=${OPTARG};;
        s) build_status=${OPTARG};;
        c) build_color=${OPTARG};;
        e) test_env=${OPTARG};;
    esac
done

# Check that required parameter exist
if [ -z "${flow_token}" ] ||
  [ -z "${message}" ] ||
  [ -z "${jenkins_url}" ] ||
  [ -z "${git_url}" ] ||
  [ -z "${git_branch}" ] ||
  [ -z "${build_status}" ] ||
  [ -z "${build_color}" ] ||
  [ -z "${test_env}" ]; then
    help
    exit
fi

# Create Flowdock notification JSON
read -d '' notify <<-EOF
{
  "flow_token": "${flow_token}",
  "event": "activity",
  "author": {
    "name": "Jenkins",
    "avatar": "https://wiki.jenkins.io/download/attachments/2916393/headshot.png?version=1&modificationDate=1302753947000&api=v2"
  },
  "title": "Update ${git_branch}",
  "external_thread_id": "${git_branch}",
  "thread": {
    "title": "${git_branch}",
    "fields": [
      { "label": "Jenkins URL", "value": "<a href=${jenkins_url}>Jenkins Job</a>" },
      { "label": "GitHub URL", "value": "<a href=${git_url}>Git ${git_branch}</a>" }
    ],
    "body": "${message}",
    "external_url": "${test_env}",
    "status": {
      "color": "${build_color}",
      "value": "${build_status}"
    }
  }
}
EOF

# Notify Flowdock
curl -s -o /dev/null -i -X POST -H "Content-Type: application/json" -d "${notify}" https://api.flowdock.com/messages
