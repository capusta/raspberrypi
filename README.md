#### Raspberrypi Utility Server
Runs both Openvpn and deluged server.  Ensures that it is always
connected via VPN.  This is a fun project for all those having a spare
Pi lying around.

###### Configuration
``` bash
apt-get update &&
apt-get install -y git &&
git clone https://github.com/capusta/raspberrypi.git &&
cd raspberrypi &&
bash setup.sh"
```

Manual Steps
1.  Modify username and password in `/etc/openvpn/login.conf`
2.  Modify the tunnel of your choice in `overwatch.sh`
