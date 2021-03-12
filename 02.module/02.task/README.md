### ssh vagrant@node-1 "cat /tmp/devops-training/02.module/02.module.txt" >> README.md
```
THIS IS TEXT FOR TEST FROM VAGRANT!!
```
### Log node-1
```
==> node-1: Running provisioner: shell...
    node-1: Running: /tmp/vagrant-shell20210311-19543-194qfsq.sh
    node-1: >>>>> Test SSH Forwarding <<<<<
    node-1: /tmp/ssh-zwggw9h5us/agent.575
    node-1: >>>>> Test GitHub Answer <<<<<
    node-1: HTTP/2 200 
    node-1: >>>>> Test GitHub Connection <<<<<
    node-1: Warning: Permanently added 'github.com,140.82.114.4' (RSA) to the list of known hosts.
    node-1: Hi zuwarskej! You've successfully authenticated, but GitHub does not provide shell access.
    node-1: >>>>> Clone GitHub Repository <<<<<
    node-1: Cloning into 'devops-training'...
    node-1: Warning: Permanently added the RSA host key for IP address '140.82.112.4' to the list of known hosts.
    node-1: THIS IS TEXT FOR TEST FROM VAGRANT!!
```
### ssh vagrant@node-2 "cat /tmp/devops-training/02.module/02.module.txt" >> README.md
```
THIS IS TEXT FOR TEST FROM VAGRANT!!
```
### Log node-2
```
==> node-2: Running provisioner: shell...
    node-2: Running: /tmp/vagrant-shell20210311-19543-zzqo87.sh
    node-2: >>>>> Test SSH Forwarding <<<<<
    node-2: /tmp/ssh-WtoTzq5wWK/agent.577
    node-2: >>>>> Test GitHub Answer <<<<<
    node-2: HTTP/2 200 
    node-2: >>>>> Test GitHub Connection <<<<<
    node-2: Warning: Permanently added 'github.com,140.82.113.4' (RSA) to the list of known hosts.
    node-2: Hi zuwarskej! You've successfully authenticated, but GitHub does not provide shell access.
    node-2: >>>>> Clone GitHub Repository <<<<<
    node-2: Cloning into 'devops-training'...
    node-2: Warning: Permanently added the RSA host key for IP address '140.82.112.4' to the list of known hosts.
    node-2: THIS IS TEXT FOR TEST FROM VAGRANT!!
```
---
### Install plugin hostmanager to automate resolving hostnames for host and guests VMs
```
vagrant plugin install vagrant-hostmanager
```
### Ping node-1
```
16:25:45 zuwarskej ~/project_devops/devops-training/02.module/02.task (module2) $ ping -c4 node-1
PING node-1 (172.16.10.2) 56(84) bytes of data.
64 bytes from node-1 (172.16.10.2): icmp_seq=1 ttl=64 time=0.486 ms
64 bytes from node-1 (172.16.10.2): icmp_seq=2 ttl=64 time=0.521 ms
64 bytes from node-1 (172.16.10.2): icmp_seq=3 ttl=64 time=0.459 ms
64 bytes from node-1 (172.16.10.2): icmp_seq=4 ttl=64 time=0.538 ms

--- node-1 ping statistics ---
4 packets transmitted, 4 received, 0% packet loss, time 67ms
rtt min/avg/max/mdev = 0.459/0.501/0.538/0.030 ms
```
### Ping node-2
```
16:26:36 zuwarskej ~/project_devops/devops-training/02.module/02.task (module2) $ ping -c4 node-2
PING node-2 (172.16.10.3) 56(84) bytes of data.
64 bytes from node-2 (172.16.10.3): icmp_seq=1 ttl=64 time=0.474 ms
64 bytes from node-2 (172.16.10.3): icmp_seq=2 ttl=64 time=0.436 ms
64 bytes from node-2 (172.16.10.3): icmp_seq=3 ttl=64 time=0.599 ms
64 bytes from node-2 (172.16.10.3): icmp_seq=4 ttl=64 time=0.518 ms

--- node-2 ping statistics ---
4 packets transmitted, 4 received, 0% packet loss, time 76ms
rtt min/avg/max/mdev = 0.436/0.506/0.599/0.066 ms
```     
### Hostmanager output from /etc/hosts:
```
127.0.0.1	localhost
127.0.1.1	laptop

# AWS instances

# The following lines are desirable for IPv6 capable hosts
::1     localhost ip6-localhost ip6-loopback
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters

## vagrant-hostmanager-start id: 93481268-df74-4178-8150-f5440a487cf5
172.16.10.2	node-1
172.16.10.3	node-2
## vagrant-hostmanager-end
```