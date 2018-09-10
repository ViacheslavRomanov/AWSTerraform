sudo yum update -y
sudo yum -y install epel-release
sudo yum -y install yum-utils
sudo yum-config-manager --enable epel
sudo yum -y install openvpn

sudo cd /etc/openvpn
sudo wget -v https://github.com/OpenVPN/easy-rsa/releases/download/v3.0.4/EasyRSA-3.0.4.tgz
sudo tar -xvzf EasyRSA-*.tgz
sudo mkdir easy-rsa

sudo mv EasyRSA-*/ /etc/openvpn/easy-rsa
sudo cd easy-rsa

sudo cp /etc/sysconfig/iptables-config /etc/sysconfig/iptables-config.orig

sudo cat << EOF > /etc/sysconfig/iptables-config
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
sudo iptables -t nat -A POSTROUTING -o eth0 -s 10.8.0.0/24 -j MASQUERADE
sudo service iptables save
sudo service iptables restart



sudo cat  << EOF > /etc/openvpn/easy-rsa/vars
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



