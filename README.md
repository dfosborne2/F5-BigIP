F5-BigIP
========

Python/Ruby/Bash related stuff to the BigIP

BigIPWhisperer :  Basic usage of the BigIP REST API (11.5 or newer of BigIP) to create nodes, pools, health monitors

bigip-gw: The SNAT killer! RC script designed to use a native interface to route public IPv4 traffic to or from a given                   interface on a server. Some assumptions are made:
1.) Must have SelfIP and Floater adderss in the same subnet as your nodes/pool members
2.) SelfIPs must be in consecutive order. ex: 10.10.10.20-10.10.10.21
3.) See https://devcentral.f5.com/codeshare/kill-snat-automap for more detail.

bigip-gw-config - The sysconfig file for bigip-gw. This is a sampple config, please adjust to your needs.



