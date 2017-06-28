#! /bin/bash
set -e

function addVPN(){
  return
}

function addDeluge(){
  return
}

cat /etc/rc.local | grep -i openvpn || addVPN
cat /etc/rc.local | grep -i deluge || addDeluge
