# Configure Octavia Loadbalancer Basic HTTP

## Configuration Step

### Instance
previously there were 2 instances running nginx services on private-net

```
openstack server list

+--------------------------------------+---------+--------+-----------------------------+------------------------------+--------+
| ID                                   | Name    | Status | Networks                    | Image                        | Flavor |
+--------------------------------------+---------+--------+-----------------------------+------------------------------+--------+
| b122eafc-69eb-43ef-9391-9d5c28491b58 | ubuntu1 | ACTIVE | private-net=192.168.100.167 | bionic-server-cloudimg-amd64 | small  |
| ca385bc8-646c-42d0-b96b-038996ac068e | ubuntu0 | ACTIVE | private-net=192.168.100.81  | bionic-server-cloudimg-amd64 | small  |
+--------------------------------------+---------+--------+-----------------------------+------------------------------+--------+
```

## Create LoadBalancer

### source user openrc file
```
source ~/kolla-install/bin/activate
source /etc/kolla/admin-openrc.sh
```

### Create Loadbalancer
```
LB_VIP=$(openstack loadbalancer create --name lb1 --vip-subnet-id private-subnet | awk  '/ vip_address / {print $4}')
```

### Create floating ip 
```
openstack floating ip create --floating-ip-address 10.20.110.50 public-net
```

### Associate floating ip to lb vip
```
openstack floating ip set --port $(openstack port list | grep $LB_VIP | cut -d '|' -f 3) 10.20.110.50
```

### Create http lisneter
```
openstack loadbalancer listener create --name listener1 --protocol HTTP --protocol-port 80 lb1
```

### Create pool
```
openstack loadbalancer pool create --name pool1 --lb-algorithm ROUND_ROBIN --listener listener1 --protocol HTTP
```

### Create health monitor
```
openstack loadbalancer healthmonitor create --delay 5 --max-retries 4 --timeout 10 --type HTTP --url-path /healthcheck pool1
```
### Add Instance become pool member
```
openstack loadbalancer member create --subnet-id private-subnet --address 192.168.100.167 --protocol-port 80 pool1
openstack loadbalancer member create --subnet-id private-subnet --address 192.168.100.81 --protocol-port 80 pool1
```