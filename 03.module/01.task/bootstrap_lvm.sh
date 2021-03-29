#!/bin/bash
export DEBIAN_FRONTEND=noninteractive

# Define some fuctions
INFO(){ echo "INFO: $*";}
WARN(){ echo "WARN: $*";}
ERRO(){ echo "ERRO: $*"; exit 1;}

INFO "Configure permissions for SSH Key"
chown -R vagrant:vagrant /home/vagrant/.ssh
chmod 700 /home/vagrant/.ssh
chmod 400 /home/vagrant/.ssh/authorized_keys
chmod 400 /home/vagrant/.ssh/id_rsa

INFO "Copy config file for SSH Agent"
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

#################################################

INFO "Install Docker"
apt-get install -yqq apt-transport-https ca-certificates gnupg lsb-release > /dev/null 2>&1
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo \
  "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
apt-get update -yqq > /dev/null 2>&1
apt-get install -yqq docker-ce docker-ce-cli containerd.io > /dev/null 2>&1
docker --version

INFO "Configure DeviceMapper for Docker"
apt-get install -yqq thin-provisioning-tools > /dev/null 2>&1
systemctl stop docker
pvcreate /dev/sdb
vgcreate docker /dev/sdb
lvcreate --wipesignatures y -n thinpool docker -l 95%VG
lvcreate --wipesignatures y -n thinpoolmeta docker -l 1%VG
lvconvert -y --zero n -c 512K --thinpool docker/thinpool --poolmetadata docker/thinpoolmeta

INFO "Configure /etc/lvm/profile/docker-thinpool.profile"
FILE=/etc/lvm/profile/docker-thinpool.profile
cat <<EOF > $FILE
activation {
    thin_pool_autoextend_threshold=80
    thin_pool_autoextend_percent=20
}
EOF

lvchange --metadataprofile docker-thinpool docker/thinpool
lvs -o+seg_monitor
rm -rf /var/lib/docker/*

INFO "Configure /etc/docker/daemon.json"
FILE=/etc/docker/daemon.json
cat <<EOF > $FILE
{
    "storage-driver": "devicemapper",
    "storage-opts": [
    "dm.thinpooldev=/dev/mapper/docker-thinpool",
    "dm.use_deferred_removal=true",
    "dm.use_deferred_deletion=true"
    ]
}
EOF

INFO "Start Docker"
systemctl daemon-reload
systemctl start docker

INFO "Check info"
docker info | grep -i "storage driver"
lsblk

#################################################

INFO "Create user for work with Docker & Services"
useradd -m -s /bin/bash deploy
groupadd services
usermod -aG docker,services deploy
FILE=/etc/sudoers.d/deploy
cat <<EOF > $FILE
deploy ALL=(ALL) NOPASSWD:ALL
%services ALL=NOPASSWD: /bin/systemctl start docker.service
%services ALL=NOPASSWD: /bin/systemctl stop docker.service
%services ALL=NOPASSWD: /bin/systemctl restart docker.service
EOF

#################################################

INFO "Install NTP"
apt-get install -yqq ntp > /dev/null 2>&1
ntpq -p