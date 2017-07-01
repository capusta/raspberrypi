#! /bin/bash

### Let's keep track on deluge and openvpn, and make sure one
### Does not run without the other

ps -ef | grep -qi "[o]penvpn --config" && OPENVPN=true
ps -ef | grep -qi "[d]eluged" && DELUGE=true

if [[ -z $OPENVPN ]]; then
  CUR_IP=$(curl ipinfo.io/ip)
  echo "Current IP is $CUR_IP ... starting openvpn"
  #TODO: do some ip comparison here to make sure we got it
fi

if [[ -z $DELUGE ]]; then
  deluged &
  STS=$!
  sleep 3
  ps -ef | grep "$STS" && DELUGE=true
fi


if [[ -z $DELUGE || -z $OPENVPN ]]; then
  echo 'Nothing is running ... exiting'
  exit 1
fi
echo 'All is good'
exit 0

kill deluge (openvpn is bad)
check ip
start openvpn 
  give some time

if (openvpn is good)
   if currentip == previous ip
         log error, exit
   else
      start deluged

confirm openvpn and deluged is running
   if not -> log error
   exit
    
      
