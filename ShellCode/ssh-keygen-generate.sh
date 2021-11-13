#!/usr/bin/env bash

if [ "$1" == "-h" -o $# -ne 3 ]; then
  echo "usage: $(basename $0) <key_name> <user> <hostname>"
  exit
fi

KEY_NAME=$1 
USER=$2 
HOSTNAME=$3 

[ ! -d ~/.ssh ] && mkdir ~/.ssh

if [ -f ~/.ssh/$KEY_NAME.pem ]; then
  echo "This key already exists"
  exit
fi

cd ~/.ssh
[ $? -ne 0 ] && exit

ssh-keygen -t rsa -f $KEY_NAME -P "" -C "$USER"
[ $? -ne 0 ] && exit

mv $KEY_NAME $KEY_NAME.pem
[ $? -ne 0 ] && exit

chmod 600 $KEY_NAME.pem
[ $? -ne 0 ] && exit

#cat ~/.ssh/$KEY_NAME.pub | \
  #ssh $USER@$HOSTNAME "mkdir -p ~/.ssh && chmod 700 ~/.ssh && \
  #cat >>  ~/.ssh/authorized_keys"
#[ $? -ne 0 ] && exit

echo "Private key: ~/.ssh/$KEY_NAME.pem"
echo "Public key:  ~/.ssh/$KEY_NAME.pub"
echo
echo "Done."

#@@@ end of script
