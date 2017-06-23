#! /bin/bash

echo 'Starting'

if [ "$EUID" -ne 0 ]; then
  echo 'This must be run as root'
  exit 1
fi
echo apt-get update
echo apt-get install -y openvpn deluged deluge-console \
                        samba samba-common-bin
deluged &

VPN_CFG=/etc/openvpn/login.conf
if [ -e $VPN_CFG ]; then
  echo 'Openvpn is configured - check username / password'
else
  echo 'Setting up generic login credentials'
  echo 'username' > $VPN_CFG
  echo 'secretpass' >> $VPN_CFG
  # TODO: insert login.conf stanza in all config files
fi

deluge-console config set allow_remote True
### Deluge client configuration
DLG_AUTH=/home/pi/.config/deluge/auth
grep -q "^#setup-complete" $DLG_AUTH
if [ $? -eq 1 ]; then
  pkill deluged
  echo 'Configuring deluge auth'
  echo '#setup-complete' > $DLG_AUTH
  echo 'pi:raspberry:10' >> $DLG_AUTH
  deluged
else
  echo 'Deluge auth is configured'
fi
