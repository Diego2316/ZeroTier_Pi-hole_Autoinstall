APIKEY=3LZk8zWEUz4s8sM9KurG0kWlqz3zqFM8
NETWORKID=d5e5fb65374eef97
APIURL="https://api.zerotier.com/api/v1"

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
JSON=`curl -s -H "Authorization: Bearer $APIKEY" $APIURL/network/$NETWORKID/member/$MYID | jq -c --arg name "Pi-hole" '.config.authorized=true | .config.ipAssignments=["10.147.20.100"] | .name=$name'`
curl -s -o /dev/null -H "Authorization: Bearer $APIKEY" -d $JSON $APIURL/network/$NETWORKID/member/$MYID
MYIP=`zerotier-cli get $NETWORKID ip`
echo "User $MYID authorized in $NETWORKID network with ip: $MYIP"
