#!/bin/bash

# Descryption:              Customize system info in Debian 10
# Path to file:             /etc/profile.d/20-lastlogin.sh
# Make executable:          chmod +x /etc/profile.d/20-lastlogin.sh

#Last login user
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