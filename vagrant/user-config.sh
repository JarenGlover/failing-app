#!/usr/bin/env bash

# Author:  @JarenGlover
# user profile script
# Date 9/28/15

# user name to user for configuration
# NOTE: I should prob set my app_user_name to the bash profile
# NOTE cont: this way I can leverage it instead of haven't to name it

USER_NAME='web'
# nozero exit from any command we want to ERROR
set -ex

err_report() {
    echo "ERROR in user-config script on line $1"
    exit 187
}

trap 'err_report $LINENO' ERR
# create user and sudo acces
useradd -s /bin/bash -m -g syslog -d /home/$USER_NAME $USER_NAME
echo "$USER_NAME ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/vagrant

#ssh setup
sudo su $USER_NAME -l
mkdir /home/$USER_NAME/.ssh
cat /vagrant/devops/sample_rsa.pub >> /home/$USER_NAME/.ssh/authorized_keys
cp /vagrant/devops/sample_rsa.pub  /home/$USER_NAME/.ssh/.

exit 0
