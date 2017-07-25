#! /bin/bash

. common.sh

# Check to see if OpenVPN and Deluge daemon are running
ps -ef | grep -qi "[o]penvpn --config" && OPENVPN=true
pgrep "deluge" && DELUGE=true

PROFILE='/etc/openvpn/Denmark.ovpn'

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
            PROFILE=$(find /etc/openvpn/*.ovpn | grep -v ' ' | shuf -n 1)
            ;;
    esac
    shift
done

if [[ -z $OPENVPN ]]; then
  OLD_IP=$(curl -s ipinfo.io/ip)
  log "Current IP: $OLD_IP Starting openvpn to $PROFILE"
  pushd /etc/openvpn > /dev/null
  /usr/sbin/openvpn --config $PROFILE >> /var/log/vpn.log 2>&1 &
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

# Keep checking dummy torrent file to ensure our IP is correct
DLG_TCH=/tmp/deluge_torrent_check
set -e
if [[ ! -e $DLG_TCH ]]; then
    log 'Configuring deluge to track public torrent IP'
    MAGNET=$(curl -L ipmagnet.services.cbcdn.com -v | grep -o "magnet.*>M" | \
        head -c-4 | sed 's@+@ @g;s@%@\\x@g' | xargs -0 printf "%b" | \
        sed 's/ /\+/g' | sed 's/\;/\&/g')
    log "Using magnet Link: $MAGNET"
    su - pi -c "deluge-console add $MAGNET" && touch $DLG_TCH
else
    log "$DLG_TCH exists ... deluge is configred?"
fi
set +e

log 'Overwatch complete'
exit 0
