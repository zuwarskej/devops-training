#!/bin/bash

# Descryption:              Customize system info in Debian 10
# Path to file:             /etc/update-motd.d/20-system_info_ssh
# Delete default file:      rm /etc/motd
# Make executable:          chmod +x /etc/update-motd.d/20-system_info_ssh
# Stop executable default:  chmod -x /etc/update-motd.d/10-uname
# Add PrintLastLog:         echo PrintLastLog no >> /etc/ssh/sshd_config

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