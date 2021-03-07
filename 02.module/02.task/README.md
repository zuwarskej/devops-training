### ssh vagrant@ubuntu-1804-02 "cat /tmp/devops-training/02.module/02.module.txt" >> README.md
```
THIS IS TEXT FOR TEST FROM VAGRANT!!
```
### ping ubuntu-1804-02 -c 4 >> README.md
```
PING ubuntu-1804-02 (192.168.10.22) 56(84) bytes of data.
64 bytes from ubuntu-1804-02 (192.168.10.22): icmp_seq=1 ttl=64 time=0.672 ms
64 bytes from ubuntu-1804-02 (192.168.10.22): icmp_seq=2 ttl=64 time=0.436 ms
64 bytes from ubuntu-1804-02 (192.168.10.22): icmp_seq=3 ttl=64 time=0.800 ms
64 bytes from ubuntu-1804-02 (192.168.10.22): icmp_seq=4 ttl=64 time=0.746 ms

--- ubuntu-1804-02 ping statistics ---
4 packets transmitted, 4 received, 0% packet loss, time 12ms
rtt min/avg/max/mdev = 0.436/0.663/0.800/0.141 ms
```
### ssh vagrant@ubuntu-1804-03 "cat /tmp/devops-training/02.module/02.module.txt" >> README.md
```
THIS IS TEXT FOR TEST FROM VAGRANT!!
```
### ping ubuntu-1804-03 -c 4 >> README.md
```
PING ubuntu-1804-03 (192.168.10.23) 56(84) bytes of data.
64 bytes from ubuntu-1804-03 (192.168.10.23): icmp_seq=1 ttl=64 time=0.422 ms
64 bytes from ubuntu-1804-03 (192.168.10.23): icmp_seq=2 ttl=64 time=0.360 ms
64 bytes from ubuntu-1804-03 (192.168.10.23): icmp_seq=3 ttl=64 time=0.623 ms
64 bytes from ubuntu-1804-03 (192.168.10.23): icmp_seq=4 ttl=64 time=0.766 ms

--- ubuntu-1804-03 ping statistics ---
4 packets transmitted, 4 received, 0% packet loss, time 64ms
rtt min/avg/max/mdev = 0.360/0.542/0.766/0.163 ms
```