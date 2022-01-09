# eigrpd-tools
random scripts and tools i use


Some common commands

     systemctl restart frr

Some handy vtysh cofic commands
     vtysh -c 'show running-config'
     vtysh -c 'configure terminal' -c 'service integrated-vtysh-config' -c 'router eigrp 4453' -c 'network 192.168.1.0/24'
