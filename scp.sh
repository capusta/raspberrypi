#! /bin/bash
echo 'SCP File Management ... will scp your files somewhere, then remove entry from deluge'
set -e
. common.sh

test -e .scp_creds || exit 1
for i in `cat .scp_creds`; do export $i; done

if [[ -z "${SRC}" ]]; then
  log "Source location not set"
  exit 1
else
  log "Source location set: $SRC"
fi
touch $SRC/test && rm $SRC/test
log "Read/Write OK"

if [[ -z "${PORT}" ]]; then
  export PORT=22
fi

if [[ -z "${USR}" || -z "${DST}" ]]; then
  log "Error - USR or DST not set"
  exit 1
fi 

ssh -p $PORT $USR@$DST whoami && log "ssh is ok"
