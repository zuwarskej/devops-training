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
docker -v

#################################################

INFO "Install & configure mdadm"
apt-get install -yqq mdadm > /dev/null 2>&1
wipefs --all --force /dev/sd{b,c,d,e}
echo yes | mdadm --create --verbose /dev/md0 -l 0 -n 2 /dev/sd{b,c}
echo yes | mdadm --create --verbose /dev/md1 -l 1 -n 2 /dev/sd{d,e}
echo "DEVICE partitions" > /etc/mdadm/mdadm.conf
mdadm --detail --scan --verbose | awk '/ARRAY/ {print}' >> /etc/mdadm/mdadm.conf
mkfs.ext4 /dev/md0
mkfs.ext4 /dev/md1
mkdir /var/raid0
mkdir /var/raid1
echo "/dev/md0        /var/raid0    ext4    defaults    1 2" >> /etc/fstab
echo "/dev/md1        /var/raid1    ext4    defaults    1 2" >> /etc/fstab
mount -a
lsblk
cat /proc/mdstat

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
