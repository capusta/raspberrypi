#! /bin/bash

. common.sh

# Check to see if OpenVPN and Deluge daemon are running
ps -ef | grep -qi "[o]penvpn --config" && OPENVPN=true
pgrep "deluge" && DELUGE=true

BASE='/etc/openvpn'
PROFILE='Denmark.ovpn'

while [[ $# -ge 1 ]]; do
    ARG=$(echo "$1" | tr '[:upper:]' '[:lower:]')
    echo "$ARG" | grep -q "\-\-"
    STS=$?
    if [[ $STS != "0" ]]; then
        # Malformed argument
        log "Bad argument $ARG (ignoring)"
        shift; continue
    fi
    case $ARG in
        --jp)
            PROFILE=Japan.ovpn
            ;;
        --sw)
            PROFILE=Sweden.ovpn
            ;;
        --ch)
            PROFILE='Switzerland.ovpn'
            ;;
        --rand)
            log "Using --rand option (random vpn tunnel)"
            pushd $BASE > /dev/null
            PROFILE=$(ls *.ovpn | grep -v ' ' | shuf -n 1)
            popd
            ;;
    esac
    shift
done

if [[ -z $OPENVPN ]]; then
  OLD_IP=$(curl -s ipinfo.io/ip)
  log "Current IP: $OLD_IP Starting openvpn to $BASE/$PROFILE"
  pushd $BASE
    /usr/sbin/openvpn --config $BASE/$PROFILE >> /var/log/vpn.log 2>&1 &
    STS=$!
    sleep 10
  popd
  log "woke up, looking for $STS"
  ps -ef | grep "$STS" && OPENVPN=true
  NEW_IP=$(curl -s ipinfo.io/ip)
  log "curl command complete."
  if [[ "$OLD_IP" == "$NEW_IP" ]]; then
    log "ERROR: new IP $NEW_IP is not changing when using VPN, exiting"
    pkill deluged
    pkill openvpn
    exit 1
  else
    log "SUCCESS: IP is set up"
  fi
fi

if [[ -z $DELUGE ]]; then
  su - pi -c 'deluged &'
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
