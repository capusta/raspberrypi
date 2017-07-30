#!/usr/bin/env python

import subprocess
import os
import pathlib

def main():
  ''' Primary Script of corrolating files and removing known completed files from deluge '''
  log("Starting scp")
  check_call(['whoami'])

def check_call(command):
  subprocess.check_call(command)

def log(line):
  print('[overwatch-py]: {0}'.format(line))

main()
