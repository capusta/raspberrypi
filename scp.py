#!/usr/bin/env python

import subprocess
import os

deluge_file ='deluge.info'
scp_creds_file = '.scp_creds'
clean_up = False
deluge_info = {}
deluge_info_raw = {}

def main():
  ''' Primary Script of corrolating files and removing known completed files from deluge '''
  check_call(['whoami'])
  if os.path.isfile(deluge_file) and os.path.getsize(deluge_file) > 0:
    log('Using provided file: {0}'.format(deluge_file))
    with open(deluge_file,'r') as f:
      deluge_info_raw = f.read()
  else:
    log('Checking deluge for info')
  if clean_up:
    os.remove(deluge_file)
    log("Removed {0}".format(deluge_file))


def check_call(command):
  subprocess.check_call(command)

def log(line):
  print('[overwatch-py]: {0}'.format(line))
  check_call(['logger','-t','overwatch',line])

main()
