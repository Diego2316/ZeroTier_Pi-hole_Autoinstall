echo "Updating repositories"
apt update
echo "Installing dependecies"
apt upgrade -y
apt install gpg
apt install nano
echo "Installing ZeroTier"
curl -s https://install.zerotier.com | sudo bash
echo "Enabling autostart for ZeroTier"
mkdir /etc/s6-overlay/s6-rc.d/zerotier-one
echo "oneshot" > /etc/s6-overlay/s6-rc.d/zerotier-one/type
echo "/usr/sbin/zerotier-one -d" > /etc/s6-overlay/s6-rc.d/zerotier-one/up
touch /etc/s6-overlay/s6-rc.d/user/contents.d/zerotier-one
