#!/bin/bash

# global parameters
# -----------------
# $1 - file to search for
# $2 - git hash fromP
# $3 - git hash to

# rfind() parameters
# ------------------
# $1 - file name to find
# $2 - start path from where to start search

function rfind() {
  current_folder="$2"
  while [[ $current_folder != "." ]]; do
    modified_projects+=($(find "$current_folder" -maxdepth 1 -name "$1"))
    current_folder=$(dirname $current_folder)
  done
}

modified_projects=()

if [ -z "$2" ]; then
  modified_files=$(git log master..HEAD --name-only --pretty=)
else
  modified_files=$(git log $2..$3 --name-only --pretty=)
fi

while read -r line; do
  rfind $1 $(dirname "${line}")
done <<<"$modified_files"

echo "${modified_projects[@]}" | tr ' ' '\n' | sort -u
