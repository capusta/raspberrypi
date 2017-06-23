#! /bin/bash

echo 'Starting'

if [ "$EUID" -ne 0 ]; then
  echo 'This must be run as root'
  exit 1
fi
echo apt-get update
