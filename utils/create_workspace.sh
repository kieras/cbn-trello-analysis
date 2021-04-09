#!/bin/bash

# This script must be run from cloud-shell
# It will generate the user's workspace by:
#  - Installing the python dependecies
#  - Fetching the project from git hub
#  - Creating an alias to startup the jupyter

VM_NAME=cbn-metrics
ZONE=us-central1-a
GIT_USER=****
GIT_PASSWORD=****

USER=$(whoami)

#sh install_packages.sh
gcloud compute ssh --zone $ZONE $VM_NAME --command \
    "git clone -b metrics_sheet_trello https://${GIT_USER}:${GIT_PASSWORD}@github.com/kieras/cbn-trello-analysis.git && \
    touch file.txt"