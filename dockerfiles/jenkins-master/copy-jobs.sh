#!/bin/bash
mkdir -p /var/jenkins_home/jobs/
installed_jobs=$(ls -1 /var/jenkins_home/jobs/)
vcs_jobs=$(ls -1 /jenkins_jobs/)

for job in ${vcs_jobs}; do
  job_is_installed=$(echo "${installed_jobs}" | grep "${job}")
  # Installing job if it doesn't exist
  if [ "${job_is_installed}" != "${job}" ]; then
    cp -a /jenkins_jobs/${job} /var/jenkins_home/jobs/
  fi
done
