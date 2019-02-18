#!/bin/bash

# global parameters
# -----------------
# $1 - filename to be found

all_projects=$(find "$PWD" -name $1)
for project in ${all_projects}; do
  cd $(dirname ${project})
  cxcloud deploy
done
