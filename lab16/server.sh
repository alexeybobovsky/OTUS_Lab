#!/bin/bash
echo "***********************************************************************"
echo "***********Provision script on "$(hostname)
echo "***********************************************************************"
yum install -y rsyslog policycoreutils-python 
semanage port -m -t syslogd_port_t -p tcp 514
semanage port -m -t syslogd_port_t -p udp 514
sed -i 's/#$ModLoad imtcp/$ModLoad imtcp/; s/#$InputTCPServerRun 514/$InputTCPServerRun 514/; s/#$ModLoad imudp/$ModLoad imudp/; s/#$UDPServerRun 514/$UDPServerRun 514/' /etc/rsyslog.conf
echo -e "\n\$template HostAudit, \"/var/log/rsyslog/%HOSTNAME%/audit.log\"\nlocal6.* ?HostAudit\n\$template RemoteLogs,\"/var/log/rsyslog/%HOSTNAME%/%PROGRAMNAME%.log\"\n*.* ?RemoteLogs\n& ~\n" >> /etc/rsyslog.conf
sleep 5
systemctl start rsyslog && systemctl enable rsyslog
