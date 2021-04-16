#!/bin/bash
export DEBIAN_FRONTEND=noninteractive

# Define some fuctions
INFO(){ echo "INFO: $*";}
WARN(){ echo "WARN: $*";}
ERRO(){ echo "ERRO: $*"; exit 1;}

# Set up SSH
INFO "Configure permissions for SSH key"
chown -R vagrant:vagrant /home/vagrant/.ssh
chmod 700 /home/vagrant/.ssh
chmod 400 /home/vagrant/.ssh/authorized_keys
chmod 400 /home/vagrant/.ssh/id_rsa

INFO "Create config file for SSH agent"
FILE="/etc/ssh/ssh_config"
cat << "EOF" > $FILE
Host *
    User vagrant
    PasswordAuthentication no
    StrictHostKeyChecking no
    UserKnownHostsFile=/dev/null
    IdentityFile /home/vagrant/.ssh/id_rsa
    IdentitiesOnly yes
EOF

INFO "Create config file for SSH server"
FILE="/etc/ssh/sshd_config"
cat << "EOF" > $FILE
Protocol 2

# Port settings
Port 22
AddressFamily inet

# Supported HostKey algorithms by order of preference.
HostKey /etc/ssh/ssh_host_ed25519_key
HostKey /etc/ssh/ssh_host_rsa_key
HostKey /etc/ssh/ssh_host_ecdsa_key

KexAlgorithms curve25519-sha256@libssh.org,ecdh-sha2-nistp521,ecdh-sha2-nistp384,ecdh-sha2-nistp256,diffie-hellman-group-exchange-sha256

Ciphers chacha20-poly1305@openssh.com,aes256-gcm@openssh.com,aes128-gcm@openssh.com,aes256-ctr,aes192-ctr,aes128-ctr

MACs hmac-sha2-512-etm@openssh.com,hmac-sha2-256-etm@openssh.com,umac-128-etm@openssh.com,hmac-sha2-512,hmac-sha2-256,umac-128@openssh.com

# Logging. LogLevel VERBOSE logs user's key fingerprint on login.
LogLevel VERBOSE

# Authentication: Password based logins are disabled - only public key based logins are allowed.
AuthenticationMethods publickey
PasswordAuthentication no
PermitEmptyPasswords no
PermitRootLogin no
AllowUsers vagrant
TCPKeepAlive yes
ClientAliveInterval 1m
ClientAliveCountMax 5
MaxAuthTries 3
MaxSessions 5
PrintLastLog no
UseDNS yes
UsePAM no

# Allow client to pass locale environment variables
AcceptEnv LANG LC_*

# Log sftp level file access (read/write/etc.) that would not be easily logged otherwise.
Subsystem sftp  /usr/lib/ssh/sftp-server -f AUTHPRIV -l INFO
EOF

INFO "Restart SSH"
systemctl restart ssh
systemctl restart sshd

#################################################

# Customize .bashrc
INFO "Adding some options to .bashrc"
mkdir /home/vagrant/bin
FILE="/home/vagrant/.bashrc"
cat << "EOF" >> $FILE

# Command prompt
export PS1='\t \[\033[01;32m\]\u\[\033[01;34m\] \w\[\033[01;33m\]$(__git_ps1)\[\033[01;34m\] \$\[\033[00m\] '

# Add PATH ~/bin
export PATH=~/bin:"$PATH"

# Some commands aliases
alias cat='cat -n'
alias ll='ls -lah'
alias ps='ps -cu'
alias update='sudo apt update && sudo apt upgrade -yqq'
alias autoremove='sudo apt autoremove -yqq && sudo apt autoclean'

# Generate random password (Can be useful for SSH passphrase)
genpasswd () {
    local l=$1
    [ "$l" == "" ] && l=20
    tr -dc A-Za-z0-9_ < /dev/urandom | head -c ${l} | xargs
}
EOF
source /home/vagrant/.bashrc

#################################################

# Set up system info and lastlogin
INFO "Delete defaut system info"
rm -f /etc/update-motd.d/99-bento
rm /etc/motd
chmod -x /etc/update-motd.d/10-uname

INFO "Update lastlog info"
FILE="/etc/profile.d/20-lastlogin.sh"
cat << "EOF" > $FILE
#!/bin/sh

# Set up system info for SSH
SystemMountPoint="/";
LinesPrefix="  ";
b=$(tput bold); n=$(tput sgr0);

SystemLoad=$(cat /proc/loadavg | cut -d" " -f1);
ProcessesCount=$(cat /proc/loadavg | cut -d"/" -f2 | cut -d" " -f1);

MountPointInfo=$(/bin/df -Th $SystemMountPoint 2>/dev/null | tail -n 1);
MountPointFreeSpace=( \
  $(echo $MountPointInfo | awk '{ print $6 }') \
  $(echo $MountPointInfo | awk '{ print $3 }') \
);
UsersOnlineCount=$(users | wc -w);

UsedRAMsize=$(free -b | grep Mem | awk '{print $3/$2 * 100.0}');

localIPaddr=$(hostname -I);

echo "You login to: $(hostname -f)."
echo ""
if [ ! -z "${LinesPrefix}" ] && [ ! -z "${SystemLoad}" ]; then
  echo -e "${LinesPrefix}${b}System load:${n}\t${SystemLoad}\t\t\t${LinesPrefix}${b}Processes:${n}\t\t${ProcessesCount}";
fi;

if [ ! -z "${MountPointFreeSpace[0]}" ] && [ ! -z "${MountPointFreeSpace[1]}" ]; then
  echo -ne "${LinesPrefix}${b}Usage of $SystemMountPoint:${n}\t${MountPointFreeSpace[0]} of ${MountPointFreeSpace[1]}\t\t";
fi;
echo -e "${LinesPrefix}${b}Users logged in:${n}\t${UsersOnlineCount}";

if [ ! -z "${UsedRAMsize}" ]; then
  echo -ne "${LinesPrefix}${b}Memory usage:${n}\t${UsedRAMsize}%\t\t";
fi;
echo -e "${LinesPrefix}${b}Local IP address:${n}\t${localIPaddr}";
echo ""

# Last login user
LASTLOG=$(last --time-format full -n 3 -w | grep pts/ | awk '{ print $1 " "$3 " "$4 " "$5 " "$6 " "$7" "$8}')
USER=$(echo $LASTLOG | awk '{print $8}')
FROM_IP=$(echo $LASTLOG | awk '{print $9}')
DATA=$(echo $LASTLOG |awk '{print $10 " "$11 " "$12 " "$13 " "$14}')
if [ "$USER" == "" ]; then
    MESSAGE="First login"
else
    MESSAGE="$DATA user '$USER' login from IP:'$FROM_IP'"
fi

echo "Last login: $MESSAGE"
EOF
chmod +x /etc/profile.d/20-lastlogin.sh

#################################################

# Set up iptables
INFO "Set up rules for iptables"
cp /vagrant/iptables_rules.sh /home/vagrant/bin/iptables_rules.sh
chmod +x /home/vagrant/bin/iptables_rules.sh
chown -R vagrant:vagrant /home/vagrant/bin
bash /home/vagrant/bin/iptables_rules.sh
FILE="/etc/network/if-pre-up.d/iptables"
cat << "EOF" > $FILE
#!/bin/sh

/sbin/iptables-restore < /etc/iptables.rules
EOF

#################################################
