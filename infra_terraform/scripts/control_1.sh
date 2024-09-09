#!/bin/bash
mkdir -p ~/.ssh && chmod 700 ~/.ssh
mkdir /home/ubuntu/final_task

sudo cat <<EOF > ~/.ssh/config
Host node*
  StrictHostKeyChecking no
  UserKnownHostsFile /dev/null
  User ubuntu
  IdentityFile /home/ubuntu/final_task/ansible.pem
EOF

chmod 600 ~/.ssh/config

sudo cat <<EOF > /etc/hosts
127.0.0.1 localhost
10.0.101.8 control.example.com control
10.0.101.116 node1.example.com node1
10.0.101.130 node2.example.com node2
EOF

apt-get update -y
sudo apt-get install -y python3 python3-pip
sudo apt-get install -y ansible

mkdir -p /etc/ansible
sudo cat <<EOF > /etc/ansible/hosts
[control]
localhost ansible_connection=local

[managed_nodes]
node1.example.com
node2.example.com
EOF

