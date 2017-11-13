#!/usr/bin/env python
import subprocess
import os
import sys

deluge_file ='deluge.info'
scp_creds_file = '.scp_creds'
dl_base = '/dev/null'
global deluge_info 
deluge_info = []

def main():
  ''' Primary Script of corrolating files and removing known completed files from deluge '''

  # Check for already-active scp session
  try:
    scp_active = check_output('pidof scp'.split(' '))
  except:
    log("SCP is not active")
    scp_active = False

  if scp_active:
    log("SCP is active.  Exiting")
    sys.exit(1)

  name = False
  check_creds()
  global dl_base

  res = os.system('ping -c 1 ' + os.environ['HOST'])
  if res != 0:
    log(os.environ['HOST'] + ' is offline')
    sys.exit(1)

  if os.path.isfile(deluge_file) and os.path.getsize(deluge_file) > 0:
    log('Using provided file: {0}'.format(deluge_file))
    with open(deluge_file,'r') as f:
      deluge_info = f.readlines()
  else:
    log('Checking deluge client for info')
    command = "deluge-console info".split(' ')
    #global deluge_info
    deluge_info = check_output(command).split("\n")
  dl_base = set_download_location()
  if dl_base == '/dev/null':
    log("ERROR: Unable to determine download location")
    sys.exit(1)
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

def find_dynamic_destination(filename):
  scp_creds_file = 'classifier'
  c = os.path.isfile(scp_creds_file) and os.path.getsize(scp_creds_file) > 0
  if not c:
    return
def copy_file(name, id):
  fname = os.path.join(dl_base,name)
  find_dynamic_destination(fname)
  if not (os.path.isfile(fname) or os.path.isdir(fname)):
    log("Not finished: {0}".format(fname))
    return
  command = 'scp -r -P {3} "{0}" {1}@{2}:{4}'.format(fname,os.environ['USR'],os.environ['HOST'],os.environ['PORT'],os.environ['DST'])
  log('Executing: {0}'.format(command))
  os.system(command)
  #subprocess.check_call(command.split(' '),shell=True)
  command = 'deluge-console rm --remove_data {0}'.format(id)
  log('Executing: {0}'.format(command))
  check_call(command.split(' '))
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
      except:
        log("Ignoring configuration item: {0}".format(line))
        continue
  if not 'PORT' in os.environ:
    os.environ['PORT'] = '22'
  if not 'USR' in os.environ:
    u = check_output(['whoami'])
    os.environ['USR'] = u
  if not 'DST' in os.environ:
    os.environ['DST'] = '/'
  log("Using connection string: {0}@{1} and checking ssh and checking ssh ".format(os.environ['USR'],os.environ['HOST']))
  s = "ssh {0}@{1} -p {2} -o ConnectTimeout=10 ls".format(os.environ['USR'],os.environ['HOST'],os.environ['PORT'])
  check_output(s.split(' '))

def check_output(command):
  return subprocess.check_output(command,universal_newlines=True)

def check_call(command):
  subprocess.check_call(command)

def set_download_location():
  if "SRC" in os.environ:
    return os.environ['SRC']
  o = check_output("deluge-console config move_completed move_completed_path download_location".split(' ')).split("\n")
  dl = None
  for line in o:
    if line.strip() == '':
      continue
    line = line.strip().split(': ')
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
  check_call(['logger','-t','overwatch-py',line])

main()

