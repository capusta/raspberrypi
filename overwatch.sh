#! /bin/bash

cd "$(dirname "$0")"

. common.sh

# Check to see if OpenVPN and Deluge daemon are running
ps -ef | grep -qi "[o]penvpn --config" && OPENVPN=true
pgrep "deluged" && DELUGE=true

# Profile is chosen randomly by default ... or flip to override
PROFILE='/etc/openvpn/Denmark.ovpn'
PROFILE=$(find /etc/openvpn/*.ovpn | grep -v 'US ' | shuf -n 1)

# First check what is our public IP 
IP=$(curl -m 10 -s ipinfo.io/ip)
STS=$?
if [[ ($STS == 28) || ($STS == 7) ]]; then
  # We have lost connectivity, better start over
  log "Connectivity lost, killing delug and openvpn"
  sudo pkill deluged || true
  sudo pkill openvpn || true
  exit 1
fi

if [[ -z $OPENVPN ]]; then
  OLD_IP=$IP
  log "Current IP: $OLD_IP Starting openvpn to $PROFILE"
  pushd /etc/openvpn > /dev/null
  /usr/sbin/openvpn --config "$PROFILE" >> /var/log/vpn.log 2>&1 &
  STS=$!
  sleep 20
  popd
  log "woke up, looking for pid $STS"
  ps -ef | grep "$STS" && OPENVPN=true
  NEW_IP=$(curl -m 5 -s ipinfo.io/ip)
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
  ps -ef | grep -q "$STS" && DELUGE=true
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
