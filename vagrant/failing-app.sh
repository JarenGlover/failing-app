#!/usr/bin/env bash

# Author:  @JarenGlover
# deploy the bad-webapp application into the node
# Date 9/28/15


# username who will execute app set up and run
USER_NAME='web'
APP_NAME='bad-webapp'

# nozero exit from any command we want to ERROR
set -xe

err_report() {
    echo "ERROR in the app deploy script on line $1"
    exit 187
}
trap 'err_report $LINENO' ERR

sudo su -l $USER_NAME

# the test app
git clone https://github.com/Shyp/bad-webapp

virtualenv venv
source venv/bin/activate

pip install -r /vagrant/vagrant/requirements.txt
# to reduce moving parts provide version info via commandline
#pip install nodeenv==0.13.6 virtualenv==13.1.2 wsgiref==0.1.2 supervisor==3.1.3

#build node w/ prebuitl
nodeenv -vp --node=4.0.0 --with-npm --npm=2.14.2 --prebuilt

# install modules
cd /home/$USER_NAME/$APP_NAME && npm install

# cp and rm over nginx config files then reload
sudo cp /vagrant/nginx/failing-app.conf /etc/nginx/sites-enabled/failing-app.conf
sudo rm /etc/nginx/sites-enabled/default
sudo nginx -s reload

# make nginx and node app running via supervisord my docker friend
/home/$USER_NAME/venv/bin/supervisord -c /vagrant/supervisor/supervisor.conf
exit 0
