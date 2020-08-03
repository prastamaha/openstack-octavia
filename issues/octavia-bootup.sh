#!/bin/bash

source /etc/kolla/octavia-openrc.sh
source /home/$USER/kolla-install/bin/activate

sudo ifconfig octavia-hm0 up

MAC=$(openstack port list | grep octavia-hm-port | cut -d '|' -f 4)
sudo ip link set dev octavia-hm0 address $MAC

sudo docker exec -it openvswitch_vswitchd sudo dhclient octavia-hm0 2>/dev/null
sudo docker exec -it openvswitch_vswitchd sudo ip route del default via 172.16.0.1 dev octavia-hm0 2> /dev/null

MAC=$(openstack port list | grep octavia-hm-port | cut -d '|' -f 4)
sudo ip link set dev octavia-hm0 address $MAC

echo 'octavia status up'