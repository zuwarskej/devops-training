## Calculate subnets: I used CIDR to divide network 212.100.54.0/24 to 8 subnets.
```
first subnet: 212.100.54.0/25
netmask: 255.255.255.128
adresses: 212.100.54.1-126
broadcast: 212.100.54.127

    second subnet: 212.100.54.128/26
    netmask: 255.255.255.192
    adresses: 212.100.54.129-190
    broadcast: 212.100.54.191

        third subnet: 212.100.54.192/27
        netmask: 255.255.255.224
        adresses: 212.100.54.193-222
        broadcast: 212.100.54.223

            forth subnet: 212.100.54.224/28
            netmask: 255.255.255.240
            adresses: 212.100.54.225-238
            broadcast: 212.100.54.239

                fifth subnet: 212.100.54.240/30
                netmask: 255.255.255.255.252
                adresses: 212.100.54.241-242
                broadcast: 212.100.54.243

                    sixth subnet: 212.100.54.244/30
                    netmask: 255.255.255.252
                    adresses: 212.100.54.245-246
                    broadcast: 212.100.54.247

                        seventh subnet: 212.100.54.248/30
                        netmask: 255.255.255.252
                        adresses: 212.100.54.249-250
                        broadcast: 212.100.54.251

                            eighth subnet: 212.100.54.252/30
                            netmask: 255.255.255.252
                            adresses: 212.100.54.253-254
                            broadcast: 212.100.54.255
```
