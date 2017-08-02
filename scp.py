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

  deluge_info_raw = ""
  if os.path.isfile(deluge_file) and os.path.getsize(deluge_file) > 0:
    log('Using provided file: {0}'.format(deluge_file))
    with open(deluge_file,'r') as f:
      deluge_info_raw = f.readlines()
  else:
    log('Checking deluge client for info')
    arg = ('deluge-console info').split(' ')
    deluge_info_raw = check_output(arg)
  log('Found {0} lines ... parsing'.format(len(deluge_info_raw)))

  ## Main Loop
  name = False
  for line in deluge_info_raw:
    if line.strip() == '':
      continue
    if 'Name: ' in line:
      name = line.strip().split(': ')[1]
      continue
    if name and 'ID: ' in line:
      id = line.split(': ')[1]
      deluge_info[name] = id
      name = False
      continue

  if clean_up:
    os.remove(deluge_file)
    log("Removed {0}".format(deluge_file))

def check_output(command):
  return subprocess.check_output(command,universal_newlines=True)

def check_call(command):
  subprocess.check_call(command)

def log(line):
  if isinstance(line, list):
    line = " ".join(line)
  print('[overwatch-py]: {0}'.format(line))
  check_call(['logger','-t','overwatch',line])

main()
