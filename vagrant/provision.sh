# Author:  @JarenGlover
# provision script to install all system wide requirements
# Date 9/28/15


# nozero exit from any command we want to ERROR
set -ex

err_report() {
    echo "ERROR in provision script on line $1"
    exit 187
}

trap 'err_report $LINENO' ERR


# we want to latest git b/c of prior secuirty concerns
add-apt-repository -y ppa:git-core/ppa
apt-get update

# build-essential g++ are for nodeenv, ntp
apt-get install -y git nginx build-essential g++ libssl-dev ntp ntpdate

# change ntp servers to be US then restart - going to keep it UTC
sudo sed -i "s/ubuntu.pool.ntp.org/north-america.pool.ntp.org/g" /etc/ntp.conf
sudo service ntp restart

# Install pip then virtualenv - keep app encapsulated
curl "https://bootstrap.pypa.io/get-pip.py" -o "get-pip.py"
python get-pip.py
pip install virtualenv


#iptables - b/c you know we don't want to be front page of NYTimes
sudo iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
sudo iptables -A INPUT -p tcp --dport 22 -j ACCEPT      # ssh
sudo iptables -A INPUT -p tcp --dport 80 -j ACCEPT      # http
sudo iptables -A INPUT -p tcp --dport 443 -j ACCEPT     # https
sudo iptables -I INPUT 1 -i lo -j ACCEPT                # localhost

# ntp rules - stop clock drift - uses default UTC timezone
sudo iptables -A INPUT -p udp --dport 123 -j ACCEPT
sudo iptables -A OUTPUT -p udp --sport 123 -j ACCEPT
sudo iptables -P INPUT DROP

#turn swap off now
sudo sysctl vm.swappiness=0

# removes it on reboot
sudo echo "vm.swappiness = 0" >> /etc/sysctl.conf
exit 0
