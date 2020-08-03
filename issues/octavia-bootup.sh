#!/bin/bash

source /etc/kolla/admin-openrc.sh
source /home/$USER/kolla-install/bin/activate

sudo ip link set dev octavia-hm0 address $(openstack port list | grep octavia-hm-port | cut -d '|' -f 4)

sudo ifconfig octavia-hm0 up

sudo docker exec -it openvswitch_vswitchd sudo dhclient octavia-hm0 2>/dev/null
sudo docker exec -it openvswitch_vswitchd sudo ip route del default via 172.16.0.1 dev octavia-hm0 2> /dev/null

echo 'octavia status up'