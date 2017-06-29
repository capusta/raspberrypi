#! /bin/bash
set -e

function prefix(){
  head -n -1 /etc/rc.local > /etc/rc.local.bak
}

function suffix(){
  mv -v /etc/rc.local.bak /etc/rc.local
  echo 'exit 0' >> /etc/rc.local
  return
}

function addVPN(){
  echo 'ps aux | grep -iq [o]penvpn || cd /etc/openvpn && openvpn --config /etc/openvpn/Denmark.ovpn >> /var/log/vpn.log &' >> /etc/rc.local.bak
}

function addDeluge(){
  echo 'ps aux | grep -iq [d]eluge || deluged >> /var/log/deluge &' >> /etc/rc.local.bak
}

prefix
cat /etc/rc.local | grep -i openvpn || addVPN
cat /etc/rc.local | grep -i deluge || addDeluge
suffix
