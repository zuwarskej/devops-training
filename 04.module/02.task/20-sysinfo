#!/bin/sh

# Descryption:              Customize system info in Debian 10
# Path to file:             /etc/update-motd.d/20-sysinfo
# Delete default file:      rm /etc/motd
# Make executable:          chmod +x /etc/update-motd.d/20-sysinfo
# Stop executable default:  chmod -x /etc/update-motd.d/10-uname
# Add PrintLastLog:         echo PrintLastLog no >> /etc/ssh/sshd_config

# System uptime
uptime=$(cat /proc/uptime | cut -f1 -d.)
updays=$((uptime/60/60/24))
uphours=$((uptime/60/60%24))
upmins=$((uptime/60%60))

# System + Memory
RELEASE=$(lsb_release -s -d)
KERNEL=$(uname -a | awk '{print $1" "$3" "$12}')
SYS_LOADS=$(cat /proc/loadavg | awk '{print $1}')
CPU_INFO=$(grep -c processor /proc/cpuinfo)
MEMORY_USED=$(free -b | grep Mem | awk '{print $3/$2 * 100.0}')
SWAP_USED=$(free -b | grep Swap | awk '{print $3/$2 * 100.0}')
NUM_PROCS=$(ps aux | wc -l)
IPADDRESS=$(hostname --all-ip-addresses)
DATE=$(date)
USERS_COUNT=$(users | wc -w)

echo "You login to: $(hostname -f)."
echo ""
echo " - IP Address    : $IPADDRESS"
echo " - Release       : $RELEASE"
echo " - Kernel        : $KERNEL"
echo " - Users         : Currently $USERS_COUNT user(s) logged on"
echo " - Server time   : $DATE"
echo " - CPU threads   : $CPU_INFO"
echo " - System load   : $SYS_LOADS / $NUM_PROCS processes running"
echo " - Memory used % : $MEMORY_USED"
echo " - Swap used %   : $SWAP_USED"
echo " - System uptime : $updays days $uphours hours $upmins minutes"
echo ""