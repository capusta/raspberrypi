#! /bin/bash

### This should be run as root
### Let's keep track on deluge and openvpn, and make sure one
### Does not run without the other

#TODO: abiliity to  change the VPN location based on a flag

function log(){
  echo "$1"
  logger -t overwatch "$1"
}

if [ "$EUID" -ne 0 ]; then
  log 'This must NOT be run as root'
  exit 1
fi

ps -ef | grep -qi "[o]penvpn --config" && OPENVPN=true
pgrep "deluge" && DELUGE=true

if [[ -z $OPENVPN ]]; then
  OLD_IP=$(curl -s ipinfo.io/ip)
  log "Current IP is $OLD_IP ... starting openvpn"
  pushd /etc/openvpn > /dev/null
    openvpn --config /etc/openvpn/Denmark.ovpn &
    STS=$!
    sleep 6
    ps -ef | grep "$STS" && OPENVPN=true
  popd
  NEW_IP=$(curl -s ipinfo.io/ip)
  if [[ "$OLD_IP" == "$NEW_IP" ]]; then
    log "ERROR: IP is not changing when using VPN, exiting"
    exit 1
  else
    log "SUCCESS: IP is set up"
  fi
fi

if [[ -z $DELUGE ]]; then
  deluged &
  STS=$!
  sleep 3
  ps -ef | grep "$STS" && DELUGE=true
  log "Started Deluge"
fi


if [[ -z $DELUGE || -z $OPENVPN ]]; then
  log 'Error: deluge or Openvpn not running, killing both and exiting'
  sudo pkill deluged || true
  sudo pkill openvpn || true
  exit 1
fi
log 'Overwatch complete'
exit 0
