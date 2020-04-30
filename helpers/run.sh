#!/bin/sh

dest=${dest:-docker.ovpn}

if [ ! -f "/local/$dest" ]; then
    set -ex
    ovpn_genconfig -u tcp://localhost
    sed -i 's|^push|#push|' /etc/openvpn/openvpn.conf
    echo localhost | ovpn_initpki nopass
    easyrsa build-client-full host nopass
    ovpn_getclient host | sed '
    	s|localhost 1194|localhost 13194|;
	s|redirect-gateway.*|route 172.24.0.0 255.255.0.0|;
    ' > "/local/$dest"
fi

/sbin/iptables -I FORWARD 1 -i tun+ -j ACCEPT

exec ovpn_run
