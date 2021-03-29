# Using disk utility from Vagrant for add more disks in VM's. 

## Before you should export variable:
```
export VAGRANT_EXPERIMENTAL="disk"
```
## Config example:
```
node.vm.disk :disk, size: "65GB", primary: true                 # Main disk
node.vm.disk :disk, size: "20GB", name: "extra_storage_1"       # Second disk
node.vm.disk :disk, size: "20GB", name: "extra_storage_2"       # Third disk
```
---
# Setup devicemapper for Docker. Using script bootstrap_lvm.sh for automation.
## Check lsblk (lvm group "docker"):
```
    node-1: NAME                      MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
    node-1: sda                         8:0    0   65G  0 disk 
    node-1: ├─sda1                      8:1    0  487M  0 part /boot
    node-1: ├─sda2                      8:2    0    1K  0 part 
    node-1: └─sda5                      8:5    0 63.5G  0 part 
    node-1:   ├─debian--10--vg-root   254:0    0 62.6G  0 lvm  /
    node-1:   └─debian--10--vg-swap_1 254:1    0  980M  0 lvm  [SWAP]
    node-1: sdb                         8:16   0   20G  0 disk 
    node-1: ├─docker-thinpool_tmeta   254:2    0  204M  0 lvm  
    node-1: │ └─docker-thinpool       254:4    0   19G  0 lvm  
    node-1: └─docker-thinpool_tdata   254:3    0   19G  0 lvm  
    node-1:   └─docker-thinpool       254:4    0   19G  0 lvm  
    node-1: sdc                         8:32   0   20G  0 disk 
```
## Add new storage to pool to make sure that the devicemapper is working properly:
```
$ sudo vgextend docker /dev/sdc
$ sudo lvextend -l+100%FREE -n docker/thinpool
```
## Check added new storage to devicemapper pool:
```
NAME                      MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
sda                         8:0    0   65G  0 disk 
├─sda1                      8:1    0  487M  0 part /boot
├─sda2                      8:2    0    1K  0 part 
└─sda5                      8:5    0 63.5G  0 part 
  ├─debian--10--vg-root   254:0    0 62.6G  0 lvm  /
  └─debian--10--vg-swap_1 254:1    0  980M  0 lvm  [SWAP]
sdb                         8:16   0   20G  0 disk 
├─docker-thinpool_tmeta   254:2    0  204M  0 lvm  
│ └─docker-thinpool       254:4    0 39.6G  0 lvm  
└─docker-thinpool_tdata   254:3    0 39.6G  0 lvm  
  └─docker-thinpool       254:4    0 39.6G  0 lvm  
sdc                         8:32   0   20G  0 disk 
└─docker-thinpool_tdata   254:3    0 39.6G  0 lvm  
  └─docker-thinpool       254:4    0 39.6G  0 lvm
```
---
# Setup raid 0 and raid 1 using mdadm. Using script bootstrap_mdadm.sh for automation.
## Check lsblk:
```
NAME                      MAJ:MIN RM  SIZE RO TYPE  MOUNTPOINT
sda                         8:0    0   65G  0 disk  
├─sda1                      8:1    0  487M  0 part  /boot
├─sda2                      8:2    0    1K  0 part  
└─sda5                      8:5    0 63.5G  0 part  
  ├─debian--10--vg-root   254:0    0 62.6G  0 lvm   /
  └─debian--10--vg-swap_1 254:1    0  980M  0 lvm   [SWAP]
sdb                         8:16   0    5G  0 disk  
└─md0                       9:0    0   10G  0 raid0 /var/raid0
sdc                         8:32   0    5G  0 disk  
└─md0                       9:0    0   10G  0 raid0 /var/raid0
sdd                         8:48   0    5G  0 disk  
└─md1                       9:1    0    5G  0 raid1 /var/raid1
sde                         8:64   0    5G  0 disk  
└─md1                       9:1    0    5G  0 raid1 /var/raid1
sdf                         8:80   0    5G  0 disk  
```
## Add spare disk to pool and then fail one of them to make sure that the raid 1 is working properly:
```
$ sudo mdadm /dev/md1 --add /dev/sdf                  # Add disk to pool
$ sudo mdadm /dev/md0 --fail /dev/sdd                 # Fail active disk
```
## Check rebuild:
```
vagrant@node-2:~$ sudo mdadm -D /dev/md1
/dev/md1:
           Version : 1.2
     Creation Time : Thu Mar 25 05:01:49 2021
        Raid Level : raid1
        Array Size : 5237760 (5.00 GiB 5.36 GB)
     Used Dev Size : 5237760 (5.00 GiB 5.36 GB)
      Raid Devices : 2
     Total Devices : 3
       Persistence : Superblock is persistent

       Update Time : Thu Mar 25 05:06:09 2021
             State : clean, degraded, recovering 
    Active Devices : 1
   Working Devices : 2
    Failed Devices : 1
     Spare Devices : 1

Consistency Policy : resync

    Rebuild Status : 15% complete

              Name : node-2:1  (local to host node-2)
              UUID : ebf9e6c6:c27a38b1:a7649bab:f59d0fe8
            Events : 28

    Number   Major   Minor   RaidDevice State
       2       8       80        0      spare rebuilding   /dev/sdf
       1       8       64        1      active sync   /dev/sde

       0       8       48        -      faulty   /dev/sdd
```
---
# Create systemd service for Puma. Using script bootstrap_puma.sh for automation.
## Config for puma.service:
```
[Unit]
Description=Puma HTTP Server
After=network.target

[Service]
Type=simple
User=vagrant
WatchdogSec=10
WorkingDirectory=/home/vagrant/app
Environment=RAILS_ENV=production

ExecStart=/bin/bash -lc '/usr/local/rvm/gems/ruby-3.0.0/bin/puma -C /home/vagrant/app/config/production.rb'
#ExecStop=/bin/bash -lc '/usr/local/rvm/gems/ruby-3.0.0/bin/pumapctl -F /home/vagrant/app/config/production.rb stop'
#ExecReload=/bin/bash -lc '/usr/local/rvm/gems/ruby-3.0.0/bin/pumactl -F /home/vagrant/app/config/production.rb phased-restart'

Restart=always
KillMode=process

[Install]
WantedBy=multi-user.target
```
## Config file for Puma app:
```
rails_env = "production"
environment rails_env

app_dir = "/home/vagrant/app" # Update me with your root rails app path

bind  "unix://#{app_dir}/puma.sock"
pidfile "#{app_dir}/puma.pid"
state_path "#{app_dir}/puma.state"
directory "#{app_dir}/"

stdout_redirect "#{app_dir}/log/puma.stdout.log", "#{app_dir}/log/puma.stderr.log", true

workers 2
threads 1,2

activate_control_app "unix://#{app_dir}/pumactl.sock"

prune_bundler
```
## Check status:
```
vagrant@node-1:~$ sudo systemctl status puma
● puma.service - Puma HTTP Server
   Loaded: loaded (/etc/systemd/system/puma.service; enabled; vendor preset: enabled)
   Active: active (running) since Mon 2021-03-29 21:19:51 UTC; 77ms ago
 Main PID: 26690 (bash)
    Tasks: 1 (limit: 542)
   Memory: 680.0K
   CGroup: /system.slice/puma.service
           └─26690 /bin/bash -lc /usr/local/rvm/gems/ruby-3.0.0/bin/puma -C /home/vagrant/app/config/production.rb

Mar 29 21:19:51 node-1 systemd[1]: Started Puma HTTP Server.
```

