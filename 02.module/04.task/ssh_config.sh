#!/bin/bash

# Define some fuctions
INFO(){ echo "INFO: $*";}
WARN(){ echo "WARN: $*";}
ERRO(){ echo "ERRO: $*"; exit 1;}

INFO "Configure Permissions for SSH Key"
chown -R vagrant:vagrant /home/vagrant/.ssh
chmod 700 /home/vagrant/.ssh
chmod 400 /home/vagrant/.ssh/authorized_keys
chmod 400 /home/vagrant/.ssh/id_rsa

INFO "Copy Config File for SSH Agent"
FILE=/etc/ssh/ssh_config
cat <<EOF > $FILE
Host *
    User vagrant
    PasswordAuthentication no
    StrictHostKeyChecking no
    UserKnownHostsFile=/dev/null
    IdentityFile /home/vagrant/.ssh/id_rsa
    IdentitiesOnly yes
EOF

INFO "Restart SSH"
systemctl restart ssh
systemctl restart sshd