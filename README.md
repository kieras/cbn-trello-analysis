# CBN Trello Analysis

## Resources
### Apis
- APIs Google Compute Engine
- Google Sheets API

### GCE
- n1-standard-1 (with persistent disk of 10gb)

## Setting up the env
Considering we already have a project with a billing account activated.

### Credentials
#### Google
1. Activate the necessary apis:
	Go to ‘APIs and services’ -> ‘Dashboard’ and click on ‘+ Enable Apis and Services’. Search for the APIs and enable them.
  
2. Create credentials:
    1. Go to ‘APIs and Services’ and click on ‘Credentials’
    2. Click on ‘+ Create Credentials’ and select ‘Service Account’
	  3. Choose an appropriate name and click on ‘Create’
	  4. Select the role ‘Service Account User’ and click on ‘Continue’
	  5. Click on ‘Done’
	  6. Select the service account you just created and go to the ‘Keys’ tab.
    7. Click on ‘Add key’ and ‘Create new key’, select ‘JSON’ and click on ‘Create’.
    8. Download the service account and keep it SAFE. It will be used to connect to the spreadsheet
    9. Rename it to `cbn-trello-metrics-sa.json`.
    
#### Trello
1. Make sure you are logged in to the trello.
2. Go to this [link](https://trello.com/app-key) and follow the instructions to generate both the ‘api key and api token’.

#### Github
1. Go to this [link](https://docs.github.com/en/github/authenticating-to-github/keeping-your-account-and-data-secure/creating-a-personal-access-token) and follow the instructions to generate the ‘token’.

### Setup Jupyter
1. Open the cloud shell.
2. Set some ambient variables:
    ``` 
    PROJECT_NAME={your-project-name}
    ```
    ```
    VM_NAME=cbn-metrics
    ZONE=us-central1-a
    MACHINE_TYPE=n1-standard-1 
    ```
    ```
    GIT_USER={your-git-user}
    ```
    ```
    GIT_PASSWORD={your-token-generated}
    ```
3. Create a folder to store the keys nedded:
    ```
    mkdir $home/cbn-metrics-keys
    ```
4. If you already have cloned from github the `cbn-trello-analysis` project on your personal computer, create the file requested (`jeys.json`) upload them and the service account json file( `cbn-trello-metrics-sa.json` previously created on the Credentials - Google section) on cloudshell to the folder `$home/cbn-metrics-keys` created. 
    *If you don't have cloned:*
    ```
     git clone https://$GIT_USER:$GIT_PASSWORD@github.com/kieras/cbn-trello-analysis
    ```
    1. Create a file called `keys.json` based on the provided `keys_template.json` and fill up the following information: (you can use your prefer text editor. Ex: nano)
        - api_key and token (obtained on the Credentials - Trello section)
        - spreadsheet_key (extract it from the spreadsheet url)
        - service account file name(make sure the file is located at the same level as this file)
    2. Upload the service account json file(previously created on the Credentials - Google section) to cloudshell.
    3. Move both to the folder `$home/cbn-metrics-keys` created.
        ```
        mv keys.json $home/cbn-metrics-keys
        ```
        ```
        mv {your-service-account-json-file-name} $home/cbn-metrics-keys
        ```
5. Share the sheet `[Alpha] Hours Report - v2.0` (Just read permission) with the `client_email` field inside the service account file.


6. Create an instance:
    ```
    gcloud compute --project=$PROJECT_NAME \
    instances create $VM_NAME \
        --zone=$ZONE \
        --machine-type=$MACHINE_TYPE \
        --maintenance-policy=MIGRATE \
        --image-family=debian-10 \
        --image-project=debian-cloud \
        --scopes=cloud-platform
    ```
7. SSHing:
    ```
    gcloud compute ssh $VM_NAME --zone $ZONE
    ```
   
8. Install the machine dependencies:
    ```
    sudo apt update
    ```
    ```
    sudo apt -y upgrade
    ```
    ```
    sudo apt -y install python3-pip
    ```
    ```
    sudo apt-get -y install git-all
    ```
    ```
    sudo pip3 install --upgrade jupyterlab google-api-python-client
    ```
    
9. Create a script to execute jupyter:
    ```
    sudo mkdir -p /opt/cbn-metrics/bin
    ```
    ```
    sudo sh -c 'echo "#!/bin/bash" > /opt/cbn-metrics/bin/run_jupyterlab'
    ```
    ```
    sudo chmod a+x /opt/cbn-metrics/bin/run_jupyterlab
    ```
    
10. Add the following setup in the script to execute jupyter with no password and with no external access:
    ```
    sudo sh -c 'echo "jupyter lab --ip=127.0.0.1 --NotebookApp.token=\"\" --NotebookApp.password=\"\" --NotebookApp.allow_origin=\"*\"" \
    >> /opt/cbn-metrics/bin/run_jupyterlab'
    ```
    
11. Exit the SSH acces:
    ```
    exit
    ```
    
12. If you already have cloned from github the `cbn-trello-analysis` project on cloudshell, ignore. If you don't, upload the `utils` folder from `cbn-trello-analysis` from your computer.

13. Enter on `utils` folder:
    If you have cloned before:
    ```
    cd path-to-cbn-trello-analysis/cbn-trello-analysis/utils
    ```
    If you just upload the utils folder:
    ```
    cd path-to-utils/utils
    ```
    
14. Execute the script to create the workspace. It will access the instance by SSH, clone the repository, install all dependencies and add an alias in your cloud shell .bashrc that will be used to shhing into the vm and run the jupyter startup script created on the previous steps.
    ```
    sh create_workspace.sh $GIT_USER $GIT_PASSWORD
    ```
    
15. Refresh the .bashrc:
    ```
    source .bashrc
    ```
    
16. From now on, every time you want to access the jupyter, turn on the instance, run the command on cloud shell:
    ```
    cbn-metrics
    ```
    and click on ‘Web preview -> Preview on port XXXX’.
    
## Troubleshooting

 - If you have some problem when trying to access the instance by SSH, try to remove the older keys:
    ```
    cd $home
    cd .ssh
    ```
    ```
    rm google_compute_engine
	  rm google_compute_engine.pub
	  rm google_compute_known_hosts
    ```
    Also delete the Compute Engine Metadata. Go to `Compute Engine -> Metadata -> SSH Keys -> Edit` and remove your user key.
    
  - If when you run the command `cbn-metrics`, get an error like:
    ```
    - bash:  : command not found
    ```
    Is nedded to refresh the .bashrc:
    ```
    source .bashrc
    ```
