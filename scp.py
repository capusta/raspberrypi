#!/usr/bin/env python

import subprocess
import os

deluge_file ='deluge.info'
scp_creds_file = '.scp_creds'
dl_base = '/dev/null'
deluge_info = {}

def main():
  ''' Primary Script of corrolating files and removing known completed files from deluge '''
  name = False
  check_creds()

  if os.path.isfile(deluge_file) and os.path.getsize(deluge_file) > 0:
    log('Using provided file: {0}'.format(deluge_file))
    with open(deluge_file,'r') as f:
      deluge_info = f.readlines()
  else:
    log('Checking deluge client for info')
    arg = ('deluge-console info').split(' ')
    deluge_info = check_output(arg)
  global dl_base
  dl_base = set_download_location()
  if dl_base == '/dev/null':
    log("ERROR: Unable to determine download location")
    os.exit(1)
  log('Download location set to {0}'.format(dl_base))

  for line in deluge_info:
    if line.strip() == '':
      continue
    if 'Name: ' in line:
      name = line.strip().split(': ')[1]
      continue
    if name and 'ID: ' in line:
      copy_file(name, line.split(': ')[1])
      name = False
      continue

def copy_file(name, id):
  fname = os.path.join(dl_base,name)
  if not os.path.isfile(fname):
    log("Not finished: {0}".format(fname))
    return

  return

### Ingest and parse credentials file.  Format "key=value" ... no quotes
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

def set_download_location():
  if "DL_SRC" in os.environ:
    return os.environ['DL_SRC']
  o = check_output("deluge-console config move_completed move_completed_path download_location".split(' ')).split("\n")
  dl = None
  for line in o:
    line = line.strip().split(': ')
    if line.strip() == '':
      continue
    if 'download_location' in line[0]:
      dl = line[1] 
      continue
    if 'move_completed' in line[0] and 'False' in line[1]:
        log('Found download location {0}'.format(line[1]))
        break
  return dl

def log(line):
  if isinstance(line, list):
    line = " ".join(line)
  print('[overwatch-py]: {0}'.format(line))
  check_call(['logger','-t','overwatch',line])

main()
