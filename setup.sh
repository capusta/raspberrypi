#! /bin/bash
set -x

sudo echo apt-get update
sudo echo apt-get install -y openvpn deluged deluge-console \
                        samba samba-common-bin

### SSH Configuration
SSH_CFG=/etc/ssh/sshd_config
# Apparently this is how you enable ssh on pixel
test -e /boot/ssh || touch /boot/ssh

# Do not do root login, and enforce ssh keys
sed -i.bak1 's/^PermitRootLogin.*/PermitRootLogin no/g' $SSH_FN
sed -i.bak2 's/^#PasswordAuthentication.*/PasswordAuthentication no/g' $SSH_FN

VPN_CFG=/etc/openvpn/login.conf
if [ -e $VPN_CFG ]; then
  echo 'Openvpn is configured - check username / password'
else
  echo 'Setting up generic login credentials'
  sudo bash -c "echo 'username' > $VPN_CFG"
  sudo bash -c "echo 'secretpass' >> $VPN_CFG"
  sudo sed -i.bak 's/^auth-user-pass.*/auth-user-pass \/etc\/openvpn\/login.conf/g' /etc/openvpn/*.ovpn
fi

### Deluge client configuration
DLG_AUTH=/home/pi/.config/deluge/auth
grep -q "^#setup-complete" $DLG_AUTH
if [ $? -eq 1 ]; then
  sudo pkill deluged
  echo 'Configuring deluge auth'
  sudo bash -c "echo '#setup-complete' > $DLG_AUTH"
  sudo bash -c "echo 'pi:raspberry:10' >> $DLG_AUTH"
else
  echo 'Deluge auth is configured'
fi

sudo pkill deluged
sudo chmod -R 0770 /var/log/deluged
deluged -i 0.0.0.0 -u 0.0.0.0 -l /var/log/deluged/deluge.log
deluge-console "config -s allow_remote True"
deluge-console plugin --enable YaRSS2

sudo bash -c 'echo "*/2 * * * * root /bin/bash $(pwd)/overwatch.sh" > /etc/cron.d/overwatch'
sudo chown root: /etc/cron.d/overwatch
sudo bash setup_02_bootup.sh
