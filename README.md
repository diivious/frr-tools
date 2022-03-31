# eigrpd-tools
random scripts and tools i use


Some common commands

     systemctl restart frr

Some handy vtysh cofic commands

     // Basic setup - need to only do once
     vtysh -c 'show running-config'
     vtysh -c 'configure terminal' -c 'service integrated-vtysh-config' -c "end" -c "wr"

     // start eigrpd for debuging
     sudo gdb eigrpd/.libs/eigrpd 

     // Config for test topo
     vtysh -c 'debug eigrp packets hello' -c 'debug eigrp packets update' -c 'deb eigrp transmit send' -c 'deb eigrp transmit recv'
     vtysh -c 'configure terminal' -c 'router eigrp 4453' -c 'network 10.0.0.0/8' -c 'network 122.16.0.0/24' -c 'network 192.168.1.0/24'


------------------------------------------------
Test Topology
			   NAT to Host
				|
			   (enp0s3)
			   	|
	RTR1(E1) ----(enp0s8) FRR (enp0s9)---- (E2)RTR2
		 		|
			    (enp0s10)
			    	|


------------------------------------------------
FRR:
  enp0s3:  N/A
  enp0s8:  inet 10.0.0.250/8
  enp0s9:  inet 172.16.0.250/20
  enp0s10: inet 192.168.1.250/24 

interface GigabitEthernet2
  ip address 10.0.0.251 255.0.0.0
  no shut
  
interface GigabitEthernet3
  ip address 172.16.0.251 255.240.0.0
  shut

interface GigabitEthernet4
  ip address 192.168.1.251 255.255.255.0
  shut

------------------------------------------------
RTR1:
interface GigabitEthernet2
  ip address 10.0.0.251 255.0.0.0
  no shut
  
interface GigabitEthernet3
  ip address 172.16.0.251 255.240.0.0
  shut

interface GigabitEthernet4
  ip address 192.168.1.251 255.255.255.0
  shut

------------------------------------------------
RTR2:
interface GigabitEthernet2
  ip address 10.0.0.252 255.0.0.0
  shut
  
interface GigabitEthernet3
  ip address 172.16.0.252 255.240.0.0
  no shut

interface GigabitEthernet4
  ip address 192.168.1.252 255.255.255.0
  shut
  

