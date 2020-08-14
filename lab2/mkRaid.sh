#!/bin/bash
#		  sudo mdadm --zero-superblock --force /dev/sd{b,c,d,e,f}
		  sudo mdadm --create --verbose /dev/md0 -l 5 -n 5 /dev/sd{b,c,d,e,f}
		  sudo mkdir /etc/mdadm
		  echo "DEVICE partitions" > /etc/mdadm/mdadm.conf && mdadm --detail --scan --verbose | awk '/ARRAY/ {print}' >> /etc/mdadm/mdadm.conf
		  