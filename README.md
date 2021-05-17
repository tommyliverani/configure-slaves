# configure-slaves

Simple script that configure remote nodes in order to act as jenkins slaves and it is made to run in the jenkins master.
The script use **_ansible playbook_** and implements the following features:

* ensure java is installed in each slaves
* esnude docker is installed in each slaves
* generate ca credentials
* generate a client signed certificate
* generate server signed certificates in each slaves
* configure the docker daemon in each slaves to act as docker host with the generated certificate

After that process you will be able to use the configured nodes as simple jenkins slaves or as docker clouds.


## Requirements
* Have openssl installed
* Have ansible installed in the jenkins master
* Configure each slaves in /etc/ansible/hosts.

## commands

* **_bash commands.sh ca_**: generate ca credentials
* **_bash commands.sh client_**: generate a client signed certificate
* **_bash commands.sh slaves_**: generate a server signed certificate in each slaves and configure the docker daemon
* **_bash commands.sh delete_**: delete all generated files



