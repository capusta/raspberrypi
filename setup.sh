#! /bin/bash
set -x
echo 'Starting'

if [ "$EUID" -eq 0 ]; then
  echo 'This must NOT be run as root'
  exit 1
fi
sudo echo apt-get update
sudo echo apt-get install -y openvpn deluged deluge-console \
                        samba samba-common-bin
VPN_CFG=/etc/openvpn/login.conf
if [ -e $VPN_CFG ]; then
  echo 'Openvpn is configured - check username / password'
else
  echo 'Setting up generic login credentials'
  sudo bash -c "echo 'username' > $VPN_CFG"
  sudo bash -c "echo 'secretpass' >> $VPN_CFG"
  sudo sed -i.bak 's/^auth-user-pass.*/auth-user-pass login.conf/g' /etc/openvpn/*.ovpn
fi

### Deluge client configuration
DLG_AUTH=/root/.config/deluge/auth
grep -q "^#setup-complete" $DLG_AUTH
if [ $? -eq 1 ]; then
  sudo pkill deluged
  echo 'Configuring deluge auth'
  echo '#setup-complete' > $DLG_AUTH
  echo 'pi:raspberry:10' >> $DLG_AUTH
else
  echo 'Deluge auth is configured'
fi

sudo pkill deluged
sudo chmod -R 0770 /var/log/deluged
deluged -i 0.0.0.0 -u 0.0.0.0 -l /var/log/deluged/deluge.log
deluge-console "config -s allow_remote True"
