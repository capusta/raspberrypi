#! /bin/bash
set -e

## Keep a backup for the rc.local
RC_BACKUP=/etc/rc.local.bak.$(date "+%Y%m%d.%M")

function prefix(){
    head -n -1 /etc/rc.local > "$RC_BACKUP"
}

function suffix(){
  cp -v "$RC_BACKUP" /etc/rc.local
  echo 'exit 0' >> /etc/rc.local
  return
}

function addOverwatch(){
    echo "/bin/bash $(pwd)/overwatch.sh --rand &" >> "$RC_BACKUP"
}

prefix
cat < /etc/rc.local | grep -i overwatch || addOverwatch
suffix
