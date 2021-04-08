#!/bin/bash

# Descryption: sends a signal to all specified processes whose names match the pattern.
#   By default terminates processes owned by the current user only if not started with root privileges.
#   -s SIGNAL - indicate signal. Example: sudo bash killall.sh -s 9 nginx
#   -u USER - indicate user. Example: sudo bash killall.sh -u vagrant ngnix
#   -t TTY - indicate tty. Example: sudo bash killall.sh -t 0 nginx
#   -n NONE - show list of processes. Example: sudo bash killall.sh -n nginx 

signal="-INT"
user=""      tty=""      donothing=0

while getopts "s:u:t:n" opt; do
  case "$opt" in
    s ) signal="-$OPTARG"; ;;
    u ) if [ -n "$tty" ] ; then
          echo "$0: ERROR: -u and -t are mutually exclusive." >&2   # We can't use -u and -t simultaneously
          exit 1
        fi
        user="$OPTARG"; ;;
    t ) if [ -n "$user" ] ; then
          echo "$0: ERROR: -u and -t are mutually exclusive." >&2   # We can't use -u and -t simultaneously
          exit 
        fi
        tty=$2; ;;
    n ) donothing=1; ;;
    ? ) echo "USAGE: $0 [-s signal] [-u user|-t tty] [-n] pattern." >&2
        exit 1
  esac
done

# Finish processing all initial flags
shift $(( $OPTIND - 1 ))

# If we have no arguments in input (return to branch -?)
if [ $# -eq 0 ] ; then
  echo "USAGE: $0 [-s signal] [-u user|-t tty] [-n] pattern." >&2
  exit 1
fi

# Sort list of pid numbers of processes by tty, user, current user
if [ -n "$tty" ] ; then
  pids=$(ps cu -t "$tty" | awk "/ $1$/ { print \$2 }")
elif [ -n "$user" ] ; then
  pids=$(ps cu -U "$user" | awk "/ $1$/ { print \$2 }")
else 
  pids=$(ps cu -U "${USER:-LOGNAME}" | awk "/ $1$/ { print \$2 }")
fi

# Check if we have no match pattern
if [ -z "$pids" ] ; then
  echo "$0: no processes match pattern $1" >&2
  exit 1
fi

# Send signal to processes with pid
for pid in $pids
do
  if [ $donothing -eq 1 ] ; then
    echo "kill $signal $pid"    # Do nothing, just show pid inforamation 
  else
    kill "$signal" "$pid"
  fi
done

exit 0