#!/bin/bash

# $1 - file name to find
# $2 - start path from where to start search

function rfind () {
  current_folder="$2"

  while [[ $current_folder != "." ]] ; do
    modified_projects+=($(find "$current_folder" -maxdepth 1 -name "$1"))
    current_folder=$(dirname $current_folder)
  done
}

modified_projects=()
modified_files=$(git log master..HEAD --name-only --pretty=)

while read -r line; do
    rfind index.html $(dirname "${line}")
done <<< "$modified_files"

sorted_files=($(echo "${modified_projects[@]}" | tr ' ' '\n' | sort -u | tr '\n' ' '))

echo ${sorted_files[@]}
