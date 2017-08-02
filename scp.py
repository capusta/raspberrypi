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
  check_creds()
  check_call(['whoami'])

  if clean_up:
    os.remove(deluge_file)
    log("Removed {0}".format(deluge_file))

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

def check_creds():
  c = os.path.isfile(scp_creds_file) and os.path.getsize(scp_creds_file) > 0
  if not c:
    raise IOError("ERROR: missing credentials file {0}".format(scp_creds_file))
  with open(scp_creds_file,'r') as f:
    for line in f:
      try:
        line = line.strip().split('=')
        k = line[0]
        v = line[1]
        os.environ[k] = v
        log("Setting {0} = {1}".format(k,os.environ[k]))
      except:
        log("Ignoring configuration item: {0}".format(line))
        continue

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
