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
  echo '/usr/sbin/openvpn --config Denmark.ovpn' >> /etc/rc.local.bak
}

function addDeluge(){
  echo 'TODO'
}

prefix
cat /etc/rc.local | grep -i openvpn || addVPN
cat /etc/rc.local | grep -i deluge || addDeluge
suffix
