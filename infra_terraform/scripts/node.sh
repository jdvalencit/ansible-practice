#!/bin/bash

sudo apt-get update -y
sudo apt-get install -y python3 python3-pip
sudo apt-get purge zip
sudo apt-get purge unzip

sudo bash -c 'cat <<EOF > /etc/hosts
127.0.0.1 localhost
10.0.101.8 control.example.com control
10.0.101.116 node1.example.com node1
10.0.101.130 node2.example.com node2
EOF'

sudo apt-get remove -y htop

sudo systemctl stop apparmor
sudo systemctl disable apparmor
sudo apt install policycoreutils selinux-basics selinux-utils -y
sudo selinux-activate
