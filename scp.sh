#! /bin/bash
echo 'SCP File Management ... will scp files from source folder, then remove entry from deluge'
set -e
. common.sh
test -e .scp_creds || exit 1

# Important to have file '.scp_creds' in exportable format
for i in `cat .scp_creds | grep -vi "^#"`; do export $i; done
[ -z "$USR" ]  && log "Warning, User not set.  Defaulting to $USER" && export USR=$USER
[ -z "$PORT" ] && log "Warning, Port not set.  Defaulting to 22" && export PORT=22

if [[ -z "${SRC}" || -z "${HOST}" ]]; then
  log "SRC folder or HOST host not set "
  exit 1
fi

ssh -p $PORT $USR@$HOST whoami && log "ssh is ok"
touch $SRC/test && rm $SRC/test && log "Read/Write OK on source"
touch $SRC/test && scp -P $PORT $SRC/test $USR@$HOST:$DEST && log "SCP working ok"

test -e localcopy || deluge-console info > localcopy > /dev/null
