#! /bin/bash

echo 'Starting'

if [ "$EUID" -ne 0 ]; then
  echo 'This must be run as root'
  exit 1
fi
echo apt-get update
echo apt-get install -y openvpn deluged deluge-console \
                        samba samba-common-bin

VPN_CFG=/etc/openvpn/login.conf

if [ -e $VPN_CFG ]; then
  echo 'Openvpn is configured - check username / password'
else
  echo 'Setting up generic login credentials'
  echo 'username' > $VPN_CFG
  echo 'secretpass' >> $VPN_CFG
fi
