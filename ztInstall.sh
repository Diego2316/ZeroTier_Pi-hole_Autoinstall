#!/bin/bash
#
APIKEY=
NETWORKID=
APIURL="https://api.zerotier.com/api/v1"
#
args=()
while (($# > 0)); do
   arg="$1"
   arg_key="${arg%%=*}"
   arg_data="${arg#*=}"
   case $arg_key in
      -a) APIKEY=${arg_data};;
      -n) NETWORKID=${arg_data};;
   esac
   shift
done
#
echo "Updating repositories"
apt update
echo "Installing dependecies"
apt upgrade -y
apt install -y gpg
apt install -y nano
echo "Installing ZeroTier"
curl -s https://install.zerotier.com | sudo bash
echo "Enabling autostart for ZeroTier"
mkdir /etc/s6-overlay/s6-rc.d/zerotier-one
echo "oneshot" > /etc/s6-overlay/s6-rc.d/zerotier-one/type
echo "/usr/sbin/zerotier-one -d" > /etc/s6-overlay/s6-rc.d/zerotier-one/up
touch /etc/s6-overlay/s6-rc.d/user/contents.d/zerotier-one
echo "Joining $NETWORKID network"
zerotier-cli join $NETWORKID
echo "Joined network, unauthorized"
MYID=$(zerotier-cli info | cut -d " " -f 3)
curl -s -H 'Content-Type: application/json' -H "Authorization: token $APIKEY" "$APIURL/network/$NETWORKID/member/$MYID" -d '{"name": "Pi-hole", "config": {"authorized":true, "ipAssignments": ["10.147.20.100"]}}'
echo -ne '\n'
echo -ne "waiting for network auth to register"
while [ -z "$(zerotier-cli listnetworks | grep $NETWORKID | grep OK)" ]; do echo -ne ".";sleep 1 ; done
echo -ne '\n'
MYIP=`zerotier-cli get $NETWORKID ip`
echo "User $MYID authorized in $NETWORKID network with ip: $MYIP"