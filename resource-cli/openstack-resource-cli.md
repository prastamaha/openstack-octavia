# Create Openstack Resource Using Cli

## Network

### Create External (Provider) Network

Source to adminrc
```
source ~/kolla-install/bin/activate
source /etc/kolla/admin-openrc.sh
```

Create External Network type flat
```
openstack network create  --share --external \
  --provider-physical-network physnet1 \
  --provider-network-type flat public-net
```

```
PROVIDER_START_IP_ADDRESS=10.20.110.10
PROVIDER_END_IP_ADDRESS=10.20.110.254
PROVIDER_NETWORK_GATEWAY=10.20.110.1
DNS_RESOLVER=8.8.8.8
PROVIDER_NETWORK_CIDR=10.20.110.0/24

openstack subnet create --network public-net \
  --allocation-pool start=$PROVIDER_START_IP_ADDRESS,end=$PROVIDER_END_IP_ADDRESS \
  --dns-nameserver $DNS_RESOLVER --gateway $PROVIDER_NETWORK_GATEWAY \
  --subnet-range $PROVIDER_NETWORK_CIDR public-subnet
```

### Create Self-service or private network

Source to adminrc or tenant rc (if exists)
```
source ~/kolla-install/bin/activate
source /etc/kolla/admin-openrc.sh
```

Create private Network
```
openstack network create private-net
```

Create private Subnet
```
PRIVATE_NETWORK_CIDR=192.168.100.0/24
PRIVATE_START_IP_ADDRESS=192.168.100.10
PRIVATE_END_IP_ADDRESS=192.168.100.254
PRIVATE_NETWORK_GATEWAY=192.168.100.1
DNS_RESOLVER=8.8.8.8

openstack subnet create --network private-net \
  --allocation-pool start=$PRIVATE_START_IP_ADDRESS,end=$PRIVATE_END_IP_ADDRESS \
  --dns-nameserver $DNS_RESOLVER --gateway $PRIVATE_NETWORK_GATEWAY \
  --subnet-range $PRIVATE_NETWORK_CIDR private-subnet
```
## Router

### Create Router

```
openstack router create myrouter
openstack router set --external-gateway public-net myrouter
```

```
openstack router add subnet myrouter private-subnet
```

## Image

### Create Public Image

Download Image
```
# Cirros
wget http://download.cirros-cloud.net/0.5.1/cirros-0.5.1-x86_64-disk.img

# Ubuntu bionid
wget https://cloud-images.ubuntu.com/bionic/current/bionic-server-cloudimg-amd64.img
```

```
# Cirros
openstack image create --disk-format qcow2 --container-format bare \
  --public --file ./cirros-0.5.1-x86_64-disk.img cirros-0.5.1-x86_64-disk

# Ubuntu
openstack image create --disk-format qcow2 --container-format bare \
  --public --file ./bionic-server-cloudimg-amd64.img bionic-server-cloudimg-amd64
```

## Flavor

### Create Flavor

```
openstack flavor create --ram 512 --disk 5 --vcpus 1 --public small
```

## Security Group

### Create Security Group Allow All ingress traffic

```
openstack security group create allow-all-traffic --description 'Allow All Ingress Traffic'
openstack security group rule create --protocol icmp allow-all-traffic
openstack security group rule create --protocol tcp  allow-all-traffic
openstack security group rule create --protocol udp  allow-all-traffic
```

## Key Pair

### Using Controller Node ssh public-key

openstack keypair create --public-key ~/.ssh/id_rsa.pub controller-key

## Instance

### Cirros Instance

```
openstack server create --flavor small \
  --image cirros-0.5.1-x86_64-disk \
  --key-name controller-key \
  --security-group allow-all-traffic \
  --network private-net \
  cirros0
```

### Ubuntu Instance

```
openstack server create --flavor small \
  --image bionic-server-cloudimg-amd64 \
  --key-name controller-key \
  --security-group allow-all-traffic \
  --network private-net \
  ubuntu0
```