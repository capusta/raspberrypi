#! /bin/bash

### Let's keep track on deluge and openvpn, and make sure one
### Does not run without the other

if (openvpn is good)
  check deluge.
  if (deluge is good)
      exit

kill deluge (openvpn is bad)
check ip
start openvpn 
  give some time

if (openvpn is good)
   if currentip == previous ip
         log error, exit
   else
      start deluged

confirm openvpn and deluged is running
   if not -> log error
   exit
    
      
