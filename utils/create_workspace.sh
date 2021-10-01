#!/bin/bash

# This script must be run from cloud-shell
# It will generate the user's workspace by:
#  - Removing the project folder if it exist
#  - Fetching the project from git hub
#  - Installing the python dependecies
#  - Creating an alias to startup the jupyter

VM_NAME=cbn-metrics
ZONE=us-central1-a
GIT_USER=$1
GIT_PASSWORD=$2

gcloud compute ssh --zone $ZONE $VM_NAME --command " \
    rm -rf cbn-trello-analysis/ && \
    git clone -b main https://${GIT_USER}:${GIT_PASSWORD}@github.com/kieras/cbn-trello-analysis.git && \
    sh ./cbn-trello-analysis/utils/install_packages.sh \
  "

gcloud compute scp --zone=$ZONE $home/cbn-metrics-keys/keys.json $VM_NAME:./cbn-trello-analysis && \
gcloud compute scp --zone=$ZONE $home/cbn-metrics-keys/cbn-trello-metrics-sa.json $VM_NAME:./cbn-trello-analysis \

is_alias_available=$(cat .bashrc | grep cbn-metrics=)

if [ -z "$is_alias_available" ]; then
  echo "Creating the alias for cbn-metrics"
  echo "" >> .bashrc
  echo "alias cbn-metrics=\"gcloud compute ssh $VM_NAME \\
       --zone $ZONE \\
       -- -L 8080:localhost:8888 -4 \\
       '/opt/cbn-metrics/bin/run_jupyterlab'\"" \
   >> .bashrc
else
  echo "The cbn-metrics alias already exists. Nothing to do."
fi