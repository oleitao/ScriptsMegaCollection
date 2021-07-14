#!/usr/bin/env bash

# ssh-tunnel
# Fabio Szostak
# Sun 28 Feb 2021 12:55:20 PM -03
#
# setup: sudo apt install sshuttle

type sshuttle > /dev/null 2>&1
if [ $? -eq 1 ]; then
	echo "Installing sshuttle..."
	sudo apt install sshuttle
	[ $? -ne 0 ] && exit
fi

if [ $# -eq 0 ]; then
	cat <<EOF

usage $(basename $0) [<gateway-host> <remote-host> <remote-port>]

example:

Tunnel up
$(basename $0) my-gateway mydb.remote.host 3306

Tunnel down
$(basename $0) 3306

EOF
	exit
fi

if [ $# -eq 1 ]; then
	R_PORT=$1
fi

GATEWAY_HOST=

if [ $# -eq 3 ]; then
	GATEWAY_HOST=$1
	R_HOST=$(getent hosts $2 | head -1 | awk '{ print $1 }' )
	R_PORT=$3
fi

KILL=$(lsof -i ":$R_PORT" | grep LISTEN | head -1 | awk '{ print $2 }')

if [ "$KILL" != "" ]; then
	kill $KILL
	[ $? -ne 0 ] && echo "SSH Tunnel is down (PID=$KILL)" && exit 
fi

if [ "$GATEWAY_HOST" != "" ]; then
	sshuttle -vv -l $R_PORT -r $GATEWAY_HOST $R_HOST $R_HOST/32
	[ $? -eq 0 ] && echo "SSH Tunnel is stated on locahost:$R_PORT"
fi
