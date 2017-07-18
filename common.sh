#! /bin/bash

# Common functions for logging
function log(){
  echo "$1"
  logger -t overwatch "$1"
}
