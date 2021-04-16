#!/bin/bash

# Define some variables
passwd_file="/etc/passwd"
shadow_file="/etc/shadow"
g_file="/etc/group"
h_dir="/home"

# Check the root rights
if [ "$(id -un)" != "root" ]; then
    echo "ERROR: You must be root to run this script." >&2
    exit 1
fi

# Creating user
echo "INFO: Add new user account to $(hostname)"
/bin/echo -n "Enter login: " ; read -r login

if [ -d "$h_dir/$login" ]; then
    echo "ERROR: User already exist." >&2
    exit 1
fi

# 5000 - this is a pool for uid. Change the number of pool if needed
uid="$(awk -F: '{ if (big < $3 && $3 < 5000) big=$3 } END {print big + 1 }' $passwd_file)"

home_dir=$h_dir/$login
gid=$uid

/bin/echo -n "Enter full name: " ; read -r fullname
/bin/echo -n "Enter shell: " ; read -r shell

echo "INFO: Setting up account $login for $fullname.."

echo "${login}:x:${uid}:${gid}:${fullname}:${home_dir}:$shell" >> $passwd_file
echo "${login}:*:11647:0:99999:7:::" >> $shadow_file
echo "${login}:x:${gid}:$login" >> $g_file

mkdir "$home_dir"
cp -R /etc/skel/.[a-zA-z]* "$home_dir"
chmod 755 "$home_dir"
chown -R "${login}":"${login}" "$home_dir"

# Set password
exec passwd "$login"