#!/bin/bash
# $1 - file to search for
# $2 - from git hash
# $3 - to git hash

modified_projects=""
modified_files=$(git log $2..$3 --name-only --pretty=)
all_projects=$(find * -maxdepth 3 -name $1 -exec dirname {} \;)

while read -r file; do
  project_modified=$(echo "${file}" | grep -o "${all_projects}")
  if [ ! -z ${project_modified} ]; then
    modified_projects+="${project_modified}\n"
  elif [ "$(dirname ${file})" == "." ]; then
    modified_projects+=".\n"
  fi
done <<< "$modified_files"

printf ${modified_projects} | sort -u
