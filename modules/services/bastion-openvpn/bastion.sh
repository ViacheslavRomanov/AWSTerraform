#!/bin/bash
sudo yum update -y
sudo yum -y install epel-release
sudo yum -y install yum-utils
sudo yum-config-manager --enable epel
sudo yum -y install openvpn 

cd /etc/openvpn
sudo wget -v https://github.com/OpenVPN/easy-rsa/releases/download/v3.0.4/EasyRSA-3.0.4.tgz
sudo tar -xvzf EasyRSA-*.tgz
sudo mkdir easy-rsa

sudo mv -v EasyRSA-*/* easy-rsa/
sudo rm -rf EasyRSA-*
cd easy-rsa

sudo cp /etc/sysconfig/iptables-config /etc/sysconfig/iptables-config.orig

sudo cat << EOF | sudo tee /etc/sysconfig/iptables-config
IPTABLES_MODULES=""
IPTABLES_MODULES_UNLOAD="yes"
IPTABLES_SAVE_ON_STOP="yes"
IPTABLES_SAVE_ON_RESTART="yes"
IPTABLES_SAVE_COUNTER="no"
IPTABLES_STATUS_NUMERIC="yes"
IPTABLES_STATUS_VERBOSE="yes"
IPTABLES_STATUS_LINENUMBERS="yes"

EOF

sudo touch /etc/sysconfig/iptables
sudo chkconfig iptables on
sudo service iptables start
sudo modprobe iptable_nat
sudo echo 1 | tee /proc/sys/net/ipv4/ip_forward
sudo iptables -t nat -A POSTROUTING -o eth0 -s 172.16.10.0/24 -j MASQUERADE
sudo service iptables save
sudo service iptables restart


sudo mkdir keys
sudo cat  << EOF | sudo tee /etc/openvpn/easy-rsa/vars
set_var EASYRSA_PKI             "$PWD/keys"
set_var EASYRSA_DN      "cn_only"
set_var EASYRSA_REQ_COUNTRY     "NN"
set_var EASYRSA_REQ_PROVINCE    "NewHorizon"
set_var EASYRSA_REQ_CITY        "DeepTown"
set_var EASYRSA_REQ_ORG "Copyleft Certificate Co"
set_var EASYRSA_REQ_EMAIL       "me@example.net"
set_var EASYRSA_REQ_OU          "My Unit"
set_var EASYRSA_KEY_SIZE        2048
set_var EASYRSA_ALGO            rsa
set_var EASYRSA_CURVE           secp384r1
set_var EASYRSA_CA_EXPIRE       3650
set_var EASYRSA_CERT_EXPIRE     3650
set_var EASYRSA_CRL_DAYS        180

EOF

sudo ./easyrsa --batch init-pki
sudo ./easyrsa --batch build-ca nopass
sudo ./easyrsa --batch gen-crl
sudo ./easyrsa --batch gen-dh
sudo ./easyrsa --batch gen-req bastion nopass
sudo ./easyrsa --batch sign-req server bastion



sudo mkdir -p /etc/openvpn/keys
sudo cp -r keys/. /etc/openvpn/keys/
sudo openvpn --genkey --secret /etc/openvpn/keys/ta.key

sudo mkdir -p /var/log/openvpn



sudo cat << EOF | sudo tee /etc/openvpn/server.conf

port 1194
proto udp
dev tun
ca keys/ca.crt
cert keys/issued/bastion.crt
key keys/private/bastion.key
dh keys/dh.pem
tls-auth keys/ta.key 0
server 172.16.10.0 255.255.255.0
ifconfig-pool-persist ipp.txt
keepalive 10 120
max-clients 32
client-to-client
persist-key
persist-tun
status /var/log/openvpn/openvpn-status.log
log-append /var/log/openvpn/openvpn.log
verb 4
mute 20
daemon
mode server
tls-server
comp-lzo

EOF

sudo echo "iptables_nat" | sudo tee /etc/modules
sudo sed -i 's/net.ipv4.ip_forward = 0/net.ipv4.ip_forward = 1/g' /etc/sysctl.conf
sudo chkconfig openvpn on
sudo service openvpn restart


sudo echo "unique_subject = no" | sudo tee /etc/openvpn/easy-rsa/keys/index.txt.attr

sudo ./easyrsa --batch gen-req bastion-user nopass
sudo ./easyrsa --batch sign-req client bastion-user

sudo mkdir userset

public_ip=`curl http://169.254.169.254/latest/meta-data/public-ipv4`
metadata="http://169.254.169.254/latest/meta-data"
mac=$(curl -s $metadata/network/interfaces/macs/ | head -n1 | tr -d '/')
cidr=$(curl -s $metadata/network/interfaces/macs/$mac/vpc-ipv4-cidr-block/)
net=`echo $cidr | awk -F '/' '{print($1)}'`
prefix=`echo $cidr | awk -F '/' '{print($2)}'`

cidr_to_netmask() {
    value=$(( 0xffffffff ^ ((1 << (32 - $2)) - 1) ))
    echo "$(( (value >> 24) & 0xff )).$(( (value >> 16) & 0xff )).$(( (value >> 8) & 0xff )).$(( value & 0xff ))"
}

netmask=`cidr_to_netmask 0.0.0.0 $prefix`

sudo cat << EOF | sudo tee /etc/openvpn/easy-rsa/userset/config
client
resolv-retry infinite
nobind
remote $public_ip 1194
proto udp
dev tun
comp-lzo
ca ca.crt
cert bastion-user.crt
key bastion-user.key
dh dh.pem
tls-client
tls-auth ta.key 1
float
route $net $netmask
keepalive 10 120
persist-key
persist-tun
verb 0


EOF

sudo cp keys/ca.crt userset/
sudo cp keys/issued/bastion-user.crt userset/
sudo cp keys/private/bastion-user.key userset/
sudo cp keys/dh.pem userset/
sudo cp ../keys/ta.key userset/

sudo tar cvfz user_settings.tar.gz userset/



